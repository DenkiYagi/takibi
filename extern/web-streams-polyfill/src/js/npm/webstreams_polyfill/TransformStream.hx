package js.npm.webstreams_polyfill;

import haxe.extern.EitherType;
import js.lib.Promise;

#if nodejs
@:jsRequire("web-streams-polyfill/ponyfill/es2018", "TransformStream")
#else
@:native("TransformStream")
#end
extern class TransformStream<T, U> {
    final writable:WritableStream<T>;
    final readable:ReadableStream<U>;

    function new(?transformer:Transformer<T, U>, ?writableStrategy:QueuingStrategy<T>, ?readableStrategy:QueuingStrategy<U>):Void;
}

typedef Transformer<T, U> = {
    var ?start:EitherType<TransformStreamDefaultController<U>->Void, TransformStreamDefaultController<U>->Promise<Void>>;
    var ?flush:EitherType<TransformStreamDefaultController<U>->Void, TransformStreamDefaultController<U>->Promise<Void>>;
    var ?transform:EitherType<(chunk:T, controller:TransformStreamDefaultController<U>) -> Void, (chunk:T, controller:TransformStreamDefaultController<U>) -> Promise<Void>>;
}