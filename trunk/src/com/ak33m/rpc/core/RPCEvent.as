package com.ak33m.rpc.core
{
	import flash.events.Event;
	/** 
	 * This event is dispatcher from a RPCResponder. 
	 */
	public class RPCEvent extends Event
	{
		public static const EVENT_RESULT:String = "onRPCResult";
		public static const EVENT_FAULT:String = "onRPCFault";
		public static const EVENT_CANCEL:String = "onRPCCancel";
		public var data:*;
		public function RPCEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,data=null)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
	}
}