package entitySystem;
import entitySystem.SystemManager.ES;

/**
 * ...
 * @author Joaquin
 */
class EntityPool
{
	var mPool:Array<Entity>;
	public function new() 
	{
		mPool = new Array();
	}
	
	public function recycle():Entity
	{
		for (entity in mPool)
		{
			if (!entity.Alive)
			{
				entity.Alive = true;
				#if expose
				ES.i.addEntityToList(entity);
				#end
				return entity;
			}
		}
		var entity = new Entity();
		entity.InPool = true;
		mPool.push(entity);
		return entity;
	}
	public function currentSize():Int
	{
		return mPool.length;
	}
}