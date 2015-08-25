package entitySystem;

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
				return entity;
			}
		}
		var entity = new Entity();
		entity.InPool = true;
		mPool.push(entity);
		return entity;
	}
}