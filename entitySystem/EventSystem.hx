package entitySystem;

/**
 * ...
 * @author Joaquin
 */
class EventSystem 
{
	private var mEvents:Map<String,Array<IListener>>;
	public function new() 
	{
		mEvents = new Map();
	}
	public function subscribe(event:String, system:IListener):Void
	{
		var list:Array<IListener> = mEvents.get(event);
		if (list == null)
		{
			list = new Array();
			mEvents.set(event,list);
		}
		list.push(system);
	}
	public function remove(event:String, system:IListener):Void
	{
		var list:Array<IListener> = mEvents.get(event);
		list.splice(list.indexOf(system), 1);
	}
	public function dispach( message:Message, broadcast:Bool = false):MessageResult
	{
		
		var list:Array<IListener> = mEvents.get(message.event);
		if (list == null)
		{
			return MessageResult.NONE;
		}
		var length:Int = list.length;
		var sys:IListener;
		var result:MessageResult;
		var returnSucces:Bool = false;
		for ( i in 0...length) 
		{
			sys=list[i];
			if (broadcast||message.to.listening(sys.id()))
			{
				result = list[i].handleEvent(message, broadcast);
				if ( result== MessageResult.ABORT)
				{
					return MessageResult.ABORT;
				}
				if (result == MessageResult.SUCCESS)
				{
					returnSucces = true;
				}
			}
		}
		if (returnSucces)
		{
			return MessageResult.SUCCESS;
		}
		return MessageResult.NONE;
	}
}
