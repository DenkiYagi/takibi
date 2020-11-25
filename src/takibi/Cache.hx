package takibi;

import haxe.ds.Map;
import haxe.extern.EitherType;
import js.lib.Error;
import js.lib.Promise;

class Cache {
    @:allow(takibi)
    function new() {}

    final cacheMap = new Map<String, Response>();

    public function match(request:EitherType<String, Request>, ?options:CacheQueryOptions):Promise<Null<Response>> {
        final requestUrl = getRequestUrl(request);
        if (!isValidMethod(request, options)) {
            return Promise.reject(new Error('Request must have GET method.'));
        }

        final response = cacheMap.get(requestUrl);
        return Promise.resolve(response);
    }

    public function put(request:EitherType<String, Request>, response:Response):Promise<Void> {
        final requestUrl = getRequestUrl(request);

        if (!isValidMethod(request)) {
            return Promise.reject(new Error('Request must have GET method.'));
        }
        if (response.status == 206) {
            return Promise.reject(new Error('Response status must not be 206.'));
        }
        if (response.headers.has('Vary')) {
            return Promise.reject(new Error('Response must not have "Vary".'));
        }

        if (Std.is(request, Request)) {
            final _request = cast(request, Request);
            final cacheControl = _request.headers.get('cache-control');
            final cacheControlDirectives = cacheControl.split(',').map(directive -> StringTools.trim(directive));
            for (directive in cacheControlDirectives) {
                // 「キャッシュしない」パターン
                if (StringTools.startsWith(directive, 'max-age')) {
                    final args = directive.split('=');
                    final maxAge = Std.parseInt(args[1]);
                    if (maxAge <= 0) return Promise.resolve();
                }
                if (directive == 'no-cache') return Promise.resolve();
                if (directive == 'no-store') return Promise.resolve();
            }
        }

        cacheMap.set(requestUrl, response);
        return Promise.resolve();
    }

    public function delete(request:EitherType<String, Request>, ?options:CacheQueryOptions):Promise<Bool> {
        final requestUrl = getRequestUrl(request);
        if (!isValidMethod(request, options)) {
            return Promise.reject(new Error('Request must have GET method.'));
        }

        final result = cacheMap.remove(requestUrl);
        return Promise.resolve(result);
    }

    private static function getRequestUrl(request:EitherType<String, Request>):String {
        return (Std.is(request, Request))? cast(request, Request).url: request;
    }

    private static function isValidMethod(request:EitherType<String, Request>, ?options:CacheQueryOptions):Bool {
        return
            if (Std.is(request, String)) true
            else if (cast(request, Request).method == 'GET') true
            else if (options != null && options.ignoreMethod) true
            else false;
    }
}

typedef CacheQueryOptions = {
    var ?ignoreMethod:Bool;
}
