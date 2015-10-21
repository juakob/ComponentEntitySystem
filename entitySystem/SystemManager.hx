package entitySystem;
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
	}
	public function update():Void
	{
		for (sys in mSystems) 
		{
			sys.update();
		}
		Message.clearWeak();
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
	public function subscribeEntity(aEntity:Entity, aMessage:String , aListenerId:Int):Void
	{
		aEntity.addListener(aMessage, aListenerId);
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
		aEntity.removeListener(aMessage,aListener);
	}
	

	public function dispatch(aMessage:Message):Void
	{
		var entity = aMessage.to;
		if (entity.listening(aMessage.event))
		{
			var listeners:Array<Int> = entity.listeners(aMessage.event);
			for (listener in listeners) 
			{
				mListeners.get(listener).handleEvent(aMessage);
			}
		}
		Message.clearWeak();
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