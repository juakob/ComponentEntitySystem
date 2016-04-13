package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;
import entitySystem.SystemManager.ES;

/**
 * ...
 * @author Joaquin
 */
class RsSendMessage extends Listener
{

	override public function onEvent(aMessage:Message):MessageResult 
	{
		var messages:Array<Message> = cast aMessage.data;
		for (message in messages)
		{
			message.to = aMessage.to;
			message.from = aMessage.from;
			if (message.data == null)
			{
				message.data = aMessage.data;
			}
			ES.i.dispatch(message);
		}
		return SUCCESS;
	}
	
}