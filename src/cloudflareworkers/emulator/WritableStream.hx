package cloudflareworkers.emulator;

import js.Lib.undefined;
import js.lib.Uint8Array;
import js.lib.Promise;
import js.lib.Object;
import js.npm.webstreams_polyfill.WritableStream in WebWritableStream;

@:keep
class WritableStream {
    @:allow(cloudflareworkers.emulator)
    final _raw:WebWritableStream<Uint8Array> = undefined;

    public final locked:Bool = undefined;

    @:allow(cloudflareworkers.emulator)
    function new(raw:WebWritableStream<Uint8Array>) {
        Object.defineProperty(this, "_raw", {value: raw, enumerable: false});
    }

    public function abort(reason:Dynamic):Promise<Void> {
        return _raw.abort(reason);
    }

    public function getWriter():WritableStreamDefaultWriter {
        return _raw.getWriter();
    }
}

typedef WritableStreamDefaultWriter = js.npm.webstreams_polyfill.WritableStreamDefaultWriter<Uint8Array>;
