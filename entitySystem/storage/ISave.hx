package entitySystem.storage;

/**
 * @author Joaquin
 */
interface ISave 
{
	function save(aData:SaveData):Void;
	function load():SaveData;
	function canLoad():Bool;
}