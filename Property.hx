package entitySystem;

/**
 * ...
 * @author Joaquin
 */

@:autoBuild(entitySystem.macros.ComponentMacro.ComponentMacro.build())
interface Property 
{
	function id():Int;
	function clone():Property;
}
