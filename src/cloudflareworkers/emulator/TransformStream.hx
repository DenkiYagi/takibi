package cloudflareworkers.emulator;

import js.lib.Object;
import js.lib.Uint8Array;
import js.Lib.undefined;
import js.npm.webstreams_polyfill.TransformStream in WebTransformStream;

@:keep
class TransformStream {
    @:allow(cloudflareworkers.emulator)
    final _raw:WebTransformStream<Uint8Array, Uint8Array> = undefined;

    public final writable:WritableStream;
    public final readable:ReadableStream;

    public function new() {
        final raw = new WebTransformStream();
        Object.defineProperty(this, "_raw", {value: raw, enumerable: false});
        writable = new WritableStream(raw.writable);
        readable = new ReadableStream(raw.readable);
    }
}