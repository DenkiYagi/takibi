package js.npm.webstreams_polyfill;

typedef QueuingStrategy<T> = {
    var ?highWaterMark:Int;
    var ?size:(chunk:T) -> Int;
}