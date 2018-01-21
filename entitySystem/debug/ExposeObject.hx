package entitySystem.debug;

/**
 * ...
 * @author Joaquin
 */
class ExposeObject
{
	public var id:Int;
	public var object:Dynamic;
	public var displayName:String;
	public var get:Dynamic->String;
	public var set:Dynamic->String->Void;
	public function new(aObject:Dynamic,aDisplayName:String,aGet:Dynamic->String,aSet:Dynamic->String->Void) 
	{
		object = aObject;
		displayName = aDisplayName;
		get = aGet;
		set = aSet;
	}
	
	/* INTERFACE entitySystem.debug.ExposeGet */
	
	public function toString():String 
	{
		return get(object);
	}
	
}
class ExposeFloat extends ExposeObject
{
	override public function toString():String 
	{
		return super.toString()+",s";
	}
}
class ExposeString extends ExposeObject
{

}
class ExposeInt extends ExposeObject
{
	
}
class ExposeBool extends ExposeObject
{
	
}