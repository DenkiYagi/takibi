package test;

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
        final body = new Response("");
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