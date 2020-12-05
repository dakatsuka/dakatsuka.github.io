---
title: CircleCIでElasticsearchを使うならDockerがよさそう
slug: elasticsearch-on-circleci
date: 2015-08-22
tags: [CI, Elasticsearch]
---

CircleCIでElasticsearchの最新版とKuromojiを使うならDockerが便利だった。circle.ymlでwgetして頑張るよりは[^1]こちらのほうがスマートだし、ここで用意したDockerfileはCI以外でも使える。

下記コードをcontainers/elasticsearch/Dockerfileに保存する。

```Dockerfile
FROM elasticsearch:1.7.1

RUN plugin install mobz/elasticsearch-head
RUN plugin install elasticsearch/elasticsearch-analysis-kuromoji/2.7.0
```

circle.ymlでDockerを有効化して、dependenciesでコンテナを起動するだけ。

```yaml
machine:
  services:
    - docker

dependencies:
  override:
    - docker build -t foobar/elasticsearch:1.7.1 ./containers/elasticsearch
    - docker run -d -p 9200:9200 -p 9300:9300 foobar/elasticsearch:1.7.1
```

で、このエントリを書いている最中に https://github.com/circleci/docker-elasticsearch そのものズバリのリポジトリを発見した。こちらのほうがイメージのキャッシュまでしているので参考になると思う。

[^1]: [Install a custom version of Elasticsearch](https://circleci.com/docs/installing-elasticsearch)
