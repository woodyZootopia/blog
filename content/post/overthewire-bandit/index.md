---
title: "OverTheWire Banditの解法一覧"
date: 2018-12-19T01:30:05-05:00
description: "一番基礎的なレベルですが、解けた時の達成感はひとしおなのでみなさんも挑戦してみてはいかが？"
# banner:"/img/some.png"
# lead: "Example lead - highlighted near the title"
# disable_comments: true # Optional, disable Disqus comments if true
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
categories:
  - "技術"
tags:
  - "shell"
# menu: main # Optional, add page to a menu. Options: main, side, footer
tocSidebar: true
---

[OverTheWire](http://overthewire.org/)というウェブサイトがありまして、セキュリティをコマンド叩きながら学ぶのにとてもいいと聞いたのでやってみました。\
一般にCTFと言われる競技の練習問題みたいです。

Banditを一通り解いたので、備忘録がてら答えを書いておこうと思います。\
一番簡単なレベルですので、序盤はセキュリティと言うよりは基礎的なシェルコマンドのマスターという感じでしょうか。


問題文は上のサイトに有るので各自参照しながらやってください。というかこの記事は解答しか書いていないので詰まるまで見ないほうがいいと思います。面白くないですし。

# Level 0
`ssh bandit0@bandit.labs.overthewire.org -p 2220`または`banditssh 0`\
以降もユーザー名を変えて同じですね。

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

これを設定ファイルに書き込んだ上で`banditssh 0`してどうぞ。\

# Level 0 to Level 1
`less readme` または
`cat readme`

# Level 1 to Level 2
`less ./-`

ファイル名が特殊文字の場合はこう書きます。

# Level 2 to Level 3
`less spaces\ in\ this\ filename`

同様。

# Level 3 to Level 4
`ls -a inhere`

隠しファイルもこれで見れます。
というわけで

`less inhere/.hidden`

# Level 4 to Level 5
`file inhere/*`

fileコマンドでファイルの種類を見れます。
あとはテキストファイルをlessしておわり。

# Level 5 to Level 6
`find . -size 1033c`

3つ条件がありますがこれだけで見つけられます。

こういうコマンドの意味がわからない場合`man find`か`find --help`でたいがいの場合なんとかなります。英語をちょっと読まないといけませんが。\
あ、Macの人は(OverTheWireサーバじゃなくて)手元でこれを実行すると**BSDライセンスの別コマンドが出てくる可能性大**ですので気をつけましょう。

# Level 6 to Level 7
`find / -user bandit7 -group bandit6 -size 33c 2>/dev/null`

問題文の条件的には`find / -user bandit7 -group bandit6 -size 33c`だけでいいんですけど、`Permission denied`警告がたくさん出て鬱陶しいです。

こういうときは、`2>`とやるとエラー出力先を画面じゃなくて特定のファイルに変更できます。`/dev/null`は書き込んでも何も起こらないブラックホールです。こうすることで目的の出力だけ出てきますね。

# Level 7 to Level 8
`less`は`/`で検索機能が起動するので、`/millionth<Enter>`で検索できます。

`cat data.txt | grep millionth`でも良し。

# Level 8 to Level 9
`sort data.txt | uniq -u`

`uniq`は名前から受ける印象とは異なり**隣り合った行が一緒なら削る**という仕様なので、さきにソートしてやる必要があります。

# Level 9 to Level 10
`strings data.txt  | grep ==`

先に人間に読める文字だけの行を取り出しましょう。

# Level 10 to Level 11
`base64 -d data.txt`

# Level 11 to Level 12
`cat data.txt | tr '[a-zA-Z]' '[n-za-mN-ZA-M]'`

正規表現から正規表現にするには`tr`が使えますね。

# Level 12 to Level 13
最初に`xxd -r data.txt out.txt`で戻します。\

いつもどおり`file something`でファイルの種類を確認し\

`gzip -d something.gz`か`bzip2 -d something`か`tar -xvf something`で解凍できます。\
`gzip`の方は拡張子が`gz`じゃないとうまくいかないみたいなので適宜`mv something something.gz`とかで改名しました。\

この3つを死ぬほど繰り返すと`data8`が手に入るので終了です。

# Level 13 to Level 14
ホームに有るsshkeyを**自分のパソコンの**`~/.ssh/bandit14_rsa`にでも書き込んで、\
`chmod 600 ~/.ssh/bandit14_rsa`で他の人が読み書きできないようにして、\
`ssh bandit14@bandit.labs.overthewire.org -p 2220 -i ~/.ssh/bandit14_rsa`でアクセスできるので終了。

# Level 14 to Level 15
Level 13に書いてあったようにこのLevelのパスワードは`/etc/bandit_pass/bandit14`にあるので、それをコピーします。
`telnet localhost 30000`でアクセスして、ペースとしたら終了です。\

**telnetは暗号化しないのでインターネットを介した接続には使わないようにしましょう。**

# Level 15 to Level 16
`openssl s_client -connect localhost:30001`で同じようにパスワードを送信してクリアです。

# Level 16 to Level 17
`nmap -A -T4 -p31000-32001 127.0.0.1`でスキャンできます。`127.0.0.1`は`localhost`に同じです。\
さっきと同じようにパスワードを送りつけて、同じのが帰ってこないやつが正解です。\

帰ってきたrsaパスワードを同じようにローカルに保存して
`ssh bandit17@bandit.labs.overthewire.org -p 2220 -i ~/.ssh/bandit17_rsa`でクリア。

# Level 17 to Level 18
`diff passwords.old passwords.new`\
`>`に出力されているのが後ろ、つまり答え。

# Level 18 to Level 19
最初に作ったエイリアスファイルは使わず`ssh bandit18@bandit.labs.overthewire.org -p 2220 "cat readme"`にします。\
なお、どんな悪戯が仕掛けられたのかを確認したかったら`ssh bandit18@bandit.labs.overthewire.org -p 2220 "cat .bashrc"`で。

# Level 19 to Level 20
`./bandit20-do cat /etc/bandit_pass/bandit20`\

ちなみに、`ls -l`で
```shell
-rwsr-x--- 1 bandit20 bandit19 7296 Oct 16 14:00 bandit20-do
```
という結果を得ますが、ご覧の通り4文字目が`x`じゃなくて`s`になってます。そのためこれを実行するとユーザ`bandit20`で実行した扱いになるわけですね。

# Level 20 to Level 21
ちょっとややこしいですが、`suconnect`はlocalhostの指定されたポートでbandit20のパスワードを聞くという仕組みですね。\

なので、まず`nc -l -p 3000 &`で3000番のポートを開きます。\
`-l`はlisten modeの意味で、3000番のポートを「聴いていますよ」モードにします。これで`suconnect`からの接続が可能になります。[^1]\
`&`はバックグラウンド処理送りにするという意味です。\
[^1]:netcatによるサーバ・クライアント接続についてとてもわかり易かったサイト: https://www.digitalocean.com/community/tutorials/how-to-use-netcat-to-establish-and-test-tcp-and-udp-connections-on-a-vps#how-to-communicate-through-netcat

で、同じく`./suconnect 3000 &`でつなぎ。
`jobs`で処理の一覧を確認して`fg <process number>`で`nc`のジョブに移動。\
bandit20のパスワードをペーストしてやれば、つながっている`suconnect`から正解が帰ってくるので終了です。

# Level 21 to Level 22

# Level 22 to Level 23

# Level 23 to Level 24

# Level 24 to Level 25

# Level 25 to Level 26

# Level 26 to Level 27

# Level 27 to Level 28

# Level 28 to Level 29

# Level 29 to Level 30

# Level 30 to Level 31

# Level 31 to Level 32

# Level 32 to Level 33

# Level 33 to Level 34

# Level 34 to Level 35

# Level 35 to Level 36

