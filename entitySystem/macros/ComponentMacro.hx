package entitySystem.macros ;
import entitySystem.Property;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.db.Types.STinyInt;
 
class ComponentMacro
{
	private static var idCount = 0;
 
	
	macro public static function build(): Array<Field>
	{
		var pos = haxe.macro.Context.currentPos();
		var mk = function( expr ) return {expr: expr, pos: pos};
        var fields = haxe.macro.Context.getBuildFields();
       	var tint = TPath({ pack : [], name : "Int", params : [], sub : null });
        	fields.push( { name : "ID", doc : null, meta : [], access : [AStatic, APublic], kind : FVar(tint, {expr: EConst(CInt(Std.string(idCount))), pos: pos}) , pos: pos });
        	fields.push( 
	        	{ 
		        	name: "id", 
		        	doc: null, 
		        	meta:[], 
		        	access: [APublic], 
		        	kind: FFun(
		        	{ 
			        	ret: tint, params: [], args: [], expr: mk( EReturn( mk( EConst(CInt(Std.string(idCount)))))) 
			        } ), 
					pos: pos
				} ); 
        idCount++;
		
		//clone function
		
		var code:String;
		var exp:Array<Expr> = new Array();
		var nodeType:String =  Context.getLocalClass().toString();
		code = "var copy:" + nodeType+" = new " +nodeType +"()";
		
		
		exp.push(Context.parseInlineString(code, Context.currentPos()));
		
		 var cloneAlreadyDefinded:Bool = false;
		var array =Context.getBuildFields();
		for (i in array) 
		{
			if (i.kind.match(FieldType.FFun))
			{
				if (i.name == "clone")
				{
					//clone is implemented
					cloneAlreadyDefinded = true;
					break;
				}
				continue;
			}
			code = "copy." + i.name+" = this." +  i.name;
			exp.push(Context.parseInlineString(code, Context.currentPos()));
		}
		code = "return copy";
		exp.push(Context.parseInlineString(code, Context.currentPos()));
		   
		if (!cloneAlreadyDefinded)
		{
			var c = macro : {
				public function clone():Property{
					$b { exp }
				}
			}
			
			switch (c) {
				case TAnonymous(cloneFunction):
					fields=fields.concat(cloneFunction);
				default:
					throw 'unreachable';
			}
		}
		
		//set function
		
		var code:String;
		var exp:Array<Expr> = new Array();
		var nodeType:String =  Context.getLocalClass().toString();
		code = "var original:" + nodeType+" = cast aProperty";
		
		
		exp.push(Context.parseInlineString(code, Context.currentPos()));
		
		 var setAlreadyDefinded:Bool = false;
		var array =Context.getBuildFields();
		for (i in array) 
		{
			if (i.kind.match(FieldType.FFun))
			{
				if (i.name == "set")
				{
					//set is implemented
					setAlreadyDefinded = true;
					break;
				}
				continue;
			}
			code = "this." + i.name+" = original." +  i.name;
			exp.push(Context.parseInlineString(code, Context.currentPos()));
		}
		  
		if (!setAlreadyDefinded)
		{
			var c = macro : {
				public function set(aProperty:Property):Void{
					$b { exp }
				}
			}
			
			switch (c) {
				case TAnonymous(setFunction):
					return fields.concat(setFunction);
				default:
					throw 'unreachable';
			}
		}
		
		return fields;
	}	
	
	
	
}