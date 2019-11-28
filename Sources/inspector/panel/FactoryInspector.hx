package panel;

import haxe.ui.containers.Absolute;
import haxe.ui.components.Button;
import haxe.ui.core.UIEvent;
import logicDomain.Entity;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

/**
 * ...
 * @author Joaquin
 */
class FactoryInspector extends EntityInspector {
	public function new() {
		super();
	}

	override function changeEntity(entity:Entity) {
		logic.changeFactory(entity);
	}

	override function updateValue(propId:Int, id:Int, text:String) {
		logic.updateFactoryValue(propId, id, text);
	}

	override function createComponent(aName:String, aPropID:Int, items:Array<String>):Absolute {
		var container:Absolute = super.createComponent(aName, aPropID, items);
		var save:Button = new Button();
		save.text = "Save";
		// save.x = 200;
		save.onClick = function(onEvent:UIEvent) {
			logic.saveFactory();
		}
		container.addComponent(save);
		return container;
	}
}
