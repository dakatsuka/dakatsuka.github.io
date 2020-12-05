---
title: node.js + expressでTwitter認証
slug: node-express-twitter
date: 2011-06-08
tags: [Node.js]
---

node.js + express でTwitter認証をしてみました。今回は取得した情報をセッションに格納していますが、これを MySQL や MongoDB に保存すれば「Twitterでログイン」みたいな事は簡単に出来そうですね。

下記環境で動作確認しています。

* Node.js v0.4.8
* express v2.3.11
* jade v0.12.1
* oauth v0.9.0

## 実装する

必要なモジュールを npm でインストールします。

```sh
npm install express oauth jade
```

app.js は下記のように実装しました。

```javascript
// This program is free software. It comes without any warranty, to
// the extent permitted by applicable law. You can redistribute it
// and/or modify it under the terms of the Do What The Fuck You Want
// To Public License, Version 2, as published by Sam Hocevar. See
// http://sam.zoy.org/wtfpl/COPYING for more details.
 
var express = require('express');
var app = express.createServer();
var oauth = new (require('oauth').OAuth)(
    'https://api.twitter.com/oauth/request_token',
    'https://api.twitter.com/oauth/access_token',
    'CONSUMER KEY',
    'CONSUMER SECRET',
    '1.0',
    'http://localhost:3000/auth/twitter/callback',
    'HMAC-SHA1'
);
 
app.configure(function() {
    app.use(express.logger());
    app.use(express.bodyParser());
    app.use(express.cookieParser());
    app.use(express.session({ secret: "secret" }));
    app.set('view engine', 'jade')
});
 
app.dynamicHelpers({
    session: function(req, res) {
        return req.session;
    }
});
 
app.get('/', function(req, res) {
    res.render('index', { layout: false });
});
 
app.get('/auth/twitter', function(req, res) {
    oauth.getOAuthRequestToken(function(error, oauth_token, oauth_token_secret, results) {
        if(error) {
            res.send(error)
        } else {
            req.session.oauth = {};
            req.session.oauth.token = oauth_token;
            req.session.oauth.token_secret = oauth_token_secret;
            res.redirect('https://twitter.com/oauth/authenticate?oauth_token=' + oauth_token);
        }
    });
});
 
app.get('/auth/twitter/callback', function(req, res) {
    if(req.session.oauth) {
        req.session.oauth.verifier = req.query.oauth_verifier;
 
        oauth.getOAuthAccessToken(req.session.oauth.token, req.session.oauth.token_secret, req.session.oauth.verifier,
            function(error, oauth_access_token, oauth_access_token_secret, results) {
                if(error) {
                    res.send(error);
                } else {
                    req.session.oauth.access_token = oauth_access_token;
                    req.session.oauth.access_token_secret = oauth_access_token_secret;
                    req.session.user_profile = results
                    res.redirect('/');
                }
            }
        );
    }
});
 
app.get('/signout', function(req, res) {
    delete req.session.oauth;
    delete req.session.user_profile;
    res.redirect('/');
});
 
app.listen(3000);
```

views/index.jade はこんな感じに。

```jade
!!! 5
html(lang="ja")
  head
    title node.js sample app
  body
    h1 node.js sample app
    - if (session.user_profile)
      p= "Welcome, " + session.user_profile.screen_name
      p
        a(href="/signout") Sign out
    - else
      p
        a(href="/auth/twitter") Sign in with twitter
```

以上、2ファイルを作成したら下記コマンドで起動します。

```
node app.js
```

http://localhost:3000/ にアクセスし「Sign in with twitter」のリンクをクリックすれば Twitter に飛んで認証する事が出来ます。
