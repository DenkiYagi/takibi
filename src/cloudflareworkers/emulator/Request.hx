package cloudflareworkers.emulator;

import haxe.DynamicAccess;
import haxe.extern.EitherType;
import js.lib.ArrayBuffer;
import js.lib.Promise;
import js.node.stream.Readable;
import js.node.util.TextEncoder;
import js.npm.webstreams_polyfill.ReadableByteStreamController;
import js.npm.webstreams_polyfill.ReadableStream in WebReadableStream;
import js.npm.webstreams_polyfill.ReadableStream.UnderlyingByteSourceType;

class Request extends Body {
    /**
        An object that contains data provided by Cloudflare (see request.cf below).
    **/
    public var cf(default, null):Dynamic; //TODO: Request#cf

    /**
        Contain the associated Headers object for the request.
    **/
    public var headers(default, null):Headers;

    /**
        The request method, such as GET or POST, associated with the request.
    **/
    public var method(default, null):RequestMethod;

    /**
        The redirect mode to use: follow or manual.
    **/
    public var redirect(default, null):RequestRedirect;

    /**
        Contains the URL of the request.
    **/
    public var url(default, null):String;

    public function new(input:EitherType<String, Request>, ?init:EitherType<RequestInit, Request>) {
        final _init = toRequestInit(init);

        if (Std.is(input, String)) {
            url = input;
            method = (_init.method != null) ? _init.method : GET;
            headers = new Headers(_init.headers);
            redirect = (_init.redirect != null) ? _init.redirect : Follow;
            super(toReadableStream(method, _init.body));
        } else {
            final _input:Request = input;
            url = _input.url;
            method = (_init.method != null) ? _init.method : _input.method;
            headers = new Headers((_init.headers != null) ? _init.headers : _input.headers);
            redirect = (_init.redirect != null) ? _init.redirect : _input.redirect;
            super(toReadableStream(method, (_init.body != null) ? _init.body : cast _input.body));
        }
    }

    inline extern function toRequestInit(?init:EitherType<RequestInit, Request>):RequestInit {
        return if (init == null) {
            {};
        } else if (Std.is(init, Request)) {
            init;
        } else {
            init;
        }
    }

    function toReadableStream(method:RequestMethod, body:Null<EitherType<String, ReadableStream>>):Null<ReadableStream> {
        return switch (method) {
            case GET | HEAD:
                null;
            case _ if (Std.is(body, ReadableStream)):
                (body : ReadableStream);
            case _ if (Std.is(body, String)):
                new ReadableStream(new WebReadableStream({
                    type: Bytes,
                    start: (controller:ReadableByteStreamController) -> {
                        controller.enqueue(new TextEncoder().encode(body));
                        controller.close();
                    }
                }));
            case _:
                null;
        }
    }

    /**
        Creates a copy of the current Request object.
    **/
    public function clone():Request {
        return new Request(this);
    }
}

typedef RequestInit = {
    /**
        The request method, such as GET or POST
    **/
    var ?method:RequestMethod;

    /**
        A Headers object
    **/
    var ?headers:EitherType<Headers, EitherType<Array<Array<String>>, DynamicAccess<String>>>;

    /**
        Any text to add to the request. Note: Requests using the GET or HEAD methods cannot have a body.
    **/
    var ?body:EitherType<String, ReadableStream>;

    /**
        The mode respected when the request is fetched.
        Note: default for requests generated from the incoming fetchEvent from the event handler is manual.
    **/
    var ?redirect:RequestRedirect;

    var ?cf:Dynamic;
}

enum abstract RequestMethod(String) to String {
    var GET;
    var HEAD;
    var POST;
    var PUT;
    var DELETE;
    var OPTIONS;
    var PATCH;
}

enum abstract RequestRedirect(String) {
    var Follow = cast js.html.RequestRedirect.FOLLOW;
    var Manual = cast js.html.RequestRedirect.MANUAL;
}