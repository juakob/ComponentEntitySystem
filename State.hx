package entitySystem;
import haxe.ds.IntMap;

/**
 * ...
 * @author Joaquin
 */
class State
{
	private var mSystems:Array<SystemAux>;
	private var mPropertiesToAdd:Array<PropertyAux>;
	private var mPropertiesToRemove:Array<Int>;
	public function new() 
	{
		mSystems = new Array();
		mPropertiesToAdd = new Array();
		mPropertiesToRemove = new Array();
	}
	public function addSystem(aSystem:Int, aSafeAdd:Bool = false):Void
	{
		mSystems.push(new SystemAux(aSystem, aSafeAdd, true));
	}
	public function addProperty(aProperty:Property, aOverride:Bool = true):Void
	{
		mPropertiesToAdd.push(new PropertyAux(aProperty, aOverride));
	}
	public function removeSystem(aSystem:Int):Void
	{
		mSystems.push(new SystemAux(aSystem, false, false));
	}

	public function removeProperty(aId:Int):Void
	{
		mPropertiesToRemove.push(aId);
	}
	public function applyState(aEntity:Entity):Void
	{
		for (property in mPropertiesToAdd) 
		{
			aEntity.add(property.property.clone());
		}
		for (property in mPropertiesToRemove) 
		{
			aEntity.remove(property);
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