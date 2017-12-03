  ﻿
# Tooltip Helper (Rebuild by Toukibi)  
Scroll down for [English Version](#description-of-english-version) description.

### 1.これは何？
ツールチップに追加の情報を表示します。  
![Tooltip Helperのイメージ](https://github.com/Toukibi/ToSAddon/raw/ForImage/TooltipHelper_Rebuild/img/topimage_s_ja.jpg?raw=true)
### 2.できること
* ツールチップに次の項目を追加表示します  
  * 使用するコレクションを列挙
  * 使用するアイテム製作を列挙
  * マグナムオーパスの変換元・変換先の表示
  * 冒険日誌での目標取得数と現在取得数の表示
  * アイテムドロップ率の表示 <span style="color:red;">(**IToSのみ**)</span>
  * NPC修理と修理露店のどちらの修理が安いかを表示 (要価格設定)
* マグナムオーパスの内蔵情報が古くなったときに備えて、外部の`recipe_puzzle.xml`ファイルからのデータ読み込みに対応
* 設定画面の実装で、視覚的な設定変更
* アイテム製造は作成経験の有無でグループ化
* マグナムオーパスは変換先のアイテムの配置も表示

<span style="color:red;">**※注意※**</span>  
基本的には原作のTooltip Helperに準拠していますが、次の機能は現在<span style="color:red;font-weight:bold">使用できません</span>。
* Marketneerとの連携
* アイテムレベルの表示 (廃止されたため)
* 装備の★の数の表示

### 3.使用可能なコマンド一覧
基本のコマンドは **`/tth`** です。  
パラメータ無しでコマンドを入力すると設定画面が開きます。

|コマンド|効果|
|---|---|
|/tth|設定画面を開く|
|/tth reset|設定リセット|
|/tth jp|日本語に切り替え|
|/tth en|英語に切り替え|
|/tth xx|xx に英語2文字を入れる<br>その言語に切り替え|
|/tth ?|チャットログにヘルプを表示|

**英語と日本語以外を使うには**：  
他の言語モードを使えるようにするには、該当する言語のテキストリソースをプログラムソースに追記する必要があります。

### 4.導入方法
このアドオンは、アドオンマネージャJPに登録しています。  
アドオンマネージャJPを用いて導入してください  

### 5.詳しい使い方
Wikiを作成中です。こちらを参照してください。  
[Tooltip Helperのヘルプ](https://github.com/Toukibi/ToSAddon/wiki/Tooltip-Helpeer)  

---
## Description of English Version 
  
**Notice**: This add-on has **English display mode**.  
You can switch to English display mode by using command **`/tth en`**  
### What is this?
This add-on will display additional information in the tooltip.  
![Image of customized tooltip view](https://github.com/Toukibi/ToSAddon/raw/ForImage/TooltipHelper_Rebuild/img/topimage_s_en.jpg?raw=true)

### Features.
* Add the following items to the tooltip.
  * Enumerate collections to use.
  * Enumerate item production required as material.
  * Magnum Opus conversion source / conversion destination.
  * Target acquisition number and current acquisition number in adventure logbook.
  * Item drop ratio. <span style="color:red;">(**only IToS**)</span>
  * NPC and repair stalls, which repair is cheap. (price setting required)
* Supports reading data from an external `recipe_puzzle.xml` file in case the built-in information of Magnum Opus becomes out-of-date.
* Implementation of setting screen realizes visual setting change.
* Item production is grouped based on creation experience.
* Magnum Opus also displays the placement of the destination item.

<span style="color:red">**Caution**</span>  
Basically it conforms to the original Tooltip Helper, but the following functions are <span style="color:red;font-weight:bold">not currently available</span>.
* Collaboration with Marketneer.
* Display item-level. (for obsolete)
* Display of the number of star marks of equipment items.

### Installation Instructions.
Install via the Addon Manager. Leave bug reports and other issues on my Github page.

### Settings.
Settings can be accessed by Slash Command **`/tth`**, and via these Slash Commands.

|Paramater|What happens result|
|---|---|
|/tth|Display options|
|/tth reset|Reset the all settings.|
|/tth jp|Switch to Japanese mode.|
|/tth en|Switch to English mode.|
|/tth xx|Insert two English letters in xx<br>(ccTLD or language code recommended)<br>Switch to Other Language mode.|
|/tth ?|Display the help-text to chat-log.|

<span style="color:red;">**In order to use language other than English and Japanese**</span>:  
In order to use **Other Language** mode, you need to **add a text resource to the program source**.

### Detailed usage
It is summarized in a wiki. Please see here.  
[How to use Tooltip Helper](https://github.com/Toukibi/ToSAddon/wiki/Tooltip-Helpeer)  
=======
﻿# Tooltip Helper (Rebuild by Toukibi)
Scroll down for [English Version](#description-of-english-version) description.

### 1.これは何？
ツールチップに追加の情報を表示します。  
![Tooltip Helperのイメージ](https://github.com/Toukibi/ToSAddon/raw/ForImage/TooltipHelper_Rebuild/img/topimage_s_ja.jpg?raw=true)
### 2.できること
* ツールチップに次の項目を追加表示します  
  * 使用するコレクションを列挙
  * 使用するアイテム製作を列挙
  * マグナムオーパスの変換元・変換先の表示
  * 冒険日誌での目標取得数と現在取得数の表示
  * アイテムドロップ率の表示 <span style="color:red;">(**IToSのみ**)</span>
  * NPC修理と修理露店のどちらの修理が安いかを表示 (要価格設定)
* マグナムオーパスの内蔵情報が古くなったときに備えて、外部の`recipe_puzzle.xml`ファイルからのデータ読み込みに対応
* 設定画面の実装で、視覚的な設定変更
* アイテム製造は作成経験の有無でグループ化
* マグナムオーパスは変換先のアイテムの配置も表示

<span style="color:red;">**※注意※**</span>  
基本的には原作のTooltip Helperに準拠していますが、次の機能は現在<span style="color:red;font-weight:bold">使用できません</span>。
* Marketneerとの連携
* アイテムレベルの表示 (廃止されたため)
* 装備の★の数の表示

### 3.使用可能なコマンド一覧
基本のコマンドは **`/tth`** です。  
パラメータ無しでコマンドを入力すると設定画面が開きます。

|コマンド|効果|
|---|---|
|/tth|設定画面を開く|
|/tth reset|設定リセット|
|/tth jp|日本語に切り替え|
|/tth en|英語に切り替え|
|/tth xx|xx に英語2文字を入れる<br>その言語に切り替え|
|/tth ?|チャットログにヘルプを表示|

**英語と日本語以外を使うには**：  
他の言語モードを使えるようにするには、該当する言語のテキストリソースをプログラムソースに追記する必要があります。

### 4.導入方法
このアドオンは、アドオンマネージャJPに登録しています。  
アドオンマネージャJPを用いて導入してください  

### 5.詳しい使い方
Wikiを作成中です。こちらを参照してください。  
[Tooltip Helperのヘルプ](https://github.com/Toukibi/ToSAddon/wiki/Tooltip-Helpeer)  

---
## Description of English Version 
  
**Notice**: This add-on has **English display mode**.  
You can switch to English display mode by using command **`/tth en`**  
### What is this?
This add-on will display additional information in the tooltip.  
![Image of customized tooltip view](https://github.com/Toukibi/ToSAddon/raw/ForImage/TooltipHelper_Rebuild/img/topimage_s_en.jpg?raw=true)

### Features.
* Add the following items to the tooltip.
  * Enumerate collections to use.
  * Enumerate item production required as material.
  * Magnum Opus conversion source / conversion destination.
  * Target acquisition number and current acquisition number in adventure logbook.
  * Item drop ratio. <span style="color:red;">(**only IToS**)</span>
  * NPC and repair stalls, which repair is cheap. (price setting required)
* Supports reading data from an external `recipe_puzzle.xml` file in case the built-in information of Magnum Opus becomes out-of-date.
* Implementation of setting screen realizes visual setting change.
* Item production is grouped based on creation experience.
* Magnum Opus also displays the placement of the destination item.

<span style="color:red">**Caution**</span>  
Basically it conforms to the original Tooltip Helper, but the following functions are <span style="color:red;font-weight:bold">not currently available</span>.
* Collaboration with Marketneer.
* Display item-level. (for obsolete)
* Display of the number of star marks of equipment items.

### Installation Instructions.
Install via the Addon Manager. Leave bug reports and other issues on my Github page.

### Settings.
Settings can be accessed by Slash Command **`/tth`**, and via these Slash Commands.

|Paramater|What happens result|
|---|---|
|/tth|Display options|
|/tth reset|Reset the all settings.|
|/tth jp|Switch to Japanese mode.|
|/tth en|Switch to English mode.|
|/tth xx|Insert two English letters in xx<br>(ccTLD or language code recommended)<br>Switch to Other Language mode.|
|/tth ?|Display the help-text to chat-log.|

<span style="color:red;">**In order to use language other than English and Japanese**</span>:  
In order to use **Other Language** mode, you need to **add a text resource to the program source**.

### Detailed usage
It is summarized in a wiki. Please see here.  
[How to use Tooltip Helper](https://github.com/Toukibi/ToSAddon/wiki/Tooltip-Helpeer)  
>>>>>>> 1f7c9fdae12f056d4b64601cbe4c5a2b13b880da:tooltiphelper_toukibi/README.md
