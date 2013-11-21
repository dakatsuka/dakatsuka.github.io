---
title: 複数のRailsアプリが同居しているGitリポジトリをデプロイする方法
date: 2011-05-25
tags: Ruby, Rails, Git, Capistrano
---

複数のRailsアプリが１つのリポジトリに同居しているような状態で Capistrano を使ってデプロイしたい場合、そのままでは動作しないので少々手を加える必要があります。

下記のようにRailsアプリがサブディレクトリにある場合を想定しています。

```
repogitory/
      ├── admin
      ├── mobile
      ├── share
```

## Capfileを書き換える

通常の手順通り、Rails.root 直下に Capfile を設置し config/deploy.rb にレシピを書いていくのですが、上記のようにリポジトリ直下 = Rails.root では無い場合、Capfile を少し変更する必要があります。

Stackoverflow の [Deploying a Git subdirectory in Capistrano](http://stackoverflow.com/questions/29168/deploying-a-git-subdirectory-in-capistrano) を参考に（というかほぼそのままですが）Capfile を以下のようにします。オリジナルと違う箇所はcpのオプションです。オリジナルのほうはシンボリックリンクをシンボリックリンクとしてコピーしますが、このコードは実体ファイルをコピーします。

```ruby
require 'capistrano/recipes/deploy/strategy/remote_cache'
 
class RemoteCacheSubdir < Capistrano::Deploy::Strategy::RemoteCache
  private
  def repository_cache_subdir
    if configuration[:deploy_subdir] then
      File.join(repository_cache, configuration[:deploy_subdir])
    else
      repository_cache
    end
  end
 
  def copy_repository_cache
    logger.trace "copying the cached version to #{configuration[:release_path]}"
    if copy_exclude.empty? 
      run "cp -RpL #{repository_cache_subdir} #{configuration[:release_path]} && #{mark}"
    else
      exclusions = copy_exclude.map { |e| "--exclude=\"#{e}\"" }.join(' ')
      run "rsync -lrpt #{exclusions} #{repository_cache_subdir}/* #{configuration[:release_path]} && #{mark}"
    end
  end
end
 
set :strategy, RemoteCacheSubdir.new(self)
```

Capfile を書き換えたら deploy.rb を次のようにすれば指定したサブディレクトリだけをデプロイする事が出来ます。

```ruby
require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'erb'
 
set :application,   "app"
set :scm,           :git
set :repository,    "git://domain.com/path/to/repository.git"
set :deploy_subdir, "/path/to/app" # require https://gist.github.com/970910 to Capfile
set :deploy_via,    :copy
set :use_sudo,      false
set :bundle_without, [:development, :test]
```

## そもそも

何故このような構成になってるかというと、admin、mobileでモデルとライブラリを共通化したくなった為です。共通ファイルを share に放り込み、各Railsアプリからはシンボリックリンクで参照する形にしています。最初は Git の submodule を考えたのですがどうもしっくり来なかったんですよね。。。
