package inspector.net;

/**
 * ...
 * @author Joaquin
 */
class LocalClient extends Local
{

	public static var i(get,null):LocalClient;
	static function get_i():LocalClient 
	{
		if (i == null)
		{
			i = new LocalClient();
			i.server = LocalServer.i;
		}
		return i;
	}
	var server:LocalServer;
	override public function update() 
	{
		for (message in messagesSend) 
		{
			server.messagesReceive.push(message);
		}
		this.messagesSend.splice(0, messagesSend.length);
		super.update();
	}

}