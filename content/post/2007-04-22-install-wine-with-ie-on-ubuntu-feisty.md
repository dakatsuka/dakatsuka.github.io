---
title: Ubuntu FeistyにWineとIEを無理矢理インストール
slug: install-wine-with-ie-on-ubuntu-feisty
date: 2007-04-22
tags: [Linux, Ubuntu]
---

64bit環境だと apt-get install wine で導入出来なかったので --force-architecture オプションで無理矢理入れる方法。

## Wineをインストール

i386用のdebパッケージを落としてきます。

```sh
cd /tmp
wget http://wine.budgetdedicated.com/apt/pool/main/w/wine/wine_0.9.35~winehq0~ubuntu~7.04-1_i386.deb
```

ia32-libsを入れた後（入ってなかったら）dpkgでインストール。

```sh
sudo apt-get install ia32-libs
sudo dpkg -i --force-architecture wine_0.9.35~winehq0~ubuntu~7.04-1_i386.deb
```

## IEs4Linuxをインストール

事前にcabextractをいれておきます。

```sh
sudo apt-get install cabextract
```

IEs4Linuxのbeta6をダウンロードしてインストールします。

```sh
wget http://www.tatanka.com.br/ies4linux/downloads/ies4linux-2.5beta6.tar.gz
tar zxvf ies4linux-2.5beta6.tar.gz
cd ies4linux-*
./ies4linux
```

デフォルトのまま作業を進めるとデスクトップにIEのアイコンが出来ますので、それをダブルクリックすればIEが起動します。

…JAを選んでインストールしたせいかメニューが激しく文字化けしました。もしかしたら英語で入れたほうが幸せになれるかもしれません。
