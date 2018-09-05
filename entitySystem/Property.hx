package entitySystem;

/**
 * ...
 * @author Joaquin
 */
@:autoBuild(entitySystem.macros.ComponentMacro.build())
interface Property {
	var nextProperty:Property;
	var versionId:Int;
	function id():Int;
	function clone():Property;
	function applyTo(aProperty:Property):Void;
	#if expose
	function serialize():String;
	function setValue(id:Int, value:String):Void;
	function getValue(id:Int):String;
	function getMetadata():String;
	function propertyName():String;
	function setValueBy(name:String, value:String):Void;
	function versionMd5():String;
	#end
}
