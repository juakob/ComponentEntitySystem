package entitySystem.helper;

import entitySystem.Entity;
import entitySystem.properties.PrStateManager;

/**
 * ...
 * @author Joaquin
 */
class DelaySlotChange {
	public var stateManager:PrStateManager;
	public var slot:String;
	public var state:String;
	public var entity:Entity;

	public function new() {}

	public function reset() {
		stateManager = null;
		entity = null;
	}
}
