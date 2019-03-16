---
title: "大学の空き教室を自動で算出してくれるプログラムを書いた"
date: 2018-12-01T18:35:04-05:00
description: "ウェブスクレイピングの基礎の参考にもなります"
# thumbnail: "img/placeholder.jpg" # Optional, thumbnail
# lead: "Example lead - highlighted near the title"
# disable_comments: false # Optional, disable Disqus comments if true
disable_profile: true # no one wants to see my profile while reading articles
# authorbox: true # Optional, enable authorbox for specific post
# mathjax: true # Optional, enable MathJax for specific post
categories:
  - "技術"
tags:
  - "python"
  - "web scraping"
# menu: main # Optional, add page to a menu. Options: main, side, footer
---

# やりたいこと
大学において、静かな部屋というのには様々な利用法があります。\
サークル活動をするもよし、静かに自習するもよし。\
特に、試験前は図書館が混み合うためとても便利です。

しかし、多くの場合どこの教室が空いているかわからなかったり、\
せっかく空いていると思って勉強を始めても次の授業で使う予定になっていたりして退出しなければならないことがままあります。

大学の公式ウェブサイトから空き教室を算出するプログラムを書けないものか。

簡単に書けます。書きましょう。

# 使うもの
僕が得意なのでPythonで書きます。\
定番のbeautifulsoup4とseleniumを使います。beautifulsoup4はhtmlをパースしてくれ、seleniumはウェブブラウザを自動で走らせてくれるのでとても便利です。\
あと、tqdmは自動でプログレスバーを出してくれるので、実行時間の長いプログラムを走らせるときはキチンと動いていることが確認できて便利です。
```Python
from pathlib import Path
import json
import sys
from bs4 import BeautifulSoup
from selenium import webdriver
from time import sleep
from tqdm import tqdm
import re
```

# やりかた
必要なライブラリをインストールしましょう。あと、seleniumはchromeとかのドライバを同じフォルダに入れていないと動かないので注意してください。
完全なコードは
https://github.com/woodyZootopia/KUEmptyClassroom
にあげてあるので参考にしてください。

## ブラウザを走らせてログインする
ここ以降は各大学のウェブページごとに仕様が違うと思うので、各自いい感じにしてください。

ログイン状態を保持したままいろいろしたいので、クラスにするのがいいでしょう。
```python
class KUWebDriver():

    def __init__(self):
        # login process
        with open("id_and_pass.json") as f:
            login_info = json.load(f)
        self.login_url = "https://www.k.kyoto-u.ac.jp/student/la/top"
        options = webdriver.ChromeOptions()
        options.add_argument('--headless')
        options.add_argument('--disable-gpu')
        options.add_argument('--no-sandbox')
        options.add_argument('--window-size=1200x600')
        self.driver = webdriver.Chrome(
            "./chromedriver", chrome_options=options)

        login_url = "https://www.k.kyoto-u.ac.jp/student/la/top"
        self.driver.get(login_url)
        self.driver.find_element_by_id(
            "username").send_keys(login_info["KU_ecs_ID"])
        self.driver.find_element_by_id("password").send_keys(
            login_info["KU_ecs_PASSWORD"])
        self.driver.find_element_by_name("_eventId_proceed").click()

    def quitDriver(self):
        self.driver.quit()

```
なお、きちんと使用後はquitするようにしないと使い終わったウェブブラウザが残って邪魔です。

あと、id_and_pass.jsonはこんな感じで：
```json
{
  "KU_ecs_ID":"my_id",
  "KU_ecs_PASSWORD":"my_password"
}
```
コードを誰かと共有するときのために、パスワードは別ファイルから読み込む形式にしておいたほうがいいでしょう。\
共有するときに消せばいいや、と思ってて消し忘れたらシャレになりません。

## スクレイピングする
先程のクラスに次の関数も追加します。
```python
    def fetchAllLASyllabusData(self, wait_sec=1):
        for k in tqdm(range(305)):
            self.driver.get("https://www.k.kyoto-u.ac.jp/student/la/syllabus/detail?condition.courseType=&condition.seriesName=&condition.familyFieldName=&condition.lectureStatusNo=1&condition.langNum=&condition.semester=&condition.targetStudent=0&condition.courseTitle=&condition.courseTitleEn=&condition.teacherName=&condition.teacherNameEn=&condition.itemInPage=10&condition.syutyu=false&condition.lectureCode=&page="+str(k))
            with open("./data/syllabus/LA/"+str(k)+".html", 'w') as f:  # 0-indexed
                f.write(self.driver.page_source)
            sleep(1)
```
アドレスを生で貼ってるので長くなってますが、気にしないでください。ミソは一番右端の```str(k)```です。\
for文をつかってページを遷移し、その内容を片端から保存していくわけですね。\
あまりガンガンアクセスするとサーバーに負担がかかるので、sleepで１秒待ってからアクセスするようにします。\
Webサーバは沢山の人がアクセスしてるし、誰かが一秒に一回アクセスしたところでそこまで迷惑にはならないので、基本的に怒られることはないでしょう。
[ん？誰か来たようだ……](https://ja.wikipedia.org/wiki/岡崎市立中央図書館事件)

今回のクラスの場合、こういう感じで実行できます↓
```python
driver = KUWebDriver()
driver.fetchAllLASyllabusData()
driver.quitDriver()
```

## パースする
というわけでウェブサイトの中身が手に入ったので、変換していきましょう。
といっても、これこそ各ウェブサイトごとに全く異なります。参考になるかわかりませんが一応該当部分のコード片を貼っておくので、各自いい感じにしてください。
```python
non_space_finder = re.compile("\S")
for html_doc in sorted(Path(path).glob("*.html")):
    with open(html_doc, 'r') as html_file:
        soup = BeautifulSoup(html_file, 'html5lib')
        for item in soup.body.div.div.find("div", id="wrapper").find("div", class_="contents")("center", recursive=False)[1].find_all("table", border="1"):

            # 曜時限
            classtime = item.tbody.find_all("tr", recursive=False)[5].tr(
                "td", recursive=False)[1].span.contents[0]
            m = re.search(non_space_finder, classtime)
            classtimelist = self.listofclasstime(classtime[m.start():])
```
なお、pathは先程保存した```./data/syllabus/LA/```です。

BeautifulSoupのドキュメントも参考になると思います。\
https://www.crummy.com/software/BeautifulSoup/bs4/doc/#quick-start

注意点としては、

- find_allはデフォルトでは再帰的に中身まで全部見ちゃうので、直下のタグだけ探したい場合は```recursive=False```をつける
- soup.bodyみたいにすると、一番最初に見つかるbodyタグのことになります
- classはpythonの予約語なので、htmlのクラスを指定したいときはclass_にする
- find_allの代わりにいきなりカッコを付ける事もできます
- find_allの結果は配列になっているのでforを回しましょう

とかです。

というわけでこれを使うと大学の空き教室を抽出できるので、あとはデータベースにでも格納してやればオッケーですね。\

再掲しますが完全なコードを\
https://github.com/woodyZootopia/KUEmptyClassroom \
ここに貼ってるので参考にすると速いと思います。

お疲れ様でした。
