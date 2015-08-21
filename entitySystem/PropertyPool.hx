package entitySystem;

/**
 * ...
 * @author Joaquin
 */
class PropertyPool
{
	var mPool:Array<Property>;
	public function new() 
	{
		mPool = new Array();
	}
	
	public function recycle(aType:Class<Property>):Property
	{
		if (mPool.length > 0)
		{
		return mPool.pop();
		}
		return cast Type.createInstance(aType,[]);
	}
	public function store(aProperty:Property):Void
	{
		mPool.push(aProperty);
	}
}