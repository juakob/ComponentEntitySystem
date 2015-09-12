package entitySystem;
import entitySystem.SystemManager.ES;
import openfl.errors.Error;

/**
 * ...
 * @author Joaquin
 */
class Entity
{
	private static var s_id:Int = 0;
	public var id:Int;
	public var Alive:Bool;
	public var InPool:Bool;
	private var mProperties:Map<Int,Property>;
	public var Systems(default, null):Array<Int>;
	public var Listeners(default, null):Array<Int>;
	public function new() 
	{
		Alive = true;
		id =++s_id;
		mProperties = new Map();
		Systems = new Array();
		Listeners = new Array();
		SystemManager.i.addEntityToDictionary(this);//TODO Is this necesary?
	}
	public function add(aProperty:Property, aCopy:Bool = false ):Void
	{
		if (!aCopy)
		{
			mProperties.set(aProperty.id(), aProperty);
		}else {
			if (mProperties.exists(aProperty.id()))
			{
				mProperties.get(aProperty.id()).set(aProperty);
			}else {
				mProperties.set(aProperty.id(), aProperty.clone());
			}
		}
	}
	public function get(aId:Int):Property
	{
		return mProperties.get(aId);
	}
	public function remove(aId:Int):Void
	{
		mProperties.remove(aId);
	}
	public function addSystem(aSystemId:Int):Bool
	{
		if (Systems.indexOf(aSystemId) != -1)
		{
			return false;
		}
		Systems.push(aSystemId);
		return true;
	}
	public function addListener(aListenerId:Int):Bool
	{
		if (Listeners.indexOf(aListenerId) != -1)
		{
			return false;
		}
		Listeners.push(aListenerId);
		return true;
	}
	public function inSystem(aSystemId:Int):Bool
	{
		return Systems.indexOf(aSystemId) > -1;
	}
	public function listening(aSystemId:Int):Bool
	{
		return Listeners.indexOf(aSystemId) > -1;
	}
	
	public function removeSystem(id:Int):Void 
	{
		var index:Int = Systems.indexOf(id);
		if (index > -1)
		{
			Systems.splice(index, 1);
		}
	}
	public function removeListener(id:Int):Void
	{
		var index:Int = Listeners.indexOf(id);
		if (index > -1)
		{
			Listeners.splice(index, 1);
		}
	}
	public function kill():Void
	{
		ES.i.deleteEntity(this);
		
	}
	public function clone():Void
	{
		var clone:Entity = new Entity();
		var keys = mProperties.keys();
		for (key in keys) 
		{
			clone.mProperties.set(key, mProperties.get(key).clone());
		}
		for (systemId in Systems) 
		{
			SystemManager.i.addEntity(clone, systemId);
		}
		for (listenerId in Listeners) 
		{
			SystemManager.i.subscribeEntity(clone, listenerId);
		}
	}
	
	
	
	
	/**
	 * Call kill or SystemManager.deleteEntity(aEntity:Entity) to destroy an entity
	 */
	public function destroy() 
	{
		Alive = false;
		if (InPool)
		{
			Systems.splice(0, Systems.length);
			return;
		}
		var properties = mProperties.iterator();
		for (property in properties) 
		{
			ES.i.storeProperty(property);
		}
		mProperties = null;
		Systems = null;
	}
}