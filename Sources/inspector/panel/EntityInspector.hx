package panel;

import haxe.ui.containers.Absolute;
import haxe.ui.containers.Box;
import haxe.ui.containers.HBox;
// import haxe.ui.containers.HSplitter;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.VBox;
import haxe.ui.components.Button;
import haxe.ui.components.TextField;
import haxe.ui.components.TextArea;
import haxe.ui.core.Component;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.core.UIEvent;
import helpers.Tools;
import logicDomain.Entity;
import logicDomain.EntityProperties;
import logicDomain.MapToRecAttributeId;
import logicDomain.Property;
import message.MessageEncoder;

/**
 * ...
 * @author Joaquin
 */
class EntityInspector {
	var propertiesContainer:VBox;

	public var logic:Logic;

	var entites:Array<Entity>;
	var entitesButtons:Array<Button>;
	var entitesButtonContainer:VBox;
	var currentEntity:EntityProperties;

	public function new() {
		entitesButtons = new Array();
		entites = new Array();
		currentEntity = new EntityProperties();
	}

	public function createWindow():Component {
		splitter = new HBox();
		splitter.includeInLayout = true;
		splitter.disabled = false;
		entitesButtonContainer = new VBox();

		var boxL:VBox = new VBox();
		var boxR:Box = new Box();
		var scrollView:ScrollView = new ScrollView();
		// scrollView.showVScroll = true;
		propertiesContainer = new VBox();

		scrollView.addComponent(propertiesContainer);
		boxR.addComponent(scrollView);

		scrollView.percentWidth = 100;
		scrollView.percentHeight = 100;

		boxL.percentWidth = 30;
		boxL.percentHeight = 100;
		// boxL.style.padding = 5;
		// boxL.minWidth = 120;

		boxR.percentWidth = 70;
		boxR.percentHeight = 100;
		// boxR.style.padding = 10;

		splitter.percentHeight = 100;
		splitter.percentWidth = 100;

		var list = new ScrollView();

		list.addComponent(entitesButtonContainer);
		list.percentWidth = 100;
		list.percentHeight = 100;
		boxL.addComponent(list);

		splitter.addComponent(boxL);
		splitter.addComponent(boxR);

		// Lib.current.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, function(aEvent:MouseEvent) { mouseDrag = false; activeField = null; } );
		return splitter;
	}

	function createComponent(aName:String, aPropID:Int, items:Array<String>):Absolute {
		var box:Absolute = new Absolute();
		box.percentWidth = 100;

		var prop:Property = new Property();
		currentEntity.add(prop);
		prop.updated = true;
		prop.name = aName;
		prop.id = aPropID;
		prop.container = box;

		var content:Absolute = new Absolute();
		box.addComponent(content);

		var text:TextField = new TextField();
		text.style.fontSize = 15;
		// text.style.fontBold = true;
		text.text = aName;

		// text.x = 40;
		// text.y = 5;

		var closeButton:Button = new Button();
		closeButton.text = "v";
		closeButton.toggle = true;
		closeButton.width = 10;
		closeButton.height = 10;
		closeButton.onClick = function(event:UIEvent) {
			if (!closeButton.selected) {
				box.height = 30;
				content.hide();
				closeButton.text = ">";
			} else {
				box.height = box.userData;
				content.show();
				closeButton.text = "v";
			}
		}
		box.addComponent(closeButton);
		box.addComponent(text);

		var increments:Int = 35;
		var counter:Int = 1;
		for (item in items) {
			var parts:Array<String> = item.split(",");
			var name:TextArea = new TextArea();
			name.text = parts[0];

			name.style.fontSize = 15;
			name.style.fontBold = true;
			var component:Component = Tools.generateTextInput(parts[1], parts[2], onMouseDown, onEnterPress);

			// name.y = increments * counter+5;
			// name.x = 10;
			// component.y = increments * counter;
			// component.x = name.width+30;
			content.addComponent(name);
			content.addComponent(component);
			component.userData = prop.addVariable(name.text, counter - 1, component);
			++counter;
		}
		box.userData = box.height = counter * increments;
		return box;
	}

	var mouseInitialX:Float;
	var mouseDrag:Bool;
	var activeField:TextArea;
	var incrementsRate:Float = 0.001;

	function onMouseDown(text:TextArea) {
		mouseDrag = true;
		mouseInitialX = 0;
		activeField = text;
	}

	function onEnterPress(text:TextArea) {
		// Lib.current.stage.focus = null;
		var attribute:Variable = cast text.userData;
		text.userData.selected = false;
		updateValue(attribute.propId, attribute.id, text.text);
	}

	function changeEntity(entity:Entity) {
		logic.changeEntity(entity);
	}

	function updateValue(propId:Int, id:Int, text:String) {
		logic.updateValue(propId, id, text);
	}

	public function updateEntities(newEntities:Array<Entity>):Void {
		for (entity in entites) {
			entity.found = false;
		}
		var found:Bool;
		for (newEntity in newEntities) {
			found = false;
			for (entity in entites) {
				if (entity.id == newEntity.id) {
					entity.found = true;
					found = true;
					break;
				}
			}
			if (!found) // new entity
			{
				newEntity.found = true;
				entites.push(newEntity);
			}
		}
		var toRemove:Array<Entity> = new Array();
		for (entity in entites) {
			if (!entity.found) {
				toRemove.push(entity);
			}
		}
		for (entity in toRemove) {
			entites.remove(entity);
		}
		var counter:Int = 0;
		for (entity in entites) {
			var button:Button;
			if (entitesButtons.length <= counter) {
				button = new Button();
				button.onClick = function(event:UIEvent) {
					changeEntity(cast event.target.userData);
				}
				entitesButtons.push(button);
				entitesButtonContainer.addComponent(button);
			} else {
				button = entitesButtons[counter];
				button.show();
			}
			button.text = entity.text + "";
			button.userData = entity;
			++counter;
		}
		for (i in counter...entitesButtons.length) {
			entitesButtons[i].hide();
		}
	}

	var splitter:HBox;

	public function updateProperties(aId:String, proptiesRaw:Array<String>):Void {
		proptiesRaw.pop(); // last one is empty
		if (currentEntity.id != aId) {
			currentEntity.reset();
			currentEntity.id = aId;
			propertiesContainer.removeAllComponents();

			for (prop in proptiesRaw) {
				var parts:Array<String> = prop.split("?");
				parts.pop(); // last one is empty
				var name:String = parts.shift();
				var propId:Int = Std.parseInt(parts.shift());
				propertiesContainer.addComponent(createComponent(name, propId, parts));
			}
		} else {
			for (prop in proptiesRaw) {
				var variables:Array<String> = prop.split("?");
				variables.pop(); // last one is empty
				var name:String = variables.shift();
				var propId:Int = Std.parseInt(variables.shift());
				var prop = currentEntity.getPropertyBy(propId);
				if (prop != null) {
					prop.updated = true;
					for (variableRaw in variables) {
						var parts:Array<String> = variableRaw.split(",");
						var text:TextArea = cast prop.get(parts[0]);
						if (!text.userData.selected) {
							text.text = parts[2];
						}
					}
				} else {
					propertiesContainer.addComponent(createComponent(name, propId, variables));
				}
			}
			currentEntity.deleteUnUpdatedProperties();
		}
	}

	public function update():Void {
		if (mouseDrag) {
			// activeField.text = Std.parseFloat(activeField.text) + (Lib.current.mouseX - mouseInitialX ) * incrementsRate+"";

			var attribute:Variable = cast activeField.userData;
			updateValue(attribute.propId, attribute.id, activeField.text);
		}
	}

	public function updateMeta(id:String, parts:Array<String>) {
		if (currentEntity.id == id) {
			var counter:Int = 0;

			for (part in parts) {
				if (part != "") {
					currentEntity.getPropertyAt(counter).metadata = part;
					var buttonShow:Button = new Button();
					buttonShow.onClick = showMetadata;
					buttonShow.text = "showRec";

					// buttonShow.x = 200;
					buttonShow.userData = currentEntity.getPropertyAt(counter);
					buttonShow.toggle = true;
					currentEntity.getPropertyAt(counter).container.addComponent(buttonShow);
				}
				++counter;
			}
		}
	}

	public function showMetadata(event:UIEvent) {
		var prop:Property = cast(event.target, Button).userData;
		logic.activateMetaData(MessageEncoder.encodeShowMetadata(prop, currentEntity));
	}
}
