package inspector.io;
#if cpp
import sys.FileSystem;
#end
/**
 * ...
 * @author Joaquin
 */
class RWData
{

	public static inline function  createFile(name:String, data:String) 
	{
		#if cpp
		if (!FileSystem.exists("./ZS"))
		{
			FileSystem.createDirectory("./ZS");
		}
		sys.io.File.saveContent("./ZS/" + name + ".txt", data);
		#end
	}
	public static inline function  exist(name:String):Bool
	{
		#if cpp
		return FileSystem.exists("./ZS/" + name+".txt");
		#else
		return false;
		#end
	}
	
	public static inline function  read(name:String):String
	{
		#if cpp
		return sys.io.File.getContent("./ZS/" + name+".txt");
		#else
		return "";
		#end
	}
	
}