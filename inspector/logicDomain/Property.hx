package inspector.logicDomain;
import zui.Zui.Handle;


/**
 * ...
 * @author Joaquin
 */
class Property
{
	public var name:String;
	public var updated:Bool;
	public var id:Int;
	public var variables:Array<Variable>;
	public var metadata:String;
	public var handle:Handle;
	
	public function new() 
	{
		variables = new Array();
		handle = new Handle();
		handle.redraws = 2;
	}
	function addVariable(aName:String,aVarId)
	{
		var variable = new Variable(aName,aVarId,id);
		variables.push(variable);
		return variable;
	}
	public function get(aName:String):Variable
	{
		for (variable in  variables) 
		{
			if (variable.name == aName)
			{
				return variable;
			}
		}
		throw "variable "+aName+" not found in property" +name ;
	}
	public function getVarId(aName:String):Int
	{
		for (variable in  variables) 
		{
			if (variable.name == aName)
			{
				return variable.id;
			}
		}
		throw "variable "+aName+" not found in property " +name +" options "+variables;
	}
	public function addVariables(items:Array<String>)
	{
		var counter:Int=0;
		for (item in items) 
		{
			var parts:Array<String> = item.split(",");

			var variable = addVariable(parts[0], counter);
			variable.type = parts[1];
			variable.value = parts[2];
			++counter;
		}
	}
}
class Variable{
	public var name:String;
	public var id:Int;
	public var propId:Int;
	public var selected:Bool;
	public var type:String;
	public var value:String;
	public var handle:Handle;
	
	
	public function new(aName:String, aId:Int,aPropId:Int)
	{
		name = aName;
		id = aId;
		propId = aPropId;
		handle = new Handle();
		handle.redraws = 2;
		handle.text = value;
	}
}