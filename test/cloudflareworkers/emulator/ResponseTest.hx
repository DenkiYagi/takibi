package cloudflareworkers.emulator;

import buddy.BuddySuite;
import js.lib.Promise;
import js.lib.Uint8Array;
import js.node.Buffer;
import js.node.util.TextEncoder;
import js.node.url.URLSearchParams;
import js.npm.webstreams_polyfill.ReadableByteStreamController;
import js.npm.webstreams_polyfill.ReadableStream in WebReadableStream;
import js.npm.webstreams_polyfill.ReadableStream.UnderlyingByteSourceType;
using buddy.Should;
using cloudflareworkers.emulator.Response;

class ResponseTest extends BuddySuite {
    static function bodyToString(body: ReadableStream): Promise<String> {
        return new Promise((resolve, reject) -> {
            var resultText = "";
            final reader = cast body.getReader();
            function push() {
                reader.read().then(result -> {
                    if (result.done) {
                        resolve(resultText);
                    } else {
                        resultText += Buffer.from(result.value).toString();
                        push();
                    }
                }, reject);
            }
            push();
        });
    }

    public function new() {
        describe("Response.new()", {
            it("should return Response that has default properties(new Response())", {
                final expect = { url: "", redirected: false, ok: true, status: 200, statusText: "OK", body: null };
                final responses: Array<Response> = [
                    new Response(),
                    new Response(null),
                    new Response(null, null),
                    new Response(null, {})
                ];

                for (res in responses) {
                    res.url.should.be(expect.url);
                    res.redirected.should.be(expect.redirected);
                    res.ok.should.be(expect.ok);
                    res.status.should.be(expect.status);
                    res.statusText.should.be(expect.statusText);
                    res.body.should.be(expect.body);
                    res.headers.entries().next().done.should.be(true);
                }
            });

            it("should return Response that has expected properties(new Response(body))", (done) -> {
                final sampleReadableStream = new ReadableStream(new WebReadableStream({
                    type: Bytes,
                    start: (controller: ReadableByteStreamController) -> {
                        controller.enqueue(new TextEncoder().encode("ReadableStream"));
                        controller.close();
                    }
                }));
                final sampleUrlSearchParams = new URLSearchParams({symbols:" `~!@#$%^&*()-_=+[{]};:'\"<,>.?/|\\", seconds:"null"});
                final testCases:Array<Dynamic> = [
                    { body: "UVString",             expect: { url: "", redirected: false, ok: true, headers: [["content-type", "text/plain;charset=UTF-8"]], status: 200, statusText: "OK", body: "UVString" } },
                    { body: sampleUrlSearchParams,  expect: { url: "", redirected: false, ok: true, headers: [["content-type", "application/x-www-form-urlencoded;charset=UTF-8"]], status: 200, statusText: "OK", body: "symbols=+%60%7E%21%40%23%24%25%5E%26*%28%29-_%3D%2B%5B%7B%5D%7D%3B%3A%27%22%3C%2C%3E.%3F%2F%7C%5C&seconds=null" } },
                    { body: sampleReadableStream,   expect: { url: "", redirected: false, ok: true, headers: [], status: 200, statusText: "OK", body: "ReadableStream" } },
                ];

                Promise.all(testCases.map(testCase -> new Promise((resolve, reject) -> {
                    final res = new Response(testCase.body);
                    res.url.should.be(testCase.expect.url);
                    res.redirected.should.be(testCase.expect.redirected);
                    res.ok.should.be(testCase.expect.ok);
                    res.status.should.be(testCase.expect.status);
                    res.statusText.should.be(testCase.expect.statusText);

                    testCase.expect.headers.forEach(headerPair -> {
                        res.headers.get(headerPair[0]).should.be(headerPair[1]);
                    });

                    ResponseTest.bodyToString(res.body).then(bodyText -> {
                        bodyText.should.be(testCase.expect.body);
                        resolve(null);
                    }, reject);
                }))).then(cast done, fail);
            });

            it("should return Response that has expected properties(new Response(FormData))", (done) -> {
                final sampleFormData = new FormData();
                sampleFormData.append("key", "value");
                sampleFormData.append("key", "value2");
                final sampleFormData2 = new FormData();
                final testCases:Array<Dynamic> = [
                    { body: sampleFormData, expect: { url: "", redirected: false, ok: true, status: 200, statusText: "OK" } },
                    { body: sampleFormData2, expect: { url: "", redirected: false, ok: true, status: 200, statusText: "OK" } },
                ];
                final contentTypeExpect = ~/^multipart\/form-data; boundary=([-0-9a-z'()+_,.\/:=?]{1,70})/i;

                Promise.all(testCases.map(testCase -> new Promise((resolve, reject) -> {
                    final res = new Response(testCase.body);
                    res.url.should.be(testCase.expect.url);
                    res.redirected.should.be(testCase.expect.redirected);
                    res.ok.should.be(testCase.expect.ok);
                    res.status.should.be(testCase.expect.status);
                    res.statusText.should.be(testCase.expect.statusText);

                    contentTypeExpect.match(res.headers.get("content-type")).should.be(true);
                    final boundary = "--" + contentTypeExpect.replace(res.headers.get("content-type"), "$1");

                    ResponseTest.bodyToString(res.body).then(bodyText -> {
                        // TODO: boundaryしか確認できていない。
                        StringTools.startsWith(bodyText, boundary).should.be(true);
                        StringTools.endsWith(StringTools.trim(bodyText), boundary + "--").should.be(true);
                        resolve(null);
                    }, reject);
                }))).then(cast done, fail);
            });

            it("should return Response that has expected properties(new Response(null, init))", {
                final testCases:Array<Dynamic> = [
                    { init: { status: 199 }, expect: null, throwError: true },
                    { init: { status: 200 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 200, statusText: "OK", body: null }, throwError: false },
                    { init: { status: 201 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 201, statusText: "Created", body: null }, throwError: false },
                    { init: { status: 202 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 202, statusText: "Accepted", body: null }, throwError: false },
                    { init: { status: 203 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 203, statusText: "Non-Authoritative Information", body: null }, throwError: false },
                    { init: { status: 204 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 204, statusText: "No Content", body: null }, throwError: false },
                    { init: { status: 205 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 205, statusText: "Reset Content", body: null }, throwError: false },
                    { init: { status: 206 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 206, statusText: "Partial Content", body: null }, throwError: false },
                    { init: { status: 207 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 207, statusText: "Multi-Status", body: null }, throwError: false },
                    { init: { status: 208 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 208, statusText: "Already Reported", body: null }, throwError: false },
                    { init: { status: 209 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 209, statusText: "Successful", body: null }, throwError: false },
                    { init: { status: 226 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 226, statusText: "IM Used", body: null }, throwError: false },
                    { init: { status: 299 }, expect: { url: "", redirected: false, ok: true, headers: [], status: 299, statusText: "Successful", body: null }, throwError: false },
                    { init: { status: 300 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 300, statusText: "Multiple Choices", body: null }, throwError: false },
                    { init: { status: 301 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 301, statusText: "Moved Permanently", body: null }, throwError: false },
                    { init: { status: 302 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 302, statusText: "Found", body: null }, throwError: false },
                    { init: { status: 303 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 303, statusText: "See Other", body: null }, throwError: false },
                    { init: { status: 304 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 304, statusText: "Not Modified", body: null }, throwError: false },
                    { init: { status: 305 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 305, statusText: "Use Proxy", body: null }, throwError: false },
                    { init: { status: 306 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 306, statusText: "Redirection", body: null }, throwError: false },
                    { init: { status: 307 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 307, statusText: "Temporary Redirect", body: null }, throwError: false },
                    { init: { status: 308 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 308, statusText: "Permanent Redirect", body: null }, throwError: false },
                    { init: { status: 309 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 309, statusText: "Redirection", body: null }, throwError: false },
                    { init: { status: 399 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 399, statusText: "Redirection", body: null }, throwError: false },
                    { init: { status: 400 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 400, statusText: "Bad Request", body: null }, throwError: false },
                    { init: { status: 401 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 401, statusText: "Unauthorized", body: null }, throwError: false },
                    { init: { status: 402 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 402, statusText: "Payment Required", body: null }, throwError: false },
                    { init: { status: 403 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 403, statusText: "Forbidden", body: null }, throwError: false },
                    { init: { status: 404 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 404, statusText: "Not Found", body: null }, throwError: false },
                    { init: { status: 405 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 405, statusText: "Method Not Allowed", body: null }, throwError: false },
                    { init: { status: 406 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 406, statusText: "Not Acceptable", body: null }, throwError: false },
                    { init: { status: 407 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 407, statusText: "Proxy Authentication Required", body: null }, throwError: false },
                    { init: { status: 408 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 408, statusText: "Request Timeout", body: null }, throwError: false },
                    { init: { status: 409 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 409, statusText: "Conflict", body: null }, throwError: false },
                    { init: { status: 410 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 410, statusText: "Gone", body: null }, throwError: false },
                    { init: { status: 411 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 411, statusText: "Length Required", body: null }, throwError: false },
                    { init: { status: 412 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 412, statusText: "Precondition Failed", body: null }, throwError: false },
                    { init: { status: 413 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 413, statusText: "Payload Too Large", body: null }, throwError: false },
                    { init: { status: 414 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 414, statusText: "URI Too Long", body: null }, throwError: false },
                    { init: { status: 415 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 415, statusText: "Unsupported Media Type", body: null }, throwError: false },
                    { init: { status: 416 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 416, statusText: "Range Not Satisfiable", body: null }, throwError: false },
                    { init: { status: 417 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 417, statusText: "Expectation Failed", body: null }, throwError: false },
                    { init: { status: 418 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 418, statusText: "I'm a teapot", body: null }, throwError: false },
                    { init: { status: 419 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 419, statusText: "Client Error", body: null }, throwError: false },
                    { init: { status: 420 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 420, statusText: "Client Error", body: null }, throwError: false },
                    { init: { status: 421 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 421, statusText: "Misdirected Request", body: null }, throwError: false },
                    { init: { status: 422 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 422, statusText: "Unprocessable Entity", body: null }, throwError: false },
                    { init: { status: 423 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 423, statusText: "Locked", body: null }, throwError: false },
                    { init: { status: 424 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 424, statusText: "Failed Dependency", body: null }, throwError: false },
                    { init: { status: 425 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 425, statusText: "Client Error", body: null }, throwError: false },
                    { init: { status: 426 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 426, statusText: "Upgrade Required", body: null }, throwError: false },
                    { init: { status: 427 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 427, statusText: "Client Error", body: null }, throwError: false },
                    { init: { status: 428 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 428, statusText: "Precondition Required", body: null }, throwError: false },
                    { init: { status: 429 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 429, statusText: "Too Many Requests", body: null }, throwError: false },
                    { init: { status: 430 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 430, statusText: "Client Error", body: null }, throwError: false },
                    { init: { status: 431 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 431, statusText: "Request Header Fields Too Large", body: null }, throwError: false },
                    { init: { status: 432 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 432, statusText: "Client Error", body: null }, throwError: false },
                    { init: { status: 451 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 451, statusText: "Unavailable For Legal Reasons", body: null }, throwError: false },
                    { init: { status: 499 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 499, statusText: "Client Error", body: null }, throwError: false },
                    { init: { status: 500 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 500, statusText: "Internal Server Error", body: null }, throwError: false },
                    { init: { status: 501 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 501, statusText: "Not Implemented", body: null }, throwError: false },
                    { init: { status: 502 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 502, statusText: "Bad Gateway", body: null }, throwError: false },
                    { init: { status: 503 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 503, statusText: "Service Unavailable", body: null }, throwError: false },
                    { init: { status: 504 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 504, statusText: "Gateway Timeout", body: null }, throwError: false },
                    { init: { status: 505 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 505, statusText: "HTTP Version Not Supported", body: null }, throwError: false },
                    { init: { status: 506 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 506, statusText: "Variant Also Negotiates", body: null }, throwError: false },
                    { init: { status: 507 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 507, statusText: "Insufficient Storage", body: null }, throwError: false },
                    { init: { status: 508 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 508, statusText: "Loop Detected", body: null }, throwError: false },
                    { init: { status: 509 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 509, statusText: "Server Error", body: null }, throwError: false },
                    { init: { status: 510 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 510, statusText: "Not Extended", body: null }, throwError: false },
                    { init: { status: 511 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 511, statusText: "Network Authentication Required", body: null }, throwError: false },
                    { init: { status: 512 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 512, statusText: "Server Error", body: null }, throwError: false },
                    { init: { status: 599 }, expect: { url: "", redirected: false, ok: false, headers: [], status: 599, statusText: "Server Error", body: null }, throwError: false },
                    { init: { status: 600 }, expect: null, throwError: true },
                    { init: { statusText: null },               expect: { url: "", redirected: false, ok: true, headers: [], status: 200, statusText: "null", body: null }, throwError: false },
                    { init: { statusText: "No Problem" },               expect: { url: "", redirected: false, ok: true, headers: [], status: 200, statusText: "No Problem", body: null }, throwError: false },
                    { init: { status: 210, statusText: "No Problem" },  expect: { url: "", redirected: false, ok: true, headers: [], status: 210, statusText: "No Problem", body: null }, throwError: false },
                    { init: { status: 310, statusText: "" },            expect: { url: "", redirected: false, ok: false, headers: [], status: 310, statusText: "", body: null }, throwError: false },
                    { init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) }, expect: { url: "", redirected: false, ok: true, headers: [ ["Content-Type", "text/html; charset=UTF-8" ] ], status: 200, statusText: "OK", body: null } },
                    { init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] }, expect: { url: "", redirected: false, ok: true, headers: [ ["Content-Type","image/gif"], ["Accept-Encoding", "deflate, gzip"] ], status: 200, statusText: "OK", body: null } },
                    { init: { headers: { "content-type": "application/json", "Accept-Encoding": "deflate" } }, expect: { url: "", redirected: false, ok: true, headers:  [ ["Content-type", "application/json"], ["Accept-Encoding", "deflate"] ], status: 200, statusText: "OK", body: null } },
                ];

                for (testCase in testCases) {
                    if (testCase.throwError) {
                        (() -> new Response(null, testCase.init)).should.throwAnything();
                    } else {
                        final res = new Response(null, testCase.init);
                        res.url.should.be(testCase.expect.url);
                        res.redirected.should.be(testCase.expect.redirected);
                        res.ok.should.be(testCase.expect.ok);
                        res.status.should.be(testCase.expect.status);
                        res.statusText.should.be(testCase.expect.statusText);
                        res.body.should.be(testCase.expect.body);

                        testCase.expect.headers.forEach(headerPair -> {
                            res.headers.get(headerPair[0]).should.be(headerPair[1]);
                        });
                    }
                }
            });

            //it("should return Response that has expected properties(new Response(body, init))", (done) -> {
            //    final testCases:Array<Dynamic> = [
            //        { body: "USVString", init: { statusText: null },               expect: { url: "", redirected: false, ok: true, headers: [['content-type', 'text/plaing;charset=UTF-8']], status: 200, statusText: "null", body: null }, throwError: false },
            //        { body: "USVString", init: { statusText: "No Problem" },               expect: { url: "", redirected: false, ok: true, headers: [], status: 200, statusText: "No Problem", body: null }, throwError: false },
            //        { body: , init: { status: 210, statusText: "No Problem" },  expect: { url: "", redirected: false, ok: true, headers: [], status: 210, statusText: "No Problem", body: null }, throwError: false },
            //        { body: , init: { status: 310, statusText: "" },            expect: { url: "", redirected: false, ok: false, headers: [], status: 310, statusText: "", body: null }, throwError: false },
            //        { body: , init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) }, expect: { url: "", redirected: false, ok: true, headers: [ ["Content-Type", "text/html; charset=UTF-8" ] ], status: 200, statusText: "OK", body: null } },
            //        { body: , init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] }, expect: { url: "", redirected: false, ok: true, headers: [ ["Content-Type","image/gif"], ["Accept-Encoding", "deflate, gzip"] ], status: 200, statusText: "OK", body: null } },
            //        { body: , init: { headers: { "content-type": "application/json", "Accept-Encoding": "deflate" } }, expect: { url: "", redirected: false, ok: true, headers:  [ ["Content-type", "application/json"], ["Accept-Encoding", "deflate"] ], status: 200, statusText: "OK", body: null } },
            //    ];

            //    Promise.all(testCases.map(testCase -> new Promise((resolve, reject) -> {
            //        final res = new Response(testCase.body);
            //        res.url.should.be(testCase.expect.url);
            //        res.redirected.should.be(testCase.expect.redirected);
            //        res.ok.should.be(testCase.expect.ok);
            //        res.status.should.be(testCase.expect.status);
            //        res.statusText.should.be(testCase.expect.statusText);

            //        testCase.expect.headers.forEach(headerPair -> {
            //            res.headers.get(headerPair[0]).should.be(headerPair[1]);
            //        });

            //        ResponseTest.bodyToString(res.body).then(bodyText -> {
            //            bodyText.should.be(testCase.expect.body);
            //            resolve(null);
            //        }, reject);
            //    }))).then(cast done, fail);
            //});
        });

        describe("Response.redirect()", {
            it("shoud return Response that has expected properties", {
                final sampleUrl = 'https://google.com/';
                final testCases = [
                    { url: sampleUrl, status: null, expect: { url: sampleUrl, redirected: false, ok: false, status: 302, statusText: 'Found', body: null, headers: [['location', sampleUrl]] }, throwError: false },
                ];

                for (testCase in testCases) {
                    if (testCase.throwError) {
                        (() -> Response.redirect(testCase.url, testCase.status)).should.throwAnything();
                    } else {
                        final res = Response.redirect(testCase.url, testCase.status);
                        res.url.should.be(testCase.expect.url);
                        res.redirected.should.be(testCase.expect.redirected);
                        res.ok.should.be(testCase.expect.ok);
                        res.status.should.be(testCase.expect.status);
                        res.statusText.should.be(testCase.expect.statusText);
                        res.body.should.be(testCase.expect.body);

                        testCase.expect.headers.forEach(headerPair -> {
                            res.headers.get(headerPair[0]).should.be(headerPair[1]);
                        });
                    }
                }
            });
        });
    }
}
