package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.properties.PrStateManager;

/**
 * ...
 * @author Joaquin
 */
class RsEnableSlot extends Listener
{

	override public function onEvent(aMessage:Message):MessageResult 
	{
		var stateManager:PrStateManager = Listener.get(PrStateManager.ID);
		var counter:Int = 0;
		while (counter < aMessage.data.length)
		{
			stateManager.enable(aMessage.data[counter], aMessage.to);
			++counter;
		}
		return SUCCESS;
	}
}