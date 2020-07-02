package js.npm.webstreams_polyfill;

import js.lib.Promise;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "ReadableStreamDefaultReader")
#else
@:native("ReadableStreamDefaultReader")
#end
extern class ReadableStreamDefaultReader<T> {
    final closed:Promise<Void>;

    function new(stream:ReadableStream<T>):Void;

    function cancel(reason:Dynamic):Promise<Void>;

    function read():Promise<ReadResult<T>>;

    function releaseLock():Void;
}