package entitySystem.properties;

/**
 * ...
 * @author Joaquin
 */
class ComplexProperty
{
	public var clone:Entity->Property;
	public var set:Entity->Property->Void;
	public var id:Int;
	public function new() 
	{
		
	}
	public function cloneF():ComplexProperty
	{
		var cl:ComplexProperty = new ComplexProperty();
		cl.clone = clone;
		cl.set = set;
		cl.id = id;
		return cl;
	}
	
}