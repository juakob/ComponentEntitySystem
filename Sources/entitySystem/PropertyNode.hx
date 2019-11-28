package entitySystem;

/**
 * ...
 * @author Joaquin
 */
class PropertyNode {
	public var nextNode:PropertyNode;
	public var NodeVersion:Int = 0;
	public var owner:Entity;

	public function new() {}
}
