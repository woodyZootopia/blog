---
title: "電卓を作ってみよう"
date: 2019-01-02T22:34:07-05:00
description: "要求スペックに従ってガリガリ実装する練習。"
# banner:"/img/some.png"
# lead: "Example lead - highlighted near the title"
# disable_comments: true # Optional, disable Disqus comments if true
disable_profile: true # no one wants to see my profile while reading articles
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
categories:
  - "技術"
  - "数学"
tags:
  - "C"
  - "shell"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

冬休みでしばらく暇なので、言語処理系を書いてみたいなという企画。\
今回はCで簡単な電卓プログラムを書いてみたので作り方含め公開。
なお、実装にあたってはRui UeyamaさんのYoutubeビデオ\
<iframe width="560" height="315" src="https://www.youtube.com/embed/JAtN0TGrNE4" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe> \
と友人のスライド\
https://speakerdeck.com/anqou/10sutetupudezuo-ruoshou-qing-intapuritakai-fa?slide=13 \
を大いに参考にした。有難うございます。\
友人のスライドのほうが正直わかりやすいが気にしたら負け。

コードは https://github.com/woodyZootopia/simplecalculator/commits/master \
にあげている。

# 雛形を書く

`main`で引数の処理をして、`eval`に文字列を渡すと計算してくれる。

```C
#include <stdio.h>
int main(int argc, char **argv) {
  p=argv[1];
  if(argc!=2){
  printf("input not one\n");
  return 0;
  }
  while(*p) printf("%d\n",eval());
  return 0;
}
```

`eval`はこんな感じ。

```C
static int eval() {
  p++;
  return 0;
}
```
もちろん、これは何も計算していないハリボテ。こっから`eval`を埋めていくのが仕事になる。

なお、`runtest`というファイルを作っておくと一発でデバッグできて便利。

```bash
#!/bin/bash

gcc -std=c11 -o calc calc.c

runtest() {
  output=$(./calc "$1")
  if [ "$output" != "$2" ]; then
    echo "$1 => $2 expected, but got $output"
    exit 1
  fi
  echo "$1 => $output"
}

runtest 0 0
```

# 位を実装する

`argv`は`char`で扱われているので、複数桁の数字は文字列として扱われている。というわけで２桁以上の入力があれば１０倍しながら後に追加していけばよい。

```C
#include <ctype.h>
static int eval() {
  if(isdigit(*p)) {
    int val = *p-'0';
    p++;
    while(isdigit(*p)) {
      val = val*10 + *p-'0';
      p++;
    }
    return val;
  }
  p++;
  return 0;
}
```

testも適宜増やしていこう。
```bash
runtest 1 1
runtest 2 2
runtest 810 810
runtest 114514 114514
```

## スペースを読み飛ばす

`" 3"`のようにスペース付きの入力が来た場合に備え、読み飛ばすようにしておく。
```C
static int skipspace(){
  while(isspace(*p)) p++;
  return 0;
}

static int eval() {
  skipspace();
  if(isdigit(*p)) {
...
```
これは後々便利。

# 足し算を実装する

足し算は、\
$3 + 43 + 5 + ... + 2$\
ならば\
$3\ (+ 43)\ (+ 5)\ (+ ...\ (+ 2)$\
と構文解釈できるので実装するだけ。

```C
static int skipspace(){
  while(isspace(*p)) p++;
  return 0;
}

static int evalint() {
  int val = *p-'0';
  p++;
  while(isdigit(*p)) {
    val = val*10 + *p-'0';
    p++;
  }
  return val;
}

static int eval() {
  skipspace();
  if(isdigit(*p)) {
    int val = evalint();
    skipspace();
    while(p == '+') {
      p++;
      skipspace();
      val += evalint();
      skipspace();
    }
    return val;
  }
  p++;
  return 0;
}
```

# 四則演算を実装する
ここから参考にさせてもらった鮟鱇さんの実装とちょっと別れる。
`evalint`を「数字ごとに評価する関数」から自然に拡張して「**項ごとに評価する関数**」と捉える。項は数字だけじゃなくて掛け算割り算を含むかもしれないので、場合分けしてやる。

```C
static int evalint() {
  int val;
  while(isdigit(*p) || *p == '*' || *p == '/') {
    switch (*p) {
      case '*':
        break;
      case '/':
        break;
      default:
        val = *p-'0';
        p++;
        while(isdigit(*p)){
          val = val*10 + *p-'0';
          p++;
        }
    }
    skipspace();
  }
  return val;
}
```
場合分けしただけなので、これに掛け算か割り算の入った入力文字列を入れると実行すると固まる。場合分け処理も書くと、
```C
    ...
    switch (*p) {
      case '*':
        p++;
        skipspace();
        val*=evalint();
        break;
      case '/':
        p++;
        skipspace();
        val/=evalint();
        break;
      default:
      ...
```

これで完成。
こう書くと鮟鱇さんのより実装が短くなるが、一つの項に含まれる掛け算・割り算の数だけ関数が再帰呼び出しされるので$O(n)$でスタックが溜まりオーバーフローの原因になる。まあこれはお試しプログラムなのでご愛嬌。

引き算の実装はもっと簡単だし省略。ｲｲｶﾝｼﾞにしてください。

# 引数なしの関数定義・呼び出しを実装する
次の書式で関数を定義できるようにする。
```sh
runtest "P()" 0
runtest "F{1}F()" 1
runtest "F{4*5}F()" 20
runtest "F{4*5} F()*F()" 400
```

関数も項なので、`evalint`で評価するように拡張。`F(`までを評価して、`eval`を呼び、`)`を読めばいい。\
ここまで来ると`evalint`じゃなくて`evalterm`のほうが良かった気がしてくるが面倒なのでこのまま突っ走ろう。
とりあえず場合分けだけ書くと
```c
static int evalint() {
    int val=0;
    while(isdigit(*p) || *p == '*' || *p == '/' || isupper(*p)) {
        if (*p == '*') {
            p++;
            skipspace();
            val*=evalint();
        }
        else if (*p == '/') {
            p++;
            skipspace();
            val/=evalint();
        }
        else if (isupper(*p)) {
            /* do something */
        }
        else {
            val = *p-'0';
            p++;
            while(isdigit(*p)){
                val = val*10 + *p-'0';
                p++;
            }
        }
        skipspace();
    }
    return val;
}
```
あとは場合分けの処理を書けば良い。上で`/* do something */`になってるところを
```c
else if (isupper(*p)) {
    int funcid=*p-'A';
    p++;
    skipspace();
    if(*p == '{') {
        int i;
        p++;
        skipspace();
        for(i=0;*p!='}';p++,i++){
            funcbuf[funcid][i]=*p;
        }
        funcbuf[funcid][i+1]='\0'; // 同じ関数が複数回定義されたときのために終端文字で埋めておく
        p++;
        skipspace();
    }
    else if(*p == '(') {
        char* tmp = p;
        p=funcbuf[funcid];
        val=eval();
        p=tmp+1;
        skipspace();
        p++;
        skipspace();
    }
}
```
と追記する。

# 引数ありの関数定義・呼び出しを実装する
とりあえず引数は一つだけにし、`.`で代入できるというライブコーディング動画と同じ仕様にする。
例えばこう。
```sh
runtest "P(1)" 0
runtest "F{.}F(1+2+3)" 6
runtest "F{.*.}F(2)*F(3)" 36
runtest "F{.*.+.}F(2)" 6
```
上のコードで`F()`をパースしている部分（後半の`else if(*p == '(')`）をいじってやればいい。
`.`が入力されたときにも対応できるよう分岐。

```c
// argはグローバル変数として宣言しておく
    ...
    else if(*p == '(') {
        p++;
        skipspace();
        if (*p != ')'){
            int argbuf=arg;
            arg=eval();
            char* tmp=p;
            p=funcbuf[funcid];
            val=eval();
            p=tmp;
            arg=argbuf;
            p++;
            skipspace();
        }
        else {
            char* tmp=p;
            p=funcbuf[funcid];
            val=eval();
            p=tmp;
            skipspace();
            p++;
            skipspace();
        }
    }
}
else if (*p == '.') {
    val = arg;
    p++;
    skipspace();
}
...
```

## 2個以上の引数を使えるようにする
2個以上と言っても実装が面倒なのでアルファベット小文字一文字、つまり26個までとする。\
前節の`arg`を配列で書き換えてやればよい。\

なお、testも次のように書き換えてやる必要がある。
```
runtest "F{a}F(1)" 1
runtest "F{a}F(1+2+3)" 6
runtest "F{a*a}F(2)*F(3)" 36
runtest "F{a*a+a}F(2)" 6
runtest "F{a*a+b}F(3,2)" 11
```

# 複数の式を実行できるようにする

式全体の戻り値は最後の式の値になるようにする。
```
runtest "10+2;3;3*7" 21
```
複数の項にまたがる文法の解釈なので、`eval`を書き換えればよい。[^mendoi]
[^mendoi]:このへんからソースコードを置くのがめんどくさくなってきている。githubを参照してくれい。

# Print関数を作る
Print関数は一つの式を引数にとりその値を標準出力に返すものとする。`?`で書き、戻り値は０。
```
runtest "?(1)" 1 0
```

# 遊びましょ！遊びます！

なーに 簡単な 数字のゲームさ!
```
./calc "F{a*a+b}P{a*a*a}F(3,P(30))"
```
```
27009
```
さあ お次は 「**フィボナッチ数列**」の 時間ですッ！
```
./calc "F{?(a);F(b,a+b)}F(1,1)" | head -n 10
```
```
1
1
2
3
5
8
13
21
34
55
```
ああああ\
楽 し す ぎ！
```
./calc "F{?(a);F(2*a)}F(1)" | head -n 10
```
```
1
2
4
8
16
32
64
128
256
512
```

**な ん で も で き る！**

# 感想
* 何でもできる。
* `skipspace()`めちゃ使う。
* 一個一個プチプチバグを潰して・機能を増やしながらインクリメンタルにやっていくの楽しい。
* gdb便利。
* カッコは対応してないけど関数呼び出しを駆使すればなんとかなるので省略。ライブコーディングみたいなポーランド記法仕様にするとカッコいらなくなるし。
* 難しそうに見えるがやるだけ。みんなもやろう。
