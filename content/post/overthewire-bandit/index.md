---
title: "OverTheWire Wargames Banditの解法一覧"
date: 2018-12-19T01:30:05-05:00
description: "CTFの練習問題集を完走した話。解けた時のカタルシスはひとしおなのでみなさんも挑戦してみてはいかが？"
# banner:"/img/some.png"
# lead: "Example lead - highlighted near the title"
# disable_comments: true # Optional, disable Disqus comments if true
disable_profile: true # no one wants to see my profile while reading articles
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
categories:
  - "技術"
tags:
  - "shell"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

# [OverTheWire](http://overthewire.org/)とは

OverTheWireというウェブサイトがありまして、**セキュリティ・Unixコマンドを実践的に学ぶのにとてもいい**と聞いたのでやってみました。\
一般にCTFと言われるプログラミング競技の練習問題がたくさん載っているサイトです。

そのなかの**Bandit**を一通り解いたので、備忘録がてら答えを書いておこうと思います。\
たぶん一番簡単なレベルですので、序盤はセキュリティと言うよりは基礎的なシェルコマンドの練習という感じでしょうか。\
これが一通り解ければシェルスクリプトとかも少しは読めるようになるかもです。\

問題文は上のサイトに有るので各自参照しながらやってください。\
というかこの記事は解答しか書いていないので詰まるまで見ないほうがいいと思います。

# 解答
## Level 0
### 解法1
`ssh bandit0@bandit.labs.overthewire.org -p 2220`\
以降もユーザー名を変えて同じですね。

### 解法2
なお、いちいちユーザー名を変えながらsshするのがかったるいという人は関数を書けばいいです:

```
#fish向け。~/.config/fish/config.fishに以下を追記
function banditssh
  ssh bandit$argv@bandit.labs.overthewire.org -p 2220
end
#zsh,bash向け。~/.bashrcか~/.zshrcに以下を追記
banditssh()
{
  ssh bandit"$@"@bandit.labs.overthewire.org -p 2220
}
```

これを設定ファイルに書き込んだ上で`banditssh 0`してくださいな。\

## Level 0 to 1
`less readme` または
`cat readme`

## Level 1 to 2
`less ./-`

ファイル名が特殊文字の場合はこう書きます。

## Level 2 to 3
`less spaces\ in\ this\ filename`

同様。

## Level 3 to 4
`ls -a inhere`

隠しファイルもこれで見れます。
というわけで

`less inhere/.hidden`

## Level 4 to 5
`file inhere/*`

fileコマンドでファイルの種類を見れます。
あとはテキストファイルをlessしておわり。

## Level 5 to 6
`find . -size 1033c`

3つ条件がありますがこれだけで見つけられます。

コマンドの意味がわからない場合`man find`か`find --help`でドキュメントが出てくるのでたいがいの場合なんとかなります。英語をちょっと読まないといけませんが。\
Macの人は(OverTheWireサーバじゃなくて)手元でこれを実行すると**BSDライセンスの別コマンドが出てくる可能性大**[^4]ですので気をつけましょう。
[^4]:brewとかで別のコマンドを入れて、そちらを優先するようにPATHを設定したらその限りではないですが

## Level 6 to 7
`find / -user bandit7 -group bandit6 -size 33c 2> /dev/null`

問題文の条件的には`find / -user bandit7 -group bandit6 -size 33c`だけでいいんですけど、`Permission denied`警告がたくさん出て鬱陶しいです。

こういうときは、`2>`とやるとエラー出力先を画面じゃなくて特定のファイルに変更できます。`/dev/null`は書き込んでも何も起こらないブラックホールです。こうすることで目的の出力だけ出てきますね。

## Level 7 to 8
### 解法1
`less`は`/`で検索機能が起動するので、`/millionth<Enter>`で検索できます。

### 解法2
`cat data.txt | grep millionth`でも良し。

## Level 8 to 9
`sort data.txt | uniq -u`

`uniq`は名前から受ける印象とは異なり**隣り合った行が一緒なら削る**という仕様なので、先にソートしてやる必要があります。

## Level 9 to 10
`strings data.txt  | grep ==`

人間に読める文字だけの行を取り出しておきましょう。

## Level 10 to 11
`base64 -d data.txt`

## Level 11 to 12
`cat data.txt | tr '[a-zA-Z]' '[n-za-mN-ZA-M]'`

正規表現から正規表現にするには`tr`が使えますね。

## Level 12 to 13
最初に`xxd -r data.txt out.txt`で戻します。\

いつもどおり`file out.txt`でファイルの種類を確認し\

`gzip -d hoge.gz`か`bzip2 -d hoge`か`tar -xvf hoge`で解凍できます。\
`gzip`の方は拡張子が`gz`じゃないとうまくいかないみたいなので適宜`mv hoge hoge.gz`とかで改名しました。\

この3つを死ぬほど繰り返すと`data8`が手に入るので終了です。

## Level 13 to 14
ホームに有るsshkeyを自分のパソコンの`~/.ssh/bandit14_rsa`にでもコピペして、\
`chmod 600 ~/.ssh/bandit14_rsa`で他の人が読めないようにして[^2]、\
`ssh bandit14@bandit.labs.overthewire.org -p 2220 -i ~/.ssh/bandit14_rsa`でアクセスできるので終了。

[^2]:秘密鍵を自分以外が読めるようになっているとセキュリティ上の危険があるので、その秘密鍵ではアクセスさせてもらえません。

## Level 14 to 15
Level 13に書いてあったようにこのLevelのパスワードは`/etc/bandit_pass/bandit14`にあるので、それをコピーします。\
`telnet localhost 30000`でアクセスして、ペーストしたら終了です[^telnet_warning]。\

[^telnet_warning]:telnetは通信内容を暗号化しないのでインターネットを介した接続につかってはいけません。

## Level 15 to 16
`openssl s_client -connect localhost:30001`で同じようにパスワードを送信してクリアです。\

## Level 16 to 17
`nmap -A -T4 -p31000-32001 127.0.0.1`でスキャンできます。`127.0.0.1`は`localhost`に同じです。\
さっきと同じようにパスワードを送りつけて、同じのが帰ってこないやつが正解です。\

帰ってきたrsaパスワードを同じようにローカルに保存して
`ssh bandit17@bandit.labs.overthewire.org -p 2220 -i ~/.ssh/bandit17_rsa`でクリア。

## Level 17 to 18
`diff passwords.old passwords.new`\
`>`に出力されているのが後ろの方のファイルに対応しており、答え。

## Level 18 to 19
最初に作った関数`banditssh 18`は使えないので\
`ssh bandit18@bandit.labs.overthewire.org -p 2220 "cat readme"`します。\

なお、どんな悪戯が仕掛けられたのかを確認したかったら\
`ssh bandit18@bandit.labs.overthewire.org -p 2220 "cat .bashrc"`で。

## Level 19 to 20
`./bandit20-do cat /etc/bandit_pass/bandit20`\

ちなみに、`ls -l`で
```shell
-rwsr-x--- 1 bandit20 bandit19 7296 Oct 16 14:00 bandit20-do
```
という結果を得ますが、ご覧の通り4文字目が`x`じゃなくて`s`になってます。`bandit19`グループにも実行権限が有るのですが、これを実行すると所有ユーザ`bandit20`で実行した扱いになります。

## Level 20 to 21
ちょっとややこしいですが、`suconnect`はlocalhostの指定されたポートでbandit20のパスワードを聞くという仕組みですね。もしbandit20のパスワードが送られてきたら答えを返してくれます。\

なので、まず`nc -l -p 3000 &`で3000番のポートを開きます。\
`-l`はlisten modeの意味で、3000番のポートを「聴いていますよ」モードにします。「聴いていますよ」とはいっても、こちらから送信することも可能です。これで`suconnect`からの接続が可能になります。[^1]\
`&`はバックグラウンド処理するという意味です。\

[^1]:netcatによるサーバ・クライアント接続について[とてもわかり易かったサイト](https://www.digitalocean.com/community/tutorials/how-to-use-netcat-to-establish-and-test-tcp-and-udp-connections-on-a-vps#how-to-communicate-through-netcat)

で、同じく`./suconnect 3000 &`でもう一方もつなぎ、
`jobs`で処理の一覧を確認して`fg <process number>`で`nc`のジョブに移動。\
bandit20のパスワードをペーストしてやれば、つながっている`suconnect`から正解が帰ってくるので終了です。

## Level 21 to 22
`cron.d`内を確認すると毎分実行されてる`bandit22`に所有権のあるシェルスクリプトがパスワードを書き出しているので、書き出し先のパスを読んでそれをコピペして終了。

```
cat /tmp/t7O6lds9S0RqQh9aMcz6ShpAoZKF7fgv
```

## Level 22 to 23
`$(<shell command>)`でシェルコマンドの返す結果がそこに代入されます。例えば`$(echo i)`は`i`です。\

それに注意すれば代入とかは他と大体一緒ですし問題のシェルスクリプトも読めるのではないでしょうか。\
問題文に書いてあるとおり、`$(whoami)`とか`echo I am user $(whoami) | md5sum`とか`echo I am user $(whoami) | md5sum | cut -d ' ' -f 1`とかをいちいち試しに実行してみれば挙動がよく分かると思います。\
毎分自分の名前をmd5sumで変換した先のファイルにパスワードが書き出されているので、\
```
cat /tmp/$(echo I am user bandit23 | md5sum | cut -d ' ' -f 1)
```
で終了です。\

```
cat /tmp/$(echo I am user $(whoami) | md5sum | cut -d ' ' -f 1)
```
としたくなりますが、**あなたが**それを実行すると`$(whoami)`は`bandit22`になり、間違った値が帰ってくるので注意。

## Level 23 to 24
### 解法1
```
cp /var/spool/bandit24/sk24/cp24sk.sh /var/spool/bandit24/print_password.sh
# change permission to allow the script to write
chmod 777 /tmp/tmp.QJxYrsRJgT
# wait for a while until it's removed. check by
ls /var/spool/bandit24/print_password.sh
# after it's removed,
cat /tmp/tmp.QJxYrsRJgT
```

### 解法2
デフォルトの書き出し先は他の人と競合するかもしれないので、自分でシェルスクリプトを書いてもいいですね。その場合、`/var/spool/bandit24/sk24/cp24sk.sh`を参考に
```
echo 'cat /etc/bandit_pass/bandit24 > /tmp/woody_file.txt' > /tmp/woody_script.sh
chmod 777 /tmp/woody_script.sh
touch /tmp/woody_file.txt
chmod 666 /tmp/woody_file.txt
cp /tmp/woody_script.sh /var/spool/bandit24/print_password.sh
# wait for a while until it's removed. check by
ls /var/spool/bandit24/print_password.sh
# after it's removed,
cat /tmp/woody_file.txt
```

とかにして同じようにコピーしましょう。`bandit24`によるcronが実行できるようにシェルスクリプト自体を`chmod`する必要があるのでそこだけ注意です。

## Level 24 to 25

### 解法1
`nc localhost 30002`でアクセスできるので、先にファイルに10000回分の入力を叩き込んでおいて入力しましょう。\
**ファイルに追記するには`>>`を使いましょう**。（`>`では毎回消去・上書きされてしまいます）\
標準入力の代わりにファイルを入力させるには`<`を使いましょう。

```
rm /tmp/woody.txt
for i in `seq 0 10000`; do printf "<Level 24 password> %04d\n" $i >> /tmp/woody.txt; done
cat /tmp/woody.txt
nc localhost 30002 < /tmp/woody.txt > /tmp/answer.txt
cat /tmp/answer.txt
```

### 解法2
なお、パイプ(|)という「手前のコマンドの標準出力をあとのコマンドの標準入力とする」というものを使えば1行で書けます。スッキリですね。
```
for i in `seq 0 10000`; do printf "<Level 24 password> %04d\n" $i; done | nc localhost 30002
```

## Level 25 to 26
sshkey自体はホームに配置されています。しかし[Level 14](#level-13-to-level-14)と同じようにアクセスしようとすると、即座に弾かれます。\
`bandit26`のログインシェルを確認しましょう。\
`cat /etc/passwd`の結果の、`bandit26`の行の最後にログインシェルが確認できます。
これは
```
#!/bin/sh

export TERM=linux

more ~/text.txt
exit 0
```
を実行するというものであり、最後の行の`exit 0`が実行されるまえになんとかしないといいけません。\

この問題、割と悩んだ末に答えを検索したんですが、なんと**ウィンドウの縦幅を狭くする**という解法がありました。\
ウィンドウが狭いと`more`コマンドが**下にスクロールしない限り終了しません。**この状態で`v`を押すとvimが起動するので、`:set shell=bin/bash`というvimコマンドを入力すればいいです。

いくつか探してみたんですけどどこもこの解法なので**これが想定解法**という可能性までありますね。たまげたなあ……

vimを終了すると続きが始まって`exit 0`まっしぐらなので、vimを終了することはできませんが、実は**この状態からでもシェルは扱える**のでbandit26にログインしたことに等しいです。vim上で`:!echo hello,world`みたいに**!をつけて実行するとシェルコマンドが実行できるのです**。

## Level 26 to 27

というわけで、一つ上からvimに入ったまま続けます。
`:!ls -l`で確認すると`bandit27-do`といういかにもなファイルがあるので、[Level 19](#level-19-to-level-20)を思い出して実行してやれば終了です。

```shell
# vim上で
:!./bandit27-do cat /etc/bandit_pass/bandit27
```

## Level 27 to 28
`git clone ssh://bandit27-git@localhost/home/bandit27-git/repo`でbandit27のパスワードを入力します。\
なお、ホームディレクトリは書き込みロックが掛かっているのでいつもどおり`/tmp`で……思ったらすでに`repo`が存在してしまっているので、名前がかぶってしまいます。なので適当に自分のディレクトリを作って、そのなかで上のコマンドを実行しましょう。`mkdir /tmp/woodyrepo`とかです。

あとは、`cat repo/README`で終了です。


## Level 28 to 29
さっき作ったディレクトリは消去不可の`repo`が入ってしまっているのでまた新しく作りましょう。同じことを繰り返すと、`README.md`が見つかりますがパスワードはきちんと消されています。
しかし、リポジトリ内で`git log`をすると……
```git log
commit 073c27c130e6ee407e12faad1dd3848a110c4f95
Author: Morla Porla <morla@overthewire.org>
Date:   Tue Oct 16 14:00:39 2018 +0200

    fix info leak

commit 186a1038cc54d1358d42d468cdc8e3cc28a93fcb
Author: Morla Porla <morla@overthewire.org>
Date:   Tue Oct 16 14:00:39 2018 +0200

    add missing data

commit b67405defc6ef44210c53345fc953e6a21338cc7
Author: Ben Dover <noone@overthewire.org>
Date:   Tue Oct 16 14:00:39 2018 +0200

    initial commit of README.md
```

`fix info leak`……あっ……\
というわけで、このcommitでパスワードが書かれていたのに気づいて焦って消したと思われますが、その一つ前のコミットに戻ってやればいいですね。
```
git checkout HEAD^
cat README.md
```
で消されたパスワードを暴いて終了です。

## Level 29 to 30
`git log --all --graph`で全コミットをきれいなグラフにして見れます。
```git log
* commit 33ce2e95d9c5d6fb0a40e5ee9a2926903646b4e3
| Author: Morla Porla <morla@overthewire.org>
| Date:   Tue Oct 16 14:00:41 2018 +0200
|
|     add data needed for development
|
* commit a8af722fccd4206fc3780bd3ede35b2c03886d9b
| Author: Ben Dover <noone@overthewire.org>
| Date:   Tue Oct 16 14:00:41 2018 +0200
|
|     add gif2ascii
|
| * commit 2af54c57b2cb29a72e8f3e84a9e60c019c252b75
|/  Author: Morla Porla <morla@overthewire.org>
|   Date:   Tue Oct 16 14:00:41 2018 +0200
|
|       add some silly exploit, just for shit and giggles
|
* commit 84abedc104bbc0c65cb9eb74eb1d3057753e70f8
| Author: Ben Dover <noone@overthewire.org>
| Date:   Tue Oct 16 14:00:41 2018 +0200
|
|     fix username
|
* commit 9b19e7d8c1aadf4edcc5b15ba8107329ad6c5650
  Author: Ben Dover <noone@overthewire.org>
  Date:   Tue Oct 16 14:00:41 2018 +0200

      initial commit of README.md
```

最新のコミットにパスワードがあります。
```
git checkout 33ce2e95d9c5d6fb0a40e5ee9a2926903646b4e3
cat README.md
```
で終了。

## Level 30 to 31
tagに答えがあります。`git tag`をすると`secret`なるタグが出てくるので、`git show secret`でクリア。[^3]\
[^3]:これと[Level 25](#level-25-to-level-26)は検索しました。初見殺しですね。なおこれの答えは[ここ](https://www.nagekar.com/2018/08/overthewire-bandit-27-33.html)を見ました

## Level 31 to 32
`README.md`にかいてあることを実行するだけです。
```
echo May I come in? > key.txt
git add -f key.txt
git commit -m "woody's commit"
git push
```

## Level 32 to 33
`WELCOME TO THE UPPERCASE SHELL`のとおり、入力した文字が全部大文字に変えられてしまいます。\
これはかなり詰まったんですが、大文字でも扱えるのは**デフォルト変数があるなあ**とおもいだしたので[このサイト](https://docstore.mik.ua/orelly/unix/unixnut/ch04_03.htm)の4.3.2とかを見てみました。\
結論から言うと`$0`で`uppershell`を抜けて`sh`に出られます。\
`$0`は *このシェルプロセスを呼び出したシェル* になるので、`sh`になる……ようです。なんで`sh`になるのかはOSの内部に踏み込まないとわからなそうなので今のところはそっとしておきます。\
そっとしたまま`cat /etc/bandit_pass/bandit33`でクリア。

# 完走した感想

今の所レベル34以降がないので、ここまでです。お疲れ様でした！\
知識と発想があればスルッと解けちゃうところが爽快感ありますね。気がついたら丸一日掛けて終わらせてしまっていました。\

こんなの楽勝だぜ、って人はもっと上のレベルがあるらしいので是非挑戦してみてください。自分もぼちぼちやっていこうと思います。
