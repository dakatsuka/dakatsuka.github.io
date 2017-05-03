---
title: Symfony2でサブドメインに対応したサイトを作る
date: 2014-08-28
tags: PHP,Symfony2
---

Symfony2では特定のBundleをサブドメインに切り出すことができる。正しくはBundle毎に任意のドメインを割り当てることができる。もちろん開発用のビルトインサーバでも使うことが可能。

将来的にサブドメインを使う想定があるならば、事前にBundleは分割しておくと良い。

## Example

AcmeWebBundleは `www.example.com` へ、AcmeSmartphoneBundleは `sp.example.com` に割り当てるようにする。

まずapp/config/parameters.yml にドメインを書いておく。パラメータ名は自由に決められるが、今回は下記のようにした。

```yaml
parameters:
    acme.www.host: www.example.com
    acme.smartphone.host: sp.example.com
```

app/config/routing.ymlでルーティングを下記のように設定する。通常のルーティングの設定にhost項目を増やすだけなので簡単ですね。どちらもprefixは `/` にしておくこと。

```yaml
acme_web:
    resource: "@AcmeWebBundle/Controller"
    type: annotation
    prefix: /
    host: "%acme.www.host%"

acme_smartphone:
    resource: "@AcmeSmartphoneBundle/Controller"
    type: annotation
    prefix: /
    host: "%acme.smartphone.host%"
```

これでAcmeWebBundleとAcmeSmartphoneBundle内のコントローラには指定したドメイン以外ではアクセス出来なくなる。また Twig の path 関数もよしなにやってくれる。ローカルで動作確認をしたい場合は/etc/hostsやDNSを書き換えて127.0.0.1に向けよう。

ただしローカル開発環境ではサブドメインではなくhttp://localhost:8000/sp/ でアクセス出来るようにしておくと開発しやすいケースもあると思うので、その場合は routing\_dev.yml を次のようにする。

```yaml
_main:
    resource: routing.yml

acme_web:
    resource: "@AcmeWebBundle/Controller"
    type: annotation
    prefix: /

acme_smartphone:
    resource: "@AcmeSmartphoneBundle/Controller"
    type: annotation
    prefix: /sp
```
