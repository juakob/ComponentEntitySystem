package entitySystem;

/**
 * ...
 * @author Joaquin
 */

@:autoBuild(entitySystem.macros.ComponentMacro.build())
interface Property 
{
	var nextProperty:Property;
	var versionId:Int;
	function id():Int;
	function clone():Property;
	function set(aProperty:Property):Void;
	#if expose
	function serialize():String;
	function setValue(id:Int, value:String):Void;
	function getValue(id:Int):String;
	function getMetadata():String;
	#end
}
