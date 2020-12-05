---
title: CloudWatchやAuto ScalingのアラームをSlackに通知するようにした
slug: amazon-sns-to-slack
date: 2015-03-24
tags: [AWS, Slack, Ruby]
categories: ["DevOps"]
---

CloudWatchやAuto Scalingのアラームは、Amazon SNSのTopicにPublishする仕組みになっていて、通常はこのTopicに通知先のメールアドレスを設定することが多いと思う。

メールでもあまり困らないんだけど、社内ではChatOpsを進めていてコミュニケーションツールにSlackを使っているので、ほとんどメールの出番がない。必然的にメーラーよりSlackを立ち上げている時間が長いので、通知系はSlackに集約したくなった。

こんな感じでチャットに流れてくるようになって満足度高い。

{{<figure src="/media/2015-03-24-amazon-sns-to-slack/amazon-sns-to-slack01.png">}}
{{<figure src="/media/2015-03-24-amazon-sns-to-slack/amazon-sns-to-slack02.png">}}

念のためメールアドレスにも通知するようにはしているけど、今のところSlackに通知が来なかったり遅れてくることはない。スマートフォンへのプッシュもSlack任せにしている。

## 仕組み

Amazon SNSから直接Slackにリクエストを送ることは出来ないので、中継サーバを立てる必要がある。今回はSinatraでサクッと実装してHerokuにデプロイして使ってます。中継サーバが死んだ場合は当然通知は来ないので、この辺はそのうち考えたい。

コードを整理してGitHubに公開したのでご自由に使ってください。CloudWatchとAuto Scaling以外に対応したい場合も簡単に追加できる仕組みにはなってます。PRもお待ちしてます。

[dakatsuka/amazon-sns-to-slack](https://github.com/dakatsuka/amazon-sns-to-slack)
