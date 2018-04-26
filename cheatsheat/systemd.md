# systemd

## Unit 定義ファイルの場所

`/etc/systemd/system/`

### サンプル

```
$ cat /etc/systemd/system/isu-ruby.service
[Unit]
Description=isu-ruby
After=syslog.target

[Service]
WorkingDirectory=/home/isucon/private_isu/webapp/ruby
EnvironmentFile=/home/isucon/env.sh
Environment=RACK_ENV=production
PIDFile=/home/isucon/private_isu/webapp/ruby/unicorn.pid

User=isucon
Group=isucon
ExecStart=/home/isucon/.local/ruby/bin/bundle exec unicorn -c unicorn_config.rb
ExecStop=/bin/kill -s QUIT $MAINPID
ExecReload=/bin/kill -s USR2 $MAINPID

[Install]
WantedBy=multi-user.target
```

## コマンド

### ログをみる

```
sudo journalctl -n 100
sudo journalctl -f
sudo journalctl -u isu6fportal.service
```

https://qiita.com/aosho235/items/9fbff75e9cccf351345c

### enable/disable

```
sudo systemctl enable [name.service]
sudo systemctl disable [name.service]
```

Unit の自動起動を有効化/無効化する
実際にはWantedBy=で指定されたUnitへの依存関係を設定/削除する

### start/stop/restart/reload

```
sudo systemctl start [name.service]
sudo systemctl stop [name.service]
sudo systemctl restart [name.service]
sudo systemctl reload [name.service]
```

Unit をその場で 起動/停止/再起動する
reload は、Unit設定ファイルでreloadの動作が定義されている場合のみ使用できる

### status

```
sudo systemctl status [name.service]
```

Unit の実行状態を表示
PID や Status や CGroup や関連するデーモンプロセスや直近ログの表示とか

### edit

```
sudo vim /etc/systemd/system/isu6fportal.service
# sudo EDITOR=vim systemctl edit --full isu6fportal.service
```

ファイル全体を編集 (--fullオプションをつける)


### daemon-reaload

```
sudo systemctl daemon-reload
```

Unit設定ファイルを変更した時に、変更内容をsystemdに認識させる


### is-active
```
sudo systemctl is-active [name.service]
```

### list-units

```
systemctl list-units --type service --all
systemctl list-units --type service
```


## 参考

-  [systemd を理解し、使いこなす](https://jp.linux.com/news/linuxcom-exclusive/421712-lco2014092602)
- [systemdで既存のunitを編集する2つの方法](http://qiita.com/nvsofts/items/529e422bb8a326401c39)
- ユニットファイルの文法 は [Systemd メモ書き](http://qiita.com/a_yasui/items/f2d8b57aa616e523ede4) 参照
- [How To Use Systemctl to Manage Systemd Services and Units | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
