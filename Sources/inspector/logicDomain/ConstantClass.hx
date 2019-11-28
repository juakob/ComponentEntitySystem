package inspector.logicDomain;

/**
 * ...
 * @author Joaquin
 */
class ConstantClass {
	public var name:String;
	public var found:Bool;
	// public var container:Absolute;
	public var constants:Array<Constant>;
	public var metadata:String;

	public function new() {
		constants = new Array();
	}

	public function addVariable(aName:String, aType:String, aValue:String) {
		var constant = new Constant(aName, aType, aValue, name);
		constants.push(constant);
		return constant;
	}
}

class Constant {
	public var name:String;
	public var value:String;
	public var type:String;
	public var parent:String;
	public var selected:Bool;

	public function new(aName:String, aType:String, aValue:String, aParent:String) {
		name = aName;
		type = aType;
		value = aValue;
		parent = aParent;
	}
}
