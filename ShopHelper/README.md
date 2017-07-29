# Shop Helper

This add-on will tell you whether the price of buff/repair/etc. is  expensive or cheap.  

Scroll down for [English Version](#description-of-english-version) description.

---
## Description of Japanese Version 
#### これは何？
街などで開かれている露店の価格が高いか安いかをコメントしてくれます。  
![alt text](https://github.com/Toukibi/ToSAddon/blob/forImageStrage/ShopHelper/img/repair_jp.png?raw=true "Image of stall of item repair")
![alt text](https://github.com/Toukibi/ToSAddon/blob/forImageStrage/ShopHelper/img/buff_jp.png?raw=true "Image of stall of buff")
![alt text](https://github.com/Toukibi/ToSAddon/blob/forImageStrage/ShopHelper/img/option_jp.jpg?raw=true "Image of option screen")

#### できること
* 原価を表示し、原価との比較結果を表示
* 平均値との比較(まだ実装していないため、作者の独断と偏見の平均値が入っています)
* 高いか安いかを一言メモと色で知らせます
* 異常に高い値段には警告マークを付与します
* 平均値は移動平均を使用することができます
* Altキーを押している間だけプレイヤーを非表示にします
* 気に入った露店にはマークを、気に入らない露店は非表示にできます
* 気に入った露店に「いいね」が簡単にできます

#### 使用可能なコマンド一覧
基本のコマンドは **`/sh`** または **`/shophelper`** です  

|コマンド|効果|
|---|---|
|/sh|設定画面を開く|
|/sh reset|平均値をリセット|
|/sh resetall|平均値と設定をリセット|
|/sh jp|日本語に切り替え|
|/sh en|英語に切り替え|
|/sh kr|韓国語に切り替え|
|/sh br|ポルトガル語に切り替え|
|/sh xx|xx に英語2文字を入れる<br>その言語に切り替え|
|/sh ?|チャットログにヘルプを表示|

**英語と日本語以外を使うには**：  
他の言語モードを使えるようにするには、該当する言語のテキストリソースをプログラムソースに追記する必要があります。

#### 導入方法
このアドオンは、アドオンマネージャJPに登録しています。  
アドオンマネージャJPを用いて導入してください  

---
## Description of English Version 
#### What is this?
This add-on will tell you whether the price of buff/repair/etc. is  expensive or cheap.  
![alt text](https://github.com/Toukibi/ToSAddon/blob/forImageStrage/ShopHelper/img/repair_en.jpg?raw=true "Image of stall of item repair")
![alt text](https://github.com/Toukibi/ToSAddon/blob/forImageStrage/ShopHelper/img/buff_en.jpg?raw=true "Image of stall of buff")
![alt text](https://github.com/Toukibi/ToSAddon/blob/forImageStrage/ShopHelper/img/option_en2.jpg?raw=true "Image of option screen")

#### Features.
* Display cost of shop items and display comparison result with cost
* Comparison with average value.
* Tell you whether it is expensive or cheap by colord text.
* You add marks to your favorite stalls and you can hide the signboards that you do not like.
![alt text](https://github.com/Toukibi/ToSAddon/blob/forImageStrage/ShopHelper/img/signboards_en.png?raw=true "Image of signboard")
* You can easily "like you" to your favorite stalls.  
![alt text](https://github.com/Toukibi/ToSAddon/blob/forImageStrage/ShopHelper/img/contextmenu_en.jpg?raw=true "Image of right-click menu")
* Give a warning mark to abnormally high prices such as fraud stalls.  
![alt text](https://github.com/Toukibi/ToSAddon/blob/forImageStrage/ShopHelper/img/ripoff_en.png?raw=true "Image of warning for rip-off")
* Average price can use moving average.
* While holding down the Alt key, you can hide the names of other characters. (useful when choosing NPC in crowded)

#### Installation Instructions.
Install via the Addon Manager. Leave bug reports and other issues on my Github page.

#### Settings.
Settings can be accessed by Slash Command **`/sh`**, and via these Slash Commands.

|Paramater|What happens result|
|---|---|
|/sh|Display options|
|/sh reset|Reset the average price settings.|
|/sh resetall|Reset the all settings.|
|/sh jp|Switch to Japanese mode.|
|/sh en|Switch to English mode.|
|/sh kr|Switch to Korean mode.|
|/sh br|Switch to Portuguese mode.|
|/sh xx|Insert two English letters in xx<br>(ccTLD or language code recommended)<br>Switch to Other Language mode.|
|/sh ?|Display the help-text to chat-log.|

<span style="color:red;">**In order to use language other than English and Japanese**</span>:  
In order to use **Other Language** mode, you need to **add a text resource to the program source**.
