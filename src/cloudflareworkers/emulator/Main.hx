package cloudflareworkers.emulator;

import js.Node;
import js.html.Console;
import js.lib.Function;
import js.node.Fs;
import js.node.Http;
// import js.npm.Micro;

class Main {
    public static function main() {
        final path = Node.process.argv[2];
        if (!Fs.existsSync(path)) {
            Console.error("NOT FOUND Script");
            return;
        }

        var server = launchServer(path);

        Fs.watch(path, (eventType, filename) -> {
            if (!Fs.existsSync(path) || Fs.statSync(path).size == 0) return;
            server.close();
            server = launchServer(path);
            Console.log("cloudflare-workers-emulator restarted: http://localhost:3000/");
        });

        // final server = Micro.serve(runtime.handle);
        // server.listen(3000);

        Console.log("cloudflare-workers-emulator started: http://localhost:3000/");
        //Node.module.exports = runtime.handle;
    }

    static function launchServer(path: String) {
        final code = Fs.readFileSync(path, "utf-8");

        final runtime = new Runtime();
        runtime.loadScript(code);

        final server = Http.createServer(runtime.handle);
        server.on('clientError', (err, socket) -> {
            socket.end('HTTP/1.1 400 Bad Request\r\n\r\n');
        });
        server.listen(3000);

        return server;
    }
}
