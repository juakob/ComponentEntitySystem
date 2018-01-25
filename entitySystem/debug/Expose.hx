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
	

	private var id:Int = 0;
	private var all:Array<ExposeObject>;
	
	
	public function new() 
	{
		all = new Array();
	}
	public function encode():String
	{
		var string:String = "";
		for (element in all) 
		{
			string += element.id+","+element.displayName+","+element.toString()+";;";
		}
		return string;
	}
	public function set(aId:Int, aValue:String) {
		for (element in all) 
		{
			if (element.id == aId)
			{
				element.set(element.object, aValue);
			}
		}	
	}
	public function addFloat(object:Dynamic, displayName:String, get:Dynamic->String, set:Dynamic->String->Void)
	{
		var floatObject = new ExposeFloat(object, displayName, get, set);
		floatObject.id=id++;
		all.push(floatObject);
	}
	public function addString(object:Dynamic, displayName:String, get:Dynamic->String, set:Dynamic->String->Void)
	{
		var stringObject = new ExposeString(object, displayName, get, set);
		stringObject.id=id++;
		all.push(stringObject);
	}
	public function addInt(object:Dynamic, displayName:String, get:Dynamic->String, set:Dynamic->String->Void)
	{
		var intObject = new ExposeInt(object, displayName, get, set);
		intObject.id=id++;
		all.push(intObject);
	}
	public function addBool(object:Dynamic, displayName:String, get:Dynamic->String, set:Dynamic->String->Void)
	{
		var boolObject = new ExposeBool(object, displayName, get, set);
		boolObject.id=id++;
		all.push(boolObject);
	}
	 macro public static function exposeFloat(object:Dynamic,attribute:String,displayName:String) {
		#if expose
		 return macro { Expose.i.addFloat(	$object, 
											$v { displayName }, 
											function(o:Dynamic):String { return  o.$attribute; },
											function(o:Dynamic, value:String):Void { o.$attribute = Std.parseFloat(value);  }
										);
		 };
		#end
	 }
	 macro public static function exposeString(object:Dynamic,attribute:String,displayName:String) {
		#if expose
		 return macro { Expose.i.addString(	$object, 
											$v { displayName }, 
											function(o:Dynamic):String { return  o.$attribute; },
											function(o:Dynamic, value:String):Void { o.$attribute = value;  }
											);
		 };
		#end
	 }
	 macro public static function exposeInt(object:Dynamic,attribute:String,displayName:String) {
		#if expose
		 return macro { Expose.i.addInt(	$object, 
											$v { displayName }, 
											function(o:Dynamic):String { return  o.$attribute; },
											function(o:Dynamic, value:String):Void { o.$attribute = Std.parseInt(value);  }
											);
		 };
		#end
	 }
	 macro public static function exposeBool(object:Dynamic,attribute:String,displayName:String) {
		#if expose
		 return macro { Expose.i.addBool(	$object, 
											$v { displayName }, 
											function(o:Dynamic):String { return  o.$attribute; },
											function(o:Dynamic, value:String):Void { o.$attribute = (value=="true");  }
											);
		 };
		#end
	 }
	 
	 public function destroy() 
	 {
		 i = null;
		 initialized = false;
	 }
}