
# Map Mate
Description of [English Version is Here](#description-of-english-version).
### 1.これは何？
マップ表示を色々便利にしてくれます。  
(現在はミニマップに追加情報を表示するだけ)  
![改良されたミニマップ表示](https://github.com/Toukibi/ToSAddon/blob/ForImage/MapMate/image/MapMate_MiniMap.png?raw=true)
### 2.できること
* ミニマップに次の項目を追加表示します  
  * マップ名
  * ランク(星の数)
  * 推奨レベル
  * 探索率
  * 接続人数(要、右クリックメニューで設定)
  * <span style="color:red;">[New] </span>宝箱とその状態
  * <span style="color:red;">[New] </span>まだ会っていないNPC
  * <span style="color:red;">[New] </span>まだ行っていない区域(MapFogViewerの機能)
* ミニマップのボタンや表示を小さくして情報を見やすくしています
* そのマップのデスペナ情報を表示(マップ名のツールチップに表示)
* ミニマップの右側に次の項目を追加表示します
  * <span style="color:red;">[New] </span>モンスターの種類と生息数
  * <span style="color:red;">[New] </span>まだ会っていないNPCのリスト
  * <span style="color:red;">[New] </span>まだ開始していないクエスト一覧
  * <span style="color:red;">[New] </span>まだ開けていない宝箱の一覧

### 3.追加された右クリックメニューの一覧
1. 接続人数の自動更新に関するメニュー  
    次の場所を右クリックすると表示されます
    * マップ名
    * 接続人数表示部
    * 次回更新のカウントダウン表示
1. 時計の表示に関するメニュー  
    時刻の欄を右クリックすると表示されます

### 4.使用可能なコマンド一覧
基本のコマンドは **`/mapmate`** または **`/mmate`** です  

|コマンド|効果|
|---|---|
|/mmate reset|設定リセット|
|/mmate update|表示を更新|
|/mmate jp|日本語に切り替え|
|/mmate en|英語に切り替え|
|/mmate xx|xx に英語2文字を入れる<br>その言語に切り替え|
|/mmate ?|チャットログにヘルプを表示|

**英語と日本語以外を使うには**：  
他の言語モードを使えるようにするには、該当する言語のテキストリソースをプログラムソースに追記する必要があります。

### 5.導入方法
このアドオンは、アドオンマネージャJPに登録しています。  
アドオンマネージャJPを用いて導入してください  

---
## Description of English Version 
  
**Notice**: This add-on has **English display mode**.  
You can switch to English display mode by using command **`/mmate en`**  
### What is this?
This add-on makes map display a lot convenient.  
(Currently it only displays additional information in the mini map)  
![Image of customized minimap view](https://github.com/Toukibi/ToSAddon/blob/ForImage/MapMate/image/MapMate_MiniMap2_en.jpg?raw=true)
### Features.
* Add the following items to the mini map.
  * Map name
  * The rank of current map. (Number of star marks)
  * Recommended level
  * Search progress
  * Number of connected people (required, set with right click menu)
  * <span style="color:red;">[New] </span>Treasure Chest and its state
  * <span style="color:red;">[New] </span>NPC that has not met yet
  * <span style="color:red;">[New] </span>Area not yet done (MapFogViewer function)
* Reduces the mini-map buttons and displays to make information easier to see.
* Display Death-penalty-information of the map. (displayed on tooltip of map name)
* The following items are added to the right of the mini map
  * <span style="color:red;">[New] </span>Monster list and population
  * <span style="color:red;">[New] </span>List of NPCs that has not met yet
  * <span style="color:red;">[New] </span>List of the remaining quest
  * <span style="color:red;">[New] </span>List of the treasure chest

### 3. List of additional right-click menu
1. Settings for automatic updates of connected persons  
    You can access by right clicking on the following place.
    * Display area of the map name
    * Display area of the connected persons count
    * Display area of the next update countdown time
1. Settings for clock style  
    You can access by right clicking on the clock

### Installation Instructions.
Install via the Addon Manager. Leave bug reports and other issues on my Github page.

### Settings.
Settings can be accessed by Right Clicking on minimap information and clock, and via these Slash Commands.

|Paramater|What happens result|
|---|---|
|/mmate reset|Reset the all settings.|
|/mmate update|The additional information displayed will be updated.|
|/mmate jp|Switch to Japanese mode.|
|/mmate en|Switch to English mode.|
|/mmate xx|Insert two English letters in xx<br>(ccTLD or language code recommended)<br>Switch to Other Language mode.|
|/mmate ?|Display the help-text to chat-log.|

<span style="color:red;">**In order to use language other than English and Japanese**</span>:  
In order to use **Other Language** mode, you need to **add a text resource to the program source**.

### Images

##### List of the enemies that live in that map
![Image of customized minimap view](https://github.com/Toukibi/ToSAddon/blob/ForImage/MapMate/image/MobList_en.jpg?raw=true)

##### List of NPCs that has not met yet
![Image of customized minimap view](https://github.com/Toukibi/ToSAddon/blob/ForImage/MapMate/image/NpcList_en.jpg?raw=true)

##### List of the remaining quest
![Image of customized minimap view](https://github.com/Toukibi/ToSAddon/blob/ForImage/MapMate/image/QuestList_en.jpg?raw=true)

##### List of the treasure chest
![Image of customized minimap view](https://github.com/Toukibi/ToSAddon/blob/ForImage/MapMate/image/BoxList_en.jpg?raw=true)

##### Main right click menu
![Image of customized minimap view](https://github.com/Toukibi/ToSAddon/blob/ForImage/MapMate/image/cMenuMain_en.jpg?raw=true)

##### Right click menu for clock
![Image of customized minimap view](https://github.com/Toukibi/ToSAddon/blob/ForImage/MapMate/image/cMenuTime_en.jpg?raw=true)