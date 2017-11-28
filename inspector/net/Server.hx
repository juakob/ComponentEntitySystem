package net;

import haxe.io.Error;
import inspector.net.IServer;
import sys.net.Host;
import sys.net.Socket;
/**
 * ...
 * @author Joaquin
 */
class Server implements IServer
{
	var s:Socket;
	var o:Socket;
	var connected:Bool;
	var messages:Array<String>;
	var onConnectionCallBack:Void->Void;

	public function new() 
	{
		o = new Socket();
		o.bind(new Host("localhost"), 5001);
		o.setBlocking(false);
		o.listen(1);
		o.setFastSend(true);
		messages = new Array();
	}
	public function update() {
		if (!connected)
		{
			try {
				s = o.accept();
				connected = true;
				if (onConnectionCallBack != null)
				{
					onConnectionCallBack();
				}
				trace("connected");
			}catch (e:Dynamic  ) {
			}
		}else {
			read();	
		}
	}
	public function send(aMessage:String):Void
	{
		try {
		if (connected)
		{
		s.output.writeString(aMessage+"\n");
		}
		}catch (e:Dynamic  ) {
			s.close();
			connected = false;
			trace("disconect");
		}
		
	}
	private function read():Void
	{
		try {
			while (true)
			{
			messages.push(s.input.readLine());
			}
		}catch (e:Dynamic  ) {
			
		}
	}	
	public inline function popMessage():String
	{
		return messages.pop();
	}
	public inline function messagesToRead():Int
	{
		return messages.length;
	}
	
	/* INTERFACE inspector.net.IServer */
	
	public function onConnection(callBack:Void->Void) 
	{
		onConnectionCallBack = callBack;
	}
	
}