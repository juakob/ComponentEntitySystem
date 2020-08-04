package entitySystem;

import com.TimeManager;
import entitySystem.Entity;
import entitySystem.Message.MessageID;
import entitySystem.constants.Constant;
import entitySystem.debug.Expose;
#if !macro
import entitySystem.helper.DelaySlotChange;
#end
import entitySystem.storage.ISave;
import entitySystem.storage.SaveData;
#if expose
import inspector.net.IServer;
import inspector.net.Local;
import inspector.net.LocalClient;
import net.FClient;
#end
/**
 * ...
 * @author Joaquin
 */
typedef ES = SystemManager;

class SystemManager {
	private var mSystemsDictionary:Map<Int, ISystem>;
	private var mListeners:Map<Int, IListener>;
	#if expose
	private var mEntities:Array<Entity>;
	#end
	private var mSystems:Array<ISystem>;
	private var mPropertiesPool:Map<Int, PropertyPool>;
	private var mBroadcast:Map<MessageID, Array<Entity>>;
	private var mSystemsClass:haxe.ds.List<Class<ISystem>>;
	private var mListenerClass:haxe.ds.List<Class<IListener>>;
	var storage:ISave;
	var saveData:SaveData;
	var id:Int=-1;

	public static var states:Array<SystemManager> = new Array();
	static var idCount:Int=0;

	public static var i(get, null):SystemManager;

	public static function get_i():SystemManager {
		return i;
	}

	public static function init():Void {
		#if !macro
		if (i != null)
			i.destroy();
		i = new SystemManager(new entitySystem.storage.SaveKhaImpl());
		#end
	}
	public static function newState():Int {
		#if !macro
		i = new SystemManager(new entitySystem.storage.SaveKhaImpl());
		i.id = idCount++;
		states.push(i);
		#end
		return i.id;
		
	}
	public static function changeState(id:Int) {
		for(state in states){
			if(state.id==id){
				i=state;
				return;
			}
		}
		throw "state id "+ id +" not found";
	}
	public static function destroyState(id:Int) {
		var toDestroy:SystemManager=null;
		for(state in states){
			if(state.id==id){
				toDestroy=state;
				break;
			}
		}
		if(toDestroy!=null){
			states.remove(toDestroy);
			toDestroy.destroy();
		}else{
			throw "state id "+ id +" not found";
		}
	}
	private function new(saveImp:ISave) {
		mSystemsClass =  CompileTime.getAllClasses(ISystem);
		mListenerClass =  CompileTime.getAllClasses(IListener);
		#if expose
		client = LocalClient.i; // new FClient();
		#end
		storage = saveImp;
		if (storage.canLoad()) {
			saveData = storage.load();
		} else {
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

	public function update(aDt:Float):Void {
		step = false;
		#if expose
		proccesNetMessages();
		#end
		processMessages(aDt);
		for (sys in mSystems) {
			sys.update();
		}

		
		#if !macro
		processDelaySlotChanges();
		#end
		proceedWithDelete();
	}

	public function addSystem(id:Int):Void {
		if(systemExists(id)) return;
		for (sys in mSystemsClass) {
			if (id == (cast sys).ID) {
				var system = Type.createInstance(sys, []);
				if (system == null)
					throw "cant create " + sys;
				add(system);
			}
		}
	}

	public function addListenerBy(id:Int):Void {
		for (sys in mListenerClass) {
			if (id == (cast sys).ID) {
				addListener(Type.createInstance(sys, []));
			}
		}
	}
	public function systemExists(id:Int):Bool {
		return mSystemsDictionary.exists(id);
	}
	public function add(sys:ISystem):Void {
		#if debug
		if(systemExists(sys.id())) throw "system added twice call systemExist()";
		#end
		mSystems.push(sys);
		mSystemsDictionary.set(sys.id(), sys);
	}

	public function add2(sys:ISystem, id:Int):Void {
		mSystems.push(sys);
		mSystemsDictionary.set(id, sys);
	}

	public function sortSystems():Void {
		mSystems.sort(function(a:ISystem, b:ISystem):Int {
			if(a.priority() < b.priority()) return 1;
			if(a.priority() > b.priority()) return -1;
			return 0;
		});
	}

	/**
	 * Groups dont get updated. Use groups to query specific data from there entities
	 * @param	sys
	 */
	public function addGroup(sys:ISystem):Void {
		mSystemsDictionary.set(sys.id(), sys);
	}
	public function addGroupBy(id):Void {
		if(systemExists(id)) return;
		for (sys in mSystemsClass) {
			if (id == (cast sys).ID) {
				var system = Type.createInstance(sys, []);
				if (system == null)
					throw "cant create " + sys;
				addGroup(system);
			}
		}
	}

	public function addGroup2(sys:ISystem, id:Int):Void {
		mSystemsDictionary.set(id, sys);
	}

	// public function getProperty(aPorperty:Class<Property>):Property
	// {
	// var pool = mPropertiesPool.get((cast aPorperty).ID);
	// if (pool == null)
	// {
	// pool = new PropertyPool();
	// mPropertiesPool.set((cast aPorperty).ID, pool);
	// }
	// return pool.recycle(aPorperty);
	// }
	// public function storeProperty(aPorperty:Property):Void
	// {
	// var pool = mPropertiesPool.get(aPorperty.id());
	// if (pool == null)
	// {
	// pool = new PropertyPool();
	// mPropertiesPool.set(aPorperty.id(), pool);
	// }
	// pool.store(aPorperty);
	// }
	public function addListener(aListener:IListener) {
		if (!mListeners.exists(aListener.id())) {
			mListeners.set(aListener.id(), aListener);
		}
	}

	public function addListener2(aListener:IListener, id:Int) {
		mListeners.set(id, aListener);
	}

	public function addEntity(aEntity:Entity, aSystemId:Int, aFirst:Bool = false):Void {
		if (aEntity.addSystem(aSystemId)) {
			if (mSystemsDictionary.get(aSystemId) == null)
				throw "cant add " + aSystemId;
			mSystemsDictionary.get(aSystemId).add(aEntity, aFirst);
		}
		#if debug
		else {
			trace("warning : entityId " + aEntity.id + " was re added to system " + mSystemsDictionary.get(aSystemId));
		}
		#end
	}

	public function subscribeEntity(aEntity:Entity, aMessage:MessageID, aListenerId:Int, aOverrideData:Dynamic = null, aBroadcast:Bool = false):Void {
		if (aEntity.addListener(aMessage, aListenerId, aOverrideData, aBroadcast) && aBroadcast) {
			if (mBroadcast.exists(aMessage)) {
				var list = mBroadcast.get(aMessage);
				for (entity in list) {
					if (entity.id == aEntity.id) {
						return;
					}
				}
				list.push(aEntity);
			} else {
				mBroadcast.set(aMessage, [aEntity]);
			}
		}
		#if debug
	//	else {
	//		trace("warning : entityId " + aEntity.id + " was not added to listener " + aMessage);
	//	}
		#end
	}

	public inline function addEntityToList(aEntity:Entity):Void {
		#if expose
		mEntities.push(aEntity);
		#end
	}

	public function removeEntity(aEntity:Entity, aSystemId:Int) {
		if(aEntity!=null){
			aEntity.removeSystem(aSystemId);
			mSystemsDictionary.get(aSystemId).remove(aEntity);
		}
	}

	public function unsubscribeEntity(aEntity:Entity, aMessage:MessageID, aListener:Int) {
		if (aEntity.removeListener(aMessage, aListener)) {
			removeBroadcast(aMessage, aEntity);
		}
	}

	var mMessages:Array<Message> = new Array();

	public function dispatch(aMessage:Message, aInstant:Bool = true):Void {
		if (aInstant && aMessage.delay == 0) {
			sendMessage(aMessage);
			return;
		}
		if (aMessage.delay <= 0 || mMessages.length == 0) {
			mMessages.unshift(aMessage);
		} else {
			insertMessageInOrder(aMessage);
		}
	}

	public function killPendingMessages(aEntity:Entity) {
		var counter = mMessages.length - 1;
		while (counter >= 0) {
			if (mMessages[counter].to != null && mMessages[counter].to.id == aEntity.id) {
				mMessages[counter].reset();
				mMessages.splice(counter, 1);
			}
			--counter;
		}
	}

	private function insertMessageInOrder(aMessage:Message):Void {
		var index:Int = mMessages.length - 1;
		while (index >= 0) {
			if (mMessages[index].delay < aMessage.delay) {
				mMessages.insert(index + 1, aMessage);
				return;
			}
			--index;
		}
		mMessages.unshift(aMessage);
	}

	private function processMessages(aDt:Float):Void {
		while (mMessages.length > 0) {
			if (mMessages[0].delay - aDt <= 0) {
				sendMessage(mMessages.shift());
			} else {
				updateMessageDelay(aDt);
				break;
			}
		}

		Message.clearWeak();
	}

	private inline function updateMessageDelay(aDt:Float):Void {
		for (message in mMessages) {
			message.delay -= aDt;
		}
	}

	private inline function sendMessage(aMessage:Message):Void {
		if (aMessage.broadcast && mBroadcast.exists(aMessage.event)) {
			var entities = mBroadcast.get(aMessage.event);
			for (entity in entities) {
				aMessage.to = entity;
				sendTo(aMessage);
			}
			aMessage.reset();
		} else {
			sendTo(aMessage);
			aMessage.reset();
		}
	}

	private function sendTo(aMessage:Message):Void {
		var entity = aMessage.to;
		var dataCopy = aMessage.data;
		aMessage.originalData = aMessage.data;
		if (entity != null && entity.listening(aMessage.event)) {
			#if expose
			entity.addMessage(aMessage);
			#end
			var listeners:Array<ListenerAux> = entity.listeners(aMessage.event);
			for (listener in listeners) {
				if (listener.data != null) {
					aMessage.data = listener.data;
				}
				mListeners.get(listener.id).onEvent(aMessage);
				aMessage.data = dataCopy;
			}
		}
		aMessage.originalData = null;
	}
	public function directProcess(listenerId:Int,aMessage:Message) {
		mListeners.get(listenerId).onEvent(aMessage);
	}

	var toDelete:Array<Entity> = new Array();

	public function deleteEntity(aEntity:Entity):Void {
		if (aEntity.Alive)
			toDelete.push(aEntity);
	}

	private function proceedWithDelete():Void {
		for (aEntity in toDelete) {
			var systems:Array<Int> = aEntity.Systems;
			for (i in systems) {
				mSystemsDictionary.get(i).remove(aEntity);
			}
			#if expose
			mEntities.remove(aEntity);
			#end
			aEntity.destroy();
		}
		toDelete.splice(0, toDelete.length);
	}

	public function removeBroadcast(aEvent:MessageID, aEntity:Entity):Void {
		var entities = mBroadcast.get(aEvent);
		var counter:Int = 0;
		for (entity in entities) {
			if (entity.id == aEntity.id) {
				entities.splice(counter, 1);
				return;
			}
			++counter;
		}
	}

	public function getSystem(aId:Int):ISystem {
		return mSystemsDictionary.get(aId);
	}

	public function destroy():Void {
		mSystemsDictionary = null;
		for(listener in mListeners){
			listener.destroy();
		}
		mListeners = null;
		#if expose
		mEntities = null;
		Expose.i.destroy();
		#end
		while(mSystems.length>0)
		{
			mSystems.pop().destroy();
		}
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

	public inline function isPaused():Bool {
		return pause && !step;
	}

	#if expose
	private var factories:Array<EntityState> = new Array();

	public function getEntities():String {
		var encode:String = "";
		for (entity in mEntities) {
			encode += entity.name + "?" + entity.id + "*";
		}
		return encode;
	}

	public function getFactories():String {
		var encode:String = "";
		/*for (factory in factories) {
			encode += factory.name + "?" + factory.name + "*";
		}*/
		return encode;
	}

	var buffer:Entity; // avoid searching all the time

	public function getEntity(id:Int):Entity {
		if (buffer != null && buffer.id == id && buffer.Alive) {
			return buffer;
		}
		for (entity in mEntities) {
			if (entity.id == id) {
				buffer = entity;
				return entity;
			}
		}

		return null;
	}

	public function getFactory(aId:String):EntityState {
	/*	for (factory in factories) {
			if (factory.name == aId) {
				return factory;
			}
		}*/
		throw "Factory " + aId + " not found";
	}

	var client:IServer;

	public function proccesNetMessages():Void {
		client.update();
		var ignore1:Bool = false;
		var ignore2:Bool = false;
		var ignore10:Bool = false;
		var ignore3:Bool = false;
		while (client.messagesToRead() > 0) {
			var message:String = client.popMessage();
			var parts:Array<String> = message.split("?*");
			switch Std.parseInt(parts[0]) {
				case 1: // get entities
					if (!ignore1) {
						ignore1 = true;
						client.send("1?*" + getEntities());
					}

				case 2: // get properties
					if (!ignore2) {
						ignore2 = true;
						var entity:Entity = getEntity(Std.parseInt(parts[1]));
						if (entity != null) {
							client.send("2?*" + parts[1] + "?*" + entity.serialize());
						} else {
							client.send("2?*" + parts[1] + "?* Dead");
						}
					}
				case 3: // commands
					if (!ignore3) {
						ignore3 = true;
						if (parts[1].indexOf("pause")>-1) {
							pause = true;
						} else if (parts[1].indexOf("resume")>-1) {
							pause = false;
							step = false;
						} else if (parts[1].indexOf("step")>-1) {
							pause = true;
							step = true;
						}
						dispatch(Message.weak(Message.dynamicID(parts[1]), null, null, null, true));
					}
				case 4: // update value
					getEntity(Std.parseInt(parts[1])).get(Std.parseInt(parts[2])).setValue(Std.parseInt(parts[3]), parts[4]);
				case 5: // update value
					var entity:Entity = getEntity(Std.parseInt(parts[1]));
					if (entity != null) {
						client.send("5?*" + parts[1] + "?*" + entity.getMetadata());
					}
				case 6: // show metadata
					var entity:Entity = getEntity(Std.parseInt(parts[1]));
					ES.i.dispatch(Message.weak(Message.id("showMeta"), null, entity, parts[2], true));
				case 7: // send constants
					client.send("7?*" + getConstantsCSV());
				case 8: // update constant value
					var constant:Dynamic = getConstant(parts[1]);
					constant.setValue(parts[2], parts[3]);
					client.send("7?*" + getConstantsCSV()); // re send the update data
				case 9: // show factories names
					client.send("9?*" + getFactories());
				case 10: // get factory properties
					if (!ignore10) {
						ignore10 = true;
						var entityS:EntityState = getFactory(parts[1]);
						if (entityS != null) {
							client.send("10?*" + parts[1] + "?*" + entityS.serialize());
						}
					}
				case 11: // update value
					getFactory(parts[1]).get(Std.parseInt(parts[2])).setValue(Std.parseInt(parts[3]), parts[4]);
				case 12: // save factory properties
					{
						var entityS:EntityState = getFactory(parts[1]);
						if (entityS != null) {
							client.send("12?*" + parts[1] + "?*" + entityS.serialize());
						}
					}
				case 13: // save factory local
					{
						var propertiesRaw:Array<String> = parts[1].split(";;");
						var factoryName:String = propertiesRaw.shift();
						var factory = getFactory(factoryName);
						propertiesRaw.pop();
						applyToFactory(factory, propertiesRaw);
//						saveData.saveFactory(factory.name, parts[1]);
						storage.save(saveData);
					}
				case 14: // get messages
					{
						var entity:Entity = getEntity(Std.parseInt(parts[1]));
						if (entity != null) {
							entity.messageRecord = true;
							client.send("13?*" + parts[1] + "?*" + entity.getMessagesData());
						}
					}
				case 15: // get expose objects
					{
						client.send("14?*" + Expose.i.encode());
					}
				case 16:
					{
						Expose.i.set(Std.parseInt(parts[1]), parts[2]);
					}
				default: // nothing
			}
		}
	}

	function applyToFactory(factory:EntityState, parts:Array<String>) {
		var property:Property;
		for (part in parts) {
			var propertyRaw:Array<String> = part.split("?");
			var propertyName:String = propertyRaw.shift();
			var propertyID:String = propertyRaw.shift();
			property = factory.getBy(propertyName);
			propertyRaw.pop();
			var counter:Int = 0;
			for (variableRaw in propertyRaw) {
				var variableParts:Array<String> = variableRaw.split(",");
				property.setValueBy(variableParts[0], variableParts[2]);
				++counter;
			}
		}
	}

	private var constants:Array<Dynamic> = new Array();

	public function getConstant(aId:String):Dynamic {
		for (constant in constants) {
			if (constant.ID == aId) {
				return constant;
			}
		}
		throw "Constant not found";
	}

	public function getConstantsCSV():String {
		var encode:String = "";
		for (constant in constants) {
			encode += constant.toCSV() + ";;";
		}
		return encode;
	}
	#end

	public inline function addConstant(constant:Dynamic) {
		#if expose
		constants.push(constant);
		#end
	}

	public function addFactory(factory:EntityState) {
		#if expose
		factories.push(factory);
		client.send("9?*" + getFactories());

	/*	var data = saveData.getData(factory.name);
		if (data != null) {
			var parts:Array<String> = data.split(";;");
			var factoryName:String = parts.shift();
			parts.pop();
			applyToFactory(factory, parts);
		}*/
		#end
	}

	public function isInitialized():Bool {
		return i != null;
	}

	#if !macro
	var delaySlotChanges:Array<DelaySlotChange> = new Array();
	var slotChangeCounter:Int = 0;

	public function changeStateDelay(prStateManager:entitySystem.properties.PrStateManager, aSlot:String, aState:String, aEntity:Entity) {
		if (delaySlotChanges.length <= slotChangeCounter)
			delaySlotChanges.push(new DelaySlotChange());
		var slotChange = delaySlotChanges[slotChangeCounter];
		slotChange.stateManager = prStateManager;
		slotChange.slot = aSlot;
		slotChange.state = aState;
		slotChange.entity = aEntity;
		++slotChangeCounter;
	}

	function processDelaySlotChanges() {
		var counter:Int = 0;
		var totalCounter:Int = slotChangeCounter;
		var traceInfo:Bool = false;
		while (counter < totalCounter) {
			var slotChange = delaySlotChanges[counter];
			slotChange.stateManager.changeDelay(slotChange.slot, slotChange.state, slotChange.entity);
			++counter;
			slotChange.reset();
		}
		slotChangeCounter = 0;
	}
	#end
}
