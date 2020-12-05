---
title: Rails3でビュー以外からヘルパーを呼び出す方法
slug: rails3-helpers
date: 2011-02-22
tags: [Ruby, Rails]
---

例えばコントローラやモデル、もしくはバッチ処理でヘルパーを使いたい時がたまにあるんですよね。いつも忘れてしまうのでブログに残しておきます。

```ruby
ApplicationController.helpers.image_tag( ..... )
```
