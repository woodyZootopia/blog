---
title: "【論文読み】Searching for MobilenetV3"
date: 2019-09-06T19:56:07+09:00
# description: "Example article description"
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

# 論文の要旨

"Searching for MobileNetV3"のタイトル通り、かっこいい新手法の提案というよりは、 **機械的な探索などを地道に貪欲に取り入れ、MobileNetV2の性能を向上させる方法を探した** というのが主な内容。  

（GPUではなく）モバイルデバイスのCPU上で速く走らせるために、細かく層の形とかを調整して **少しでもMulAddの数を減らそう** と試みている。  
この結果として、 **MobileNetV3-Small, MobileNetV3-Large** という２つのモデルを提案している。

４つに分けて改良ポイントを述べていく。 **自動アーキテクチャ探索、効率的なネットワークデザイン、効率的な非線形関数、効率的なセグメンテーションデコーダ** だ。

（なお、多くの人は[まとめ](#まとめ-感想)だけ読めば事足りるかもしれない）

# 自動アーキテクチャ探索

MobileNetV3に使われた自動アーキテクチャ探索（いわゆるNAS, Neural Architecture Search)は主に２つのステップからなる。  

まず、[MnasNet論文](https://arxiv.org/abs/1807.11626)で提案された **platform-aware NAS** を使っておおまかにCNNの形を決定する。  
つぎに、 **NetAdapt** を使って細かく性能を向上させていく。以上。

……だとわからないので、platform-aware NASとNetAdaptをそれぞれ解説していく。

## platform-aware NAS


アイデアは単純で、目的関数を定め、それを報酬として受け取る強化学習アルゴリズムを回す。  
具体的にはRNNを使って予測し、Proximal Policy OptimizationというアルゴリズムでRNNのパラメータを更新していくらしい（知らない）

![Controllerがキモ。RNNが予測し、パラメータの探索に強化学習をつかう](Screenshot from 2019-09-06 23-53-24.png)

流れとしては  
1. Controllerの提案してきたモデルを実際に訓練し、accuracyを測る。また、実際に走らせて実行時間を測定する  
2. それらから報酬を決定する  
3. その報酬を使ってControllerのパラメータを更新する  
4. 更新されたパラメータに沿って、Controllerが次のモデルを提案してくる
となる。

* なお、強化学習を使ったのは便利で報酬がカスタマイズしやすかったため。他のアルゴリズム、たとえば遺伝的アルゴリズムを使っても良いかも by 論文
* 遅延時間計測には **実際にGoogle Pixelをつかう** 。だから **platform-aware** 

### 目的関数

モデル$m$が与えられた時、$ACC(m)$を最大化しつつ、実行（遅延）時間$LAT(m)$は小さくしたい。目標実行時間が$T$のとき、簡単に思いつくのは

$$
\underset{m}{\mathrm{maximize}}\ ACC(m)
$$
$$
\mathrm{subject\ to}\ LAT(m)\leq T
$$

だが、これだと一度の探索で一つの$T$に対するモデルしかできない。NASはコストがかかるので、一度の探索で複数のモデルを見つけたい。なのでこうする：

$$
\begin{eqnarray}
\underset{m}{\mathrm{maximize}}\   &R(m)\\\\\\
=\underset{m}{\mathrm{maximize}}\  &ACC(m)\times {\left[\frac{LAT(m)}{T}\right]}^w
\end{eqnarray}
$$
ただし、$w$は以下で定義される重み係数
$$
w = \begin{cases}
\alpha,\ \mathrm{if}\ LAT(m)\leq T\\\\\\
\beta,\ \mathrm{otherwise}
\end{cases}
$$
とする。

![例えばこんなグラフになる。目的によって$\alpha, \beta$を変えれば良い](Screenshot from 2019-09-06 23-53-56.png)

こうすると、"$T$をちょっとオーバーするけど$ACC$は高い"というモデルとかも提案されるようになる

![1度の探索でMnasNetA1-MnasNetA3という複数のモデルができた。](Screenshot from 2019-09-06 23-03-05.png)


本論文における違いとしては、$w=-0.07\rightarrow-0.15$に変更したこと。モデルが小さいときにはLATをちょっと変えるだけでACCが劇的に変わるので、それに対応した。  
また、Largeについては、MnasNet-A1と大体一緒だったので、NASは省略してNetAdaptのみ行った。

どのようにしてモデルを調整したかは、以下の図が詳しい：

![それぞれのブロックの中では、同じレイヤーが繰り返されている。ただし、最初のレイヤーだけはstride=2のこともある](Screenshot from 2019-09-06 23-53-39.png)

また、パラメータは次の文章の通り：

![](Screenshot from 2019-09-06 22-19-31.png)

ん？ **Squeeze-and-Excitationって何？？？？** と多くの人はなると思うので、NetAdaptのまえに少々寄り道してそちらを解説する。

## Squeeze-and-Excitation

以前に[別の論文](https://arxiv.org/abs/1709.01507)で提案されていた手法。  
こちらも仕組みは単純。

![SE Blockの概略図](Screenshot from 2019-09-06 23-55-32.png)

なんらかのコンボリューションブロック$\mathbf{F}$が終わったら、その出力$\mathbf{U}$を  
1. Global average poolingする  
2. 全結合層にかける（1x1 convのようにチャンネルごとに混ぜ合わせる働きを持つことに注目）$$
s = \mathbf{F}_{ex}(z, \mathbf{W})=\sigma(\mathbf{W}_2\mathrm{ReLU}(\mathbf{W}_1z))
$$  
3. $s \in [0, 1]$を「倍率」として扱い、もとの特徴量$\mathbf{U}$にチャンネルごとに掛ける  
というもの。 **これだけで性能が向上する** 

これをSqueeze-and-Exciation Block略して **SE Block** という。

![InceptionブロックとResidualブロックに適用した図。どんなモデルにも追加でき、安定して性能向上に寄与するのもメリットの一つ](Screenshot from 2019-09-06 23-53-02.png)

SE Blockは、（平均して）どのチャンネルがよく活性化しているか、という **チャンネルの特徴自体をチャンネルの重みとして活用** しており、軽量な **self-attentionのようなもの** と捉えることができる。

ただ、闇雲に全部の層に突っ込みまくればいいというわけでもなさそうというのも指摘されていた：

![層の深さによって、excitationのクラスごとの違いに差がある](Screenshot from 2019-09-06 23-52-36.png)

最初の方と最後の方の層ではクラス間にあまり差がなく、識別に役に立っているとは考えづらい。  
とくに、最後の方の層は **チャネル数が多いのでSE Blockの計算量も大きくなってしまう** 。  

* 例えば、最終層を取り除くとほぼ性能変化がない（<0.1%）にもかかわらずパラメータ増加を+10%→+4%に落とせる、うれしい！ということが原論文ですでに指摘されていた

だが、どの層でSE Blockを使うかというのはハイパラとして細かく調整できそうだ。というわけでNASではそれを調整している[^hypara-okasikune]。

[^hypara-okasikune]: $r$の定義がMnasNet論文とSEを提案した論文とで一致していないが、MnasNet論文における$r=0$とはおそらくSE Blockを使わないという意味だろう。

## NetAdapt

フィルタ数を細かく調整していくための方法。これも[別の論文](https://arxiv.org/abs/1804.03230)で提案されたもの。

1. 現在の設定を変更して、いくつかの「提案」をつくる。これらは、現在のモデルより$\delta$以上レイテンシが減っているようにすること。
	* 例えば、現在のレイテンシ$L$に対して$\delta = 0.01\left|L\right|$とすれば、0.999倍以下になるようにできる。
	* レイテンシをいちいち測定するのは大変だが、設定によってほぼ確定するので設定ごとのルックアップテーブルを事前に作っておけば速い
	![チャネル数とフィルタ数はその層のレイテンシを一意に決める](Screenshot from 2019-09-06 23-52-10.png)

2. 設定の変更に応じてL2ノルムの小さなフィルタを消す。
3. $T$ステップfine tuneして大体の性能を推定する。
4. 最も性能の高い「提案」が生き残る。

これを、ほしいレイテンシが得られるまで繰り返す。

この論文における変更点としては、  

* 性能の高い提案ではなく、性能・レイテンシの減少比$\frac{\mathrm{\Delta Acc}}{\left|\mathrm{\Delta Latency}\right|}$の高い提案が生き残るようにした。
	* 提案は非連続なものなので、「レイテンシが$\delta$より大きく減少しているがAccもそれに合わせて大きく減少してしまっている」という提案がなされるかもしれず、これを考慮したもの
* 以下の設定を追加、これらの変更を「提案」として使えるように
	* expansion layerのサイズを減らす
* ボトルネック層のチャネルサイズを（一括で）調整
	* 一括にしないといけないのは、residual connectionで繋がれているボトルネック層のチャネル数が合ってないと足し合わせることができないため

# ネットワークデザイン

最初の方の層と、最終層が計算的に重いことがわかったので、改善する。

## 復習

* 1x1 convの計算量は入力$C$チャンネル、出力$C'$チャンネルのとき$HWCC'$
* 3x3 depthwise convの計算量は$9HWC$（入力と出力は同じ$C$チャンネル）

## 最終層

![既存のモデルの最終層。inverted residual blockのあと、global average poolingをしている](Screenshot from 2019-09-07 00-14-00.png)

これに則ってそれぞれのconvのMulAdd計算量を出すと、

* $7^2 \times 160 \times 960 \approx 7\mathrm{M}$
* $9 \times 7^2 \times 960 \approx 0.42\mathrm{M}$
* $7^2 \times 960 \times 320 \approx 15\mathrm{M}$←こいつと
* $7^2 \times 320 \times 1280 \approx 20\mathrm{M}$←こいつがやばい
* $1^2 \times 1280 \times 1000 \approx 1.3\mathrm{M}$

チャンネル数を最後に広げるのは、豊富な特徴量のために不可欠だが、計算が重いのでどうにかしたい。

こんなに計算が重い理由の一つは、1x1 convを **7x7の解像度でやっているせいで計算量が約５０倍** になってしまっているためだろう。  
これを解決するため、最後の層をaverage poolingのあとに移す。これで機能を保ったまま解像度が1x1に下がる。

また、この手法をとったのなら、計算量を減らすために一つ前に入れられていた320チャンネルへのボトルネックも不要だ。これでさらに計算量を減らすことができ、最終的に下図のようになる。

![最終層が上から下に変更される](Screenshot from 2019-09-06 23-50-48.png)

実際、計算量は

* $7^2 \times 160 \times 960 \approx 7\mathrm{M}$
* $1^2 \times 960 \times 1280 \approx 1.2\mathrm{M}$
* $1^2 \times 1280 \times 1000 \approx 1.3\mathrm{M}$

になっており、合計計算量は$43.72 \mathrm{M} \rightarrow 9.5 \mathrm{M}$、約$30\mathrm{M}$の減少。これは7msに相当し、 **全実行時間の11%** にもなる。  
 **この変更による精度の減少はほぼない。** 

## 最初の層

現行のモデルは、3x3コンボリューションフィルタ32個を使うことが多い。だが、これらは **お互いの鏡像である** ことが多い。

そこで、フィルタを減らす代わりに **非線形関数を変えて** ムダを減らす。  
最終的に他の非線形関数と同じような性能を出したhard swishを使うことにした。  

ReLUやswishで32フィルタを使ったときと同等の性能をh-swish+16フィルタで達成。$10\mathrm{M}$=1.2msの削減に成功した  
どうしてh-swishを使うことにしたのかは次の節で説明する

# 非線形関数

既存研究で **swish** という非線形関数をReLUの代わりに使うことが提案されている。

$$
\mathrm{swish}\ x=x \cdot \sigma (x)
$$

だがsigmoidは重いのでどうにかしたい。というわけで **hard swish** という関数を使うことにする

$$
\text{h\-swish}\ \left[ x \right] = x \frac{\mathrm{ReLU6} (x+3)}{6}
$$

ただし、$\mathrm{ReLU6}(x) = \min (\mathrm{ReLU}(x), 6)$

これは、計算が軽いだけでなく、量子化されているときにsigmoidの近似により発生するかもしれない誤差が小さい。  
また実際には

$$
\text{h-swish}(x) = \begin{cases}
0\           &(x<0)\\\\\\
x(x+3)/6\    &(0<x<3)\\\\\\
x            &(3<x)
\end{cases}
$$

のように最適化できる。これによりメモリアクセスが減ってレイテンシが劇的に下がる。嬉しい。  
ちなみに最適化されたh-swishはすでにTFLiteに実装されており、デフォルトで使えるそう。

![h-swishの図。h-sigmoidと同じように、だいたい同じ値にしつつ計算量を下げるのが目的](Screenshot from 2019-09-07 10-09-58.png)

しかし、h-swishは最適化されていても小さいとはいえやはり速度に影響を及ぼす。できるだけReLUも使いたいので、どちらを使うかを探索する。  
すると、 **深い層のほうが活性化関数の使われる回数（∝コスト）は一般に少ない** ということが効いてくる。

* 深くなると解像度が半分になり、したがって使われる回数は1/4だが、そのときチャンネル数が４倍になっていることはまずないので

実際、h-swishを使うことによる恩恵は後半の層でのみ大きくなるようで、今回は **最初の層と後半の層のみ** にh-swishが使われている。詳しくは以下の表を見よ。

![MobilenetV3-Largeのスペック。SE: Squeeze-and-Exciteが使われているか否か。NL: 非線形関数の種類（ReLU or Hard-Swish)。NBN: No Batch Normalization](Screenshot from 2019-09-07 10-31-39.png)

![MobilenetV3-Smallのスペック](Screenshot from 2019-09-07 10-31-47.png)

![MobilenetV3のブロック構造。SE Blockのbottleneck部のチャンネル数はもとの=expansionの1/4とすると、遅延はほぼなく性能が向上することがわかった。また、sigmoidの代わりにh-sigmoidを使っていることにも注目](Screenshot from 2019-09-07 10-48-09.png)


# セグメンテーションモジュール

セグメンテーションの手法の一つ[DeepLab](https://arxiv.org/abs/1606.00915)では、下の図[^pctoliangchiehchen]

[^pctoliangchiehchen]:[DeepLabの著者の一人のサイト](http://liangchiehchen.com/projects/DeepLab.html)より引用

![](deeplab_aspp.jpg)

のように、複数のdilated convを並列的に行って情報を集約するという方法が取られていた。これで、様々なスケールの特徴量を同時に計算できる。  
具体的には以下のようなモデルとなる。

![](Screenshot from 2019-09-07 14-53-22.png)

しかし、 **計算が死ぬほど重い割にそんなに性能に効果がない** ことが指摘され、 **average poolingだけでいいじゃん** となった。

![MobilenetV2論文より](Screenshot from 2019-09-07 15-56-43.png)

* たとえば３行目と５行目に注目。ASPPにより計算量が倍以上になっているのに性能は0.4%弱しか上がってない。

これにより提案された[^proposed_in_mobilenetv2]のが **Reduced-ASPP** 、略して **R-ASPP** 。atrous convを並列的に行う代わりに **1x1 convとGAPだけですませる** というもの。

[^proposed_in_mobilenetv2]: MobilenetV2にて提案されている。名前は後付のようだが……

本論文では、それを更に改良した **Lite R-ASPP** 、略して **LR-ASPP** を提案する。~~名前つけるの好きだな……~~

![複数の解像度の特徴量を混ぜ、高速にsegmentationを実行する](Screenshot%20from%202019-09-07%2011-50-25.png)

* Squeeze-and-Excitationをまねて、GAPっぽい仕組みを使う
	* 広い範囲のpoolingを大きいstrideで行って、情報を集約しつつ計算量を節約
		* このあとこれに対して1x1 convを行わなければいけないので
	* それをスケールとして使う
* 最後に解像度の高い層の結果と足し合わせ、細かい修正効果を期待する

# 結果

## Classification Task

![浮動小数点演算を使ったときのパフォーマンス。P-nはGoogleのスマホであるPixel-nを使いバッチサイズ=１としたときのレイテンシ(ms), Top-1はImageNetでの結果](Screenshot from 2019-09-07 10-59-41.png)

![上の表をグラフにしたもの。左上のほうが良い](Screenshot from 2019-09-07 20-23-24.png)

![計算を量子化したときのパフォーマンス](Screenshot from 2019-09-07 10-59-48.png)

![解像度やチャンネル数比をいじったときのパフォーマンスの変化](Screenshot from 2019-09-07 11-04-12.png)

* 解像度を下げると良い結果が出るが、セグメンテーションや物体検出など、高い解像度を要求するタスクには使えないので注意

## Ablation Study

![h-swishを使う数を変えたときの結果。@nは「最初にh-swishが使われた層はnチャンネル」の意](Screenshot from 2019-09-07 11-07-25.png)

* @16とはつまり全てh-swishという意味。当然計算量は少し多くなる……が性能は高めになる。特に、最適化をしないとすごく計算時間が伸びることに注目
* @112ではh-swishが減っているので速度は僅かに上がっているが、性能が下がっている

![上の結果をグラフに追加したもの](Screenshot from 2019-09-07 11-20-53.png)

![それぞれの改良によってモデルの性能にどのような変化が起きるかという図](Screenshot from 2019-09-07 11-22-39.png)

## Detection

![$\dagger$がついているものは、チャネル数を最後の方の層で半分にしている](Screenshot from 2019-09-07 11-39-09.png)

$\dagger$の改良は、性能を変えないままレイテンシを15%下げている。ImagenetとCOCOには異なる形状の特徴量抽出器を使ったほうがいいのかもしれないということを示唆。

* Imagenetは1000クラスあるが、COCOは90クラスしかないので、必要とされるチャンネルの豊富さが違うためと考えられる

## Semantic Segmentation

![RF2: 最終層のフィルタを半分にする。SH: ✓ではR-ASPPでなく提案手法LR-ASPPを用いている。F: Segmentation Headにおけるフィルタ数。CPU: Pixel 3(浮動小数点)で測定したGPU時間、(h)は画像サイズを半分 (512x1024) にしたもの。８、１１行目が最終的な提案モデル](Screenshot from 2019-09-07 14-33-29.png)

* 物体検出のときと同じように、最後のブロックのチャネル数を２で割ってもあまり性能は変わらず、速度を大きく向上させられる（１行目vs２行目、５行目vs６行目。以下、「行目」を略す）
	* 今回のタスクであるCityscapesは19クラスしかないので、やはりムダがあるのだろう
* LR-ASPPはR-ASPPと比べ性能がよく速度もわずかに速い (２vs３, ６vs７)
* Segmentation Headのフィルタ数を256→128に減らすと、性能が少し落ちるが速度が上がる（３vs４ ７vs８）
* 同じ設定なら、V3はV2と同じような性能でわずかに速い（１〜４vs５〜８）
* V3-Small（11）はV2 0.5（９）と同程度の性能だがより速い
* V3-Small（11）はV2 0.35（10）と同程度の速度だがかなり性能がいい

![OS: output strideのこと、OS=16のとき、atrous convolutionがバックボーンの最終ブロックに使われている](Screenshot from 2019-09-07 14-33-43.png)

* atrous convを使えばもちろん勝てる、使わなくてもやや性能が悪いがそれでも勝ってる、計算量的にも圧勝

# まとめ＆感想

正直なところ、この記事に書いてある内容をほとんど知らなくてもMobileNetV3は使えるだろう[^black_box_technology]。なので、自分も最初は徒労感があって読むのをやめようかとも思ったが、読んで見ればなかなかどうして面白かった。ムダを鋭く指摘してストイックに削っていく様はなかなか爽快なので暇な人は読んでみてはいかがだろうか。

ただ、自分含む多くの人は、MobilenetV3とは **CPU上での実行を** 高速化するため **徹頭徹尾MulAddを減らそうと試みているモデルである** ことを覚えて帰れば十分であり、むしろこの事実が一番重要だろう。  
つまり、おそらくMobilenetを **GPUで走らせても、性能はそんなに良くないわ実行も速くないわで使い物にならない** だろうから注意[^why_slow_on_gpu]せねばならないということだ。だが、 **スマホアプリに載せる** とか、 **ラズパイで走らせる** とかが目的なら、NASの力を使って極限までハイパラチューニングされたこのモデルは、十徳ナイフのように、どんなタスクにも安定して高い性能を発揮する非常に強力な助っ人となるだろう。

[^black_box_technology]: 深層学習のモデル選定すらも完全に自動で行われるようになり、人間が必要とされる場面がますます限定されていくディストピアを舞台にしたSF百合小説『色のない緑』（ハヤカワ文庫JA『アステリズムに花束を』に収録）を最近読んだ。とても良かった。月並みだが、このMobileNetV3にも使われたNASなどは、そのディストピアの始まりに思えてならない。楽しみだ

[^why_slow_on_gpu]: なぜGPUでこのモデルが遅くなるかは[以前書いた記事](https://qiita.com/woody_egg/items/db6e85de34eab5247478)に詳しい

*写真は、特に明記したものを除いて、リンクされている論文の中のいずれかのスクリーンショット。*  
*また、この記事はMETRICAの社内勉強会のために書いたものを改稿したものである。*
