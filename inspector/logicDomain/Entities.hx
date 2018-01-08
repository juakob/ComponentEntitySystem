package inspector.logicDomain;
import inspector.logicDomain.Property.Variable;
import inspector.logicDomain.Entity;


/**
 * ...
 * @author Joaquin
 */
class Entities
{
	public var allEntities:Array<Entity>;
	public var currentEntity:CurrentEntity;
	public function new() 
	{
		allEntities = new Array();
		currentEntity = new CurrentEntity();
	}
	public function updateEntities(newEntities:Array<Entity>):Void
	{
		for (entity in allEntities) 
		{
			entity.found = false;
		}
		var found:Bool;
		for (newEntity in newEntities) 
		{
			found = false;
			for (entity in allEntities) 
			{
				if (entity.id == newEntity.id)
				{
					entity.found = true;
					found = true;
					break;
				}
			}
			if (!found)//new entity
			{
				newEntity.found = true;
				allEntities.push(newEntity);
				
			}
		}
		var toRemove:Array<Entity> = new Array();
		for (entity in allEntities) 
		{
			if (!entity.found)
			{
				toRemove.push(entity);
			}
		}
		for (entity in toRemove) 
		{
			allEntities.remove(entity);
		}
		
	}
	
	public function updateProperties(aId:String,proptiesRaw:Array<String>):Void
	{
		proptiesRaw.pop();//last one is empty
		if (currentEntity.id != aId)
		{
			currentEntity.reset();
			currentEntity.id = aId;
			

			for (prop in proptiesRaw) 
			{
				createProperty(prop);
			}
		}else {
			for (propRaw in proptiesRaw) 
			{
				var variables:Array<String> = propRaw.split("?");
				variables.pop();//last one is empty
				var name:String = variables.shift();
				var propId:Int=Std.parseInt(variables.shift());
				var prop = currentEntity.getPropertyBy(propId);
				if (prop!=null)
				{
					prop.updated = true;
					for (variableRaw in variables) 
					{
						var parts:Array<String> = variableRaw.split(",");
						var variable:Variable = prop.get(parts[0]);
						if (!variable.selected)
						{
							variable.value= parts[2];
						}
					}
				}else
				{
					createProperty(propRaw);
				}
				
			}
			currentEntity.deleteUnUpdatedProperties();
		}
	}
	
	public function addMessages(id:String, messages:String) 
	{
		if (id == currentEntity.id)
		{
			currentEntity.addMessages(messages);
		}
	}
	
	function createProperty(prop:String):Void 
	{
		var parts:Array<String> = prop.split("?");
		parts.pop();//last one is empty
		var name:String = parts.shift();
		var propId:Int = Std.parseInt(parts.shift());
		var prop:Property = new Property();
		currentEntity.add(prop);
		prop.updated = true;
		prop.name = name;
		prop.id = propId;
		prop.addVariables(parts);
	}
	
}