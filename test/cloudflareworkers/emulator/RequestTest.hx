package cloudflareworkers.emulator;

import buddy.BuddySuite;
import js.lib.Promise;
import js.node.Buffer;
using buddy.Should;
using cloudflareworkers.emulator.Request;

class RequestTest extends BuddySuite {
  static function bodyToString(body: ReadableStream): Promise<String> {
    return new Promise((resolve, reject) -> {
      var resultText = "";
      final reader = body._raw.getReader();
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
    final dummyUrl = "https://google.com/";
    final dummyUrlSub = "https://google.co.jp";

    describe("Request.new()", {
      it("should return Request that has default properties (new Request(string))", {
        final expect = { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" };
        final request = new Request(dummyUrl);

        request.url.should.be(expect.url);
        request.method.should.be(expect.method);
        request.redirect.should.be(expect.redirect);
        request.body.should.be(expect.body);
        request.headers.entries().next().done.should.be(true);
      });

      it("should return Request that has expected properties (new Request(string, init))", (done) -> {
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
              RequestTest.bodyToString(cast req.body).then(bodyText -> {
                bodyText.should.be(testCase.expect.body);
                resolve(null);
              }, reject);
            }
          }
        }))).then(cast done, fail);
      });

      it("should return Request that has expected properties (new Request(string, request))", (done) -> {
        final testCases: Array<Dynamic> = [
          { request: { input: dummyUrlSub, init: null},                                                                                 expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },                                                                        throwError: false },
          { request: { input: dummyUrlSub, init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) } },              expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "text/html; charset=UTF-8" ] ], method: "GET", redirect: "follow" },                         throwError: false },
          { request: { input: dummyUrlSub, init: { headers: { "content-type": "application/json", "Accept-Encoding": "deflate" } } },   expect: { url: dummyUrl, body: null, headers: [ ["content-type", "application/json"], ["Accept-Encoding", "deflate"] ], method: "GET", redirect: "follow" },  throwError: false },
          { request: { input: dummyUrlSub, init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] } }, expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "image/gif"], ["accept-encoding", "deflate, gzip"] ], method: "GET", redirect: "follow" },   throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "follow" } },                                                              expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },                                                                        throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "error" } },                                                               expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "error" },                                                                         throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "manual" } },                                                              expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "manual" },                                                                        throwError: false },
          { request: { input: dummyUrlSub, init: { method: "GET" } },                                                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },                                                                        throwError: false },
          { request: { input: dummyUrlSub, init: { method: "HEAD" } },                                                                  expect: { url: dummyUrl, body: null, headers: [], method: "HEAD", redirect: "follow" },                                                                       throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST" } },                                                                  expect: { url: dummyUrl, body: null, headers: [], method: "POST", redirect: "follow" },                                                                       throwError: false },
          { request: { input: dummyUrlSub, init: { method: "PUT" } },                                                                   expect: { url: dummyUrl, body: null, headers: [], method: "PUT", redirect: "follow" },                                                                        throwError: false },
          { request: { input: dummyUrlSub, init: { method: "DELETE" } },                                                                expect: { url: dummyUrl, body: null, headers: [], method: "DELETE", redirect: "follow" },                                                                     throwError: false },
          { request: { input: dummyUrlSub, init: { method: "CONNECT" } },                                                               expect: { url: dummyUrl, body: null, headers: [], method: "CONNECT", redirect: "follow" },                                                                    throwError: false },
          { request: { input: dummyUrlSub, init: { method: "OPTIONS" } },                                                               expect: { url: dummyUrl, body: null, headers: [], method: "OPTIONS", redirect: "follow" },                                                                    throwError: false },
          { request: { input: dummyUrlSub, init: { method: "PATCH" } },                                                                 expect: { url: dummyUrl, body: null, headers: [], method: "PATCH", redirect: "follow" },                                                                      throwError: false },
          { request: { input: dummyUrlSub, init: { body: "NonNull" } },                                                                 expect: {},                                                                                                                                                   throwError: true },
          { request: { input: dummyUrlSub, init: { method: "GET", body: "NonNull" } },                                                  expect: {},                                                                                                                                                   throwError: true },
          { request: { input: dummyUrlSub, init: { method: "HEAD", body: "NonNull" } },                                                 expect: {},                                                                                                                                                   throwError: true },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },                                                 expect: { url: dummyUrl, body: "NonNull", headers: [], method: "POST", redirect: "follow" },                                                                  throwError: false },
          { request: { input: dummyUrlSub, init: { method: "PUT", body: "NonNull" } },                                                  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PUT", redirect: "follow" },                                                                   throwError: false },
          { request: { input: dummyUrlSub, init: { method: "DELETE", body: "NonNull" } },                                               expect: { url: dummyUrl, body: "NonNull", headers: [], method: "DELETE", redirect: "follow" },                                                                throwError: false },
          { request: { input: dummyUrlSub, init: { method: "CONNECT", body: "NonNull" } },                                              expect: { url: dummyUrl, body: "NonNull", headers: [], method: "CONNECT", redirect: "follow" },                                                               throwError: false },
          { request: { input: dummyUrlSub, init: { method: "OPTIONS", body: "NonNull" } },                                              expect: { url: dummyUrl, body: "NonNull", headers: [], method: "OPTIONS", redirect: "follow" },                                                               throwError: false },
          { request: { input: dummyUrlSub, init: { method: "PATCH", body: "NonNull" } },                                                expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PATCH", redirect: "follow" },                                                                 throwError: false },
        ];

        Promise.all(testCases.map(testCase -> new Promise((resolve, reject) -> {
          if (testCase.throwError) {
            (() -> new Request(dummyUrl, new Request(testCase.request.input, testCase.request.init))).should.throwAnything();
            resolve(null);
          } else {
            final req = new Request(dummyUrl, new Request(testCase.request.input, testCase.request.init));
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
              RequestTest.bodyToString(cast req.body).then(bodyText -> {
                bodyText.should.be(testCase.expect.body);
                resolve(null);
              }, reject);
            }
          }
        }))).then(cast done, fail);
      });

      it("should return Request that has source requests properties (new Request(request))", (done) -> {
        final testCases: Array<Dynamic> = [
          { request: { input: dummyUrl, init: null } },
          { request: { input: dummyUrl, init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) } } },
          { request: { input: dummyUrl, init: { headers: { "content-type": "application/json", "Accept-Encoding": "deflate" } } } },
          { request: { input: dummyUrl, init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] } } },
          { request: { input: dummyUrl, init: { redirect: "follow" } } },
          { request: { input: dummyUrl, init: { redirect: "error" } } },
          { request: { input: dummyUrl, init: { redirect: "manual" } } },
          { request: { input: dummyUrl, init: { method: "GET" } } },
          { request: { input: dummyUrl, init: { method: "HEAD" } } },
          { request: { input: dummyUrl, init: { method: "POST" } } },
          { request: { input: dummyUrl, init: { method: "PUT" } } },
          { request: { input: dummyUrl, init: { method: "DELETE" } } },
          { request: { input: dummyUrl, init: { method: "CONNECT" } } },
          { request: { input: dummyUrl, init: { method: "OPTIONS" } } },
          { request: { input: dummyUrl, init: { method: "PATCH" } } },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } } },
          { request: { input: dummyUrl, init: { method: "PUT", body: "NonNull" } } },
          { request: { input: dummyUrl, init: { method: "DELETE", body: "NonNull" } } },
          { request: { input: dummyUrl, init: { method: "CONNECT", body: "NonNull" } } },
          { request: { input: dummyUrl, init: { method: "OPTIONS", body: "NonNull" } } },
          { request: { input: dummyUrl, init: { method: "PATCH", body: "NonNull" } } },
        ];

        Promise.all(testCases.map(testCase -> new Promise((resolve, reject) -> {
          final source = new Request(testCase.request.input, testCase.request.init);
          final dest = new Request(source);
          dest.url.should.be(source.url);
          dest.method.should.be(source.method);
          dest.redirect.should.be(source.redirect);

          var itr = source.headers.entries();
          var result = itr.next();
          while (!result.done) {
            dest.headers.get(result.value[0]).should.be(result.value[1]);
            result = itr.next();
          }

          if (source.body == null) {
            dest.body.should.be(null);
            resolve(null);
          } else {
            (cast ((cast source.body).locked, Bool)).should.be(true);
            RequestTest.bodyToString(cast dest.body).then(bodyText -> {
              bodyText.should.be((cast testCase.request.init).body);
              resolve(null);
            }, reject);
          }
        }))).then(cast done, fail);
      });

      it("should return Request that has expected properties (new Request(request, init))", (done) -> {
        final testCases: Array<Dynamic> = [
          { request: { input: dummyUrl, init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) } },              init: null,  expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "text/html; charset=UTF-8" ] ], method: "GET", redirect: "follow" },                         throwError: false },
          { request: { input: dummyUrl, init: { headers: { "content-type": "application/json", "Accept-Encoding": "deflate" } } },   init: null,  expect: { url: dummyUrl, body: null, headers: [ ["content-type", "application/json"], ["Accept-Encoding", "deflate"] ], method: "GET", redirect: "follow" },  throwError: false },
          { request: { input: dummyUrl, init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] } }, init: null,  expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "image/gif"], ["accept-encoding", "deflate, gzip"] ], method: "GET", redirect: "follow" },   throwError: false },
          { request: { input: dummyUrl, init: { redirect: "follow" } },                                                              init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },                                                                        throwError: false },
          { request: { input: dummyUrl, init: { redirect: "error" } },                                                               init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "error" },                                                                         throwError: false },
          { request: { input: dummyUrl, init: { redirect: "manual" } },                                                              init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "manual" },                                                                        throwError: false },
          { request: { input: dummyUrl, init: { method: "GET" } },                                                                   init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },                                                                        throwError: false },
          { request: { input: dummyUrl, init: { method: "HEAD" } },                                                                  init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "HEAD", redirect: "follow" },                                                                       throwError: false },
          { request: { input: dummyUrl, init: { method: "POST" } },                                                                  init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "POST", redirect: "follow" },                                                                       throwError: false },
          { request: { input: dummyUrl, init: { method: "PUT" } },                                                                   init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "PUT", redirect: "follow" },                                                                        throwError: false },
          { request: { input: dummyUrl, init: { method: "DELETE" } },                                                                init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "DELETE", redirect: "follow" },                                                                     throwError: false },
          { request: { input: dummyUrl, init: { method: "CONNECT" } },                                                               init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "CONNECT", redirect: "follow" },                                                                    throwError: false },
          { request: { input: dummyUrl, init: { method: "OPTIONS" } },                                                               init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "OPTIONS", redirect: "follow" },                                                                    throwError: false },
          { request: { input: dummyUrl, init: { method: "PATCH" } },                                                                 init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "PATCH", redirect: "follow" },                                                                      throwError: false },
          { request: { input: dummyUrl, init: { body: "NonNull" } },                                                                 init: null,  expect: {},                                                                                                                                                   throwError: true },
          { request: { input: dummyUrl, init: { method: "GET", body: "NonNull" } },                                                  init: null,  expect: {},                                                                                                                                                   throwError: true },
          { request: { input: dummyUrl, init: { method: "HEAD", body: "NonNull" } },                                                 init: null,  expect: {},                                                                                                                                                   throwError: true },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } },                                                 init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "POST", redirect: "follow" },                                                                  throwError: false },
          { request: { input: dummyUrl, init: { method: "PUT", body: "NonNull" } },                                                  init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PUT", redirect: "follow" },                                                                   throwError: false },
          { request: { input: dummyUrl, init: { method: "DELETE", body: "NonNull" } },                                               init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "DELETE", redirect: "follow" },                                                                throwError: false },
          { request: { input: dummyUrl, init: { method: "CONNECT", body: "NonNull" } },                                              init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "CONNECT", redirect: "follow" },                                                               throwError: false },
          { request: { input: dummyUrl, init: { method: "OPTIONS", body: "NonNull" } },                                              init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "OPTIONS", redirect: "follow" },                                                               throwError: false },
          { request: { input: dummyUrl, init: { method: "PATCH", body: "NonNull" } },                                                init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PATCH", redirect: "follow" },                                                                 throwError: false },
          { request: { input: dummyUrl, init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] } }, init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) },               expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "text/html; charset=UTF-8" ] ], method: "GET", redirect: "follow" },                         throwError: false },
          { request: { input: dummyUrl, init: { headers: { "content-type": "text/plain", "Accept-Encoding": "deflate" } } },         init: { headers: { "content-type": "application/json", "Accept-Encoding": "deflate" } },    expect: { url: dummyUrl, body: null, headers: [ ["content-type", "application/json"], ["Accept-Encoding", "deflate"] ], method: "GET", redirect: "follow" },  throwError: false },
          { request: { input: dummyUrl, init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) } },              init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] },  expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "image/gif"], ["accept-encoding", "deflate, gzip"] ], method: "GET", redirect: "follow" },   throwError: false },
          { request: { input: dummyUrl, init: { redirect: "follow" } },  init: { redirect: "follow" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrl, init: { redirect: "follow" } },  init: { redirect: "error" },                                    expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "error" },             throwError: false },
          { request: { input: dummyUrl, init: { redirect: "follow" } },  init: { redirect: "manual" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "manual" },            throwError: false },
          { request: { input: dummyUrl, init: { redirect: "error" } },   init: { redirect: "follow" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrl, init: { redirect: "error" } },   init: { redirect: "error" },                                    expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "error" },             throwError: false },
          { request: { input: dummyUrl, init: { redirect: "error" } },   init: { redirect: "manual" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "manual" },            throwError: false },
          { request: { input: dummyUrl, init: { redirect: "manual" } },  init: { redirect: "follow" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrl, init: { redirect: "manual" } },  init: { redirect: "error" },                                    expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "error" },             throwError: false },
          { request: { input: dummyUrl, init: { redirect: "manual" } },  init: { redirect: "manual" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "manual" },            throwError: false },
          { request: { input: dummyUrl, init: { method: "PATCH" } },     init: { method: "GET" },                                        expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrl, init: { method: "GET" } },       init: { method: "HEAD" },                                       expect: { url: dummyUrl, body: null, headers: [], method: "HEAD", redirect: "follow" },           throwError: false },
          { request: { input: dummyUrl, init: { method: "HEAD" } },      init: { method: "POST" },                                       expect: { url: dummyUrl, body: null, headers: [], method: "POST", redirect: "follow" },           throwError: false },
          { request: { input: dummyUrl, init: { method: "POST" } },      init: { method: "PUT" },                                        expect: { url: dummyUrl, body: null, headers: [], method: "PUT", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrl, init: { method: "PUT" } },       init: { method: "DELETE" },                                     expect: { url: dummyUrl, body: null, headers: [], method: "DELETE", redirect: "follow" },         throwError: false },
          { request: { input: dummyUrl, init: { method: "DELETE" } },    init: { method: "CONNECT" },                                    expect: { url: dummyUrl, body: null, headers: [], method: "CONNECT", redirect: "follow" },        throwError: false },
          { request: { input: dummyUrl, init: { method: "CONNECT" } },   init: { method: "OPTIONS" },                                    expect: { url: dummyUrl, body: null, headers: [], method: "OPTIONS", redirect: "follow" },        throwError: false },
          { request: { input: dummyUrl, init: { method: "OPTIONS" } },   init: { method: "PATCH" },                                      expect: { url: dummyUrl, body: null, headers: [], method: "PATCH", redirect: "follow" },          throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } },     init: { method: "GET" },                        expect: {},                                                                                       throwError: true },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } },     init: { method: "HEAD" },                       expect: {},                                                                                       throwError: true },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } },     init: { method: "POST" },                       expect: { url: dummyUrl, body: "NonNull", headers: [], method: "POST", redirect: "follow" },      throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } },     init: { method: "PUT" },                        expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PUT", redirect: "follow" },       throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } },     init: { method: "DELETE" },                     expect: { url: dummyUrl, body: "NonNull", headers: [], method: "DELETE", redirect: "follow" },    throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } },     init: { method: "CONNECT" },                    expect: { url: dummyUrl, body: "NonNull", headers: [], method: "CONNECT", redirect: "follow" },   throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } },     init: { method: "OPTIONS" },                    expect: { url: dummyUrl, body: "NonNull", headers: [], method: "OPTIONS", redirect: "follow" },   throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } },     init: { method: "PATCH" },                      expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PATCH", redirect: "follow" },     throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull1" } },    init: { body: "NonNull2" },                     expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "POST", redirect: "follow" },     throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull1" } },    init: { method: "GET", body: "NonNull2" },      expect: {},                                                                                       throwError: true },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull1" } },    init: { method: "HEAD", body: "NonNull2" },     expect: {},                                                                                       throwError: true },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull1" } },    init: { method: "POST", body: "NonNull2" },     expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "POST", redirect: "follow" },     throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull1" } },    init: { method: "PUT", body: "NonNull2" },      expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "PUT", redirect: "follow" },      throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull1" } },    init: { method: "DELETE", body: "NonNull2" },   expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "DELETE", redirect: "follow" },   throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull1" } },    init: { method: "CONNECT", body: "NonNull2" },  expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "CONNECT", redirect: "follow" },  throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull1" } },    init: { method: "OPTIONS", body: "NonNull2" },  expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "OPTIONS", redirect: "follow" },  throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } },     init: { method: "GET", body: null },            expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrl, init: { method: "POST", body: "NonNull" } },     init: { method: "HEAD", body: null },           expect: { url: dummyUrl, body: null, headers: [], method: "HEAD", redirect: "follow" },           throwError: false },
        ];

        Promise.all(testCases.map(testCase -> new Promise((resolve, reject) -> {
          if (testCase.throwError) {
            (() -> new Request(
              new Request(testCase.request.input, testCase.request.init),
              testCase.init
            )).should.throwAnything();
            resolve(null);
          } else {
            final req = new Request(
              new Request(testCase.request.input, testCase.request.init),
              testCase.init
            );
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
              RequestTest.bodyToString(cast req.body).then(bodyText -> {
                bodyText.should.be(testCase.expect.body);
                resolve(null);
              }, reject);
            }
          }
        }))).then(cast done, fail);
      });

      it("should return Request that has expected properties (new Request(string, new Request(request, init)))", (done) -> {
        final testCases: Array<Dynamic> = [
          { request: { input: dummyUrlSub, init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) } },              init: null,  expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "text/html; charset=UTF-8" ] ], method: "GET", redirect: "follow" },                         throwError: false },
          { request: { input: dummyUrlSub, init: { headers: { "content-type": "application/json", "Accept-Encoding": "deflate" } } },   init: null,  expect: { url: dummyUrl, body: null, headers: [ ["content-type", "application/json"], ["Accept-Encoding", "deflate"] ], method: "GET", redirect: "follow" },  throwError: false },
          { request: { input: dummyUrlSub, init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] } }, init: null,  expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "image/gif"], ["accept-encoding", "deflate, gzip"] ], method: "GET", redirect: "follow" },   throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "follow" } },                                                              init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },                                                                        throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "error" } },                                                               init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "error" },                                                                         throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "manual" } },                                                              init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "manual" },                                                                        throwError: false },
          { request: { input: dummyUrlSub, init: { method: "GET" } },                                                                   init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },                                                                        throwError: false },
          { request: { input: dummyUrlSub, init: { method: "HEAD" } },                                                                  init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "HEAD", redirect: "follow" },                                                                       throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST" } },                                                                  init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "POST", redirect: "follow" },                                                                       throwError: false },
          { request: { input: dummyUrlSub, init: { method: "PUT" } },                                                                   init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "PUT", redirect: "follow" },                                                                        throwError: false },
          { request: { input: dummyUrlSub, init: { method: "DELETE" } },                                                                init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "DELETE", redirect: "follow" },                                                                     throwError: false },
          { request: { input: dummyUrlSub, init: { method: "CONNECT" } },                                                               init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "CONNECT", redirect: "follow" },                                                                    throwError: false },
          { request: { input: dummyUrlSub, init: { method: "OPTIONS" } },                                                               init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "OPTIONS", redirect: "follow" },                                                                    throwError: false },
          { request: { input: dummyUrlSub, init: { method: "PATCH" } },                                                                 init: null,  expect: { url: dummyUrl, body: null, headers: [], method: "PATCH", redirect: "follow" },                                                                      throwError: false },
          { request: { input: dummyUrlSub, init: { body: "NonNull" } },                                                                 init: null,  expect: {},                                                                                                                                                   throwError: true },
          { request: { input: dummyUrlSub, init: { method: "GET", body: "NonNull" } },                                                  init: null,  expect: {},                                                                                                                                                   throwError: true },
          { request: { input: dummyUrlSub, init: { method: "HEAD", body: "NonNull" } },                                                 init: null,  expect: {},                                                                                                                                                   throwError: true },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },                                                 init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "POST", redirect: "follow" },                                                                  throwError: false },
          { request: { input: dummyUrlSub, init: { method: "PUT", body: "NonNull" } },                                                  init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PUT", redirect: "follow" },                                                                   throwError: false },
          { request: { input: dummyUrlSub, init: { method: "DELETE", body: "NonNull" } },                                               init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "DELETE", redirect: "follow" },                                                                throwError: false },
          { request: { input: dummyUrlSub, init: { method: "CONNECT", body: "NonNull" } },                                              init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "CONNECT", redirect: "follow" },                                                               throwError: false },
          { request: { input: dummyUrlSub, init: { method: "OPTIONS", body: "NonNull" } },                                              init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "OPTIONS", redirect: "follow" },                                                               throwError: false },
          { request: { input: dummyUrlSub, init: { method: "PATCH", body: "NonNull" } },                                                init: null,  expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PATCH", redirect: "follow" },                                                                 throwError: false },
          { request: { input: dummyUrlSub, init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] } }, init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) },               expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "text/html; charset=UTF-8" ] ], method: "GET", redirect: "follow" },                         throwError: false },
          { request: { input: dummyUrlSub, init: { headers: { "content-type": "text/plain", "Accept-Encoding": "deflate" } } },         init: { headers: { "content-type": "application/json", "Accept-Encoding": "deflate" } },    expect: { url: dummyUrl, body: null, headers: [ ["content-type", "application/json"], ["Accept-Encoding", "deflate"] ], method: "GET", redirect: "follow" },  throwError: false },
          { request: { input: dummyUrlSub, init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) } },              init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] },  expect: { url: dummyUrl, body: null, headers: [ ["Content-Type", "image/gif"], ["accept-encoding", "deflate, gzip"] ], method: "GET", redirect: "follow" },   throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "follow" } },  init: { redirect: "follow" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "follow" } },  init: { redirect: "error" },                                    expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "error" },             throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "follow" } },  init: { redirect: "manual" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "manual" },            throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "error" } },   init: { redirect: "follow" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "error" } },   init: { redirect: "error" },                                    expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "error" },             throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "error" } },   init: { redirect: "manual" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "manual" },            throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "manual" } },  init: { redirect: "follow" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "manual" } },  init: { redirect: "error" },                                    expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "error" },             throwError: false },
          { request: { input: dummyUrlSub, init: { redirect: "manual" } },  init: { redirect: "manual" },                                   expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "manual" },            throwError: false },
          { request: { input: dummyUrlSub, init: { method: "PATCH" } },     init: { method: "GET" },                                        expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrlSub, init: { method: "GET" } },       init: { method: "HEAD" },                                       expect: { url: dummyUrl, body: null, headers: [], method: "HEAD", redirect: "follow" },           throwError: false },
          { request: { input: dummyUrlSub, init: { method: "HEAD" } },      init: { method: "POST" },                                       expect: { url: dummyUrl, body: null, headers: [], method: "POST", redirect: "follow" },           throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST" } },      init: { method: "PUT" },                                        expect: { url: dummyUrl, body: null, headers: [], method: "PUT", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrlSub, init: { method: "PUT" } },       init: { method: "DELETE" },                                     expect: { url: dummyUrl, body: null, headers: [], method: "DELETE", redirect: "follow" },         throwError: false },
          { request: { input: dummyUrlSub, init: { method: "DELETE" } },    init: { method: "CONNECT" },                                    expect: { url: dummyUrl, body: null, headers: [], method: "CONNECT", redirect: "follow" },        throwError: false },
          { request: { input: dummyUrlSub, init: { method: "CONNECT" } },   init: { method: "OPTIONS" },                                    expect: { url: dummyUrl, body: null, headers: [], method: "OPTIONS", redirect: "follow" },        throwError: false },
          { request: { input: dummyUrlSub, init: { method: "OPTIONS" } },   init: { method: "PATCH" },                                      expect: { url: dummyUrl, body: null, headers: [], method: "PATCH", redirect: "follow" },          throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },     init: { method: "GET" },                        expect: {},                                                                                       throwError: true },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },     init: { method: "HEAD" },                       expect: {},                                                                                       throwError: true },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },     init: { method: "POST" },                       expect: { url: dummyUrl, body: "NonNull", headers: [], method: "POST", redirect: "follow" },      throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },     init: { method: "PUT" },                        expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PUT", redirect: "follow" },       throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },     init: { method: "DELETE" },                     expect: { url: dummyUrl, body: "NonNull", headers: [], method: "DELETE", redirect: "follow" },    throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },     init: { method: "CONNECT" },                    expect: { url: dummyUrl, body: "NonNull", headers: [], method: "CONNECT", redirect: "follow" },   throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },     init: { method: "OPTIONS" },                    expect: { url: dummyUrl, body: "NonNull", headers: [], method: "OPTIONS", redirect: "follow" },   throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },     init: { method: "PATCH" },                      expect: { url: dummyUrl, body: "NonNull", headers: [], method: "PATCH", redirect: "follow" },     throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull1" } },    init: { body: "NonNull2" },                     expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "POST", redirect: "follow" },     throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull1" } },    init: { method: "GET", body: "NonNull2" },      expect: {},                                                                                       throwError: true },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull1" } },    init: { method: "HEAD", body: "NonNull2" },     expect: {},                                                                                       throwError: true },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull1" } },    init: { method: "POST", body: "NonNull2" },     expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "POST", redirect: "follow" },     throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull1" } },    init: { method: "PUT", body: "NonNull2" },      expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "PUT", redirect: "follow" },      throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull1" } },    init: { method: "DELETE", body: "NonNull2" },   expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "DELETE", redirect: "follow" },   throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull1" } },    init: { method: "CONNECT", body: "NonNull2" },  expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "CONNECT", redirect: "follow" },  throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull1" } },    init: { method: "OPTIONS", body: "NonNull2" },  expect: { url: dummyUrl, body: "NonNull2", headers: [], method: "OPTIONS", redirect: "follow" },  throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },     init: { method: "GET", body: null },            expect: { url: dummyUrl, body: null, headers: [], method: "GET", redirect: "follow" },            throwError: false },
          { request: { input: dummyUrlSub, init: { method: "POST", body: "NonNull" } },     init: { method: "HEAD", body: null },           expect: { url: dummyUrl, body: null, headers: [], method: "HEAD", redirect: "follow" },           throwError: false },
        ];

        Promise.all(testCases.map(testCase -> new Promise((resolve, reject) -> {
          if (testCase.throwError) {
            (() -> new Request(
              dummyUrl,
              new Request(new Request(testCase.request.input, testCase.request.init), testCase.init)
            )).should.throwAnything();
            resolve(null);
          } else {
            final req = new Request(
              dummyUrl,
              new Request(new Request(testCase.request.input, testCase.request.init), testCase.init)
            );
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
              RequestTest.bodyToString(cast req.body).then(bodyText -> {
                bodyText.should.be(testCase.expect.body);
                resolve(null);
              }, reject);
            }
          }
        }))).then(cast done, fail);
      });
    });

    describe("Request.clone()", {
      it("should return Request that has same properties as source Request", (done) -> {
        final testCases: Array<Dynamic> = [
          { init: null },
          { init: { headers: new Headers({"Content-Type": "text/html; charset=UTF-8"}) } },
          { init: { headers: { "content-type": "application/json", "Accept-Encoding": "deflate" } } },
          { init: { headers: [ ["Content-Type","image/gif"], ["accept-encoding", "deflate, gzip"] ] } },
          { init: { redirect: "follow" } },
          { init: { redirect: "error" } },
          { init: { redirect: "manual" } },
          { init: { method: "GET" } },
          { init: { method: "HEAD" } },
          { init: { method: "POST" } },
          { init: { method: "PUT" } },
          { init: { method: "DELETE" } },
          { init: { method: "CONNECT" } },
          { init: { method: "OPTIONS" } },
          { init: { method: "PATCH" } },
          { init: { method: "POST", body: "NonNull" } },
          { init: { method: "PUT", body: "NonNull" } },
          { init: { method: "DELETE", body: "NonNull" } },
          { init: { method: "CONNECT", body: "NonNull" } },
          { init: { method: "OPTIONS", body: "NonNull" } },
          { init: { method: "PATCH", body: "NonNull" } },
        ];

        Promise.all(testCases.map(testCase -> new Promise((resolve, reject) -> {
          final source = new Request(dummyUrl, testCase.init);
          final dest = source.clone();
          dest.url.should.be(source.url);
          dest.method.should.be(source.method);
          dest.redirect.should.be(source.redirect);

          var itr = source.headers.entries();
          var result = itr.next();
          while (!result.done) {
            dest.headers.get(result.value[0]).should.be(result.value[1]);
            result = itr.next();
          }

          if (source.body == null) {
            dest.body.should.be(null);
            resolve(null);
          } else {
            Promise.all([
              RequestTest.bodyToString(cast source.body),
              RequestTest.bodyToString(cast dest.body)
            ]).then(results -> {
              results[0].should.be(results[1]);
              resolve(null);
            }, reject);
          }
        }))).then(cast done, fail);
      });
    });
  }
}