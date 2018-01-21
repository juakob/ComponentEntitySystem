package inspector.ui;
import inspector.logicDomain.CurrentEntity;
import zui.Id;
import zui.Zui;

/**
 * ...
 * @author Joaquin
 */
class Messages
{
	static var  handle:Handle = new Handle();
	
	public static function  draw(ui:Zui,logic:Logic)
	{
		handle.redraws = 2;
		if (ui.window(handle, 600, 100, 500, 400, true)) {
			
			if(ui.panel(handle,"Messages")){
				var entity:CurrentEntity = logic.entities.currentEntity;
				for (x in 0...Std.int(entity.messages.length/6)) 
				{
					ui.row([1 / 6, 1 / 6, 1 / 6, 1 / 6, 1 / 6, 1 / 6]);
					for (i in (x*6)...((x*6)+6))
					{
						ui.text(entity.messages[i]);
					}
				}
			}
				
		}
	}
}