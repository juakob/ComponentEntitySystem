package inspector.ui;
import zui.Id;
import zui.Zui;

/**
 * ...
 * @author Joaquin
 */
class EntityProperties
{
	static var  handle:Handle = new Handle();
	
	public static function  draw(ui:Zui,logic:Logic)
	{
		EntityProperties.handle.redraws = 2;
		if (ui.window(EntityProperties.handle, 400, 100, 200, 400, true)&&true) {
			
			if(ui.panel(handle,"Property Inspector")){
				var entity:inspector.logicDomain.EntityProperties = logic.entities.currentEntity;
				for (property in entity.properties) 
				{
					
				if (ui.panel(property.handle, property.name)&&true) 
					{
						for (variable in property.variables) 
						{
							variable.handle.text = variable.value;
							
							Attribute.show(ui, variable);
							if (variable.handle.changed)
							{
								logic.updateValue(property.id, variable.id, variable.handle.text);
							}
						}
					}
				}
			}
				
		}
	}
}