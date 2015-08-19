package entitySystem;
import entitySystem.Message;
import entitySystem.MessageResult;

/**
 * ...
 * @author Joaquin
 */
@:autoBuild(entitySystem.macros.ActionIdMacro.build())
class EntityState implements IEntityState
{
	var mEntities:Array<Int>;
	public function new() 
	{
		mEntities = new Array();	
	}
	public function add(aEntity:Entity):Void
	{
		//TODO add  to entity so it can remove itself
		if (mEntities.indexOf(aEntity.id)!=-1)
		{
			mEntities.push(aEntity.id);
		}
	}

	public function remove(aEntity:Entity):Void
	{
		var index:Int = indexOf(aEntity.id) ;
		if (index!=-1)
		{
			mEntities.splice(index,1);
		}
	}
	
	public function handleEvent(message:Message):MessageResult 
	{
		if (mEntities.indexOf(message.to.id)!=-1)
		{
			setState(message);
		}
	}
	public function setState(message:Message):MessageResult 
	{
		throw "override this function";
	}
	
	
	
}