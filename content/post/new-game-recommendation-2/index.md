---
title: "僕が次に遊ぶべきゲームをデータから探そう 続"
date: 2018-12-15T04:40:09-05:00
description: "続編です。SVDによるデータ処理の解釈についていろいろと考えたこともつらつらと書きました。"
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

[前回](https://woodyzootopia.github.io/2018/12/15/僕が次に遊ぶべきゲームをデータから探そう/)に引き続きもう少し高度なやつをやったのでご紹介。

スパースなデータに対して協調フィルタリングは弱いらしいので、SVD・NMFなどの手法を用いて線形代数の力を借りるともっといい結果が出るかもしれません。

これらの手法が強いのは次元を削減しているためです。次元を減らすことで表現力を下げることができ、過適合を避けられます。\

また、特にスパースなデータに協調フィルタリングを適用したときは**比較したい2つのゲームを遊んでいる人がいないと結果に現れない**という問題があります。\
それに対し、次元を削減するこれらの手法はユーザ・ゲームタイトルを**クラスタリングする**ことができます。つまり、「これを遊んだ人はこれも遊んでいます」から「これを遊んだ**人たち**はこれも遊んでいます」に進化するわけですね。\
今回の例ではどちらも100次元にまで減らしています。\

また、ユーザがどのくらい時間を費やしたかを見たいので、ユーザごとに合計プレイ時間が$[0,1]$に収まるように正規化しています。[前回](https://woodyzootopia.github.io/2018/12/15/僕が次に遊ぶべきゲームをデータから探そう/)述べたように時間を食いまくる中毒ゲーが推薦されることが心配されますが、**BotWのプレイ時間を見て「面白いゲームが時間を食うのは仕方ない」**と思ったので諦めることにしました。

この記事の著者は典型的工学部人間なので、数学的なバックグラウンドは曖昧です。SVDの解釈の仕方など、数学系の人が見ると鳥肌の立つような表現があるかもしれませんが、そこは優しい目で見逃してください。

## SVD

SVDは与えられたデータを
$$
A=U\Sigma V^T \ 
where\ U,V\ is\ orthogonal\ matrices,\ \Sigma\ is\ a\ diagonal\ matrix
$$
と分解します[^2]。今回の例だと、ユーザ数が11350、ゲームの種類が3600だけあるので、$dim(A)=11350\times 3600,dim(U)=11350\times s,dim(\Sigma)=s\times s,dim(V^T)=s\times 3600$としてやり、$s$をお好みの値にします。$s$が$max(m,n)$より小さいと完全な分解は一般に存在せず、近似することになります。[^1]\

[^2]:$A$の代わりに$A^T$としてやって始めても同じ結果になります。左右がひっくり返るイメージです
[^1]:なお、このときUは正方行列ではないので厳密には列のみ直交 $U^T\cdot U=I\_s$です。後ろの$3600-s$次元を切り取ったイメージ。Vも同様

SVDには大きく分けて2通り解釈の仕方があります。

### $V$から解釈するやり方

$V:(3600,s)$は**ゲームタイトルから潜在空間への対応**と考えることができます。例えば各ゲームのベクトルは$V$の$i$行目で$dim(V\_i)=(1,s)$です。もしかしたらこれは**$s$種類のジャンル**に対応付けているのかもしれません。\

ただし、Vには正規性の制約が有るため、各ゲームのジャンルを2乗して総和を取ると1にならないといけません。\
また、直交性の制約も有るため、各ジャンルは互いに素でないといけません。例えば、アクションとアドベンチャーは明らかに素ではないと（同じ方向性を持っていると）考えられるため、$V$は明らかにこれら2つのジャンルとは厳密には対応していないでしょう。

次に対角行列$\Sigma$が、それぞれのジャンルの「強さ」を再調整します。例えば、上の制約より、多くのゲームが属しているジャンル（アドベンチャーなど）は合計値が大きくなってしまうのですが、それを制限してやるわけですね。\
$\Sigma$のそれぞれの値を特異値といいますが、これは**重要度÷出てきた回数**と解釈できるでしょう。

最後に、Uを掛けて潜在空間からユーザに対応させてやるわけです。

### $U$から解釈するやり方

逆に$U$から解釈しても同じことが起きます。$U$はユーザのジャンル、すなわち**好みの似ているユーザ**と解釈するのが妥当でしょう。例えば、「アクションゲーム好き」「ノベルゲー好き」「ギャルゲー好き」なユーザたちがそれぞれ似た値を持つことが推測されます。\
これに$\Sigma V^T$を右から書けてやると、そのプレイヤーたちが好きであろう[^3]ゲームが出てくるわけです。ということは、$\Sigma V^T$は**あるユーザのジャンル活性度データ$U\_i$に右から掛けることで**おすすめゲームを算出してくれる行列と解釈できるでしょう。

[^3]:$s$が十分大きい場合、$A$が再現されるので実際に好きなゲームのみが出てきます。なんの意味もないですが。

### 今回だとどうするのか
というわけで、Aのi行目のユーザにおすすめのゲームを考えたい時は、$A\_i\Sigma V^T$のようにしてやります。\
今回は僕という**データセット内に存在しないデータ**$U_i$（TESVのところが80、Undertaleのところが50で他は0のベクトル）について考えないといけないので、これらユーザの中に僕を追加して計算してやるといい気がしますが、このやり方だと僕自身が訓練データに含まれることになるのでなんか美しくないです。\

なので、普通に$U\_i\cdot V\cdot V^T$を計算してやってそれを降順に並べ替えます。これは、好みのゲームを潜在空間に一度射影して、その潜在空間から対応するゲームを取り出すという作業に相当します。\

```python
Me=np.zeros(3600)
Me[38]=50.0 #Undertale 50 hours
Me[0]=80.0 #TESV 80 hours

from sklearn.decomposition import TruncatedSVD
#scipy.linalg.svdは\Sigmaの次元をmin(m,n)にしかできないので今回はこっち
svd=TruncatedSVD(n_components=100,random_state=42)
svd.fit(normalized_sparsedata.T)
VT=svd.components_
recommendation=np.dot(Me,(np.dot(VT.T,VT)))
```

$V^T\cdot V$は**ジャンルの似ているゲームを活性化させる**行列とも言えます。前回の内容（データ行列は自身の転置との内積を取ると自己相関を表すようになる）と$V$が「データからジャンル潜在空間への対応のデータ行列であること」を考えると自然な帰結と言えるのではないでしょうか。\

```data
Don't Starve                                  0.049135
Mitos.is The Game                             0.042975
The Elder Scrolls V Skyrim                    0.040343
Rocksmith 2014                                0.029442
The Witcher 3 Wild Hunt                       0.029096
Half-Life 2 Episode One                       0.028437
Zombie Panic Source                           0.027298
Gotham City Impostors Free To Play            0.025928
Undertale                                     0.024810
Dirty Bomb                                    0.023235
Neverwinter                                   0.022141
Crusader Kings II                             0.022028
Batman Arkham Origins                         0.019220
Dark Souls Prepare to Die Edition             0.015924
Sniper Ghost Warrior                          0.014669
Age of Empires II HD Edition                  0.014120
Half-Life 2 Episode Two                       0.013151
Magic Duels                                   0.012050
Star Wars Knights of the Old Republic         0.011773
Europa Universalis IV                         0.011404
Batman Arkham City GOTY                       0.009904
South Park The Stick of Truth                 0.009752
Stronghold Kingdoms                           0.009547
The Binding of Isaac Rebirth                  0.008689
Insurgency Modern Infantry Combat             0.008475
Terraria                                      0.008366
Magicka                                       0.007992
Nosgoth                                       0.007693
The Witcher Enhanced Edition                  0.007434
LEGO MARVEL Super Heroes                      0.007411
```

おお！いい感じですね。Undertaleも入ってます。大作オープンワールドとインディーズゲームが混じってて、評価も高いものが多いです。
                                  
## NMF

NMF(Non-negative Matrix Factorization)も線形代数による潜在空間への射影において強力です。
分解したベクトルが正になるように制約をかけています。これにより、より直感的な分解が可能になります。こちらの記事がわかりやすいです。https://abicky.net/2010/03/25/101719/ \

$$
V \approx WH\ where\ W,H\geq 0
$$

例によって$dim(V)=11350\times 3600,dim(W)=11350\times s,dim(H)=s\times 3600$です。$s$次元の潜在空間に一旦飛ばすわけです。\
要素に正の制約があるので正直どうやって計算したものかさっぱりなのですが、参考文献[^5]に有るような手法を使うと学習させることができるらしいです。\
これによりs次元潜在空間へと写像できます。[^6]

NMFのが直感的というのは、上記事で紹介されているように、白いキャンバスに黒い絵の具の素材の貼り合わせ**のみ**で顔を書いていくような問題を考えると理解しやすいかと思います。マイナスの値、すなわち**白い絵の具を使えなくした**のがNMFです。\

[^6]:また、NMFは正の制約を課す代わりに生成されるs次元のベクトルに直交性の制約がないです。すなわち、ジャンル同士が互いに素でなくてもいいということです。これは嬉しいですね。

今回の問題でいうと、**ゲームが何らかのジャンル・属性を持つことが推定プレイ時間に負の影響を与えない**という制約を課すことになります。\
ただ、この制約が今回のデータに対して正しいものかどうかはわかりません。例えば僕はホラーゲームが嫌いなので、**ホラーというジャンルに属することがプレイ時間に負の影響を与えています。**そのため正しいモデルとは言えないかもしれず、結果として変な推測を返すかもしれません。今回はどんな推測が正しいのかわからないし、別に気にしませんが。

実装は大体SVDと一緒です:

```python
#Non-negative Matrix Factorization
from sklearn.decomposition import NMF
nmf=NMF(n_components=100,random_state=42)
nmf.fit(normalized_sparsedata.T)
H=nmf.components_
recommendation=np.dot(Me,np.dot(H.T,H))
print(pd.DataFrame(recommendation.T,index=playtime['The Elder Scrolls V Skyrim'].unique(),columns=[1]).sort_values(by=1,ascending=False))
```

結果を見てみましょう。同じく$U\_i\cdot H^T\cdot H$を計算したものです。

```data
Magicite                                      2.906095
Super Amazing Wagon Adventure                 2.702556
FarSky                                        2.464610
Titan Souls                                   2.375021
8BitBoy                                       2.339357
Grand Class Melee 2                           2.339051
Crawl                                         2.339051
ENKI                                          2.339051
Movie Studio 13 Platinum - Steam Powered      2.339051
Obscure                                       2.339051
Obscure 2                                     2.339051
Vagante                                       2.339051
Divine Divinity                               2.339051
Runers                                        2.339051
Fancy Skulls                                  2.338706
A Valley Without Wind                         1.956577
SOMA                                          1.782524
Action! - Gameplay Recording and Streaming    1.617995
SteamWorld Dig                                1.367417
Edge of Space                                 1.100761
Fallout New Vegas                             1.092337
Savage Lands                                  1.014750
The Witcher 3 Wild Hunt                       0.978085
Magicka 2                                     0.972367
Endless Legend                                0.892993
The Elder Scrolls Online Tamriel Unlimited    0.878821
Ziggurat                                      0.863003
TowerFall Ascension                           0.832033
Rocksmith 2014                                0.802326
Shadow Warrior                                0.794411
```

なんだかちょっと違う結果になりましたね[^4][^8]。\

いずれにせよ評価の高いゲームが並んでおり、ある程度「**高評価**(＝プレイヤーが自分のゲーム時間の多くを費やしている)**・かつ自分の好み**」なゲームを取り出すことに成功しています。

計算自体も非常に速い(削減先の次元数にもよると思いますが、100次元程度ならノートPCでも学習はすぐに終わり、推論に至っては単純な行列の内積なので一瞬)ので、ﾃﾞｨｰﾌﾟﾗｰﾆﾝｸﾞに飽食気味な自分には良いエクササイズになりました。

どっちの手法でもFallout New Vegasが強く推されているのでこれはやらないといけないな……（勉強は？）

[^8]:僕の好きなゲームが少なすぎるのであまりうまく比較はできませんが、SVDよりNMFのほうが「ザ・洋ゲー」みたいなゲームを強く押してきているような気がします

[^4]:ちなみに、推定値自体は当てにしてはいけません。データは$[0,1]$の範囲なのに3近くなってますし。これは、データがガウス分布に従っているという仮定を満たしておらず、実際にはスパースであることに起因します。

[^5]:http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.31.7566
