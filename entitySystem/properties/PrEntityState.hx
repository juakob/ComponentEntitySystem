package entitySystem.properties;
import entitySystem.Entity;
import entitySystem.EntityState;
import entitySystem.Property;

/**
 * ...
 * @author Joaquin
 */

class PrEntityState implements Property
{
	private var mStates:Array<EntityState>;
	private var mDefinitions:Array<StateDefinition>
	
	public function new() 
	{
		states = new Array();
		mStates = new Array();
	}
	public function addState(aState:EntityState):Void
	{
		mStates.push(aState);
	}
	public function addDefinition(aName:String,aState:EntityState):Void
	{
		var definition = new StateDefinition();
		definition.name = aName;
		definition.state = aState;
		mDefinitions.push(definition);
	}
	public function setState(aName:String, aEntity:Entity):Bool
	{
		for (state in mStates) 
		{
			if (state.name == aName)
			{
				state.applyState(aEntity);
				return true;
			}
		}
		return false;
	}
	public function removeState(aName:String, aEntity:Entity):Bool
	{
		for (state in mStates) 
		{
			if (state.name == aName)
			{
				state.removeState(aEntity);
				return true;
			}
		}
		return false;
	}
	public function setDefinition(aDefinition:String:aState:String, aEntity:Entity):Bool
	{
		for (definition in mDefinitions) 
		{
			if (definition.name == aDefinition)
			{
				for (state in mStates) 
				{
					if (state.name == aState)
					{
						definition.state.removeState(aEntity);
						state.applyState(aEntity);
						return true;
					}
				}
				
				
			}
		}
		return false;
	}
	
	//TODO
	//public function clone():Property 
	//{
		//
	//}
	//
	//public function set(aProperty:Property):Void 
	//{
		//
	//}
	
}
private class StateDefinition
{
	public var name:String;
	public var state:EntityState;
	public function new()
	{
		
	}
}