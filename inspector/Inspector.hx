package inspector;
import com.gEngine.GEngine;
import inspector.ui.Console;
import inspector.ui.Entities;
import inspector.ui.EntityProperties;
import kha.Assets;
import kha.Canvas;
import zui.Zui;

/**
 * ...
 * @author Joaquin
 */
class Inspector
{
	var logic:Logic;
	var ui:Zui;
	var initialized:Bool;
	
	
	public function new() {
		logic = new Logic();
		
		ui = new Zui( { font: Assets.fonts.mainfont,scaleFactor:GEngine.i.width/1280 } );
	}

	public function render(framebuffer: Canvas): Void {
		
		ui.begin(framebuffer.g2);
		
		//if (ui.window(Id.handle(), 10, 10, 360, 600, true)) {
			//if (ui.panel(Id.handle({selected: true}), "Panel")) {
				//
				////TextInputAdvance.TextScroller(ui,textHandler, "width");
				//
			//}
		//}
		Console.draw(ui, logic);
		Entities.draw(ui, logic);
		EntityProperties.draw(ui, logic);
		ui.end();	
	}
	public function update() {
		logic.update();
	}
}