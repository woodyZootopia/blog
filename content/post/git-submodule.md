---
title: "git submoduleってなんのために使うの？"
date: 2018-12-03T11:23:50-05:00
description: "git submoduleってなんで便利なのか、例とともに解説します。"
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
  - "git"
  - "shell"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---
git submoduleって

# そもそも一体何？

git submoduleとは、「**gitディレクトリに親子/参照関係をもたせることができるもの**」である。\
他のgitディレクトリを自分のgitディレクトリの内部に持ってきて、参照関係をもたせることができる。

ネットをざっと調べたところ、コマンドの仕様を解説している記事は多くあったが、**なぜ必要なのか、どう便利なのか**を解説した記事が見受けられなかった。\
（[公式ドキュメント](https://git-scm.com/book/en/v2/Git-Tools-Submodules)にはきちんと書いてあるが、公式ドキュメントを読み通せる人はこの記事を開いていないと思う）\
なので、使いみちとして自分の遭遇したパターン２つをご紹介したい。\
細かいコマンドの仕様については他の記事にお任せすることとする。

また、「このブログ自体」のソースコードが例として参考になると思う。\
https://github.com/woodyZootopia/blog \
上のリンクを開いてもらうと、`public`ディレクトリと`themes/hugo-icarus-theme`ディレクトリのあとに@がついているが、これらがsubmoduleとなっている。

## 他のリポジトリの中身を参照する場合

例えば、あなたが作ろうとしているリポジトリで、すでに存在するリポジトリを利用したくなったとする。 さて、どのように管理するのが良いだろうか。

- 一番安直な方法は、あなたのリポジトリのディレクトリの隣にgit cloneで持ってきてしまうことだろう。
 - だが、これだと他の人に使ってもらいたくなったときに、同じようにディレクトリを配置してもらわねばならず、環境構築が面倒になる為よくない。
 - また、同じように配置したつもりでもその**リポジトリのバージョンが異なっていたためにうまく動作しない**ということも考えられる。
- 次に思いつく方法は、あなたのリポジトリの中にgit cloneするということだ。
 - これをもっと**便利で気の利いた**ふうにしてくれるやり方がgit submoduleなのだと理解できる。

気の利いたふうに、とはどういうことか。

- リポジトリをcloneすると、**そのsubmoduleも再帰的にcloneしてくれる。**\
- そのさい、**バージョン（コミットID）も指定されたものをcloneしてくれる。**バージョンミスの防止。\
- バージョン指定を簡単に変更できる。

ということだ。

試しに、上のblogリポジトリをcloneしてみてほしい。2つのsubmoduleディレクトリもcloneされる。それぞれのディレクトリのあとに付いていた@とは、コミットIDのことである。

また、それぞれのディレクトリの中に入ると、.gitディレクトリも独自のものが使われていることがわかるだろう。\
たとえばgit logなどをやってみても親ディレクトリではなく、参照先のものが出てくるはずだ。

自分のブログでは、icarusというテーマを使っているのだが、そのリポジトリを参照するために

```submodule.sh
cd themes # submoduleを加えたい場所へ移動
git submodule add git@github.com:digitalcraftsman/hugo-icarus-theme.git
```

とした。

バージョン指定の変更・アップデートについてはここでは割愛する。

### 2018-12-20追記
このテーマは2年間以上更新されておらず、自分の求める機能で実装されていないものがたくさんあった。\\
そのため、現在はこのリポジトリをフォークし、独自の実装をしているため、[そちら](https://github.com/woodyZootopia/hugo-icarus-theme)を参照するようになっている。

## 公開用リポジトリを内部に作る場合

~~正直、上の例が大多数を占めると思うのだが、一応紹介しておく。~~\
自分のリポジトリではpublicディレクトリがいい例だろう。

自分のブログは[Hugo](https://gohugo.io)という静的サイト生成ソフトで作られている。\
また、[github.io](https://pages.github.com)でホスティングされている。これは、自分のgithub usernameのリポジトリ( https://github.com/woodyZootopia/woodyZootopia.github.io )を作り、そこにpushすると自動でブログが公開されるという仕組みになっている。

しかし、Hugoは完成したサイトを自分の直下のpublicディレクトリに投げる。\
そこで、publicディレクトリが**実はusernameリポジトリである**ようにしたい。**これはまさに、submoduleの出番である。**

具体的な手順としては、

```bash
rm -rf public
git submodule add <address to your repository> public
```

となる。最初に`public`を削除するのは、すでに`public`ディレクトリが存在していた場合、git submoduleはこれを書き換えてくれないためである。

これで設定は完了したので、あとは
```bash
hugo # サイトを生成してpublicディレクトリに投げる
cd public
git add . # 更新されているのは
          # publicディレクトリ内の子リポジトリ、
          # すなわちホスティングされているサイトの方である
git commit
git push origin master
cd ..
```

みたいな感じのシェルスクリプトでも書いておけば、これを実行するだけでブログが更新される。\
これをもう少しいい感じにしたものが、`deploy.sh`である。ご確認いただきたい。\

というわけでこの記事を書き終わった自分は、`./deploy.sh`だけで更新を済ませてしまう。かんたんかんたん♫\

みなさんもgit submoduleを活用して快適なgitライフを。この記事がその一助となれば幸いです。

参考：\
https://gohugo.io/hosting-and-deployment/hosting-on-github/ \
https://git-scm.com/book/en/v2/Git-Tools-Submodules
