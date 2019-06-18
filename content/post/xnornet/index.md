---
title: "Xnornet"
date: 2019-06-18T12:50:56+09:00
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
tags:
  - "Latex"
  - "shell"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---


【論文読み】XNOR-Net: ImageNet Classification Using Binary Convolutional Neural Networks
https://arxiv.org/pdf/1511.00363
![image](https://gyazo.com/35a93e694e7c28a57d1cc3c9d91095b4)

今回読んだ論文では **係数(scaling factor)** を計算することにより、本来のニューラルネットワークに層の出力結果をより近づけ、性能を向上させることを提案しています。
*	新規性
	*	入力がbinarizeされたBWN(Binary Weight Network)、及び、入力、重みの両方がbinarizeされたXNOR-Netを提案
		*   これらでは**係数scaling factor**を計算する
		*	計算が早い
		*	性能も良い
	*	ブロックの順番を入れ替えることにより性能が向上

1. 重みがBinarizeされたネット(BWN)
*	画像$\mathbf{I}$が入力された時、フィルタ$\mathbf{W}$をバイナリフィルタ$\mathbf{B}$, 係数(scaling factor) $\alpha$で近似します。すなわち
*	$\mathbf{I} * \mathbf{W} \approx(\mathbf{I} \oplus \mathbf{B}) \alpha$
*	この時、目的関数は
*	$J(\mathbf{B}, \alpha)=\|\mathbf{W}-\alpha \mathbf{B}\|^{2}$
*	$\alpha^{*}, \mathbf{B}^{*}=\underset{\alpha, \mathbf{B}}{\operatorname{argmin}} J(\mathbf{B}, \alpha)$
*	であり、これを偏微分をつかって解くと
*	$B^*_i=\left\{\begin{array}{ll}{+1} & {\mathrm {if}\  W_i \geq 0} \\ {-1} & {\text { otherwise }}\end{array}\right.$
*	$\alpha^{*}=\frac{\mathbf{W}^{\top} \mathbf{B}^{*}}{n} =\frac{\mathbf{W}^{\top} \operatorname{sign}(\mathbf{W})}{n}=\frac{\sum\left|\mathbf{W}_{i}\right|}{n}=\frac{1}{n}\|\mathbf{W}\|_{\ell 1}$
*	これによって近似されたWを$\widetilde{W}$と呼ぶ
	*	順伝播は$\mathbf{I} \oplus \widetilde{W}$とすれば良く、逆伝播は
	*	$\frac{\partial C}{\partial W_{i}}=\frac{\partial C}{\widetilde{W}_{i}}\left(\frac{1}{n}+\frac{\partial \operatorname{sign}}{\partial W_{i}} \alpha\right)$
	*	$\frac{\partial \operatorname{sign(r)}}{\partial r}=r 1_{|r| \leq 1}$
	*	を使う

これを発展させ、次を考える
[https://gyazo.com/7d376d745c6f5db926cb583b7e4a07c4]
2. 重みも入力もBinarizeされたXNORNet
*	XNORは「入力2つが同じ時だけ1、違うと0（今回は-1）」というイメージ
*	入力X、フィルタWが与えられた時、
*	$\mathbf{X}^{\top} \mathbf{W} \approx \beta \mathbf{H}^{\top} \alpha \mathbf{B}$
*	で近似
*	$\alpha^{*}, \mathbf{B}^{*}, \beta^{*}, \mathbf{H} *=\underset{\alpha, \mathbf{B}, \beta, \mathbf{H}}{\operatorname{argmin}}\|\mathbf{X} \odot \mathbf{W}-\beta \alpha \mathbf{H} \odot \mathbf{B}\|$
*	普通に考えるとFig2(1,2)のように
	*	重みをBinarize
	*	それに対して最適なαを求める
	*	入力をbinarize
	*	最適なbをそれぞれについて求める
*	という作業が入るが、(2)ではなく(3)のようにすると$\beta$を効率的に求めることができ計算量を減らせる
	*	Convolution windowごとに$\beta$を求めなければならないが、先にチャンネル平均をメモしておくことで速くする
*	数式で書くと次のようになる	 	   
*	$\mathbf{A}=\frac{\sum\left|\mathbf{I}_{:, :, i}\right|}{c}$（チャンネル平均を取る）
*	$\mathbf{K}=\mathbf{A} * \mathbf{k}, \mathrm { where\ } \forall i j \quad \mathbf{k}_{i j}=\frac{1}{w \times h}$
*	$\mathbf{K}$はβの行列になっている
*	$\mathbf{I} * \mathbf{W} \approx(\operatorname{sign}(\mathbf{I}) \otimes \operatorname{sign}(\mathbf{W})) \odot \mathbf{K} \alpha$

[https://gyazo.com/fda637db3ea59a324320057aac48af8a]

実践
*	スピードアップ：
*	CPUはきちんと実å装すれば1クロックで64bitの計算ができるので
$S=\frac{c N_{\mathbf{W}} N_{\mathbf{I}}}{\frac{1}{64} c N_{\mathbf{W}} N_{\mathbf{I}}+N_{\mathbf{I}}}=\frac{64 c N_{\mathbf{W}}}{c N_{\mathbf{W}}+64}$

*	性能比較：
[https://gyazo.com/43977b841de624e687800efbbd38caed]
[https://gyazo.com/2a1ccbd5e435ab73963e88efe5b2787f]

*	ブロック構造を入れ替えると性能が向上するよという図（普通のConvNetの構造はBinalizedには適していないらしい）
[https://gyazo.com/e53900c25241c96ea4bc919687947e2b]

*	k-bit Quantizationもこの仕組を拡張することで可能と示唆されている

