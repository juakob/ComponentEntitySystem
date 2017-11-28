package inspector.logicDomain;

/**
 * ...
 * @author Joaquin
 */
class MapToRecAttributeId
{

	public static  function mapToRecAttributeId(atributeName:String):Int
	{
		switch(atributeName)
		{
			case "x": return 0;
			case "y":return 1;
			case "width":return 2;
			case "height":return 3;
			case "offsetX":return 4;
			case "offsetY":return 5;
			case "scaleX":return 6;
			case "scaleY":return 7;
		}
		throw atributeName+ "not found";
	}
	
}