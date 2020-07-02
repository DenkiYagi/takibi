package js.npm.webstreams_polyfill;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "TransformStreamDefaultController")
#else
@:native("TransformStreamDefaultController")
#end
extern class TransformStreamDefaultController<T> {
    final desiredSize:Null<Int>;

    function enqueue(chunk:T):Void;

    function error(reason:Dynamic):Void;

    function terminate():Void;
}