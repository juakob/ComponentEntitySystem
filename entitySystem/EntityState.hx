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
	private var mListener:Array<SystemAux>;
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
	public function addListeneing(aSystem:Int, aSafeAdd:Bool = false):Void
	{
		mListener.push(new SystemAux(aSystem, aSafeAdd, true));
	}
	
	public function removeListeneing(aSystem:Int):Void
	{
		mListener.push(new SystemAux(aSystem, false, false));
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
				systemManager.subscribeEntity(aEntity, listener.id);
			}else {
				systemManager.unsubscribeEntity(aEntity, listener.id);
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
		//TODO update with all the stuff in applyState
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
}

private class PropertyAux
{
	public var property:Property;
	public var override_:Bool;
	public function new(aProperty:Property, aOverride:Bool)
	{
		property = aProperty;
		override_ = aOverride;
	}
}