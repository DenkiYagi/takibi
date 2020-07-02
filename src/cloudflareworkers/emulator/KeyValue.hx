package cloudflareworkers.emulator;

abstract KeyValue<K, V>(Array<Any>) {
    public var key(get, never):K;
    public var value(get, never):V;

    public inline function new(key:K, value:V) {
        this = [key, value];
    }

    inline extern function get_key():K {
        return this[0];
    }

    inline extern function get_value():V {
        return this[1];
    }
}
