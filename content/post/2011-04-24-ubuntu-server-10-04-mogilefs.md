---
title: Ubuntu Server 10.04に分散ファイルシステム MogileFSを入れてみた
slug: ubuntu-server-10-04-mogilefs
date: 2011-04-24
tags: [Ubuntu, MogileFS]
---

Ubuntu Server 10.04 に 分散ファイルシステム「MogileFS」をインストール＆初期設定をして動作するところまで書いてみます。

MogileFS には次のような特徴があります。

* Perl で実装されている
* HTTPを利用（NFSとか使わなくてOK）
* 自動フェイルオーバー
* 自動レプリケーション
* そこそこ実績がある（たしかはてなでも使われていたはず）

以下参考にさせて頂いたサイトです。

* [分散ファイルシステム MogileFS について : Tech Talk Blog – Six Apart](http://www.sixapart.jp/techtalk/2006/10/dev_mogilefs.html)
* [MogileFS のインストールと初期設定 : Tech Talk Blog – Six Apart](http://www.sixapart.jp/techtalk/2006/10/dev_mogilefs_install.html)
* [MogileFSで構築する高速スケーラブルな分散ファイルシステム – builder](http://builder.japan.zdnet.com/virtualization/sp_open-source-software-moonlinx-2009/20391825/)
* [PerlbalでMogileFSを更に高速化、効率化する – builder](http://builder.japan.zdnet.com/virtualization/sp_open-source-software-moonlinx-2009/20391968/)
* [OSS分散ファイルシステムMogileFS で組む素敵システム](http://www.slideshare.net/kazuhisa/090214ldd-mogilefs)

## 動作環境

* Ubuntu Server 10.04 LTS / 64bit
* MySQL 5.1
* Perl 5.10.1

## MogileFSが依存しているライブラリなどを入れる

あらかじめGCC、MySQLをインストールしておきます。

```sh
sudo apt-get install build-essential mysql-server-5.1 libmysqlclient16-dev
```

次にMogileFSのインストールに必要なライブラリをCPANでインストールします。

```sh
$ sudo cpan
cpan[1]> install YAML
capn[2]> install Net::Netmask
cpan[3]> install Danga::Socket
cpan[4]> install IO::AIO
cpan[5]> install IO::WrapTie
cpan[6]> install DBI
cpan[7]> install DBD::mysql
cpan[8]> install Perlbal
```

## MogileFSのインストール

MogileFS-Clientのソースをダウンロード、展開、インストールします。

```sh
$ cd /usr/local/src
$ sudo wget http://search.cpan.org/CPAN/authors/id/D/DO/DORMANDO/MogileFS-Client-1.14.tar.gz
$ sudo tar zxvf sudo tar zxvf MogileFS-Client-1.14.tar.gz
$ cd MogileFS-Client-1.14/
$ sudo perl Makefile.PL
$ sudo make
$ sudo make install
```

MogileFS-Utilsのソースをダウンロード、展開、インストールします。

```sh
$ cd /usr/local/src
$ sudo wget http://search.cpan.org/CPAN/authors/id/D/DO/DORMANDO/MogileFS-Utils-2.19.tar.gz
$ sudo tar zxvf MogileFS-Utils-2.19.tar.gz
$ cd MogileFS-Utils-2.19/
$ sudo perl Makefile.PL
$ sudo make
$ sudo make install
```

MogileFS-Serverのソースをダウンロード、展開、インストールします。

```sh
$ cd /usr/local/src
$ sudo wget http://search.cpan.org/CPAN/authors/id/D/DO/DORMANDO/MogileFS-Server-2.46.tar.gz
$ sudo tar zxvf MogileFS-Server-2.46.tar.gz
$ cd MogileFS-Server-2.46/
$ sudo perl Makefile.PL
$ sudo make
$ sudo make install
```

## MogileFSの初期設定

DBにスキーマを作成します。一発でDB、ユーザーを作成してくれるコマンドがあるので利用します。

```sh
mogdbsetup --dbrootuser=root --dbrootpass=hogehoge --dbuser=mogilefs --dbpass=mogilefs --yes
```

### Trackerの設定（mogilefsd）

デフォルトだと /etc/mogilefs/mogilefsd.conf を読みに行きます。特に変更する必要も無いのでデフォルトのままいきます。変更したい場合は -c で指定出来ます。

```sh
$ sudo mkdir /etc/mogilefs
```

/etc/mogilefs/mogilefsd.conf は[このページを参考](http://www.sixapart.jp/techtalk/2006/10/dev_mogilefs_install.html)にして次のようにしました。

```conf
daemonize = 1
db_dsn = DBI:mysql:mogilefs:host=127.0.0.1
db_user = mogilefs
db_pass = mogilefs
conf_port = 7001
listener_jobs = 10
```

Trackerは root ユーザーでは実行出来ませんので 専用のユーザーを作ってあげる必要があります。

```sh
sudo useradd -s /bin/false mogilefs
sudo -u mogilefs mogilefsd
```

psコマンドで起動しているか確認。

```sh
$ ps ax | grep mogilefsd
11160 ?        S      0:00 mogilefsd
11161 ?        S      0:00 mogilefsd [replicate]
11162 ?        S      0:00 mogilefsd [delete]
11163 ?        S      0:00 mogilefsd [queryworker]
11164 ?        S      0:00 mogilefsd [queryworker]
11165 ?        S      0:00 mogilefsd [queryworker]
11166 ?        S      0:00 mogilefsd [queryworker]
11167 ?        S      0:00 mogilefsd [queryworker]
11168 ?        S      0:00 mogilefsd [queryworker]
11169 ?        S      0:00 mogilefsd [queryworker]
11170 ?        S      0:00 mogilefsd [queryworker]
11171 ?        S      0:00 mogilefsd [queryworker]
11172 ?        S      0:00 mogilefsd [queryworker]
11173 ?        S      0:00 mogilefsd [monitor]
11174 ?        S      0:00 mogilefsd [reaper]
11175 ?        S      0:00 mogilefsd [job_master]
11176 ?        SN     0:00 mogilefsd [fsck]
```

### Storage nodeの設定（mogstored）

デフォルトだと /etc/mogilefs/mogstored.conf を読みに行きます。Trackerと同様、変更したい場合は -c で指定出来ます。

```conf
httplisten = 0.0.0.0:7500
mgmtlisten = 0.0.0.0:7501
docroot = /var/mogdata
```

/etc/mogilefs/mogstored.conf で指定したdocrootのディレクトリを作成します。

```sh
sudo mkdir /var/mogdata
```

Trackerとは違いStorage nodeは root ユーザーで起動させます。

```sh
$ sudo mogstored -d
$ ps ax | grep mogstored
11209 ?        Ss     0:00 mogstored
11210 ?        S      0:00 mogstored [diskusage]
11211 ?        S      0:00 mogstored [iostat]
```

## Storage node の登録

上記インストール・初期設定が終われば、あとはmogadmコマンドを使用して設定していくことが出来ます。

Trackerが正常に動作しているか確認。

```sh
$ mogadm check
Checking trackers...
  127.0.0.1:7001 ... OK
 
Checking hosts...
No devices found on tracker(s).
```

TrackerはOKと出ていますが、Checking hosts…ではNo devicesと出てしまっていますので、mogadm host add で Storage node を登録します。

```sh
$ mogadm host add localhost --port=7500
$ mogadm check
Checking trackers...
  127.0.0.1:7001 ... OK
 
Checking hosts...
  [ 1] localhost ... skipping; status = down
No devices found on tracker(s).
```

## Deviceの登録

```sh
$ mogadm device add localhost 1
$ mogadm device add localhost 2
$ sudo mkdir /var/mogdata/{dev1,dev2}
$ mogadm device list
localhost [1]: down
                   used(G) free(G) total(G)
  dev1: down       0.000   0.000   0.000  
  dev2: down       0.000   0.000   0.000
```

downとなっているので有効にしてあげます。

```sh
$ mogadm host mark localhost alive
$ mogadm check
Checking trackers...
  127.0.0.1:7001 ... OK
 
Checking hosts...
  [ 1] localhost ... OK
 
Checking devices...
  host device         size(G)    used(G)    free(G)   use%   ob state   I/O%
  ---- ------------ ---------- ---------- ---------- ------ ---------- -----
  [ 1] dev1             7.109      1.066      6.042  15.00%  writeable   0.0
  [ 1] dev2             7.109      1.066      6.042  15.00%  writeable   0.0
  ---- ------------ ---------- ---------- ---------- ------
             total:    14.217      2.132     12.085  15.00%
```

これでようやくMogileFSが使用可能になりました！

MogileFSのクライアントはPerl以外でも出ていますので、分散ストレージとして色々使い道があるのではないでしょうか。私の会社ではRailsアプリの画像ストレージとして利用しています。
