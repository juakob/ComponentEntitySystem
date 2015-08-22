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
	private var mEventSystem:EventSystem;
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
		mEventSystem = new EventSystem();
		mEntities = new Map();
		mPropertiesPool = new Map();
	}
	public function update():Void
	{
		for (sys in mSystems) 
		{
			sys.update();
		}
	}
	public function add(sys:ISystem):Void
	{
		mSystems.push(sys);
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
	public function subscribeEntity(aEntity:Entity, aListenerId:Int):Void
	{
		if (aEntity.addListener(aListenerId))
		{
			mListeners.get(aListenerId).add(aEntity);
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
	public function unsubscribeEntity(aEntity:Entity, aListener:Int)
	{
		aEntity.removeListener(aListener);
		mListeners.get(aListener).remove(aEntity);
	}
	

	public function dispatch(aMessage:Message, aBrodcast:Bool = false):Void
	{
		mEventSystem.dispach(aMessage, aBrodcast);
	}
	public function subscribe(aEvent:String,aSystemId:Int):Void
	{
		mEventSystem.subscribe(aEvent, mListeners.get(aSystemId));
	}
	public function unsubscribe(aEvent:String,aSystemId:Int):Void
	{
		mEventSystem.remove(aEvent, mListeners.get(aSystemId));
	}

	
	public function deleteEntity(aEntity:Entity):Void
	{
		var systems:Array<Int> = aEntity.Systems;
		for (i in systems) 
		{
			mSystemsDictionary.get(i).remove(aEntity);
		}
		var listeners:Array<Int> = aEntity.Listeners;
		for (i in listeners) 
		{
			mListeners.get(i).remove(aEntity);
		}
		mEntities.remove(aEntity.id);
		aEntity.destroy();
	}
	public function getEntity(aId:Int):Entity
	{
		return mEntities.get(aId);
	}
	
	public function destroy():Void
	{
		mSystemsDictionary=null;
		mListeners=null;
		mEntities=null;
		mSystems=null;
		mEventSystem=null;
		mPropertiesPool = null;
		ES.i = null;
	}
	
}