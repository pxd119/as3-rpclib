package com.ak33m.rpc.core
{
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.utils.*;
	import mx.rpc.*;
	import mx.managers.CursorManager;
	import mx.collections.ArrayCollection;
	import mx.rpc.mxml.IMXMLSupport;
	import mx.rpc.events.*;
	import com.ak33m.rpc.core.*;
	import com.ak33m.rpc.amf0.*;
	import mx.messaging.messages.IMessage;
	import mx.messaging.messages.RemotingMessage;
	import flash.events.Event;
	use namespace flash_proxy;
	
	//EVENTS
	[Event (name="result", type="ResultEvent")]
	[Event (name="fault", type="FaultEvent")]
	[Event (name="invoke", type="InvokeEvent")]
	
	[Bindable]
	
	/**
	 * @author Akeem Philbert <akeemphilbert@gmail.com>
	 * @author Carlos Rovira <carlos.rovira@gmail.com>
	 * The AMF0RemoteObject lets you invoke commands on a  RPC Server that uses the AMF0 format (e.g. Flash Remoting MX, AMFPHP 1.0).
	 * It mimics the built in RemoteObject and can be accessed from both MXML and actionscript 3.0 
	 */
	dynamic public class AbstractRPCObject extends AbstractService implements IMXMLSupport
	{
		public static const MULTIPLE : String = "multiple";
        public static const SINGLE : String = "single";
        public static const LAST : String = "last";
        
        //private var _gateway:IRPCConnection = null;
        protected var _isbusy:Boolean = false;
        protected var _appservername:String;
        [ArrayElementType("Responder")]
        protected var _responders:ArrayCollection;
        protected var _requestTimeout:Number = 0;
        protected var _showBusyCursor:Boolean = false;
        protected var _destination:String;
        protected var _concurrency:String = "multiple";
        protected var _endpoint:String;
        public var call:Function;
        function AbstractRPCObject ()
        {
        	super();
        	this._responders = new ArrayCollection();
        	this.call = this.callProperty;
        }
        
        //GETTERS AND SETTERS
		protected final function getAccess():AbstractRestriction
		{
			return new AbstractRestriction();
		}
        /**
        *@inheritDoc
        */
        public function get showBusyCursor ():Boolean
        {
        	return this._showBusyCursor;
        }
        
        /**
        *@inheritDoc
        */
        public function set showBusyCursor (showcursor:Boolean):void
        {
        	this._showBusyCursor = showcursor;
        }
        
        /**
        * Value that indicates how to handle multiple calls to the same service.
        * 
        * <p>
        * The following values are permitted:
        * <ul>
        * 	<li><code>AMF0RemoteObject.MULTIPLE</code>. Existing requests are not cancelled, and the developer is responsible for ensuring the consistency of returned data by carefully managing the event stream. This is the default.</li>
        * 	<li><code>AMF0RemoteObject.SINGLE</code>. Only a single request at a time is allowed on the operation; multiple requests generate a fault.</li>
        * 	<li><code>AMF0RemoteObject.LAST</code>. Making a request cancels any existing request.</li>
        * </ul>
        */
        public function get concurrency ():String
        {
        	return this._concurrency;
        }
        
        
        public function set concurrency (concurrency:String):void
        {
        	this._concurrency = concurrency;
        }
        
        public function set endpoint(name:String):void
        {
        	this._endpoint = name;
        }
        
       
       public function get endpoint():String
        {
        	return _endpoint;
        }
        
       override public function set destination (destination:String):void
        {
        	this._destination = destination;
        }
        
       override public function get destination():String
       {
       		return this._destination;
       }
    
        /**
        * @inheritDoc
        */
        override public function set requestTimeout(value:int):void
        {
        	this._requestTimeout = Math.max(0,value);
        }
        
        /**
        * @inheritDoc
        */
        override public function get requestTimeout():int
        {
        	return this._requestTimeout;
        }
        
        /**
        * @private 
        */
        flash_proxy override function callProperty (method : *,... args) : *
        {
            switch (this.concurrency)
            {
                case AbstractRPCObject.SINGLE :
                if (_isbusy)
                {
                    throw new Fault(RPCMessageCodes.CONCURRENCY_SINGLE,"The method \""+method+"\" could not be executed because an existing request is being processed");
                }                    
                break;
                case AbstractRPCObject.LAST :
                if (_isbusy)
                {
                   this._responders = new ArrayCollection();
                }
                return makeCall(method,args);
                break;
                case AbstractRPCObject.MULTIPLE :
                return makeCall(method,args);
                break;
                default:
                throw new Error ('concurrency must be: single, multiple or last');
                break;
            }
        }
        
        /**
        * This is where the RPC function call implemntation should be placed. 
        */
        public function makeCall (method : String,args : Array): AsyncToken
        {
    		var tmessage:RemotingMessage = new RemotingMessage();
        	tmessage.operation = method;
        	tmessage.destination = this.destination;
        	var ttoken:AsyncToken = new AsyncToken(tmessage);
            var responder:RPCResponder = new RPCResponder (ttoken);
            responder.timeout = this.requestTimeout;
            responder.addEventListener(RPCEvent.EVENT_RESULT,this.onResult);
            responder.addEventListener(RPCEvent.EVENT_FAULT,this.onFault);
            responder.addEventListener(RPCEvent.EVENT_CANCEL,this.onRemoveResponder);
            _responders.addItem(responder);
            var params : Array = args;
            _isbusy = true;
            if (showBusyCursor)
            {
                CursorManager.setBusyCursor();
            }
            return ttoken;
        }
        
        protected function onRemoveResponder (event:Event):void
        {
        	this._responders.removeItemAt(this._responders.getItemIndex(event.target));
        }
        /**
        * RPCEvent result handler. This dispatches a result event and invokes the result function of the responders in the RPC token
        */
        protected function onResult (evt:RPCEvent):void
		{
			var token:AsyncToken = evt.target.token;
			token.message.body = evt.data;
			var resultevent:ResultEvent = new ResultEvent(ResultEvent.RESULT,true,true,evt.data,token,token.message);
			dispatchEvent(resultevent);
			if (token.hasResponder())
			{
				for (var i:int; i<token.responders.length; i++)
				{
					token.responders[i].result.call(token.responders[i],resultevent);
				}
			}
		}
		
		/**
		 * RPCEvent fault handler. This dispatchers a fault event and invokes the fault function of the responders in the RPC token
		 */
		protected function onFault (evt:RPCEvent):void
		{
			var token:AsyncToken = evt.target.token;
			token.message.body = evt.data;
			if (evt.data.faultCode && evt.data.faultString)
			var tfault:Fault = new Fault(evt.data.faultCode,evt.data.faultString,evt.data.faultDetail);
			else
			var tfault:Fault = new Fault(evt.data.code,evt.data.description,evt.data.details);
			var faultevent:FaultEvent = new FaultEvent(FaultEvent.FAULT,true,true,tfault,token,token.message);
			dispatchEvent(faultevent);
			if (token.hasResponder())
			{
				for (var i:int; i<token.responders.length; i++)
				{
					token.responders[i].fault.call(token.responders[i],faultevent);
				}
			}
		}
	}
}
internal class AbstractRestriction
{
		
}