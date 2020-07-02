package js.npm.webstreams_polyfill;

import js.lib.ArrayBufferView;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "ReadableStreamBYOBRequest")
#else
@:native("ReadableStreamBYOBRequest")
#end
extern class ReadableStreamBYOBRequest {
    final view:ArrayBufferView;

    function respond(bytesWritten:Int):Void;
    function respondWithNewView(view:ArrayBufferView):Void;
}
