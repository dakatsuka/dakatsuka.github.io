---
title: has_one関連でaccepts_nested_attributes_for / fields_forを使う
date: 2011-09-30
tags: Ruby, Rails
---

先日、has\_one関連でaccepts\_nested\_attributesを使ってフォームを作ろうとしたら、ネスト先のフィールドが画面に出てこなくて小一時間ハマりました。そういえば以前も同じ事で悩んだような気がしたのでブログに残しておきます。

UserモデルとProfileモデルが存在し、1対1の関連で結ばれているよくある構成を例にします。ユーザー登録を行うフォームで同時にプロフィールも登録出来るようにします。

Userモデル

```ruby
class User < ActiveRecord::Base
  has_one :profile
  accepts_nested_attributes_for :profile
end
```

Profileモデル

```ruby
class Profile < ActiveRecord::Base
  belongs_to :profile
end
```

\_form.html.hamlビュー

```ruby
= form_for @user do |f|
  = f.fields_for :profile, @user.profile || Profile.new do |p|
    .field
      = p.label :nickname
      = p.text_field :nickname
```

上のコードのように fields\_for の第二引数で@user.profileが存在するかチェックし、存在しない場合はProfileのインスタンスを新規に作成します。こうすることで new, edit 両方に対応することが出来ます。
