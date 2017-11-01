package entitySystem;

/**
 * ...
 * @author Joaquin
 */
class Message 
{
	public var event:String;
	public var to:Entity;
	public var from:Entity;
	public var data:Dynamic;
	public var originalData:Dynamic;
	public var broadcast:Bool;
	public var delay:Float;
	public var totalDelay:Float;
	public function new(aEvent:String, aTo:Entity, aFrom:Entity, aData:Dynamic = null, aBroadcast:Bool = false ,aDelay:Float=0)
	{
		event = aEvent;
		to = aTo;
		from = aFrom;
		data = aData;
		broadcast = aBroadcast;
		totalDelay=delay = aDelay;
	}
	public function clone():Message
	{
		return new Message(event,to,from,data,broadcast,delay);
	}
	public function weakClone():Message
	{
		return Message.weak(event,to,from,data,broadcast,delay);
	}
	public function reset():Void
	{
		to = null;
		from = null;
		delay = totalDelay;
	}
	private static var i_weak:Array<Message> = new Array();
	private static var index:Int=0;
	public static inline function clearWeak():Void
	{
		index = 0;
	}
	
	public static function weak(aEvent:String, aTo:Entity, aFrom:Entity, aData:Dynamic = null,aBroadcast:Bool=false,aDelay:Float=0):Message
	{
		if (index >= i_weak.length)
		{
			i_weak.push(new Message(null, null, null));
		}
		var message = i_weak[index];
		message.event = aEvent;
		message.to = aTo;
		message.from = aFrom;
		message.data = aData;
		message.broadcast = aBroadcast;
		message.totalDelay=message.delay = aDelay;
		++index;
		return message;
	}
	public static function weakBroadcast(aEvent:String,aData:Dynamic = null,aDelay:Float=0):Message
	{
		return Message.weak(aEvent,null,null,aData,true,aDelay);
	}
	public static function clearPool():Void
	{
		i_weak.splice(0, i_weak.length);
		index = 0;
	}
}
