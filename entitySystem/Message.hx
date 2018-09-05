package entitySystem;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Joaquin
 */
typedef MessageID = #if RELEASE Int #else String #end;

typedef Msg = Message;

class Message {
	public var event:MessageID;
	public var to:Entity;
	public var from:Entity;
	public var data:Dynamic;
	public var originalData:Dynamic;
	public var broadcast:Bool;
	public var delay:Float;
	public var totalDelay:Float;

	public function new(aEvent:MessageID, aTo:Entity, aFrom:Entity, aData:Dynamic = null, aBroadcast:Bool = false, aDelay:Float = 0) {
		event = aEvent;
		to = aTo;
		from = aFrom;
		data = aData;
		broadcast = aBroadcast;
		totalDelay = delay = aDelay;
	}

	public function clone():Message {
		return new Message(event, to, from, data, broadcast, delay);
	}

	public function weakClone():Message {
		return Message.weak(event, to, from, data, broadcast, delay);
	}

	public function reset():Void {
		to = null;
		from = null;
		delay = totalDelay;
	}

	private static var i_weak:Array<Message> = new Array();
	private static var index:Int = 0;

	public static inline function clearWeak():Void {
		index = 0;
	}

	public static function weak(aEvent:MessageID, aTo:Entity, aFrom:Entity, aData:Dynamic = null, aBroadcast:Bool = false, aDelay:Float = 0):Message {
		if (index >= i_weak.length) {
			i_weak.push(new Message(#if false - 1 #else null #end , null, null));
		}
		var message = i_weak[index];
		message.event = aEvent;
		message.to = aTo;
		message.from = aFrom;
		message.data = aData;
		message.broadcast = aBroadcast;
		message.totalDelay = message.delay = aDelay;
		++index;
		return message;
	}

	public static function weakBroadcast(aEvent:MessageID, aData:Dynamic = null, aDelay:Float = 0):Message {
		return Message.weak(aEvent, null, null, aData, true, aDelay);
	}

	public static function clearPool():Void {
		i_weak.splice(0, i_weak.length);
		index = 0;
		messageMap = new Map();
	}

	public static var messageMap:Map<String, Int> = new Map();
	public static var messageIndex:Int = 0;

	macro public static function id(message:String) {
		#if RELEASE
		if (message.charCodeAt(0) == 91) // "["
		{
			return macro {Message.dynamicID($v{message});};
		}
		if (Message.messageMap.exists(message)) {
			return macro $v{messageMap.get(message)};
		} else {
			messageIndex++;
			messageMap.set(message, messageIndex);
			return macro $v{messageIndex};
		}
		#else
		return macro $v{message};
		#end
	}

	public static function dynamicID(message:String):MessageID {
		#if RELEASE
		if (Message.messageMap.exists(message)) {
			return Message.messageMap.get(message);
		} else {
			messageIndex++;
			messageMap.set(message, messageIndex);
			return Message.messageIndex;
		}
		#else
		return message;
		#end
	}
}
