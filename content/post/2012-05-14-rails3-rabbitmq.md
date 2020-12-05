---
title: Rails3 + unicornからRabbitMQに接続するには
slug: rails3-rabbitmq
date: 2012-05-14
tags: [Ruby, Rails, RabbitMQ]
---

[ruby-amqp](https://github.com/ruby-amqp/amqp)はEventMachineに依存しているので、unicorn上のRailsアプリからRabbitMQに接続する場合は少し手間がかかります。EventMachineで実装されているThinなどはそのまま動くようですが。。。

下記コードをconfig/unicorn.rbに追記します。

```ruby
ENV["UNICORN"] = "true"
 
after_fork do |server, worker|
  AMQPManager.start
end
```

config/amqp.ymlを用意します。

```yaml
development:
  uri: "amqp://localhost"
```

開発環境（WebRickなど）からもRabbitMQに接続出来るようにします。

```ruby
# config/initializers/amqp.rb
require 'amqp/utilities/event_loop_helper'
require 'amqp/integration/rails'
 
module AMQPManager
  def self.start
    AMQP::Utilities::EventLoopHelper.run
    AMQP::Integration::Rails.start do |connection|
      connection.on_error do |ch, connection_close|
        raise connection_close.reply_text
      end
 
      connection.on_tcp_connection_loss do |conn, settings|
        conn.reconnect(false, 2)
      end
 
      connection.on_tcp_connection_failure do |conn, settings|
        conn.reconnect(false, 2)
      end
 
      channel = AMQP::Channel.new(connection, AMQP::Channel.next_channel_id, :auto_recovery => true)
      channel.on_error do |ch, channel_close|
        raise channel_close.reply_text
      end
 
      AMQP.channel = channel
    end
  end
end
 
AMQPManager.start unless ENV["UNICORN"]
```

コントローラからパブリッシュする場合は下記のようにします。

```ruby
# coding: utf-8
 
class AmqpController < ApplicationController
  def publish
    AMQP::Utilities::EventLoopHelper.run do
      AMQP.channel.default_exchange.publish("Hello World!!!!!", routing_key: "queue.name")
    end
    head :created
  end
end
```
