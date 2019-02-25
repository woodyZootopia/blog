---
title: "LSPがとっても便利なのでDeopleteと併用する"
date: 2019-02-17T15:42:23-05:00
description: "備忘録"
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
  - "vim"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

VimとLSPの組み合わせがとっても良かったのでメモ。

# LSPとはなんぞや
マイクロソフトによって提唱された「プログラミング支援機能の共通言語」。補完その他の便利機能をローカルに立ち上げた**言語サーバ**とエディタがやり取りするという形で行う。

そのやり取りに使われている言語が**LSP(Language Server Protocol)**。\

これを共通化しておけば、各言語・各エディタにその言語を処理できる仕組みを用意するだけで、便利機能がカンタンに使えるようになるというわけ。[^ref]\

Vimの場合、言語サーバの立ち上げ・言語サーバとのやり取りをやってくれる`autozimu/LanguageClient-neovim`と[^native_support]、それをつかって補完候補を`deoplete`に表示してくれる`Shougo/deoplete-lsp`を使えばよい。

[^ref]:[ここの説明](https://qiita.com/atsushieno/items/ce31df9bd88e98eec5c4)は、特に前半の図とかが分かりやすかった。
[^native_support]:[neovim本体にLSPをつける予定もある](https://neovim.io/roadmap/)ようだが、現在のバージョン0.3に対し0.5からなのでまだしばらくはかかりそうである。

# インストールどうすればええのん？

まず、dein[^prereq]を使ってプラグインをインストール:
[^prereq]: deinのインストールなどは[こちら]({{< relref "/post/vim-dark-power/index.md" >}})
```toml
[[plugins]]
repo = 'autozimu/LanguageClient-neovim'
rev = 'next'
build = 'bash install.sh'
[[plugins]]
repo='Shougo/deoplete-lsp'
```

次に、Vim設定ファイルに以下を追記:

```vim
let g:LanguageClient_serverCommands = {}

" 言語ごとに設定する
if executable('clangd')
    let g:LanguageClient_serverCommands['c'] = ['clangd']
    let g:LanguageClient_serverCommands['cpp'] = ['clangd']
endif

if executable('pyls')
    let g:LanguageClient_serverCommands['python'] = ['pyls']
endif

let g:LanguageClient_autoStart = 1
```

ここでは、C/C++とPythonの言語サーバである`clangd`と`pyls`を設定している。これらが実行できないといけないので、これらもインストールしておく。\

インストールしたらシェルで`which clangd`や`which pyls`と実行してみて、パスが通っていることを確認しておこう。[^path_problem]

[^path_problem]:Ubuntuでaptをつかってインストールしたところ、clangdの実行ファイルはバージョン名つきのもの(自分だと`clangd-7.0`)になっていた。そのような場合は、`ln`か`update-alternatives`を使ってパスを通すか、Vim設定ファイルの中の`if executable('clangd')`のところを適宜変更するなどして対応するといいだろう。


これでdeopleteの検索候補に`clangd`や`pyls`の結果が出てくるようになる。

# さらなる機能

## セマンティックチェック
Vim設定ファイルに以下を追記する:
```vim
augroup LanguageClient_config
    autocmd!
    autocmd User LanguageClientStarted setlocal signcolumn=yes
    autocmd User LanguageClientStopped setlocal signcolumn=auto
augroup END
```
プログラムのミス（文法ミスだけでなく、関数の引数など割と高度なことも）を自動で指摘してくれる。\

**変数名や文法のちょっとしたミスでコンパイルエラーになるのを防いでくれる。超便利。**個人的にはこれをやるためだけでもLSPを導入する価値があると思う。


## キーバインド
Vim設定ファイルに以下を追記する:
```vim
function LC_maps()
    if has_key(g:LanguageClient_serverCommands, &filetype)
        " any keybindings you want, such as ...
        nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<CR>
        nnoremap <silent> <Leader>lh :call LanguageClient_textDocument_hover()<CR>
        nnoremap <silent> <Leader>ld :call LanguageClient_textDocument_definition()<CR>
        nnoremap <silent> <Leader>lr :call LanguageClient_textDocument_rename()<CR>
        nnoremap <silent> <Leader>lf :call LanguageClient_textDocument_formatting()<CR>
    endif
endfunction

autocmd FileType * call LC_maps()
```

このようにするとLSP対応のファイルの場合のみキーバインドが行われる。\

特に、`K`はこのようにしないと既存のマップを塗り替えてしまう。こうすることで、Vim Scriptなどを開いているときは通常通りVim標準Docを、LSP対応のファイルを開いているときはそのファイルに対応した説明ファイルを開くということができる。

## 同じ変数をハイライト
Vim設定ファイルに以下を追記する:
```vim
augroup LCHighlight
    autocmd!
    autocmd CursorHold,CursorHoldI *.py,*.c,*.cpp call LanguageClient#textDocument_documentHighlight()
augroup END

" カーソル停止から更新までの時間をミリ秒で記入。デフォルトは4秒
set updatetime=50
```

このようにするとカーソル上の変数・関数・メソッドなどと同じものを自動でハイライトしてくれる。これまた便利。

以上
