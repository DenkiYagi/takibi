package js.npm.webstreams_polyfill;

import js.lib.Promise;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "WritableStreamDefaultWriter")
#else
@:native("WritableStreamDefaultWriter")
#end
extern class WritableStreamDefaultWriter<T> {
    final closed:Promise<Void>;

    final desiredSize:Null<Int>;

    final ready:Promise<Void>;

    function new(stream:WritableStream<T>):Void;

    function abort(reason:Dynamic):Promise<Void>;

    function close():Promise<Void>;

    function releaseLock():Void;

    function write(chunk:T):Promise<Void>;
}