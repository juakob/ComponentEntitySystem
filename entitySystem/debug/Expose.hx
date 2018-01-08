package entitySystem.debug;
import entitySystem.debug.ExposeObject.ExposeBool;
import entitySystem.debug.ExposeObject.ExposeFloat;
import entitySystem.debug.ExposeObject.ExposeInt;
import entitySystem.debug.ExposeObject.ExposeString;

/**
 * ...
 * @author Joaquin
 */
class Expose
{
	
	public static var i(get, null):Expose;
	private static var initialized:Bool;

	private static function get_i():Expose
	{
		if (initialized) return i;
		initialized = true;
		i = new Expose();
		return i;
	}
	
	private var floats:Map<Int,ExposeFloat>;
	private var strings:Map<Int,ExposeString>;
	private var ints:Map<Int,ExposeInt>;
	private var bools:Map<Int,ExposeBool>;
	private var id:Int = 0;
	
	public function new() 
	{
		floats = new Map();
		strings = new Map();
		ints = new Map();
		bools = new Map();
	}
	public function addFloat(object:Dynamic, displayName:String, get:Dynamic->Float, set:Dynamic->Float->Void)
	{
		var floatObject = new ExposeFloat(object, displayName, get, set);
		floats.set(id++, floatObject);
	}
	public function addString(object:Dynamic, displayName:String, get:Dynamic->String, set:Dynamic->String->Void)
	{
		var stringObject = new ExposeString(object, displayName, get, set);
		strings.set(id++, stringObject);
	}
	public function addInt(object:Dynamic, displayName:String, get:Dynamic->Int, set:Dynamic->Int->Void)
	{
		var intObject = new ExposeInt(object, displayName, get, set);
		ints.set(id++, intObject);
	}
	public function addBool(object:Dynamic, displayName:String, get:Dynamic->Bool, set:Dynamic->Bool->Void)
	{
		var boolObject = new ExposeBool(object, displayName, get, set);
		bools.set(id++, boolObject);
	}
	 macro public static function exposeFloat(object:Dynamic,attribute:String,displayName:String) {
		#if expose
		 return macro { Expose.i.addFloat(	$object, 
											$v { displayName }, 
											function(o:Dynamic):Float { return  o.$attribute; },
											function(o:Dynamic, value:Float):Void { o.$attribute = value;  }
											);
		 };
		#end
		
	 }
}