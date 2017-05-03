---
title: Rails3 + OmniAuth で mixi OpenID を使うための設定
date: 2011-06-01
tags: Ruby, Rails
---

[OmniAuth](https://github.com/intridea/omniauth)を使ってTwitterやFacebookと連携・認証をする方法はググればたくさん出てくるのですが、[mixi OpenID](http://developer.mixi.co.jp/openid)を使ったやり方は出てこなかったので調べてみました。

## OmniAuthの設定

config/initializers/omniauth.rbに以下を記述して保存します。OpenID.fetcher.ca_fileを指定しないと Warning が出まくるのでしっかり指定してあげましょう。

```ruby
require 'omniauth/openid'
require 'openid/fetchers'
require 'openid/store/filesystem'
 
OpenID.fetcher.ca_file = "/usr/lib/ssl/certs/ca-certificates.crt"
 
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid, OpenID::Store::Filesystem.new("/tmp"), :name => "mixi", :identifier => "mixi.jp"
end
```

providerにTwitterやFacebookを追加すれば、3サイトで認証出来るようになります。

## 参考サイト

UserモデルやSessionsControllerの実装などは、[@jugyo](http://twitter.com/jugyo)さんの [OmniAuth で簡単 Twitter 認証！](http://blog.twiwt.org/e/c3afce)の通りにやれば完璧だと思います。
