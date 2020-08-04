package entitySystem.listeners;

import entitySystem.Listener;
import entitySystem.Message;
import entitySystem.MessageResult;
import entitySystem.SystemManager.ES;

/**
 * ...
 * @author Joaquin
 */
class RsSendMessage extends Listener {
	override public function onEvent(aMessage:Message):MessageResult {
		var messages:Array<Message> = cast aMessage.data;
		#if debug
		if(messages==null) throw "data must be an array of Message";
		#end
		for (message in messages) {
			var messageCopy:Message;
			if (message.delay != 0) {
				messageCopy = message.clone();
			} else {
				messageCopy = message;
			}
			messageCopy.to = aMessage.to;
			messageCopy.from = aMessage.from;
			if(messageCopy.broadcast){
				messageCopy.from =aMessage.to;
			}
			if (message.data == null) {
				messageCopy.data = aMessage.data;
			}
			ES.i.dispatch(messageCopy);
		}
		return SUCCESS;
	}
}
