package entitySystem;
import entitySystem.SystemManager.ES;


/**
 * ...
 * @author Joaquin
 */
class Entity
{
	private static var s_id:Int = 0;
	public var id:Int;
	public var Alive:Bool;
	public var InPool:Bool;
	private var mProperties:Map<Int,Property>;
	public var Systems(default, null):Array<Int>;
	public var Listening(default, null):Map<String,Array<ListenerAux>>;
	private var mBroadcast:Array<BroadcastAux>;
	public function new() 
	{
		Alive = true;
		id =++s_id;
		mProperties = new Map();
		Systems = new Array();
		Listening = new Map();
		mBroadcast = new Array();
		SystemManager.i.addEntityToDictionary(this);//TODO Is this necesary?
	}
	public function add(aProperty:Property, aCopy:Bool = false ):Void
	{
		if (!aCopy)
		{
			mProperties.set(aProperty.id(), aProperty);
		}else {
			if (mProperties.exists(aProperty.id()))
			{
				mProperties.get(aProperty.id()).set(aProperty);
			}else {
				mProperties.set(aProperty.id(), aProperty.clone());
			}
		}
	}
	public function get(aId:Int):Property
	{
		return mProperties.get(aId);
	}
	public function getVersion(aId:Int,version:Int):Property
	{
		var prop:Property = mProperties.get(aId);
		var first = prop;
		while (prop != null)
		{
			if (prop.versionId == version)
			{
				return prop;
			}
			prop = prop.nextProperty;
		}
		return first;
	}
	public function remove(aId:Int):Void
	{
		mProperties.remove(aId);
	}
	public function addSystem(aSystemId:Int):Bool
	{
		if (Systems.indexOf(aSystemId) != -1)
		{
			return false;
		}
		Systems.push(aSystemId);
		return true;
	}

	public function addListener(aMessage:String, aListenerId:Int, aOverrideData:Dynamic = null, aBroadcast:Bool = false ):Bool
	{
		if (!Listening.exists(aMessage))
		{
			Listening.set(aMessage, [new ListenerAux(aListenerId, aOverrideData, aBroadcast)]);
			if (aBroadcast)
			{
				mBroadcast.push(new BroadcastAux(aListenerId, aMessage));
			}
			return true;
		}
		var listeners = Listening.get(aMessage);
		for (listener in listeners)
		{
			if (listener.id == aListenerId)
			{
				return false; //already added
			}
		}
		
		listeners.push(new ListenerAux(aListenerId, aOverrideData,aBroadcast));
		if (aBroadcast)
		{
			mBroadcast.push(new BroadcastAux(aListenerId,aMessage));
		}
		return true;
	}
	public function inSystem(aSystemId:Int):Bool
	{
		return Systems.indexOf(aSystemId) > -1;
	}
	public inline function listening(aMessage:String):Bool
	{
		return Alive&&Listening.exists(aMessage);
	}
	public inline function listeners(aMessage:String):Array<ListenerAux>
	{
		return Listening.get(aMessage);
	}
	
	public function removeSystem(id:Int):Void 
	{
		var index:Int = Systems.indexOf(id);
		if (index > -1)
		{
			Systems.splice(index, 1);
		}
	}
	public function removeListener(aMessage:String,aListenerId:Int):Bool
	{
		var listeners = Listening.get(aMessage);
		var index:Int = -1; 
		var counter:Int = 0;
		var broadcast:Bool=false;
		for (listener in listeners)
		{
			if (listener.id == aListenerId)
			{
				broadcast = listener.broadcast;
				index = counter;
				break;
			}
			++counter;
		}
		if (index > -1)
		{
			listeners.splice(index, 1);
		}
		if (broadcast)
		{
			var indexs:Array<Int> = [];
			for (listener in mBroadcast)
			{
				if (listener.message == aMessage)
				{
					if (listener.id == aListenerId)
					{
						indexs.push(counter);
					}else {
						broadcast = false;	//we have more than one subscription
					}
				}
				++counter;
			}
			counter = 0;
			for (index in indexs) 
			{
				mBroadcast.splice(index-counter, 1);
				--counter;
			}
			
		}
		return broadcast;
	}
	public function kill():Void
	{
		ES.i.deleteEntity(this);
		
	}
	//public function clone():Void
	//{
		//var clone:Entity = new Entity();
		//var keys = mProperties.keys();
		//for (key in keys) 
		//{
			//clone.mProperties.set(key, mProperties.get(key).clone());
		//}
		//for (systemId in Systems) 
		//{
			//SystemManager.i.addEntity(clone, systemId);
		//}
		//for (listenerId in Listeners) 
		//{
			//SystemManager.i.subscribeEntity(clone, listenerId);
		//}
	//}
	
	
	
	
	/**
	 * Call kill or SystemManager.deleteEntity(aEntity:Entity) to destroy an entity
	 */
	public function destroy() 
	{
		Alive = false;
		if (InPool)
		{
			Systems.splice(0, Systems.length);
			return;
		}
		var properties = mProperties.iterator();
		for (property in properties) 
		{
			ES.i.storeProperty(property);
		}
		mProperties = null;
		Systems = null;
		Listening = null;
		for (listener in mBroadcast) 
		{
			ES.i.removeBroadcast(listener.message, this);
		}
		mBroadcast = null;
	}
	
	public function hasProperty(id:Int) :Bool
	{
		return mProperties.exists(id);
	}
}
class ListenerAux
{	
	public var id:Int;
	public var data:Dynamic;
	public var broadcast:Bool;
	public function new(aId:Int,aData:Dynamic=null,aBroadcast:Bool=false)
	{
		id = aId;
		data = aData;
		broadcast = aBroadcast;
	}
}
class BroadcastAux
{
	public var message:String;
	public var id:Int;
	public function new(aId:Int,aMessage:String)
	{
		id = aId;
		message = aMessage;
	}
}