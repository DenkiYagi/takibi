package cloudflareworkers.emulator;

import js.Syntax;
import js.lib.Map;
import haxe.extern.EitherType;

class FormData {
    final map:Map<String, Array<String>>;

    public function new():Void {
        this.map = new Map();
    }

    public function append(name:String, value:String):Void {
        if (map.has(name)) {
            map.get(name).push(value);
        } else {
            map.set(name, [value]);
        }
    }

    public function delete(name:String):Void {
        map.delete(name);
    }

    public function get(name:String):Null<String> {
        final items = map.get(name);
        return if (items != null && items.length > 0) {
            items[0];
        } else {
            null;
        }
    }

    public function getAll(name:String):Array<String> {
        return map.get(name).copy();
    }

    public function has(name:String):Bool {
        return map.has(name);
    }

    public function set(name:String, value:String):Void {
        map.set(name, [value]);
    }

    public function entries():js.lib.Iterator<KeyValue<String, String>> {
        if (map.size <= 0) return new EmptyIterator();

        final keyIterator = map.keys();
        var currentKey = null;
        var valueIterator = null;
        return {
            next: () -> {
                while (true) {
                    if (valueIterator == null) {
                        final key = keyIterator.next();
                        if (key.done) break;
                        currentKey = key.value;
                        valueIterator = arrayIterator(map.get(key.value));
                    }
                    final val = valueIterator.next();
                    if (!val.done) return {done: false, value: new KeyValue(currentKey, val.value)};
                    else valueIterator = null;
                }
                return {done: true};
            }
        }
    }

    public function keys():js.lib.Iterator<String> {
        return map.keys();
    }

    public function values():js.lib.Iterator<String> {
        if (map.size <= 0) return new EmptyIterator();

        final valueIterator = map.values();
        var itemsIterator = null;
        return {
            next: () -> {
                while (true) {
                    if (itemsIterator == null) {
                        final items = valueIterator.next();
                        if (items.done) break;
                        itemsIterator = arrayIterator(items.value);
                    }
                    final item = itemsIterator.next();
                    if (!item.done) return {done: false, value: item.value};
                }
                return {done: true};
            }
        }
    }

    function forEach(callback:EitherType<(value:String)->Void, (value:String, key:String)->Void>, ?thisArg:Dynamic):Void {
        final iterator = entries();
        while (true) {
            final current = iterator.next();
            if (current.done) return;
            Syntax.code("{0}.call({1}, {2}, {3})", callback, thisArg, current.value.key, current.value.value);
        }
    }

    inline function arrayIterator<T>(array:Array<T>):js.lib.Iterator<T> {
        return js.Syntax.code("{0}.values()", array);
    }
}

private class EmptyIterator<T> {
    public function new() {}

    public function next():js.lib.Iterator.IteratorStep<T> {
        return {done: true};
    }
}
