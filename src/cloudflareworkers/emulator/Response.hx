package cloudflareworkers.emulator;

import cloudflareworkers.emulator.Body.BodySource;
import cloudflareworkers.emulator.ReadableStream.ReadableStreamDefaultReader;
import haxe.extern.EitherType;
import js.Syntax;
import js.lib.ArrayBuffer;
import js.lib.BufferSource;
import js.lib.Uint8Array;
import js.node.url.URLSearchParams;
import js.npm.webstreams_polyfill.ReadableStream in WebReadableStream;
import js.npm.webstreams_polyfill.ReadableStreamDefaultController;

@:keep
class Response extends Body {
    public var status(default, null):Int;
    public var statusText(default, null):String;
    public var headers(default, null):Headers;
    public var ok(default, null):Bool;
    public var redirected(default, null):Bool;
    public var url(default, null):String;
    //public var webSocket(default, null);

    public function new(?body:BodySource, ?init:ResponseInit) {
        if (init != null) {
            status = (init.status != null) ? init.status : 200;
            statusText = ((cast init).hasOwnProperty("statusText"))
                ? "" + init.statusText
                : Response.getDefaultStatusText(status);
            headers = new Headers(init.headers);
        } else {
            status = 200;
            statusText = Response.getDefaultStatusText(status);
            headers = new Headers();
        }
        url = "";
        redirected = false;
        ok = (200 <= status) && (status < 300);

        if (status < 200 || 600 <= status) {
            throw new js.lib.Error.RangeError("Responses may only be constructed with status codes in the range 200 to 599, inclusive.");
        }

        // final stream = if (Syntax.instanceof(body, ArrayBuffer)) {
        //     new ReadableStream(new WebReadableStream({
        //         start: (ctrl:ReadableStreamDefaultController<Uint8Array>) -> {
        //             ctrl.enqueue(new Uint8Array((body : ArrayBuffer)));
        //             ctrl.close();
        //         }
        //     }));
        // } else if (Syntax.instanceof(body, FormData)) {
        //     (body : FormData);
        //     null;
        // } else if (Syntax.instanceof(body, ReadableStream)) {
        //     (body : ReadableStream);
        // } else if (Syntax.instanceof(body, URLSearchParams)) {
        //     null;

        // } else if (Syntax.instanceof(body, String)) {
        //     null;

        // } else {
        //     null;
        // }
        super(body);
    }

    public function redirect() {}
    public function clone() {}

    private static function getDefaultStatusText(status: Int): String {
        return switch (status) {
            case 200: "OK";
            case 201: "Created";
            case 202: "Accepted";
            case 203: "Non-Authoritative Information";
            case 204: "No Content";
            case 205: "Reset Content";
            case 206: "Partial Content";
            case 207: "Multi-Status";
            case 208: "Already Reported";
            case 226: "IM Used";
            case 300: "Multiple Choices";
            case 301: "Moved Permanently";
            case 302: "Found";
            case 303: "See Other";
            case 304: "Not Modified";
            case 305: "Use Proxy";
            case 307: "Temporary Redirect";
            case 308: "Permanent Redirect";
            case 400: "Bad Request";
            case 401: "Unauthorized";
            case 402: "Payment Required";
            case 403: "Forbidden";
            case 404: "Not Found";
            case 405: "Method Not Allowed";
            case 406: "Not Acceptable";
            case 407: "Proxy Authentication Required";
            case 408: "Request Timeout";
            case 409: "Conflict";
            case 410: "Gone";
            case 411: "Length Required";
            case 412: "Precondition Failed";
            case 413: "Payload Too Large";
            case 414: "URI Too Long";
            case 415: "Unsupported Media Type";
            case 416: "Range Not Satisfiable";
            case 417: "Expectation Failed";
            case 418: "I'm a teapot";
            case 421: "Misdirected Request";
            case 422: "Unprocessable Entity";
            case 423: "Locked";
            case 424: "Failed Dependency";
            case 426: "Upgrade Required";
            case 428: "Precondition Required";
            case 429: "Too Many Requests";
            case 431: "Request Header Fields Too Large";
            case 451: "Unavailable For Legal Reasons";
            case 500: "Internal Server Error";
            case 501: "Not Implemented";
            case 502: "Bad Gateway";
            case 503: "Service Unavailable";
            case 504: "Gateway Timeout";
            case 505: "HTTP Version Not Supported";
            case 506: "Variant Also Negotiates";
            case 507: "Insufficient Storage";
            case 508: "Loop Detected";
            case 510: "Not Extended";
            case 511: "Network Authentication Required";
            case s if (200 <= s && s < 300): "Successful";
            case s if (300 <= s && s < 400): "Redirection";
            case s if (400 <= s && s < 500): "Client Error";
            case s if (500 <= s && s < 600): "Server Error";
            case _: "";
        }
    }
}

typedef ResponseInit = {
    /**
        The status code for the reponse, such as 200.
    **/
    var ?status:Int;

    /**
        The status message associated with the status code, like, OK.
    **/
    var ?statusText:String;

    /**
        Any headers to add to your response that are contained within a Headers object or object literal of ByteString key/value pairs.
    **/
    var ?headers:EitherType<Headers, EitherType<KeyValue<String, String>, haxe.DynamicAccess<String>>>;
}