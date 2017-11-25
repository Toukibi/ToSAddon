# Experience Viewer Ex
Scroll down for [English Version](#description-of-english-version) description.
![ExpViewerの外観](https://github.com/Toukibi/ToSAddon/blob/ForImage/ExpViewer_Ex/img/topimage_ja.jpg?raw=true)

### 1.これは何？
経験値に関する情報を表示します。  

### 2.できること
* 経験値に関する次の情報を表示します。  
  * 現在値/要求値とその割合
  * 最終取得経験値
  * 1時間あたりの取得経験値の予測値
  * レベルアップまでの必要討伐数
  * レベルアップまでの所要時間の予測値
* 所持金の情報(現在値・1時間あたりの予測取得量・最終取得量)を表示
* 5分あたりの取得量から1時間あたりの取得予測を行います(設定で切替可能)
* 一定時間討伐を行わなかった場合、討伐再開時に自動的にリセットを行います(設定で切替可能)
* 単位表示を用いることで表示を短くできます(設定で切替可能)

### 3.使用可能なコマンド一覧
基本のコマンドは **`/expv`** です。  
パラメータ無しでコマンドを入力すると設定画面が開きます。

|コマンド|効果|
|---|---|
|/expv reset|計測をリセット|
|/expv update|表示を強制更新|
|/expv jp|日本語に切り替え|
|/expv en|英語に切り替え|
|/expv xx|xx に英語2文字を入れる<br>その言語に切り替え|
|/expv ?|チャットログにヘルプを表示|

**英語と日本語以外を使うには**：  
他の言語モードを使えるようにするには、該当する言語のテキストリソースをプログラムソースに追記する必要があります。

### 4.導入方法
このアドオンは、アドオンマネージャJPに登録しています。  
アドオンマネージャJPを用いて導入してください  

### 5.詳しい使い方
Wikiを作成中です。こちらを参照してください。  
[Tooltip Helperのヘルプ](https://github.com/Toukibi/ToSAddon/wiki/Experience-Viewer)  

---
## Description of English Version 
  
**Notice**: This add-on has **English display mode**.  
You can switch to English display mode by using command **`/tth en`**  
### What is this?
This add-on will display all sorts of information about your character's experience.  
![Image of ExpViewer](https://github.com/Toukibi/ToSAddon/blob/ForImage/ExpViewer_Ex/img/topimage_en.jpg?raw=true)

### Features.
* Displays the following information about experience values.  
  * Current value / required value and its ratio
  * Final acquisition experience value
  * Predicted value of acquisition experience value per hour
  * Required number of subjugation until level up
  * Estimated time required to level up
* Displays information on current money (present value, predicted acquisition amount per hour, final acquisition amount)
* Predict acquisition per hour from acquisition amount per 5 minutes (switchable by setting)
* In case of not being suppressed for a certain period of time, it will automatically reset at the time of restarting prosecution (switchable by setting)
* You can shorten the display by using metric prefix (switchable by setting)


### Installation Instructions.
Install via the Addon Manager. Leave bug reports and other issues on my Github page.

### Settings.
Settings can be accessed by Slash Command **`/expv`**, and via these Slash Commands.

|Paramater|What happens result|
|---|---|
|/tth reset|Reset session.|
|/tth|Force update display.|
|/tth jp|Switch to Japanese mode.|
|/tth en|Switch to English mode.|
|/tth xx|Insert two English letters in xx<br>(ccTLD or language code recommended)<br>Switch to Other Language mode.|
|/tth ?|Display the help-text to chat-log.|

<span style="color:red;">**In order to use language other than English and Japanese**</span>:  
In order to use **Other Language** mode, you need to **add a text resource to the program source**.

### Detailed usage
It is summarized in a wiki. Please see here.  
[How to use Tooltip Helper](https://github.com/Toukibi/ToSAddon/wiki/Experience-Viewer)  

