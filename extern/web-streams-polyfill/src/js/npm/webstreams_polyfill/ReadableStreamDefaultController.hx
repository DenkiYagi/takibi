package js.npm.webstreams_polyfill;

import js.lib.ArrayBufferView;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "ReadableStreamDefaultController")
#else
@:native("ReadableStreamDefaultController")
#end
extern class ReadableStreamDefaultController<T> {
    final desiredSize:Null<Int>;

    function close():Void;

    function enqueue(chunk:T):Void;

    function error(e:Dynamic):Void;
}