---
title: "【論文読み】A Probabilistic U-Net for Segmentation of Ambiguous Images"
date: 2018-12-08T11:11:00-05:00
description: "面白い試みです。"
banner: "banners/probabilistic-unet-segmentation.png"
# lead: "Example lead - highlighted near the title"
# disable_comments: true # Optional, disable Disqus comments if true
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
categories:
  - "技術"
  - "論文"
tags:
  - "CNN"
  - "generative model"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

表題の論文を読んだので備忘録がてら解説。
[arxiv URL](https://arxiv.org/abs/1806.05034)


1. 論文の概要

 * U-NetとConditional VAEで確率的セグメンテーションをした。
 * 複数の教師アノテーションがある場合に、それらを内包することができる設計。
 * 医療の意思決定に使うことができるかもしれない？（単一の画像で返されるより、いくつかの予想パターンを返してほしい）

2. 問題設定と解決した点（先行研究と比べてどこが凄い？）

 * VAEからサンプルした数だけ、consistentなmap[^1]が複数出てくる。計算量も軽い。数量的に評価可能。
 * 色塗りをする人によって結果が異なる場合があるため、多人数で行われた色塗りの結果でtrainすることができる。
 * これまでの手法はinconsistentだったり、diversityに欠けていたり、確率を学べていなかった。(spatial dropout, ensemble, multi-headなどが先行手法としてあげられている)
 * graphical modelは、graphiclal modelで表現できるものしか学ばない

 [^1]:pixel-wiseではなく画像一枚単位でのconsistency。

3. 技術や手法のキモ

 * U-netと並列にVAEでmeanとvarianceを作り、そこからサンプリングした変数をbroadcastしてu-netのDeconvの出力に加える。その後1x1 convolutionを3回やって特徴量をなじませる。
 * U-netの推論は一回でいいので、計算量的にもお得。
 * 学習時にはCVAEであるposterior netの作った潜在変数を代わりに与える。ラベルを知ることができないprior netは入力画像だけからposterior netの作る潜在変数を模倣するよう努める(KLDiv最小化)。これは文献[25]に詳しいらしい。

4. 主張の有効性検証

 * 本論文ではVAEの潜在変数の次元は6。
 * 肺の病気を見つけるLung abnormalities segmentation,車載カメラの画像からsegmentationするCityscapes semantic segmentationでテスト。
 * 同じ画像に対して複数のアノテーションが存在しないとuncertaintyが生まれないので、Lung abnormalitiesの方は４人の別のラベラーの結果を、Cityscapesの方は確率で新たなセグメンテーションにflipした。こうしないと実用はともかくquantitative eavluationができないので。
 * Lungの方について、サンプル数4以上の時squared generalized energy distanceというground truthからのずれを表す指標が提案手法は既存手法より優位に低かった。
 * cityscapeの方についても同様。また、訓練データに人工的に与えたflipをうまく再現できていた。最も低いもので0.5％の可能性でしか出現しないのだが、それにもきちんとマッチしていた。
5. 議論すべき点

 * 複数のアノテーション可能性をVAEに内包できるのは、応用がききそう。例えば自動色塗りにおいていくつかのパターンを提示するとか
 * VAEからのサンプリングということは、運が悪ければ変なアノテーションを見ることになるので、結局多くのサンプルを見ないといけない。いちいち数十枚の画像を見せられても医者は困るので、そこは改善しなければならない？

6. 次に読むべき論文は？

 * 既存手法としてあげられていたmulti headなどがまずわからんので時間があれば読みたい。
 * appendixに潜在空間とアノテーションの関係とかが図付きで載っていてきれいなので暇なら読んでみてください。
 * 文献[25]. beta-vae: Learning basic visual concepts with a constrained variational framework

以上です
