package inspector.ui;

import inspector.customComponents.TextInputAdvance;
import zui.Id;
import zui.Zui;

/**
 * ...
 * @author Joaquin
 */
class Expose {
	static var handle:Handle = new Handle();
	static var tempHandles:Array<Handle> = new Array<Handle>();

	public static function draw(ui:Zui, logic:Logic) {
		var exposeRaw = logic.exposeObjects.rawData;
		if (exposeRaw == null || exposeRaw == "")
			return;
		var data = exposeRaw.split(";;");
		data.pop(); // is empty
		handle.redraws = 2;
		if (ui.window(handle, 600, 300, 500, 400, true)) {
			//	if(ui.panel(handle,"expose")){
			var counter:Int = 0;
			for (attribute in data) {
				if (counter >= tempHandles.length)
					tempHandles.push(new Handle());
				var components = attribute.split(",");
				// if (components[2] == "f")
				// {
				// TextInputAdvance.TextScroller(ui, Id.handle( { text : components[1] } ) , components[0]);
				// }else {
				var tempHandle:Handle = tempHandles[counter];
				tempHandle.text = components[2];
				ui.textInput(tempHandle, components[1]);
				if (tempHandle.changed) {
					logic.updateExpose(Std.parseInt(components[0]), tempHandle.text);
				}
				++counter;
				// }
			}
			//	}
		}
	}
}
