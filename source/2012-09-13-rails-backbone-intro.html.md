---
title: Rails3にBackbone.jsを導入する
date: 2012-09-13
tags: JavaScript, Ruby, Rails, Backbone.js
---

最近Backbone.jsを触っています。Backbone.jsをRailsで使いたいならパッケージで導入してしまうのが一番簡単でしょう。

Gemfileにrails-backboneを追加して`bundle install`

```ruby
source 'https://rubygems.org'
 
gem 'rails', '3.2.8'
gem 'mysql2'
 
group :assets do
...
end
 
gem 'jquery-rails'
gem 'rails-backbone' # <- 追加
```

Backbone.jsを組み込みます。

```
$ bundle exec rails g backbone:install
      insert  app/assets/javascripts/application.js
      create  app/assets/javascripts/backbone/routers
      create  app/assets/javascripts/backbone/routers/.gitkeep
      create  app/assets/javascripts/backbone/models
      create  app/assets/javascripts/backbone/models/.gitkeep
      create  app/assets/javascripts/backbone/views
      create  app/assets/javascripts/backbone/views/.gitkeep
      create  app/assets/javascripts/backbone/templates
      create  app/assets/javascripts/backbone/templates/.gitkeep
      create  app/assets/javascripts/backbone/app.js.coffee
```

app/assets/javascript/application.js は以下のように変更されます。

```javascript
//= require jquery
//= require jquery_ujs
//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink
//= require backbone/app
//= require_tree .
```

この下から2行目、ファイルでは app/assets/javascript/backbone/app.js.coffee が各モデル・ビュー・テンプレートなどを読み込むようになっています（ファイル名はRailsアプリと同じ名前になります）

```coffee
#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers
 
window.App =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
```

rails-backboneのお作法は（scaffoldで生成されたコードをみる限り）モデル・ビュー・ルーターをディレクトリに分けて管理するようです。そしてその構造がそのまま名前空間になります。

例えばUserモデルなら app/assets/javascript/backbone/models/user.js.coffee にファイルを作り、下記のようなコードを書いていきます。

```coffee
class App.Models.User extends Backbone.Model
  url: ->
    "/api/users/#{@id}"
```

アプリ名が長いと若干タイプが面倒かなーって印象ですが、まぁ app/\* と同じ感覚で作れるのでRails慣れしてる人は違和感なく使えそうです。
