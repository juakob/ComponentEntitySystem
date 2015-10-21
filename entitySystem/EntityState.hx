package entitySystem;
import entitySystem.properties.ComplexProperty;
import haxe.ds.IntMap;

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
	public function new() 
	{
		mSystems = new Array();
		mPropertiesToAdd = new Array();
		mPropertiesToRemove = new Array();
		mComplexProperties = new Array();
		mListener = new Array();
	}
	public function addSystem(aSystem:Int, aSafeAdd:Bool = false):Void
	{
		mSystems.push(new SystemAux(aSystem, aSafeAdd, true));
	}
	
	public function removeSystem(aSystem:Int):Void
	{
		mSystems.push(new SystemAux(aSystem, false, false));
	}
	public function addListeneing( aMessage:String,aSystem:Int):Void
	{
		mListener.push(new ListenerAux(aSystem, aMessage, true));
	}
	
	public function removeListeneing(aSystem:Int,aMessage:String):Void
	{
		mListener.push(new ListenerAux(aSystem, aMessage, false));
	}
	public function addProperty(aProperty:Property, aOverride:Bool = true):Void
	{
		mPropertiesToAdd.push(new PropertyAux(aProperty, aOverride));
	}
	public function removeProperty(aId:Int):Void
	{
		mPropertiesToRemove.push(aId);
	}
	public function addComplexProperty(aProperty:ComplexProperty, aOverride:Bool = true):Void
	{
		mComplexProperties.push(aProperty);
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
				systemManager.subscribeEntity(aEntity, listener.message,listener.id);
			}else {
				systemManager.unsubscribeEntity(aEntity,listener.message, listener.id);
			}
		}
	}
	public function removeState(aEntity:Entity):Void
	{
		for (property in mPropertiesToAdd) 
		{
			aEntity.remove(property.property.id());
		}
		//TODO re add is not implemented
		//for (property in mPropertiesToRemove) 
		//{
			//aEntity.remove(property);
		//}
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
				systemManager.subscribeEntity(aEntity, listener.message,listener.id);
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
	public function new(aId:Int, aMessage:String,aAdd:Bool)
	{
		id = aId;
		message = aMessage;
		add = aAdd;
	}
	public function clone():ListenerAux
	{
		return new ListenerAux(id, message, add);
	}

}
private class PropertyAux
{
	public var id:Int;
	public var property:Property;
	public var override_:Bool;
	public function new(aProperty:Property, aOverride:Bool)
	{
		id = aProperty.id();
		property = aProperty;
		override_ = aOverride;
	}
	public function clone():PropertyAux
	{
		return new PropertyAux(property.clone(), override_);
	}
	
}
