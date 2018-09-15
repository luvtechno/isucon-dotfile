# はじめにやること

## ssh

```
curl https://github.com/{luvtechno,qnighy,Altech}.keys >> ~/.ssh/authorized_keys
```

## git

`.gitconfig` の設定

```
cd ~
curl https://raw.githubusercontent.com/luvtechno/isucon-dotfile/master/.gitconfig > ~/.gitconfig
```

## github

https://github.com/settings/tokens で token を取得( repo 権限をつける )

```
cd /webapp
git init
git remote add origin https://xxx@github.com/luvtechno/isucon8-qualifier  # `xxx` を token で置き換える
# vi .gitignore
# git add -f .gitignore
git add .
git commit -am "Initialize"
git push -f -u origin master
```

2台め以降は`push -f`しないでmasterをpullする。もっといいやり方があれば知りたい。

```
git co tmp
git branch -d master
git pull
```
