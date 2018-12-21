---
title: "コマンドラインのLatexでpdfファイルだけを手に入れる快適設定"
date: 2018-12-01T10:49:58-05:00
description: "または私はいかにして中間ファイルについて心配するのをやめてコマンドラインでのlatexを愛するようになったか"
# thumbnail: "img/placeholder.jpg" # Optional, thumbnail
# disable_comments: false # Optional, disable Disqus comments if true
disable_profile: true # no one wants to see my profile while reading articles
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

# Latexmkがおすすめ
とりあえず、コンパイルにはlatexmkが最強なので使いましょう。自動でpdfまでコンパイルしてくれるスグレモノです。
```shellscript
latexmk yourthesis.tex
```

ただ、これをすると**中間ファイルがドバーっと出てきて作業環境がとても見づらくなります**。かなしいですね。\
あと、pdfファイルが完成したんなら**自動でプレビューしてくれる仕組み**も欲しいところですね。

作りましょう。

# .latexmkrcの設定
まずはプレビューの仕組みから。\
設定を`~/.latexmkrc`に書き込みます。

```latexmkrc
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

この設定にした上でlatexmkを使うと、自動的に更新監視モードに入り、Ctrl+cで終了するまで更新し続けてくれます。\
pdf_previewerの行はMac用のアプリSkimを使うためのものです。\
また、platexが日本語を使う人にはおすすめなのでそのようにしています。\

ここまでで詰まった人のための参考:
http://teru0rc4.hatenablog.com/entry/2017/01/28/213102

# シェル関数の設定
ただ、これだけでは中間ファイル含めた全てのファイルが`~/.tmp/tex`に流されちゃって、欲しかったpdfが出て来ないです。\
いちいち.tmpフォルダに取りに行くのは賢くないので、自動で取りに行ってくれるようにちょこっといじりましょう。

```.zshrc
#以下を、~/.bashrcか~/.zshrcに追記
fetchlatexpdf ()
{
  local filename=$(echo "$@" | sed -e "s/\.tex//g")
  cp ~/.tmp/tex/$(basename $PWD)/$filename.pdf $(dirname "$@")/$filename.pdf
  #make sure to change "~/.tmp/tex/" to your latex temporary folder.
}

latexmkandfetchpdf ()
{
  \latexmk "$@" ; fetchlatexpdf "$@"
}

alias latexmk='latexmkandfetchpdf'
alias cleantextmp="rm -rf ~/.tmp/tex"
```
いじりました。

fetchlatexpdfは、引数の名前を持つpdfファイルを.tmpディレクトリまで取りに行ってカレントディレクトリにおいてくれます。\
latexmkandfetchpdfは、latexmkを実行したあとfetchlatexpdfを実行します。\

## 2018-12-20追記
自分がfishを使い始めたのでfish版も作りました。ついでに引数の個数のチェックもつけた豪華版です。
```
# 以下を、~/.config/fish/config.fishに追記
function fetchlatexpdf
  if test (count $argv) -ne 1
    echo "please input only one file."
    echo "Usage: fetchlatexpdf yourthesis.tex"
  else
    set -l filename (echo "$argv" | sed -e "s/\.tex//g")
    cp ~/.tmp/tex/(basename $PWD)/$filename.pdf (dirname "$argv")/$filename.pdf
    #make sure to change "~/.tmp/tex/" to your latex temporary folder.
  end
end

function latexmk
  if test (count $argv) -ne 1
    echo "please input only one file."
    echo "Usage: latexmk yourthesis.tex"
  else
    command latexmk $argv ; fetchlatexpdf $argv
  end
end

function cleantextmp
  rm -rf ~/.tmp/tex
end
```

## 2018-12-21追記
上の2つでもちゃんと動くのですが、fishは文法がちょっと違って面倒なので、共通化するためシェルスクリプト化しました。\
[gist](https://gist.github.com/woodyZootopia/348573dc195acf0ef0f39fae7b4bf5e3)にあげてます。\
細かい引数の書式チェックに加え、.texファイルが入ったフォルダからじゃなくても実行できるように改良してます。


# 使い方
## latexmkandfetchpdf
すごく長い名前になっていますが、エイリアスしているので、
```latexmk.sh
latexmk yourthesis.tex
```
をして更新監視モードに入り、Ctrl+cで終了すると、カレントディレクトリにpdfを移しておいてくれます。便利ですね。

なお、latexmkandfetchpdfのなかでlatexmkの前にバックスラッシュがついているのは、エイリアス前のlatexmkを実行するという意味です。

## cleantextmp
すごく複雑なファイルが上手くコンパイルできなくなり、一回ゼロからやり直したくなった場合、`cleantextmp`を実行しましょう。\
これを行わない限り.tmpディレクトリにある中間ファイルは再利用されます。嬉しいですね。

それでは、快適なコマンドラインlatexライフを。\
終わり
