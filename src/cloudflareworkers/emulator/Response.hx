package cloudflareworkers.emulator;

import cloudflareworkers.emulator.Body.BodySource;
import cloudflareworkers.emulator.ReadableStream.ReadableStreamDefaultReader;
import haxe.extern.EitherType;
import js.Syntax;
import js.lib.ArrayBuffer;
import js.lib.BufferSource;
import js.lib.Uint8Array;
import js.node.url.URLSearchParams;
import js.npm.webstreams_polyfill.ReadableStream in WebReadableStream;
import js.npm.webstreams_polyfill.ReadableStreamDefaultController;

@:keep
class Response extends Body {
    public final status:Int;
    public final statusText:String;
    public final headers:Headers;

    public function new(?body:BodySource, ?init:ResponseInit) {
        if (init != null) {
            status = (init.status != null) ? init.status : 200;
            statusText = (init.statusText != null) ? init.statusText : "";
            headers = (Std.is(init.headers, Headers)) ? new Headers(init.headers) : new Headers();
        } else {
            status = 200;
            statusText = "";
            headers = new Headers();
        }

        // final stream = if (Syntax.instanceof(body, ArrayBuffer)) {
        //     new ReadableStream(new WebReadableStream({
        //         start: (ctrl:ReadableStreamDefaultController<Uint8Array>) -> {
        //             ctrl.enqueue(new Uint8Array((body : ArrayBuffer)));
        //             ctrl.close();
        //         }
        //     }));
        // } else if (Syntax.instanceof(body, FormData)) {
        //     (body : FormData);
        //     null;
        // } else if (Syntax.instanceof(body, ReadableStream)) {
        //     (body : ReadableStream);
        // } else if (Syntax.instanceof(body, URLSearchParams)) {
        //     null;

        // } else if (Syntax.instanceof(body, String)) {
        //     null;

        // } else {
        //     null;
        // }
        super(body);
    }
}

typedef ResponseInit = {
    /**
        The status code for the reponse, such as 200.
    **/
    var ?status:Int;

    /**
        The status message associated with the status code, like, OK.
    **/
    var ?statusText:String;

    /**
        Any headers to add to your response that are contained within a Headers object or object literal of ByteString key/value pairs.
    **/
    var ?headers:EitherType<Headers, EitherType<KeyValue<String, String>, haxe.DynamicAccess<String>>>;
}