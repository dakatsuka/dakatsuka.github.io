---
title: OCamlでLuhnアルゴリズムを書いてみる
slug: ocaml-luhn
date: 2016-02-22
tags: [OCaml]
---

OCamlに慣れるために何か書こうと思ったけど、あまりいいネタが思い浮かばなかったのでLuhnアルゴリズムを書いてみた。クレジットカードの番号などを検証することができる。

```ocaml
#load "str.cma";;

let check_number number =
  let calculate i x =
    if i mod 2 = 0 then
      int_of_string x
    else
      let d = int_of_string x * 2 in d mod 10 + d / 10
  in

  Str.split (Str.regexp "") number
  |> List.rev
  |> List.mapi calculate
  |> List.fold_left (fun x y -> x + y) 0
  |> fun i -> i mod 10 = 0

let _ =
  (* テスト用のクレジットカード番号 *)
  let numbers = [
    "5555555555554444";
    "5105105105105100";
    "4111111111111111";
    "4012888888881881";
    "3530111333300000";
    "3566002020360505";
    "30569309025904";
    "38520000023237";
    "378282246310005";
    "371449635398431";
    "378734493671000";
    "6011111111111117";
    "6011000990139424";
  ] in
  List.iter (fun n -> n |> check_number |> string_of_bool |> print_string) numbers
```

### 参考文献

* [チェックディジット - Wikipedia](https://ja.wikipedia.org/wiki/%E3%83%81%E3%82%A7%E3%83%83%E3%82%AF%E3%83%87%E3%82%A3%E3%82%B8%E3%83%83%E3%83%88)
* [Luhnアルゴリズム - Wikipedia](https://ja.wikipedia.org/wiki/Luhn%E3%82%A2%E3%83%AB%E3%82%B4%E3%83%AA%E3%82%BA%E3%83%A0)
* [クレジットカード番号についてのメモ at softelメモ](https://www.softel.co.jp/blogs/tech/archives/4388)

### 追記

有益な情報をいただきました。演算子気をつけよう

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr"><a href="https://twitter.com/d_akatsuka">@d_akatsuka</a> == じゃなくて = を使ったほうが良いです。そのコードでは問題ないんですけども、ポインタ比較を間違って使ってハマる人多いので</p>&mdash; らくだの卯之助 (@camloeba) <a href="https://twitter.com/camloeba/status/701638766235025409">2016, 2月 22</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
