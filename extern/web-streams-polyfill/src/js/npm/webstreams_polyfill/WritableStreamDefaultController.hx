package js.npm.webstreams_polyfill;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "WritableStreamDefaultController")
#else
@:native("WritableStreamDefaultController")
#end
extern class WritableStreamDefaultController<T> {
    function error(e:Dynamic):Void;
}