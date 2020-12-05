---
title: activerecord-importとelasticsearch-railsでメソッドが被る問題
slug: activerecord-import
date: 2015-11-18
tags: [Ruby, Rails]
---

どちらのgemもActiveRecordモデルに`import`メソッドを生やそうとする。

いい感じに共存させる方法をググっていたら同じことを[Issue](https://github.com/zdennis/activerecord-import/issues/149)で質問している人がいて、解決方法が書いてあったので助かった。`config/application.rb`で`activerecord-import`側のメソッド名を変更する。

```ruby
require File.expand_path('../boot', __FILE__)
require 'rails/all'

# https://github.com/zdennis/activerecord-import/issues/149
require 'activerecord-import/base'

class ActiveRecord::Base
  class << self
    alias :bulk_insert :import
    remove_method :import
  end
end

Bundler.require(*Rails.groups)
....
```

### 参考文献

* [elasticsearch-rails](https://github.com/elastic/elasticsearch-rails)
* [activerecord-import](https://github.com/zdennis/activerecord-import)
* [Name clash with the elasticsearch gem · Issue #149 · zdennis/activerecord-import](https://github.com/zdennis/activerecord-import/issues/149)

