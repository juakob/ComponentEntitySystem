package entitySystem;
import entitySystem.SystemManager.ES;

/**
 * ...
 * @author Joaquin
 */
class EntityChildPool
{
	var mPool:Array<EntityChild>;
	public function new() 
	{
		mPool = new Array();
	}
	
	public function recycle(aParent:Entity):EntityChild
	{
		for (entity in mPool)
		{
			if (!entity.Alive)
			{
				entity.Alive = true;
				#if expose
				ES.i.addEntityToList(entity);
				#end
				entity.reParent(aParent);
				return entity;
			}
		}
		var entity = new EntityChild(aParent);
		entity.InPool = true;
		mPool.push(entity);
		return entity;
	}
	public function currentSize():Int
	{
		return mPool.length;
	}
}