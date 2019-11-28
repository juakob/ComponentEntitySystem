package entitySystem.macros;

import entitySystem.Property;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import sys.db.Types.STinyInt;

class ConstantsMacro {
	macro public static function build():Array<Field> {
		var fields = haxe.macro.Context.getBuildFields();
		#if expose
		var pos = haxe.macro.Context.currentPos();
		var mk = function(expr) return {expr: expr, pos: pos};

		var nodeType:String = Context.getLocalClass().toString();
		var typeName = nodeType.split(".").pop();
		if (nodeType.indexOf("Cs") != -1) {
			typeName = typeName.substring(2, typeName.length);
		}

		var tint = TPath({
			pack: [],
			name: "String",
			params: [],
			sub: null
		});

		{
			fields.push({
				name: "ID",
				doc: null,
				meta: [],
				access: [AStatic, AInline, APublic],
				kind: FVar(tint, {expr: EConst(CString(typeName)), pos: pos}),
				pos: pos
			});
		}

		// toCSV function
		var code:String;
		var exp:Array<Expr> = new Array();

		code = "var encode:String=\"" + typeName + "?\"";

		exp.push(Context.parseInlineString(code, Context.currentPos()));

		var array = Context.getBuildFields();
		for (i in array) {
			if (i.kind.getName() == "FFun") {
				continue;
			}
			if (i.meta.length != 0 && (i.meta[0].name == "ignore" || i.meta[0].name == "ignore")) {
				continue;
			}

			var type:String = Std.string(i.kind.getParameters()[0]);
			if (type.indexOf("String") != -1) {
				code = "encode+= \"" + i.name + ",s,\" +" + nodeType + "." + i.name + "+\"?\"";
			} else if (type.indexOf("Float") != -1) {
				code = "encode+= \"" + i.name + ",f,\" +" + nodeType + "." + i.name + "+\"?\"";
			} else if (type.indexOf("Int") != -1) {
				code = "encode+= \"" + i.name + ",i,\" +" + nodeType + "." + i.name + "+\"?\"";
			} else if (type.indexOf("Bool") != -1) {
				code = "encode+= \"" + i.name + ",b,\" +" + nodeType + "." + i.name + "+\"?\"";
			} else {
				code = "encode+= \"" + i.name + ",d,\" +" + nodeType + "." + i.name + "+\"?\"";
			}
			exp.push(Context.parseInlineString(code, Context.currentPos()));
		}

		code = "return encode";
		exp.push(Context.parseInlineString(code, Context.currentPos()));

		var c = macro:{
			public static function toCSV():String {
				$b{exp}
			}
		}

		switch (c) {
			case TAnonymous(setFunction):
				fields = fields.concat(setFunction);
			default:
				throw 'unreachable';
		}

		// set value function

		var code:String;
		var exp:Array<Expr> = new Array();

		var array = Context.getBuildFields();
		var counter:Int = 0;
		for (i in array) {
			if (i.kind.getName() == "FFun") {
				continue;
			}
			if (i.meta.length != 0 && i.meta[0].name == "ignore") {
				continue;
			}

			var type:String = Std.string(i.kind.getParameters()[0]);
			if (type.indexOf("String") != -1) {
				code = "if (\"" + i.name + "\"== name){" + nodeType + "." + i.name + "=  value; return;}";
			} else if (type.indexOf("Float") != -1) {
				code = "if (\"" + i.name + "\"== name){" + nodeType + "." + i.name + "= Std.parseFloat(value); return;}";
			} else if (type.indexOf("Int") != -1) {
				code = "if (\"" + i.name + "\"== name){" + nodeType + "." + i.name + "=  Std.parseInt(value); return;}";
			} else if (type.indexOf("Bool") != -1) {
				code = "if (\"" + i.name + "\"== id){" + nodeType + "." + i.name + "=  value==\"true\"; return;}";
			} else {
				code = "if (\"" + i.name + "\"== name)return";
			}
			exp.push(Context.parseInlineString(code, Context.currentPos()));
			++counter;
		}

		var c = macro:{
			public static function setValue(name:String, value:String):Void {
				$b{exp}
			}
		}

		switch (c) {
			case TAnonymous(setFunction):
				fields = fields.concat(setFunction);
			default:
				throw 'unreachable';
		}
		#end
		return fields;
	}
}
