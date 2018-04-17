package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;
import entitySystem.properties.PrStateManager;

/**
 * ...
 * @author Joaquin
 */
class RsChangeSlotState extends Listener
{

	override public function onEvent(aMessage:Message):MessageResult 
	{
		var state:PrStateManager = cast aMessage.to.get(PrStateManager.ID);
		state.change(aMessage.data[0],aMessage.data[1], aMessage.to);
		trace(aMessage.data[0]+" "+ aMessage.data[1]);
		return SUCCESS;
	}
}