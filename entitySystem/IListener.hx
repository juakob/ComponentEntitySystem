package entitySystem;
import entitySystem.Message;
import entitySystem.MessageResult;

/**
 * @author Joaquin
 */
interface IListener 
{
   function id():Int;
	function add(aEntity:Entity,aFirst:Bool=false):Void;
	function remove(aEntity:Entity):Void;
	function onEvent(aMessage:Message):MessageResult;
}