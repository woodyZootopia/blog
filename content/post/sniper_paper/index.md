---
title: "【論文読み】SNIPER"
date: 2019-09-14T09:59:07+09:00
# description: "Example article description"
# banner:"/img/some.png"
# lead: "Example lead - highlighted near the title"
# disable_comments: true # Optional, disable Disqus comments if true
disable_profile: true # no one wants to see my profile while reading articles
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
categories:
  - "技術"
  - "翻訳記事"
  - "論文"
  - "数学"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

**[WIP]**

**訓練手法**を提案した論文。  
multi-scale訓練時に画像の一部をいい感じにサンプリングして、解像度を下げておくことによって、単GPUでも20images/batchで訓練できるようになり、batch normalizationの恩恵を受けられるようにした

# 概要

![異なるサイズの箱（chip、太い箱）を画像から切り取り、それに入っているground truth（緑の箱）で訓練を行う。ただし、chipに比してあまりに小さい・大きいもの（赤の箱）を除く](Screenshot from 2019-09-14 11-18-54.png)

難しい物体検出タスクは、高い解像度で画像全体に対して訓練するのが良いとされていた。しかし、これを処理するのは計算量が大きく、特に常人のGPUではバッチ数を増やすのがほぼ不可能だった。

そこで、画像の一部を切り取り、512x512にリサイズして、それを食わせて訓練するようにした。このリサイズされた箱を**chip**と呼ぶ。

# 仕組み

## positive chip生成

* いくつかのスケール$s\_1, \ldots ,s\_n$に対して、画像を$(W_i, H_i)$にリサイズし、$K\times K$ pixelのchipを$d=32$ pixelずらしながら、chipの候補を作る。
* それぞれのスケールに対して、どのGTが含まれるかを決める
	* GTの面積が$\mathcal{R}^i =\left[ r\_{min}^i, r\_{max}^i \right]$に入っていれば、GTはスケールに対してvalidとよばれる。そのようなGTを$\mathcal{G}^i$とする
	* $\mathcal{G}^i$がすべてカバーされるように貪欲法でchipを選ぶ
		* 「カバーされている」とは完全に箱が含まれているということ
	* 選ばれたchipの集合を$\mathcal{C^i\_{pos}}$と呼ぶ。
	* chip内に（意図せず）一部が含まれてしまったGTはcropされていると呼ぶ。これも正解データとして含めるが、カバーされている判定にはならない

こうすることで、すべてのGTが適切なスケールのチップに必ず含まれているようにできる。チップのサイズは画像自体より非常に小さい（一番小さいもので10x以上）ので、ほとんどの背景を高解像度状態では処理せずに済む

![すべてのGTを4つの箱で効率的に処理している。とくに、高解像度で処理しているのはたった2つである](Screenshot from 2019-09-14 11-18-54.png)

### 補足
* 同じGTが複数のchipに含まれることがある
* $\mathcal{R}^i, \mathcal{R}^{i+1}$にはカブっている部分があるので、おなじGTが$\mathcal{G}^i, \mathcal{G}^{i+1}$両方に含まれることがある

## negative chip生成

* これだけだと、背景が使われないので、False Positiveに非常に弱くなってしまう
* アトランダムに選ぶのでは、easy sampleばかりになってしまう

なので、次のようにする。

* RPNを数epochs適当に訓練する。この時negative chipは使わない。
* 当然、false positiveに弱くなる=FPをたくさん検出してしまう。**だがそれでいい**
* このRPNを全訓練データに適用、Proposalのリストを得る
* このうち$\mathcal{C^i\_{pos}}$にカバーされているものは本物の可能性が高いので除く。そうでないものはFPの可能性が高い
* $\mathcal{R}^i$ののなかで$M$個のproposalを含むようなchipをあつめ、$C^i\_{neg}$とする。これを保存（プール）しておく
* 実際の訓練では$\cup ^n \_{i=1} C^i\_{neg}$のプールから何個か取り出す

![赤い点はRPNの提案のうちpositive chipsの中になかったもの。これからnegative chip（オレンジの箱）を生成](Screenshot from 2019-09-14 11-19-02.png)

## 訓練時のラベリング

訓練時は、chipに含まれている *すべての* GTで訓練する。すなわち、GTがchipの$\mathcal{R}$に入っていなくても訓練に使う。

* 例えば、小さいchipに巨大な物体の一部がクロップされて入っていたら、それに対する検出結果も使いたいので

## メリット

訓練時には、データセット全体からランダムにchipをサンプルする。scaleは$(512/ms, 1.667, 3)$（ただし、$ms=\max(width, height)$）

* 画像の短辺が512より小さい場合は、ゼロパディングする

平均して512x512のchipsを5個程度生成。

計算量は多そうに見えるが、上述のように画像の一部を、それも縮小した状態で訓練するので、pixel数ベースでの計算量は単純に全体を処理するときに比べ30%増加ですむ（COCOの場合。COCOは画像サイズが800x1333）。  
実際には、画像サイズが同じになっているので、データがより良い感じに処理でき、30%の増加は簡単にひっくり返る。

まとめると、**multi-scaleな訓練、大きなバッチサイズ、batch normalizationの恩恵を計算が遅くなることなしに8GPUで受けられるようになった**。

これまで、高解像度のまま処理することが物体検出のタスクには必要と考えられてきた

* そのために必要だったマルチGPU法も、遅かったりといろいろ問題があった

しかし、提案手法がうまく行ったことから、**negative sampleと巨大サンプルが適切に含まれていれば**、COCOのような難しいデータセットに対しても訓練可能ということが示された。ある程度の視野より広い範囲のコンテキスト情報は不要か。

# 実験の詳細

## COCO

* $\mathcal{R} = (0, 80^2), (32^2, 150^2), (120^2, \inf)$
* 6 epochs訓練, 1 epoch = 11000 iterations
* FP用RPNは2 epochs訓練、1 epoch = 7000 iterations
* よって、RPNの訓練は全訓練時間の20%以下
* 他にも、mixed precision trainingなど細かくいろいろ書かれていた

![なんと、Recallはnegative chip samplingにまったく影響されていない](table1.png)

* RecallはFPとは関係がないためと思われる

![](table2.png)

* APは関係があるのでもちろん効果がある


![](table3.png)
