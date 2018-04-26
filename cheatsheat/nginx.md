# nginx

## 設定ファイル

```
/etc/nginx/nginx.conf
```

`/etc/nginx/conf.d/*.conf` や `/etc/nginx/sites-enabled/*` を include していることもある。

シンボリックリンクにする

```
mkdir -p ~/webapp/conf
cp /etc/nginx/nginx.conf ~/webapp/conf
sudo rm /etc/nginx/nginx.conf
sudo ln -s /home/isucon/webapp/conf/nginx.conf /etc/nginx/nginx.conf
```


## 再起動

```
#!/usr/bin/env bash
set -eux
sudo logrotate -f /etc/logrotate.d/nginx
sudo service nginx restart
sudo chmod 644 /var/log/nginx/access_kataribe.log
sudo tail /var/log/nginx/error.log
```

うまく起動しないときは下記のコマンドで状況を確かめる。

```
sudo systemctl status nginx.service
sudo tail /var/log/nginx/error.log
```

## kataribe 設定

https://github.com/matsuu/kataribe#nginx

```
http {
        log_format kataribe '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $request_time';
        access_log /var/log/nginx/access_kataribe.log kataribe;
}
```

## 静的ファイル配信

`try_files` directive を使う。

```
  root /home/isucon/private_isu/webapp/public/;

  location / {
    try_files $uri @app;
  }
  location ~* \.(?:ico|css|js|gif|jpe?g|png)$ {
    try_files $uri @app;
    expires max;
    add_header Pragma public;
    add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    etag off;
  }
  location @app {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass http://app;
  }
```

`try_files` をつかわない場合

```
        root /home/isucon/webapp/public/;

        location ~ .*\.(htm|html|css|js|png|gif|ico) {
          index  index.html index.htm;
          expires 24h;
          add_header Cache-Control public;
          open_file_cache max=1024;
          break;
        }
```

## SSL & HTTP2

```
        server {
           listen 443 ssl http2;
           ssl_certificate /home/isucon/webapp/ssl/oreore.crt;
           ssl_certificate_key /home/isucon/webapp/ssl/oreore.key;
        }
```

## gzip

```
http {
  gzip on;
  gzip_http_version 1.0;
  gzip_proxied any;
  gzip_types text/css
             text/javascript
             application/javascript;
  gzip_static on;
}
```

## unix domain socket

```
	upstream react {
		# server 127.0.0.1:4430;
		server unix:/tmp/unicorn.sock;
	}
```

## 参考

- https://github.com/shirokanezoo/isucon5/blob/master/5f/config/nginx.conf
