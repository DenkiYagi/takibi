package js.npm;

import haxe.extern.EitherType;
import js.lib.Error;
import js.lib.Promise;
import js.node.Buffer;
import js.node.http.Server;
import js.node.http.IncomingMessage;
import js.node.http.ServerResponse;
import js.node.Stream.IStream;

@:jsRequire("micro")
extern class Micro {
    static function buffer(req:IncomingMessage, ?limit:String, ?encoding:String):Promise<Buffer>;
    static function text(req:IncomingMessage, ?limit:String, ?encoding:String):Promise<String>;
    static function json(req:IncomingMessage, ?limit:String, ?encoding:String):Promise<Dynamic>;

    @:overload(function (res:ServerResponse, statusCode:Int, ?data:IStream):Promise<Void> {})
    @:overload(function (res:ServerResponse, statusCode:Int, ?data:Buffer):Promise<Void> {})
    @:overload(function (res:ServerResponse, statusCode:Int, ?data:{}):Promise<Void> {})
    static function send(res:ServerResponse, statusCode:Int, ?data:String):Promise<Void>;

    static function run(req:IncomingMessage, res:ServerResponse, fn:RequestHandler):Promise<Void>;

    static function createError(statusCode:Int, message:String, ?orig:Error):MicroError;
    static function sendError(req:IncomingMessage, res:ServerResponse, info:{?statusCode:Int, ?status:Int, ?message:String, ?stack:String}):Promise<Void>;

    @:selfCall
    static function serve(fn:RequestHandler):Server;
}

typedef RequestHandler = EitherType<
    (req:IncomingMessage, res:ServerResponse) -> Void,
    (req:IncomingMessage, res:ServerResponse) -> Dynamic
>;

@:forward
abstract MicroError(Error) from Error to Error {
    public var statusCode(get, set):Int;
    public var originalError(get, set):Null<Error>;

    extern inline function get_statusCode():Int {
        return Syntax.code("{0}.statusCode", this);
    }

    extern inline function set_statusCode(statusCode:Int):Int {
        return Syntax.code("{0}.statusCode = ${1}", this, statusCode);
    }

    extern inline function get_originalError():Error {
        return Syntax.code("{0}.originalError", this);
    }

    extern inline function set_originalError(orig:Error):Error {
        return Syntax.code("{0}.originalError = ${1}", this, orig);
    }
}