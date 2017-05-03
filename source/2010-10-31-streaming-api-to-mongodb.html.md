---
title: Twitter Streaming APIをMongoDBに保存して遊んでみる
date: 2010-10-31
tags: Ruby, MongoDB
---

TwitterのストリーミングAPIを利用する場合、かなりのデータ量が流れてくるので、リアルタイムに解析・集計などを行うと処理が追いつかない可能性が出てきます。

そこで、流れてきたデータをいったんどこかに保存しておいて後からバッチ処理で解析をしていく事になると思います。今回はその保存先にMongoDBをチョイスします。

## なぜMongoDBなのか

* RDBMSに比べて高速
* BSON形式で保存するので、JSONの階層構造をそのまま維持して保存可能
* NoSQLながらGROUP BYライクな集計処理が可能

ということで、試しにストリーミングAPIのsampleから流れてくるデータをMongoDBに保存するスクリプトを書いてみました。このスクリプトを動かすには、別途MongoDB本体と「json」「bson_ext」「mongo」の3つのgemが必要になります。


```ruby
# coding: utf-8
 
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.
 
require 'rubygems'
require 'net/https'
require 'openssl'
require 'uri'
require 'json'
require 'mongo'
 
USERNAME = ""
PASSWORD = ""
 
con    = Mongo::Connection.new
db     = con.db('twitter')
tweets = db.collection('tweets')
 
uri = URI.parse('https://stream.twitter.com/1/statuses/sample.json')
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_NONE
https.verify_depth = 5
 
https.start do |h|
  request = Net::HTTP::Get.new(uri.request_uri)
  request.basic_auth(USERNAME, PASSWORD)
 
  h.request(request) do |response|
    response.read_body do |chunk|
      parsed = JSON.parse(chunk) rescue next
      tweets.insert(parsed)
    end
  end
end
```

## 実際に動かしてみた結果

上記スクリプトを15分程度動かしてみて、MongoDBのshellから色々クエリを投げてみました。

```
$ mongo twitter
MongoDB shell version: 1.6.3
connecting to: twitter
 
// 件数を取得する
> db.tweets.find().count()
2093
 
// 日本語のツイートの件数を取得する（もしかしたら日本語で登録しているユーザーかな？）
> db.tweets.find({"user.lang": "ja"}).count()
568
 
// タイムゾーンを指定して件数を取得する
> db.tweets.find({"user.time_zone" : "Tokyo"}).count()
363
> db.tweets.find({"user.time_zone" : "Osaka"}).count()
38
 
// Twitterクライアントを指定して検索
> db.tweets.find({"source" : /TweetDeck/i}).count()
72
> db.tweets.find({"source" : /Twitter for iPhone/i}).count()
99
```

さらにMongoDB shellではJavaScriptが使用出来るので、ちょっとコードを書くだけでTwitterクライアントのランキングを作成することも出来ます。

```javascript
function count_source(order) {
  var result = db.tweets.group({
    key:     { source:true },
    reduce:  function(obj, prev) { prev.count++; },
    initial: { count: 0 },
  });
  if (order == "asc") {
    return result.sort( function(a, b) { return a['count'] > b['count'] ? 1 : -1; } );
  } else if (order == "desc") {
    return result.sort( function(a, b) { return a['count'] < b['count'] ? 1 : -1; } );
  }
}
 
// ランキングを昇順に並び替え
> count_source("asc")
 
// ランキングを降順に並び替え
> count_source("desc")
```

これを応用すればランキングサイトなども簡単に作れそうですね。まぁ、その前にタイムアウトした場合の再接続処理とか、デーモン化とかやるべき事がたくさんありそうですが。。。
