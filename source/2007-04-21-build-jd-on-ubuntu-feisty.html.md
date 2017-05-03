---
title: 64bit環境のUbuntu FeistyでJDをビルド
date: 2007-04-21
tags: Linux, Ubuntu
---

Feistyの日本語ローカライズ版が出ました。しかしAMD64への対応はもうちょっとかかるみたいなので、気が短い私はリリースまでの間JD（2ちゃんねるブラウザ）を自前でビルドして使おうと思います。

アンインストールも手軽に出来るようにdebパッケージ化までしてみます。

## 必要なパッケージをインストール

まずdebパッケージを作成するのに必要なツールをインスコします。（余計なものまで入れたかも…

```
$ sudo apt-get install autoconf automake libtool libc6-dev dpkg-dev gpc fakeroot debhelper lintian devscripts g++ dh-make g77
```

次にJDのビルドに必要なライブラリを入れておきます。

```
$ sudo apt-get install libgtkmm-2.4-dev zlib1g-dev libssl-dev
```

## パッケージ化

最新のソースをダウンロードしてきて適当なディレクトリに解凍します。

```
$ mkdir /tmp/deb
$ cd /tmp/deb
$ wget http://keihanna.dl.sourceforge.jp/jd4linux/24814/jd-1.8.8-070403.tgz
$ tar zxvf jd-1.8.8-070403.tgz
$ cd jd-1.8.8-070403
```

autoreconfを実行します。

```
$ autoreconf -i
```

パッケージの基本情報ファイルを作る

```
$ dh_make -e clavice@dotted.jp -s -f ../jd-1.8.8-070403.tgz
```

個人用なので何も変更せずこのままパッケージ化

```
$ dpkg-buildpackage -rfakeroot
```

ビルドが終わるとひとつ上の階層（ここでは/tmp/deb）にパッケージが出来上がっています。

## インストール

出来上がったパッケージ jd-1.8.8_070403-1_amd64.deb をダブルクリックしてインストール出来ます。

起動方法は、

```
$ jd
```

です。かなりやっつけですがこれでJDが使えるようになります。
