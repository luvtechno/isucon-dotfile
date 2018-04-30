# mysql

## インストール

### Ubuntu

```shell-session
$ sudo apt-get install -y mysql-server
```

### Mac

```shell-session
$ brew update && brew install mysql
```

## ログイン

`mysql -h[host] -P[port] -u[user_name] -p[password] ([database])`

```shell-session
$ mysql -h0.0.0.0 -P3306 -uisucon -pisucon isuketch
```

localhost なら

```shell-session
$ mysql -uroot
```

### ユーザー作成

```sql
CREATE USER 'isucon'@'localhost' IDENTIFIED BY 'isucon';
GRANT ALL PRIVILEGES ON *.* TO 'isucon'@'localhost' WITH GRANT OPTION;
```

## 設定ファイル
パス

```
$ mysql --help | grep my.cnf
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
/etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
```
左から順に読み込まれる。

`/etc/mysql/my.cnf` の実体は下記ディレクトリ以下のファイルを読み込むだけ。

```
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/
```

なので実際に編集するのであれば `/etc/mysql/mysql.conf.d/mysqld.cnf`


## コマンド
### database 一覧
`show databases`

```sql
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| isuconp            |
| mysql              |
| performance_schema |
+--------------------+
4 rows in set (0.00 sec)
```

### table 一覧

`show tables`

```sql

mysql> use isuconp;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+-------------------+
| Tables_in_isuconp |
+-------------------+
| comments          |
| posts             |
| users             |
+-------------------+
3 rows in set (0.00 sec)
```

### schema 確認

`describe <table>`

```sql
mysql> describe comments;
+------------+-----------+------+-----+-------------------+----------------+
| Field      | Type      | Null | Key | Default           | Extra          |
+------------+-----------+------+-----+-------------------+----------------+
| id         | int(11)   | NO   | PRI | NULL              | auto_increment |
| post_id    | int(11)   | NO   |     | NULL              |                |
| user_id    | int(11)   | NO   |     | NULL              |                |
| comment    | text      | NO   |     | NULL              |                |
| created_at | timestamp | NO   |     | CURRENT_TIMESTAMP |                |
+------------+-----------+------+-----+-------------------+----------------+
5 rows in set (0.00 sec)

```

### データ量確認
```
SELECT table_name, engine, table_rows, avg_row_length, floor((data_length+index_length)/1024/1024) as allMB, floor((data_length)/1024/1024) as dMB, floor((index_length)/1024/1024) as iMB FROM information_schema.tables WHERE table_schema=database() ORDER BY (data_length+index_length) DESC;
```

```sql

mysql>  SELECT table_name, engine, table_rows, avg_row_length, floor((data_length+index_length)/1024/1024) as allMB, floor((data_length)/1024/1024) as dMB, floor((index_length)/1024/1024) as iMB FROM information_schema.tables WHERE table_schema=database() ORDER BY (data_length+index_length) DESC;
+---------------+--------+------------+----------------+-------+------+------+
| table_name    | engine | table_rows | avg_row_length | allMB | dMB  | iMB  |
+---------------+--------+------------+----------------+-------+------+------+
| points        | InnoDB |    1439020 |             48 |    97 |   66 |   30 |
| tokens        | InnoDB |      49856 |            116 |    12 |    5 |    6 |
| room_watchers | InnoDB |      53519 |            108 |     8 |    5 |    2 |
| strokes       | InnoDB |      41184 |             64 |     4 |    2 |    1 |
| rooms         | InnoDB |       1000 |            131 |     0 |    0 |    0 |
| room_owners   | InnoDB |       1002 |             65 |     0 |    0 |    0 |
+---------------+--------+------------+----------------+-------+------+------+
6 rows in set (0.00 sec)
```

### index 確認

`show index from <table>`

```sql
mysql> show index from posts;
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| posts |          0 | PRIMARY    |            1 | id          | A         |        9382 |     NULL | NULL   |      | BTREE      |         |               |
| posts |          1 | user_id    |            1 | user_id     | A         |        1876 |     NULL | NULL   |      | BTREE      |         |               |
| posts |          1 | created_at |            1 | created_at  | A         |         180 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
3 rows in set (0.00 sec)

```



### index を追加

`alter table <table_name> add index <index_name> (<column_name>);`
OR `create index <index_name> on <table_name> (<column_name>);`


multi-column index は `column_name` をコンマ区切りで複数指定する。


https://dev.mysql.com/doc/refman/5.6/ja/create-index.html

```sql

mysql> create index post_id on comments (post_id);
Query OK, 0 rows affected (0.19 sec)
Records: 0  Duplicates: 0  Warnings: 0

```

### index を削除

`alter table <table_name> drop index <index_name>`


## dump と restore


### 基本
#### dump
`mysqldump -u[user] -p[password] [dbname] > dbname.sql`

```shell-session
$ mysqldump -u user -p password dbname > dbname.sql
```

#### restore
`mysql -u[user] -p[password] < dbname.sql`

```shell-session
$ mysql -u user -p password < dbname.sql
```

dump 時は `--single-transaction` `--quick` などのオプションを付けるといいらしい。
https://qiita.com/PlanetMeron/items/3a41e14607a65bc9b60c

### gzip で dump & restore する

#### dump

```shell-session
$ mysqldump -u user -p password dbname | gzip > dbname.dump.gz
```

#### restore

```shell-session
$ zcat dbname.dump.gz | mysql -u user -p password dbname

# mac なら gzcat を使う
$ gzcat dbname.dump.gz | mysql -u user -p password dbname
```

データが大きい場合は restore で `max_allowed_packet` に引っかかる場合がある。設定で大きくしておくとよい（デフォルトは 4MB)

```
[mysqld]
max_allowed_packet=160M
```


## チューニング
my.cnf を書き換えたら `mysql.server restart` でサーバーを再起動する。

### buffer pool size の設定
- `innodb_buffer_pool_size` と `innodb_log_file_size` を設定
- `innodb_log_file_size` \* `innodb_log_files_in_group` <  `innodb_buffer_pool_size` を満たす必要あり

`innodb_buffer_pool_size` はメモリの~80% 程度、`innodb_log_file_size` は数GBが目安？
https://yakst.com/ja/posts/61
メモリ量は `free -h` で確認。

例

```
[mysqld]
innodb_buffer_pool_size=1G
innodb_log_file_size=512M
```

OSのファイルシステムとのダブルキャッシュを避けるため、以下にするといい。

```
innodb_flush_method=O_DIRECT
```


### ログフラッシュのタイミング

disk へのフラッシュをトランザクションごとではなく、１秒に１回にする。

```
[mysqld]
innodb_flush_log_at_trx_commit=2  // デフォルトは 1
```

https://qiita.com/kkyouhei/items/d2c40d9e3952c7049ca3


## slow query log 解析

### 設定変数の値確認

`slow_query_log`, `slow_query_log_file`, `long_query_time`

これらの値は my.cnf で変えられる。


```sql
mysql> show variables like '%query%';
+------------------------------+--------------------------------------+
| Variable_name                | Value                                |
+------------------------------+--------------------------------------+
| binlog_rows_query_log_events | OFF                                  |
| ft_query_expansion_limit     | 20                                   |
| have_query_cache             | YES                                  |
| long_query_time              | 10.000000                            |
| query_alloc_block_size       | 8192                                 |
| query_cache_limit            | 1048576                              |
| query_cache_min_res_unit     | 4096                                 |
| query_cache_size             | 1048576                              |
| query_cache_type             | OFF                                  |
| query_cache_wlock_invalidate | OFF                                  |
| query_prealloc_size          | 8192                                 |
| slow_query_log               | ON                                   |
| slow_query_log_file          | /var/lib/mysql/62853bb7e371-slow.log |
+------------------------------+--------------------------------------+
13 rows in set (0.00 sec)
```


### [pt-query-digest](https://www.percona.com/doc/percona-toolkit/LATEST/pt-query-digest.html) のインストール
https://github.com/percona/percona-toolkit/releases から最新のソースコードをダウンロード

```sh

$ wget https://github.com/percona/percona-toolkit/archive/3.0.5-test.tar.gz
$ tar zxvf 3.0.5-test.tar.gz
$ ./percona-toolkit-3.0.5-test/bin/pt-query-digest --version
pt-query-digest 3.0.2
```

### 走らせる
```
$ ./percona-toolkit-3.0.5-test/bin/pt-query-digest **-slow.log > slow-log.txt
```

見方等 https://thinkit.co.jp/article/9617

### 一時的にslow queryを有効にする

```
# mysqlのコンソールにて
> set global slow_query_log = 1;
> set global long_query_time = 0;
> set global slow_query_log_file = "/tmp/slow.log";
# ベンチマーク実行
$ pt-query-digest /tmp/slow.log > /tmp/digest.txt
$ rm /tmp/slow.log
# 戻すときは
$ service mysqld restart
```

[ISUCONの勝ち方 YAPC::Asia Tokyo 2015](http://www.slideshare.net/kazeburo/isucon-yapcasia-tokyo-2015/50)より抜粋

## Timezone の設定

初期状態

```sql
mysql> show variables like '%time_zone';
+------------------+--------+
| Variable_name    | Value  |
+------------------+--------+
| system_time_zone | JST    |
| time_zone        | SYSTEM |
+------------------+--------+
2 rows in set (0.00 sec)
```

### UTC にする

```
[mysqld_safe]
timezone = UTC
default-time-zone = UTC
```

これだけだと `time_zone` は SYSTEM のままで UTC にはならなかった。`SET TIME_ZONE = 'UTC';` すると、`time_zone` も UTC になった。

```sql
mysql> show variables like '%time_zone%';
+------------------+--------+
| Variable_name    | Value  |
+------------------+--------+
| system_time_zone | UTC    |
| time_zone        | SYSTEM |
+------------------+--------+
2 rows in set (0.00 sec)

mysql> SET TIME_ZONE = 'UTC';
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like '%time_zone%';
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| system_time_zone | UTC   |
| time_zone        | UTC   |
+------------------+-------+
2 rows in set (0.01 sec)
```


