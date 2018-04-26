# stackprof (ruby プロファイラ) の使い方

https://github.com/tmm1/stackprof

## インストール

https://github.com/luvtechno/isucon-practice-20171015/pull/12/files を参照して実装する

```
gem 'stackprof'
```

`config.ru`

```ruby
if ENV['ISUPROFILE'] == ?1
  puts "stackprof is being enabled..."
  require 'stackprof'
  use StackProf::Middleware,
    enabled: true,
    mode: :cpu,
    interval: 500,
    save_every: 100,
    save_at_exit: true,
    path: '/home/isucon/stackprof'
end
```

- `rm -f /tmp/stackprof/*` をデプロイ毎に実行する。
- `save_every` は1インスタンスあたりのリクエストが少ないと保存されないことがあるので、適切に小さくする。



## コマンド

```
stackprof /tmp/stackprof/stackprof-wall-*.dump --text --limit 30
stackprof /tmp/stackprof/stackprof-wall-*.dump --method 'Isuconp::App#make_posts'

bundle exec stackprof /home/isucon/stackprof/stackprof-cpu-*.dump --limit 30
bundle exec stackprof /home/isucon/stackprof/stackprof-cpu-*.dump --method 'Isuda::Web#htmlify'

```

## 実行例

結論: 中盤〜後半で、エンドポイント単位の最適化が終わったあたりで活躍しそう
- ベンチマーク実行全体で、どのメソッドが一番処理時間がかかったかわかる。下記の例だと`Hash#symbolize_keys` や `CGI::Util#escape` が遅いので、それを減らそうという意思決定が出来た。
- これをいれていると10%ぐらいパフォーマンス低下するので、提出前に外すのを忘れずに。

```
$ stackprof /tmp/stackprof/stackprof-wall-4*.dump --text --limit 30
==================================
  Mode: wall(500)
  Samples: 282708 (2.71% miss rate)
  GC: 92036 (32.56%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
     53739  (19.0%)       53739  (19.0%)     Hiredis::Ext::Connection#read
     57834  (20.5%)       29138  (10.3%)     Hash#symbolize_keys
     97630  (34.5%)       26202   (9.3%)     Isuconp::App#make_posts
     14001   (5.0%)       12364   (4.4%)     Rack::Utils#escape_html
      8238   (2.9%)        8238   (2.9%)     Redis::Connection::Hiredis#write
      4820   (1.7%)        4820   (1.7%)     Time#xmlschema
      3439   (1.2%)        3439   (1.2%)     CGI::Util#escape
      5331   (1.9%)        2826   (1.0%)     block in <class:Redis>
      2505   (0.9%)        2505   (0.9%)     block (2 levels) in <class:Redis>
     15824   (5.6%)        2410   (0.9%)     Isuconp::App#redis_find_posts
      2615   (0.9%)        2295   (0.8%)     Tilt::Cache#fetch
     42222  (14.9%)        1953   (0.7%)     Isuconp::App#make_posts_for_index
     89070  (31.5%)        1918   (0.7%)     Isuconp::App#redis_find_post_comments_hash
      1694   (0.6%)        1694   (0.6%)     MonitorMixin#mon_enter
      2077   (0.7%)        1682   (0.6%)     block in <class:Base>
      2410   (0.9%)        1659   (0.6%)     Redis::Pipeline#call
      1640   (0.6%)        1638   (0.6%)     Isuconp::App#redis
      1549   (0.5%)        1549   (0.5%)     Sinatra::Base.settings
     12537   (4.4%)        1492   (0.5%)     Isuconp::App#redis_initialize_comments
      5270   (1.9%)        1473   (0.5%)     Isuconp::App#redis_convert_user
      1063   (0.4%)        1063   (0.4%)     Rack::Request#session
     94548  (33.4%)         964   (0.3%)     Sinatra::Templates#render
       796   (0.3%)         796   (0.3%)     MonitorMixin#mon_check_owner
       751   (0.3%)         751   (0.3%)     Redis::Future#initialize
      1438   (0.5%)         697   (0.2%)     Tilt::Template#compiled_method
    202123  (71.5%)         696   (0.2%)     Redis::Client#process
      6372   (2.3%)         685   (0.2%)     Redis::Future#_set
       627   (0.2%)         627   (0.2%)     Isuconp::App#key_user
       696   (0.2%)         560   (0.2%)     block in delegating_block
       550   (0.2%)         550   (0.2%)     block in set
```

```
stackprof /tmp/stackprof/stackprof-wall-4*.dump --method 'Isuconp::App#make_posts'
Isuconp::App#make_posts (/home/isucon/private_isu/webapp/ruby/app.rb:489)
  samples:  26202 self (9.3%)  /   97630 total (34.5%)
  callers:
    42323  (   43.4%)  block in <class:App>
    35419  (   36.3%)  Isuconp::App#make_posts
    15707  (   16.1%)  block in <class:App>
    4181  (    4.3%)  block in <class:App>
  callees (71428 total):
    35419  (   49.6%)  Isuconp::App#make_posts
    20996  (   29.4%)  Isuconp::App#redis_find_post_comments_hash
    7781  (   10.9%)  Isuconp::App#redis_banned?
    7232  (   10.1%)  Isuconp::App#redis_find_users
  code:
                                  |   489  |       def make_posts(results, all_comments: false)
                                  |   490  |         posts = []
    8    (0.0%) /     8   (0.0%)  |   491  |         return [] if results.size == 0
                                  |   492  |
   78    (0.0%) /    39   (0.0%)  |   493  |         post_ids = results.map { |post| post[:id] }
 20996    (7.4%)                   |   494  |         comment_hash = redis_find_post_comments_hash(post_ids)
                                  |   495  |
  120    (0.0%) /    60   (0.0%)  |   496  |         user_ids = results.map{ |post| post[:user_id] }
 25772    (9.1%)                   |   497  |         comment_hash.each do |post_id, comments|
 27107    (9.6%) /  25772   (9.1%)  |   498  |           user_ids += comments.map { |comment| comment[:user_id] }
                                  |   499  |         end
                                  |   500  |         user_ids.uniq!
                                  |   501  |
 7232    (2.6%)                   |   502  |         users = redis_find_users(user_ids)
  152    (0.1%) /    76   (0.0%)  |   503  |         user_hash = users.map { |user| [user[:id], user] }.to_h
                                  |   504  |
 8024    (2.8%)                   |   505  |         results.each do |post|
 7781    (2.8%)                   |   506  |           next if redis_banned?(post[:user_id])
                                  |   507  |
   23    (0.0%) /    23   (0.0%)  |   508  |           comments = comment_hash[post[:id]] || []
                                  |   509  |
                                  |   510  |           post[:comment_count] = comments.size
                                  |   511  |
    5    (0.0%) /     5   (0.0%)  |   512  |           unless all_comments
                                  |   513  |             comments = comments.first(3)
                                  |   514  |           end
                                  |   515  |
  113    (0.0%)                   |   516  |           comments.each do |comment|
  113    (0.0%) /   113   (0.0%)  |   517  |             comment[:user] = user_hash[comment[:user_id]]
                                  |   518  |           end
                                  |   519  |           post[:comments] = comments.reverse
                                  |   520  |
                                  |   521  |           post[:user] = user_hash[post[:user_id]]
                                  |   522  |
                                  |   523  |           posts.push(post)
  102    (0.0%) /   102   (0.0%)  |   524  |           break if posts.length >= POSTS_PER_PAGE
                                  |   525  |         end
                                  |   526  |
    4    (0.0%) /     4   (0.0%)  |   527  |         posts
                                  |   528  |       end
Isuconp::App#make_posts_for_index (/home/isucon/private_isu/webapp/ruby/app.rb:452)
  samples:  1953 self (0.7%)  /   42222 total (14.9%)
  callers:
    39617  (   93.8%)  block in <class:App>
    2605  (    6.2%)  Isuconp::App#make_posts_for_index
  callees (40269 total):
    22912  (   56.9%)  Isuconp::App#redis_find_users
    14752  (   36.6%)  Isuconp::App#redis_find_post_comments_hash
    2605  (    6.5%)  Isuconp::App#make_posts_for_index
  code:
                                  |   452  |       def make_posts_for_index(results, all_comments: false)
                                  |   453  |         posts = []
   18    (0.0%) /    18   (0.0%)  |   454  |         return [] if results.size == 0
                                  |   455  |
   46    (0.0%) /    23   (0.0%)  |   456  |         post_ids = results.map { |post| post[:id] }
 14752    (5.2%)                   |   457  |         comment_hash = redis_find_post_comments_hash(post_ids)
                                  |   458  |
   86    (0.0%) /    43   (0.0%)  |   459  |         user_ids = results.map{ |post| post[:user_id] }
  521    (0.2%)                   |   460  |         comment_hash.each do |post_id, comments|
  917    (0.3%) /   521   (0.2%)  |   461  |           user_ids += comments.map { |comment| comment[:user_id] }
                                  |   462  |         end
                                  |   463  |         user_ids.uniq!
                                  |   464  |
 22912    (8.1%)                   |   465  |         users = redis_find_users(user_ids)
  712    (0.3%) /   356   (0.1%)  |   466  |         user_hash = users.map { |user| [user[:id], user] }.to_h
                                  |   467  |
  990    (0.4%)                   |   468  |         results.each do |post|
  395    (0.1%) /   395   (0.1%)  |   469  |           comments = comment_hash[post[:id]] || []
                                  |   470  |
                                  |   471  |           post[:comment_count] = comments.size
                                  |   472  |
                                  |   473  |           unless all_comments
                                  |   474  |             comments = comments.first(3)
                                  |   475  |           end
                                  |   476  |
  276    (0.1%)                   |   477  |           comments.each do |comment|
  276    (0.1%) /   276   (0.1%)  |   478  |             comment[:user] = user_hash[comment[:user_id]]
                                  |   479  |           end
                                  |   480  |           post[:comments] = comments.reverse
                                  |   481  |
                                  |   482  |           post[:user] = user_hash[post[:user_id]]
  319    (0.1%) /   319   (0.1%)  |   483  |           posts.push(post)
                                  |   484  |         end
                                  |   485  |
    2    (0.0%) /     2   (0.0%)  |   486  |         posts
                                  |   487  |       end
```

### 参照
- https://github.com/tmm1/stackprof
- https://github.com/shirokanezoo/isucon4-qualifier-sorah/blob/master/ruby/config.ru
- [Ruby プロセスを追いかけるツール(プロファイラとか)10選](http://blog.livedoor.jp/sonots/archives/39380434.html)
- [StackProfを使ってrubyプログラムのプロファイリングをする方法](http://qiita.com/shunsakai/items/28182914389a156199cd)
