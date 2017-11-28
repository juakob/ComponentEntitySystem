package inspector.ui;
import inspector.logicDomain.Entity;
import zui.Id;
import zui.Zui;

/**
 * ...
 * @author Joaquin
 */
class Entities
{
	public static function  draw(ui:Zui,logic:Logic)
	{
		if (ui.window(Id.handle(), 400, 10, 100, 120, true)) {
			
			var entites:Array<Entity> = logic.entities.allEntities;
			for (entity in entites) 
			{
				if (ui.button(entity.text))
				{
					logic.changeEntity(entity);
				}
			}
				
		}
	}
}