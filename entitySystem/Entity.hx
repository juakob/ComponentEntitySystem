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
	private var mProperties:Map<Int,Property>;
	public var Systems(default, null):Array<Int>;
	public var Listeners(default, null):Array<Int>;
	public function new() 
	{
		id =++s_id;
		mProperties = new Map();
		Systems = new Array();
		Listeners = new Array();
		SystemManager.i.addEntityToDictionary(this);//TODO Is this necesary?
	}
	public function add(aProperty:Property):Void
	{
		mProperties.set(aProperty.id(), aProperty);
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
		//TODO check if this could leave the state unstable
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
	/**
	 * Call kill or SystemManager.deleteEntity(aEntity:Entity) to destroy an entity
	 */
	
	public function destroy() 
	{
		mProperties = null;
		Systems = null;
	}
}