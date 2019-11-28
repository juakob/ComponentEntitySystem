package inspector.logicDomain;

/**
 * ...
 * @author Joaquin
 */
class CurrentEntity {
	public var id:String = "";
	public var properties:Array<Property> = new Array();
	public var messages:Array<String> = new Array();
	public var duplicate:Array<Int> = new Array();

	public function new() {}

	public function add(aProperty:Property) {
		properties.push(aProperty);
	}

	public function getProperty(name:String):Property {
		for (prop in properties) {
			if (prop.name == name || "Pr" + prop.name == name) {
				return prop;
			}
		}
		return null;
	}

	public function getPropertyBy(id:Int):Property {
		for (prop in properties) {
			if (prop.id == id) {
				return prop;
			}
		}
		return null;
	}

	public inline function getPropertyAt(aId:Int):Property {
		return properties[aId];
	}

	public function reset() {
		properties.splice(0, properties.length);
		messages.splice(0, messages.length);
		duplicate.splice(0,duplicate.length);
	}

	public function deleteUnUpdatedProperties() {
		var toDelete:Array<Property> = new Array();
		for (prop in properties) {
			if (!prop.updated) {
				toDelete.push(prop);
			}
			prop.updated = false;
		}
		for (prop in toDelete) {
			properties.remove(prop);
		}
	}

	public function addMessages(aMessages:String) {
		if (aMessages == null || aMessages == "")
			return;
		aMessages = aMessages.substr(0, aMessages.length - 2);
		var newMessages = aMessages.split(";;");
		for(message in newMessages){
			if(messages.length==0 || message !=messages[0]){
				messages.insert(0,message);
				duplicate.insert(0,0);
			}else{
				++duplicate[0];
			}
		}
		 
	}
}
