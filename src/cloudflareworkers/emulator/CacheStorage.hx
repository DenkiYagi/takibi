package cloudflareworkers.emulator;

import js.lib.Object;

class CacheStorage {
    @:allow(cloudflareworkers.emulator)
    function new() {
        final cache = new Cache();
        Object.defineProperty(this, "default", {get: () -> cache});
    }
}
