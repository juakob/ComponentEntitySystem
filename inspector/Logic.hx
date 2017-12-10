package inspector;
#if cpp
import sys.FileSystem;
#end
import inspector.logicDomain.Entities;
import inspector.net.IServer;
import inspector.net.Local;
import inspector.io.RWData;
import inspector.net.LocalServer;
import kha.Scheduler;
import inspector.logicDomain.ConstantClass;
import inspector.logicDomain.Entity;



/**
 * ...
 * @author Joaquin
 */
class Logic
{
	
	var server:IServer;
	
	
	
	public var entities:Entities;
	public function new() 
	{
	
		server = LocalServer.i;//new Server();
		server.onConnection(onConnection);
	
		entities = new Entities();
	}
	
	function onConnection() 
	{
	
		checkLocalFiles = true;
		server.send("7?;>");//get constants
		server.send("9?;>");//get factories
	
	}
	var timer:Float = 0;
	var currentEntityId:String;
	var checkLocalFiles:Bool;
	public function update():Void 
	{
	
		
		if (Scheduler.realTime() - timer< 0.05)
		{
			
			return;
		}else{
	
		timer = Scheduler.realTime();
		server.send("1?*;>");
		server.send("2?*"+currentEntityId+";>");
		}
		
		
		server.update();
		var ignore1:Bool = false;
		var ignore2:Bool = false;
		
		while (server.messagesToRead() > 0)
		{
			var parts:Array<String> = server.popMessage().split("?*");
			if (parts[0] == "1"&&!ignore1)
			{
				ignore1 = true;
				entities.updateEntities(createEntities(parts[1]));
			}else
			if (parts[0] == "2"&&!ignore2)
			{
				ignore2 = true;
				entities.updateProperties(parts[1],parts[2].split(";;"));
			}else 
			if(parts[0]=="5" ){
			//	dynamicUpdater.updateMeta(parts[1],parts[2].split(";;"));
			}else 
			if (parts[0] == "7" ) {
				
			//	dynamicUpdater.updateConstants(createConstants(parts[1]));
			}else
			if (parts[0] == "9")
			{
				var factories:Array<Entity> = createEntities(parts[1]);
			//	dynamicUpdater.updateFactories(factories);
				if (checkLocalFiles)
				{
					checkLocalFiles = false;
					for (entity in factories) 
					{
						if (RWData.exist(entity.id))
						{
							server.send("13?*" + entity.id + ";;"+ RWData.read(entity.id));
						}
					}
				}
			}
			else
			if (parts[0] == "10")
			{
				ignore2 = true;
			//	dynamicUpdater.updateFactoryProperties(parts[1],parts[2].split(";;"));
			}
			else
			if (parts[0] == "12")
			{
				ignore2 = true;
				createFile(parts[1],parts[2]);
			}
		}
		
	}
	
	function createFile(name:String, data:String) 
	{
		RWData.createFile(name, data);
	}
	public function saveFactory() {
		
		server.send("12?*" + currentEntityId + ";>");
		
	}
	private function createEntities(message:String):Array<Entity> {
		var entities:Array<Entity> = new Array();
		var entitiesRaw:Array<String> = message.split("*");
		for (entityRaw in entitiesRaw) 
		{
			var parts:Array<String> = entityRaw.split("?");
			var entity:Entity = new Entity();
			entity.text = parts[0];
			entity.id = parts[1];
			entities.push(entity);
		}
		return entities;
	}
	private function createConstants(message:String):Array<ConstantClass> {
		var constants:Array<ConstantClass> = new Array();
		var constantsRaw:Array<String> = message.split(";;");
		constantsRaw.pop();//empty
		for (constantClassRaw in constantsRaw) 
		{
			var parts:Array<String> = constantClassRaw.split("?");
			var constantClass:ConstantClass = new ConstantClass();
			constantClass.name = parts.shift();
			parts.pop();//empty
			for (constantRaw in parts) 
			{
				var parts:Array<String> = constantRaw.split(",");
				constantClass.addVariable(parts[0], parts[1], parts[2]);
			}
			constants.push(constantClass);
		}
		return constants;
	}
	public function changeEntity(aEntity:Entity)
	{
		
		currentEntityId = aEntity.id;
		server.send("2?*" + currentEntityId + ";>");
		server.send("5?*" + currentEntityId + ";>");
		timer = Scheduler.realTime();
		
	}
	
	public function pauesApp():Void
	{
		server.send("3?*pause;>");
		
	}
	public function resumeApp():Void
	{
		
		server.send("3?*resume;>");
		
	}
	public function stepApp():Void
	{
		
		server.send("3?*step;>");
		
	}
	public function updateValue(aIdProperty:Int,aValueIndex:Int,aValue:String):Void
	{
		
		server.send("4?*"+currentEntityId+"?*"+aIdProperty+"?*"+aValueIndex+"?*"+aValue+";>");
		
	}
	public function changeFactory(aEntity:Entity)
	{
		
		currentEntityId = aEntity.id;
		server.send("10?*" + currentEntityId + ";>");
		
	}
	public function updateFactoryValue(aIdProperty:Int,aValueIndex:Int,aValue:String):Void
	{
		
		server.send("11?*"+currentEntityId+"?*"+aIdProperty+"?*"+aValueIndex+"?*"+aValue+";>");
		
	}
	
	public function activateMetaData(message:String) 
	{
		
		server.send("6?*"+currentEntityId+"?*"+message+";>");
		
	}
	
	public function updateConstant(constantClass:String, constant:String, value:String) 
	{
		
		server.send("8?*"+constantClass+"?*"+constant+"?*"+value+";>");
		
	}
}