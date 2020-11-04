# Takibi（焚火）

[Cloudflare Workers](https://workers.cloudflare.com/)のローカル環境エミュレータ。

Cloudflareの提供する`wrangler`では達成し得ない、`localhost`へのプロキシをローカル環境でエミュレートできます。

## 使い方

このアプリケーションは[Haxe](https://haxe.org/)を用いてビルドするため、Haxeのインストールをする必要があります。

また実行には、[Node.js](https://nodejs.org/)が必要です。

### プロジェクトのセットアップ

```sh
git clone https://github.com/DenkiYagi/cloudflare-workers-emulator.git
haxelib install build.hxml
npm install
```

### 起動方法

```sh
npm start $WORKER_SCRIPT_PATH
```

### 使用例

~/worker-example/index.js
```javascript
const PRODUCTION = false

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

/**
 * Respond with hello worker text
 * @param {Request} request
 */
async function handleRequest(request) {
  return await fetch(
    PRODUCTION ? 'https://example.com' : 'http://localhost:8080'
  )
}
```

~/helloworld-app/index.js
```javascript
const app = require('express')()
app.get('/', (req, res) => res.end('Hello World!'))
app.listen(8080)
```

shell
```sh
cd ~/helloworld-app
node index &
cd ~/cloudflare-workers-emulator # This repository's directory
npm start ~/worker-example/index.js
```
