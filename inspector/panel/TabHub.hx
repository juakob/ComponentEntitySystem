package panel;

import haxe.ui.containers.Absolute;
import haxe.ui.containers.Box;
import haxe.ui.containers.ContinuousHBox;
import haxe.ui.containers.HBox;
import haxe.ui.containers.ListView;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.TabView;
import haxe.ui.containers.TableView;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.core.UIEvent;
import logicDomain.ConstantClass;
import logicDomain.Entity;
import logicDomain.Property;
import haxe.ui.Toolkit;

/**
 * ...
 * @author Joaquin
 */
class TabHub {
	var entityInspector:EntityInspector;
	var constantInspector:ConstantsInspector;
	var factoryInspector:FactoryInspector;
	var console:Console;

	public function new(logic:Logic) {
		entityInspector = new EntityInspector();
		entityInspector.logic = logic;
		constantInspector = new ConstantsInspector();
		constantInspector.logic = logic;
		factoryInspector = new FactoryInspector();
		factoryInspector.logic = logic;
		console = new Console();

		var tab:TabView = new TabView();
		tab.percentWidth = 100;
		tab.percentHeight = 100;

		var splitter:Component = entityInspector.createWindow();
		splitter.text = "Entities";
		tab.addComponent(splitter);

		// tab.set(0).text = "Entities";
		var constants:Component = constantInspector.createWindow();
		constants.text = "Constants";
		tab.addComponent(constants);
		// tab.getTabButton(1).text =
		var factories:Component = factoryInspector.createWindow();
		factories.text = "Factories";
		tab.addComponent(factories);
		// tab.getTabButton(2).text = "Factories";

		Screen.instance.addComponent(tab);
		var consoleContainer:VBox = new VBox();

		consoleContainer.percentWidth = 100;
		consoleContainer.addComponent(console.createWindow(logic));

		Screen.instance.addComponent(consoleContainer);
	}

	public function update():Void {
		entityInspector.update();
		factoryInspector.update();
	}

	public function updateEntities(newEntities:Array<Entity>):Void {
		entityInspector.updateEntities(newEntities);
	}

	public function updateProperties(aId:String, proptiesRaw:Array<String>):Void {
		entityInspector.updateProperties(aId, proptiesRaw);
	}

	public function updateMeta(id:String, parts:Array<String>) {
		entityInspector.updateMeta(id, parts);
	}

	public function updateConstants(constants:Array<ConstantClass>) {
		constantInspector.updateConstantsClass(constants);
	}

	public function updateFactories(newEntities:Array<Entity>):Void {
		factoryInspector.updateEntities(newEntities);
	}

	public function updateFactoryProperties(aId:String, proptiesRaw:Array<String>):Void {
		factoryInspector.updateProperties(aId, proptiesRaw);
	}
}
