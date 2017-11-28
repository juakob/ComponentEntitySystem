package inspector.net;

/**
 * ...
 * @author Joaquin
 */
class LocalServer extends Local
{
	public static var i(get,null):LocalServer;
	static function get_i():LocalServer 
	{
		if (i == null)
		{
			i = new LocalServer();
			i.client = LocalClient.i;
		}
		return i;
	}
	var client:LocalClient;
	override public function update() 
	{
		for (message in messagesSend) 
		{
			client.messagesReceive.push(message);
		}
		this.messagesSend.splice(0, messagesSend.length);
		super.update();
	}
	
}