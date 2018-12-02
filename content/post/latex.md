---
title: "Latexでpdfファイル『だけ』を手に入れるためのオレオレ快適設定"
date: 2018-12-01T10:49:58-05:00
description: "または私はいかにして中間ファイルについて心配するのをやめてコマンドラインでのlatexを愛するようになったか"
# thumbnail: "img/placeholder.jpg" # Optional, thumbnail
# disable_comments: false # Optional, disable Disqus comments if true
# authorbox: true # Optional, enable authorbox for specific post
toc: false # Optional, enable Table of Contents for specific post
# mathjax: true # Optional, enable MathJax for specific post
categories:
  - "技術"
  - "備忘録"
tags:
  - "Latex"
  - "shell"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

latexの設定をいろいろいじったらいい感じになったので備忘録。\
環境構築はできている前提にします。MacTexとかTexLiveを入れましょう。

とりあえず、コンパイルにはlatexmkが最強なので使いましょう。自動でpdfまでコンパイルしてくれるスグレモノです。
```shellscript
$ latexmk yourthesis.tex
```

ただ、これをすると中間ファイルがドバー出てきて作業環境がとても見づらくなります。かなしいですね。\
あと、pdfファイルが完成したんなら自動でプレビューしてくれる仕組みも欲しいところですね。

作りましょう。

まずはプレビューの仕組みから。\
設定を.latexmkrcに書き込みます。

```.latexmkrc
#!/usr/bin/perl
$latex                   = 'platex -interaction=nonstopmode -synctex=1 -halt-on-error';
$latex_silent            =                             'platex -interaction=batchmode';
$dvips                   =                                                     'dvips';
$bibtex                  =                                                   'pbibtex';
$makeindex               =                                  'mendex -r -c -s jind.ist';
$dvipdf                  =                                      'dvipdfmx %O -o %D %S';
$pdf_previewer           =                                           'open -a Skim %S';
$preview_continuous_mode =                                                           1;
$pdf_mode                =                                                           3;
$pdf_update_method       =                                                           4;
$aux_dir                 =                   "$ENV{HOME}/.tmp/tex/" . basename(getcwd);
$out_dir                 =                                                    $aux_dir;
```

latexmkを使うと、自動的に更新監視モードに入り、Ctrl+cで終了するまで更新し続けてくれます。
ただし、pdf_previewerの行はMac用のアプリSkimを使うためのものです。
そうでない人はそうでない感じにしてください。\
ここまでで詰まった人のための参考:
http://teru0rc4.hatenablog.com/entry/2017/01/28/213102

これだけでは中間ファイル含めた全てのファイルが~/.tmp/texに流されちゃって、欲しかったpdfも出て来ないです。\
いちいち.tmpフォルダに取りに行くのは賢くないので、自動で取りに行ってくれるようにちょこっといじりましょう。

.bashrcか.zshrcをいじります：
```.zshrc
fetchlatexpdf ()
{
  local filename=$(echo "$@" | sed -e "s/\.tex//g")
  cp ~/.tmp/tex/$(basename $PWD)/$filename.pdf ./$filename.pdf
	#change "~/.tmp/tex/" to your latex temporary folder.
}

ltxmkandfetchpdf ()
{
  \latexmk "$@" ; fetchlatexpdf "$@"
}

alias latexmk='ltxmkandfetchpdf'
alias cleantextmp="rm -rf ~/.tmp/tex"
```

いじりました。

fetchlatexpdfは、引数の名前を持つpdfファイルを.tmpディレクトリまで取りに行ってカレントディレクトリにおいてくれます。\
ltxmkandfetchpdfは、latexmkを実行したあとfetchlatexpdfを実行します。\
最後にエイリアスをかければ終了です。 いつもと同じように、
```latexmk.sh
$latexmk yourthesis.tex
```
をしてやってCtrl+cで終了すると、カレントディレクトリにpdfを移しておいてくれます。便利ですね。

なお、ltxmkandfetchpdfのなかでlatexmkの前にバックスラッシュがついているのは、エイリアス前のlatexmkを実行するという意味です。

あと、すごく複雑なファイルが上手くコンパイルできなくなり、一回ゼロからやり直したくなった場合、cleantextmpを実行しましょう。\
これを行わない限り.tmpディレクトリにある中間ファイルは再利用されるので、コンパイル時間も通常使用時は変わりません。嬉しいですね。

なお、ここに書いたコードはgistにもあげてます:
https://gist.github.com/woodyZootopia/32caa7bac7cdd1b3e56691f0db76a763

それでは、快適なコマンドラインlatexライフを。

