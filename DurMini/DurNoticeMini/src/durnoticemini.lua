local addonName = "DurNoticeMini";
local verText = "1.00";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
DurMini = Me;
local DebugMode = true;

local floor = math.floor;

CHAT_SYSTEM("{#333333}[Add-ons]" .. addonName .. verText .. " loaded!{/}");
CHAT_SYSTEM("{#333333}[DurNoticeMini]コマンド /durmini で耐久表示のON/OFFが切り替えられます{/}");

-- ***** 変数の宣言と設定 *****
Me.SettingFilePathName = string.format("../addons/%s/settings.json", addonNameLower);
local eqTypes = {"RH", "LH", "SHIRT", "GLOVES", "PANTS", "BOOTS", "RING1", "RING2", "NECK"};
local eqDurData = {}
Me.Loaded = false;

-- ***** ログ表示関連 *****
local function CreateValueWithStyleCode(Value, Styles)
	-- ValueにStylesで与えたスタイルタグを付加した文字列を返します
	local ReturnValue;
	if Styles == nil or #Styles == 0 then
		-- スタイル指定なし
		ReturnValue = Value;
	else
		local TagHeader = ""
		for i, StyleTag in ipairs(Styles) do
			TagHeader = TagHeader .. string.format( "{%s}", StyleTag);
		end
		ReturnValue = string.format( "%s%s%s", TagHeader, Value, string.rep("{/}", #Styles));
	end
	return ReturnValue;
end

local function AddLog(Message, Mode, DisplayAddonName, OnlyDebugMode)
	if Me.Settings == nil then return end
	if Message == nil then return end
	if (not DebugMode) and Mode == "Info" then return end
	if (not DebugMode) and OnlyDebugMode then return end
	local HeaderText = "";
	if DisplayAddonName then
		HeaderText = string.format("[%s]", addonName);
	end
	local MsgText = HeaderText .. Message;
	if Mode == "Info" then
		MsgText = CreateValueWithStyleCode(MsgText, {"#333333"});
	elseif Mode == "Warning" then
		MsgText = CreateValueWithStyleCode(MsgText, {"#331111"});
	elseif Mode == "Caution" then
		MsgText = CreateValueWithStyleCode(MsgText, {"#666622"});
	elseif Mode == "Notice" then
		MsgText = CreateValueWithStyleCode(MsgText, {"#333366"});
	else
		-- 何もしない
	end
	CHAT_SYSTEM(MsgText);
end

-- ***** 設定読み書き関連 *****
-- 設定書き込み
local function SaveTable(FilePathName, objTable)
	if FilePathName == nil then
		AddLog("設定の保存ファイル名が指定されていません", "Warning", true, false);
	end
	local objFile, objError = io.open(FilePathName, "w")
	if objError then
		AddLog(string.format("設定の保存でエラーが発生しました:{nl}%s", tostring(objError)), "Warning", true, false);
	else
		local json = require('json');
		objFile:write(json.encode(objTable));
		objFile:close();
		AddLog("設定の保存が完了しました", "Info", true, true);
	end
end
local function SaveSetting()
	SaveTable(Me.SettingFilePathName, Me.Settings);
end

-- 既存の値がない場合にデフォルト値をマージする
local function GetValueOrDefault(Value, DefaultValue, Force)
	Force = Force or false;
	if Force or Value == nil then
		return DefaultValue;
	else
		return Value;
	end
end

-- デフォルト設定(ForceがTrueでない場合は、既存の値はそのまま引き継ぐ)
local function MargeDefaultSetting(Force, DoSave)
	DoSave = GetValueOrDefault(DoSave, true);
	Me.Settings = Me.Settings or {};
	Me.Settings.PosX = GetValueOrDefault(Me.Settings.PosX, nil, Force);
	Me.Settings.PosY = GetValueOrDefault(Me.Settings.PosY, nil, Force);
	Me.Settings.Movable = GetValueOrDefault(Me.Settings.Movable, false, Force);
	Me.Settings.Visible = GetValueOrDefault(Me.Settings.Visible, true, Force);
	Me.Settings.DisplayGauge = GetValueOrDefault(Me.Settings.DisplayGauge, true, Force);
	if Force then
		AddLog("デフォルトの設定の読み込みが完了しました。", "Info", true, false);
	end
	if DoSave then SaveSetting() end
end

-- 設定読み込み
local function LoadSetting()
	local acutil = require("acutil");
	local objReadValue, objError = acutil.loadJSON(Me.SettingFilePathName);
	if objError then
		AddLog(string.format("設定の読み込みでエラーが発生したのでデフォルトの設定を使用します。{nl}{#331111}%s{/}", tostring(objError)), "Caution", true, false);
		MargeDefaultSetting(true, false);
	else
		Settings = objReadValue;
		MargeDefaultSetting(false, false);
	end
	AddLog("設定の読み込みが完了しました", "Info", true, false);
end

-- ===== 基本機能 =====
-- ***** 表示周り *****
-- 引数にTrueを設定するとピコハンと安全ヘルメットの絵に変わる。ただそれだけ
function Me.Joke(value)
	value = value or false;
	local TopFrame = Me.frame;
	local pnlBase = GET_CHILD(TopFrame, "pnlBase", "ui::CGroupBox");
	local Pic1 = GET_CHILD(pnlBase, "Pic1", "ui::CPicture");
	local Pic2 = GET_CHILD(pnlBase, "Pic2", "ui::CPicture");
	if value then
		Pic1:SetImage("icon_item_banghammer");
		Pic2:SetImage("durminiicon_helmet");
	else
		Pic1:SetImage("mon_info_melee");
		Pic2:SetImage("durminiicon_shield");
	end
	Me.Joking = value;
end

-- ゲージのスキンを選択する(10/30/50/100で色が変わる)
local function GetGaugeSkin(current, max)
	local GaugeColor = "green";
	if current * 10 < max then
		GaugeColor = "red";
	elseif current * 10 < max * 3 then
		GaugeColor = "orange";
	elseif current * 10 < max * 5 then
		GaugeColor = "yellow";
	elseif current <= max then
		GaugeColor = "green";
	else
		GaugeColor = "blue_ongreen";
	end
	return "durmini_" .. GaugeColor;
end

-- 装備の耐久値を取得する
local function GetDurData(eqTypeName)
	local eqlist = session.GetEquipItemList();
	local num = item.GetEquipSpotNum(eqTypeName)
	if num == nil then return end
	local eq = eqlist:Element(num);

	if eq.type ~= item.GetNoneItem(eq.equipSpot) then
		local obj = GetIES(eq:GetObject());
		eqDurData[eqTypeName] = {
			eqTypeName = eqTypeName,
			Name = obj.Name,
			Dur = obj.Dur,
			MaxDur = obj.MaxDur,
			imgName = GET_ITEM_ICON_IMAGE(obj)
		};
	else
		eqDurData[eqTypeName] = nil;
	end
end

-- 取得した耐久値データから最も小さいものを選ぶ
local function GetMinimumDur()
	local ReturnValue = {};
	for i = 1, 2 do
		ReturnValue[i] = {};
	end
	for key, value in pairs(eqDurData) do
		local index = 2;
		if key == "LH" or key == "RH" then index = 1 end
		if value.Dur > 0 and (ReturnValue[index].Dur == nil or ReturnValue[index].Dur > value.Dur) then
			ReturnValue[index].Dur = value.Dur;
			ReturnValue[index].EqTypeName = value.eqTypeName;
		end
	end
	for i = 1, 2 do
		ReturnValue[i].eqDurData = eqDurData[ReturnValue[i].EqTypeName];
		if ReturnValue[i].EqTypeName == nil then
			ReturnValue[i].DurText = "--";
		else
			ReturnValue[i].DurText = floor(ReturnValue[i].Dur / 100);
		end
	end
	return ReturnValue;
end

-- メインフレームの描写更新
local function UpdateMainFrame()
	local MinDur = GetMinimumDur();

	local TopFrame = Me.frame;
	local pnlBase = GET_CHILD(TopFrame, "pnlBase", "ui::CGroupBox");
	for i = 1, 2 do
		local lblDur = GET_CHILD(pnlBase, "Dur" .. i, "ui::CRichText");
		if lblDur ~= nil then
			lblDur:SetTextByKey("opValue", MinDur[i].DurText);
		end
		local objDurGauge = GET_CHILD(pnlBase, "Gauge" .. i, "ui::CGauge");
		if objDurGauge ~= nil then
			local intValue = 0;
			if MinDur[i].EqTypeName ~= nil then intValue = MinDur[i].Dur end
			local intMaxValue = 100;
			if MinDur[i].EqTypeName ~= nil then intMaxValue = MinDur[i].eqDurData.MaxDur end
			objDurGauge:SetSkinName(GetGaugeSkin(intValue, intMaxValue));
			if intValue > intMaxValue then intValue = intValue - intMaxValue end
			if DebugMode then
				objDurGauge:SetPoint(0,100); -- Gaugeのスキン変更を反映させるには値が変わる(厳密にはグラフィック更新)必要があるみたい
			end
			objDurGauge:SetPoint(intValue, intMaxValue);
		end
	-- picImage:SetTooltipType("texthelp");
	-- picImage:SetTooltipArg("{@st42b}{#00FF33}宝箱(イベント)");
	end
end

-- ***** コンテキストメニュー周り *****
-- セパレータを挿入
local function MakeContextMenuSeparator(parent, width)
	width = width or 300;
	ui.AddContextMenuItem(parent, string.format("{img fullgray %s 1}", width), "None");
end

-- コンテキストメニュー項目を作成
local function MakeContextMenuItem(parent, text, eventscp, icon, checked)
	local CheckIcon = "";
	local ImageIcon = "";
	local eventscp = eventscp or "None";
	if checked == nil then
		CheckIcon = "";
	elseif checked == true then
		CheckIcon = "{img socket_slot_check 24 24} ";
	elseif checked == false  then
		CheckIcon = "{img channel_mark_empty 24 24} "
	end
	if icon == nil then
		ImageIcon = "";
	else
		ImageIcon = string.format("{img %s 24 24} ", icon);
	end
	ui.AddContextMenuItem(parent, string.format("%s%s%s", CheckIcon, ImageIcon, text), eventscp);
end

-- コンテキストメニューを作成する
function TOUKIBI_DURMINI_CONTEXT_MENU(frame, ctrl)
	local Title = "{#006666}====== DurNotice Miniの設定 ======{/}";
	local context = ui.CreateContextMenu("DURMINI_MAIN_RBTN", Title, 0, 0, 180, 0);
	MakeContextMenuItem(context, "位置を固定する", "TOUKIBI_DURMINI_CHANGE_MOVABLE()", nil, not Me.Settings.Movable);
	MakeContextMenuSeparator(context, 240);
	MakeContextMenuItem(context, "位置をリセット", "TOUKIBI_DURMINI_RESETPOS()");
	MakeContextMenuItem(context, "{#666666}閉じる{/}");
	ui.OpenContextMenu(context);
	return context;
end

-- ***** コンテキストメニュー選択イベント受取 *****

function TOUKIBI_DURMINI_CHANGE_MOVABLE()
	if Me.Settings == nil then return end
	Me.Settings.Movable = not Me.Settings.Movable;
	Me.frame:EnableMove(Me.Settings.Movable and 1 or 0);
	SaveSetting();
end

function TOUKIBI_DURMINI_RESETPOS()
	if Me.Settings == nil then return end
	Me.Settings.PosX = nil;
	Me.Settings.PosY = nil;
	Me.UpdatePos();
	SaveSetting();
	AddLog("耐久表示の表示位置をリセットしました", "Info", true, false);
end

-- ***** その他イベント受取 *****

function TOUKIBI_DURMINI_START_DRAG()
	Me.IsDragging = true;
end

function TOUKIBI_DURMINI_END_DRAG()
	Me.IsDragging = false;
	if not Me.Settings.Movable then return end
	Me.Settings.PosX = Me.frame:GetX();
	Me.Settings.PosY = Me.frame:GetY();
	SaveSetting();
	AddLog("ドラッグ終了。現在位置を保存します。", "Info", true, true);
end

function TOUKIBI_DURMINI_ON_GAME_START()
	-- GAME_STARTイベント時ではheadsupdisplayフレームの移動が完了していないみたいなので0.5秒待ってみる
	ReserveScript("TOUKIBI_DURMINI_UPDATE_ALL()", 0.5);
end

function TOUKIBI_DURMINI_UPDATE_ALL(frame)
	Me.UpdatePos();
	Me.Update();
	Me.Joke();
end

function TOUKIBI_DURMINI_UPDATE(frame)
	Me.Update();
end

-- [DevConsole呼出可] 耐久値の表示を更新する
function Me.Update()
	for i = 1, #eqTypes do
		GetDurData(eqTypes[i]);
	end
	UpdateMainFrame();
end

-- [DevConsole呼出可] 表示位置を更新する
function Me.UpdatePos()
	local TopFrame = Me.frame;
	if TopFrame == nil then return end
	if Me.Settings == nil or Me.Settings.PosX == nil or Me.Settings.PosY == nil then
		-- デフォルト設定(ステータス表示にドッキング)
		local StatusFrame = ui.GetFrame("headsupdisplay");
		if StatusFrame ~= nil then
			TopFrame:SetPos(StatusFrame:GetX() + 280, StatusFrame:GetY());
		end
	else
		TopFrame:SetPos(Me.Settings.PosX, Me.Settings.PosY);
	end
end

-- [DevConsole呼出可] 表示/非表示を切り替える(1:表示 0:非表示 nil:トグル)
function Me.Show(value)
	if value == nil or value == 0 or value == 1 then
		local BaseFrame = Me.frame;
		if BaseFrame == nil then
			CHAT_SYSTEM("設定画面のハンドルが取得できませんでした");
			return;
		end
		if value == nil then
			if BaseFrame:IsVisible() == 0 then
				value = 1;
			else
				value = 0;
			end
		end
		BaseFrame:ShowWindow(value);
	end 
end

-- 使い方のテキストを出力する
local function PrintHelpToLog()
	local HelpMsg = "{#333333}Dur Notice Miniのパラメータ説明{/}{nl}{#92D2A0}Dur Notice Miniは次のパラメータで設定を呼び出してください。{/}{nl}{#333333}'/durmini [パラメータ]' または '/DurMini [パラメータ]'{/}{nl}{#333366}パラメータなしで呼び出された場合は耐久値表示画面のON/OFFが切り替わります。(例： /DurMini ){/}{nl}{#333333}使用可能なコマンド：{nl}/DurMini reset    :設定リセット{nl}/DurMini resetpos :耐久値表示画面の位置をリセット{nl}/DurMini rspos    :  〃{nl}/DurMini refresh  :位置・表示を更新{nl}/DurMini update   :耐久値表示を更新{nl}/DurMini ?        :このヘルプを表示{nl}/DurMini joke     :？？？{/}{nl} ";
	AddLog(HelpMsg, "None", false, false);
end

-- スラッシュコマンド受取
function TOUKIBI_DURMINI_PROCESS_COMMAND(command)
	AddLog("TOUKIBI_DURMINI_PROCESS_COMMANDが呼び出されました", "Info", true, true);
	local cmd = ""; 
	if #command > 0 then 
		cmd = table.remove(command, 1); 
	else 
		Me.Show();
		return;
	end 
	if cmd == "reset" then 
		-- すべてをリセット
		MargeDefaultSetting(true, true);
		return;
	elseif cmd == "resetpos" or cmd == "rspos" then 
		-- 位置をリセット
		TOUKIBI_DURMINI_RESETPOS();
		return;
	elseif cmd == "refresh" then
		-- プログラムをリセット
		TOUKIBI_DURMINI_UPDATE_ALL();
		return;
	elseif cmd == "update" then
		-- 表示値の更新
		Me.Update();
		return;
	elseif cmd == "joke" then
		Me.Joke(true);
		return;
	elseif cmd ~= "?" then
		AddLog("無効なコマンドが呼び出されました{nl}コマンド一覧を見るには[ /durmini ? ]を用いてください", "Warning", true, false);
	end 
	PrintHelpToLog()
end

function DURNOTICEMINI_ON_INIT(addon, frame)
	Me.addon = addon;
	Me.frame = frame

	addon:RegisterMsg('UPDATE_ITEM_REPAIR', 'TOUKIBI_DURMINI_UPDATE');
	addon:RegisterMsg('ITEM_PROP_UPDATE', 'TOUKIBI_DURMINI_UPDATE');
	addon:RegisterMsg('EQUIP_ITEM_LIST_GET', 'TOUKIBI_DURMINI_UPDATE');
	addon:RegisterMsg('MYPC_CHANGE_SHAPE', 'TOUKIBI_DURMINI_UPDATE');
	addon:RegisterMsg('GAME_START', 'TOUKIBI_DURMINI_ON_GAME_START');

	local acutil = require("acutil");
	acutil.slashCommand("/DurMini", TOUKIBI_DURMINI_PROCESS_COMMAND);
	acutil.slashCommand("/Durmini", TOUKIBI_DURMINI_PROCESS_COMMAND);
	acutil.slashCommand("/durMini", TOUKIBI_DURMINI_PROCESS_COMMAND);
	acutil.slashCommand("/durmini", TOUKIBI_DURMINI_PROCESS_COMMAND);

	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	Me.frame:EnableMove(Me.Settings.Movable and 1 or 0);
	Me.Show(1);
	Me.Update();
	Me.UpdatePos()
	frame:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_DURMINI_CONTEXT_MENU');
	Me.IsDragging = false;
	Me.Joke(OSRandom(1, 100) < 5)
end


