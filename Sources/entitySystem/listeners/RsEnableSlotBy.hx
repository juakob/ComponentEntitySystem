package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.properties.PrStateManager;

/**
 * ...
 * @author Joaquin
 */
class RsEnableSlotBy extends Listener {
	override public function onEvent(aMessage:Message):MessageResult {
		var stateManager:PrStateManager = Listener.get(PrStateManager.ID);
		stateManager.enableBy(aMessage.data, aMessage.to);

		return SUCCESS;
	}
}
