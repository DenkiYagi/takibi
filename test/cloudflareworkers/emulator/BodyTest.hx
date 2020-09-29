package cloudflareworkers.emulator;

import js.node.url.URLSearchParams;
import buddy.BuddySuite;
using buddy.Should;
using cloudflareworkers.emulator.Body;
using cloudflareworkers.emulator.Response;
using cloudflareworkers.emulator.FormData;
import js.node.util.TextEncoder;
import js.npm.webstreams_polyfill.ReadableByteStreamController;
import js.npm.webstreams_polyfill.ReadableStream in WebReadableStream;
import js.npm.webstreams_polyfill.ReadableStream.UnderlyingByteSourceType;
import js.lib.Promise;
import js.lib.ArrayBuffer;

class BodyTest extends BuddySuite {
    public function new() {
        describe("Body.arrayBuffer()", {
            it("should return Promise<ArrayBuffer>", done -> {
                final body = new Response("");
                final result = body.arrayBuffer();
                Std.is(result, Promise).should.be(true);
                result.then(ab -> {
                    if (Std.is(ab, ArrayBuffer)) done();
                    else fail();
                }, err -> { fail(); });
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
            it("should return Promise has expected string", done -> {
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
                final buffer = new TextEncoder().encode("バッファ");

                final testCases:Array<Dynamic> = [
                    { body: null, expect: "" },
                    { body: "USVString\r\n", expect: "USVString\r\n" },
                    { body: urlSearchParams, expect: "key=value&symbols=%7E%60%21%40%23%24%25%5E%26*%28%29_%2B-%3D%7B%7D%7C%5B%5D%5C%3B%27%3A%22%2F.%2C%3F%3E%3C+" },
                    { body: readableStream, expect: "ReadableStream" },
                    { body: buffer, expect: "バッファ" }
                ];

                Promise.all(testCases.map(testCase -> {
                    return new Response(testCase.body).text().then(result -> {
                        result.should.be(testCase.expect);
                    });
                })).then(cast done, fail);
            });

            it("should return Promise has expected string with boundary", done -> {
                final formData = new FormData();
                formData.append('key', 'value');
                formData.append('symbols', '~`!@#$%^&*()_+-={}|[]\\;\':"/.,?>< ');
                final expect = [
                    "",
                    "\r\nContent-Disposition: form-data; name=\"key\"\r\n\r\nvalue\r\n",
                    "\r\nContent-Disposition: form-data; name=\"symbols\"\r\n\r\n~`!@#$%^&*()_+-={}|[]\\;':\"/.,?>< \r\n",
                    "--\r\n"
                ];

                new Response(formData).text().then(result -> {
                    final boundary = StringTools.trim(result.split("\n")[0]);
                    result.should.be(expect.join(boundary));
                }).then(cast done, fail);
            });
        });
    }
}
