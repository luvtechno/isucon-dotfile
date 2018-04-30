# redis

## インストール

```
sudo apt-get install -y redis-server
sudo systemctl enable redis-server.service
sudo systemctl start redis-server.service
```

## 設定ファイル

`/etc/redis/redis.conf`

## ログファイル

`/var/log/redis/redis-server.log`

## ruby/sinatra からの利用

`Gemfile`

```
gem "redis"
gem "hiredis"
```

`app.rb`

```ruby
require 'redis'
require 'redis/connection/hiredis'

   helpers do
      if development?
        def redis
          @redis ||= (Thread.current[:isu_redis] ||= Redis.new(driver: :hiredis))
        end
      else
        def redis
          @redis ||= (Thread.current[:isu_redis] ||= Redis.new(path: "/var/run/redis/redis.sock", driver: :hiredis))
        end
      end
   end
```

## unix domain socket

```
unixsocket /var/run/redis/redis.sock
unixsocketperm 777
```

動作確認
```
redis-cli -s /var/run/redis/redis.sock
```

systemd の privatetmp の仕組みで /tmp 以下のパスだと動かない。以下のようにすれば動く。

`sudo vim /etc/systemd/system/redis.service`

```
PrivateTmp=false
```
