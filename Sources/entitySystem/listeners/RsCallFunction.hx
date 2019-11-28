package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;

/**
 * ...
 * @author Joaquin
 */
class RsCallFunction extends Listener {
	override public function onEvent(aMessage:Message):MessageResult {
		aMessage.data();
		return SUCCESS;
	}
}
