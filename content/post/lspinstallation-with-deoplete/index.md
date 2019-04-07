---
title: "LSPがとっても便利なのでNeovimで使う"
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

Vimの場合、言語サーバの立ち上げ・言語サーバとのやり取りをやってくれる`autozimu/LanguageClient-neovim`[^native_support]をインストールすればよい。

[^ref]:[ここの説明](https://qiita.com/atsushieno/items/ce31df9bd88e98eec5c4)は、特に前半の図とかが分かりやすかった。
[^native_support]:[neovim本体にLSPをつける予定もある](https://neovim.io/roadmap/)ようだが、現在のバージョン0.3に対し0.5からなのでまだしばらくはかかりそうである。

# インストールどうすればええのん？

例によってNeoVimのみ動作確認済み。

まず、dein[^prereq]を使って必要なプラグインをインストール:

[^prereq]: deinのインストールなどは[こちら]({{< relref "/post/vim-dark-power/index.md" >}})

```dein.toml
[[plugins]]
repo = 'autozimu/LanguageClient-neovim'
rev = 'next'
build = 'bash install.sh'
```
とかく。

次に、

```init.vim
let g:LanguageClient_serverCommands = {}

" 言語ごとに設定する
if executable('clangd')
    let g:LanguageClient_serverCommands['c'] = ['clangd']
    let g:LanguageClient_serverCommands['cpp'] = ['clangd']
endif

if executable('pyls')
    let g:LanguageClient_serverCommands['python'] = ['pyls']
endif

" 自分の環境では重たくなったのでオフにしておく
let g:LanguageClient_useVirtualText = 0
```

ここでは、C/C++とPythonの言語サーバである`clangd`と`pyls`を設定している。これらが実行できないといけないので、これらもインストールしておく。\

インストールしたらシェルで`which clangd`や`which pyls`と実行してみて、パスが通っていることを確認しておこう。[^path_problem]

[^path_problem]:Ubuntuでaptをつかってインストールしたところ、clangdの実行ファイルはバージョン名つきのもの(自分だと`clangd-7.0`)になっていた。そのような場合は、`ln`か`update-alternatives`を使ってパスを通すか、Vim設定ファイルの中の`if executable('clangd')`のところを適宜変更するなどして対応するといいだろう。また、MacOSで`brew install llvm`を使ってインストールした場合、パスを通さないと使えない。`export PATH="/usr/local/opt/llvm/bin:$PATH"`と実行すればいい。詳しく知りたい人は`brew info llvm`で。

これで補完の検索候補に`clangd`や`pyls`の結果が出てくるようになる。

自分の最新の設定は[こちら](https://raw.githubusercontent.com/woodyZootopia/nvim/master/plugins/languageclient.vim)に上げているので参考にしてほしい。

これら以外の言語サーバの開発状況については、提唱元の[Microsoftによる一覧表](https://microsoft.github.io/language-server-protocol/implementors/servers/)をご覧頂きたい。同じように言語サーバを事前にインストールし、パスを通してここに書けば使うことができる。

# さらなる機能

## セマンティックチェック
プログラムのミス（文法ミスだけでなく、関数の引数など割と高度なことも）を自動で指摘してくれる。\

**変数名や文法のちょっとしたミスでコンパイルエラーになるのを防いでくれる。超便利。**個人的にはこれをやるためだけでもLSPを導入する価値があると思う。

以下を追記するのをおすすめする:

```init.vim
augroup LanguageClient_config
    autocmd!
    autocmd User LanguageClientStarted setlocal signcolumn=yes
    autocmd User LanguageClientStopped setlocal signcolumn=auto
augroup END
```
これは、文法ミスなどがあったときに出てくる記号の場所を常に開けておくようにする設定である。

## キーバインド
以下を追記する:
```init.vim
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

特に、`K`は既存のマップを塗り替えてしまう。こうすることで、Vim Scriptなどを開いているときは通常通りVim標準Docを、LSP対応のファイルを開いているときはそのファイルに対応した説明ファイルを開くということができる。

## 同じ変数をハイライト
以下を追記する:
```init.vim
augroup LCHighlight
    autocmd!
    autocmd CursorHold,CursorHoldI *.py,*.c,*.cpp call LanguageClient#textDocument_documentHighlight()
augroup END

" カーソル停止から更新までの時間をミリ秒で記入。デフォルトは4秒=4000
set updatetime=50
```

このようにするとカーソル上の変数・関数・メソッドなどと同じものを自動でハイライトしてくれる。これまた便利。

上にも書いたが、自分の最新の設定を以下に書いてあるので参考にしてほしい。
https://raw.githubusercontent.com/woodyZootopia/nvim/master/plugins/languageclient.vim

以上
