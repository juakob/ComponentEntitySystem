package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;

/**
 * ...
 * @author Joaquin
 */
class RsCallFunctionPassMessage extends Listener
{

	override public function onEvent(aMessage:Message):MessageResult 
	{
		var func = aMessage.data;
		aMessage.data = aMessage.originalData;
		func(aMessage);
		aMessage.data = func;
		return SUCCESS;
	}
}