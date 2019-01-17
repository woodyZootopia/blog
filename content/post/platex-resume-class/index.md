---
title: "LateXで英文履歴書を作る"
date: 2018-12-01T21:17:53-05:00
description: "クラスファイルはダウンロード可・再利用自由なのでお使いください。"
banner: "banners/platex-resume-class.png"
disable_comments: false # Optional, disable Disqus comments if true
disable_profile: true # no one wants to see my profile while reading articles
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
categories:
  - "技術"
  - "備忘録"
tags:
  - "Latex"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

# 完成品
ソースファイルを[ここ](https://github.com/woodyZootopia/resume)にあげてある。PDFは[これ](https://github.com/woodyZootopia/resume/raw/master/resume.pdf)\
なお、pLaTeXのみ対応。それ以外の場合修正が必要かも。platexのおすすめ設定は[こっちの記事](2018/12/コマンドラインのlatexでpdfファイルだけを手に入れる快適設定/)に書いてるので読んでみてくださいな。

# 解説
落としたソースファイルを適当に改造しながら使ってくれたらいいのだけど、せっかくなのでクラスファイルについて少し解説をば。

クラスファイルはちょっと命令の名前が違ったりするけど、ほかは大体いつもの.texファイルと一緒なので扱いやすい。\
読めば何となく分かると思うので、なんとなくじゃわかりそうにないところを解説する。

## \ProvidesClass

`\ProvidesClass{woody-cv}[2018/11/18]` を書くことで外部からwoody-cvの名前で呼び出せるようになる。[]内は自分の好きなオプション。特に意味はない。

## \LoadClassWithOptions

` \LoadClassWithOptions{article} ` はarticleクラスをベースに利用するということ。

WithOptionsとは、texファイルで`\documentclass[letterpaper]{woody-cv}`のように呼ばれた時、

```latex
\documentclass[letterpaper]{article}
```

のようにletterpaperオプションを付けたものをベースに利用することに相当するようになるという意味。

## \newcommand

構文を覚えれば良い。
```latex
\newcommand*{\my_command}{\some_command}
```
は`\my_command`を`\some_command`にエイリアスする。

```latex
\newcommand*{\my_command}[3]{\some_command{#1}{#2}{#3}}
```
のように、[n]をつけると自作コマンドはその数だけの引数を取るようになり、{#n}のところにそれぞれ代入される。引数は最大９個。
例えば、
```latex
\newcommand*{\firstnamefont}[1]{{\fontsize{24pt}{4em}\textbf {#1}}}
\newcommand*{\lastnamefont}[1]{{\fontsize{24pt}{4em}\textbf {#1}}}
\newcommand*{\fullname}[2]{{\firstnamefont{#1}\fontsize{24pt}{4em}\ \ \lastnamefont{#2}}}
```
をクラスファイルで定義しているので、
```latex
\fullname{John}{Doe}
```
でいい感じにフルネームがどーんと表記される。

おわり。海外で就活したい時とかに使ってください。
