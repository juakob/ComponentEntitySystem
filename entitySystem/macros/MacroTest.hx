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
				if (i.name == "owner"||i.name == "NodeVersion"||i.name == "nextNode")
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
		//FunctionArg
		
		
	}
	
	
  macro static public function createFilterFunctions():Array<Field> 
  {
	  var code:String;
	  var nodeType:String = Context.getLocalClass().get().superClass.params[0].getParameters()[0];
	  var exp:Array<Expr> = new Array();
	  var filterCode:Array<String> = new Array();
	  var arguments:Array<FunctionArg> = new Array();
	  var tint = TPath({ pack : [], name : "Int", params : [], sub : null });
	   switch (Context.getLocalClass().get().superClass.params[0])
		{
			case TInst(cl, _):
				code = "var _node:" + nodeType+" = new " + nodeType+"()";
				exp.push(Context.parseInlineString(code, Context.currentPos()));
				
				//filter code
				filterCode.push("var _filter:Array<Int> = new Array()");
				//
				
				code = "_node.owner = aEntity ";
				exp.push(Context.parseInlineString(code, Context.currentPos()));
				
				var array = cl.get().fields.get();
				var counter:Int = 0;
				for (i in array) 
				{
					if (i.name == "owner"||i.name == "NodeVersion"||i.name == "nextNode")
					{
						continue;
					}
					code = "_node." + i.name+" = cast(aEntity.getVersion(" + i.type.getParameters()[0].toString() + ".ID, aFilter["+counter+"])) ";
					exp.push(Context.parseInlineString(code, Context.currentPos()));
					//filter code
					arguments.push( { name:"" + i.name, type:tint, value : {expr: EConst(CInt("0")), pos: Context.currentPos()} } );
					filterCode.push("_filter.push(" + i.name+")");
					//
				}
				
				code = "return _node";
				exp.push(Context.parseInlineString(code, Context.currentPos()));
				
				//filter code
				filterCode.push("return _filter");
				//
			 
		  case _: 
			  trace("Macro error wrong type, look at : " + Context.currentPos);
		}
	  var fields = Context.getBuildFields();
	  	var treturn = TPath( { pack : [], name : "Array", params : [TPType(tint)], sub : null } );
		var filterExpresion:Array<Expr> = new Array();
		var pos:Position = Context.currentPos();
		for (code in filterCode) 
		{
			filterExpresion.push(Context.parseInlineString(code, pos ));
		}
	
		var expresion:Expr =macro $b { filterExpresion };
		
	
			fields.push( 
	        	{ 
		        	name: "filter", 
		        	doc: null, 
		        	meta:[], 
		        	access: [APublic, AStatic], 
		        	kind: FFun(
		        	{ 
			        	ret: treturn, params: [], args: arguments, expr: expresion
			        } ),
					pos: Context.currentPos()
				} );
	
				
		var c = macro : {
			override private function createNodeFilter(aEntity:entitySystem.Entity,aFilter:Array<Int>):entitySystem.PropertyNode{ 
				$b { exp }
			}
		}
		
		
		 
				
		switch (c) {
			
			case TAnonymous(extra):
				return fields.concat(extra);
			default:
				throw 'unreachable';
		}
  }
  static function makeType()
  {
  }
  static function makeEnumField(name, kind) {
    return {
      name: name,
      doc: null,
      meta: [],
      access: [],
      kind: kind,
      pos: Context.currentPos()
    }
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