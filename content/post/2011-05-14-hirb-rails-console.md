---
title: hirb を導入して rails console を快適に利用する
slug: hirb-rails-console
date: 2011-05-14
tags: [Ruby, Rails]
---

[Rails 3: Fully Loaded | Intridea Blog](http://intridea.com/2011/5/13/rails3-gems) で [hirb](https://github.com/cldwalker/hirb) という gem が紹介されていたので試してみることにしました。hirb は Rails Console 上で ActiveRecord の結果を見やすく整形してくれるツールのようです。

le に下記コードを追加して bundle install を実行してインストールします。

```ruby
group :development do
  gem 'hirb'
  gem 'hirb-unicode'
end
```

あとは rails console を起動して Hirb.enable と打つだけで使用可能になります。

```sh
ruby-1.9.2-p180 > Hirb.enable
 => true 
ruby-1.9.2-p180 > Prefecture.limit(3)
  Prefecture Load (0.3ms)  SELECT `prefectures`.* FROM `prefectures` LIMIT 3
+----+--------+
| id | name   |
+----+--------+
| 1  | 北海道 |
| 2  | 青森県 |
| 3  | 岩手県 |
+----+--------+
3 rows in set
```

すばらしい！ちなみにウインドウが狭い場合は自動で文字を省略するので見にくくなることも無さそうです。

```sh
ruby-1.9.2-p180 > Gender.limit(3)
  Gender Load (0.4ms)  SELECT `genders`.* FROM `genders` LIMIT 3
+----+------+---------------+---------------+
| id | name | created_at    | updated_at    |
+----+------+---------------+---------------+
| 1  | 女性 | 2011-04-27... | 2011-04-27... |
| 2  | 男性 | 2011-04-27... | 2011-04-27... |
| 3  | 秘密 | 2011-04-27... | 2011-04-27... |
+----+------+---------------+---------------+
3 rows in set
```

私は毎回 Hirb.enable と入力するのが面倒なので $HOME/.irbrc に書いて自動で実行されるようにしました。

```ruby
if defined? Rails::Console
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveResource::Base.logger = Logger.new(STDOUT)
 
  if defined? Hirb
    Hirb.enable
  end
end
```
