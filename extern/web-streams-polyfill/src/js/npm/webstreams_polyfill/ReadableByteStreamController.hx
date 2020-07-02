package js.npm.webstreams_polyfill;

import js.lib.ArrayBufferView;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "ReadableByteStreamController")
#else
@:native("ReadableByteStreamController")
#end
extern class ReadableByteStreamController {
    final byobRequest:Null<ReadableStreamBYOBRequest>;
    final desiredSize:Null<Int>;

    function close():Void;

    function enqueue(chunk:ArrayBufferView):Void;

    function error(e:Dynamic):Void;
}