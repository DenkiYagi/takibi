package js.npm;

import js.node.Buffer;
import haxe.extern.EitherType;
import js.node.stream.Readable.IReadable;

@:jsRequire("form-data")
extern class FormData {
    function new(?options:FormDataNewOptions):Void;

}

typedef FormDataNewOptions = js.node.stream.Readable.ReadableNewOptions & {
    var ?writable:Bool;
    var ?readable:Bool;
    var ?dataSize:Int;
    var ?maxDataSize:Int;
    var ?pauseStreams:Bool;
}
