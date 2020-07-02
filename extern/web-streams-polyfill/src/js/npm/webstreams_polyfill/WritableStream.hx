package js.npm.webstreams_polyfill;

import js.lib.Promise;
import js.lib.ArrayBufferView;
import js.lib.Promise;
import haxe.extern.EitherType;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "WritableStream")
#else
@:native("WritableStream")
#end
extern class WritableStream<T> {
    final locked:Bool;

    function new(?underlyingSink:UnderlyingSink<T>, ?strategy:QueuingStrategy<T>):Void;

    function abort(reason:Dynamic):Promise<Void>;

    function getWriter():WritableStreamDefaultWriter<T>;
}

typedef UnderlyingSink<T> = {
    var ?start:EitherType<(controller:WritableStreamDefaultController<T>) -> Void, (controller:WritableStreamDefaultController<T>) -> Promise<Void>>;
    var ?write:EitherType<(chunk:T, controller:WritableStreamDefaultController<T>) -> Void, (chunk:T, controller:WritableStreamDefaultController<T>) -> Promise<Void>>;
    var ?close:EitherType<() -> Void, () -> Promise<Void>>;
    var ?abort:EitherType<(reason:Dynamic) -> Void, (reason:Dynamic) -> Promise<Void>>;
}
