package inspector.ui;
import zui.Id;
import zui.Zui;

/**
 * ...
 * @author Joaquin
 */
class Console
{

	public static function  draw(ui:Zui,logic:Logic)
	{
		if (ui.window(Id.handle(), 100, 10, 100, 120, true)) {
				ui.row([1 / 3, 1 / 3, 1 / 3]);
				if (ui.button("||"))
				{
					logic.pauesApp();
				}
				if (ui.button("|>")) {
					logic.stepApp();
				}
				if (ui.button(">>"))
				{
					logic.resumeApp();
				}
		}
	}
	
}