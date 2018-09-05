package inspector.ui;

import zui.Id;
import zui.Zui;

/**
 * ...
 * @author Joaquin
 */
class Console {
	public static function draw(ui:Zui, logic:Logic) {
		if (ui.window(Id.handle(), 130, 10, 100, 120, true)) {
			ui.row([1 / 4, 1 / 4, 1 / 4, 1 / 4]);
			if (ui.button("||")) {
				logic.pauesApp();
			}
			if (ui.button("|>")) {
				logic.stepApp();
			}
			if (ui.button(">>")) {
				logic.resumeApp();
			}
			if (logic.visible) {
				if (ui.button("-"))
					logic.visible = false;
			} else {
				if (ui.button("+"))
					logic.visible = true;
			}
		}
	}
}
