package cloudflareworkers.emulator;

import buddy.BuddySuite;
import js.lib.Promise;
import js.node.Buffer;
using buddy.Should;
using cloudflareworkers.emulator.Request;

class RequestTest extends BuddySuite {
  public function new() {
    describe("Request.new()", {
      final dummyUrl = "https://example.com/";

      it("should return Request that has init properties", (done) -> {
        final testCases: Array<Dynamic> = [
          { init: null,                                                                                 expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },                                                                        throwError: false },
          { init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) },               expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "text/html; charset=UTF-8" ] ], method: "GET", redirect: "follow" },                         throwError: false },
          { init: { headers: { "content-type": "application/json", "Accept-Encoding": "deflate" } },    expect: { url: dummyUrl, body: null, headers: [ ["content-type", "application/json"], ["Accept-Encoding", "deflate"] ], method: "GET", redirect: "follow" },  throwError: false },
          { init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] },  expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "image/gif"], ["accept-encoding", "deflate, gzip"] ], method: "GET", redirect: "follow" },   throwError: false },
          { init: { redirect: "follow" },                                                               expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },                                                                        throwError: false },
          { init: { redirect: "error" },                                                                expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "error" },                                                                         throwError: false },
          { init: { redirect: "manual" },                                                               expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "manual" },                                                                        throwError: false },
          { init: { method: "GET" },                                                                    expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },                                                                        throwError: false },
          { init: { method: "HEAD" },                                                                   expect: { url: dummyUrl, body: null, headers: [], method: "HEAD", redirect: "follow" },                                                                       throwError: false },
          { init: { method: "POST" },                                                                   expect: { url: dummyUrl, body: null, headers: [], method: "POST", redirect: "follow" },                                                                       throwError: false },
          { init: { method: "PUT" },                                                                    expect: { url: dummyUrl, body: null, headers: [], method: "PUT", redirect: "follow" },                                                                        throwError: false },
          { init: { method: "DELETE" },                                                                 expect: { url: dummyUrl, body: null, headers: [], method: "DELETE", redirect: "follow" },                                                                     throwError: false },
          { init: { method: "CONNECT" },                                                                expect: { url: dummyUrl, body: null, headers: [], method: "CONNECT", redirect: "follow" },                                                                    throwError: false },
          { init: { method: "OPTIONS" },                                                                expect: { url: dummyUrl, body: null, headers: [], method: "OPTIONS", redirect: "follow" },                                                                    throwError: false },
          { init: { method: "PATCH" },                                                                  expect: { url: dummyUrl, body: null, headers: [], method: "PATCH", redirect: "follow" },                                                                      throwError: false },
          { init: { body: "NonNull" },                                                                  expect: {},                                                                                                                                                   throwError: true },
          { init: { method: "GET", body: "NonNull" },                                                   expect: {},                                                                                                                                                   throwError: true },
          { init: { method: "HEAD", body: "NonNull" },                                                  expect: {},                                                                                                                                                   throwError: true },
          { init: { method: "POST", body: "NonNull" },                                                  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "POST", redirect: "follow" },                                                                  throwError: false },
          { init: { method: "PUT", body: "NonNull" },                                                   expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PUT", redirect: "follow" },                                                                   throwError: false },
          { init: { method: "DELETE", body: "NonNull" },                                                expect: { url: dummyUrl, body: "NonNull", headers: [], method: "DELETE", redirect: "follow" },                                                                throwError: false },
          { init: { method: "CONNECT", body: "NonNull" },                                               expect: { url: dummyUrl, body: "NonNull", headers: [], method: "CONNECT", redirect: "follow" },                                                               throwError: false },
          { init: { method: "OPTIONS", body: "NonNull" },                                               expect: { url: dummyUrl, body: "NonNull", headers: [], method: "OPTIONS", redirect: "follow" },                                                               throwError: false },
          { init: { method: "PATCH", body: "NonNull" },                                                 expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PATCH", redirect: "follow" },                                                                 throwError: false },
        ];

        Promise.all(testCases.map(testCase -> new Promise((resolve, reject) -> {
          if (testCase.throwError) {
            (() -> new Request(dummyUrl, testCase.init)).should.throwAnything();
            resolve(null);
          } else {
            final req = new Request(dummyUrl, testCase.init);
            req.url.should.be(testCase.expect.url);
            req.method.should.be(testCase.expect.method);
            req.redirect.should.be(testCase.expect.redirect);

            testCase.expect.headers.forEach(headerPair -> {
              req.headers.get(headerPair[0]).should.be(headerPair[1]);
            });

            if (testCase.expect.body == null) {
              req.body.should.be(null);
              resolve(null);
            } else {
              var resultText = "";
              final _body = cast(req.body, ReadableStream);
              final reader = _body._raw.getReader();
              function push() {
                reader.read().then(result -> {
                  if (result.done) {
                    resultText.should.be(testCase.expect.body);
                    resolve(null);
                  } else {
                    resultText += Buffer.from(result.value).toString();
                    push();
                  }
                }, reject);
              }
              push();
            }
          }
        }))).then(cast done, fail);
      });

      it("should return Request that has method", {
        final testCases = [
          { inputMethod: null,      initMethod: null,       expectMethod: "GET" },
          { inputMethod: "GET",     initMethod: null,       expectMethod: "GET" },
          { inputMethod: "HEAD",    initMethod: null,       expectMethod: "HEAD" },
          { inputMethod: "POST",    initMethod: null,       expectMethod: "POST" },
          { inputMethod: "PUT",     initMethod: null,       expectMethod: "PUT" },
          { inputMethod: "DELETE",  initMethod: null,       expectMethod: "DELETE" },
          { inputMethod: "CONNECT", initMethod: null,       expectMethod: "CONNECT" },
          { inputMethod: "OPTIONS", initMethod: null,       expectMethod: "OPTIONS" },
          { inputMethod: "PATCH",   initMethod: null,       expectMethod: "PATCH" },
          { inputMethod: "GET",     initMethod: "GET",      expectMethod: "GET" },
          { inputMethod: "GET",     initMethod: "HEAD",     expectMethod: "HEAD" },
          { inputMethod: "GET",     initMethod: "POST",     expectMethod: "POST" },
          { inputMethod: "GET",     initMethod: "PUT",      expectMethod: "PUT" },
          { inputMethod: "GET",     initMethod: "DELETE",   expectMethod: "DELETE" },
          { inputMethod: "GET",     initMethod: "CONNECT",  expectMethod: "CONNECT" },
          { inputMethod: "GET",     initMethod: "OPTIONS",  expectMethod: "OPTIONS" },
          { inputMethod: "GET",     initMethod: "PATCH",    expectMethod: "PATCH" },
        ];

        for (testCase in testCases) {
          final req = new Request(
            (testCase.inputMethod == null) ? dummyUrl : new Request(dummyUrl, cast({ method: testCase.inputMethod })),
            (testCase.initMethod == null) ? null : cast({ method: testCase.initMethod })
          );
          req.method.should.be(testCase.expectMethod);
        }
      });
    });

    describe("Request.clone()", {
      it("should same", {
        final source = new Request("", {method: POST, body: ""});
        final destination = source.clone();

        (source.body == destination.body).should.be(true);
      });
    });
  }
}