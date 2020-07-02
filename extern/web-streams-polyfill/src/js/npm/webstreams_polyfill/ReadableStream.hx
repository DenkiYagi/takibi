package js.npm.webstreams_polyfill;

import js.lib.ArrayBufferView;
import js.lib.Promise;
import haxe.extern.EitherType;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "ReadableStream")
#else
@:native("ReadableStream")
#end
extern class ReadableStream<T> {
    final locked:Bool;

    // @:overload(function (underlyingSource:UnderlyingByteSource, ?queuingStrategy:{?highWaterMark:Int, ?size:Dynamic}):Void {})
    function new(underlyingSource:EitherType<UnderlyingSource<T>, UnderlyingByteSource>, ?queuingStrategy:QueuingStrategy<T>):Void;

    function cancel(reason:String):Promise<Void>;

    @:overload(function(mode:{mode:ReadableStreamReaderByobMode}):ReadableStreamBYOBReader {})
    function getReader():ReadableStreamDefaultReader<T>;

    function pipeThrough<U>(transformStream:TransformStream<T, U>, ?options:PipeOptions):ReadableStream<U>;

    function pipeTo(destination:WritableStream<T>, ?options:PipeOptions):Promise<Void>;

    function tee():Array<ReadableStream<T>>;
}

typedef UnderlyingSource<T> = {
    var ?start:(controller:ReadableStreamDefaultController<T>) -> Void;
    var ?pull:(controller:ReadableStreamDefaultController<T>) -> Void;
    var ?cancel:EitherType<(reason:Dynamic)->Void, (reason:Dynamic)->Promise<Void>>;
};

typedef UnderlyingByteSource = {
    var ?start:(controller:ReadableByteStreamController) -> Void;
    var ?pull:(controller:ReadableByteStreamController) -> Void;
    var ?cancel:EitherType<(reason:Dynamic)->Void, (reason:Dynamic)->Promise<Void>>;
    var type:UnderlyingByteSourceType;
    var ?autoAllocateChunkSize:Int;
}

enum abstract UnderlyingByteSourceType(String) {
    var Bytes = "bytes";
}

enum abstract ReadableStreamReaderByobMode(String) {
    var Byob = "byob";
}

typedef PipeOptions = {
    var ?preventClose:Bool;
    var ?preventAbort:Bool;
    var ?preventCancel:Bool;
    var ?signal:{};
}
