---
title: Symfony2アプリをTravisでCIする
slug: symfony2-travis-ci
date: 2014-04-03
tags: [PHP,Symfony2]
---

.travis.ymlを下記のようにした。TravisはComposerもPHPUnitもパスが通った状態になっているため、ダウンロードするスクリプトをわざわざ書く必要はない。

CIの結果をHipChatに通知したい場合はnotificationsで設定するだけで良い。

```yaml
language: php

php:
  - 5.5

before_script:
  - composer install --dev
  - php app/console doctrine:database:create --env=test
  - php app/console doctrine:schema:create --env=test

script: phpunit -c app

notifications:
  hipchat: secret_token@room_name
```
