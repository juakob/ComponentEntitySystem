package entitySystem;
import entitySystem.Message.MessageID;
import entitySystem.properties.ComplexProperty;
import entitySystem.SystemManager.ES;


/**
 * ...
 * @author Joaquin
 */
class EntityState
{
	public var name:String;
	private var mSystems:Array<SystemAux>;
	private var mPropertiesToAdd:Array<PropertyAux>;
	private var mPropertiesToRemove:Array<Int>;
	private var mComplexProperties:Array<ComplexProperty>;
	private var mListener:Array<ListenerAux>;
	private var mMessages:Array<Message>;
	public var onSet:Entity->Void;
	public var onRemove:Entity->Void;
	
	var mChildID:Int;
	var mChildren:Array<EntityState>;
	public function new() 
	{
		mSystems = new Array();
		mPropertiesToAdd = new Array();
		mPropertiesToRemove = new Array();
		mComplexProperties = new Array();
		mListener = new Array();
		mMessages = new Array();
		mChildren = new Array();
	}
	public function addSystem(aSystem:Int, aSafeAdd:Bool = false):Void
	{
		mSystems.push(new SystemAux(aSystem, aSafeAdd, true));
	}
	
	public function removeSystem(aSystem:Int):Void
	{
		mSystems.push(new SystemAux(aSystem, false, false));
	}
	public function addListeneing( aMessage:MessageID,aSystem:Int,aOverrideData:Dynamic=null,aBroadcast:Bool=false):Void
	{
		mListener.push(new ListenerAux(aSystem, aMessage, true,aOverrideData,aBroadcast));
	}
	
	public function removeListeneing(aMessage:MessageID,aSystem:Int,aOverrideData:Dynamic=null,aBroadcast:Bool=false):Void
	{
		mListener.push(new ListenerAux(aSystem, aMessage,aOverrideData, aBroadcast));
	}
	public function addProperty(aProperty:Property, aDelete:Bool = false):Void
	{
		mPropertiesToAdd.push(new PropertyAux(aProperty, aDelete));
	}
	public function removeProperty(aId:Int):Void
	{
		mPropertiesToRemove.push(aId);
	}
	public function addComplexProperty(aProperty:ComplexProperty, aOverride:Bool = true):Void
	{
		mComplexProperties.push(aProperty);
	}
	public function addMessage(aMessage:Message):Void
	{
		mMessages.push(aMessage);
	}
	
	public function applyState(aEntity:Entity):Void
	{
		for (property in mPropertiesToAdd) 
		{
			aEntity.add(property.property,true);
		}
		for (property in mPropertiesToRemove) 
		{
			aEntity.remove(property);
		}
		for (complexProp in mComplexProperties) 
		{
			if (aEntity.hasProperty(complexProp.id))
			{
				complexProp.set(aEntity, aEntity.get(complexProp.id));
			}else {
				aEntity.add(complexProp.clone(aEntity));
			}
		}
		var systemManager:SystemManager = SystemManager.i;
		for (system in mSystems) 
		{
			if (system.add)
			{
				systemManager.addEntity(aEntity, system.id);
			}else {
				systemManager.removeEntity(aEntity, system.id);
			}
		}
		for (listener in mListener) 
		{
			if (listener.add)
			{
				systemManager.subscribeEntity(aEntity, listener.message,listener.id,listener.overrideData,listener.broadcast);
			}else {
				systemManager.unsubscribeEntity(aEntity,listener.message, listener.id);
			}
		}
		
		for (childState in mChildren) 
		{
			childState.applyState(aEntity.getChild(childState.mChildID));
		}
		
		for (message in mMessages)
		{
			message.to = aEntity;
			message.from = aEntity;
			ES.i.dispatch(message);
		}
		if (onSet != null)
		{
			onSet(aEntity);
		}
	}
	
	public function removeState(aEntity:Entity):Void
	{
		for (property in mPropertiesToAdd) 
		{
			if (property.delete)
			{
			aEntity.remove(property.property.id());
			}
		}
		//re add is not implemented for properties, don't think is needed
	
		var systemManager:SystemManager = SystemManager.i;
		for (system in mSystems) 
		{
			if (!system.add)
			{
				systemManager.addEntity(aEntity, system.id);
			}else {
				systemManager.removeEntity(aEntity, system.id);
			}
		}
		
		for (listener in mListener) 
		{
			if (!listener.add)
			{
				systemManager.subscribeEntity(aEntity, listener.message,listener.id,listener.overrideData,listener.broadcast);
			}else {
				systemManager.unsubscribeEntity(aEntity,listener.message, listener.id);
			}
		}
		
		for (childState in mChildren) 
		{
			childState.removeState(aEntity.getChild(childState.mChildID));
		}
		if (onRemove != null)
		{
			onRemove(aEntity);
		}
	}
	/////////////////////// Child Functions ////////////////////////
	private  function getChildState(aChildID:Int):EntityState
	{
		for (state in mChildren)
		{
			if (state.mChildID == aChildID) return state;
		}
		var newState = new EntityState();
		newState.mChildID = aChildID;
		mChildren.push(newState);
		return newState;
	}
	public function addSystemTo(aChildID:Int,aSystem:Int, aSafeAdd:Bool = false):Void
	{
		getChildState(aChildID).addSystem(aSystem, aSafeAdd);
	}
	
	public function removeSystemTo(aChildID:Int,aSystem:Int):Void
	{
		getChildState(aChildID).removeSystem(aSystem);
	}
	public function addListeneingTo(aChildID:Int,aMessage:MessageID,aSystem:Int,aOverrideData:Dynamic=null,aBroadcast:Bool=false):Void
	{
		getChildState(aChildID).addListeneing(aMessage, aSystem, aOverrideData, aBroadcast);
	}
	
	public function removeListeneingTo(aChildID:Int,aMessage:MessageID,aSystem:Int):Void
	{
		getChildState(aChildID).removeListeneing(aMessage, aSystem);
	}
	public function addPropertyTo(aChildID:Int,aProperty:Property, aDelete:Bool = false):Void
	{
		getChildState(aChildID).addProperty(aProperty, aDelete);
	}
	public function removePropertyTo(aChildID:Int,aId:Int):Void
	{
		getChildState(aChildID).removeProperty(aId);
	}
	public function addComplexPropertyTo(aChildID:Int,aProperty:ComplexProperty, aOverride:Bool = true):Void
	{
		getChildState(aChildID).addComplexProperty(aProperty, aOverride);
	}
	//////////////////////////////////////////
	public function clone():EntityState
	{
		var cl:EntityState = new EntityState();
		cl.name = name;
		for (system in mSystems) 
		{
			cl.mSystems.push(system.clone());
		}
		for (property in mPropertiesToAdd)
		{
			cl.mPropertiesToAdd.push(property.clone());
		}
		for (property in mPropertiesToRemove)
		{
			cl.mPropertiesToRemove.push(property);
		}
		for (id in mPropertiesToRemove) 
		{
			cl.mPropertiesToRemove.push(id);
		}
		for (property in mComplexProperties)
		{
			cl.mComplexProperties.push(property.cloneF());
		}
		for (listener in mListener)
		{
			cl.mListener.push(listener.clone());
		}
		for (message in mMessages) 
		{
			cl.mMessages.push(message.clone());
		}
		cl.onSet = onSet;
		return cl;
	}
	public function set(entityState:EntityState):Void
	{
		//var remove:Array<Int> = new Array();
		//var counter:Int;
		//var remove:Bool;
		//for (system in mSystems) 
		//{
			//remove = true;
			//for (systemCopy in entityState.mSystems) 
			//{
				//if (system.id == systemCopy)
				//{
					//system.add = systemCopy.add;
					//remove = false;
					//break;
				//}
			//}
			//if (remove)
			//{
				//remove.push(counter);
			//}
			//++counter;
		//}
		//var offset = 0;
		//for (id in remove) 
		//{
			//mSystems.splice(id - offset, 1);
			//--offset;
		//}
		//for (property in mPropertiesToAdd)
		//{
			//cl.mPropertiesToAdd.push(property.clone());
		//}
		//for (property in mPropertiesToRemove)
		//{
			//cl.mPropertiesToRemove.push(property.clone());
		//}
		//for (id in mPropertiesToRemove) 
		//{
			//cl.mPropertiesToRemove.push(id);
		//}
		//for (property in mComplexProperties)
		//{
			//cl.mComplexProperties.push(property.clone());
		//}
		//for (listener in mListener)
		//{
			//cl.mListener.push(listener.clone());
		//}
	}
	
	#if expose
	public function serialize():String
	{
		var encode:String = "";
		for (prop in mPropertiesToAdd) 
		{
			encode+=prop.property.serialize();
		}
		return encode;
	}
	public function getBy(aName:String):Property
	{
		for (prop in mPropertiesToAdd) 
		{
			if (prop.name == aName)
			{
				return prop.property;
			}
		}
		throw "property with name " + aName + " not found";
	}
	public function get(aId:Int):Property
	{
		for (prop in mPropertiesToAdd) 
		{
			if (prop.id == aId)
			{
				return prop.property;
			}
		}
		throw "property with id " + aId + " not found";
	}
	#end
}

private class SystemAux
{
	public var id:Int;
	public var safeAdd:Bool;
	public var add:Bool; //false equals to remove;
	public function new(aId:Int, aSafeAdd:Bool,aAdd:Bool)
	{
		id = aId;
		safeAdd = aSafeAdd;
		add = aAdd;
	}
	public function clone():SystemAux
	{
		return new SystemAux(id, safeAdd, add);
	}
	
	
}
private class ListenerAux
{
	public var id:Int;
	public var message:MessageID;
	public var add:Bool; //false equals to remove;
	public var overrideData:Dynamic;
	public var broadcast:Bool;
	public function new(aId:Int, aMessage:MessageID,aAdd:Bool,aOverrideData:Dynamic=null,aBroadcast:Bool=false)
	{
		id = aId;
		message = aMessage;
		add = aAdd;
		overrideData = aOverrideData;
		broadcast = aBroadcast;
		
	}
	public function clone():ListenerAux
	{
		return new ListenerAux(id, message, add,overrideData);
	}

}
private class PropertyAux
{
	public var id:Int;
	public var property:Property;
	public var delete:Bool;
	#if expose
	public var name:String;
	#end
	public function new(aProperty:Property, aOverride:Bool)
	{
		id = aProperty.id();
		property = aProperty;
		delete = aOverride;
		#if expose
		name = aProperty.propertyName();
		#end
		
	}
	public function clone():PropertyAux
	{
		return new PropertyAux(property.clone(), delete);
	}
	
}
