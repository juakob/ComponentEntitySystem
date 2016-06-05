package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;
import entitySystem.properties.PrStateManager;

/**
 * ...
 * @author Joaquin
 */
class RsRemoveListening extends Listener
{

	override public function onEvent(aMessage:Message):MessageResult 
	{
		aMessage.to.removeListener(aMessage.data[0], aMessage.data[1]);
		return SUCCESS;
	}
}