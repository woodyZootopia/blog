---
title: "自分の普段使っているVimプラグインを一挙紹介"
date: 2019-01-09T11:21:22-05:00
# description: "Example article description"
# banner:"/img/some.png"
# lead: "Example lead - highlighted near the title"
# disable_comments: true # Optional, disable Disqus comments if true
disable_profile: true # no one wants to see my profile while reading articles
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
draft: true
categories:
  - "技術"
  - "備忘録"
tags:
  - "Vim"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

[前に書いた記事](/2018/12/%E8%87%AA%E5%88%86%E3%81%AEvim%E3%81%AE%E3%83%97%E3%83%A9%E3%82%B0%E3%82%A4%E3%83%B3%E7%92%B0%E5%A2%83%E8%A8%AD%E5%AE%9A-dein-denite-deoplete%E3%82%92%E5%8B%95%E3%81%8B%E3%81%99%E3%81%BE%E3%81%A7/)に従って、`dein.toml`と`dein_lazy.toml`に置くための書式で書いていく。良いなあと思うものがあれば入れてください。

# dein.toml

## Shougo/dein.vim
前記事参照。必須。
```toml
[[plugins]]
repo = 'Shougo/dein.vim'
```

## Shougo/vimfiler.vim
`dein`がまだツリー表示をサポートしていないので、ツリー表示とはどんなものか知りたくて入れただけ。普段は`dein.nvim`を使っているので使っていない。ひとつ下の`Unite.vim`が必須。
```toml
[[plugins]]
repo = 'Shougo/vimfiler.vim'
```

## Shougo/unite.vim
`vimfiler.vim`に必要なので入れている。`Denite`のほうが速い上十分実用的なのでもう使っていない。
```toml
[[plugins]]
repo = 'Shougo/unite.vim'
```
## cohama/lexima.vim
`(`や`{`を入力したり削除したりしたときに括弧閉じを自動で挿入してくれるプラグイン。超絶便利。
```toml
[[plugins]]
repo = 'cohama/lexima.vim'
hook_post_source = '''
call lexima#add_rule({'char': '$', 'input_after': '$', 'filetype': 'latex'})
call lexima#add_rule({'char': '$', 'at': '\%#\$', 'leave': 1, 'filetype': 'latex'})
call lexima#add_rule({'char': '<BS>', 'at': '\$\%#\$', 'delete': 1, 'filetype': 'latex'})
'''
```

## Shougo/denite.nvim
前記事参照。超絶便利。
```toml
[[plugins]]
repo = 'Shougo/denite.nvim'
hook_add='''
nnoremap <silent> <space>fr :<C-u>Denite file_mru<CR>
nnoremap <silent> <space>fb :<C-u>Denite buffer<CR>
nnoremap <silent> <space>fy :<C-u>Denite neoyank<CR>
nnoremap <silent> <space>ff :<C-u>Denite file_rec<CR>
nnoremap <silent> <space>fu :<C-u>Denite outline<CR>
'''
```

## Shougo/unite-outline,Shougo/neomru.vim,Shougo/neoyank.vim
`unite`とあるものもあるが`denite`で利用可能。拡張プラグイン。
```toml
[[plugins]]
repo = 'Shougo/unite-outline'
```

```toml
[[plugins]]
repo = 'Shougo/neomru.vim'
```

```toml
[[plugins]]
repo = 'Shougo/neoyank.vim'
```

## Yggdroot/indentLine
インデントに縦線を入れてくれる。プログラムが非常に読みやすくなる。
```toml
[[plugins]]
repo = 'Yggdroot/indentLine'
hook_post_source='''
IndentLinesEnable
'''
```

## Shougo/neosnippet-snippets
`neosnippet`で使うためのスニペット集。`neosnippet`に必須ではないが超重要。
```toml
[[plugins]]
repo = 'Shougo/neosnippet-snippets'
```

## thinca/vim-quickrun
```toml
[[plugins]]
repo = 'thinca/vim-quickrun'
```
```toml
[[plugins]]
repo = 'kana/vim-smartinput'

```
```toml
[[plugins]]
repo = 'osyo-manga/shabadou.vim'

```
```toml
[[plugins]]
repo = 'woodyZootopia/flatwhite-vim'

```
```toml
[[plugins]]
repo = 'kana/vim-operator-user'
```
```toml
[[plugins]]
repo = 'rhysd/vim-operator-surround'

```
```toml
[[plugins]]
repo = 'kana/vim-textobj-user'
```
```toml
[[plugins]]
repo = 'kana/vim-textobj-syntax'
```
```toml
[[plugins]]
repo = 'thinca/vim-textobj-between'
```
```toml
[[plugins]]
repo = 'osyo-manga/vim-textobj-multiblock'
```
```toml
[[plugins]]
repo = 'kana/vim-textobj-entire'

```
```toml
[[plugins]]
repo = 'airblade/vim-gitgutter'

```
```toml
[[plugins]]
repo = 'scrooloose/nerdcommenter'
hook_add='''
let g:NERDSpaceDelims=1
let g:NERDDefaultAlign='left'
let g:NERDCustomDelimiters = {'vim': {'left': '"','right':''}}
'''

```
```toml
[[plugins]]
repo = 'tpope/vim-fugitive'

```
```toml
[[plugins]]
repo = 'godlygeek/tabular'
hook_add = '''
xmap <Space>ga :Tabular 
'''

```
```toml
[[plugins]]
repo = 'junegunn/vim-easy-align'
hook_add='''
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap       ga                     <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap       ga                     <Plug>(EasyAlign)
'''

```
```toml
[[plugins]]
repo = 'tyru/open-browser.vim'
hook_add = '''
nmap <space>b <Plug>(openbrowser-smart-search)
vmap <space>b <Plug>(openbrowser-smart-search)
'''

```
```toml
[[plugins]]
repo = 'soramugi/auto-ctags.vim'

```
```toml
[[plugins]]
repo = 'majutsushi/tagbar.git'

```
