package com.ak33m.rpc.amf0
{
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import com.ak33m.rpc.core.IRPCConnection;
	
	public class AMF0Connection extends NetConnection implements IRPCConnection
	{
		public function AMF0Connection (url : String)
        {
            objectEncoding = ObjectEncoding.AMF0;
            if (url)
            connect(url);
        }
	}
}