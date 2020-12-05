---
title: シャーディング環境で Mongoose を使う
slug: sharding-mongoose
date: 2012-03-07
tags: [Node.js, MongoDB]
---

MongooseでSchemaを定義する時に、Shard keyの情報を渡してあげる事で insert, update, remove等の処理がTargetedオペレーションで実行されるようになります。便利ですね。

```javascript
var mongoose = require('mongoose')
  , Schema = mongoose.Schema
  , ObjectId = Schema.ObjectId;
 
var Footprint = new Schema({
  user_id: { type: ObjectID },
  visitor_id: { type: ObjectID },
  seconds: { type: Number, default: (new Date()).getSeconds() },
  created_at: { type: Date, default: Date.now }
}, {
  shardkey: {
    user_id: 1,
    seconds: 1
  }
});
```

※ シャーディングの設定自体は予めMongoDB側で済ませておく必要があります。
