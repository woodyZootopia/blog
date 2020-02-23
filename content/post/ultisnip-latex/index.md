---
title: "Ultisnip Latex"
date: 2020-02-23T20:50:36+09:00
# description: "Example article description"
# banner:"/img/some.png"
# lead: "Example lead - highlighted near the title"
# disable_comments: true # Optional, disable Disqus comments if true
disable_profile: true # no one wants to see my profile while reading articles
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
# draft: true
categories:
  - "技術"
  - "ポエム"
  - "翻訳記事"
  - "論文"
  - "備忘録"
  - "数学"
  - "shell"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---


突然ですが，例えば次のような数式を入力したいとします．

$$
a_3=\frac{1}{\pi } \int_{0}^{2\pi } f(x) \cos 3x \mathrm{d} x
$$

すると，次のような文章を入力する必要がありますね．

```example.ltx
\begin{equation}
a_3 = \frac{1}{\pi} \int_{0}^{2\pi} f(x) \cos 3x \mathrm{d} x
\end{equation}
```

このとき，入力文字（ストローク）数はなんと**91文字**にもなります．今回の記事では，これを34文字にまで短縮する方法を紹介します．約**3倍**の高速化です．実際には，ホームポジションから遠い特殊文字（`\`,`{`,`}`など）を入力する必要がほとんどなくなるので更に速くできます．

これを可能にする秘訣はスニペットにあります．スニペットとは，特定のテキストの入力により発動する別のテキストへの置き換えです．例えば，Vim機能である`map`も立派なスニペットと言えるでしょう．
しかし，これは機能が貧弱なので，より高度なプラグインを入れます．

# Ultisnipの導入

[Ultisnip](https://github.com/SirVer/ultisnips)はVimのプラグインです．まずはこれをVimにインストールします．なお，このプラグインは今の所NeoVimとの相性が悪いようで，まともに動かないのでVimを使いましょう．

## snippetsの基礎文法

続いて，Ultisnipの設定を書いていきます．.texファイルを開いているときに発動するスニペットは，`~/.vim/UltiSnips/tex.snippets`に書けば良いようです．
例えば，以下のように書いたうえでVimを再起動してみましょう．

```tex.snippets
snippet enum "Enumerate" bA
\begin{enumerate}
	\item $0
\end{enumerate}
endsnippet
```

このスニペットは`enum`と入力されると発動し，2行目以降である

```snippet.ltx
\begin{enumerate}
	\item $0
\end{enumerate}
```
に置き換わります．

1行目の`"Enumerate"`はスニペットの名前（補完とかで用いられます）なのであまり気にしなくてもいいですが，その後ろにある`bA`はとても重要です．
このオプションをつけておくことで，「行頭であるときのみ」「自動で」スニペットが発動するようになります．これ以外の設定について知りたいときは`:h UltiSnips-snippet-options`してください．

また，スニペットの発動後に`$0`にカーソルが飛びます．`$1`,`$2`...を設定しておくと，`$0`に飛ぶ前にそこに飛びます．

# 設定の例

いかにいくつか例を示すので，パターンを掴んでみてください．

以下の設定で，`m,`と入力すると，`$$`が出てきます．

```tex.snippets
snippet m, "math" iA
\$$1\$$0
endsnippet
```

数式につかうスニペットも以下のようにして定義できます．

```tex.snippets
snippet -> "to" iA
\to 
endsnippet
```

```tex.snippets
snippet mscr "mathscr" iA
\mathscr{$1}$0
endsnippet
```

# 数式環境内か否かの判定
`tex.snippets`の先頭に以下を貼り付けてください．

```tex.snippets
global !p
texMathZones = ['texMathZone'+x for x in ['A', 'AS', 'B', 'BS', 'C',
'CS', 'D', 'DS', 'E', 'ES', 'F', 'FS', 'G', 'GS', 'H', 'HS', 'I', 'IS',
'J', 'JS', 'K', 'KS', 'L', 'LS', 'M', 'MS','N', 'NS', 'O', 'OS' 'V', 'W', 'X', 'Y', 'Z']]

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

これをやった上で，スニペットの前に`context "math()"`を書き込むと，そのスニペットは数式環境内でのみ発動するようになります．

## 数式環境の種類の拡張
`context "math()"`は，Vimのシンタックスハイライト機能を応用しています．Vimでは最初から基本的なlatexの数式環境が登録されていますが，いくらか登録されていないものがあります．  
とくに使用頻度の高い`align`が登録されていないのは（数式がハイライトされないという点でも，上の判定法が通用しないという点でも）困るので手動で追加しましょう．

`~/.vim/after/syntax/tex.vim`に追加したい数式環境を書き込めばよいです．

```tex.vim
call TexNewMathZone("M","align",1)
call TexNewMathZone("N","multline",1)
call TexNewMathZone("O","gather",1)
```
Mからスタートしてアルファベットがかぶらないように追加します．

# 難しいスニペット

スニペット内でpythonコードを書くことができます．

```tex.snippets
context "math()"
snippet "([^\\])bet" "beta" irA
`!p snip.rv = match.group(1)`\beta 
endsnippet
```

このようにすると，`bet`と入力することで`\beta`に変わります．

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

理解するのは難しいですが，

```tex.snippets
```

```tex.snippets
```

```tex.snippets
```
