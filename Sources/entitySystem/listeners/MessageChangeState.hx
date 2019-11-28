package entitySystem.listeners;

import entitySystem.Entity;
import entitySystem.Message;

/**
 * ...
 * @author Joaquin
 */
class MessageChangeState extends Message {
	public function new(aSlot:String, aState:String, aBroadcast:Bool = false, aDelay:Float = 0) {
		super("changeState", null, null, [aSlot, aState], aBroadcast, aDelay);
	}
}
