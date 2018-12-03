---
title: "git submoduleはなんのために使うのか"
date: 2018-12-03T11:23:50-05:00
description: "git submoduleってなんで便利なのか、例とともに解説します。"
# banner:"/img/some.png"
# lead: "Example lead - highlighted near the title"
# disable_comments: true # Optional, disable Disqus comments if true
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
categories:
  - "技術"
  - "備忘録"
tags:
  - "git"
  - "shell"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---
# そもそも一体何？

git submoduleとは、「**gitディレクトリに親子/参照関係をもたせることができるもの**」である。\
他のgitディレクトリを自分のgitディレクトリの内部に持ってきて、参照関係をもたせることができる。

ネットをざっと調べたところ、コマンドの仕様を解説している記事は多くあったが、**なぜ必要なのか、どう便利なのか**を解説した記事が見受けられなかった。\
なので、使いみちとして自分の遭遇したパターン２つをご紹介したい。\
細かいコマンドの仕様については他の記事にお任せすることとする。

また、「このブログ自体」のソースコードが例として参考になると思う。\
https://github.com/woodyZootopia/blog \
上のリンクを開いてもらうと、publicディレクトリとthemes/hugo-icarus-themeディレクトリのあとに@がついているが、これらがsubmoduleとなっている。

## 1. 他のリポジトリの中身を参照する場合

例えば、あなたが作ろうとしているリポジトリで、すでに存在するリポジトリを利用したくなったとする。 さて、どのように管理するのが良いだろうか。

- 一番安直な方法は、あなたのリポジトリのディレクトリの隣にgit cloneで持ってきてしまうことだろう。
 - だが、これだと他の人に使ってもらいたくなったときに、同じようにディレクトリを配置してもらわねばならず、環境構築が面倒になる為よくない。
 - また、同じように配置したつもりでもその**リポジトリのバージョンが異なっていたためにうまく動作しない**ということも考えられる。
- 次に思いつく方法は、あなたのリポジトリの中にgit cloneするということだ。
 - これをもっと**便利で気の利いた**ふうにしてくれるやり方がgit submoduleなのだと理解できる。

気の利いたふうに、とはどういうことか。

- リポジトリをcloneすると、**そのsubmoduleも再帰的にcloneしてくれる。**\
- そのさい、**バージョン（コミットID）も指定されたものをcloneしてくれる。**バージョンミスが起こらない。\

ということだ。

試しに、上のblogリポジトリをcloneしてみてほしい。2つのsubmoduleディレクトリもcloneされる。\
また、それぞれのディレクトリのあとに付いていた@とは、コミットIDのことである。

また、それぞれのディレクトリの中に入ると、.gitディレクトリも独自のものが使われていることがわかるだろう。\
たとえばgit logなどをやってみても親ディレクトリではなく、参照先のものが出てくるはずだ。

自分のブログでは、icarusというテーマを使っているのだが、そのリポジトリを参照するために

```shell
cd themes
git submodule add git@github.com:digitalcraftsman/hugo-icarus-theme.git
```

とした。

## 2. 公開用リポジトリを内部に作る場合

正直、上の例が大多数を占めると思うのだが、一応紹介しておく。\
自分のリポジトリではpublicディレクトリがいい例だろう。

自分のブログは[Hugo](https://gohugo.io)という静的サイト生成ソフトで作られている。\
また、[github.io](https://pages.github.com)でホスティングされている。なので、自分のgithub usernameのリポジトリ( https://github.com/woodyZootopia/woodyZootopia.github.io )を作り、そこにpushすると自動でブログが公開されるという仕組みになっている。

しかし、Hugoは完成したサイトを自分の直下のpublicディレクトリに投げる。そこで、**publicディレクトリがusernameリポジトリに直結している**ようにしたい。\
**これはまさに、submoduleの出番である。**

具体的な手順としては、

```shell
rm -rf public
git submodule add <address to your repository> public
```

となる。最初にpublicを削除するのは、すでにpublicディレクトリが存在していた場合git submoduleは書き換えてくれないためである。

これで設定は完了したので、あとは
```shell
hugo # サイトを生成してpublicディレクトリに投げる
cd public
git add . # 更新されているのは
          # publicディレクトリ内の子リポジトリ、
          # すなわちホスティングされているサイトの方である
git commit
git push origin master
cd ..
```

みたいな感じのシェルスクリプトでも書いておけば、**これを実行するだけでブログが更新される。**\
これをもう少しいい感じにしたものが、`deploy.sh`である。ご確認いただきたい。\

というわけでこの記事を書き終わった自分は、`./deploy.sh`だけで更新を済ませてしまう。かんたんかんたん♫\
みなさんもgit submoduleを活用して快適なgitライフを。

参考:https://gohugo.io/hosting-and-deployment/hosting-on-github/
