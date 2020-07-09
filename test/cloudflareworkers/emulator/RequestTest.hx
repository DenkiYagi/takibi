package cloudflareworkers.emulator;

import buddy.BuddySuite;
using buddy.Should;
using cloudflareworkers.emulator.Request;

class RequestTest extends BuddySuite {
  public function new() {
    describe("Request.new()", {
      describe("string input", {  
        it("should has body", {
          final request = new Request("", { method: POST, body: "" });
          (request.body != null).should.be(true);
        });
  
        it("should has no body", {
          final request = new Request("");
          (request.body == null).should.be(true);
        });
      });

      describe("request input", {
        final getRequest = new Request("");
        final postRequest = new Request("", { method: POST, body: "" });

        it("should has body", {
          final request = new Request(postRequest);
          (request.body != null).should.be(true);
        });

        it("should has no body", {
          final request = new Request(getRequest);
          (request.body == null).should.be(true);
        });
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