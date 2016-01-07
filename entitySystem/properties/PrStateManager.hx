package entitySystem.properties;
import entitySystem.Entity;
import entitySystem.EntityState;
import entitySystem.Property;

/**
 * ...
 * @author Joaquin
 */
class PrStateManager implements Property
{
	private var mStates:Array<StateGroup>;
	private var mSlots:Array<Slot>;
	public function new() 
	{
		mStates = new Array();
		mSlots = new Array();
	}
	public function createSlot(aName:String,?aTag:String,?aState:String):Void
	{
		var slot = new Slot();
		slot.name = aName;
		slot.tag = aTag;
		if (aState != null)
		{
			slot.state = getState(aState);
		}
		mSlots.push(slot);
	}
	
	public function addState(aName:String, aStates:Array<EntityState>):Void
	{
		var state = new StateGroup();
		state.name = aName;
		state.states = aStates;
		mStates.push(state);
	}
	public function addState2(aName:String, aStates:Array<Int>):Void
	{
		var eState:EntityState = new EntityState();
		for (id in aStates) 
		{
			eState.addSystem(id);
		}
		var state = new StateGroup();
		state.name = aName;
		state.states = [eState];
		mStates.push(state);
	}
	public function concatTo(aStateName:String, aState:EntityState):Void
	{
		for (state in mStates) 
		{
			if (state.name == aStateName)
			{
				state.states.push(aState);
				return;
			}
		}
	}
	public function currentState(aSlot:String):String
	{
		return getSlot(aSlot).state.name;
	}
	public function change(aSlot:String, aState:String, aEntity:Entity):Void
	{
		var slot = getSlot(aSlot);
		if (slot.state != null)
		{
			slot.state.unapplyState(aEntity);
		}
		slot.state = getState(aState);
		slot.state.applyState(aEntity);
	}
	public function disable(aSlot:String, aEntity:Entity):Void
	{
		var slot = getSlot(aSlot);
		if (slot.state != null&&!slot.disable)
		{
			slot.state.unapplyState(aEntity);
			slot.disable = true;
		}
	}
	public function enable(aSlot:String, aEntity:Entity):Void
	{
		var slot = getSlot(aSlot);
		if (slot.state != null&&slot.disable)
		{
			slot.state.applyState(aEntity);
			slot.disable = false;
		}
	}
	public function disableBy(aTag:String,aEntity:Entity):Void
	{
		for (slot in mSlots) 
		{
			if (slot.tag == aTag)
			{
				if (slot.state != null&&!slot.disable)
				{
					slot.state.unapplyState(aEntity);
					slot.disable = true;
				}
			}
		}
	}
	public function enableBy(aTag:String,aEntity:Entity):Void
	{
		for (slot in mSlots) 
		{
			if (slot.tag == aTag)
			{
				if (slot.state != null&&slot.disable)
				{
					slot.state.applyState(aEntity);
					slot.disable = false;
				}
			}
		}
	}
	
	/* INTERFACE entitySystem.Property */

	public function clone():Property 
	{
		var cl:PrStateManager = new PrStateManager();
		for (slot in mSlots)
		{
			cl.mSlots.push(slot.clone());
		}
		for (state in mStates)
		{
			cl.mStates.push(state.clone());
		}
		return cl;
	}
	
	public function set(aProperty:Property):Void 
	{
		//TODO deep set of all states
		var copy:PrStateManager = cast aProperty;
		for (slot in mSlots) 
		{
			for (slotCopy in copy.mSlots) 
			{
				if (slot.name == slotCopy.name)
				{
					if (slotCopy.state != null)
					{
						slot.state = getState(slotCopy.state.name);
					}
					slot.disable = slotCopy.disable;
					break;
				}
			}
		}
	}
	 private function getState(aName:String):StateGroup
	{
		for (state in mStates) 
		{
			if (state.name == aName)
			{
				return state;
			}
		}
		return null;
	}
	 private function getSlot(aName:String):Slot
	{
		for (slot in mSlots) 
		{
			if (slot.name == aName)
			{
				return slot;
			}
		}
		return null;
	}
	
}
class Slot
{
	public var name:String;
	public var tag:String;
	public var state:StateGroup;
	public var disable:Bool;
//	public var block:Bool; TODO this should be use to disable the slot independent of the tag disable/enable
	
	public function new()
	{
		
	}
	public function clone():Slot 
	{
		var cl:Slot = new Slot();
		cl.name = name;
		cl.tag = tag;
		if (state != null)
		{
			cl.state = state.clone();
		}
		cl.disable = disable;
		return cl;
	}
}
class StateGroup
{
	public var name:String;
	public var states:Array<EntityState>;
	public function applyState(aEntity:Entity):Void
	{
		for (state in states) 
		{
			state.applyState(aEntity);
		}
	}
	public function unapplyState(aEntity:Entity):Void
	{
		for (state in states) 
		{
			state.removeState(aEntity);
		}
	}
	public function new()
	{
		states = new Array();
	}
	public function clone():StateGroup
	{
		var cl:StateGroup = new StateGroup();
		cl.name = name;
		for (state in states) 
		{
			cl.states.push(state.clone());
		}
		return cl;
	}
}