package takibi;

import js.lib.Promise;

class FetchEvent {
    final impl:FetchEventImpl;

    /**
        The type of event. Always = fetch.
    **/
    public final type:String;

    /**
        A Request Object that represents the request triggering FetchEvent.
    **/
    public final request:Request;

    @:allow(takibi)
    function new(request:Request, impl:FetchEventImpl) {
        this.impl = impl;
        this.type = "fetch";
        this.request = request;
    }

    /**
        Cause the script to “fail open” unhandled exceptions.
        Instead of returning a runtime error response, the runtime proxies the request to its destination.
        To prevent JavaScript errors from causing entire requests to fail on uncaught exceptions,
        `passThroughOnException` causes the Worker script to act as if the exception wasn’t there.
        This allows the script to yield control to your origin server.
    **/
    public function passThroughOnException():Void {
        impl.passThroughOnException();
    }

    /**
        Intercept the request and send a custom response.
        If no event handler calls `respondWith()` the runtime attempts to proxy the request to the origin as if no Worker script intercepted.
    **/
    public function respondWith(task:Promise<Response>):Void {
        impl.respondWith(task);
    }

    /**
        Extend the lifetime of the event.
        Use this method to notify the runtime to wait for tasks, such as streaming and caching,
        that run longer than the usual time it takes to send a response.
        This is good for handling logging and analytics to third-party services, where you don’t want to block the response.
    **/
    public function waitUntil(promise:Promise<Dynamic>):Void {
        impl.waitUntil(promise);
    }
}

@:allow(takibi.Runtime)
private typedef FetchEventImpl = {
    var passThroughOnException:() -> Void;
    var respondWith:(task:Promise<Response>) -> Void;
    var waitUntil:(promise:Promise<Dynamic>) -> Void;
}
