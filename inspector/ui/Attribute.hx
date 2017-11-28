package inspector.ui;
import inspector.customComponents.TextInputAdvance;
import inspector.logicDomain.Property.Variable;
import zui.Id;
import zui.Zui;

/**
 * ...
 * @author Joaquin
 */
@:access(zui.Zui)
class Attribute
{

	public static function showString(aUi:Zui,aHandle:Handle,aName:String)
	{
		aUi.textInput(aHandle, aName);
	}
	
	
	static public function show(ui:Zui, variable:Variable) 
	{
		if (variable.type == "f")
		{
			TextInputAdvance.TextScroller(ui, variable.handle, variable.name);
		}else {
			showString(ui, variable.handle, variable.name);	
		}
	}
	
}