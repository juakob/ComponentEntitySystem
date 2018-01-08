package entitySystem.debug;

/**
 * ...
 * @author Joaquin
 */
class ExposeObject<T>
{
	public var object:Dynamic;
	public var displayName:String;
	public var get:Dynamic->T;
	public var set:Dynamic->T->Void;
	public function new(aObject:Dynamic,aDisplayName:String,aGet:Dynamic->T,aSet:Dynamic->T->Void) 
	{
		object = aObject;
		displayName = aDisplayName;
		get = aGet;
		set = aSet;
	}
	
}
class ExposeFloat extends ExposeObject<Float>
{

}
class ExposeString extends ExposeObject<String>
{

}
class ExposeInt extends ExposeObject<Int>
{
	
}
class ExposeBool extends ExposeObject<Bool>
{
	
}