---
title: cucumberで携帯サイトをテストするには
date: 2010-11-01
tags: Ruby, Rails, BDD
---

達人出版会から出版された「[はじめる！Cucumber](http://tatsu-zine.com/books/2)」という本を本日購入しました。日本語で丁寧に書かれている良書で、cucumberをこれから触ってみたい方にはオススメです。

さて、このcucumberを携帯サイトのプロジェクトで使った場合、そのままだとUAで弾かれたりして使用出来ないかもしれません。その場合は、下記をfeatures/support/env.rbに追記することによって、UAの偽装と個体識別番号の付与が出来ます。

```ruby
前提 /^携帯でアクセスしている$/ do
  header('user_agent', 'DoCoMo/2.0 P906i(c100;TB;W24H15)')
  header('x_dcmguid',  'subscriber')
end
```
