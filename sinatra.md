# sinatra

### 前提

単一ファイルで構成されたアプリケーション（clasic application という）。だいたい ISUCON はこれ。

* debugger => pry
* reloader => sinatra-contrib
* exception tracking => honeybadger

### Gemfile

```rb
gem 'honeybadger'

group :development do
  gem 'pry'
  gem 'pry-byebug'
  gem 'sinatra-contrib', require: nil
end
```

### Application

クラス内だと環境判定に `development?`, `production?` が使える。

```rb
class WebApp < ::Sinatra::Base
  require 'pry' if development?
  require 'sinatra/reloader' if development?
  require 'honeybadger' unless ENV['DISABLE_HONEYBADGER'] == 'true'
end
```

Honeybadger は [Honeybadger\.io Documentation : Sinatra Exception Tracking](https://docs.honeybadger.io/ruby/integration-guides/sinatra-exception-tracking.html) に従って API キーをセットすれば使える。環境変数 `DISABLE_HONEYBADGER` はベンチのスコアをオーバーヘッド抜きで見たい時用のフック。

### ドキュメント

http://www.sinatrarb.com/intro.html
