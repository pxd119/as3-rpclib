package com.ak33m.rpc.xmlrpc
{
	import com.ak33m.rpc.core.IRPCConnection;
	import flash.net.Responder;
	import mx.rpc.http.HTTPService;

	public class XMLRPCConnection extends HTTPService  implements IRPCConnection
	{	
		public function XMLRPCConnection (rootURL)
		{
			super(rootURL);
		}
		
		public function call(command:String,responder:Responder,...args):void
		{
			var trequestxml:XML = XMLRPCSerializer.serialize(command,args);
			send(trequestxml);
		}
	}
}