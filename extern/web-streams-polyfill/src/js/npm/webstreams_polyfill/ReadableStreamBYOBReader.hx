package js.npm.webstreams_polyfill;

import js.lib.ArrayBufferView;
import js.lib.Promise;
import js.lib.Uint8Array;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "ReadableStreamBYOBReader")
#else
@:native("ReadableStreamBYOBReader")
#end
extern class ReadableStreamBYOBReader {
    final closed:Promise<Void>;

    function new(stream:ReadableStream<Uint8Array>):Void;

    function cancel(reason:Dynamic):Promise<Void>;

    function read<T:ArrayBufferView>(view:T):Promise<ReadResult<T>>;

    function releaseLock():Void;
}
