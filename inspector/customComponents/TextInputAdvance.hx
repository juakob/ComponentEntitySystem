package inspector.customComponents;
import kha.Scheduler;
import kha.input.KeyCode;
import zui.Zui;

/**
 * ...
 * @author Joaquin
 */
@:access(zui.Zui)
class TextInputAdvance
{
	static var acceleration:Float = 0.1;
	static var veloctiy:Float = 0;
	public static function TextScroller(ui:Zui, handle:Handle,label:String) :Float
	{
		ui.row([4 / 6, 0.5 / 6, 0.5 / 6]);
		var value = ui.textInput(handle, label, Align.Left);
		if (handle.changed)
		{
			var value=Std.parseFloat(handle.text);
			if (value != Math.NaN)
			{
				handle.value = value;
			}else {
				handle.text =ui.textToSubmit= handle.value+"";
			}
		}
		
		if (ui.getPushed())
		{
			if (ui.inputStarted)
			{
				veloctiy = 0;
			}
			veloctiy += acceleration;
			handle.text = (Std.parseFloat(handle.text) - veloctiy) + "";
			trace(handle.text);
			handle.changed = true;
		}
		ui.button("<");
		
		if (ui.getPushed())
		{
			if (ui.inputStarted)
			{
				veloctiy = 0;
			}
			veloctiy += acceleration;
			handle.text=(Std.parseFloat(handle.text)+ veloctiy)+"";
			handle.changed = true;
		}
		ui.button(">");
		ui.separator();
		
		return handle.value;
	}
		
}