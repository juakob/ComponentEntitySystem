package entitySystem;
import entitySystem.macros.SystemIdMacro;
import entitySystem.Message;
import entitySystem.MessageResult;
import entitySystem.Entity;
import haxe.macro.Expr;
import openfl.errors.Error;

/**
 * ...
 * @author Joaquin
 */
@:autoBuild(entitySystem.macros.SystemIdMacro.build()) //use the same id sequence to avoid overlap
class Listener implements IListener
{
	macro static function get(aType:Expr)
	{
		return macro { cast aMessage.to.get($aType); };
	}
	var mEntityes:Array<Entity>;
	public function new() 
	{
		mEntityes = new Array();
	}
	
	/* INTERFACE entitySystem.IMessageHanlder */
	public function id():Int 
	{
		//if macros work correctly this should be override
		throw new Error("Override this method");
	}
	
	public function add(aEntity:Entity, aFirst:Bool = false):Void 
	{
		mEntityes.push(aEntity);
	}
	
	public function remove(aEntity:Entity):Void 
	{
		mEntityes.remove(aEntity);
	}
	
	public function onEvent(aMessage:Message):MessageResult
	{
		return NOT_IMPLEMENTED;
	}
	
}