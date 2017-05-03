---
title: Node.js アプリをデプロイして Upstart で起動させる Capistrano レシピを書いた
date: 2011-10-13
tags: Node.js, Capistrano
---

Node.js アプリをデプロイする場合、Heroku などの PaaS を使っているとすごく簡単なのですが、デプロイ先が VPS や専用サーバの場合、何かしらのツールを使ってデプロイをする事になると思います。

今回はデプロイツールに Capistrano を使うことにしました。ただ、Capistrano はそのままだと Rails 用になっているので、Node.js 用に少しレシピを書き換えます。ちなみに当初の予定では起動・監視ツールに Node.js製の Forever を使うはずだったのですが、v0.5系でうまく動作しなかったので急遽 Upstart で代用することにしました。他にも Upstart + God という組み合わせも良さそうですがまだ未検証。

```ruby
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.
 
set :application, "nodeapp"
set :scm,         :git
set :repository,  "git://github.com:hogehoge/foobar.git"
set :branch,      "master"
set :deploy_via,  :remote_cache
set :deploy_to,   "/home/nodeapp/#{application}"
set :node_path,   "/opt/node-current/bin"
set :node_script, "app.js"
 
set :user, "nodeapp"
set :use_sudo, true
set :default_run_options, :pty => true
 
role :app, "xxx.xxx.xxx.xxx"
 
set :shared_children, %w(log node_modules)
 
namespace :deploy do
  task :default do
    update
    start
  end
 
  task :cold do
    update
    start
  end
  
  task :setup, :expect => { :no_release => true } do
    dirs  = [deploy_to, releases_path, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "mkdir -p #{dirs.join(' ')}"
    run "chmod g+w #{dirs.join(' ')}" if fetch(:group_writable, true)
  end
  
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
    run <<-CMD
      rm -rf #{latest_release}/log #{latest_release}/node_modules &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/node_modules #{latest_release}/node_modules
    CMD
  end
  
  task :start, :roles => :app do
    run "#{sudo} restart #{application} || #{sudo} start #{application}"
  end
 
  task :stop, :roles => :app do
    run "#{sudo} stop #{application}"
  end
 
  task :restart, :roles => :app do
    start
  end
  
  task :npm, :roles => :app do
    run <<-CMD
      export PATH=#{node_path}:$PATH &&
      cd #{latest_release} &&
      npm install 
    CMD
  end
  
  task :write_upstart_script, :roles => :app do
    upstart_script = <<-UPSTART_SCRIPT
description "#{application} upstart script"
start on (local-filesystem and net-device-up)
stop on shutdown
respawn
respawn limit 5 60
script
  chdir #{current_path}
  exec sudo -u #{user} NODE_ENV="production" #{node_path}/node #{node_script} >> log/production.log 2>&1
end script
    UPSTART_SCRIPT
    
    put upstart_script "/tmp/#{application}.conf"
    run "#{sudo} mv /tmp/#{application}.conf /etc/init"
  end
end
 
after 'deploy:setup', 'deploy:write_upstart_script'
after 'deploy:finalize_update', 'deploy:npm'
```

## 使い方

set :node\_pathで Node.js がインストールされているパスを指定し、set :node\_scriptで起動したいJSファイルを指定します。あとの項目は通常のデプロイと変わらないと思います（上のレシピはGit前提で書いていますが）

デプロイ先に必要なディレクトリや Upstart のスクリプトを作成するには下記コマンドを使います。

```
cap deploy:setup
```

デプロイしてアプリを起動するには下記コマンドを使います。リポジトリに package.json を置いておけば自動的にnpm installが動いて node_modules にインストールされます。

```
cap deploy:cold
```

以上です。それでは、良い Node.js 生活を。
