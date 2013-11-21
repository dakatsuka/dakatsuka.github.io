---
title: Consistent HashingをNode.jsで実装してみた
date: 2011-08-14
tags: Node.js
---

Node.js から Key Value Store などを利用する際に、キーを複数のノードに分散させる汎用的なライブラリがあったら便利なのではと思い実装してみました。

[ソースコードはGitHubで公開](https://github.com/dakatsuka/node-consistent-hashing)しています。ライセンスはMIT Licenseとします。

```
git clone git://github.com/dakatsuka/node-consistent-hashing.git
```

また、npmでもインストール出来るようにしました。

```
npm install consistent-hashing
```

## 使い方

基本的な使い方は下記の通りです。

```javascript
var ConsistentHashing = require('consistent-hashing');
var cons = new ConsistentHashing(["node1", "node2", "node3"]);
console.log(cons.getNode("key1"));  // => node3
console.log(cons.getNode("key2"));  // => node2
console.log(cons.getNode("key3"));  // => node1
console.log(cons.getNode("key4"));  // => node2
```

試しにA..Zまでのキーを分散させてみます。

```javascript
var nodes = {};
var chars = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
  'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
  'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
];
 
chars.forEach(function(c) {
  var node = cons.getNode(c);
 
  if (nodes[node]) {
    nodes[node].push(c);
  } else {
    nodes[node] = [];
    nodes[node].push(c);
  }
});
 
console.log(nodes);
 
// { node3: [ 'A', 'F', 'H', 'J', 'N', 'S', 'U', 'W', 'X' ],
//   node1: [ 'B', 'C', 'E', 'G', 'L', 'M', 'Q', 'R', 'V', 'Y', 'Z' ],
//   node2: [ 'D', 'I', 'K', 'O', 'P', 'T' ] }
```

ノードの追加と削除が出来ます。

```javascript
cons.addNode("node4");
cons.removeNode("node1");
```

また、new するときに仮想ノード数を変更する事が出来ます（デフォルト値は160）。

```javascript
var cons = new ConsistentHashing(["node1", "node2", "node3"], { replicas: 200 });
```

ハッシュ値を出すときのアルゴリズムも変更する事が出来ます（デフォルト値はmd5）。

```javascript
// md5, sha1, sha256, sha512を選択出来ます。
var cons = new ConsistentHashing(["node1", "node2", "node3"], { algorithm: 'sha1' });
```
