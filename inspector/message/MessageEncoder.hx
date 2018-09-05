package inspector.message;

import logicDomain.EntityProperties;
import logicDomain.MapToRecAttributeId;
import logicDomain.Property;

/**
 * ...
 * @author Joaquin
 */
class MessageEncoder {
	public function new() {}

	public static inline function encodeShowMetadata(prop:Property, entity:EntityProperties):String {
		var message:String = "";
		var metaParts:Array<String> = prop.metadata.split("?");
		metaParts.pop(); // last one is empty
		for (part in metaParts) {
			var parameters:Array<String> = part.split(",");
			if (parameters[0] == "Rec") {
				message = "Rec?";
				continue;
			}
			parameters.pop(); // last one is empty
			var varDestination:Int = MapToRecAttributeId.mapToRecAttributeId(parameters[0]);
			if (parameters[1].indexOf("*") != -1) {
				var properties:Array<String> = parameters[1].split("*");
				var attributesIds:Array<String> = parameters[2].split("*");
				var operations:Array<String> = parameters[3].split("*");
				for (i in 0...properties.length) {
					if (properties[i] == "fix") {
						message += varDestination + "," + properties[i] + "," + attributesIds[i] + "," + operations[i] + "Fix?";
					} else {
						var property:Property = entity.getProperty(properties[i]);
						var propertySourceId:Int = property.id;
						var attributeSourceId:Int = property.getVarId(attributesIds[i]);
						var op:String = operations[i];
						message += varDestination + "," + propertySourceId + "," + attributeSourceId + "," + op + "?";
					}
				}
			} else if (parameters.length > 2) {
				var property:Property = entity.getProperty(parameters[1]);
				var propertySourceId:Int = property.id;
				var attributeSourceId:Int = property.getVarId(parameters[2]);
				message += varDestination + "," + propertySourceId + "," + attributeSourceId + "?";
			} else {
				message += varDestination + "," + parameters[1] + "?";
			}
		}
		return message;
	}
}
