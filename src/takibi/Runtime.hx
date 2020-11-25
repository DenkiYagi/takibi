package takibi;

import takibi.Request;
import takibi.Response;
import haxe.extern.EitherType;
import js.Node;
import js.Syntax;
import js.html.Console;
import js.html.URL;
import js.lib.ArrayBuffer;
import js.lib.Function;
import js.lib.Object;
import js.lib.Promise;
import js.lib.Uint8Array;
import js.node.Buffer;
import js.node.Timers.Timeout;
import js.node.Vm;
import js.node.http.IncomingMessage;
import js.node.http.ServerResponse;
import js.node.https.Agent;
import js.node.stream.Readable;
import js.npm.Micro;
import js.npm.NodeFetch.Request in NodeFetchRequest;
import js.npm.NodeFetch.RequestInit in NodeFetchRequestInit;
import js.npm.NodeFetch.RequestRedirect in NodeFetchRequestRedirect;
import js.npm.NodeFetch.Response in NodeFetchResponse;
import js.npm.webstreams_polyfill.ReadableByteStreamController;
import js.npm.webstreams_polyfill.ReadableStream in WebReadableStream;
import js.npm.webstreams_polyfill.ReadableStream.UnderlyingByteSourceType;
import js.npm.webstreams_polyfill.ReadableStreamBYOBReader;

class Runtime {
    final listeners:Array<haxe.Constraints.Function>;
    final context:VmContext<{}>;
    final timeoutObjects:Array<Timeout>;

    public function new() {
        listeners = [];
        context = createContext();
        timeoutObjects = [];
    }

    public function loadScript(code:String):Void {
        //TODO: Windowsでnode-webcrypto-osslをインストールするのがしんどいので、一旦WebCryptoを無効化
        // final inheritsCode = "util.inherits(ArrayBuffer, hostClass.ArrayBuffer);";
        // Vm.runInContext(inheritsCode + code, context);
        Vm.runInContext(code, context);
    }

    public function handle(req:IncomingMessage, res:ServerResponse) {
        final request = createRequest(req);
        final promises = invokeFetchHandlers(request);

        return Promise.race(promises).then((response:Response) -> {
            res.statusCode = response.status;
            res.statusMessage = response.statusText;

            response.headers.forEach((value, name) -> {
                if (res.hasHeader(name)) {
                    final current = res.getHeader(name);
                    if (Std.is(current, Array)) {
                        res.setHeader(name, (current : Array<String>).concat([value]));
                    } else {
                        res.setHeader(name, [current, value]);
                    }
                } else {
                    res.setHeader(name, value);
                }
            });

            response.arrayBuffer().then(ab -> res.end(Buffer.from(ab)));

        }, e -> {
            res.statusCode = 500;
            res.end();
        });
    }

    function createContext():VmContext<{}> {
        final abab = js.Lib.require("abab");

        //TODO: Windowsでnode-webcrypto-osslをインストールするのがしんどいので、一旦WebCryptoを無効化
        // final crypto = new Crypto();

        // // method override
        // final orgImportKey = crypto.subtle.importKey;
        // function importKey(format: String, keyData: Dynamic, algorithm: Dynamic, extractable: Bool, keyUsages: Array<String>): Promise<Dynamic> {
        //     var fixedAlgorithm = {}
        //     for (key in Reflect.fields(algorithm)) {
        //         Reflect.setField(fixedAlgorithm, key, Reflect.field(algorithm, key));
        //     }
        //     return orgImportKey.call(crypto.subtle, format, keyData, fixedAlgorithm, extractable, keyUsages);
        // }
        // crypto.subtle.importKey = importKey;

        // final util = js.Lib.require("util");
        // final hostClass = {
        //     Array: Array,
        //     ArrayBuffer: ArrayBuffer
        // };

        return Vm.createContext({
            console: Console,

            atob: abab.atob,
            btoa: abab.btoa,

            setTimeout: setTimeout,
            setInterval: setInterval,
            clearTimeout: clearTimeout,
            clearInterval: clearTimeout,

            TextEncoder: js.node.util.TextEncoder,
            TextDecorder: js.node.util.TextDecoder,

            fetch: fetch,
            caches: new CacheStorage(),
            addEventListener: addEventListener,
            Request: takibi.Request,
            Response: takibi.Response,
            Headers: takibi.Headers,
            FormData: takibi.FormData,
            URL: js.node.url.URL,
            URLSearchParams: js.node.url.URLSearchParams,

            // crypto: crypto,
            // util: util,
            // hostClass: hostClass,

            ReadableStream: ReadableStream,
            WritableStream: WritableStream,
            TransformStream: TransformStream,
        });
    }

    function fetch(input:EitherType<String, Request>, ?init:RequestInit):Promise<Response> {
        final request = new Request(input, init);
        request.headers.set("host", new URL(request.url).host);

        return js.npm.NodeFetch.fetch(request.url, {
            method: request.method,
            headers: request.headers,
            redirect: cast request.redirect,
            agent: (request.url.indexOf("https://") >= 0) ? new Agent(cast {rejectUnauthorized:false}) : null, //TODO: hxnodejsを更新したらcast不要になるはず
            body: (request.body != null) ? new NodeFetchBody((cast request.body)._raw) : null,
            compress: false
        }).then(createResponse, e -> {
            js.Node.console.log(e);
            throw e;
        });
    }

    function addEventListener(name:String, fn:haxe.Constraints.Function):Void {
        if (Syntax.strictEq(name, "fetch")) listeners.push(fn);
    }

    function createRequest(req:IncomingMessage):Request {
        // TODO: emulatorがlocalhost:3000で動く前提になっているが、起動中の情報を取得した方が良い
        final url = new Request('http://localhost:3000${req.url}');

        final headers = new Headers(req.headers);
        // final headers = new Headers();
        // for (key => item in req.headers) {
        //     if (Std.is(item, Array)) {
        //         for (x in (item : Array<String>)) {
        //             headers.append(key, x);
        //         }
        //     } else {
        //         headers.append(key, item);
        //     }
        // }

        return new Request(url, {
            method: cast req.method,
            headers: headers,
            redirect: RequestRedirect.Follow,
            body: switch (req.method) {
                case Get | Head: null;
                case _: toReadableStream(req);
            }
        });
    }

    function createResponse(res:NodeFetchResponse):Response {
        return new Response(toReadableStream(res.body), {
            status: res.status,
            statusText: res.statusText,
            headers: res.headers
        });
    }

    // cloudflare workersスクリプト側で登録されたfetchイベントハンドラーを実行
    function invokeFetchHandlers(request:Request):Array<Promise<Response>> {
        final results:Array<Promise<Response>> = [];

        try {
            final event = new FetchEvent(request, {
                respondWith: results.push,
                waitUntil: promise -> {},
                passThroughOnException: () -> {}
            });
            for (fn in listeners) fn(event);
        } catch (e:Dynamic) {
            trace(e);
        }

        return results;
    }



    function toReadableStream(raw:IReadable) {
        return new ReadableStream(new WebReadableStream({
            type: Bytes,
            start: (controller:ReadableByteStreamController) -> {
                raw.on(ReadableEvent.Data, chunk -> {
                    controller.enqueue(chunk);
                }).on(ReadableEvent.End, () -> {
                    controller.close();
                }).on(ReadableEvent.Error, e -> {
                    controller.error(e);
                });
                return;
            }
        }, {highWaterMark: 0}));
    }

    function setTimeout(func: Function, delay: Int) {
        final args = (cast Array).prototype.slice.call(Syntax.code("arguments"), 2);
        final timeoutObject = js.Node.setTimeout(() -> {
            func.apply(null, args);
        }, delay);

        timeoutObjects.push(timeoutObject);
        return timeoutObjects.length - 1;
    }
    function setInterval(func: Function, delay: Int) {
        final args = (cast Array).prototype.slice.call(Syntax.code("arguments"), 2);
        final timeoutObject = js.Node.setInterval(() -> {
            func.apply(null, args);
        }, delay);

        timeoutObjects.push(timeoutObject);
        return timeoutObjects.length - 1;
    }
    function clearTimeout(timeoutId: Int) {
        js.Node.clearTimeout(timeoutObjects[timeoutId]);
        timeoutObjects[timeoutId] = null;
    }

    // function readWorkerStream(stream:ReadableStream<Uint8Array>):Promise<String> {
    //     return new Promise((f, r) -> {
    //         final body = [];
    //         stream.on(ReadableEvent.Data, chunk -> {
    //             body.push(chunk);
    //         }).on(ReadableEvent.End, () -> {
    //             f(Buffer.concat(body).toString());
    //         }).on(ReadableEvent.Error, e -> {
    //             r(e);
    //         });
    //     });
    // }

    // function toNodeFetchRequest(request:Request):Promise<NodeFetchRequest> {
    //     final headers = new NodeFetchHeaders();
    //     request.headers.forEach((value, name) -> headers.append(name, value));

    //     final redirect = switch (request.redirect) {
    //         case Follow: NodeFetchRequestRedirect.FOLLOW;
    //         case Manual: NodeFetchRequestRedirect.MANUAL;
    //     }

    //     return switch (request.method) {
    //         case RequestMethod.GET | RequestMethod.HEAD:
    //             Promise.resolve(new NodeFetchRequest(request.url, {
    //                 method: request.method,
    //                 headers: headers,
    //                 redirect: redirect
    //             }));
    //         case _:
    //             readStream(request.body).then(body -> new NodeFetchRequest(request.url, {
    //                 method: request.method,
    //                 headers: headers,
    //                 redirect: redirect,
    //                 body: body
    //             }));
    //     }
    // }
}

private class NodeFetchBody extends Readable<NodeFetchBody> {
    public function new(stream:WebReadableStream<Uint8Array>) {
        var reader:ReadableStreamBYOBReader = null;

        function handleError(error:Dynamic) {
            if (reader != null) reader.releaseLock();
            destroy(error);
        }

        function getReader():ReadableStreamBYOBReader {
            if (reader == null) {
                reader = stream.getReader({mode:Byob});
                reader.closed.then(_ -> {
                    push(null);
                    return;
                }, handleError);
            }
            return reader;
        }

        super({
            read: (size:Int) -> {
                final buff = new Uint8Array(size);
                getReader().read(buff).then(
                    x -> {
                        reader.releaseLock();
                        if (!x.done) push(x.value);
                    },
                    handleError
                );
            }
        });
    }
}

// @:jsRequire("node-webcrypto-ossl", "Crypto")
// extern class Crypto {
//     function new(?options: Object): Void;

//     final subtle: Dynamic;
// }
