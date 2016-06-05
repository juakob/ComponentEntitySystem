package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;
import entitySystem.properties.PrStateManager;

/**
 * ...
 * @author Joaquin
 */
class RsAddListening extends Listener
{

	override public function onEvent(aMessage:Message):MessageResult 
	{
		aMessage.to.addListener(aMessage.data[0], aMessage.data[1],aMessage.data[2],aMessage.data[3]);
		return SUCCESS;
	}
}