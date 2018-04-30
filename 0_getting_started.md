# はじめにやること

## ssh

```
curl https://github.com/{luvtechno,3846masa}.keys >> /home/isucon/.ssh/authorized_keys
```

## git

`.gitconfig` の設定

```
cd ~
wget https://raw.githubusercontent.com/luvtechno/isucon-dotfile/master/.gitconfig
```

## github

https://github.com/settings/tokens で token を取得( repo 権限をつける )

```
cd /webapp
git init
git remote add origin https://xxx@github.com/luvtechno/isucon7-qualifier  # `xxx` を token で置き換える
# vi .gitignore
# git add -f .gitignore
git commit -am "Init"
git push -f -u origin master
```
