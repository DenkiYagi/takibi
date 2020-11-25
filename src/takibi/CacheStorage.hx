package takibi;

import js.lib.Object;

class CacheStorage {
    @:allow(takibi)
    function new() {
        final cache = new Cache();
        Object.defineProperty(this, "default", {get: () -> cache});
    }
}
