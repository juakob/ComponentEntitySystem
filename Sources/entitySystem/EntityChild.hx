package entitySystem;

import entitySystem.Property;

/**
 * ...
 * @author Joaquin
 */
class EntityChild extends Entity {

	public function new(aParent:Entity) {
		super();
		aParent.addChild(this);
	}

	override public function get(aId:Int):Property {
		var prop:Property = mProperties.get(aId);
		if (prop != null) {
			return prop;
		}
		return parent.get(aId);
	}
}
