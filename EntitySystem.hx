package entitySystem;

import entitySystem.macros.SystemIdMacro;
import entitySystem.Message;
import entitySystem.MessageResult;
import openfl.errors.Error;
/**
 * ...
 * @author Joaquin
 */
@:autoBuild(entitySystem.macros.SystemIdMacro.build())
class EntitySystem<T> implements ISystem
{
	var mProperties:Array<T>;
	var mEntityes:Array<Entity>;
	var mEntityProperty:Map<Int,T>;
	public function new() 
	{
		mProperties = new Array();
		mEntityes = new Array();
		mEntityProperty = new Map();
		
	}
	public function add(aEntity:Entity,aFirst:Bool=false):Void
	{
		var node:T = cast(createNode(aEntity));
		mEntityes.push(aEntity);
		if (aFirst)
		{
			mProperties.insert(0, node);
		}else{
		mProperties.push(node);
		}
		mEntityProperty.set(aEntity.id, node);
		
	}
	public function remove(aEntity:Entity):Void
	{
		var node:T = mEntityProperty.get(aEntity.id);
		if(node!=null){
		onRemove(node);
		mEntityProperty.remove(aEntity.id);
		mEntityes.remove(aEntity);
		mProperties.remove(node);
		}
		
	}
	private function createNode(aEntity:Entity):PropertyNode
	{
		throw new Error("override this function");
	}
	function onRemove(item:T):Void 
	{
		
	}
	public function process(item:T):Void
	{
		
	}
	public function update():Void
	{
		for (item in mProperties) 
		{
			process(item);
		}
	}
	
	public function id():Int 
	{
		//if macros work correctly this should be override
		throw new Error("Override this method");
	}
	
	public function handleEvent(message:Message,brodcast:Bool=false):MessageResult 
	{
		if (brodcast)
		{
			for (e in mEntityes) 
			{
				message.to = e;
				if (onEvent(message) == MessageResult.ABORT)
				{
					return MessageResult.SUCCESS;
				}
			}
		}else {
			return onEvent(message);
		}
		return SUCCESS;
	}
	
	public function onEvent(message:Message):MessageResult 
	{
		return MessageResult.NOT_IMPLEMENTED;
	}
	
}