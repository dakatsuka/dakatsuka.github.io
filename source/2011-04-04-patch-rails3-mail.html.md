---
title: RFCに違反している（ドットが連続する）メールアドレスをRails3で扱うには
date: 2011-04-04
tags: Ruby, Rails
---

Rails3のActionMailer（Mail）で、DoCoMoやauに存在するRFC違反のメールアドレス（@の前にドットが連続するやつ）を受信するときの対処方法を書いておきます。

Rails2以前（TMail）のときはFromがnilになって取得出来なくて、仕方なくパーサを書き換えるという結構面倒な事をしていましたが、Rails3では一応取得することは出来ます。ただし、Fromのフォーマットによって挙動が変わってきますので注意が必要です。

具体的には下記のようになります。

```
# 通常のメールアドレスの場合
ruby-1.9.2-p180 > mail.from
=> ["d.akatsuka@gmail.com"]
ruby-1.9.2-p180 > mail.from.class
=> Mail::AddressContainer
 
# @の前にドットが連続するメールアドレスの場合
ruby-1.9.2-p180 > mail.from
=> d.akatsuka...@gmail.com
ruby-1.9.2-p180 > mail.from.class
=> ActiveSupport::Multibyte::Chars 
 
# @の前にドットが連続し、かつ名前が入っている場合
ruby-1.9.2-p180 > mail.from
=> Dai Akatsuka <d.akatsuka...@gmail.com>
ruby-1.9.2-p180 > mail.from.class
=> ActiveSupport::Multibyte::Chars
 
# @の前にドットが連続し、かつマルチバイトな名前が入っている場合
ruby-1.9.2-p180 > mail.from
=> "赤塚 <d.akatsuka...@gmail.com>"
ruby-1.9.2-p180 > mail.from.class
=> String
```

こ、これは面倒臭い（# ＾ω＾）

Fromのフォーマットによってオブジェクトまで変わってしまうと扱うのが面倒です。（しかもメールアドレスだけではなくて名前まで取得してしまうという。。）

そこでどのフォーマットのメールアドレスが来ても、FromをStringで取得出来るパッチを書きました。

```ruby
# coding: utf-8
 
module Mail
  class Message
    def from_with_patch_rfc_violation
      str = from_without_patch_rfc_violation
 
      begin
        str = str.join
      rescue
        str = str.to_s
      end
 
      str.scan(/^.*?([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+?)(?![a-zA-Z0-9._-]).*$/).flatten.first
    end
 
    alias_method_chain :from, :patch_rfc_violation
  end
end
```

上記パッチを config/initializers に mail_patch.rb として保存するだけでOKです。

```
ruby-1.9.2-p180 > mail.from
=> "d.akatsuka...@gmail.com"
ruby-1.9.2-p180 > mail.from.class
=> String
```

一応某サイトに仕込んで2週間ほど経過していますが、特に不具合は出ていないようです。もし同様の件で困っている方が居ましたらお試しください。
