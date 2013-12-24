---
title: テキストフィールドへの入力を検出して数秒おきにサーバに送信する
date: 2013-12-24
tags: JavaScript
---

サインアップフォームなどでユーザー名が取得可能かどうかAjaxで問い合わせるアレです。

愚直に実装するとkeyupイベントをキャッチして$.ajax()を使うだけですが、これだと1文字入力する毎にサーバのAPIを叩くことになってしまうので少し工夫。

Ajax通信をしたいテキストフィールドにデータ属性を作ってAPIのURLを書いておく。

```html
<input type="text" id="user_username" name="user[username]" data-autocheck="/autocheck/username">
```

JavaScriptは下記のように書く。

```javascript
$(document).on("keyup", "input[data-autocheck]", function() {
    var elem = $(this);
    var data = { url: elem.data("autocheck"), value: elem.val() };

    clearTimeout(elem.data("timer"));

    elem.data("timer", setTimeout(function() {
        $.ajax({
            type: "POST",
            url: data.url,
            data: { value: data.value }
        }).done(function(result) {


        });
    }, 400));
});
```
