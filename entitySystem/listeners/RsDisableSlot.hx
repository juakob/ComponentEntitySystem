package entitySystem.listeners;


import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;
import entitySystem.properties.PrStateManager;

/**
 * ...
 * @author Joaquin
 */
class RsDisableSlot extends Listener
{

	override public function onEvent(aMessage:Message):MessageResult 
	{
		var stateManager:PrStateManager = Listener.get(PrStateManager.ID);
		stateManager.disable(aMessage.data,aMessage.to);
		return SUCCESS;
	}
	
}