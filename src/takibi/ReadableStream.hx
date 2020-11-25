package takibi;

import js.lib.Object;
import js.lib.Uint8Array;
import js.lib.Promise;
import js.npm.webstreams_polyfill.ReadableStream in WebReadableStream;
import haxe.extern.EitherType;
import js.Lib.undefined;

@:keep
class ReadableStream {
    @:allow(takibi)
    final _raw:WebReadableStream<Uint8Array> = undefined;

    /**
        A Boolean value that indicates if the readable stream is locked to a reader.
    **/
    public final locked:Bool = undefined;

    @:allow(takibi)
    function new(raw:WebReadableStream<Uint8Array>) {
        Object.defineProperty(this, "_raw", {value: raw, enumerable: false});
        Object.defineProperty(this, "locked", {get: () -> raw.locked});
    }

    public function cancel(reason:String):Promise<Void> {
        return _raw.cancel(reason);
    }

    /**
        Gets an instance of `ReadableStreamDefaultReader` and locks the `ReadableStream` to that reader instance.
        This method accepts an object argument indicating options. We only support one mode,
        which can be set to byob to create a `ReadableStreamBYOBReader`.
    **/
    public function getReader(?mode:{mode:String}):EitherType<ReadableStreamDefaultReader, ReadableStreamBYOBReader> {
        return _raw.getReader(cast mode);
    }

    public function pipeThrough(transformStream:TransformStream, ?options:PipeOptions):ReadableStream {
        return new ReadableStream(_raw.pipeThrough(transformStream._raw, options));
    }

    /**
        Pipes the readable stream to a given writable stream `destination` and returns a promise
        that is fulfilled when the write operation succeeds or rejects it if the operation fails.
    **/
    public function pipeTo(destination:WritableStream, ?options:PipeOptions):Promise<Void> {
        return _raw.pipeTo(destination._raw, options);
    }

    public function tee():Array<ReadableStream> {
        return _raw.tee().map(x -> new ReadableStream(x));
    }
}

typedef ReadableStreamDefaultReader = js.npm.webstreams_polyfill.ReadableStreamDefaultReader<Uint8Array>;
typedef ReadableStreamBYOBReader = js.npm.webstreams_polyfill.ReadableStreamBYOBReader;
typedef PipeOptions = js.npm.webstreams_polyfill.ReadableStream.PipeOptions;
