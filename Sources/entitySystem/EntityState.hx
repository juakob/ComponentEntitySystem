package entitySystem;


import entitySystem.SystemManager.ES;
import entitySystem.Message.MessageID;
import entitySystem.properties.ComplexProperty;


/**
 * ...
 * @author Joaquin
 */
class EntityState {

	private var mSystems:Array<SystemAux>;
	private var mGroups:Array<SystemAux>;
	private var mRequiredSystems:Array<Int>;
	private var mRequiredListeners:Array<Int>;
	private var mPropertiesToAdd:Array<PropertyAux>;
	private var mPropertiesToRemove:Array<Int>;
	private var mComplexProperties:Array<ComplexProperty>;
	private var mListener:Array<ListenerAux>;
	private var mMessages:Array<Message>;

	public var onSet:Entity->Void;
	public var onRemove:Entity->Void;
	public var mStates:Array<EntityState>;

	var mChildID:Int;
	var mChildren:Array<EntityState>;

	public function new() {
		mSystems = new Array();
		mGroups = new Array();
		mRequiredSystems = new Array();
		mRequiredListeners = new Array();
		mPropertiesToAdd = new Array();
		mPropertiesToRemove = new Array();
		mComplexProperties = new Array();
		mListener = new Array();
		mMessages = new Array();
		mChildren = new Array();
		mStates = new Array();
	}

	public function addSystem(aSystem:Int):Void {
		mSystems.push(new SystemAux(aSystem, true));
	}
	public function addGroup(aGroup:Int):Void {
		mGroups.push(new SystemAux(aGroup, true));
	}

	public function init():Void {
		for (sys in mSystems) {
			if (sys.add) {
				ES.i.addSystem(sys.id);
			}
		}
		for(group in mGroups){
			if(group.add){
				ES.i.addGroupBy(group.id);
			}
		}
		for (sysId in mRequiredSystems) {
			ES.i.addSystem(sysId);
		}
		for (listener in mListener) {
			if (listener.add) {
				ES.i.addListenerBy(listener.id);
			}
		}
		for (listenerId in mRequiredListeners) {
			ES.i.addListenerBy(listenerId);
		}
		for(child in mChildren){
			child.init();
		}
		ES.i.sortSystems();
	}

	public function removeSystem(aSystem:Int):Void {
		mSystems.push(new SystemAux(aSystem, false));
	}
	public function removeGroup(aGroup:Int):Void {
		mGroups.push(new SystemAux(aGroup, false));
	}

	public function addListeneing(aMessage:MessageID, aSystem:Int, aOverrideData:Dynamic = null, aBroadcast:Bool = false):Void {
		mListener.push(new ListenerAux(aSystem, aMessage, true, aOverrideData, aBroadcast));
	}

	public function requireSystem(aSystem:Int):Void {
		mRequiredSystems.push(aSystem);
	}

	public function requireListeners(aSystem:Int):Void {
		mRequiredListeners.push(aSystem);
	}

	public function removeListeneing(aMessage:MessageID, aSystem:Int, aOverrideData:Dynamic = null, aBroadcast:Bool = false):Void {
		mListener.push(new ListenerAux(aSystem, aMessage,false, aOverrideData, aBroadcast));
	}

	public function addProperty(aProperty:Property, aDelete:Bool = false):Void {
		mPropertiesToAdd.push(new PropertyAux(aProperty, aDelete));
	}

	public function removeProperty(aId:Int):Void {
		mPropertiesToRemove.push(aId);
	}

	public function addComplexProperty(aProperty:ComplexProperty, aOverride:Bool = true):Void {
		mComplexProperties.push(aProperty);
	}

	public function addMessage(aMessage:Message):Void {
		mMessages.push(aMessage);
	}

	public function addState(findTargetState:EntityState):Void {
		mStates.push(findTargetState);
	}

	public function applyState(aEntity:Entity):Void {

		for (message in mMessages) {
			message.to = aEntity;
			message.from = aEntity;
			ES.i.dispatch(message);
		}
		for (property in mPropertiesToAdd) {
			aEntity.add(property.property, true);
		}
		for (property in mPropertiesToRemove) {
			aEntity.remove(property);
		}
		for (complexProp in mComplexProperties) {
			if (aEntity.hasProperty(complexProp.id)) {
				complexProp.set(aEntity, aEntity.get(complexProp.id));
			} else {
				aEntity.add(complexProp.clone(aEntity));
			}
		}
		var systemManager:SystemManager = SystemManager.i;
		for (system in mSystems) {
			if (system.add) {
				systemManager.addEntity(aEntity, system.id);
			} else {
				systemManager.removeEntity(aEntity, system.id);
			}
		}
		for (group in mGroups) {
			if (group.add) {
				systemManager.addEntity(aEntity, group.id);
			} else {
				systemManager.removeEntity(aEntity, group.id);
			}
		}
		for (listener in mListener) {
			if (listener.add) {
				systemManager.subscribeEntity(aEntity, listener.message, listener.id, listener.overrideData, listener.broadcast);
			} else {
				systemManager.unsubscribeEntity(aEntity, listener.message, listener.id);
			}
		}
		for (subStates in mStates) {
			subStates.applyState(aEntity);
		}

		for (childState in mChildren) {
			childState.applyState(aEntity.getChild(childState.mChildID));
		}
		#if !macro
		var prStateManager:entitySystem.properties.PrStateManager=cast get(entitySystem.properties.PrStateManager.ID);
		if(prStateManager!=null){
			prStateManager.applyInitialStates(aEntity);
		}
		#end

		if (onSet != null) {
			onSet(aEntity);
		}
	}

	public function removeState(aEntity:Entity):Void {
		for (property in mPropertiesToAdd) {
			if (property.delete) {
				aEntity.remove(property.property.id());
			}
		}
		// re add is not implemented for properties, don't think is needed

		var systemManager:SystemManager = SystemManager.i;
		for (system in mSystems) {
			if (!system.add) {
				systemManager.addEntity(aEntity, system.id);
			} else {
				systemManager.removeEntity(aEntity, system.id);
			}
		}

		for (group in mGroups) {
			if (!group.add) {
				systemManager.addEntity(aEntity, group.id);
			} else {
				systemManager.removeEntity(aEntity, group.id);
			}
		}

		for (listener in mListener) {
			if (!listener.add) {
				systemManager.subscribeEntity(aEntity, listener.message, listener.id, listener.overrideData, listener.broadcast);
			} else {
				systemManager.unsubscribeEntity(aEntity, listener.message, listener.id);
			}
		}

		for (childState in mChildren) {
			childState.removeState(aEntity.getChild(childState.mChildID));
		}
		if (onRemove != null) {
			onRemove(aEntity);
		}
	}

	/////////////////////// Child Functions ////////////////////////
	private function getChildState(aChildID:Int):EntityState {
		for (state in mChildren) {
			if (state.mChildID == aChildID)
				return state;
		}
		var newState = new EntityState();
		newState.mChildID = aChildID;
		mChildren.push(newState);
		return newState;
	}

	public function addSystemTo(aChildID:Int, aSystem:Int):Void {
		getChildState(aChildID).addSystem(aSystem);
	}

	public function removeSystemTo(aChildID:Int, aSystem:Int):Void {
		getChildState(aChildID).removeSystem(aSystem);
	}

	public function addGroupTo(aChildID:Int, aGroup:Int):Void {
		getChildState(aChildID).addGroup(aGroup);
	}

	public function removeGroupTo(aChildID:Int, aGroup:Int):Void {
		getChildState(aChildID).removeGroup(aGroup);
	}

	public function addListeneingTo(aChildID:Int, aMessage:MessageID, aSystem:Int, aOverrideData:Dynamic = null, aBroadcast:Bool = false):Void {
		getChildState(aChildID).addListeneing(aMessage, aSystem, aOverrideData, aBroadcast);
	}

	public function removeListeneingTo(aChildID:Int, aMessage:MessageID, aSystem:Int):Void {
		getChildState(aChildID).removeListeneing(aMessage, aSystem);
	}

	public function addPropertyTo(aChildID:Int, aProperty:Property, aDelete:Bool = false):Void {
		getChildState(aChildID).addProperty(aProperty, aDelete);
	}

	public function removePropertyTo(aChildID:Int, aId:Int):Void {
		getChildState(aChildID).removeProperty(aId);
	}

	public function addComplexPropertyTo(aChildID:Int, aProperty:ComplexProperty, aOverride:Bool = true):Void {
		getChildState(aChildID).addComplexProperty(aProperty, aOverride);
	}

	//////////////////////////////////////////
	public function clone():EntityState {
		var cl:EntityState = new EntityState();
		for (system in mSystems) {
			cl.mSystems.push(system.clone());
		}
		for (group in mGroups) {
			cl.mGroups.push(group.clone());
		}
		for (property in mPropertiesToAdd) {
			cl.mPropertiesToAdd.push(property.clone());
		}
		for (property in mPropertiesToRemove) {
			cl.mPropertiesToRemove.push(property);
		}
		for (id in mPropertiesToRemove) {
			cl.mPropertiesToRemove.push(id);
		}
		for (property in mComplexProperties) {
			cl.mComplexProperties.push(property.cloneF());
		}
		for (listener in mListener) {
			cl.mListener.push(listener.clone());
		}
		for (message in mMessages) {
			cl.mMessages.push(message.clone());
		}
		for(child in mChildren){
			cl.mChildren.push(child.clone());
		}
		cl.mChildID=mChildID;
		cl.onSet = onSet;
		cl.onRemove = onRemove;
		return cl;
	}

	public function set(entityState:EntityState):Void {
		// var remove:Array<Int> = new Array();
		// var counter:Int;
		// var remove:Bool;
		// for (system in mSystems)
		// {
		// remove = true;
		// for (systemCopy in entityState.mSystems)
		// {
		// if (system.id == systemCopy)
		// {
		// system.add = systemCopy.add;
		// remove = false;
		// break;
		// }
		// }
		// if (remove)
		// {
		// remove.push(counter);
		// }
		// ++counter;
		// }
		// var offset = 0;
		// for (id in remove)
		// {
		// mSystems.splice(id - offset, 1);
		//--offset;
		// }
		// for (property in mPropertiesToAdd)
		// {
		// cl.mPropertiesToAdd.push(property.clone());
		// }
		// for (property in mPropertiesToRemove)
		// {
		// cl.mPropertiesToRemove.push(property.clone());
		// }
		// for (id in mPropertiesToRemove)
		// {
		// cl.mPropertiesToRemove.push(id);
		// }
		// for (property in mComplexProperties)
		// {
		// cl.mComplexProperties.push(property.clone());
		// }
		// for (listener in mListener)
		// {
		// cl.mListener.push(listener.clone());
		// }
	}
	public function get(aId:Int):Property {
		for (prop in mPropertiesToAdd) {
			if (prop.id == aId) {
				return prop.property;
			}
		}
		return null;
	}

	#if expose
	public function serialize():String {
		var encode:String = "";
		for (prop in mPropertiesToAdd) {
			encode += prop.property.serialize();
		}
		return encode;
	}

	public function getBy(aName:String):Property {
		for (prop in mPropertiesToAdd) {
			if (prop.name == aName) {
				return prop.property;
			}
		}
		throw "property with name " + aName + " not found";
	}
	#end
}

private class SystemAux {
	public var id:Int;
	public var add:Bool; // false equals to remove;

	public function new(aId:Int, aAdd:Bool) {
		id = aId;
		add = aAdd;
	}

	public function clone():SystemAux {
		return new SystemAux(id,  add);
	}
}

private class ListenerAux {
	public var id:Int;
	public var message:MessageID;
	public var add:Bool; // false equals to remove;
	public var overrideData:Dynamic;
	public var broadcast:Bool;

	public function new(aId:Int, aMessage:MessageID, aAdd:Bool, aOverrideData:Dynamic = null, aBroadcast:Bool = false) {
		id = aId;
		message = aMessage;
		add = aAdd;
		overrideData = aOverrideData;
		broadcast = aBroadcast;
	}

	public function clone():ListenerAux {
		return new ListenerAux(id, message, add, overrideData, broadcast);
	}
}

private class PropertyAux {
	public var id:Int;
	public var property:Property;
	public var delete:Bool;
	#if expose
	public var name:String;
	#end

	public function new(aProperty:Property, aOverride:Bool) {
		id = aProperty.id();
		property = aProperty;
		delete = aOverride;
		#if expose
		name = aProperty.propertyName();
		#end
	}

	public function clone():PropertyAux {
		return new PropertyAux(property.clone(), delete);
	}
}
