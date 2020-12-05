---
title: Rails2とRails3でセッションを共有する
slug: sharing-sessions-rails2-rails3
date: 2010-11-22
tags: [Ruby, Rails]
---

サブドメインが異なるRails2アプリとRails3アプリでセッションを共有したい場合、Cookie Session Storeに互換性が無いみたいでそのまま共有しようとすると問題が発生します。

具体的にどういう問題があるかというと、

* Rails2はCookieのKeyをSymbolとして扱う。しかしRails3はStringとして扱っている。
* Flash周りは何とマーシャルしてCookieに保存されている。Rails2とRails3でモジュール・クラス名が異なっているのでアンマーシャル時にuninitialized constantが発生する。

まず1つ目の問題ですが、幸いなことにRails3はKeyがSymbolでも読み込みが可能です。ただし一度でも読み込むとStringに変換されてRails2からは読めなくなります。ということは、Rails2でStringなKeyを認識出来るようにすれば、この問題は解決出来そうです。

2つ目の問題は、双方に存在しないモジュール・クラスを予め定義しておけばエラーは出ないはずです。

以上を踏まえてRails2、Rails3にモンキーパッチを当てます。

## Rails2側

config/initializersにaccept_rails3_session.rbなど適当に名前をつけて下記ソースをコピペします。

```ruby
module ActionDispatch
  module Flash
    class FlashHash < Hash
      def method_missing(m, *a, &b)
      end
    end
  end
end
 
module ActionController
  module Session
    class CookieStore
      private
      def unmarshal(cookie)
        if cookie
          data = persistent_session_id!(@verifier.verify(cookie))
          data.symbolize_keys!
        end
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        nil
      end
 
      def requires_session_id?(data)
        if data
          data.respond_to?(:key?) && !data.key?(:session_id) && !data.key?("session_id")
        else
          true
        end
      end
    end
  end
end
```

config/initializers/session_store.rbを開き、:key、:secret、:domainを設定します。この3つはRails3側も同じにする必要があります。

```ruby
ActionController::Base.session = {
  :key    => '_session',
  :secret => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
  :domain => '.example.com'
}
```

## Rails3側

config/initializersにaccept_rails2_session.rbなど適当に名前をつけて下記ソースをコピペします。

```ruby
module ActionController
  module Flash
    class FlashHash < Hash
      def method_missing(m, *a, &b)
      end
    end
  end
end
```

config/initializers/session_store.rbを開き、:keyと:domainをRails2側で設定した値と同じ値にします。

```ruby
AppName::Application.config.session_store :cookie_store,
                                          :key    => '_session',
                                          :domain => '.example.com'
```

config/initializers/secret_token.rbを開き、Rails2側で設定した:secretと同じ値にします。

```ruby
AppName::Application.config.secret_token = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
```

以上です！これでRails2とRails3でセッションを共有出来るようになります。

## まだ残る問題点

* Rails2側がRuby1.8.xでRails3側がRuby1.9.2の構成で、Rails2で作成したFlash MessageをRails3側で読み出すとincompatible character encodingsになります。
* Rails2側で作成したFlash MessageをRails3側で呼び出すとFlashが消えてくれません。

Flash周りはもう少し考えないと厳しいかもしれません。。。
