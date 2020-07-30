package cloudflareworkers.emulator;

import buddy.BuddySuite;
using buddy.Should;
using cloudflareworkers.emulator.Response;

class ResponseTest extends BuddySuite {
    public function new() {
        describe("Response.new()", {
            it("should return Response that has default properties(new Response())", {
                final expect = { url: "", redirected: false, ok: true, status: 200, statusText: "OK", body: null };
                final responses: Array<Response> = [
                    new Response(),
                    new Response(null),
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

            it("should return Response that has expected properties(new Response(body))", {

            });

            it("should return Response that has expected properties(new Response(null, init))", {
                
            });

            it("should return Response that has expected properties(new Response(body, init))", {

            });
        });
    }
}