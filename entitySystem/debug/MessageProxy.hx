package entitySystem.debug;

import entitySystem.Message;
import entitySystem.Message.MessageID;

/**
 * ...
 * @author Joaquin
 */
class MessageProxy {
	public var event:MessageID;
	public var from:Int;
	public var fromType:String;
	public var data:Dynamic;
	public var broadcast:Bool;
	public var delay:Float;

	public function new(aMessage:Message) {
		copy(aMessage);
	}

	public function copy(aMessage:Message) {
		event = aMessage.event;
		if (aMessage.from != null) {
			from = aMessage.from.id;
			fromType = aMessage.from.name;
		}
		data = aMessage.data;
		broadcast = aMessage.broadcast;
		delay = aMessage.totalDelay;
	}

	public function toString():String {
		return "" + event + ";;" + from + ";;" + fromType + ";;" + data + ";;" + broadcast + ";;" + delay;
	}
}
