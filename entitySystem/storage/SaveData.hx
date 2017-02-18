package entitySystem.storage;

/**
 * ...
 * @author Joaquin
 */
class SaveData
{
	public var userData:Dynamic;
	public var factoriesNames:Array<String>;
	public var factoriesData:Array<String>;
	public function new() 
	{
		factoriesNames = new Array();
		factoriesData = new Array();
	}
	public function saveFactory(aName:String,aData:String)
	{
		var counter:Int = 0;
		for (name in factoriesNames)
		{
			if (name == aName)
			{
				factoriesData[counter] = aData;
				return;
			}
			++counter;
		}
		factoriesNames.push(aName);
		factoriesNames.push(aData);
	}
	public function getData(aName:String):String
	{
		var counter:Int = 0;
		for (name in factoriesNames)
		{
			if (name == aName)
			{
				return factoriesData[counter];
			}
			++counter;
		}
		return null;
	}
}