---
title: Ubuntu 11.04 + nave + npm で Node.js 環境を構築する
date: 2011-06-06
tags: Node.js
---

近々 Node.js を使う機会がありそうなので Node.js を Ubuntu にインストールしてみました。

nave か nvm にするか迷ったのですが、nvm は zsh と相性が悪くて nvm 本体に手を入れないといけないので物ぐさな私は nave を使う事にしました。

## 準備

まず Node.js をインストールするために必要なパッケージ類を apt-get で導入します。

```
sudo apt-get install git-core curl build-essential libssl-dev
```

## naveをインストール

naveの最新版をGithubからcloneしてきます。

```
git clone git://github.com/isaacs/nave.git .nave
```

正常に動作するか確認。

```
$ .nave/nave.sh help
 
Usage: nave <cmd>
 
Commands:

....
```

毎回 ./nave/nave.sh と入力するのは面倒なのでパスが通っているディレクトリにシンボリックを貼りました。

```
cd ~/bin
ln -s ../.nave/nave.sh nave
```

これで nave と入力するだけで呼び出せるようになります。

## Node.jsをインストール

nave を使って最新版をインストールしてみます。

```
nave install latest
```

インストールが終わったら下記コマンドで確認。

```
$ nave ls
src:
0.4.8    
 
installed:
0.4.8
```

0.4.8が入ったようです。

試しに0.4.7を入れてみましょう。

```
$ nave install 0.4.7
$ nave ls
src:
0.4.7    0.4.8    
 
installed:
0.4.7    0.4.8
```

nave use で使用したいバージョンを指定します。

```
$ nave use 0.4.8
Already installed: 0.4.8
using 0.4.8
 
$ node -v
v0.4.8
```

## npmをインストール

nave use して node.js を使える状態にした上で、下記コマンドでインストールします。

```
curl http://npmjs.org/install.sh | sh
```

インストールされたか確認。

```
$ npm -v
1.0.9-1
```

以上です。Ruby + rvm よりちょっとインストールが手間ですけど使えるようになりました。今度は express あたりをイジくってみようと思います。

## 参考リンク

* [Node.js](http://nodejs.org/)
* [isaacs/nave – GitHub](https://github.com/isaacs/nave)
* [npm – Node Package Manager](http://npmjs.org/)
* [Node.jsとnvmを初めてインストールするときのハマりポイントと対策 – ess sup](http://d.hatena.ne.jp/mollifier/20110221/p1)
* [zshでnvmを使うときに必要なこと(2011-05-10現在版) – Inquisitive!](http://d.hatena.ne.jp/uk_oasis/20110510/1305014415)
