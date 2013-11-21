---
title: Chefで始めるシステム構成管理入門 その2 – インストールと初期設定
date: 2011-12-08
tags: Chef
---

前回に引き続き Chef に関するエントリです。このエントリではChef Serverのインストールと初期設定、更にNodeの接続までを書いていこうと思います。自分のメモ書きを整理して書き出しているので、何かおかしな箇所があったら是非指摘してください！

さて、作業を進めていく上で複数のマシンが出てくるので、便宜上、下図のようなネットワーク構成にしようと思います。192.168.50.100はグローバルIPだと思ってください。また、Chef Server, 各Nodeは全てUbuntu 11.10 Serverと仮定します（Debian squeezeでも大丈夫）。

![chef-network](/uploads/2011/12/08/chef-network.png)

## Chef Server はパッケージシステムからインストールするのが無難

前回の「Chefの仕組み」でも書いたように、自力で Chef Server をセットアップするのは骨が折れます。サーバの構築を自動化したいのに肝心のChefで手間取るなど本末転倒ですね。なるべくならディストリビューション付属のパッケージシステムで導入したいところです。

有り難いことに開発元の Opscode が、[Debina/Ubuntu用のAPT Repository](http://wiki.opscode.com/display/chef/Installing+Chef+Server+on+Debian+or+Ubuntu+using+Packages)を提供して下さっていますので迷わず利用しましょう。…CentOSは…美味しいんでしょうか…

作業手順は下記の通り。まずChef ServerにSSHでログインし、KeyとRepositoryを登録して apt-get で chef-server をインストールします。

```
# Ubuntu
chefserver:$ echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list
 
# Debian
chefserver:$ echo "deb http://apt.opscode.com/ squeeze-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list
 
chefserver:$ sudo apt-get update
chefserver:$ sudo apt-get install opscode-keyring
chefserver:$ sudo apt-get update
chefserver:$ sudo apt-get install chef-server
```

インストールの途中で3回質問が出ますので入力が必要になります。

![q1](/uploads/2011/12/08/chef-q1.png)

これはChef Server内にインストールされるChef ClientからみたChef Server APIのURIを入力します（分かりにくいｗ）。同一サーバなのでここではhttp://localhost:4000と入力してください。

![q2](/uploads/2011/12/08/chef-q2.png)

AMQP Server（RabbitMQ）のパスワードを入力します。任意の文字列を入力してください。ここで入力したパスワードは /etc/chef/solr.rb 内に記述されます。

![q3](/uploads/2011/12/08/chef-q3.png)

WebUIの初期ユーザー（admin）のパスワードを設定します。任意の文字列を入力してください。

インストールが無事終わるとChef Serverが自動的に立ち上がります。結構な量のパッケージが入りますので多少時間がかかると思います。

## 管理用Clientを登録する

Chef Serverのインストールが終わったら管理用Clientを登録します。ここで登録するClientはChef Server内でのみ使用します。

まずホームディレクトリに.chefディレクトリを作成し、鍵二種類を/etc/chefからコピーしてきます。

```
chefserver:$ mkdir -p ~/.chef
chefserver:$ sudo cp /etc/chef/validation.pem /etc/chef/webui.pem ~/.chef
chefserver:$ sudo chown -R $USER:$USER ~/.chef
```

そのあとにknifeコマンドで初期設定を行います。

```
chefserver:$ knife configure -i
WARNING: No knife configuration file found
Where should I put the config file? [~/.chef/knife.rb] [ENTER]
Please enter the chef server URL: [http://chefserver:4000] http://localhost:4000
Please enter a clientname for the new client: [username] master
Please enter the existing admin clientname: [chef-webui] [ENTER]
Please enter the location of the existing admin client's private key: [/etc/chef/webui.pem] /home/username/.chef/webui.pem
Please enter the validation clientname: [chef-validator] [ENTER]
Please enter the location of the validation key: [/etc/chef/validation.pem] /home/username/.chef/validation.pem
Please enter the path to a chef repository (or leave blank): [ENTER]
Creating initial API user...
Created client[master]
Configuration file written to /home/username/.chef/knife.rb
```

これでmasterという管理用Clientが登録されました。試しに下記コマンドを叩いてみましょう。

```
chefserver:$ knife client list
```

次のように返ってくれば成功です。

```
chefserver:$ knife client list
  chef
  chef-validator
  chef-webui
  master
```

Clientの詳細をみることも出来ます。

```
chefserver:$ knife client show master
_rev:        1-2901b7c2eb6d33b01f8f12951933b709
admin:       true
chef_type:   client
json_class:  Chef::ApiClient
name:        master
public_key:  -----BEGIN RSA PUBLIC KEY-----
             snip
             -----END RSA PUBLIC KEY-----
```

## ローカル環境用に管理用Clientを作成する

今後、Chefの操作はほぼKnifeコマンドで行う事になるのですが、毎回サーバにログインして作業するのは微妙です。Cookbookなどは別の環境で作成してGitなどのSCMで管理したいですよね。

ですので別の環境からでもアクセス出来る管理用Clientを作成したいと思います。

下記コマンドを実行しましょう。これはakatsukaという管理用Clientを作成するコマンドになります。Client名は適宜置き換えて下さい。

```
chefserver:$ knife client create akatsuka -n -a -f /tmp/akatsuka.pem
Created client[akatsuka]
```

ちゃんと作成出来ているか確認します。

```
chefserver:$ knife client list
  akatsuka
  chef
  chef-validator
  chef-webui
  master
```

あとは上記コマンドで生成された/tmp/akatsuka.pemと~/.chef/validation.pemの二つの鍵をSCPなどでローカル環境にコピーしてください。

## ローカル環境の準備

ローカル環境側はknifeコマンドを使うだけですので、RubyとRubygemsが入っていればgem installだけで済みます（Rubyのインストールは割愛します）。

```
workstation:$ gem install chef
```

インストールが終わったら先ほどSCPで持ってきた akatsuka.pem と validation.pem を ~/.chef にコピーして、下記コマンドを実行します。

```
workstation: $ knife configure
WARNING: No knife configuration file found
Where should I put the config file? [~/.chef/knife.rb] [ENTER]
Please enter the chef server URL: [http://workstation:4000] http://192.168.50.100:4000
Please enter an existing username or clientname for the API: [username] akatsuka
Please enter the validation clientname: [chef-validator] [ENTER]
Please enter the location of the validation key: [/etc/chef/validation.pem] /Users/username/.chef/validation.pem
Please enter the path to a chef repository (or leave blank): [ENTER]
*****
 
You must place your client key in:
  /Users/username/.chef/akatsuka.pem
Before running commands with Knife!
 
*****
 
You must place your validation key in:
  /Users/username/.chef/validation.pem
Before generating instance data with Knife!
 
*****
Configuration file written to /Users/username/.chef/knife.rb
```

ローカル環境からでも接続出来るか確認してみましょう。

```
workstation:$ knife client list
  akatsuka
  chef
  chef-validator
  chef-webui
  master
```

## Chef Server APIをHTTPSにしてセキュアにする

Chef Server APIのプロトコルは普通のHTTPなので、フロントエンドに nginx を置いてHTTPSに対応させます。

```
chefserver:$ sudo apt-get install nginx
```

OpenSSLを使って鍵を生成します。

```
chefserver:$ cd /etc/nginx
chefserver:$ sudo mkdir ssl
chefserver:$ sudo openssl req -new -key ssl/server.key -out ssl/server.csr
chefserver:$ sudo openssl x509 -in ssl/server.csr -out ssl/server.crt -req -signkey ssl/server.key -days 365
chefserver:$ sudo chmod 400 ssl/server.*
```

nginxのデフォルトファイルを削除します。

```
sudo rm -rf /etc/nginx/sites-enabled/default
```

/etc/nginx/conf.d/proxy.confを作成します。

```
# /etc/nginx/conf.d/proxy.conf
proxy_redirect                          off;
proxy_set_header Host                   $host;
proxy_set_header X-Real-IP              $remote_addr;
proxy_set_header X-Forwarded-Host       $host;
proxy_set_header X-Forwarded-Server     $host;
proxy_set_header X-Forwarded-For        $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto      https;
```

/etc/nginx/sites-available/sslを作成します。

```
# /etc/nginx/sites-available/ssl
server {
    listen 443;
    server_name localhost;
 
    ssl on;
    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;
    ssl_session_timeout 5m;
    ssl_protocols SSLv2 SSLv3 TLSv1;
    ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
    ssl_prefer_server_ciphers on;
 
    location / {
        proxy_pass http://127.0.0.1:4000/;
    }
}
```

上で作ったファイルのシンボリックリンクを/etc/nginx/sites-enabled内に作成します。

```
chefserver:$ sudo ln -s /etc/nginx/sites-available/ssl /etc/nginx/sites-enabled/ssl
```

nginxを起動させます。

```
chefserver:$ sudo /etc/init.d/nginx start
```

これでChef ServerはHTTPS対応になりました。ローカル環境のほうもHTTPSで繋がるように変更しておきましょう。~/.chef/knife.rbを開いてchef\_server\_urlの値を修正します。

```diff
-chef_server_url          'http://192.168.50.100:4000'
+chef_server_url          'https://192.168.50.100'
```

## まとめ

うーん・・・。書いていて思ったのはやはり手間ですね！もう少し何とかならないものか・・・。あと完全にWebUIをスルーしておりますが、今後もスルーする方向で行こうと思っています。理由は、WebUIだけだと出来ない事がある、何故かOpenIDを使ってログイン出来てしまう（致命的なような…）、そもそも使い勝手的にどうなんだ、といったところです。あと設定ファイルもローカルに残らないのでそれもマイナスですね。

さて、次はいよいよNodeを登録して実際にレシピを書いていこうと思います。年内に書ければいいなぁ
