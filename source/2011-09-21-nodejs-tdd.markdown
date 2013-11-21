---
title: Node.js + Vowsではじめるテスト駆動開発
date: 2011-09-21
tags: Node.js, TDD, BDD
---

Node.jsで使えるTDD, BDDフレームワークはいくつかあるのですが（nodeunit, Jasmine, etc）コールバック・イベント周りのテストのしやすさとCoffeeScriptが利用出来る [Vows](http://vowsjs.org/) が非常に熱い感じです。

特にテストコードをCoffeeScriptで（別途コンパイルせずに）そのまま記述出来るのは、テストコードの可読性を考えると大きなメリットだと思います。

## Vowsのインストール

VowsはNode Package Manager（npm）でインストールする事が出来ます。vowsコマンドを有効にするためにカレントディレクトリの node_modules の他にグローバルにも入れておきましょう。

```
npm install vows
npm install -g vows
```

## Vowsを使った開発手順

サンプルとして自分のフルネームを返す事しか出来ないPersonクラスを実装してみます。まずはVowsでテストを書きます。今回は単機能なので下記コードを一気に書きました。

```coffee
vows   = require('vows')
assert = require('assert')
Person = require('./person')
 
vows
  .describe('Person')
  .addBatch
 
    'a instance':
      topic: ->
        new Person("Nobita", "Nobi")
 
      'should return full name': (topic) ->
        assert.equal topic.name(), "Nobita Nobi"
 
  .export module
```

この状態でテストを実行してみます。

```
$ vows test-person.coffee --spec
 
node.js:205
        throw e; // process.nextTick error, or 'error' event on first tick
              ^Error: Cannot find module './person'
```

そもそもテストの対象となるファイルが存在しないのでエラーになりますね。

次に person.coffee を作成します。ひとまず Person クラスを定義します。

```coffee
class Person
 
module.exports = Person
```

再度テストを実行してみます。

```
$ vows test-person.coffee --spec
 
♢ Person
 
  a instance
    ✗ should return full name
    TypeError: Object <Person> has no method 'name'
```

エラーが出ました。nameメソッドが無いと怒っていますので作りましょう。

```coffee
class Person
  name: ->
 
module.exports = Person
```

nameメソッドを定義したら再度テストを実行してみます。

```
$ vows test-person.coffee --spec
 
♢ Person
 
  a instance
    ✗ should return full name
      » expected 'Nobita Nobi',
        got      undefined (==) // vows.js:93
 
✗ Broken » 1 broken (0.004s)
```

ようやくテストが動作しました。が、nameメソッドには何も実装していないので勿論テストは通りません。後はテストが通るまでせっせとコードを書いていきましょう。

せっせと書いたコードはこちら。

```coffee
class Person
  constructor: (firstName, lastName) ->
    @firstName = firstName
    @lastName  = lastName
 
  name: ->
    "#{@firstName} #{@lastName}"
 
module.exports = Person
```

テストを実行します。

```
$ vows test-person.coffee --spec
 
♢ Person
 
  a instance
    ✓ should return full name
 
✓ OK » 1 honored (0.002s)
```

無事にグリーンになりました！

ところで、こんなしょぼいコードでもリファクタリングの余地が残されています。CoffeeScriptはコンストラクタの引数をそのままインスタンスのプロパティに割り当てる構文があるので、それに書き換えてみます。

```diff
  class Person
+   constructor: (@firstName, @lastName) ->
-     @firstName = firstName
-     @lastName  = lastName
 
    name: ->
      "#{@firstName} #{@lastName}"
 
  module.exports = Person
```

テストを実行。

```
$ vows test-person.coffee --spec
 
♢ Person
 
  a instance
    ✓ should return full name
 
✓ OK » 1 honored (0.002s)
```

うむ。


## Vowsでモック・スタブを使うには

Vowsでモック・スタブを使いたい場合は Sinon.JS を利用しましょう。Sinon.JS は Node Package Manager（npm）で入れる事が出来ます。

```
npm install sinon
```

下記はモックを使った例。

```coffee
vows   = require('vows')
sinon  = require('sinon')
assert = require('assert')
 
class Twitter
  tweet: (message) ->
 
class Person
  constructor: (@twitter) ->
 
  tweet: (message) ->
    @twitter.tweet(message)
 
vows
  .describe('Person')
  .addBatch
 
    'when tweet message':
      topic: ->
        twitter = new Twitter()
        twitterMock = sinon.mock(twitter)
        twitterMock.expects("tweet").once().withArgs("hello")
 
        person = new Person(twitter)
        person.tweet("hello")
 
        return twitterMock
 
      'should call twitter.tweet': (topic) ->
        topic.verify()
 
  .export module
```

## Vowsで非同期イベントのテストを行うには

Vowsで非同期イベントのテストを行う場合、this.callbackとpromiseの2種類が用意されています。私は後者のプロミスのほうをよく利用していますので、ここではプロミスを使ったサンプルを掲載しておきます。

```coffee
vows   = require('vows')
assert = require('assert')
http   = require('http')
 
vows
  .describe('http')
  .addBatch
 
    'GET google.co.jp':
      topic: ->
        promise = new (require('events').EventEmitter)()
        options =
          host: 'www.google.co.jp',
          port: 80,
          path: '/',
          method: 'GET',
          headers:
            'Content-length': 0
 
        req = http.request options, (res) ->
          res.setEncoding('utf8')
          res.on 'data', (chunk) ->
            promise.emit 'success', chunk
 
        req.end()
        return promise
 
 
      'should be received': (topic) ->
        assert.ok topic
 
  .export module
```

上記コードを見れば分かると思いますが、プロミスとはトピックの戻り値をEventEmitterにして、successイベントが発生すると各テストを実行していく仕組みです。うまくイベントが発生しなかった場合はcallback not firedというエラーが起きてテストに失敗します。

（非同期周りのテストはまた別の機会に…）

## まとめ

駆け足でVowsを紹介してみましたが如何でしょうか？Node.jsでのテストは面倒くさいという印象が強いですが（自分だけですかね…）JavaScriptは色々な書き方が出来て、油断するとコードが大変な事になったりするので是非テストは書いていきたいですね。

VowsはCoffeeScriptで書けるので、いちいちテストコードでhogehoge(function() { ... });とか書いてられない人にもお勧めです！

## 参考サイト

* [Vows « Asynchronous BDD for Node](http://vowsjs.org/)
* [Sinon.JS – Versatile standalone test spies, stubs and mocks for JavaScript](http://sinonjs.org/)
* [Node.js 用のテスティングフレームワーク Vows](http://d.hatena.ne.jp/koichik/20100918#1284804000)
* [Node.js 用のテスティングフレームワーク Vows その 2](http://d.hatena.ne.jp/koichik/20100919#1284886800)
* [Node.js 用のテスティングフレームワーク Vows その 3](http://d.hatena.ne.jp/koichik/20100920#1284937200)
