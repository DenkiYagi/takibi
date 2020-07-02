package js.npm.webstreams_polyfill;

typedef ReadResult<T> = {
    final done:Bool;
    final ?value:T;
}
