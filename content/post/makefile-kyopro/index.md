---
title: "競プロ用Makefileのススメ"
date: 2019-01-30T18:55:10-05:00
description: "友達にツイッターで回答した内容をまとめました。"
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


競技プログラミングでいちいち`g++ -Wall -o hoge hoge.cpp`ってやってると時間がかかります。\

いちいち面倒なので、`make`コマンドを使うと良いです（他にいい方法があったら教えてください）。

文法の解説自体はネットにいくらでも上がっているので割愛します。競プロ、特にAtcoderで使いたい人向けの記事です[^why-not-quickrun]。

[^why-not-quickrun]:[vim-quickrun](https://github.com/thinca/vim-quickrun)がvimからの手軽さだと最強なんですけど、標準入力するファイルを用意してやらないといけないので標準入出力で解答するAtcoderだとスピーディさに欠けるんですよね……

`make`は、コンパイルしたいファイルと同じ場所に`Makefile`というファイルを置くことで使うことができます。というわけで、以下を競プロ用の全フォルダに置きましょう。
```makefile
CXXFLAGS=-std=c++14 -Wall

a:a.cpp
b:b.cpp
c:c.cpp
d:d.cpp
e:e.cpp
f:f.cpp

clean:
	rm ?
```

これで、`make c`とやると`c.cpp`がコンパイルされ、実行ファイル`c`が出てきます。`./c`とやると実行できます。タイピング量が少なくていいですね[^mie]。\

[^mie]:F問題とかたどり着いたことすらないのに一応書いてあるのは ~~見栄~~ 将来の実力の伸びを考慮したものです。

`make clean`で実行ファイルを全部消すこともできます。楽ちんですね。\
こっちは正規表現に慣れてれば`rm ?`の方が速いでしょうか。

書き方の話をしますと、`引数:依存ファイル`の順番で書きます。\
それに続いてタブを行頭に入れてコマンドを指定することができ、コマンドが指定されていなければ、標準のコンパイラで`依存ファイル`をコンパイルして`引数`という名前で出力します。

最初の行にある`CXXFLAGS`が`.cpp`ファイルをコンパイルする際に与えられるオプションです。\
なので、好みに応じて`CXXFLAGS`は変えたほうが良いかもしれません。

例えば、この記事を書いている現在Atcoderのgccは確かC++14対応だったのでそれに合わせていますが、自分のやりたいサイトに合わせてそこは変えると良いでしょう。

他には、自分はMacの環境だからか`bits/stdc++.h`がインクルードファイルの中にないので、自分で適当な場所に`bits/stdc++.h`ファイルを置き、\
```makefile
CXXFLAGS=-I <path_to_bits_directory> -std=c++14 -Wall
```
としています。

なお、

以上
