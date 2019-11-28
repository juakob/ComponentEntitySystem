package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;
import entitySystem.SystemManager.ES;

/**
 * ...
 * @author Joaquin
 */
class RsKillPendingMessages extends Listener {
	override public function onEvent(aMessage:Message):MessageResult {
		ES.i.killPendingMessages(aMessage.to);
		return SUCCESS;
	}
}
