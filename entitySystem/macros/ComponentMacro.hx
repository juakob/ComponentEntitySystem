package entitySystem.macros ;
import entitySystem.Property;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
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
		var cloneAlreadyDefinded:Bool = false;
		var idAlreadyDefinded:Bool = false;
		var setAlreadyDefinded:Bool = false;
		var serializeAlreadyDefinded:Bool = false;
		var setValueAlreadyDefinded:Bool = false;
		var getValueAlreadyDefinded:Bool = false;
		for (i in fields)
		{
			if (i.kind.getName()=="FFun")
			{
				if (i.name == "clone")
				{
					//clone is implemented
					cloneAlreadyDefinded = true;

				}
				else if (i.name == "id")
				{
					//id is implemented
					idAlreadyDefinded = true;

				}
				else if (i.name == "set")
				{
					//set is implemented
					setAlreadyDefinded = true;
					
				}
				else if (i.name == "serialize")
				{
					//serialize is implemented
					serializeAlreadyDefinded = true;
					
				}
				else if (i.name == "setValue")
				{
					
					//setValue is implemented
					setValueAlreadyDefinded = true;
					
				}
				else if (i.name == "getValue")
				{
					
					//setValue is implemented
					getValueAlreadyDefinded = true;
					
				}
			}
		}
		var tint = TPath({ pack : [], name : "Int", params : [], sub : null });
		fields.push( { name : "versionId", doc : null, meta : [], access : [APublic], kind : FVar(tint, { expr: EConst(CInt(Std.string("0"))), pos: pos } ), pos: pos } );
		fields.push( { name : "nextProperty", doc : null, meta : [], access : [APublic], kind : FVar(TPath({ pack : [], name : "Property", params : [], sub : null }), {expr: EConst(CIdent("null")), pos: pos}), pos: pos });
		if (!idAlreadyDefinded)
		{

			fields.push( { name : "ID", doc : null, meta : [], access : [AStatic,AInline, APublic], kind : FVar(tint, {expr: EConst(CInt(Std.string(idCount))), pos: pos}), pos: pos });
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
		}

		//clone function

		if (!cloneAlreadyDefinded)
		{
			var code:String;
			var exp:Array<Expr> = new Array();
			var nodeType:String =  Context.getLocalClass().toString();
			code = "var copy:" + nodeType+" = new " +nodeType +"()";

			exp.push(Context.parseInlineString(code, Context.currentPos()));

			var array =Context.getBuildFields();
			for (i in array)
			{

				if (i.kind.getName()=="FFun")
				{
					continue;
				}
				else if (i.meta.length>0 && i.meta[0].name=="array")
				{
					code = "for(item in this." + i.name+") {  copy." +i.name+".push(item); }" ;
					exp.push(Context.parseInlineString(code, Context.currentPos()));

				}
				else
				{
					code = "copy." + i.name+" = this." +  i.name;
					exp.push(Context.parseInlineString(code, Context.currentPos()));
				}
			}
			code = "return copy";
			exp.push(Context.parseInlineString(code, Context.currentPos()));

			var c = macro :
			{
				public function clone():Property
				{
					$b { exp }
				}
			}

			switch (c)
			{
				case TAnonymous(cloneFunction):
					fields=fields.concat(cloneFunction);
				default:
					throw 'unreachable';
			}
		}

		//set function
		if (!setAlreadyDefinded)
		{
			var code:String;
			var exp:Array<Expr> = new Array();
			var nodeType:String =  Context.getLocalClass().toString();
			code = "var original:" + nodeType+" = cast aProperty";

			exp.push(Context.parseInlineString(code, Context.currentPos()));

			var array =Context.getBuildFields();
			for (i in array)
			{
				if (i.kind.getName()=="FFun")
				{

					continue;
				}
				code = "this." + i.name+" = original." +  i.name;
				exp.push(Context.parseInlineString(code, Context.currentPos()));
			}

			var c = macro :
			{
				public function set(aProperty:Property):Void
				{
					$b { exp }
				}
			}

			switch (c)
			{
				case TAnonymous(setFunction):
					fields=fields.concat(setFunction);
				default:
					throw 'unreachable';
			}
		}

		#if expose
		//serialize function
		if (!serializeAlreadyDefinded)
		{
			var code:String;
			var exp:Array<Expr> = new Array();
			var nodeType:String =  Context.getLocalClass().toString();
			var typeName = nodeType.split(".").pop();
			if (nodeType.indexOf("Pr") == 0)
			{
				typeName = typeName.substring(2, typeName.length);
			}
			code = "var encode:String=\"" + typeName+"?\"+ID+\"?\"";

			exp.push(Context.parseInlineString(code, Context.currentPos()));

			var array =Context.getBuildFields();
			for (i in array)
			{
				
				if (i.kind.getName()=="FFun")
				{

					continue;
				}
				
				if (i.meta.length != 0)
				{
					//if (i.meta[0]. != -1)
					//{
						//trace("ignore");
						//continue;
					//}
					
					for ( p in i.meta[0].params)
					{
						var c = p.expr.getParameters()[0];
						switch(c)
						{
							case CString(s): code = "encode+= \"" + i.name+"."+s+",f,\" +" +i.name+"."+s+"+\"?\"";//TODO add other types other than float
							default: { trace("meta data error " + c); continue; }
						
						}
						exp.push(Context.parseInlineString(code, Context.currentPos()));
					}
				}else
				{
					var type:String = Std.string(i.kind.getParameters()[0]);
					if (type.indexOf("String") !=-1)
					{
						code = "encode+= \"" + i.name+",s,\" +" +i.name+"+\"?\"";
					}
					else if (type.indexOf("Float") !=-1)
					{
						code = "encode+= \"" + i.name+",f,\" +" +i.name+"+\"?\"";
					}
					else if (type.indexOf("Int") !=-1)
					{
						code = "encode+= \"" + i.name+",i,\" +" +i.name+"+\"?\"";
					}
					else if (type.indexOf("Bool") !=-1)
					{
						code = "encode+= \"" + i.name+",b,\" +" +i.name+"+\"?\"";
					}
					else
					{
						code = "encode+= \"" + i.name+",d,\" +" +i.name+"+\"?\"";
					}
					exp.push(Context.parseInlineString(code, Context.currentPos()));
				}
				
			}
			code = "return encode+\";;\"";
			exp.push(Context.parseInlineString(code, Context.currentPos()));

			var c = macro :
			{
				public function serialize():String
				{
					$b { exp }
				}
			}

			switch (c)
			{
				case TAnonymous(setFunction):
					fields=fields.concat(setFunction);
				default:
					throw 'unreachable';
			}
		}

		//set value function
		if (!setValueAlreadyDefinded)
		{
			var code:String;
			var exp:Array<Expr> = new Array();

			var array = Context.getBuildFields();
			var counter:Int = 0;
			for (i in array)
			{
				if (i.kind.getName()=="FFun")
				{

					continue;
				}
				if (i.meta.length != 0)
				{
					for ( p in i.meta[0].params)
					{
						var c = p.expr.getParameters()[0];
						switch(c)
						{
							case CString(s): code = "if ("+counter+"== id){" + i.name+"."+s+"=  Std.parseFloat(value); return;}";//TODO add other types other than float
							default: {trace("meta data error " + c); continue;}
						}
						exp.push(Context.parseInlineString(code, Context.currentPos()));
						++counter;
					}
				}else
				{
					var type:String = Std.string(i.kind.getParameters()[0]);
					if (type.indexOf("String") !=-1)
					{

						code = "if ("+counter+"== id){" + i.name+"=  value; return;}";
					}
					else if (type.indexOf("Float") !=-1)
					{
						code = "if ("+counter+"== id){" + i.name+"= Std.parseFloat(value); return;}";
					}
					else if (type.indexOf("Int") !=-1)
					{
						code = "if ("+counter+"== id){" + i.name+"=  Std.parseInt(value); return;}";
					}
					else if (type.indexOf("Bool") !=-1)
					{
						code = "if ("+counter+"== id){" + i.name+"=  value==\"true\"; return;}";
					}
					else
					{
						code = "if ("+counter+"== id)return";
					}
					exp.push(Context.parseInlineString(code, Context.currentPos()));
					++counter;
				}
				
			}

			var c = macro :
			{
				public function setValue(id:Int, value:String):Void
				{

					$b { exp }
				}
			}

			switch (c)
			{
				case TAnonymous(setFunction):
					fields=fields.concat(setFunction);
				default:
					throw 'unreachable';
			}
		}
		//get value function
		if (!setValueAlreadyDefinded)
		{
			var code:String;
			var exp:Array<Expr> = new Array();

			var array = Context.getBuildFields();
			var counter:Int = 0;
			for (i in array)
			{
				if (i.kind.getName()=="FFun")
				{

					continue;
				}
				if (i.meta.length != 0)
				{
					for ( p in i.meta[0].params)
					{
						var c = p.expr.getParameters()[0];
						switch(c)
						{
							case CString(s): code = "if ("+counter+"== id){ return Std.string(" + i.name+"."+s+");}";//TODO add other types other than float
							default: {trace("meta data error " + c); continue;}
						}
						exp.push(Context.parseInlineString(code, Context.currentPos()));
						++counter;
					}
				}else
				{
					
					code = "if ("+counter+"== id){ return Std.string("+ i.name+");}";
					
					exp.push(Context.parseInlineString(code, Context.currentPos()));
					++counter;
				}
				
			}

			var c = macro :
			{
				public function getValue(id:Int):String
				{

					$b { exp }
					throw "id error";
				}
			}

			switch (c)
			{
				case TAnonymous(setFunction):
					fields=fields.concat(setFunction);
				default:
					throw 'unreachable';
			}
		}
		
		#end
		return fields;
	}

}