package cloudflareworkers.emulator;

import js.lib.HaxeIterator;
import buddy.BuddySuite;
using buddy.Should;
using cloudflareworkers.emulator.Body;
using cloudflareworkers.emulator.Response;
using cloudflareworkers.emulator.FormData;
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
            it("should return Promise has source FormData", done -> {
                final sampleFormData = new FormData();
                sampleFormData.append('key', 'value');
                final testCases:Array<Dynamic> = [
                    { body: sampleFormData, throwError: false },
                    { body: null, throwError: true },
                    { body: "invalid form data", throwError: true }
                ];

                Promise.all(testCases.map(testCase -> {
                    if (testCase.throwError) {
                        return new Response(testCase.body).json().then(fail, cast (() -> {}));
                    }
                    return new Response(testCase.body).formData().then(formData -> {
                        for (kv in new HaxeIterator(formData.entries())) {
                            (kv.value == sampleFormData.get(kv.key)).should.be(true);
                        }
                    });
                })).then(cast done, fail);
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
