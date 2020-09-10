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
            final urlSearchParams = new URLSearchParams({
                'key': 'value',
                'symbols': '~`!@#$%^&*()_+-={}|[]\\;\':"/.,?>< '
            });
            final formData = new FormData();
            formData.append('key', 'value');
            formData.append('symbols', '~`!@#$%^&*()_+-={}|[]\\;\':"/.,?>< ');
            final readableStream = new ReadableStream(new WebReadableStream({
                type: Bytes,
                start: (controller: ReadableByteStreamController) -> {
                    controller.enqueue(new TextEncoder().encode("ReadableStream"));
                    controller.close();
                }
            }));
            final buffer = new TextEncoder().encode("バッファ");

            final samples = {
                none: {
                    body: null,
                    expect: "",
                },
                string: {
                    body: "USVString\r\n",
                    expect: "USVString\r\n",
                },
                urlSearchParams: {
                    body: urlSearchParams,
                    expect: "key=value&symbols=%7E%60%21%40%23%24%25%5E%26*%28%29_%2B-%3D%7B%7D%7C%5B%5D%5C%3B%27%3A%22%2F.%2C%3F%3E%3C+",
                },
                formData: {
                    body: formData,
                    expect: [
                        "",
                        "\r\nContent-Disposition: form-data; name=\"key\"\r\n\r\nvalue\r\n",
                        "Content-Disposition: form-data; name=\"symbols\"\r\n\r\n~`!@#$%^&*()_+-={}|[]\\;':\"/.,?>< \r\n",
                        "--"
                    ],
                },
                readableStream: {
                    body: readableStream,
                    expect: "ReadableStream",
                },
                bufferSource: {
                    body: buffer,
                    expect: "バッファ",
                },
            };

            it("should return Promise has expected string", done -> {
                Promise.all([
                    new Response(samples.none.body).text(),
                    new Response(samples.string.body).text(),
                    new Response(samples.urlSearchParams.body).text(),
                    new Response(samples.readableStream.body).text(),
                    new Response(cast samples.bufferSource.body).text(),
                ]).then(results -> {
                    final expects = [
                        samples.none.expect,
                        samples.string.expect,
                        samples.urlSearchParams.expect,
                        samples.readableStream.expect,
                        samples.bufferSource.expect,
                    ];
                    for (i in 0...expects.length) {
                        results[i].should.be(expects[i]);
                    }
                }).then(cast done, fail);
            });

            it("should return Promise has expected string with boundary", done -> {
                new Response(samples.formData.body).text().then(result -> {
                    final boundary = StringTools.trim(result.split("\n")[0]);
                    result.should.be(samples.formData.expect.join(boundary));
                }).then(cast done, fail);
            });
        });
    }
}
