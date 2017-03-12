# 改造版 Developer Console
変数展開機能を追加しています。
![alt text](https://github.com/Toukibi/ToSAddon/blob/ForImage/Do_It_Yourself/LuaOnly/Alter_DeveloperConsole/img/main.jpg?raw=true "Image of main frame")

使い方は次の通り

|コマンド|内容|
|---|---|
|?変数|変数の内容を表示 print(tostring(変数)) と等価|
|??変数|変数の内容を表示<br>ただし、table型かuserdata型が来たらその中身を展開します|
|???変数|変数の中身を表示<br>table型かuserdata型が来たらその中身を展開します<br>さらに、function型が来た場合は、引数なしで実行を試みます   <span style="color:red">**注意**：この部分にはエラー回避のコードを入れていません。最悪エラー落ちする場合もあるので使用する場合は中身を把握した上でお願いします。</span>|