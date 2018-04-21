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
		var counter:Int = 0;
		while (counter < aMessage.data.length)
		{
			trace(aMessage.data[counter] + " " + aMessage.data[counter + 1] + " " + counter);
			state.change(aMessage.data[counter], aMessage.data[counter + 1], aMessage.to);
			counter += 2;
		}
		
		return SUCCESS;
	}
}