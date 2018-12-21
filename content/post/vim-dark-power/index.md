---
title: "自分のVimのプラグイン環境設定 Dein/Denite/Deopleteを動かすまで"
date: 2018-12-13T11:12:52-05:00
description: "あるいはいかにして私は心配するのをやめて闇の力を愛するようになったか"
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

自分が普段使っているのはNeoVimである。\
Neovimは後述するリモートプラグインという仕組みを持っていて、Vim Script以外で書かれているプラグインも使用できるのが嬉しい。

# NeoVimのインストール

Macの場合NeoVimはHomebrewを使えば簡単にインストールできる。「Homebrewって何？」という人は次の一行をターミナルで実行してから進んでほしい。Homebrewについて詳しくは[こちら](https://brew.sh)
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

これでHomebrewというパッケージマネージャがインストールされる。これをつかってNeoVimをインストールする。

```
brew install neovim
```

NeoVimは`nvim`で起動できる。

Mac以外も調べればすぐ出てくると思うので省略する。以降は共通のはずである。

# 闇の力のインストール

闇の力というのは**De-**で始まる[ShougoMatsu](https://github.com/Shougo)さんの公開されてるvimプラグインシリーズのこと。\
**Dark powered nEo -**の略称らしく、Shougoさんが今まで開発していたNeoシリーズに比べ（特に多くのファイルを開いたときに）高速化している。\
なぜ速いかというと、リモートプラグインを用いて**本体部分がVim Scriptより速いPythonで書かれている**から。リモートプラグインについては[こちらの記事](https://qiita.com/lighttiger2505/items/440c32e40082dc310c1e#remote-plugins)がわかりやすい。

というわけで今回の記事ではそのうち**deoplete.nvim**,**denite.nvim**,**dein.vim**を入れることを目標にする。いずれも非常に強力かつ完成度の高いプラグインである。

* deopleteは補完プラグイン。プログラミングのときに役に立つ。
* deniteは検索プラグイン。今までに開いたファイル、カレントディレクトリの下にあるファイル、ヤンク履歴、バッファ等色々なものを高速で検索してくれる。
* deinはそれらを自動でインストールしてくれるパッケージマネージャ。

## Pythonの設定

```
# 使っているパッケージマネージャに合わせて次のうちどちらか
# なお、Pythonは3.6以降を推奨、3以降が必須
pip3 install neovim
conda install neovim
```

リモートプラグインがNeovimと通信するためにneovimパッケージがimportされる必要がある。

## init.vim
NeoVimの設定ファイルは`.vimrc`ではなく`~/.config/nvim/init.vim`に書く。\
ここ以降の内容は[自分の設定をgithubにあげている](https://github.com/woodyZootopia/nvim)ので参考にしてもいいかもしれない。

まずは次の内容をinit.vimにコピペする。

```
"plugin settings
let s:cache_home = expand('~/.config/nvim')
let s:dein_dir = s:cache_home . '/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif
let &runtimepath = s:dein_repo_dir .",". &runtimepath
let g:python3_host_prog = substitute(system("which python3"), '\n', '', 'g')

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  " locate toml directory beforehand
  let g:rc_dir    = s:cache_home . '/toml'
  let s:toml      = g:rc_dir . '/dein.toml'
  let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

  " read toml file and cache them
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

if dein#check_install(['vimproc.vim'])
  call dein#install(['vimproc.vim'])
endif

if has('vim_starting') && dein#check_install()
  call dein#install()
endif
```
これで、deinというVim用のパッケージマネージャがインストールされる。これを使って残りのプラグインもインストールするわけである。\
最後の方で、`call dein#install(['vimproc.vim'])`とあるように最初にvimprocをインストールして、そのあとで残りのプラグインをインストールしていく。vimprocはdeinで並列処理をするのに必要なプラグインで、バックグラウンド処理を可能としてくれるので、重い処理をしてもVimが固まらなくなる。

さて、では肝心の残りのプラグインだが、ここではなく別の場所に書く。ここにはキーマッピングなども書くため、プラグインをすべて書いていては幅をとって読みづらくなってしまう。\

キーマッピングの例としては、たとえばinit.vimに`inoremap fd <ESC>`と追記し、vimを再起動すると、エスケープキーの代わりに`fd`をすばやく押すことでノーマルモードに戻ることができる。[^2]
エスケープは遠すぎるのでこのタイプのキーマッピングをつけている人は多いだろう。。

[^2]:他には`jj`派や`Ctrl-j`派がいるらしい。`Ctrl-j`にするには`<C-j>`とすればよい。

閑話休題。\
先程コピペしてもらったものの真ん中あたりに`" locate toml directory beforehand`とあるあたりで、プラグインをどこに書くかを指定している。\
ここでは、必ず必要になるものを`~/.config/nvim/toml/dein.toml`,ファイル形式・状況に応じて起動したいものを`~/.config/nvim/toml/dein_lazy.toml`に書くようにしている。\
このtomlファイルには、読み込み時にのみ実行する命令も書いておくことができる。以下で、`hook何某`とあるのがそれである。

## dein.toml

まず、`dein.toml`の方に書く内容だが、

* dein,vimprocは常に必要なので書く。
* deniteはファイル探索プラグインであり、常に必要となるので書く。

というわけで、

```
[[plugins]]
repo = 'Shougo/dein.vim'

[[plugins]]
repo = 'Shougo/vimproc.vim'
hook_post_update = '''
  let cmd = 'make'
  let g:dein#plugin.build = cmd
'''

[[plugins]]
repo = 'Shougo/denite.nvim'
hook_add='''
  nnoremap <silent> <space>fr :<C-u>Denite file_mru<CR>
  nnoremap <silent> <space>fb :<C-u>Denite buffer<CR>
  nnoremap <silent> <space>fy :<C-u>Denite neoyank<CR>
  nnoremap <silent> <space>ff :<C-u>Denite file_rec<CR>
  nnoremap <silent> <space>fu :<C-u>Denite outline<CR>
'''
[[plugins]]
repo = 'Shougo/unite-outline'
[[plugins]]
repo = 'Shougo/neomru.vim'
[[plugins]]
repo = 'Shougo/neoyank.vim'
```

ちなみに`<silent>`をつけているため画面下のログが出ない。そんなに変わらないが、気になる人は外して試してみてほしい。\

その下に３つの補助プラグインがあるが、それぞれdeniteの追加機能である。

* `<space>fr`で最近使ったファイルを検索できる。
* `<space>fb`で開いているバッファを検索できる。
* `<space>fy`でヤンク（コピー）履歴検索できる。
* `<space>ff`で現在のディレクトリの下にあるファイルを検索できる。
* `<space>fu`で現在のファイルのアウトラインを検索。

また、検索結果が十分に絞り込まれたと感じたら、`Ctrl-o`で検索結果の中に入り、ノーマルモードのように`j`と`k`でどれを開くか選択できる。\
とても便利なのでガシガシ使ってほしい。

## dein_lazy.toml

deopleteの方は、インサートモードに入ってから起動するので十分なので、[^1]こちらに書く。
[^1]:大きなファイルを開いたときなどに、インサートモードに入ってからちょっとの間補完が機能しないという問題はあるが、そこまで大した問題ではない。

```
[[plugins]]
repo = 'Shougo/deoplete.nvim'
hook_source = '''
  let g:deoplete#enable_at_startup = 1

  inoremap <expr><tab> pumvisible() ? "\<C-n>" : "\<tab>"

  inoremap <expr><BS>  deoplete#smart_close_popup()."\<C-h>"

  " Expand the completed snippet trigger by <CR>.
  imap <expr><CR>
  \ (pumvisible() && neosnippet#expandable()) ?
  \ "\<Plug>(neosnippet_expand)" : "<C-r>=<SID>my_cr_function()<CR>"

  function! s:my_cr_function() abort
    return deoplete#close_popup() . "\<CR>"
  endfunction

  let g:deoplete#auto_complete_delay = 0
  let g:deoplete#enable_camel_case = 0
  let g:deoplete#enable_ignore_case = 0
  let g:deoplete#enable_refresh_always = 0
  let g:deoplete#enable_smart_case = 1
  let g:deoplete#file#enable_buffer_path = 1
  let g:deoplete#auto_complete_start_length = 1
  let g:deoplete#max_list = 100
'''
on_i = 1

[[plugins]]
repo = 'Shougo/neco-syntax'
on_i = 1

[[plugins]]
repo = 'Shougo/neosnippet'
hook_source = '''
  imap <C-k> <Plug>(neosnippet_expand_or_jump)
  smap <C-k> <Plug>(neosnippet_expand_or_jump)
  xmap <C-k> <Plug>(neosnippet_expand_target)
  if has('conceal')
    set conceallevel=0 concealcursor=niv
  endif
'''
on_i  = 1
depends = ['neosnippet-snippets']

[[plugins]]
repo= 'Shougo/neosnippet-snippets'
```

deopleteの補完候補を拡張するため、次のプラグインもインストールしてある。

* neco-syntax
 * シンタックスファイルを使って補完してくれるプラグイン
* neosnippet
 * スニペット（定型構文）を補完するためのプラグイン
* neosnippet-snippets
 * おすすめのスニペットがたくさん入っているプラグイン

なお、neosnippetの改良版である[deoppet.nvim](https://github.com/Shougo/deoppet.nvim)もあるが、まだ実装が完了していないので使わない。

Tabキーで補完候補の中を移動することができる。行き過ぎて戻るときは`Ctrl-p`。
neosnippetを使うときは、次の入力場所に移動するときには`Ctrl-k`を押すとよい。実際に使ってみればすぐわかると思うが、以下に動画も置いておく。

![動画](sample movie.mov)

## 外部ファイルによる補完

deopleteはライブラリ補完を標準ではサポートしておらず、追加プラグインを入れる仕組みになっている。どのような言語が対応しているかは[completion sources](https://github.com/Shougo/deoplete.nvim/wiki/Completion-Sources)にある。ここではPythonの追加プラグイン[deoplete-jedi](https://github.com/zchee/deoplete-jedi)を入れてみる。

```
[[plugins]]
repo = 'davidhalter/jedi'
on_ft = 'python'

[[plugins]]
repo = 'zchee/deoplete-jedi'
hook_source = '''
let g:deoplete#sources#jedi#server_timeout = 20
'''
on_ft = 'python'
```

これを`dein_lazy.toml`に追記すればよい。\
numpyやTensorFlowなどなどがimportされているファイルでは補完が効くようになり非常に便利である。[^3]\

なお、どこかで詰まった場合はVimを開いて`:checkhealth`を実行するとどこがだめなのかチェックしてくれるので参考にしてほしい。

以上です。

> 闇の世界にようこそ。<cite>--ShougoMatsu</cite>

[^3]:これらは大きなライブラリなので最大で１０秒程度補完が効くまで掛かる可能性がある。ガマン。
