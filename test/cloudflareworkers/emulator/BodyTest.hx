package cloudflareworkers.emulator;

import js.html.TextEncoder;
import haxe.Json;
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
            it("should return Promise has expected objects", done -> {
                final someObject = {
                    key: "value",
                    number: 0,
                    bool: true
                };
                final json = Json.stringify(someObject);
                final testCases:Array<Dynamic> = [
                    { body: null, throwError: true },
                    { body: json, throwError: false },
                    { body: new TextEncoder().encode(json), throwError: false },
                    { body: "Invalid JSON", throwError: true },
                ];

                Promise.all(testCases.map(testCase -> {
                    if (testCase.throwError) {
                        return new Response(testCase.body).json().then(fail, cast (() -> {}));
                    }
                    return new Response(testCase.body).json().then(json -> {
                        (json.key == someObject.key).should.be(true);
                        (json.number == someObject.number).should.be(true);
                        (json.bool == someObject.bool).should.be(true);
                    });
                })).then(cast done, fail);
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
