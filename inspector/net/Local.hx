package inspector.net;

/**
 * ...
 * @author Joaquin
 */
class Local implements IServer
{
	var messagesSend:Array<String>;
	var messagesReceive:Array<String>;
	
	public function new() 
	{
		messagesSend = new Array();
		messagesReceive = new Array();
	}
	
	/* INTERFACE inspector.net.IServer */
	
	public function update() 
	{
		
	}
	
	public function send(aMessage:String):Void 
	{
		messagesSend.push(aMessage.substr(0,aMessage.length-2));
	}

	public function popMessage():String 
	{
		var message:String = messagesReceive.pop();
		return message;
	}
	
	public function messagesToRead():Int 
	{
		return messagesReceive.length;
	}
	
	/* INTERFACE inspector.net.IServer */
	
	public function onConnection(callBack:Void->Void)
	{
		callBack();
	}
	public function close()
	{
		messagesReceive.splice(0, messagesReceive.length);
		messagesSend.splice(0, messagesSend.length);
	}
	
	
	
	
}