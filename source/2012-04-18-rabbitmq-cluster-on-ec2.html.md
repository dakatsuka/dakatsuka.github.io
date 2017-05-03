---
title: Ubuntu on EC2でRabbitMQクラスタを構築する手順
date: 2012-04-18
tags: Ubuntu, RabbitMQ, AWS
---

EC2 で動かしている Ubuntu Server 11.10 に RabbitMQ クラスタを構築したのでその時の手順をブログに残しておきます。ホスト名の設定で若干手こずりました…。

## RabbitMQをインストール
オフィシャルで配布されているパッケージを使うのがお手軽です。

```
cd /tmp
wget wget http://www.rabbitmq.com/releases/rabbitmq-server/v2.8.1/rabbitmq-server_2.8.1-1_all.deb
sudo apt-get install erlang-nox
sudo dpkg -i rabbitmq-server_2.8.1-1_all.deb
```

下記コマンドでエラーが出なければ、正常にRabbitMQが起動しています。

```
sudo rabbitmqctl status
```

## RabbitMQの初期設定
RabbitMQはデフォルトでノード名がインストールしたサーバのhostname -sになっています。このノード名を変更するには /etc/rabbitmq/rabbitmq-env.conf でNODENAMEを指定すれば良いのですが、何故かNODENAMEにはFQDNが使えません。

このままだと、別のRabbitMQサーバをクラスタに追加する時にノード名の不一致が起き、正常に追加出来ないという罠が待っています。まぁ、/etc/hosts に全サーバのホスト名を書いていけば問題無いのですが、EC2だとインスタンスの再起動でIPとホスト名が変わったりするので、あまり現実的ではありませんね。極力ドメイン名で処理したいところです。

そこで /etc/rabbitmq/rabbitmq-env.conf でFQDNが使えるようにRabbitMQ本体に若干手を加えます。といってもオプションを書き換えるだけです。

書き換える前にサーバを停止しておきます。

```
sudo /etc/init.d/rabbitmq-server stop
```

/usr/lib/rabbitmq/lib/rabbitmq\_server-2.8.1/sbin/rabbitmq-server

```diff
--- rabbitmq-Server2012-04-18 16:17:39.168100001 +0900
+++ rabbitmq-Server2012-04-18 16:17:13.304100001 +0900
@@ -102,7 +102,7 @@
 exec erl \
     ${RABBITMQ_EBIN_PATH} \
     ${RABBITMQ_START_RABBIT} \
-    -sname ${RABBITMQ_NODENAME} \
+    -name ${RABBITMQ_NODENAME} \
     -boot ${RABBITMQ_BOOT_FILE} \
     ${RABBITMQ_CONFIG_ARG} \
     +W w \
```

/usr/lib/rabbitmq/lib/rabbitmq\_server-2.8.1/sbin/rabbitmqctl

```diff
--- rabbitmqctl2012-04-18 16:12:54.016100001 +0900
+++ rabbitmqctl2012-04-18 16:12:32.828100000 +0900
@@ -31,7 +31,7 @@
     -noinput \
     -hidden \
     ${RABBITMQ_CTL_ERL_ARGS} \
-    -sname rabbitmqctl$$ \
+    -name rabbitmqctl$$ \
     -s rabbit_control \
     -nodename $RABBITMQ_NODENAME \
     -extra "$@"
```

/etc/rabbitmq/rabbitmq-env.conf は下記のようにします。

```
NODENAME=rabbit@rabbit1.foo.bar.internal
```

これでRabbitMQを再度起動させてエラーが出なければ設定完了です。

## クラスタ化する
rabbit1.foo.bar.internal と rabbit2.foobar.internal に対して、上記手順に則ってRabbitMQをインストールしたと仮定します。

rabbit1を初期化する

```
rabbit1% sudo rabbitmqctl stop_app
rabbit1% sudo rabbitmqctl reset
```

rabbit1上でrabbit2をクラスタに参加させる

```
rabbit1% sudo rabbitmqctl cluster rabbit2.foo.bar.internal
rabbit1% sudo rabbitmqctl start_app
```

クラスタに追加されているか確認する

```
rabbit1% sudo rabbitmqctl cluster_status
 
Cluster status of node 'rabbit@rabbit1.foo.bar.internal' ...
[{nodes,[{disc,['rabbit@rabbit2.foo.bar.internal']},
         {ram,['rabbit@rabbit1.foo.bar.internal']}]},
 {running_nodes,['rabbit@rabbit2.foo.bar.internal',
                 'rabbit@rabbit1.foo.bar.internal']}]
...done.
```

追加されてますね。rabbit2からも確認してみます。

```
rabbit2% sudo rabbitmqctl cluster_status
 
Cluster status of node 'rabbit@rabbit2.foo.bar.internal' ...
[{nodes,[{disc,['rabbit@rabbit2.foo.bar.internal']},
         {ram,['rabbit@rabbit1.foo.bar.internal']}]},
 {running_nodes,['rabbit@rabbit1.foo.bar.internal',
                 'rabbit@rabbit2.foo.bar.internal']}]
...done.
```

これでrabbit1, rabbit2どちらに接続してもキューをpublish, subscribeすることが出来ます。クラスタ化自体はそこまで難しくないと思います。

詳しくは[オフィシャルドキュメント](http://www.rabbitmq.com/clustering.html)に全部書いてあるので、そちらを参照してください。
