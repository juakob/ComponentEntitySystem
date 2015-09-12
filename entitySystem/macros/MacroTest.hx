package entitySystem.macros ;
import entitySystem.Entity;
import entitySystem.PropertyNode;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
/**
 * ...
 * @author Joaquin
 */
class MacroTest
{

	public function new() 
	{
		
	}
	macro public static function add(e:Expr) {
    return macro $e + $e;
  }
  
  macro public static function generateExtraMethods():Array<Field> {
	  var code:String;
	  var nodeType:String = Context.getLocalClass().get().superClass.params[0].getParameters()[0];
	  var exp:Array<Expr> = new Array();
	   switch (Context.getLocalClass().get().superClass.params[0])
		{
		  case TInst(cl, _):
			  code = "var _node:" + nodeType+" = new " + nodeType+"()";
			exp.push(Context.parseInlineString(code, Context.currentPos()));
			
			code = "_node.owner = aEntity ";
			exp.push(Context.parseInlineString(code, Context.currentPos()));
			
			var array = cl.get().fields.get();
			
			for (i in array) 
			{
				if (i.name == "owner")
				{
					continue;
				}
				code = "_node." + i.name+" = cast(aEntity.get(" + i.type.getParameters()[0].toString() + ".ID)) ";
				exp.push(Context.parseInlineString(code, Context.currentPos()));
			}
			  code = "return _node";
			  exp.push(Context.parseInlineString(code, Context.currentPos()));
			 
		  case _: 
			  trace("Macro error wrong type, look at : " + Context.currentPos);
		}
		//var className = Context.parseInlineString(nodeType, Context.currentPos());
		var c = macro : {
			override public function createNode(aEntity:entitySystem.Entity):entitySystem.PropertyNode{ 
				$b { exp }
			}
		}
		switch (c) {
			
			case TAnonymous(fields):
				return Context.getBuildFields().concat(fields);
			default:
				throw 'unreachable';
		}
	}
	
  macro static public function test(aNode:Class<PropertyNode>)
  {
	//var instanceType.createInstance(aNode,_)
	
	 switch (haxe.macro.Context.getType("MotionNode"))
    {
      case TInst(cl,_):
        var array = cl.get().fields.get();
		for (i in array) 
		{
			trace(cast(Type.resolveClass(i.type.getParameters()[0].toString())));
		}
      case _:
    }
	 var parsed_expr: Expr=Context.parse("var t:String=\"doc\"", Context.currentPos());
	var a_var = macro {parsed_expr: ${parsed_expr} };
	return a_var;
  }
/*  macro static public function
  build(fieldName:String):Array<Field> {

	  var pos = haxe.macro.Context.currentPos();
    var fields = Context.getBuildFields();
	//var type =FunctionArg( { name:"name" } );
	var mk = function( expr ) return {expr: expr, pos: pos};
	var tint = TPath( { pack : [], name : "null", params : [], sub : null } );
    var newField = {
      name: fieldName,
      doc: null,
      meta: [],
      access: [ APublic],
      kind:FFun(
		        	{ 
			        	ret: null,
						params: [],
						args:[ { name:"entity", type:macro:Entity },{ name:"properties", type:macro:Class }],
						expr: macro { 
							entity; 
							}
			        } ),
      pos: Context.currentPos()
    };
    fields.push(newField);
    return fields;
  }*/
}