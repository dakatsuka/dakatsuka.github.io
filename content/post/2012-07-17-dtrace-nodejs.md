---
title: OpenIndiana (Solaris) のDTraceでNode.jsをプロファイリングする
slug: dtrace-nodejs
date: 2012-07-17
tags: [Node.js]
---

昨年辺りから開発を進めているNodeアプリが大変残念なパフォーマンスだったので、DTraceでプロファイリングしてボトルネックを探してみる作戦です。

DTraceはSolaris, FreeBSD, Mac OS X辺りに搭載されているのですが、[Profiling Node.js](http://blog.nodejs.org/2012/04/25/profiling-node-js/) を読むとMacでは動かない上に32bitじゃないと駄目、とだいぶ面倒な制約が付いています。ちなみにFreeBSDもNGのようです。

仕方がないのでOpenSolarisの後継？にあたるOpenIndianaをVirtualBoxで動かす事にしました。

## Node.jsを入れる

OpenIndiana自体のインストール方法は割愛します。普通にF2キーを連打していればインストール出来ると思います。。。それにしてもSolarisを触るのなんて何年ぶりだろうか。

ひとまずインストール済みパッケージを最新版に上げて再起動しておきます。

```
$ su -
# pkg refresh --full
# pkg install package/pkg
# pkg image-update
# reboot
```

GCCとmath.hをインストールします。

```
# pkg install gcc-3
# pkg install header-math
```

OpenSSLは入っているはずなんですが、configureした時に無いって怒られるので改めて入れておきます。

```
# mkdir -p /usr/local/src
# cd /usr/local/src
# wget http://www.sunfreeware.com/intel/10/openssl-0.9.8x-sol10-x86-local.gz
# gunzip openssl-0.9.8x-sol10-x86-local.gz
# pkgadd -d openssl-0.9.8x-sol10-x86-local
```

Nodeのソースを落としてきてインストールします。v0.8.2は謎のエラーを吐いてビルドに失敗するのでv0.6.20にしました。DTraceを有効にするためにconfigureに–with-dtraceオプションを付与してビルドします。

```
# wget http://nodejs.org/dist/v0.6.20/node-v0.6.20.tar.gz
# tar zxvf node-v0.6.20.tar.gz
# cd node-v0.6.20
# ./configure --prefix=/usr/local --with-dtrace
# make
# make install
```

DTraceの結果をSVGに加工してくれるstackvisを入れておきます。

```
# npm install -g stackvis
```

## 実際にプロファイリングしてみる

試しにフィボナッチ数列を計算する関数をひたすらぶん回すコードをトレースしてみます。良いコード無くてごめんなさい。

```javascript
function fib(i) {
  if (i == 0 || i == 1) { return i; }
  return fib(i - 1) + fib(i - 2);
}
 
while(1) {
  var result = fib(30);
  console.log(result);
}
```

Nodeを実行します。これは一般ユーザーでも大丈夫です。


```
$ node ./fib.js
832040
832040
832040
832040
......
```

Nodeプロセスを動作させたまま、別ターミナルでDTraceをroot権限で実行します。60秒間 stacks.out に記録していきます。

```
# dtrace -o stacks.out -n 'profile-97/execname == "node" && arg1/{
    @[jstack(100, 8000)] = count(); } tick-60s { exit(0); }'
```

stackvisを使ってstacks.outをSVG化します。

```
# stackvis dtrace flamegraph-svg < stacks.out > stacks.svg
```

生成されたstacks.svgはこちらになりました（縦がコールスタックの深さで横が処理時間の相対的な長さのはず？）

{{<figure src="/media/2012-07-17-dtrace-nodejs/fib.svg">}}

WebSocket-Nodeで実装したエコーサーバーをDTraceしてみた結果はこちら。

{{<figure src="/media/2012-07-17-dtrace-nodejs/echo.svg">}}


## まとめ

処理に時間がかかっている関数がザックリと分かるのでボトルネック探しに重宝しそうです。

しかしMacで動かないのが惜しい。Solarisってだけでハードルが上がるような気がします。あと何故かNode v0.8.2がビルド出来ないのでそこら辺が今後の課題ですね。
