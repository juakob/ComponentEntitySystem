package panel;
import haxe.ui.containers.Absolute;
import haxe.ui.containers.Box;
//import haxe.ui.containers.HSplitter;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.VBox;
import haxe.ui.components.Button;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.core.Component;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.core.UIEvent;
import helpers.Tools;
import logicDomain.ConstantClass;
import logicDomain.Entity;

/**
 * ...
 * @author Joaquin
 */
class ConstantsInspector
{
	var constantsContainer:VBox;
	public var logic:Logic;
	var constants:Array<ConstantClass>;
	var constantsButtons:Array<Button>;
	var constantsButtonContainer:VBox;
	public function new() 
	{
		constantsButtons = new Array();
		constants = new Array();
		
	}
	public function createWindow():Component
	{
		splitter = new VBox();
			splitter.includeInLayout = true;
			splitter.disabled = false;
			constantsButtonContainer = new VBox();
			
			var boxL:VBox = new VBox();
			var boxR:Box = new Box();
			var scrollView:ScrollView = new ScrollView();
			//scrollView.showVScroll = true;
			constantsContainer = new VBox();
			
			scrollView.addComponent(constantsContainer);
			boxR.addComponent(scrollView);
		
			scrollView.percentWidth = 100;
			scrollView.percentHeight = 100;
			
			boxL.percentWidth = 30;
			boxL.percentHeight = 100;
			//boxL.style.padding = 5;
		//boxL.minWidth = 120;
	
			

			boxR.percentWidth = 70;
			boxR.percentHeight = 100;
			//boxR.style.padding = 10;
			
			
			splitter.percentHeight = 100;
			splitter.percentWidth = 100;
			
			var list = new ScrollView();
			
			list.addComponent(constantsButtonContainer);
			list.percentWidth = 100;
			list.percentHeight = 100;
			boxL.addComponent(list);
			

			splitter.addComponent(boxL);
			splitter.addComponent(boxR);
			
			//Lib.current.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, function(aEvent:MouseEvent) { mouseDrag = false; activeField = null; } );
			
			return splitter;
	}
	
	function createComponent(aConstantClass:ConstantClass):Absolute
	{
		
		var box:Absolute = new Absolute();
		box.percentWidth = 100;

		//box.clipContent = true;
		var content:Absolute = new Absolute();
		box.addComponent(content);
		
		var text:TextArea = new TextArea();
	//	text.style.color = 0xFFFFFF;
		text.style.fontSize = 15;
		text.style.fontBold = true;
		text.text = aConstantClass.name;
		
		//text.y = 5;
		//text.x = 40;
		
		var closeButton:Button = new Button();
		closeButton.text = "v";
		closeButton.toggle = true;
		closeButton.width = 10;
		closeButton.height = 10;
		closeButton.onClick = function(event:UIEvent)
		{
			if (!closeButton.selected)
			{
				box.height = 30;
				content.invalidateDisplay();
				closeButton.text = ">";
			}else {
				box.height = box.userData;	
				content.invalidateDisplay;
				closeButton.text = "v";
			}
		}
		box.addComponent(closeButton);
		box.addComponent(text);
		
		var increments:Int = 35;
		var counter:Int=1;
		for (constant in aConstantClass.constants) 
		{
			
			var name:TextArea = new TextArea();
			name.text = constant.name;
			
		//	name.style.color = 0xFFFFFF;
			name.style.fontSize = 15;
			name.style.fontBold = true;
			var component:Component = generate(constant.type, constant.value);
			
			//name.y = increments * counter+5;
			//name.x = 10;
			//component.y = increments * counter;
			//component.x = name.width+30;
			content.addComponent(name);
			content.addComponent(component);
			component.userData=constant;
			++counter;
		}
		box.userData=box.height = counter * increments ;
		return box;
	}
	var mouseInitialX:Float;
	var mouseDrag:Bool;
	var activeField:TextArea;
	var incrementsRate:Float = 0.001;
	function generate(type:String,value:String) :Component
	{
		switch(type)
		{
			
			case "i":
				var text:TextArea = new TextArea();
				text.userData = "i";
				text.onChange = function(event:UIEvent) {
				event.target;
				//event.cancelable;
			
				}
				text.text = value;
				return text;
			case "f":
				var text:TextArea = new TextArea();
				text.userData = "f";
				text.text = value;
				//text.addEventListener(FocusEvent.FOCUS_IN,function (aEvent:FocusEvent)
				//{
					//trace("enter");
					//text.style.backgroundColor = 0xBBD9BC;
					//text.userData.selected = true;
					//
					//
				//});
				//text.addEventListener(FocusEvent.FOCUS_OUT,function (aEvent:FocusEvent)
				//{
					//trace("leave");
					//text.style.backgroundColor = 0xFFFFFF;
					//text.userData.selected = false;
				//
				//});
				//text.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, function (event:MouseEvent)
				//{
					//mouseDrag = true;
					//mouseInitialX = Lib.current.mouseX;
					//activeField = text;
				//});
				//text.addEventListener(KeyboardEvent.KEY_DOWN, function (event:KeyboardEvent){
//
					   //// if the key is ENTER
					   //if(event.charCode == 13){
//
						   //// your code here
						 //Lib.current.stage.focus = null;
						//var attribute:Constant = cast text.userData;
						//text.userData.selected = false;
						//logic.updateConstant(attribute.parent, attribute.name, text.text);
					   //}
					//}
				//);
				
				
				return text;
			default:
				var text:TextArea = new TextArea();
				text.userData = "s";
				text.text = value;
				return text;
		}
	}
	public function updateConstantsClass(newConstants:Array<ConstantClass>):Void
	{
		constants = newConstants;
		constantsButtonContainer.removeAllComponents();
		for (constant in constants) 
		{
			var button:Button= new Button();
			button.onClick = function (event:UIEvent)
			{
				displayConstant(button.userData);
			}
			
			constantsButtons.push(button);
			constantsButtonContainer.addComponent(button);
			
			button.text = constant.name+"";
			button.userData = constant;
		}
		
	}
	var currententityId:String ="";
	var splitter:VBox;
	 function displayConstant(aConstant:ConstantClass):Void
	{

		currententityId = aConstant.name;
		
		constantsContainer.removeAllComponents();
		
		
		constantsContainer.addComponent(createComponent(aConstant));
		
	}
	public function update():Void
	{
		if (mouseDrag)
		{
			//activeField.text = Std.parseFloat(activeField.text) + (Lib.current.mouseX - mouseInitialX ) * incrementsRate+"";
			
			var attribute:Constant = cast activeField.userData;
			//logic.updateValue(attribute.propId, attribute.id, activeField.text);
		}
	}
	
}