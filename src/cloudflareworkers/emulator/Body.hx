package cloudflareworkers.emulator;

import cloudflareworkers.emulator.ReadableStream.ReadableStreamBYOBReader;
import cloudflareworkers.emulator.ReadableStream.ReadableStreamDefaultReader;
import haxe.Json;
import haxe.extern.EitherType;
import haxe.macro.Expr.Error;
import js.lib.ArrayBuffer;
import js.lib.BufferSource;
import js.lib.Error.TypeError;
import js.lib.Promise;
import js.lib.Uint8Array;
import js.node.Buffer;
import js.node.url.URLSearchParams;

@:keep
class Body {
    /**
        A simple getter that exposes a ReadableStream of the contents.
    **/
    public var body(default, null):BodySource;

    /**
        A Boolean that declares if the body has been used in a response.
    **/
    public var bodyUsed(default, null):Bool;

    function new(?body:BodySource) {
        this.body = body;
    }
 
    /**
        Returns a promise that resolves with an ArrayBuffer representation of the request body.
    **/
    public function arrayBuffer():Promise<ArrayBuffer> {
        // TODO: 仮実装ゆえ要実装修正
        if (Std.is(body, ArrayBuffer)) {
            return Promise.resolve(cast (body, ArrayBuffer));
        }
        return new Promise((resolve, reject) -> {
            if (Std.is(body, ReadableStream)) {
                final _body = cast (body, ReadableStream);
                final reader = _body._raw.getReader();
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
            } else if (Std.is(body, FormData)) {
                final _body = cast body;
                resolve(Buffer.from(_body.entries().reduce((acc, cur) -> (acc + cur[0] + ":" + cur[1] + "\n"), "")));
            } else if (Std.is(body, URLSearchParams)) {
                final _body = cast body;
                resolve(Buffer.from(cast _body.toString()));
            } else if (Std.is(body, String)) {
                resolve(Buffer.from(body));
            } else if (body == null) {
                resolve(Buffer.alloc(0));
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
        if (Std.is(body, FormData)) {
            return Promise.resolve(cast (body, FormData));
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
        if (Std.is(body, ReadableStream)) {
            return new Promise((resolve, reject) -> {
                final _body = cast (body, ReadableStream);
                final reader = _body._raw.getReader();
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
        if (Std.is(body, ArrayBuffer)) {
            final _body = cast body;
            return Promise.resolve(_body.toString());
        }
        if (Std.is(body, FormData)) {
            final _body = cast body;
            return Promise.resolve(_body.entries().reduce((acc, cur) -> (acc + cur[0] + ":" + cur[1] + "\n"), ""));
        }
        if (Std.is(body, URLSearchParams)) {
            final _body = cast body;
            return Promise.resolve(_body.toString());
        }
        if (Std.is(body, String)) {
            return Promise.resolve(cast (body, String));
        }
        if (body == null) {
            return Promise.resolve("");
        }
        return Promise.reject(new TypeError());
    }
}

typedef BodySource = EitherType<BufferSource, EitherType<FormData, EitherType<ReadableStream, EitherType<URLSearchParams, String>>>>;
