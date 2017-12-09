
# Better Pick Queue  
  
Description of [English Version is Here](#description-of-english-version).  
  
### 1.これは何？
画面の右下で拾ったアイテムを表示する機能を強化します。  
![外観表示](https://github.com/Toukibi/ToSAddon/blob/ForImage/BetterPickQueue/img/topimage2_ja.jpg?raw=true)  
### 2.できること
* バグで正しい金額を表示できないかわいそうな子に代わって次の機能を提供します。  
  * 現在の所持数を正しく表示します
  * 開始時点からの増加数を表示します
  * 過去3回分の拾った時間と量を表示します
  * 1時間あたりに拾える予測数を表示します
  * 所持重量の情報を表示します

### 3.追加された右クリックメニューの一覧
1. **よく使うであろう項目のメニュー**  
   Better Pick Queueのフレーム上を右クリックすると表示されます。  
1. **1回設定したらあまり変更しないであろう項目のメニュー**  
   Better Pick Queueのフレーム上をShift＋右クリックで表示されます。

|メイン設定 (右クリック)|第2設定 (Shift+右クリック)|
|---|---|
|![Image of Better-Pick-Queue](https://github.com/Toukibi/ToSAddon/blob/ForImage/BetterPickQueue/img/primarymenu_simple_ja.jpg?raw=true)|![Image of Better-Pick-Queue](https://github.com/Toukibi/ToSAddon/blob/ForImage/BetterPickQueue/img/secondarymenu_ja.jpg?raw=true)|

### 4.使用可能なコマンド一覧
基本的な設定は表示を右クリックすると出て来る設定メニューで行なえます。  
コマンドは **`/pickq`** または **`/pickqueue`** です  

|コマンド|効果|
|---|---|
|/pickq|メイン画面の表示/非表示を切り替え|
|/pickq reset|計測リセット|
|/pickq resetpos|位置をリセット|
|/pickq resetsetting|設定をリセット|
|/pickq update|表示を更新|
|/pickq ?|チャットログにヘルプを表示|
|/pickq jp<br>/pickq ja|日本語モードに切り替え|
|/pickq en|英語モードに切り替え|

### 5.導入方法
このアドオンは、アドオンマネージャJPに登録しています。  
アドオンマネージャJPを用いて導入してください  

---
## Description of English Version 
  
To switch to English mode, Use the command **`/pickq en`**

### What is this?
This add-on enhances the ability to display the items picked up.  
![Image of Better-Pick-Queue](https://github.com/Toukibi/ToSAddon/blob/ForImage/BetterPickQueue/img/topimage_en.jpg?raw=true)  
### Features.
* On behalf of the standard functions that can not display the correct amount with a bug, this add-on provides the following functions.  
  * Correctly display the current number of possessions.
  * Displays the increment from the start.
  * Displays the time and amount picked up for the past 3 times
  * Displays the number of forecasts that can be picked up per hour.
  * Displays information on possession weight.

### Installation Instructions.
Install via the Addon Manager. Leave bug reports and other issues on my Github page.  

### 3. List of additional right click menu.
1. **Menu of items that will be used frequently**  
    Right-click on the Better-Pick-Queue frame to display it
1. **Menu of items that will not change so much after setting once**  
    Shift + Right-click on the Better-Pick-Queue frame to display it

|Only Right Click|Shift + Right Click|
|---|---|
|![Image of Better-Pick-Queue](https://github.com/Toukibi/ToSAddon/blob/ForImage/BetterPickQueue/img/primarymenu_simple_en.jpg?raw=true)|![Image of Better-Pick-Queue](https://github.com/Toukibi/ToSAddon/blob/ForImage/BetterPickQueue/img/secondarymenu_en.jpg?raw=true)|
    
### Settings.
Settings can be accessed by Right Clicking or Shift + Right Clicking on Better-Pick-Queue, and via these Slash Commands.

|Commands|Description|
|---|---|
|/pickq|Toggle visibility|
|/pickq reset|Reset session|
|/pickq resetpos|Reset position|
|/pickq resetsetting|Reset the all settings|
|/pickq update|Better-Pick-Queue displayed will be updated|
|/pickq ?|Display the help text in the chatlog|
|/pickq jp<br>/pickq ja|Switch to Japanese mode|
|/pickq en|Switch to English mode|

### Images

|Normal mode|Obtained counter mode|Obtained history mode|
|---|---|---|
|![Image of Better-Pick-Queue](https://github.com/Toukibi/ToSAddon/blob/ForImage/BetterPickQueue/img/normalmode_en.jpg?raw=true)<br>**note:** Item that has passed 10 seconds to pick up will be hidden.|![Image of Better-Pick-Queue](https://github.com/Toukibi/ToSAddon/blob/ForImage/BetterPickQueue/img/countermode_en.jpg?raw=true)<br>**note:** Only log items that has passed 10 seconds to pick up will be hidden.|![Image of Better-Pick-Queue](https://github.com/Toukibi/ToSAddon/blob/ForImage/BetterPickQueue/img/detailmode_en.jpg?raw=true)<br>**note:** Display all information.|
