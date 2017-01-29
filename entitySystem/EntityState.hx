package entitySystem;
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
	public function new() 
	{
		mSystems = new Array();
		mPropertiesToAdd = new Array();
		mPropertiesToRemove = new Array();
		mComplexProperties = new Array();
		mListener = new Array();
		mMessages = new Array();
	}
	public function addSystem(aSystem:Int, aSafeAdd:Bool = false):Void
	{
		mSystems.push(new SystemAux(aSystem, aSafeAdd, true));
	}
	
	public function removeSystem(aSystem:Int):Void
	{
		mSystems.push(new SystemAux(aSystem, false, false));
	}
	public function addListeneing( aMessage:String,aSystem:Int,aOverrideData:Dynamic=null,aBroadcast:Bool=false):Void
	{
		mListener.push(new ListenerAux(aSystem, aMessage, true,aOverrideData,aBroadcast));
	}
	
	public function removeListeneing(aMessage:String,aSystem:Int):Void
	{
		mListener.push(new ListenerAux(aSystem, aMessage, false));
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
	}
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
	public var message:String;
	public var add:Bool; //false equals to remove;
	public var overrideData:Dynamic;
	public var broadcast:Bool;
	public function new(aId:Int, aMessage:String,aAdd:Bool,aOverrideData:Dynamic=null,aBroadcast:Bool=false)
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
	
	public function new(aProperty:Property, aOverride:Bool)
	{
		id = aProperty.id();
		property = aProperty;
		delete = aOverride;
		
	}
	public function clone():PropertyAux
	{
		return new PropertyAux(property.clone(), delete);
	}
	
}
