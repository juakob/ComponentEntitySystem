package inspector.logicDomain;

/**
 * ...
 * @author Joaquin
 */
class EntityProperties
{
	public var id:String="";
	public var properties:Array<Property> = new Array();
	public function new() 
	{
		
	}
	public function add(aProperty:Property)
	{
		properties.push(aProperty);
	}
	public function getProperty(name:String) :Property
	{
		for (prop in properties) 
		{
			if (prop.name == name || "Pr" + prop.name == name)
			{
				return prop;
			}
		}
		return null;
	}
	public function getPropertyBy(id:Int) :Property
	{
		for (prop in properties) 
		{
			if (prop.id == id)
			{
				return prop;
			}
		}
		return null;
	}
	public inline function getPropertyAt(aId:Int):Property
	{
		return properties[aId];
	}
	public function reset()
	{
		properties.splice(0, properties.length);
	}
	public function deleteUnUpdatedProperties() 
	{
		var toDelete:Array<Property> = new Array();
		for (prop in properties) 
		{
			if (!prop.updated)
			{
				toDelete.push(prop);
			}
			prop.updated = false;
		}
		for (prop in toDelete) 
		{
			properties.remove(prop);
		}
	}
	
}