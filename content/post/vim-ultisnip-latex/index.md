---
title: "Vim+スニペットの力でLaTeXもサクサク入力"
date: 2020-02-23T20:50:36+09:00
# description: "Example article description"
# banner:"/img/some.png"
# lead: "Example lead - highlighted near the title"
# disable_comments: true # Optional, disable Disqus comments if true
disable_profile: true # no one wants to see my profile while reading articles
# authorbox: true # Optional, enable authorbox for specific post
mathjax: true # Optional, enable MathJax for specific post
# draft: true
categories:
  - "技術"
  - "翻訳記事"
  - "備忘録"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

> この記事は、Gilles Castelさんによる[記事](https://castel.dev/post/lecture-notes-1/)に（許可を頂いた上で）大きく依っています。
> この人はLaTeXでノートを授業中にとってしまうすごい人で、正直このポストも ~~二番煎じ~~ 余り需要がない気がするのですが、
> 日本語でのUltisnipの情報が全くなく、周りにもこの情報を知っている人は少なかったので筆を執ることにした次第です。  
> そういう経緯が有りますので、英語が読める人は上の記事もぜひご覧ください。この記事には含まれていない情報もいくつか書かれています。
> Gillesさん、ありがとうございます！

LaTeXで大量の数式を入力するのが大変で困ることはありませんか？僕にはあります。

例えば次のような数式を入力したいとします。

$$
a\_3=\frac{1}{\pi } \int\_{0}^{2\pi } f(x) \cos 3x \mathrm{d} x
$$

すると、次のような文章を入力する必要がありますね。

```example.ltx
\begin{equation}
a_3 = \frac{1}{\pi} \int_{0}^{2\pi} f(x) \cos 3x \mathrm{d} x
\end{equation}
```

このとき、入力文字（ストローク）数はなんと**91文字**にもなります。
今回の記事のスニペット設定をフルに活用すると、これを34文字にまで短縮することができます。
約**3倍**の高速化です。実際には、ホームポジションから遠い特殊文字（`\`,`{`,`}`など）を入力する必要がほとんどなくなるのでもっと入力は楽です。

**スニペット**とは、特定のテキストの入力により発動する別のテキストへの置き換えです。例えば、Vimの標準機能である`map`も立派なスニペットと言えるでしょう。

```.vimrc
" `abr`という文字列を`abbreviation`にマップする設定
inoremap abr abbreviation
```

しかし、これは機能が貧弱なので、より高度なプラグインを入れます。  
具体的には、特定の条件、たとえば「カーソルが数式モードに入ったときにだけ」「カーソルが行頭にあるときにだけ」などにのみスニペットが発動するようにしたり、マッチに正規表現を使ったりしたいです。

# Ultisnipの導入

[Ultisnip](https://github.com/SirVer/ultisnips)はVimのプラグインです。まずはこれをVimにインストールします。なお、このプラグインは今の所[NeoVimとの相性が悪い](https://github.com/neovim/neovim/issues/5702)ようで、まともに動かないのでVimを使いましょう。

[2020-05-06 追記] どのタイミングで改善されたのかはわかりませんが、最新版のNeoVim(0.5.0-479-ge5022c61e)の場合、特に問題はなくなっています。NeoVimだけで完結するので嬉しいですね！

```.vimrc
Plug 'SirVer/ultisnips'
let g:UltiSnipsExpandTrigger="<Tab>"
let g:UltiSnipsJumpForwardTrigger="<Tab>"
```

## snippetsの基礎文法

続いて、Ultisnipの設定を書いていきます。.texファイルを開いているときに発動するスニペットは、`~/.vim/UltiSnips/tex.snippets`に書けば良いです。
例えば、以下のように書いたうえでVimを再起動してみましょう。

```tex.snippets
snippet enum "Enumerate" bA
\begin{enumerate}
	\item $0
\end{enumerate}
endsnippet
```

このスニペットは`enum`と入力されると発動し、2行目以降である

```snippet.ltx
\begin{enumerate}
	\item $0
\end{enumerate}
```
に置き換わります。

文法の解説をしましょう。一行目と最後の行の`snippet`と`endsnippet`で囲うことでスニペットを定義します。その後にある`enum`のところが入力することで発動するテキストです。

そのあとにある`"Enumerate"`はスニペットの名前（補完とかで用いられます）なのであまり気にしなくてもいいですが、その後ろについているオプション（今回は`bA`）に注目してください。
このオプションにより、「行頭であるときのみ」「`<Tab>`を押さなくても自動で」スニペットが発動するようになります（それぞれ、`beginning`と`Automatic`の意味だと思われます）。  
これ以外のオプションについて知りたいときは`:h UltiSnips-snippet-options`してください。

また、スニペットの発動後に`$0`にカーソルが飛びます。`$1`,`$2`...を設定しておくと、`$0`に飛ぶ前にそこに飛びます。

# 設定の例

いかにいくつか例を示すので、パターンを掴んでみてください。

```tex.snippets
snippet -> "to" iA
\to 
endsnippet
```
`->`を書くと`\to`に展開されます。

```tex.snippets
snippet mscr "mathscr" iA
\mathscr{$1}$0
endsnippet
```
`mscr`とかくと`\mathscr{}`（花文字命令）に展開されます。

以下の設定はどうなるのでしょうか。

```tex.snippets
snippet m, "math" iA
\$$1\$$0
endsnippet
```
`m,`と入力すると、`$$`が出てきます。スニペット内で`$`を使いたい場合、`$1`などの記号と区別がつかないので、`\$`とするわけですね。
カーソルがその間に飛ぶので、そのまま数式入力を開始できます。数式入力が終わったなら`<Tab>`を押せばそこから出られます。

# 数式環境内か否かの判定

この方法を使うと数式も簡単に書くことができそうです。例えば、`\theta`と入力する代わりに`the`と入力するような設定を考えることができます。すべてのギリシャ文字についてこれを行えば、かなり入力が楽になりそうです。

しかし、こうすると、英語の文章を書いているときにtheが全て
$ \theta $
に展開されてしまいます。これを防ぐために、数式モード中でのみこのスニペットが発動するようにしたいです。数式モード中で定冠詞theを入力することはないでしょうからね。

`tex.snippets`の先頭に以下を貼り付けてください。

```tex.snippets
global !p
texMathZones = ['texMathZone'+x for x in ['A', 'AS', 'B', 'BS', 'C',
'CS', 'D', 'DS', 'E', 'ES', 'F', 'FS', 'G', 'GS', 'H', 'HS', 'I', 'IS',
'J', 'JS', 'K', 'KS', 'L', 'LS', 'V', 'W', 'X', 'Y', 'Z']]

texIgnoreMathZones = ['texMathText']

texMathZoneIds = vim.eval('map('+str(texMathZones)+", 'hlID(v:val)')")
texIgnoreMathZoneIds = vim.eval('map('+str(texIgnoreMathZones)+", 'hlID(v:val)')")

ignore = texIgnoreMathZoneIds[0]

def math():
	synstackids = vim.eval("synstack(line('.'), col('.') - (col('.')>=2 ? 1 : 0))")
	try:
		first = next(
            i for i in reversed(synstackids)
            if i in texIgnoreMathZoneIds or i in texMathZoneIds
        )
		return first != ignore
	except StopIteration:
		return False
endglobal
```

これをやった上で、スニペットの前に`context "math()"`を書き込むと、そのスニペットは数式環境内でのみ発動するようになります。

これは一体どのようにして動いているのでしょうか。
この`context "math()"`は、Vimのシンタックスハイライト機能を応用しています。Vimは、latexの数式環境に色を付ける（ハイライト）ために、文法（シンタックス）解析を行っています。そのため、Vimはカーソルが数式環境の中にいるかを判定することができるので、その結果が`True`ならスニペットを発動するように設定しているわけです。

## 数式環境の種類の拡張
Vimのシンタックスハイライトには基本的なlatexの数式環境が登録されていますが、いくらか登録されていないものがあります。  
とくに使用頻度の高い`align`が登録されていないのは（数式がハイライトされないという点でも、上の判定法が通用しないという点でも）困るので手動で追加しましょう。

`~/.vim/after/syntax/tex.vim`に追加したい数式環境を書き込めばよいです。

```tex.vim
call TexNewMathZone("M","align",1)
call TexNewMathZone("N","multline",1)
call TexNewMathZone("O","gather",1)
```
Mからスタートしてアルファベットがかぶらないように追加します。  
また、追加したもの（と、それに`S`を足したもの。今回なら`'M','MS','N', 'NS', 'O', 'OS'`）も`texMathZones`に含まれるように上の`tex.snippets`の最初を変更してください。

```tex.snippets
texMathZones = ['texMathZone'+x for x in ['A', 'AS', 'B', 'BS', 'C',
'CS', 'D', 'DS', 'E', 'ES', 'F', 'FS', 'G', 'GS', 'H', 'HS', 'I', 'IS',
'J', 'JS', 'K', 'KS', 'L', 'LS', 'M', 'MS','N', 'NS', 'O', 'OS', 'V', 'W', 'X', 'Y', 'Z']]
```

# 難しいスニペット

## スニペット内でpythonコード

$a_3$とするために`a_3`と入力しますが、`_`はホームポジションからの場所が遠いのでできれば避けたいです。

`sb`と入力することで`_{}`に変換するようにするのも有りです（実際に僕はその設定も行っています）が、`a3`のように「アルファベットの直後に数字」が入力されたら変換するようにしてしまえば結構楽になるのではないでしょうか。  
この設定は以下のようにかけます：

```tex.snippets
priority 10
context "math()"
snippet '([A-Za-z])(\d)' "auto subscript" wrA
`!p snip.rv = match.group(1)`_`!p snip.rv = match.group(2)`
endsnippet
```

オプションの`r`はスニペットに正規表現が含まれているという意味です。
更に、ここでは展開先の中にpythonコードを含んでいます。
pythonコードが終了したときに`snip.rv`に入っていたものがここに展開されます。`match.group(n)`はn個めの正規表現にマッチした内容となります。

### 応用

次のコードをコピペしてみましょう。

```tex.snippets
context "math()"
snippet // "Fraction" iA
\\frac{$1}{$2}$0
endsnippet

context "math()"
snippet '((\d+)|(\d*)(\\)?([A-Za-z]+)((\^|_)(\{\d+\}|\d))*)/' "Fraction" wrA
\\frac{`!p snip.rv = match.group(1)`}{$1}$0
endsnippet

context "math()"
priority 1000
snippet '^.*\)/' "() Fraction" wrA
`!p
stripped = match.string[:-1]
depth = 0
i = len(stripped) - 1
while True:
	if stripped[i] == ')': depth += 1
	if stripped[i] == '(': depth -= 1
	if depth == 0: break;
	i -= 1
snip.rv = stripped[0:i] + "\\frac{" + stripped[i+1:-1] + "}"
`{$1}$0
endsnippet
```

理解するのはちょっと難しいですが、これをすることで

![](https://castel.dev/3f83f1bdc3078aa16382e80a276f199f/frac.gif)のような挙動をさせることが可能です。

# その他の例

## 数式の形を入力するとスニペットが展開される

```tex.snippets
priority 100
context "math()"
snippet -> "to" iA
\to 
endsnippet

priority 200
context "math()"
snippet <-> "leftrightarrow" iA
\leftrightarrow
endsnippet

snippet >> ">>" iA
\gg 
endsnippet
```

## 関数名の自動展開
下のように、よく使う関数をすべて登録しておくことができます。
```tex.snippets
context "math()"
snippet "([^\\])max" "max" irA
`!p snip.rv = match.group(1)`\max 
endsnippet
```

これらの例を含め、僕の使っているスニペット一覧を[GitHubにあげている](https://github.com/woodyZootopia/nvim/blob/master/UltiSnips/tex.snippets)ので参考にしてください。

それでは、Happy LaTeX life!
