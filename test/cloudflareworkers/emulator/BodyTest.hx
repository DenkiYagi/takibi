package cloudflareworkers.emulator;

import js.node.url.URLSearchParams;
import js.html.TextDecoder;
import js.html.TextEncoder;
import buddy.BuddySuite;
using buddy.Should;
using cloudflareworkers.emulator.Body;
using cloudflareworkers.emulator.Response;
using cloudflareworkers.emulator.FormData;
import js.npm.webstreams_polyfill.ReadableByteStreamController;
import js.npm.webstreams_polyfill.ReadableStream in WebReadableStream;
import js.npm.webstreams_polyfill.ReadableStream.UnderlyingByteSourceType;
import js.lib.Promise;

class BodyTest extends BuddySuite {
    public function new() {
        describe("Body.arrayBuffer()", {
            it("should return Promise has ArrayBuffer of expected string", done -> {
                final urlSearchParams = new URLSearchParams({
                    'key': 'value',
                    'symbols': '~`!@#$%^&*()_+-={}|[]\\;\':"/.,?>< '
                });
                final readableStream = new ReadableStream(new WebReadableStream({
                    type: Bytes,
                    start: (controller: ReadableByteStreamController) -> {
                        controller.enqueue(new TextEncoder().encode("ReadableStream"));
                        controller.close();
                    }
                }));
                final testCases:Array<Dynamic> = [
                    { body: "USVString", expect: "USVString" },
                    { body: new TextEncoder().encode("ArrayBuffer"), expect: "ArrayBuffer" },
                    { body: urlSearchParams, expect: "key=value&symbols=%7E%60%21%40%23%24%25%5E%26*%28%29_%2B-%3D%7B%7D%7C%5B%5D%5C%3B%27%3A%22%2F.%2C%3F%3E%3C+" },
                    { body: readableStream, expect: "ReadableStream" },
                    { body: null, expect: "" },
                ];

                Promise.all(testCases.map(testCase -> {
                    return new Response(testCase.body).arrayBuffer().then(ab -> {
                        new TextDecoder().decode(ab).should.be(testCase.expect);
                    });
                })).then(cast done, fail);
            });
        });

        describe("Body.formData()", {
            it("should return Promise<FormData>", done -> {
                final body = new Response(new FormData());
                final result = body.formData();
                Std.is(result, Promise).should.be(true);
                result.then(ab -> {
                    if (Std.is(ab, FormData)) done();
                    else fail();
                }, err -> { fail(); });
            });
        });

        describe("Body.json()", {
            it("should return Promise<Dynamic>", done -> {
                final body = new Response("{\"Hello\":\"World\"}");
                final result = body.json();
                Std.is(result, Promise).should.be(true);
                result.then(json -> {
                    if (Std.is(json, Dynamic)) done();
                    else fail();
                }, err -> { fail(); });
            });
        });

        describe("Body.text()", {
            it("should return Promise<String>", done -> {
                final body = new Response("");
                final result = body.text();
                Std.is(result, Promise).should.be(true);
                result.then(text -> {
                    if (Std.is(text, String)) done();
                    else fail();
                }, err -> { fail(); });
            });
        });
    }
}
