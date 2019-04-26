---
title: "オレオレVim備忘録"
date: 2019-04-26T19:05:24-04:00
# description: "Example article description"
# banner:"/img/some.png"
# lead: "Example lead - highlighted near the title"
# disable_comments: true # Optional, disable Disqus comments if true
disable_profile: true # no one wants to see my profile while reading articles
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
categories:
  - "技術"
  - "備忘録"
tags:
  - "Vim"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

最近Vimのドキュメントを読むのにハマっており、標準でもかなりの数の便利な機能があることを知った。
だが普段は使わないものも多く、読んだだけでは忘れそうなのでここにメモしておく。

当然この記事の内容は[vimdoc-ja](https://vim-jp.org/vimdoc-ja/)の書き直しなので、一切の権利を主張しない。

# コマンドライン補完
`:`でコマンドを打っている途中、`<C-d>`で現在時点での候補を一覧できる。

`<Tab>`で補完できる。`<C-p>``<C-n>`で補完候補を選択できる。補完したは良いものの、別の候補が出てきてしまったのでやり直したい場合はその場で`<C-p>`

矢印キー上下で過去のコマンドを探せる(シェルと似た動作)が、`:se<Up>`のようにすると、`:se`から始まる過去のコマンドを探せる。
