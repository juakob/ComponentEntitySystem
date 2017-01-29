package entitySystem;
import entitySystem.Property;

/**
 * ...
 * @author Joaquin
 */
class EntityChild extends Entity
{
	var mParent:Entity;
	public function new(aParent:Entity) 
	{
		super();
		mParent = aParent;
	}
	override public function get(aId:Int):Property 
	{
		var prop:Property = mProperties.get(aId);
		if (prop != null)
		{
			return prop;
		}
		return mParent.get(aId);
	}
	
}