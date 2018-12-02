---
title: "LateXで誰でも簡単に英文履歴書が作れるクラスを作った"
date: 2018-12-01T21:17:53-05:00
description: "クラスファイルはダウンロード可・再利用自由なのでお使いください。"
banner: "img/スクリーンショット 2018-12-01 23.12.21.png"
disable_comments: false # Optional, disable Disqus comments if true
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
[こんな感じ](/latex/Resume.pdf)で、ソースファイルは[これ](/latex/source-resume.tar.gz)

落としたソースファイルを適当に改造しながら使ってくれたらいいんだけど、せっかくなのでクラスファイルについて少し解説。

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

のようにletterpaperオプションを付けたものに相当するようになるという意味。

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
\newcommand*{\fullname}[2]{{\firstnamefont{#1}\fontsize{24pt}{4em}\ \ \lastnamefont{#2}}}
```
をクラスファイルで定義しているので、
```latex
\fullname{John}{Doe}
```
でいい感じにフルネームがどーんと表記される。

おわり。海外で就活したい時とかに使ってください。
