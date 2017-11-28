package inspector.net;

/**
 * @author Joaquin
 */
interface IServer 
{
   function update():Void;
   function send(aMessage:String):Void;
    function popMessage():String;
    function messagesToRead():Int;
  
   function onConnection(callBack:Void->Void):Void;
   
   function close():Void;
}