package entitySystem;


import com.TimeManager;
import entitySystem.Entity;
import entitySystem.constants.Constant;
import entitySystem.storage.ISave;
import entitySystem.storage.SaveData;


import net.FClient;

/**
 * ...
 * @author Joaquin
 */

typedef ES = SystemManager;

class SystemManager
{
	private var mSystemsDictionary:Map<Int,ISystem>;
	private var mListeners:Map<Int,IListener>;
	#if expose
		private var mEntities:Array<Entity>;
	#end
	private var mSystems:Array<ISystem>;
	private var mPropertiesPool:Map<Int,PropertyPool>;
	private var mBroadcast:Map<String,Array<Entity>>;
	
	var storage:ISave;
	var saveData:SaveData;
	public static var i(get,null):SystemManager;
	public static function get_i():SystemManager
	{
		return i;
	}
	public static function init():Void
	{
		#if !macro
		i = new SystemManager(new entitySystem.storage.SaveKhaImpl());
		#end
		
	}
	private function new(saveImp:ISave) 
	{
		
		storage = saveImp;
		if (storage.canLoad())
		{
			saveData = storage.load();
		}else {
			saveData = new SaveData();	
		}
		mSystems = new Array();
		mSystemsDictionary = new Map();
		mListeners = new Map();
		#if expose
			mEntities = new Array();
		#end
		mPropertiesPool = new Map();
		mBroadcast = new Map();
	}
	public function update(aDt:Float):Void
	{
		step = false;
		#if expose
		proccesNetMessages();
		#end
		if (pause && !step)
		{
			aDt = 0;
			TimeManager.setDelta(0,0);//temporal
		}
			for (sys in mSystems) 
			{
				sys.update();
			}
			
		
		processMessages(aDt);
		proceedWithDelete();
		
	}
	public function add(sys:ISystem):Void
	{
		mSystems.push(sys);
		mSystemsDictionary.set(sys.id(), sys);
	}
	public function add2(sys:ISystem,id:Int):Void
	{
		mSystems.push(sys);
		mSystemsDictionary.set(id, sys);
	}
	/**
	 * Groups dont get updated. Use groups to query specific data from there entities
	 * @param	sys
	 */
	public function addGroup(sys:ISystem):Void
	{
		mSystemsDictionary.set(sys.id(), sys);
	}
	public function addGroup2(sys:ISystem,id:Int):Void
	{
		mSystemsDictionary.set(id, sys);
	}
	//public function getProperty(aPorperty:Class<Property>):Property
	//{
		//var pool = mPropertiesPool.get((cast aPorperty).ID);
		//if (pool == null)
		//{
			//pool = new PropertyPool();
			//mPropertiesPool.set((cast aPorperty).ID, pool);
		//}
		//return pool.recycle(aPorperty);
	//}
	//public function storeProperty(aPorperty:Property):Void
	//{
		//var pool = mPropertiesPool.get(aPorperty.id());
		//if (pool == null)
		//{
			//pool = new PropertyPool();
			//mPropertiesPool.set(aPorperty.id(), pool);
		//}
		//pool.store(aPorperty);
	//}
	public function addListener(aListener:IListener)
	{
		mListeners.set(aListener.id(), aListener);
	}
	public function addListener2(aListener:IListener, id:Int) 
	{
		mListeners.set(id, aListener);
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
	
	
	public inline function addEntityToList(aEntity:Entity):Void
	{
		#if expose
		mEntities.push(aEntity);
		#end
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
	public function killPendingMessages(aEntity:Entity)
	{
		var counter = mMessages.length-1;
		while(counter>=0)
		{
			if (mMessages[counter].to!=null&&mMessages[counter].to.id == aEntity.id)
			{
				mMessages[counter].reset();
				mMessages.splice(counter, 1);
			}
			--counter;
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
	private function processMessages(aDt:Float):Void
	{
		while(mMessages.length>0) 
		{
			if (mMessages[0].delay-aDt <= 0)
			{
				sendMessage(mMessages.shift());
			}else {
				updateMessageDelay(aDt);
				break;
			}
		}
	
		Message.clearWeak();
	}
	private inline  function updateMessageDelay(aDt:Float):Void
	{
		for (message in mMessages)
		{
			message.delay -= aDt;
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
		aMessage.originalData = aMessage.data;
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
		aMessage.originalData = null;
	}
	var toDelete:Array<Entity> = new Array();
	public function deleteEntity(aEntity:Entity):Void
	{
		if(aEntity.Alive) toDelete.push(aEntity);
	}
	private function proceedWithDelete():Void
	{
		for (aEntity in toDelete)
		{
			var systems:Array<Int> = aEntity.Systems;
			for (i in systems) 
			{
				mSystemsDictionary.get(i).remove(aEntity);
			}
			#if expose
				mEntities.remove(aEntity);
			#end
			aEntity.destroy();
		}
		toDelete.splice(0, toDelete.length);
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
	
	public function getSystem(aId:Int):ISystem
	{
		return mSystemsDictionary.get(aId);
	}
	
	public function destroy():Void
	{
		mSystemsDictionary=null;
		mListeners = null;
		#if expose
			mEntities = null;
		#end
		mSystems.splice(0, mSystems.length);
		mSystems = null;
		mPropertiesPool = null;
		mBroadcast = null;
		Message.clearPool();
		ES.i = null;
		#if expose
		client.close();
		#end
	}
	var pause:Bool;
	var step:Bool;
	public inline function isPaused():Bool
	{
		return pause && !step;
	}
	
	#if expose
	private var factories:Array<EntityState> = new Array();
	public function getEntities():String
	{
		var encode:String="";
		for (entity in mEntities)
		{
			encode+= entity.name+"?" + entity.id+"*";
		}
		return encode;
	}
	public function getFactories():String
	{
		var encode:String="";
		for (factory in factories)
		{
			encode+= factory.name+"?"+factory.name+"*";
		}
		return encode;
	}
	var buffer:Entity;//avoid searching all the time
	public function getEntity(id:Int):Entity
	{
		if (buffer != null && buffer.id == id&&buffer.Alive)
		{
			return buffer;
		}
		for (entity in mEntities)
		{
			if (entity.id == id)
			{
				buffer = entity;
				return entity;
			}
		}
		
		return null;
	}
	public function getFactory(aId:String):EntityState
	{
		for (factory in factories) 
		{
			if (factory.name == aId)
			{
				return factory;
			}
		}
		throw "Factory "+aId+" not found";
	}
	var client:FClient = new FClient();
	public function proccesNetMessages():Void
	{
		client.update();
		var ignore1:Bool=false;
		var ignore2:Bool = false;
		var ignore10:Bool = false;
		var ignore3:Bool=false;
		while (client.messagesToRead() > 0)
		{
			var message:String = client.popMessage();
			var parts:Array<String> = message.split("?*");
			switch Std.parseInt(parts[0])
			{
				case 1://get entities
					if (!ignore1){
					ignore1 = true;
					client.write("1?*" + getEntities());
					}
					
				case 2: //get properties
					if (!ignore2)
					{
						ignore2 = true;
						var entity:Entity = getEntity(Std.parseInt(parts[1]));
						if (entity != null)
						{
						client.write("2?*" + parts[1] + "?*" + entity.serialize());
						}else
						{
							client.write("2?*" + parts[1] + "?* Dead" );
						}
					}
					case 3: //commands
					if (!ignore3)
					{
						ignore3 = true;
						if (parts[1] == "pause")
						{
							pause = true;
						}else
						if (parts[1] == "resume")
						{
							pause = false;
							step = false;
						}else
						if (parts[1] == "step")
						{
							pause = true;
							step = true;
						}
						dispatch(Message.weak(parts[1], null, null, null, true));
					}
				case 4://update value
					getEntity(Std.parseInt(parts[1])).get(Std.parseInt(parts[2])).setValue(Std.parseInt(parts[3]), parts[4]);
				case 5://update value
					var entity:Entity = getEntity(Std.parseInt(parts[1]));
						if (entity != null)
						{
							client.write("5?*" + parts[1] + "?*"+entity.getMetadata() );
						}
				case 6://show metadata
					var entity:Entity = getEntity(Std.parseInt(parts[1]));
					ES.i.dispatch(Message.weak("showMeta", null, entity, parts[2], true));
				case 7://send constants
					client.write("7?*" + getConstantsCSV());
				case 8://update constant value
					var constant:Dynamic = getConstant(parts[1]);
					constant.setValue(parts[2], parts[3]);
					client.write("7?*" + getConstantsCSV());// re send the update data
				case 9://show factories names
					client.write("9?*" + getFactories());
				case 10: //get factory properties
					if (!ignore10)
					{
						ignore10 = true;
						var entityS:EntityState = getFactory(parts[1]);
						if (entityS != null)
						{
							client.write("10?*" + parts[1] + "?*" + entityS.serialize());
						}
					}
				case 11://update value
					getFactory(parts[1]).get(Std.parseInt(parts[2])).setValue(Std.parseInt(parts[3]), parts[4]);
				case 12: //save factory properties
					{
						var entityS:EntityState = getFactory(parts[1]);
						if (entityS != null)
						{
							client.write("12?*" + parts[1] + "?*" + entityS.serialize());
						}
					}
				case 13:
					{
						var propertiesRaw:Array<String> = parts[1].split(";;");
						var factoryName:String = propertiesRaw.shift();
						var factory = getFactory(factoryName);
						propertiesRaw.pop();
						applyToFactory(factory, propertiesRaw);
						saveData.saveFactory(factory.name, parts[1]);
						storage.save(saveData);
					}
				default://nothing
			}
		}
	}
	function applyToFactory(factory:EntityState,parts:Array<String>)
	{
		var property:Property;
		for (part in parts) 
		{
			var propertyRaw:Array<String> = part.split("?");
			var propertyName:String = propertyRaw.shift();
			var propertyID:String = propertyRaw.shift();
			property = factory.getBy(propertyName);
			propertyRaw.pop();
			var counter:Int = 0;
			for (variableRaw in propertyRaw)
			{
				var variableParts:Array<String> = variableRaw.split(",");
				property.setValueBy(variableParts[0], variableParts[2]);
				++counter;
			}
		}
	}
	private var constants:Array<Dynamic> = new Array();
	public function getConstant(aId:String):Dynamic
	{
		for (constant in constants) 
		{
			if (constant.ID == aId)
			{
				return constant;
			}
		}
		throw "Constant not found";
	}
	public function getConstantsCSV():String
	{
		var encode:String = "";
		for (constant in constants) 
		{
			encode+=constant.toCSV()+";;";
		}
		return encode;
	}

	#end
	public inline function addConstant(constant:Dynamic)
	{
		#if expose
		constants.push(constant);
		#end
	}
	public  function addFactory(factory:EntityState)
	{
		#if expose
		factories.push(factory);
		client.write("9?*" + getFactories());
		
		var data = saveData.getData(factory.name);
		if (data != null)
		{
			var parts:Array<String> =	data.split(";;");
			var factoryName:String = parts.shift();
			parts.pop();
			applyToFactory(factory, parts);
		}
		#end
	}
	
	public function isInitialized():Bool
	{
		return i != null;
	}
	
	
}