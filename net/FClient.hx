package net;
#if flash
import flash.errors.IOError;
import flash.errors.SecurityError;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.system.Security;
import flash.utils.ByteArray;
#end
/**
 * ...
 * @author Joaquin
 */
class FClient
{
	#if flash
	var socket:Socket;
	#end
	
	var messages:Array<String>;

	public function new() 
	{
		#if flash
		try {
		  Security.allowDomain('127.0.0.1');
		  Security.loadPolicyFile("xmlsocket://127.0.0.1:5001");
		} catch (e:IOError) {
			
		}
		socket = new Socket();	
		
		 socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		try {
			socket.connect("127.0.0.1", 5001);
		} catch(ioError:IOError) {
			//  handle synchronous errors here  
		} catch(secError:SecurityError) {
			// and here
		}
		#end
		messages = new Array();
	}
	
	#if flash
	private function ioErrorHandler(event:IOErrorEvent):Void {
		trace("ioErrorHandler: " + event);
	}

	private function securityErrorHandler(event:SecurityErrorEvent):Void {
		trace("securityErrorHandler: " + event);
	}
	#end
	
	var stream:String="";
	public function update():Void
	{
		#if flash
		if (socket.connected && socket.bytesAvailable != 0)
		{	
			stream += socket.readUTFBytes(socket.bytesAvailable);
			var parts:Array<String> = stream.split(";>");
			while (parts.length > 1)
			{
				messages.push(parts.shift());
			}
			stream = parts[0];
		}
		#end
	}
	public function write(aMessage:String):Void
	{
		#if flash
		if (socket.connected)
		{
			socket.writeUTFBytes(aMessage+"\n");
			socket.flush();
		}
		#end
	}
	
	public inline function popMessage():String
	{
		return messages.pop();
	}
	public inline function messagesToRead():Int
	{
		return messages.length;
	}
	
	public function close() 
	{
		#if flash
		if (socket.connected)
		{
			socket.close();
		}
		#end
	}
}