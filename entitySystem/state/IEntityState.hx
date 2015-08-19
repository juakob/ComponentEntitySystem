package entitySystem;
import entitySystem.Message;
import entitySystem.MessageResult;

/**
 * ...
 * @author Joaquin
 */
interface IEntityState
{
	function id():Int;
	function add(aEntity:Entity,aFirst:Bool=false):Void;
	function remove(aEntity:Entity):Void;
	function handleEvent(message:Message,brodcast:Bool=false):MessageResult;
}