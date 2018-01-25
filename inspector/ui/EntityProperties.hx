package inspector.ui;
import inspector.customComponents.TextInputAdvance;
import inspector.logicDomain.CurrentEntity;
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
				var entity:CurrentEntity = logic.entities.currentEntity;
				for (property in entity.properties) 
				{
					
				if (ui.panel(property.handle, property.name)&&true) 
					{
						for (variable in property.variables) 
						{
							if(variable.type=="f"){
								variable.handle.text = TextInputAdvance.floatToStringPrecision(Std.parseFloat(variable.value),2);
							}else {
								variable.handle.text = variable.value;
							}
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