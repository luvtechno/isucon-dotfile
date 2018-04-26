# kataribe

アクセスログを集計するツール

https://github.com/matsuu/kataribe

## インストール

色々考えるとローカルでやる方が良さそう。

Go の設定をする必要がある。設定できていれば、`go get <repository>` でインストールできる。

バイナリは https://github.com/matsuu/kataribe/releases からDLする。Mac なら `darwin_amd64.zip` 。

## Nginx

scp でローカルに持ってきて、cat で食わせて ruby で整形する。
nginx のログフォーマットは変えておく必要あり。


```
# リモート
sudo chmod 666 /var/log/nginx/access_kataribe.log
docker cp d67c8aab815b:/app/app.log app.log # Docker から持ってくる場合
```

```
# ローカル
cd ~/Downloads/kataribe
scp isucon@13.71.158.7:/var/log/nginx/access_kataribe.log .
cat ./access_kataribe.log | ./kataribe -f ./kataribe_nginx.toml | ./kataribe_to_md.rb | pbcopy
```


<details>
<summary>設定ファイル</summary>

```
# Top Ranking Group By Request
ranking_count = 20

# Top Slow Requests
slow_count = 10

# Show Standard Deviation column
show_stddev = true

# Show HTTP Status Code columns
show_status_code = true

# Percentiles
percentiles = [ 50.0, 90.0, 95.0, 99.0 ]

# for Nginx($request_time)
scale = 0
effective_digit = 3

# for Apache(%D) and Varnishncsa(%D)
#scale = -6
#effective_digit = 6

# for Rack(Rack::CommonLogger)
#scale = 0
#effective_digit = 4


# combined + duration
# Nginx example: '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $request_time'
# Apache example: "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D"
# Varnishncsa example: '%h %l %u %t "%r" %s %b "%{Referer}i" "%{User-agent}i" %D'
log_format = '^([^ ]+) ([^ ]+) ([^ ]+) \[([^\]]+)\] "((?:\\"|[^"])*)" (\d+) (\d+|-) "((?:\\"|[^"])*)" "((?:\\"|[^"])*)" ([0-9.]+)$'

request_index = 5
status_index = 6
duration_index = 10

# Rack example: use Rack::CommonLogger, Logger.new("/tmp/app.log")
#log_format = '^([^ ]+) ([^ ]+) ([^ ]+) \[([^\]]+)\] "((?:\\"|[^"])*)" (\d+) (\d+|-) ([0-9.]+)$'
#request_index = 5
#status_index = 6
#duration_index = 8

# You can aggregate requests by regular expression
# For overview of regexp syntax: https://golang.org/pkg/regexp/syntax/
[[bundle]]
regexp = '^(GET|HEAD) .+\.css'
name = "GET *.css"

[[bundle]]
regexp = '^(GET|HEAD) .+\.js'
name = "GET *.js"

[[bundle]]
regexp = '^GET /api/rooms/\d+'
name = "GET /api/rooms/:id"

[[bundle]]
regexp = '^POST /api/strokes/rooms/\d+'
name = "POST /api/strokes/rooms/:id"

[[bundle]]
regexp = '^GET /api/stream/rooms/\d+?'
name = "GET /api/stream/rooms/:id"

[[bundle]]
regexp = '^GET /img/\d+'
name = "GET /img/:id"

[[bundle]]
regexp = '^GET /rooms/\d+'
name = "GET /rooms/:id"
```
</details>

## Rack

```rb
# config.ru
logger = Logger.new("./app_#{Time.now.strftime('%H%m')}.log")
use Rack::CommonLogger, logger
```

設定ファイル kataribe.toml もデフォルトで Nginx 用なので、コメントアウトしてあるところを適宜書き換える。


```
# ローカル
scp isucon@13.71.158.7:/home/isucon/webapp/app.log .
cat ./app.log | ./kataribe -f ./kataribe_rack.toml | ./kataribe_to_md.rb | pbcopy
```



<details>
<summary>設定ファイル</summary>

```rb
# Top Ranking Group By Request
ranking_count = 20

# Top Slow Requests
slow_count = 10

# Show Standard Deviation column
show_stddev = true

# Show HTTP Status Code columns
show_status_code = true

# Percentiles
percentiles = [ 50.0, 90.0, 95.0, 99.0 ]

# for Nginx($request_time)
# scale = 0
# effective_digit = 3

# for Apache(%D) and Varnishncsa(%D)
#scale = -6
#effective_digit = 6

# for Rack(Rack::CommonLogger)
scale = 0
effective_digit = 4


# combined + duration
# Nginx example: '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $request_time'
# Apache example: "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D"
# Varnishncsa example: '%h %l %u %t "%r" %s %b "%{Referer}i" "%{User-agent}i" %D'
# log_format = '^([^ ]+) ([^ ]+) ([^ ]+) \[([^\]]+)\] "((?:\\"|[^"])*)" (\d+) (\d+|-) "((?:\\"|[^"])*)" "((?:\\"|[^"])*)" ([0-9.]+)$'

# request_index = 5
# status_index = 6
# duration_index = 10

# Rack example: use Rack::CommonLogger, Logger.new("/tmp/app.log")
log_format = '^([^ ]+) ([^ ]+) ([^ ]+) \[([^\]]+)\] "((?:\\"|[^"])*)" (\d+) (\d+|-) ([0-9.]+)$'
request_index = 5
status_index = 6
duration_index = 8

# You can aggregate requests by regular expression
# For overview of regexp syntax: https://golang.org/pkg/regexp/syntax/
[[bundle]]
regexp = '^GET /api/rooms/\d+'
name = "GET /api/rooms/:id"

[[bundle]]
regexp = '^POST /api/strokes/rooms/\d+'
name = "POST /api/strokes/rooms/:id"

[[bundle]]
regexp = '^GET /api/stream/rooms/\d+?'
name = "GET /api/stream/rooms/:id"
```

</details>

ref. https://github.com/matsuu/kataribe#rack

#### kataribe to md

```rb
#!/usr/bin/env ruby

txt = $stdin.read

val = txt.split("\n\n").map { |txt|
  header = txt.lines.first
  body = txt.lines[1..-1]

  ["\n\n### #{header}", "\n", "```\n", body, "\n```\n"].join
}.join

puts val

```

