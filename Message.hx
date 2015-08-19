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
	private static var i_weak:Message=new Message(null,null,null);
	public static function clearWeak():Void
	{
		i_weak = null;
	}
	public static function weak(aEvent:String, aTo:Entity, aFrom:Entity, aData:Dynamic = null):Message
	{
		i_weak.event = aEvent;
		i_weak.to = aTo;
		i_weak.from = aFrom;
		i_weak.data = aData;
		return i_weak;
	}
}
