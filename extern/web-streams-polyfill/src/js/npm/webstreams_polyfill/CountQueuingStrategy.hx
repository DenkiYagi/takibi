package js.npm.webstreams_polyfill;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "CountQueuingStrategy")
#else
@:native("CountQueuingStrategy")
#end
extern class CountQueuingStrategy {
    function new(init:{highWaterMark:Int}):Void;

    function size(chunk:Dynamic):Int;
}