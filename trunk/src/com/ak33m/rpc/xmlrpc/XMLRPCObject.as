package com.ak33m.rpc.xmlrpc
{
	import mx.rpc.AsyncToken;
	import com.ak33m.rpc.core.*;
	import mx.rpc.AsyncToken;
	import mx.managers.CursorManager;
	import mx.messaging.messages.IMessage;
	import mx.messaging.messages.RemotingMessage;
	import mx.rpc.events.*;
	import mx.rpc.Fault;
	import mx.messaging.messages.HTTPRequestMessage;
	dynamic public class XMLRPCObject extends AbstractRPCObject implements IRPCObject
	{
		protected var _gateway:XMLRPCConnection;
		public function XMLRPCObject (endpoint:String = null)
		{
			super();
			this.endpoint = endpoint;
		}
		
		override public function set endpoint (endpoint:String):void
		{
			this._endpoint = endpoint;
			this.makeConnection();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function makeCall(method:String, args:Array):AsyncToken
		{
			this._gateway.url = this.endpoint+this.destination;
			this._gateway.request = "POST";
			this._gateway.contentType = "application/xml";
			this._gateway.resultFormat = "object"; //Must be set to object in order for the xmlDecode to be used
			this._gateway.xmlDecode = XMLRPCSerializer.deserialize; //Converts results to AS3 objects
			this._gateway.requestTimeout = this.requestTimeout;
			var ttoken:AsyncToken = this._gateway.send(XMLRPCSerializer.serialize(method,args));
			
			//====== THIS IS A HACK IMPLEMENTED TO THROW FAULT EVENTS FROM THE XML RPC CALL
			//@TODO think of better solution to this problem
			var rpctoken:AsyncToken = new AsyncToken(ttoken.message);//create "fake" token with the real token message
			var responder:RPCResponder = new RPCResponder (rpctoken); //Create a responder
			responder.timeout = this.requestTimeout;
			responder.addEventListener(RPCEvent.EVENT_RESULT,this.onResult);
            responder.addEventListener(RPCEvent.EVENT_FAULT,this.onFault);
            responder.addEventListener(RPCEvent.EVENT_CANCEL,this.onRemoveResponder);
            ttoken.addResponder(responder);
            return rpctoken;
		}
		
		override protected function onResult (evt:RPCEvent):void
		{
			var token:AsyncToken = evt.target.token;
			var resultevent:ResultEvent = ResultEvent(evt.data); //@NOTE because the RPCResponder is a responder to HTTPService the result data will be a result event
			token.message.body = resultevent.result; //The actual data would be in the result
			if (resultevent.result is Fault)//The XMLRPCSerializer.deserialize will return a fault object if a fault is returned by the rpc call
			{
				var faultevent:FaultEvent= new FaultEvent(FaultEvent.FAULT,true,true,resultevent.result as Fault,token);
				dispatchEvent(faultevent);
				if (token.hasResponder())
				{
					for (var i:int; i<token.responders.length; i++)
					{
						token.responders[i].fault.call(token.responders[i],faultevent);
					}
				}
			}
			else
			{
				dispatchEvent(resultevent);
				if (token.hasResponder())
				{
					for (var i:int; i<token.responders.length; i++)
					{
						token.responders[i].result.call(token.responders[i],resultevent);
					}
				}
			}
		}
		
		override protected function onFault (evt:RPCEvent):void
		{
			var token:AsyncToken = evt.target.token;
			var faultevent:FaultEvent= FaultEvent(evt.data);
			dispatchEvent(faultevent);
			if (token.hasResponder())
			{
				for (var i:int; i<token.responders.length; i++)
				{
					token.responders[i].fault.call(token.responders[i],faultevent);
				}
			}
		}
		
		 public function makeConnection ():void
        {
        	this._gateway = new XMLRPCConnection(this._endpoint);
        }
		
	}
}