---
title: "僕が次に遊ぶべきゲームをデータから探そう"
date: 2018-12-15T01:45:05-05:00
description: "レコメンデーションシステムに興味が湧いたのでいくつか実装しました。"
# banner:"/img/some.png"
# lead: "Example lead - highlighted near the title"
# disable_comments: true # Optional, disable Disqus comments if true
disable_profile: true # no one wants to see my profile while reading articles
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
categories:
  - "技術"
tags:
  - "scikit-learn"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

> この記事には主に結果だけ書いてあります。実装を読みたい人はjupyter notebookで読んでください。\
> また、この記事は、**データサイエンス系の記事の皮をかぶったそうでない何か**の記事かもしれません。

# 動機

機械学習の分野の一つに**レコメンデーションシステム**があります。いろいろ記事はあるんですけど、**ゲーム**でやったものは見当たらなかったので、実装の練習がてらやってみようと思います。
データセットは[Kaggle Steam Video Games](https://www.kaggle.com/tamber/steam-video-games)より。Steamのプレイヤーの匿名化されたゲームプレイ情報です。

結論から言うとこの記事はこのデータセットに対して協調フィルタリングを適用してみた結果について書いています。

僕がSteamでやったことのあるゲームの中でこのデータセットにあったものは2つで、

* **Undertale**
* **The Elder Scrolls V Skyrim**

ですね。

The Elder Scrolls V Skyrim、通称**TESV**は言わずとしれた大作オープンワールドゲームです。80時間くらいやりました。\

Undertaleもかなりやりこんで50時間位ですかね。\
こちらはインディーズ作品にもかかわらず異例の大ヒットを飛ばしたゲームで、可愛らしいモンスターたちとのやり取りと**凄まじく練り込まれたプロット**が魅力の作品ですので、プレイしたい方は**ネットで検索することすらせずに**まっさらな状態でプレイすることを**強くおすすめ**します。\

↓まだUndertaleを知らない頃にfan-madeのこの動画を見て完成度の高さに感動しました
{{< youtube m7QsKlLLgw0 >}}

さて、この2つのゲームをやりこんだという記録から他の人がどんなゲームを遊んでいるのかをもとに僕に合いそうなゲームを探してみましょう。

# 実装
[jupyter notebookで書いた](Steam.ipynb)ので読みたい人はダウンロードしてください。試行錯誤しながらやるタイプのプログラミングは可視性も相まってやっぱりnotebookがいいですね。

データセットには購入したゲームと遊んだ時間が乗っています。遊んだ時間が長ければ長いほどその人がゲームにはまっていることを示し、より多くの情報が得られそうなのでこちらを今回は採用。one-hot（じゃないですけど。こういうのなんて言うんでしょう？）な感じのスパース行列に格納しました。\
よくアマゾンとかの商品レコメンドのやつでは星1〜星5を格納してますが、今回は遊んだ時間の範囲が$ [0,\inf) $なので、**長いプレイ時元が必要な・長く楽しめるタイプのゲームほど影響が大きい**という現象が起きます。それでも構わないという人もいるかも知れませんが、

* ハマると極端に時間を費やしてしまうゲームに結果が引っ張られること
* 逆に短時間でクリアできるゲームにも面白いものはたくさんあること（Undertaleは一周長くても10時間程度でクリアできますが、先に述べたようにとっても心に残る良作です）
* またそのようなゲームをレコメンドされても自分は忙しくてプレイできないであろうこと（ハマったゲームですら100時間できてないです）

という問題があるので、ゲームごとに$[0,1]$の範囲に入るように標準化しました。[^1]

[^1]:このやり方は正直適当に決めたもので、いいのかはわかりません。標準偏差を合わせたほうがいいのかもしれないし、プレイヤーごとの差を考慮できていません。ここがミソな気がするのでいい方法を考えたいですね……

## 協調フィルタリング
今回行った実装は極めて簡単なもので、データセットを自身の転置と掛けるだけです。この結果は明らかに対称行列になり、かつ要素$(i,j)$は$i$番目のゲームと$j$番目のゲームの遊ばれ方（どのユーザに・どのくらいの時間遊ばれたか）の類似度になっています。\

厳密に言うと、掛け合わせる順番によりアイテムベース（**これを遊んだ人はこれも遊んでいます**=このゲームとこのゲームにハマる人は同じ場合が多いです）と、その逆のユーザベース（あなたはこのユーザと似ています）の2つの類似度が算出できますが、今回欲しいのは前者だしそもそもデータセット内のユーザ名は匿名なのでアイテムベースで考えます。\

では結果ですが、TESVと一致度が高かったものは……
```data
The Elder Scrolls V Skyrim                        7.031460
Fallout New Vegas                                 2.192425
Middle-earth Shadow of Mordor                     1.733149
Far Cry 3                                         1.656518
Borderlands 2                                     1.460792
Dead Island                                       1.325333
Deus Ex Human Revolution                          1.262768
Hitman Absolution                                 1.208435
Medal of Honor(TM) Single Player                  1.149765
Fallout 4                                         1.138593
Sunless Sea                                       1.074332
Toy Soldiers                                      1.062508
Kingdoms of Amalur Reckoning                      1.037520
Dungeons & Dragons Daggerdale                     1.034061
Brothers - A Tale of Two Sons                     1.024191
Just Cause 2                                      1.014241
Assassin's Creed II                               1.001581
Saints Row IV                                     1.001019
Battle Los Angeles                                1.000000
Dying Light                                       0.997646
Stronghold 3                                      0.989779
Saints Row The Third                              0.988511
Endless Space                                     0.973435
The Elder Scrolls III Morrowind                   0.966623
Call of Duty 4 Modern Warfare                     0.951071
Trine 2                                           0.942453
Wolfenstein The New Order                         0.911866
Fallout 3 - Game of the Year Edition              0.899140
The Witcher 2 Assassins of Kings Enhanced Edition 0.899073
Red Faction Guerrilla Steam Edition               0.881324
...   
```

FalloutとかMiddle-earth Shadow of Mordorみたいな同じオープンワールドゲームもあるし、そうでなくても主人公のかっこいい系のロールプレイングアクションゲームが揃ってますね。Just Cause 2は昔やったことがあります。悪くない感じです。

さて、Undertaleの方は……
```data
Undertale                                           4.468112
Papers, Please                                      0.847320
The Walking Dead Season Two                         0.778996
Emily is Away                                       0.699467
Amnesia A Machine for Pigs                          0.667237
Year Walk                                           0.666857
Long Live The Queen                                 0.622831
Before the Echo                                     0.621120
Organ Trail Director's Cut                          0.600000
UFO Aftermath                                       0.600000
Fate of the World                                   0.600000
Lume                                                0.572333
Cook, Serve, Delicious!                             0.564706
FINAL FANTASY XIII                                  0.559238
Fiesta Online NA                                    0.546667
Dark Arcana The Carnival                            0.480000
Aqua Kitty - Milk Mine Defender                     0.480000
Midnight Mysteries Salem Witch Trials               0.480000
Midnight Mysteries 3 Devil on the Mississippi       0.480000
realMyst                                            0.480000
War for the Overworld                               0.480000
Tales of Monkey Island Chapter 4 - The Trial and E  0.480000
Alchemy Mysteries Prague Legends                    0.480000
Nancy Drew The Haunted Carousel                     0.480000
Tales of Monkey Island Chapter 5 - Rise of the Pir  0.480000
Hector Ep 1                                         0.480000
The Silent Age                                      0.480000
Nancy Drew Ghost Dogs of Moon Lake                  0.480000
Parcel                                              0.480000
Midnight Mysteries 4 Haunted Houdini                0.480000
...
```

Papers, Pleaseは実況で見ましたね。ほかは見たことのないようなゲームばかりです。\
上からざっと調べてみましたが制作費がそこまでかかってなさそうなゲームが多いですね。
Undated好きにはインディーズ好きが多いということなんでしょうか。\
ノベル系・ホラー系が多いのも特徴と言えます。


# 感想

協調フィルタリングはスパースなデータに弱いということがあるらしいのでこれはあんまりいい方法じゃないかもしれませんね。\
NMF,SVDといったもっと高度な方法を試して続きを書かねば。

これで得られた面白そうなゲームを買うかもしれません。みなさんも自分にあったゲームを探してみてはいかがですか？\

**まあ今友達にBotW借りてめっちゃやってるんだけどね！！！！！！！！\
楽しすぎるうううううう！！！！！！！！うひゃひゃうひゃひゃうひゃ**

参考にさせていただいたサイト\
http://smrmkt.hatenablog.jp/entry/2014/08/23/211555#f-edee9aa7 \
https://qiita.com/koshian2/items/401f50d0717983696fef \
https://abicky.net/2010/03/25/101719/
