package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;
import entitySystem.properties.PrStateManager;
import entitySystem.Entity;

/**
 * ...
 * @author Joaquin
 */
class RsApplyState extends Listener {
	override public function onEvent(aMessage:Message):MessageResult {
		var stateManager:PrStateManager = Listener.get(PrStateManager.ID);
		stateManager.applyState(aMessage.data, aMessage.to);
		return SUCCESS;
	}
}
