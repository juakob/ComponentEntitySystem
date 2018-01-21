package inspector.ui;
import inspector.customComponents.TextInputAdvance;
import zui.Id;
import zui.Zui;

/**
 * ...
 * @author Joaquin
 */
class Expose
{
	static var  handle:Handle = new Handle();
	public function new() 
	{
		
	}
	public static function  draw(ui:Zui,logic:Logic)
	{
		var exposeRaw = logic.exposeObjects.rawData;
		if (exposeRaw == null||exposeRaw=="") return;
		var data = exposeRaw.split(";;");
		handle.redraws = 2;
		if (ui.window(handle, 600, 300, 500, 400, true)) {
		//	if(ui.panel(handle,"expose")){
				for (attribute in data) 
				{
					var components = attribute.split(",");
					//if (components[2] == "f")
					//{
						//TextInputAdvance.TextScroller(ui, Id.handle( { text : components[1] } ) , components[0]);
					//}else {
					handle.text = components[2] ;
						ui.textInput(handle, components[1]);
						if (handle.changed)
						{
							trace(Std.parseInt(components[0]));
							logic.updateExpose(Std.parseInt(components[0]), handle.text);
						}
					//}	
				}
		//	}
		}
	}
}