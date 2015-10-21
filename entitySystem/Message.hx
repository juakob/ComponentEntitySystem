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
	public function new(aEvent:String, aTo:Entity, aFrom:Entity, aData:Dynamic= null)
	{
		event = aEvent;
		to = aTo;
		from = aFrom;
		data = aData;
	}
	private static var i_weak:Array<Message> = new Array();
	private static var index:Int=0;
	public static inline function clearWeak():Void
	{
		index = 0;
	}
	public static function weak(aEvent:String, aTo:Entity, aFrom:Entity, aData:Dynamic = null):Message
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
		++index;
		return message;
	}
}
