---
title: CircleCIでPackerを使う
date: 2015-01-28
tags: CI
---

コンテナ起動後にLinux版Packerをダウンロードして、パスの通っている場所に配置すれば動く。毎回Packerをダウンロードするのは無駄なのでキャッシュしておく。

```yaml
# circle.yml
machine:
    post:
      - "if [[ ! -e ~/packer ]]; then cd ~ && wget --no-check-certificate https://dl.bintray.com/mitchellh/packer/packer_0.7.5_linux_amd64.zip && unzip -d packer packer_0.7.5_linux_amd64.zip ;fi"
      - "if [[ ! -e ~/bin/packer ]]; then ln -s ~/packer/packer ~/bin/packer ;fi"

dependencies:
    cache_directories:
      - ~/packer

deployment:
    production:
        branch: deployment/production
        commands:
            - packer build amazon-ebs.json
                  timeout: 600
```

AMIの作成は時間がかかるので、念のためタイムアウトの閾値は上げておいたほうが安心。
