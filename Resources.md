# Documentation #

Each RPC type is based on a AbstractRPCObject which mimics the native [http://livedocs.macromedia.com/flex/2/langref/](RemoteObject.md). Since the implementation is the same for the different RPC types (AMF0,XML-RPC and JSON-RPC), AbstractObject will be used to generalize them in the examples. Simply replace `<ak33m:AbstractObject>` with the appropriate tags:


| **RPC Type** | **Package** | **AS Class** | **MXML Tag** |
|:-------------|:------------|:-------------|:-------------|
| AMF0 (Flash Remoting) | `com.ak33m.rpc.amf0.*` | `AMF0Object` | `<ak33m:AMF0Object>` |
| XML-RPC      | `com.ak33m.rpc.xmlrpc.*` | `XMLRPCObject` | `<ak33m:XMLRPCObject>` |
|JSON-RPC      | `com.ak33m.rpc.jsonrpc.*` | `JSONRPCObject`| `<ak33m:JSONRPCObject>` |


General Example:
```
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" xmlns:ak33m="http://ak33m.com/mxml" creationComplete="callFunction();">
    <mx:Script>
       <![CDATA[
         import mx.controls.Alert;
         function callFunction ()
         {
           //sample method call using token pattern
           someapi.doSomeThing(param1,param2);
          //sample method call if method has a dot (.) (as is the case with blog xmlrpc API
          someapi.call("method.with.dot",param1,param2);
         }
      ]]>
   </mx:Script>
    <ak33m:AbstractObject id="someapi" endpoint="http://ak33m.com" destination="someendpoint" fault="Alert.show(event.fault.faultString,event.fault.faultCode)">
    </ak33m:AbstractObject>
</mx:Application>
```

Below is an example using the xmlrpc api of a blog. It uses the token pattern and the ItemResponder.


<sub>NB Any class that implements IResponder can be used. ItemResponder is the only responder natively available in Flex 2&copy; and hence utilized in this example</sub>
```
<?xml version="1.0" encoding="utf-8"?>
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" xmlns:ak33m="http://ak33m.com/mxml" creationComplete="">
	<mx:Script>
		<![CDATA[
			import mx.rpc.events.ResultEvent;
			import mx.rpc.events.FaultEvent;
			import mx.rpc.AsyncToken;
			import mx.controls.Alert;
			import mx.collections.ItemResponder;
			var urlregexp:String = "^[A-Za-z]+://[A-Za-z0-9-_]+\\.[A-Za-z0-9-_%&\?\/.=]+$";
			var endpointregexp:String = "/[A-Za-z0-9-_%&\?\/.=]";
			function login ()
			{
				//This is the rpc call. Because the xmlrpc service used in this example has functions with dots (.) in them the call function is used
				//if there was no dot the call could be blogapi.getUserInfo ()
				var token:AsyncToken = blogapi.call("blogger.getUserInfo","",user_txt.text,password_txt.text);
				var tresponder:ItemResponder = new ItemResponder(this.showUserInfo,this.onFault);
				
				token.addResponder(tresponder);
			}
			
			function showUserInfo (event:ResultEvent,token = null)
			{
				Alert.show("User: "+event.result.nickname,"User info result");
			}
			
			function onFault (event:FaultEvent, token=null)
			{
				Alert.show(event.fault.faultString,event.fault.faultCode);
			}
		]]>
	</mx:Script>
	<!-- Validation -->
	  <mx:RegExpValidator id="regExpV" 
        source="{rooturl_txt}" property="text" 
        flags="g" expression="{urlregexp}" noMatchError="Please enter a valid URL"
      />
     <mx:RegExpValidator id="endpointregExpV" 
        source="{this.endpoint_txt}" property="text" 
        flags="g" expression="{endpointregexp}" noMatchError="Please enter a valid endpoint. It MUST start with a /"
      />
     <!-- User Interface -->
	<mx:Panel height="300" width="380">
		<mx:Form height="200" width="350" x="0" y="0">
			<mx:FormHeading label="Blog Login" textAlign="left"/>
			<mx:FormItem label="Root URL">
				<mx:TextInput id="rooturl_txt"/>
			</mx:FormItem>
			<mx:FormItem label="Xmlrpc endpoint">
				<mx:TextInput id="endpoint_txt"/>
			</mx:FormItem>
			<mx:FormItem label="Username">
				<mx:TextInput id="user_txt"/>
			</mx:FormItem>
			<mx:FormItem label="Password">
				<mx:TextInput id="password_txt"/>
			</mx:FormItem>
			<mx:FormItem>
				<mx:Button label="Send" id="send_btn" click="login();"/>
			</mx:FormItem>
		</mx:Form>
	</mx:Panel>
	<!-- RPC Object -->
	<ak33m:XMLRPCObject id="blogapi" endpoint="{rooturl_txt.text}" destination="{endpoint_txt.text}" >
		
	</ak33m:XMLRPCObject>
</mx:Application>
```

# External Links #

**Specifications**
  * [XML-RPC](http://www.xmlrpc.com/spec)
  * [JSON-RPC](http://json-rpc.org/wiki/specification)












