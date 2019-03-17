---
title: "VimでLatexの括弧補完をする"
date: 2019-03-17T11:11:32-04:00
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
  - "Latex"
  - "Vim"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

Vimには`(`と入力すると`()`と自動で保管してくれたりする、[cohama/lexima](https://github.com/cohama/lexima.vim)なる便利なプラグインがある。

`dein`で簡単にインストールできる。
```dein.toml
[[plugins]]
repo = 'cohama/lexima.vim'
```

そして、Latexにおける`$$`や`\(\)`の補完をしたいので、`hook_add`を使って次のように書く。

```dein.toml
[[plugins]]
repo = 'cohama/lexima.vim'
hook_add = '''
call lexima#add_rule({'char': '$', 'input_after': '$', 'filetype': ['latex','tex']})
call lexima#add_rule({'char': '$', 'at': '\%#\$', 'input_after': '$', 'filetype': ['latex','tex']})
call lexima#add_rule({'char': '<BS>', 'at': '\$\%#\$', 'delete': 1, 'filetype': ['latex','tex']})

call lexima#add_rule({'char': '(', 'at': '\\\%#', 'input_after': '\)', 'filetype': ['latex','tex']})
call lexima#add_rule({'char': '[', 'at': '\\\%#', 'input_after': '\]', 'filetype': ['latex','tex']})
'''
```

以上
