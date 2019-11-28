package entitySystem.constants;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

/**
 * ...
 * @author Joaquin
 */
@:autoBuild(entitySystem.macros.ConstantsMacro.build())
class Constant {
	macro public static function test(ff:Expr) {
		var t = ff.expr.getParameters()[0].expr;
		var name:String = ff.expr.getParameters()[1];
		switch (t) {
			case EConst(d):
				{
					switch (d) {
						case CIdent(g): {
								return Context.parseInlineString(g + "." + $v{name}, Context.currentPos());
							}

						default:
					}
				}
			default:
		}

		return macro {};
	}
}
