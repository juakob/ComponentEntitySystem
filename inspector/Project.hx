package;

import haxe.ui.Toolkit;
import haxe.ui.core.Screen;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import panel.TabHub;

class Project {
	var logic:Logic;
	var dynamicUpdater:panel.TabHub;
	var initialized:Bool = false;
	public function new() {
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);
		Assets.loadEverything(init);
	}
	
	function init() 
	{
		Toolkit.init();
		logic = new Logic();
		dynamicUpdater = new TabHub(logic);
		logic.dynamicUpdater = dynamicUpdater;
		initialized = true;
	}

	function update(): Void {
		if(initialized){
			dynamicUpdater.update();
			logic.update();
		}
	}

	function render(framebuffer: Framebuffer): Void {
		if(initialized){
			 var g = framebuffer.g2;
			g.begin(true, 0xFFFFFF);
			Screen.instance.renderTo(g);
			g.end();
		}
	}
}
