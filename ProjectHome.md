Actionscript 3 RPC Library

# Introduction #

As3 RPC lib is a set of libraries that can be used with Flex 2 or AS 3 to invoke remote procedure calls using:
  * AMF0 (Flash Remoting MX)
  * XML-RPC
  * JSON-RPC (Coming Soon)

Usage mimics the RemoteObject which is available natively in [Flex 2](http://livedocs.macromedia.com/flex/2/langref/) in an effort to make usage in existing frameworks (e.g. Cairngorm) and design pattern (e.g. Token pattern) easy as possible.

## Update 2013 ##
Unfortunately I've not been able to actively update the library in sometime. However the project is now available via github at https://github.com/Webysther/as3rpclib thanks to Websyther.

# Updates 4/16/2008 #

  * Fixed date format
  * Change content-type header to text/xml
  * Fixed binary data decoding
  * Added encoding of generic objects
  * Added ability to overwrite serializer

# Updates 4/14/2007 #

  * Fixed show busy cursor
  * Fixed untyped object returning null issue

# Updates 2/25/2007 #

  * Added preliminary JSON support
  * Added manifest to swc to allow for easier namespace declaration e.g. `xmlns:ak33m='http://ak33m.com/mxml'`
  * Fixed XMLRPC missing double deserialazation