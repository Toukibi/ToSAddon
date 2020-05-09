# Buff Counter
Description of [English Version is Here](#description-of-english-version).

### 1.これは何？
上段バフの残り枠数を教えてくれます。  
(ついでにトークンの残り時間をバフ欄に表示します)  
![外観表示](https://github.com/Toukibi/ToSAddon/blob/ForImage/BuffCounter/img/topimage.png?raw=true)  
### 2.できること
* 次の項目を追加表示します  
  * 上段バフの残り数
  * トークンの残り時間
  * 一部スキルのスキルレベルなどのパラメータ  
  
スキルのパラメータ表示は、画面がゴタゴタしないよう、知ることに意味が大きいものに限定しています。  

### 3.追加された右クリックメニューの一覧
1. Buff Counterの動作に関するメニュー  
    Buff Counterのフレーム上を右クリックすると表示されます

### 4.使用可能なコマンド一覧
基本のコマンドは **`/buffc`** または **`/buffcounter`** です  

|コマンド|効果|
|---|---|
|/buffc|メイン画面の表示/非表示を切り替え|
|/buffc reset|設定リセット|
|/buffc resetpos<br>/buffc rspos|表示位置をリセット|
|/buffc refresh|位置・表示を更新|
|/buffc update|表示を更新|
|/buffc ?|チャットログにヘルプを表示|
|/buffc jp<br>/buffc ja|日本語モードに切り替え|
|/buffc en|英語モードに切り替え|
|/buffc kr|韓国語モードに切り替え|

### 5.導入方法
このアドオンは、アドオンマネージャJPに登録しています。  
アドオンマネージャJPを用いて導入してください  

---
## Description of English Version 
  
**Notice**: From Ver.1.10, this add-on  implements **English mode**.   
To switch to English mode, Use the command **`/buffc en`**

### What is this?
This addon will show you the remaining number of Top Row Buff Slots left.  
![Image of Buff-Counter](https://github.com/Toukibi/ToSAddon/blob/ForImage/BuffCounter/img/topimage_en.jpg?raw=true)  
### Features.
* Display the number of Top Row Buff Slots left as a Continuous Bar or Blocks

|Block style|Continuous Bar style|
|---|---|
|![Image of Buff-Counter with block style](https://github.com/Toukibi/ToSAddon/blob/ForImage/BuffCounter/img/display_left_en.png?raw=true)|![Image of Buff-Counter with continuous bar style](https://github.com/Toukibi/ToSAddon/blob/ForImage/BuffCounter/img/display_left_bar_en.png?raw=true)|
  
|Display <br>Used Count|Display <br>Left Count|Ultra Mini Style|
|---|---|---|
|![Image of Buff-Counter displays used Buff count](https://github.com/Toukibi/ToSAddon/blob/ForImage/BuffCounter/img/display_use_en.png?raw=true)|![Image of Buff-Counter displays Buff's left count](https://github.com/Toukibi/ToSAddon/blob/ForImage/BuffCounter/img/display_left_en.png?raw=true)|![Image of Buff-Counter with Ultra Mini Style](https://github.com/Toukibi/ToSAddon/blob/ForImage/BuffCounter/img/display_mini_en.png?raw=true)<br>Display the Number only|

* Display the number of Top Row Buffs Slots left numerically
* Days Remaining on your TP Token
* Other stats of buffs (I.E Blessing's Damage , Team Lodge Level, Amount of spells Divine Might Effects.(Show the level only, cannnot update used count) )

### Installation Instructions.
Install via the Addon Manager. Leave bug reports and other issues on my Github page.  

### List of additional right click menu.
1. The operation of Buff-Counter  
    Right-click on the Buff-Counter frame to display it

### Settings.
Settings can be accessed by Right Clicking on Buff Counter, and via these Slash Commands.

|Commands|Description|
|---|---|
|/buffc|Toggle visibility|
|/buffc reset|Reset the all settings|
|/buffc resetpos<br>/buffc rspos|Reset the position of this add-on|
|/buffc update|The Buff Counter displayed will be updated|
|/buffc refresh|Update the Buff Counter and move to where it should be|
|/buffc ?|Display the help text in the chatlog|
|/buffc jp<br>/buffc ja|Switch to Japanese mode|
|/buffc en|Switch to English mode|
|/buffc kr|Switch to Korean mode|

Right click menu image  
![Image of Buff-Counter context menu](https://github.com/Toukibi/ToSAddon/blob/ForImage/BuffCounter/img/contextmenu_en.jpg?raw=true)  


When using UltraMini mode, I recommend placing it in the location shown in the following figure.  
![Image of Buff-Counter recomended location when use with ultra-mini mode](https://github.com/Toukibi/ToSAddon/blob/ForImage/BuffCounter/img/minimode_recomend_en.jpg?raw=true)  