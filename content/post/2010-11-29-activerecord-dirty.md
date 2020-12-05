---
title: ActiveRecordオブジェクトの属性変更を確認・取得する
slug: activerecord-dirty
date: 2010-11-29
tags: [Ruby, Rails]
---

ActiveRecord（Rails3だとActiveModel）は、自分自身（オブジェクト）のプロパティが変更されたかどうか、またどのプロパティがどのように変更されたのかなどを取得する機能が備わっています。

管理画面で操作ログなどを実装する時に役立ちそうです。

変更無し：

```ruby
@user = User.find_by_email("old@exmaple.com")
@user.changed? # => false
@user.changes  # => {}
```

emailを変更してみる：

```ruby
@user = User.find_by_email("old@exmaple.com")
@user.email = "new@exmaple.com"
@user.changed?     # => true
@user.changes      # => {"email"=>["old@exmaple.com", "new@exmaple.com"]}
@user.email_change # => ["old@exmaple.com", "new@example.com"]
@user.email_was    # => "old@exmaple.com"
```
