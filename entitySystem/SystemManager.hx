package entitySystem;
import com.TimeManager;
import entitySystem.Entity;

/**
 * ...
 * @author Joaquin
 */

typedef ES = SystemManager;

class SystemManager
{
	private var mSystemsDictionary:Map<Int,ISystem>;
	private var mListeners:Map<Int,IListener>;
	private var mEntities:Map<Int,Entity>;
	private var mSystems:Array<ISystem>;
	private var mPropertiesPool:Map<Int,PropertyPool>;
	private var mBroadcast:Map<String,Array<Entity>>;
	
	public static var i(get,null):SystemManager;
	public static function get_i():SystemManager
	{
		return i;
	}
	public static function init():Void
	{
		i = new SystemManager();
	}
	private function new() 
	{
		mSystems = new Array();
		mSystemsDictionary = new Map();
		mListeners = new Map();
		mEntities = new Map();
		mPropertiesPool = new Map();
		mBroadcast = new Map();
	}
	public function update():Void
	{
		for (sys in mSystems) 
		{
			sys.update();
		}
		processMessages();
	}
	public function add(sys:ISystem):Void
	{
		mSystems.push(sys);
		mSystemsDictionary.set(sys.id(), sys);
	}
	/**
	 * Groups dont get updated. Use groups to query specific data of a group o entities
	 * @param	sys
	 */
	public function addGroup(sys:ISystem):Void
	{
		mSystemsDictionary.set(sys.id(), sys);
	}
	public function getProperty(aPorperty:Class<Property>):Property
	{
		var pool = mPropertiesPool.get((cast aPorperty).ID);
		if (pool == null)
		{
			pool = new PropertyPool();
			mPropertiesPool.set((cast aPorperty).ID, pool);
		}
		return pool.recycle(aPorperty);
	}
	public function storeProperty(aPorperty:Property):Void
	{
		var pool = mPropertiesPool.get(aPorperty.id());
		if (pool == null)
		{
			pool = new PropertyPool();
			mPropertiesPool.set(aPorperty.id(), pool);
		}
		pool.store(aPorperty);
	}
	public function addListener(aListener:IListener)
	{
		mListeners.set(aListener.id(), aListener);
	}
	public function addEntity(aEntity:Entity, aSystemId:Int,aFirst:Bool=false): Void
	{
		if (aEntity.addSystem(aSystemId))
		{
			mSystemsDictionary.get(aSystemId).add(aEntity, aFirst);
		}
	}
	public function subscribeEntity(aEntity:Entity, aMessage:String , aListenerId:Int, aOverrideData:Dynamic = null, aBroadcast:Bool = false):Void
	{
		
		if ( aEntity.addListener(aMessage, aListenerId, aOverrideData,aBroadcast) && aBroadcast )
		{
			if (mBroadcast.exists(aMessage))
			{
				var list = mBroadcast.get(aMessage);
				for (entity in list)
				{
					if (entity.id == aEntity.id)
					{
						return;
					}
				}
				list.push(aEntity);
			}else {
				mBroadcast.set(aMessage, [aEntity]);
			}
		}
	}
	
	//Look if this is needed
	public function addEntityToDictionary(aEntity:Entity):Void
	{
		mEntities.set(aEntity.id, aEntity);
	}
	
	public function removeEntity(aEntity:Entity, aSystemId:Int) 
	{
		aEntity.removeSystem(aSystemId);
		mSystemsDictionary.get(aSystemId).remove(aEntity);
	}
	public function unsubscribeEntity(aEntity:Entity,aMessage:String, aListener:Int)
	{
		if (aEntity.removeListener(aMessage, aListener))
		{
			removeBroadcast(aMessage, aEntity);
		}
	}
	
	var mMessages:Array<Message> = new Array();
	
	public function dispatch(aMessage:Message, aInstant:Bool = true ):Void
	{
		if (aInstant&&aMessage.delay==0)
		{
			sendMessage(aMessage);
			return;
		}
		if (aMessage.delay <= 0 ||mMessages.length==0)
		{
			mMessages.unshift(aMessage);
		}else {
			insertMessageInOrder(aMessage);
		}
	}
	private  function insertMessageInOrder(aMessage:Message):Void
	{
		var index:Int = mMessages.length - 1;
		while (index >= 0)
		{
			if (mMessages[index].delay < aMessage.delay)
			{
				mMessages.insert(index + 1, aMessage);
				return;
			}
			--index;
		}
		mMessages.unshift(aMessage);
	}
	private function processMessages():Void
	{
		while(mMessages.length>0) 
		{
			if (mMessages[0].delay-TimeManager.delta <= 0)
			{
				sendMessage(mMessages.shift());
			}else {
				updateMessageDelay();
				break;
			}
		}
	
		Message.clearWeak();
	}
	private inline function updateMessageDelay():Void
	{
		for (message in mMessages)
		{
			message.delay -= TimeManager.delta;
		}
	}
	private inline  function sendMessage(aMessage:Message):Void
	{
		if (aMessage.broadcast && mBroadcast.exists(aMessage.event))
		{
			var entities = mBroadcast.get(aMessage.event);
			for (entity in entities) 
			{
				aMessage.to = entity;
				sendTo(aMessage);
			}
			aMessage.reset();
		}else {
			sendTo(aMessage);	
			aMessage.reset();
		}
	}
	private  function sendTo(aMessage:Message):Void
	{
		var entity = aMessage.to;
		var dataCopy = aMessage.data;
		if (entity!=null&&entity.listening(aMessage.event))
		{
			var listeners:Array<ListenerAux> = entity.listeners(aMessage.event);
			for (listener in listeners) 
			{
				if (listener.data != null)
				{
					aMessage.data = listener.data;
				}
				mListeners.get(listener.id).onEvent(aMessage);
				aMessage.data = dataCopy;
			}
		}
	}

	public function deleteEntity(aEntity:Entity):Void
	{
		var systems:Array<Int> = aEntity.Systems;
		for (i in systems) 
		{
			mSystemsDictionary.get(i).remove(aEntity);
		}
		mEntities.remove(aEntity.id);
		aEntity.destroy();
	}
	public function removeBroadcast(aEvent:String, aEntity:Entity):Void
	{
		var entities = mBroadcast.get(aEvent);
		var counter:Int = 0;
		for (entity in entities) 
		{
			if (entity.id == aEntity.id)
			{
				entities.splice(counter, 1);
				return;
			}
			++counter;
		}
	}
	public function getEntity(aId:Int):Entity
	{
		return mEntities.get(aId);
	}
	public function getSystem(aId:Int):ISystem
	{
		return mSystemsDictionary.get(aId);
	}
	
	public function destroy():Void
	{
		mSystemsDictionary=null;
		mListeners=null;
		mEntities=null;
		mSystems=null;
		mPropertiesPool = null;
		ES.i = null;
	}
	
}