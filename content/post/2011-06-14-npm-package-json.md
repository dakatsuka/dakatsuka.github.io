---
title: npm と package.json でパッケージ管理
slug: npm-package-json
date: 2011-06-14
tags: [Node.js]
---

node.js で Ruby の Bundler(Gemfile) のようにパッケージとバージョンを管理するには、package.json というファイルを作成すれば良いようです。

package.json のdependenciesに必要なパッケージ名とバージョンを指定していきます。バージョンは"2.3.11"のように直接指定する事はもちろん、">= 0.0.1"のように記述する事も出来ます。ここら辺はBundlerと一緒ですね。

```json
{
    "name": "example-app"
  , "version": "0.0.1"
  , "private": true
  , "dependencies": {
      "express": "2.3.11"
    , "jade": ">= 0.0.1"
    , "socket.io": "0.6.18"
  }
}
```

package.json の記述が終わったら下記コマンドでパッケージを一括でインストールする事が出来ます。

```sh
npm install
```

-g オプションを付けずに実行すれば ./node_modules ディレクトリ内にインストールされます。.gitignore に ./node_modules を追加しておくと良さそうです。

## 参考サイト

* [Packages/1.1 – CommonJS Spec Wiki](http://wiki.commonjs.org/wiki/Packages/1.1)
