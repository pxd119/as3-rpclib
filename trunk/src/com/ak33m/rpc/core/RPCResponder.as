/**
 * @author Akeem Philbert <akeemphilbert@gmail.com>
 * @author Carlos Rovira <carlos.rovira@gmail.com>
 * @versi
 */
package com.ak33m.rpc.core
{
	import mx.rpc.IResponder;
	import flash.net.Responder;
	import mx.rpc.AsyncToken;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.Fault;
	import flash.events.*;
	

	public class RPCResponder extends Responder implements IEventDispatcher,IResponder
	{
		protected var _token:AsyncToken;
		protected var _timeout:Number = 0;
		protected var _timer:Timer;
		protected var _dispatcher:EventDispatcher;
		
		public function RPCResponder (token:AsyncToken)
		{
			super(this.result,this.fault);
			this._dispatcher = new EventDispatcher(this);
			this._token = token;
		}
		
		public function get token ():AsyncToken
		{
			return this._token;
		}
		
		public function set timeout (value:Number) : void
        {
            _timeout = value;
            _timer = new Timer(value,1);
            if (_timeout > 0)
            {
                _timer.addEventListener(TimerEvent.TIMER_COMPLETE,cancelRequest);
                _timer.start();
            }
        }
        
        public function get timeout (): Number
        {
            return _timeout;
        }
		
		public function result (data:Object):void
		{
			this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,cancelRequest);
			dispatchEvent(new RPCEvent(RPCEvent.EVENT_RESULT,false,true,data));
		}
		
		public function fault (info:Object):void
		{
			this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,cancelRequest);
			dispatchEvent(new RPCEvent(RPCEvent.EVENT_FAULT,false,true,info));
		}
		
		private function cancelRequest (event:TimerEvent):void
		{
			if (event.target.currentCount == 1)
			{
				dispatchEvent(new RPCEvent(RPCEvent.EVENT_CANCEL,false,true));
			}
		}
		
		//EVENTDISPATCHER IMPLEMENTATION
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
       	 	this._dispatcher.addEventListener(type, listener, useCapture, priority);
   		}
           
	    public function dispatchEvent(evt:Event):Boolean
	    {
	        return this._dispatcher.dispatchEvent(evt);
	    }
    
	    public function hasEventListener(type:String):Boolean
	    {
	        return this._dispatcher.hasEventListener(type);
	    }
    
	    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
	    {
	        this._dispatcher.removeEventListener(type, listener, useCapture);
	    }
                   
	    public function willTrigger(type:String):Boolean 
	    {
	        return this._dispatcher.willTrigger(type);
	    }
	}
}