package entitySystem;
import entitySystem.Message.MessageID;
import entitySystem.SystemManager.ES;
import entitySystem.debug.MessageProxy;


/**
 * ...
 * @author Joaquin
 */
class Entity
{
	#if expose
	public var messages:Array<MessageProxy> = new Array();
	public var messageBufferSize:Int = 5;
	public var messageRecord:Bool;
	public function addMessage(aMessage:Message)
	{
		if (!messageRecord) return;
		if (messages.length == messageBufferSize)
		{
			var message = messages.pop();
			message.copy(aMessage);
			messages.unshift(message);
		}else {
			messages.push(new MessageProxy(aMessage));
		}
	}
	public function getMessagesData() {
		var string:String = "";
		var length:Int = messages.length;
		for (x in 0...length) 
		{
			string += messages.shift()+";;";
		}
		
		return string;
	}
	#end
	private static var s_id:Int = 0;
	public var id:Int;
	public var logicChildID:Int;
	public var Alive:Bool;
	public var InPool:Bool;
	public var name:String;
	private var mProperties:Map<Int,Property>;
	public var Systems(default, null):Array<Int>;
	public var Listening(default, null):Map<MessageID,Array<ListenerAux>>;
	private var mBroadcast:Array<BroadcastAux>;
	private var mChild:Entity;
	private var mNext:Entity = null;
	public function new() 
	{
		Alive = true;
		id =++s_id;
		mProperties = new Map();
		Systems = new Array();
		Listening = new Map();
		mBroadcast = new Array();
		#if expose
		SystemManager.i.addEntityToList(this);
		#end
	}
	public function add(aProperty:Property, aCopy:Bool = false ):Void
	{
		if (!aCopy)
		{
			mProperties.set(aProperty.id(), aProperty);
		}else {
			if (mProperties.exists(aProperty.id()))
			{
				aProperty.applyTo(mProperties.get(aProperty.id()));
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

	public function addListener(aMessage:MessageID, aListenerId:Int, aOverrideData:Dynamic = null, aBroadcast:Bool = false ):Bool
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
	public inline function listening(aMessage:MessageID):Bool
	{
		return Alive&&Listening.exists(aMessage);
	}
	public inline function listeners(aMessage:MessageID):Array<ListenerAux>
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
	public function removeListener(aMessage:MessageID,aListenerId:Int):Bool
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
		if (Alive) {
			ES.i.deleteEntity(this);
			Alive = false;
		}
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
		var nextChild:Entity = mChild;
		while (nextChild!=null) 
		{
			var last = nextChild;
			nextChild = nextChild.mNext;
			ES.i.deleteEntity(last);
		}
		mChild = null;
		mNext = null;
		
		if (InPool)
		{
			Listening = new Map();
			for (listener in mBroadcast) 
			{
				ES.i.removeBroadcast(listener.message, this);
			}
			mBroadcast.splice(0, mBroadcast.length);
			Systems.splice(0, Systems.length);
			return;
		}
		
		//var properties = mProperties.iterator();
		//for (property in properties) 
		//{
			//ES.i.storeProperty(property);
		//}
		mProperties = null;
		Systems = null;
		Listening = null;
		for (listener in mBroadcast) 
		{
			ES.i.removeBroadcast(listener.message, this);
		}
		mBroadcast = null;
	}
	
	public function addChild(aEntity:Entity)
	{
		if (mChild == null)
		{
			mChild = aEntity;
			return;
		}
		var next = mChild;
		while (true)
		{
			if (next.mNext != null)
			{
				next = next.mNext;
				continue;
			}
			next.mChild = aEntity;
			return;
		}
	}
	public function getChild(aLogicChildId:Int):Entity
	{
		var next = mChild;
		while (next!=null)
		{
			if (next.logicChildID == aLogicChildId)
			{
				return next;
			}
			next = next.mNext;
		}
		throw "no child with logic id " + aLogicChildId;
	}
	
	public function hasProperty(id:Int) :Bool
	{
		return mProperties.exists(id);
	}
	#if expose
	public function serialize():String
	{
		var encode:String = "";
		for (prop in mProperties) 
		{
			encode+=prop.serialize();
		}
		return encode;
	}
	#end
	
	#if expose
	public function getMetadata():String
	{
		var encode:String = "";
		for (prop in mProperties) 
		{
			encode+=prop.getMetadata()+";;";
		}
		return encode;
	}
	#end
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
	public var message:MessageID;
	public var id:Int;
	public function new(aId:Int,aMessage:MessageID)
	{
		id = aId;
		message = aMessage;
	}
}