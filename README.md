# Cloudflare Workers Emulator 〇〇

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


```sh
npm start $WORKER_SCRIPT
```
