---
title: "【論文読み】Reducing the Model Order of Deep Neural Networks Using Information Theory"
date: 2019-06-07T19:22:17+09:00
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
  - "ポエム"
  - "翻訳記事"
  - "論文"
  - "備忘録"
  - "数学"
tags:
  - "Latex"
  - "shell"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

CNNにおけるFC層の各重みに対して出力結果とのフィッシャー情報量対角成分を計算し、その小さいものを除去することで、精度を保ちつつモデルサイズを削減する研究。

*	フィッシャー情報量の定義は

	$
	\mathbf{F}(\boldsymbol{\theta})=\mathrm{E}_{\mathbf{y}}\left[\left(\frac{\partial \log p(\mathbf{y} | \mathbf{x} ; \boldsymbol{\theta})}{\partial \boldsymbol{\theta}}\right)\left(\frac{\partial \log p(\mathbf{y} | \mathbf{x} ; \boldsymbol{\theta})}{\partial \boldsymbol{\theta}}\right)^{T}\right]
	$

	すなわち、対角成分の定義は

	$
	\mathbf{F}\_{D}(\boldsymbol{\theta})=\mathrm{E}\_{\mathbf{y}}[\mathbf{g} \odot \mathbf{g}]
	$

*	フィッシャー情報量のイメージを掴むには[このサイト](https://kriver-1.hatenablog.com/entry/2018/05/02/175855#431-%E3%83%95%E3%82%A3%E3%83%83%E3%82%B7%E3%83%A3%E3%83%BC%E6%83%85%E5%A0%B1%E9%87%8F)がわかりやすい。

まず重みの小さいものを除去し、次にフィッシャー情報量に基づいて消す。更に残りの重みのフィッシャー情報行列対角成分をクラスタリング（ランキング）し、意味のなさそうなものを低ビットで表現する。
これには以下のような理由があり、

*	フィッシャー情報量の値小さいほどその重みが出力結果に寄与していないと考えられるので
*	重みの小さいもののフィッシャー情報量を正確に推定するのは難しいので

*	Adamの計算のときに自動的に出てくる
*	スケールが可能

枝刈りと量子化の２方法でaccを評価した
