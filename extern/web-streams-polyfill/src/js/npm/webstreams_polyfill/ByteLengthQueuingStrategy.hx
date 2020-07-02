package js.npm.webstreams_polyfill;

import js.lib.ArrayBufferView;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "ByteLengthQueuingStrategy")
#else
@:native("ByteLengthQueuingStrategy")
#end
extern class ByteLengthQueuingStrategy {
    function new(init:{highWaterMark:Int}):Void;

    function size(chunk:ArrayBufferView):Int;
}