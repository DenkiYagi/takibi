package cloudflareworkers.emulator;

import buddy.BuddySuite;
using buddy.Should;
using cloudflareworkers.emulator.Response;

class ResponseTest extends BuddySuite {
  public function new() {
    describe("Response.new()", {
      it("should has 200 status", {
        final response = new Response();
        response.status.should.be(200);
        response.statusText.should.be("");
      });

      it("should has init status", {
        final init = { status: 500, statusText: "Internal Server Error" };
        final response = new Response("", init);
        response.status.should.be(init.status);
        response.statusText.should.be(init.statusText);
      });
    });
  }
}