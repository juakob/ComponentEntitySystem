package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;
import entitySystem.SystemManager.ES;

/**
 * ...
 * @author Joaquin
 */
class RsRespondMessage extends Listener {
	override public function onEvent(aMessage:Message):MessageResult {
		var messages:Array<Message> = cast aMessage.data;
		for (message in messages) {
			var messageCopy:Message;
			if (message.delay != 0) {
				messageCopy = message.clone();
			} else {
				messageCopy = message;
			}
			messageCopy.to = aMessage.from;
			messageCopy.from = aMessage.to;
			if (message.data == null) {
				messageCopy.data = aMessage.data;
			}
			ES.i.dispatch(messageCopy);
		}
		return SUCCESS;
	}
}
