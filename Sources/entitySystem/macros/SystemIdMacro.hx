package entitySystem.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class SystemIdMacro {
	private static var idCount = 0;
	@:persistent static var namesId:Map<String,Int> = new Map();
	
	macro public static function build():Array<Field> {
		var pos = haxe.macro.Context.currentPos();
		var mk = function(expr) return {expr: expr, pos: pos};
		var fields = haxe.macro.Context.getBuildFields();
		var className=haxe.macro.Context.getLocalClass().get().name;
		var idValue=idCount;	
		if(namesId.exists(className)){
			idValue=namesId.get(className);
		}else{
			namesId.set(className,idValue);
		}

		var tint = TPath({
			pack: [],
			name: "Int",
			params: [],
			sub: null
		});
		fields.push({
			name: "ID",
			doc: null,
			meta: [],
			access: [AStatic, APublic],
			kind: FVar(tint, {expr: EConst(CInt(Std.string(idValue))), pos: pos}),
			pos: pos
		});
		fields.push({
			name: "id",
			doc: null,
			meta: [],
			access: [APublic, AOverride],
			kind: FFun({
				ret: tint,
				params: [],
				args: [],
				expr: mk(EReturn(mk(EConst(CInt(Std.string(idValue))))))
			}),
			pos: pos
		});
		idCount++;

		return fields;
	}

	macro public static function getId() {
		return macro $v{idCount++};
	}
}
