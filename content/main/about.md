---
title: "About Me"
date: 2018-12-01T18:23:12-05:00
menu: "main"
---

# 作ったもの
* [太鼓の達人自動作譜AI](/2018/07/cnnで太鼓の達人の譜面を自動生成するプログラムを書いた/)（[英語の解説記事もあるよ](https://medium.com/datadriveninvestor/automatic-drummer-with-deep-learning-3e92723b5a79)）
    * DFTで画像化した音楽データをCNNで学習した。\
    * 音楽データはネットに転がっている譜面付きのもので、実時間に変換して教師データとしてある。
    * キャッチーなテーマだったこともありツイッターでちょっと伸びた\
<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">「音楽から全自動で太鼓の達人の譜面を作るAI」を作りました<br><br>またいつか解説記事書きます <a href="https://t.co/IW6qrd9knS">pic.twitter.com/IW6qrd9knS</a></p>&mdash; うっでぃ (@woodyOutOfABase) <a href="https://twitter.com/woodyOutOfABase/status/1018708633511575553?ref_src=twsrc%5Etfw">July 16, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
* [京大空き教室リスト](/2018/12/大学の空き教室を自動で算出してくれるプログラムを書いた/)
    * 京大のウェブサイトを軽くスクレイピングして作った。一般教養科目の授業に使われる「4共」とよばれる建物の空きコマをリストにした。\
    * 手元にはあるが、大学のデータなので一応非公開。京大生の人は記事を参考にすると簡単にできるのでお試しあれ。
* [英文履歴書 (Resume)](/2018/12/latex%E3%81%A7%E8%8B%B1%E6%96%87%E5%B1%A5%E6%AD%B4%E6%9B%B8%E3%82%92%E4%BD%9C%E3%82%8B/Resume.pdf)
    * LaTeXで作った。フォーマットなどはクラスファイルに分けて書いてあるので流用・拡張が容易。
    * [ソースファイル・解説はこちらの記事で](/2018/12/latex%E3%81%A7%E8%8B%B1%E6%96%87%E5%B1%A5%E6%AD%B4%E6%9B%B8%E3%82%92%E4%BD%9C%E3%82%8B/)\
* このウェブサイト
    * [Hugo](https://gohugo.io/)でビルドされており、[github.io](https://pages.github.com/)でホスティングされている。\
    * [Icarus](https://github.com/digitalcraftsman/hugo-icarus-theme)というブログ用テーマを使っているが、これは数年前から更新が途絶えており、自分の欲しい機能がなかったため[フォークして改造し](https://github.com/woodyZootopia/hugo-icarus-theme)ながら使っている。\
        * 特に、左に出ているプロフィールを消しても本文がその分のスペースを広く使わないのが致命的だったので直した。ディスプレイの大きいデバイスでこのページ以外の記事を開くと本文が広くなっているのが確認できると思う。
        * [2018/12/27追記] 色彩デザインが目に優しくなくて気に入らなかったので魔改造した結果、オリジナルの面影はほとんどなくなりました。もしこれを使いたいという人がいたら、`config.toml`や`archetypes`などの設定も変えているので、自分の[親リポジトリ](https://github.com/woodyZootopia/blog)から直接cloneしたほうが速いかもしれません。
* [関数呼び出し機能付きインタプリタ](/2019/01/電卓を作ってみよう/)
    * Cで書いた。
    * 次のような計算ができる:
        * `10*3/2-5*3` → $0$
        * `F{a+b*b} F(2,3)` → $11$
    * 関数内で関数を呼び出すこともできるので、再帰的呼び出しも可能:
        * `F{?(a);F(a*2+3)} F(1)` → $1,5,13,29,61,125,\dots$\
* カラーテーマ[flatwhite](https://atom.io/themes/flatwhite-syntax)の[Vim移植版・flatwhite-vim](https://github.com/woodyZootopia/flatwhite-vim)
    * **文字色ではなく背景の色を変える**という斬新なカラースキーム。もともとはAtom用に作られたもの。
    * 現行のVim移植版は各言語への対応が貧弱だったので、フォークして改造中。
    * 現状、C,C++,HTML,CSS,Markdown,Pythonといった自分のよく使う言語にはほとんど対応済みで、本家とほぼ同じ色描画がなされる。
        * 自分が普段使いできるレベルに綺麗・実用的なので是非試してみてほしい。
        * 他の言語にはまだまだ対応していないので、気に入られた方でvimに詳しい人はPRしてくださると助かります。
    * 解説記事？は[こちら](/2019/01/flatwhite%E3%82%92vim%E3%81%AB%E7%A7%BB%E6%A4%8D%E3%81%97%E3%81%9F%E5%AE%8C%E6%88%90%E3%81%97%E3%81%9F%E3%81%A8%E3%81%AF%E8%A8%80%E3%81%A3%E3%81%A6%E3%81%AA%E3%81%84/)
* 自作Cコンパイラ[wdcc](https://github.com/woodyZootopia/woodycc)（つくりかけだけど[記事を書いた](/2019/01/c%E9%A2%A8%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%A9%E3%82%92%E8%87%AA%E4%BD%9C%E3%81%97%E3%81%9F/)よ！）
    * 鮟鱇さん([@ushitora_anqou](https://twitter.com/ushitora_anqou))を始めとするセキュキャン2018でCコンパイラを書いてた人々が羨ましくなったので作り始めた。
    * Ruiさんの[解説記事](https://www.sigbus.info/compilerbook/)と鮟鱇さんの[有用な資料をまとめた記事](https://anqou.net/poc/2019/01/03/post-2650/)に大いに助けられている。
    * あと困ったことをTwitterに投げてるとよく返信をくれるhsjoihsさん([@hsjoihs](https://twitter.com/hsjoihs))すごくいい人。皆さん有難うございます。


# 使用プログラミング言語
* Pythonをよく使う。特に、scikit-learn, TensorFlow, Keras, PyTorchといったライブラリを用いた機械学習が得意。\
PandasやMongoDBといったデータ処理用のライブラリも使ったりする。\

* C,C++も好き。低レベルに触るときなどに書く。\

* LaTeXに触ったことがある。クラスファイルを自作できるくらい。\

* HTML,CSS,JavaScriptの文法がわかる。1からウェブページを作るのは骨が折れるが、すでにあるサイトを軽く修正したりすることができる。

* Gitでバージョンをいじりながら開発できる。上の[作ったもの](#作ったもの)は全てGitでバージョン管理している。

* 簡単なbash/zshシェルスクリプトを書ける。このホームページのデプロイ・バックアップ・画像の軽量化・ローカルテストサーバー設定等はシェルスクリプトで自動化されている。

* Vim Scriptの文法がわかる。
[Shougo](https://github.com/Shougo)さんのVimプラグインが心底お気に入りなので最近[Defx.nvim](https://github.com/Shougo/defx.nvim)のcontributerになった。

# 略歴
* 地元の公立中、広島大学附属高等学校卒
    * 高校はSSHだったのでいろいろ研究をさせてもらえた。
        * ルービックキューブに関する論文を書いて京大で発表したり
        * タイ(TJSSF 2015)で水の浄化に関してポスター発表をしたり
    * JOI2015/2016本選に出てた。
* 2017/4より京都大学工学部電気電子工学科
    * 京都大学ではESS（英語ディベート）および人工知能研究会(KaiRA)に所属。
        * なので英語をちょっと話せる（TOEFL iBTで106とか）
    * 2018/8まで8ヶ月間、画像認識を専門とするベンチャーである[Rist](https://www.rist.co.jp/)でAIプログラマ
        * 詳しくは（たぶん企業秘密なので）書けないが、機械のログから異常のあった時刻を抜き出したり、CNNをつかって異物認識をするプログラムを書いたりしてた。
        * Ristはその実績を買われたらしく[京セラの子会社になった](https://prtimes.jp/main/html/rd/p/000000098.000009956.html)。
        * 気のいい人たちばかりで、とてもいい会社だった。
* 2018/9よりUniversity of Waterlooに京都大学からの交換留学により派遣(2019/4まで、８ヶ月間)
    * 留学に際して[フクシマグローバル人材支援財団](https://www.fukushima-global.or.jp/index.html)から奨学金を頂いている。自分は１期生らしい。
        * 関西圏を中心とした特定大学の人のみなど条件が厳しいが、そのことにより倍率がそこまで高くならないことが予想されること、面接会場も大阪であり多くの人にとって金銭的負担が少ないことから、応募できる権利のある人にはおすすめな奨学金である。
    * 2018/11よりUWaterlooの自動運転車プロジェクト[WATonomous](https://watonomous.ca)でFPGA Core Engineer
    * 2018/12より[KIMIA Lab](http://kimia.uwaterloo.ca) Undergraduate Research Assistant
* 工学が好きで、その中でも特に情報・電子・コンピュータに幅広く興味がある。
    * 最近でいうと統計、機械学習、画像処理、音声信号処理、CV、コンピュータネットワーク、低レイヤ実装などなど気の向くまま無節操に手を出している。

[マシュマロやってます](https://marshmallow-qa.com/woody_egg?utm_medium=url_text&utm_source=promotion)
