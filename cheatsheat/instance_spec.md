# instance spec

前提となるマシンスペックを知る。

## マシン調査

### スペック

```
$ grep processor /proc/cpuinfo
processor       : 0
processor       : 1

$ cat /proc/cpuinfo | grep "model name"

$ cat /proc/meminfo | grep MemTotal

$ free -m
             total       used       free     shared    buffers     cached
Mem:           998        906         92         12         25        335
-/+ buffers/cache:        545        453
Swap:            0          0          0
```

### プロセス

`ps aux` で何が動いているか確認。明らかに不要なものがあれば落としておく方が良い。


### Ubuntu バージョン

```
$ lsb_release -r
```

### ネットワーク

```
$ lspci | grep Ethernet
```

https://wiki.ubuntulinux.jp/UbuntuTips/Hardware/SearchHardwareInformation


