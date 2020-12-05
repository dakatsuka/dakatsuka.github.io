---
title: Ruby1.9 + Rails3 + jpmobileで構築したサイトをcucumberでテストするためのTips
slug: rails3-jpmobile-cucumber
date: 2011-01-24
tags: [Ruby, Rails]
---

地味に苦戦したのでメモしておきます。これだから携帯向けサイトは大変・・・

開発環境

* Ruby 1.9.2-p136
* Ruby on Rails 3.0.3
* jpmobile 0.1.4
* cucumber 0.10.0 ( capybara 0.4.0 )

## インストール

cucumberを動かすためのgemをインストールします。今回はバックエンドにcapybaraを使用します。（WebratはRails3だとうまく動きませんでした）

```ruby
# Gemfile
group :test do
  gem 'rspec-rails'
  gem 'cucumber-rails'
  gem 'capybara'
end
```

Bundlerでインストールし、cucumberをRailsプロジェクトに組み込みます。

```sh
bundle install
rails g cucumber:install ja --rspec --capybara
```

## capybaraのUserAgentを偽装する

モバイルサイトのテストなので、UAを偽装してアクセスしたいところです。ところがcapybaraは、HTTPヘッダをカスタマイズする機能が標準では備わっていないようなので、自力で何とかしないといけません。ググってみると、[Testing custom headers and ssl with Cucumber and Capybara](http://aflatter.de/2010/06/testing-headers-and-ssl-with-cucumber-and-capybara/) という記事を発見しました。ここにcapybaraでHTTPヘッダを変える方法が書いてあります。

この記事を参考に下記ソースを features/support/headers_hack.rb に保存します。

```ruby
module RackTestMixin
  def self.included(mod)
    mod.class_eval do
      # This is where we save additional entries.
      def hacked_env
        @hacked_env ||= {}
      end
      
      # Alias the original method for further use.
      alias_method  :original_env, :env
 
      # Override the method to merge additional headers.
      # Plus this implicitly makes it public.
      def env
        original_env.merge(hacked_env)
      end
    end
  end
end
 
Capybara::Driver::RackTest.send :include, RackTestMixin
 
module HeadersHackHelper
  def add_headers(headers)
    page.driver.hacked_env.merge!(headers)
  end
end
 
World(HeadersHackHelper)
```

そして、features/step_definitions/mobile_support.rb というファイルを作成して、下記コードを貼り付けます。

```ruby
# coding: utf-8
 
前提 /^携帯端末でアクセスしている$/ do
  add_headers({'HTTP_USER_AGENT' => 'KDDI-CA39 UP.Browser/6.2.0.13.1.5 (GUI) MMP/2.0',
               'HTTP_X_UP_SUBNO' => 'subscriber'})
end
```

これで、各シナリオの前提に「携帯端末でアクセスしている」と書くことによってUAが偽装された状態でテストが実行されます。

ちなみに偽装するUAは、セッション・クッキーの仕様上、DoCoMoではなくauをお勧めします。

## invalid byte sequence in Shift_JIS を黙らせる

capybaraの仕様なのかcucumberの仕様なのか分からないのですが、フォームで入力される文字はUTF-8固定になるようです。

jpmobileのmobile_filterを有効にしていると、半角カタカナなどが混ざったデータがポストされた時に invalid byte sequence in Shift_JIS というエラーが発生してしまいます。

これを回避するために、テストが実行される時のみmobile_filterを動作させないようにします。若干無理矢理ですが、config/application.rb の mobile_filter 呼び出し箇所を次のように変更します。

```ruby
unless Rails.env == "test"
  config.jpmobile.mobile_filter
  config.jpmobile.form_accept_charset_conversion = true
end
```

以上で、通常のサイトをテストする感じでモバイルサイトもテスト出来るようになるはずです。

何か間違っている箇所やもっとベストな方法があったら教えて下さい！
