package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;

/**
 * ...
 * @author Joaquin
 */
class RsChildrenListen extends Listener {
	override public function onEvent(aMessage:Message):MessageResult {
		aMessage.to.sendMessageToChild(aMessage);
		return SUCCESS;
	}
}
