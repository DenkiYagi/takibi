package cloudflareworkers.emulator;

import js.lib.HaxeIterator;
import haxe.Json;
import haxe.extern.EitherType;
import js.lib.DataView;
import js.lib.ArrayBufferView;
import js.lib.ArrayBuffer;
import js.lib.BufferSource;
import js.lib.Error.TypeError;
import js.lib.Promise;
import js.node.Buffer;
import js.node.url.URLSearchParams;
import js.node.util.TextEncoder;
import js.npm.webstreams_polyfill.ReadableByteStreamController;
import js.npm.webstreams_polyfill.ReadableStream in WebReadableStream;
import js.npm.webstreams_polyfill.ReadableStream.UnderlyingByteSourceType;

@:keep
class Body {
    var rawBody:BodySource;
    var readableBody:ReadableStream;
    var formDataBoundary:String;
    /**
        A simple getter that exposes a ReadableStream of the contents.
    **/
    public var body(get, null):ReadableStream;
    public function get_body(): ReadableStream {
        if (readableBody != null) {
            return readableBody;
        }
        if (rawBody == null || Std.is(rawBody, ReadableStream)) {
            return (readableBody = rawBody);
        }

        var buffer: Dynamic;
        if (Std.is(rawBody, ArrayBuffer) || ArrayBuffer.isView(rawBody)) {
            buffer = (ArrayBuffer.isView(rawBody)) ? cast (rawBody) : new DataView(rawBody);
        } else if (Std.is(rawBody, FormData)) {
            buffer = new TextEncoder().encode(generateFormDataString());
        } else if (Std.is(rawBody, URLSearchParams)) {
            buffer = new TextEncoder().encode(cast (rawBody, URLSearchParams).toString());
        } else {
            buffer = new TextEncoder().encode(cast (rawBody, String));
        }

        return (readableBody = new ReadableStream(new WebReadableStream({
            type: Bytes,
            start: (controller:ReadableByteStreamController) -> {
                controller.enqueue(buffer);
                controller.close();
            }
        })));
    }

    /**
        A Boolean that declares if the body has been used in a response.
    **/
    public var bodyUsed(default, null):Bool;

    function new(?body:BodySource) {
        rawBody = body;
    }

    /**
        Returns a promise that resolves with an ArrayBuffer representation of the request body.
    **/
    public function arrayBuffer():Promise<ArrayBuffer> {
        // TODO: 仮実装ゆえ要実装修正
        if (Std.is(rawBody, ArrayBuffer)) {
            return Promise.resolve(cast (rawBody, ArrayBuffer));
        }
        return new Promise((resolve, reject) -> {
            if (Std.is(rawBody, URLSearchParams)) {
                resolve(Buffer.from(cast (rawBody, URLSearchParams).toString()));
            } else if (Std.is(rawBody, String)) {
                resolve(Buffer.from(rawBody));
            } else if (body == null) {
                resolve(Buffer.alloc(0));
            } else if (Std.is(body, ReadableStream)) {
                final reader = cast body.getReader();
                var buf = Buffer.from([]);

                function push() {
                    reader.read().then(result -> {
                        if (result.done) {
                            resolve(buf);
                        } else {
                            buf = Buffer.concat([buf, Buffer.from(result.value)]);
                            push();
                        }
                    }, reject);
                }
                push();
            } else reject(new TypeError());
        }).then(buffer -> {
            return buffer.buffer.slice(buffer.byteOffset, buffer.byteOffset + buffer.byteLength);
        });
    }

    /**
        Returns a promise that resolves with a FormData representation of the request body.
    **/
    public function formData():Promise<FormData> {
        // TODO: 仮実装ゆえ要実装修正
        if (Std.is(rawBody, FormData)) {
            return Promise.resolve(cast (rawBody, FormData));
        }
        return Promise.reject();
    }

    /**
        Returns a promise that resolves with a JSON representation of the request body.
    **/
    public function json():Promise<Dynamic> {
        return text().then(text -> {
            return Json.parse(StringTools.trim(text));
        });
    }

    /**
        Returns a promise that resolves with an USVString (text) representation of the request body.
    **/
    public function text():Promise<String> {
        if (Std.is(rawBody, String)) {
            return Promise.resolve(cast rawBody);
        }
        if (body == null) {
            return Promise.resolve("");
        }
        return new Promise((resolve, reject) -> {
            final reader = cast body.getReader();
            var text = "";

            function push() {
                reader.read().then(result -> {
                    if (result.done) {
                        resolve(text);
                    } else {
                        text += Buffer.from(result.value).toString();
                        push();
                    }
                }, reject);
            }
            push();
        });
    }

    function getBoundary() {
        if (formDataBoundary != null) return formDataBoundary;
        final tmp = new StringBuf();
        for (_ in 0...32) {
            tmp.add(StringTools.hex(Std.random(16)).toLowerCase());
        }
        formDataBoundary = tmp.toString();
        return formDataBoundary;
    }
    function generateFormDataString() {
        final boundary = "--" + getBoundary();
        if (!Std.is(rawBody, FormData)) return "";
        final tmp = new StringBuf();
        final formData = cast (rawBody, FormData);

        for (kv in new HaxeIterator(formData.entries())) {
            tmp.add(boundary);
            tmp.add("\r\nContent-Disposition: form-data; name=\"");
            tmp.add(kv.key);
            tmp.add("\"\r\n\r\n");
            tmp.add(kv.value);
            tmp.add("\r\n");
        }
        tmp.add(boundary);
        tmp.add("--\r\n");
        return tmp.toString();
    }
}

typedef BodySource = EitherType<BufferSource, EitherType<FormData, EitherType<ReadableStream, EitherType<URLSearchParams, String>>>>;
