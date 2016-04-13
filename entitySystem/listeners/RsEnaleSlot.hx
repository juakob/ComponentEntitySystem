package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.properties.PrStateManager;

/**
 * ...
 * @author Joaquin
 */
class RsEnaleSlot extends Listener
{

	override public function onEvent(aMessage:Message):MessageResult 
	{
		var stateManager:PrStateManager = Listener.get(PrStateManager.ID);
		stateManager.enable(aMessage.data,aMessage.to);
		return SUCCESS;
	}
}