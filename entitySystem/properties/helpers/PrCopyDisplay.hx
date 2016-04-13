package entitySystem.properties.helpers;

import com.gEngine.GEngine;
import entitySystem.Property;
import myComponents.properties.PrDisplay;

/**
 * ...
 * @author Joaquin
 */

class PrCopyDisplay implements Property
{
	public var name:String;
	public var frameRate:Float=1/60;
	public var scale:Float = 1;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public function new() 
	{
		
	}
	
	public function clone():Property 
	{
		var cl:PrDisplay = new PrDisplay();
		var sprite=GEngine.i.getNewAnimation(name);
		cl.sprite = sprite;
		sprite.frameRate = frameRate;
		sprite.scaleX = cl.sprite.scaleY = scale;
		sprite.offsetX = offsetX;
		sprite.offsetY = offsetY;
		return cl;
	}
	
	/* INTERFACE entitySystem.Property */
	
	public function id():Int 
	{
		return PrDisplay.ID;
	}
	
	
	
}
