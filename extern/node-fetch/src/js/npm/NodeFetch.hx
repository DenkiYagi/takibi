package js.npm;

import haxe.DynamicAccess;
import haxe.extern.EitherType;
import js.lib.ArrayBuffer;
import js.lib.ArrayBufferView;
import js.lib.Promise;
import js.node.Buffer;
import js.node.stream.Readable;
import js.npm.FormData;

@:jsRequire("node-fetch")
extern class NodeFetch {
    @:selfCall
    @:overload(function(input:String, ?init:RequestInit):Promise<Response> {})
    static function fetch(input:Request, ?init:RequestInit):Promise<Response>;
}

@:jsRequire("node-fetch", "Request")
extern class Request {
    var method(default, null):String;
    var url(default, null):String;
    var headers(default, null):Headers;
    var redirect(default, null):RequestRedirect;
    var signal(default, null):AbortSignal;
    var body(default, null):IReadable;
    var bodyUsed(default, null):Bool;

    @:overload(function(input:String, ?init:RequestInit):Void {})
    function new(input:Request, ?init:RequestInit):Void;

    function clone():Request;
    function arrayBuffer():Promise<ArrayBuffer>;
    function blob():Promise<Blob>;
    function json():Promise<Dynamic>;
    function text():Promise<String>;
}

typedef RequestInit = {
    // These properties are part of the Fetch Standard
    var ?method:String;
    var ?headers:EitherType<Headers, DynamicAccess<String>>;
    var ?body:Null<BodySource>;
    var ?redirect:RequestRedirect;
    var ?signal:AbortSignal;

    // The following properties are node-fetch extensions
    var ?follow:Int;
    var ?timeout:Int;
    var ?compress:Bool;
    var ?size:Int;
    var ?agent:Dynamic;
}

@:jsRequire("node-fetch", "Headers")
extern class Headers {
    @:overload(function(?init:Array<Array<String>>):Headers {})
    @:overload(function(?init:DynamicAccess<String>):Headers {})
    function new(?init:Headers):Void;

    function append(name:String, value:String):Void;
    function delete(name:String):Void;
    function get(name:String):String;
    function has(name:String):Bool;
    function set(name:String, value:String):Void;
    // TODO: function entries():Iterator<js.lib.KeyValue>;
    function entries():js.lib.Iterator<Array<String>>;
    function keys():js.lib.Iterator<String>;
    function values():js.lib.Iterator<String>;
    function forEach(callback:EitherType<(value:String) -> Void, (value:String, name:String) -> Void>, ?thisArg:Dynamic):Void;
}

@:jsRequire("node-fetch", "Response")
extern class Response {
    var url(default, null):String;
    var status(default, null):Int;
    var ok(default, null):Bool;
    var redirected(default, null):Bool;
    var statusText(default, null):String;
    var headers(default, null):Headers;
    var body(default, null):IReadable;
    var bodyUsed(default, null):Bool;

    function new(?body:BodySource, ?init:ResponseInit):Void;

    function clone():Response;
    function arrayBuffer():Promise<js.lib.ArrayBuffer>;
    function blob():Promise<Blob>;
    function json():Promise<Dynamic>;
    function text():Promise<String>;
}

typedef ResponseInit = {
    var ?url:String;
    var ?headers:EitherType<Headers, EitherType<Array<Array<String>>, DynamicAccess<String>>>;
    var ?status:Int;
    var ?statusText:String;
    var ?counter:Int;
}

typedef URLSearchParams = js.node.url.URLSearchParams;
typedef RequestRedirect = js.html.RequestRedirect;

typedef AbortSignal = {
    var aborted(default, null):Bool;
    var onabort:haxe.Constraints.Function;
}

extern class Blob {
    var size(default, null):Int;
    var type(default, null):String;

    function text():Promise<String>;
    function arrayBuffer():Promise<ArrayBuffer>;
    function stream():Readable<Dynamic>;
    function slice():Blob;
}

typedef BodySource = EitherType<
    EitherType<String, EitherType<URLSearchParams, FormData>>,
    EitherType<EitherType<Blob, EitherType<Buffer, EitherType<ArrayBuffer, ArrayBufferView>>>, IReadable>
>;
