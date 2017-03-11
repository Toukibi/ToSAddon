local addonName = "MapMate";
local verText = "0.12";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/mapmate", "/MapMate", "/mmate", "/MMate"};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
MapMate = Me;
local DebugMode = false;

local floor = math.floor;
local fmod = math.fmod;

CHAT_SYSTEM("{#333333}[Add-ons]" .. addonName .. verText .. " loaded!{/}");
--CHAT_SYSTEM("{#333333}[DurNoticeMini]コマンド /mmate で耐久表示のON/OFFが切り替えられます{/}");

-- ***** 変数の宣言と設定 *****
Me.SettingFilePathName = string.format("../addons/%s/%s", addonNameLower, SettingFileName);
Me.HoockedOrigProc = Me.HoockedOrigProc or {};
Me.PCCountSafetyCount = 0;
Me.Loaded = false;
Me.BrinkRadix = 4;

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
	Me.Settings.DoNothing = GetValueOrDefault(Me.Settings.DoNothing, false, Force);
	Me.Settings.Movable = GetValueOrDefault(Me.Settings.Movable, false, Force);
	Me.Settings.Visible = GetValueOrDefault(Me.Settings.Visible, true, Force);
	Me.Settings.UpdatePCCountInterval = GetValueOrDefault(Me.Settings.UpdatePCCountInterval, nil, Force);
	Me.Settings.EnableOneClickPCCUpdate = GetValueOrDefault(Me.Settings.EnableOneClickPCCUpdate, false, Force);
	Me.Settings.UsePCCountSafety = GetValueOrDefault(Me.Settings.UsePCCountSafety, true, Force);
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
		Me.Settings = objReadValue;
		MargeDefaultSetting(false, false);
	end
	AddLog("設定の読み込みが完了しました", "Info", true, false);
end

-- ===== アドオンの内容ここから =====














-- Map名のラベルを更新
local function UpdatelblMapName()
	local Parent = ui.GetFrame('minimap');
	if Parent == nil then return end
	local lblTarget = GET_CHILD(Parent, "MapMate_MapName", "ui::CRichText");
	if lblTarget == nil then return end
	lblTarget:SetText(string.format("{s14}{ol}%s%s{nl}%s%s{/}{/}"
								  , Me.ThisMapInfo.Stars
								  , Me.ThisMapInfo.strLv
								  , Me.ThisMapInfo.MapSymbol
								  , Me.ThisMapInfo.Name));

	local strTemp = "";
	if Me.ThisMapInfo.IESData.isVillage == "YES" then
		strTemp = string.format("{s14}{ol}%s%s [%s]"
							  , Me.ThisMapInfo.MapSymbol
							  , Me.ThisMapInfo.Name
							  , Me.ThisMapInfo.MapClassName);
	else
		strTemp = string.format("{s14}{ol}%s%s{nl}"
							 .. "%s%s [%s]{nl}"
							 .. "  {img journal_map_icon 16 16}探査率:%s{nl}"
							 .. "  {img icon_item_expcard 16 16}カードLv: %s{nl}"
							 .. "  {img channel_mark_empty 16 16}最大被ターゲット数: %s{nl}"
							 .. "%s{/}{/}"
							  , Me.ThisMapInfo.Stars
							  , Me.ThisMapInfo.strLv
							  , Me.ThisMapInfo.MapSymbol
							  , Me.ThisMapInfo.Name
							  , Me.ThisMapInfo.MapClassName
							  , Me.ThisMapInfo.FogRevealRate or ""
							  , Me.ThisMapInfo.strExpCardLv
							  , Me.ThisMapInfo.MaxHateCount
							  , Me.ThisMapInfo.DeathPenaltyText or "");
	end
	lblTarget:SetTooltipType("texthelp");
	lblTarget:SetTooltipArg(strTemp);
end

local function UpdatelblFogRevealRate()
	local Parent = ui.GetFrame('minimap');
	if Parent == nil then return end
	local lblTarget = GET_CHILD(Parent, "MapMate_FogRate", "ui::CRichText");
	if lblTarget == nil then return end
	if Me.ThisMapInfo.FogRevealRate ~= "" then
		lblTarget:SetText(string.format("{img journal_map_icon 20 20}{s14}{ol}%s{/}{/}", Me.ThisMapInfo.FogRevealRate));
		if Me.lblFogRateHideTimer == nil then
			lblTarget:ShowWindow(1);
		elseif Me.lblFogRateHideTimer >= 0 and fmod(Me.lblFogRateHideTimer, Me.BrinkRadix) > 0 then
			lblTarget:ShowWindow(1);
		else
			lblTarget:ShowWindow(0);
		end
	else
		lblTarget:ShowWindow(0);
	end
	UpdatelblMapName()
end

local function UpdatelblPCCount()
	local Parent = ui.GetFrame('minimap');
	if Parent == nil then return end
	local lblTarget = GET_CHILD(Parent, "MapMate_PCCount", "ui::CRichText");
	if lblTarget == nil then return end
	local strTemp = "";
	local strTipTemp  = ""
	if Me.ThisMapInfo.PCCount == nil then
		-- 取得失敗
		strTemp = "--";
		strTipTemp = "接続人数の取得に失敗しました";
	elseif Me.ThisMapInfo.PCCount < -1 then
		strTemp = "--";
		strTipTemp = "接続人数の取れないMapです";
	elseif Me.ThisMapInfo.PCCount == -1 then
		strTemp = "閉鎖";
		strTipTemp = "このチャンネルは閉鎖されています";
	else
		strTemp = Me.ThisMapInfo.PCCount;
		strTipTemp = string.format("接続人数:%s/%s", Me.ThisMapInfo.PCCount, session.serverState.GetMaxPCCount())
	end
	lblTarget:SetText(string.format("{img minimap_0_old 16 16}{s14}{ol}%s{/}{/}", strTemp));
	lblTarget:SetTextTooltip(string.format("{img minimap_0_old 16 16}{s14}{ol}%s{/}{/}", strTipTemp));

	local lblPCCountRemainingTime = GET_CHILD(Parent, "MapMate_PCCountRemainingTime", "ui::CRichText");
	if lblPCCountRemainingTime ~= nil then
		local tmpMargin = lblTarget:GetMargin();
		lblPCCountRemainingTime:SetMargin(0, 0, tmpMargin.right + lblTarget:GetWidth(), tmpMargin.bottom);
	end

end



-- ***** MAP情報を更新する *****

-- Mapの基本情報を更新する
function Me.UpdateMapInfo()
	Me.ThisMapInfo = Me.ThisMapInfo or {};
	Me.ThisMapInfo.MapClassName = session.GetMapName();
	Me.ThisMapInfo.IESData = GetClass("Map", Me.ThisMapInfo.MapClassName);
	Me.ThisMapInfo.Name = Me.ThisMapInfo.IESData.Name;
	if Me.ThisMapInfo.IESData.isVillage == "YES" then
		Me.ThisMapInfo.Stars = "";
		Me.ThisMapInfo.MapSymbol = "{img friend_team 14 14}";
		Me.ThisMapInfo.strLv = "";
	else
		Me.ThisMapInfo.Stars = "";
		for i = 1, Me.ThisMapInfo.IESData.MapRank do
			Me.ThisMapInfo.Stars = Me.ThisMapInfo.Stars .. "{img star_in_arrow 14 14}";
		end
		for i = 1, 4 - Me.ThisMapInfo.IESData.MapRank do
			Me.ThisMapInfo.Stars = Me.ThisMapInfo.Stars .. "{img star_out_arrow 14 14}";
		end
		if Me.ThisMapInfo.IESData.QuestLevel > 0 and (Me.ThisMapInfo.IESData.MapType == "Field" or Me.ThisMapInfo.IESData.MapType == "Dungeon") then
			Me.ThisMapInfo.strLv = " Lv." .. Me.ThisMapInfo.IESData.QuestLevel;
		else
			Me.ThisMapInfo.strLv = "";
		end
		if Me.ThisMapInfo.IESData.MapType == "Dungeon" then
			if string.find(string.lower(Me.ThisMapInfo.MapClassName), "id_") or string.find(string.lower(Me.ThisMapInfo.MapClassName), "mission_") or Me.ThisMapInfo.IESData.Mission == "YES" then
				Me.ThisMapInfo.MapSymbol = "{img minimap_indun 14 14}";
			elseif Me.ThisMapInfo.IESData.EliteMobLimitCount > 0 then
				Me.ThisMapInfo.MapSymbol = "{img minimap_erosion 14 14}";
			else
				Me.ThisMapInfo.MapSymbol = "{img minimap_dungeon 14 14}";
			end
		else
			Me.ThisMapInfo.MapSymbol = "";
		end
		local ExpCardInfo = string.lower(Me.ThisMapInfo.IESData.DropItemClassName1);
		if string.find(ExpCardInfo, "expcard") then
			Me.ThisMapInfo.strExpCardLv = string.gsub(ExpCardInfo, "expcard", "");
		else
			Me.ThisMapInfo.strExpCardLv = "--";
		end
	end
	Me.ThisMapInfo.MaxHateCount = Me.ThisMapInfo.IESData.MaxHateCount;
	-- デスペナ内容を解析 例:Gem3#Silver5#Card1#Blessstone1
	local strReadData = string.lower(Me.ThisMapInfo.IESData.DeathPenalty);
	if strReadData ~= nil and strReadData ~= "" and strReadData ~= "none" then
		local strTemp = "{#663333}デスペナ情報：";
		for w in string.gmatch(strReadData, "%w+") do
			if string.find(w, "gem") then
				strTemp = strTemp .. "{nl}  ジェム消失 Lv." .. string.gsub(w, "gem", "");
			elseif string.find(w, "silver") then
				strTemp = strTemp .. "{nl}  " .. string.gsub(w, "silver", "") .. "％のシルバーを消失";
			elseif string.find(w, "card") then
				strTemp = strTemp .. "{nl}  Bossカード消失 Lv." .. string.gsub(w, "card", "");
			elseif string.find(w, "blessstone") then
				strTemp = strTemp .. "{nl}  祝福石消失 Lv." .. string.gsub(w, "blessstone", "");
			else
				strTemp = strTemp .. string.format("{nl}  その他のペナルティー(%s)", w)
			end
		end
		strTemp = strTemp .. "{nl}{/}";
		Me.ThisMapInfo.DeathPenaltyText = strTemp;
	else
		Me.ThisMapInfo.DeathPenaltyText = nil
	end
	UpdatelblMapName();
end

-- Mapの接続人数を更新する
function Me.UpdatePCCount()
	if ui.GetFrame("loadingbg") ~= nil then return end
	if Me.Settings.PCCountSafetyCount ~= nil and Me.Settings.PCCountSafetyCount > 0 then return end
	local zoneInsts = session.serverState.GetMap();
	if zoneInsts == nil then
		app.RequestChannelTraffics();
		Me.ThisMapInfo.PCCount = nil;
	else
		if zoneInsts:NeedToCheckUpdate() == true then app.RequestChannelTraffics() end
		if zoneInsts:GetZoneInstCount() - 1 >= session.loginInfo.GetChannel() then
			local zoneInst = zoneInsts:GetZoneInstByIndex(session.loginInfo.GetChannel());
			if zoneInst ~= nil then
				Me.ThisMapInfo.PCCount = zoneInst.pcCount
			else
				Me.ThisMapInfo.PCCount = nil;
			end
		end
	end
	if Me.Settings.UsePCCountSafety then
		Me.Settings.PCCountSafetyCount = Me.BrinkRadix * 5;
	end
	if Me.Settings.UpdatePCCountInterval ~= nil then
		Me.PCCountRemainingTime = Me.Settings.UpdatePCCountInterval * Me.BrinkRadix;
	end
	UpdatelblPCCount()
end

-- Mapの走破率を更新する
function Me.UpdateFogRevealRate()
	Me.ThisMapInfo.MapClassName = session.GetMapName();
	if 0 ~= MAP_USE_FOG(Me.ThisMapInfo.MapClassName) then
		local CompRate = session.GetMapFogRevealRate(Me.ThisMapInfo.MapClassName);
		local CompSymbol = "";
		if CompRate >= 100 then
			-- CompSymbol = " {img test_pvp_mvpicon 24 24}";
			CompSymbol = "{img collection_com 20 20}";
			Me.ThisMapInfo.Complete = true;
			if Me.lblFogRateHideTimer == nil then
				Me.lblFogRateHideTimer = 8 * Me.BrinkRadix;
			end
		else
			CompSymbol = "";
			Me.ThisMapInfo.Complete = false;
			if Me.lblFogRateHideTimer ~= nil and Me.lblFogRateHideTimer < 0 then
				Me.lblFogRateHideTimer = nil;
			end
		end
		Me.ThisMapInfo.FogRevealRate = string.format("{s14}{ol}%s%.1f％{/}{/}", CompSymbol, CompRate);
	else
		Me.ThisMapInfo.FogRevealRate = "";
		Me.ThisMapInfo.Complete = nil;
	end
	UpdatelblFogRevealRate()
end

function TOUKIBI_MAPMATE_TIMER_PCCOUNT_TICK(frame)
	if Me.Settings.UpdatePCCountInterval ~= nil then
		if Me.PCCountRemainingTime == nil then
			Me.PCCountRemainingTime = Me.Settings.UpdatePCCountInterval * Me.BrinkRadix;
		elseif Me.PCCountRemainingTime <= 1 then
			Me.UpdatePCCount();
			Me.PCCountRemainingTime = Me.Settings.UpdatePCCountInterval * Me.BrinkRadix;
		else
			Me.PCCountRemainingTime = Me.PCCountRemainingTime - 1;
		end
	end
	if Me.Settings.PCCountSafetyCount ~= nil and Me.Settings.PCCountSafetyCount > 0 then
		Me.Settings.PCCountSafetyCount = Me.Settings.PCCountSafetyCount - 1;
	end
	local Parent = ui.GetFrame('minimap');
	local TargetControl = GET_CHILD(Parent, "MapMate_PCCountRemainingTime", "ui::CRichText");
	local strRemainingTime = "---";
	if Me.Settings.UpdatePCCountInterval ~= nil then
		strRemainingTime = string.format("%d", Me.PCCountRemainingTime / Me.BrinkRadix + 0.9);
	end
	if TargetControl ~= nil then
		local TextColor = "#888888";
		if Me.Settings.PCCountSafetyCount ~= nil and Me.Settings.PCCountSafetyCount > 0 then
			TextColor = "#FF6666";
		end
		TargetControl:SetText(string.format("{%s}{s8}{ol}%s{/}{/}{/}", TextColor, strRemainingTime));
	end

	if Me.lblFogRateHideTimer ~= nil and Me.lblFogRateHideTimer >= 0  then
		Me.lblFogRateHideTimer = Me.lblFogRateHideTimer - 1;
		UpdatelblFogRevealRate();
	end
end

function TOUKIBI_MAPMATE_TIMER_PCCOUNT_START()
	if Me.BrinkRadix == nil or Me.BrinkRadix <= 0 and Me.BrinkRadix > 100 then
		Me.BrinkRadix = 1;
	end
	Me.timer_pccount:Start(1 / Me.BrinkRadix);
end

function TOUKIBI_MAPMATE_TIMER_PCCOUNT_STOP()
	CHAT_SYSTEM("timer stop!");
	Me.timer_pccount:Stop();
end

-- ***** コンテキストメニュー関連 *****
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
		CheckIcon = "{img channel_mark_empty 24 24} ";
	end
	if icon == nil then
		ImageIcon = "";
	else
		ImageIcon = string.format("{img %s 24 24} ", icon);
	end
	ui.AddContextMenuItem(parent, string.format("%s%s%s", CheckIcon, ImageIcon, text), eventscp);
end

-- ***** コンテキストメニューを作成する *****

-- 接続人数更新設定のコンテキストメニュー
function TOUKIBI_MAPMATE_CONTEXT_MENU_PCCOUNT(frame, ctrl)
	local Title = "{#006666}==== MapMateの設定(接続人数更新) ===={/}{nl}{#663333}更新機能はサーバーへの通信を行います。{nl}使用は自己責任でお願いします。{/}";
	local context = ui.CreateContextMenu("DURMINI_MAIN_RBTN", Title, 0, 0, 320, 0);
	MakeContextMenuSeparator(context, 300);
	MakeContextMenuItem(context, "{#FFFF88}今すぐ更新する{/}", "TOUKIBI_MAPMATE_EXEC_PCCUPDATE()", nil, nil);
	MakeContextMenuSeparator(context, 301);
	MakeContextMenuItem(context, "10秒毎に自動更新", "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(10)", nil, Me.Settings.UpdatePCCountInterval == 10);
	MakeContextMenuItem(context, "20秒毎に自動更新", "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(20)", nil, Me.Settings.UpdatePCCountInterval == 20);
	MakeContextMenuItem(context, "30秒毎に自動更新", "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(30)", nil, Me.Settings.UpdatePCCountInterval == 30);
	MakeContextMenuItem(context, "1分毎に自動更新", "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(60)", nil, Me.Settings.UpdatePCCountInterval == 60);
	MakeContextMenuItem(context, "3分毎に自動更新", "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(180)", nil, Me.Settings.UpdatePCCountInterval == 180);
	MakeContextMenuItem(context, "5分毎に自動更新", "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(300)", nil, Me.Settings.UpdatePCCountInterval == 300);
	MakeContextMenuItem(context, "{#8888FF}自動更新しない{/}", "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(nil)", nil, Me.Settings.UpdatePCCountInterval == nil);
	MakeContextMenuSeparator(context, 302);
	MakeContextMenuItem(context, "{img minimap_0_old 20 20}をクリックで手動更新する", "TOUKIBI_MAPMATE_TOGGLE_ENABLED_ONECLICK_PCCUPDATE()", nil, Me.Settings.EnableOneClickPCCUpdate);
	MakeContextMenuItem(context, "{#8888FF}更新後5秒間は更新しない{/}", "TOUKIBI_MAPMATE_TOGGLE_PCCUPDATESAFETY()", nil, Me.Settings.UsePCCountSafety);
	MakeContextMenuSeparator(context, 303);
	MakeContextMenuItem(context, "{#666666}閉じる{/}");
	context:Resize(330, context:GetHeight());
	ui.OpenContextMenu(context);
	return context;
end

-- ***** コンテキストメニューのイベント受け *****

function TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(value)
	if Me.Settings == nil then return end
	Me.Settings.UpdatePCCountInterval = value;
	if Me.PCCountRemainingTime > Me.Settings.UpdatePCCountInterval * Me.BrinkRadix then
		Me.PCCountRemainingTime = Me.Settings.UpdatePCCountInterval * Me.BrinkRadix;
	end
	SaveSetting();
end

function TOUKIBI_MAPMATE_EXEC_PCCUPDATE()
	Me.UpdatePCCount();
end

function TOUKIBI_MAPMATE_TOGGLE_ENABLED_ONECLICK_PCCUPDATE()
	if Me.Settings == nil then return end
	Me.Settings.EnableOneClickPCCUpdate = not Me.Settings.EnableOneClickPCCUpdate;
	SaveSetting();
end

function TOUKIBI_MAPMATE_TOGGLE_PCCUPDATESAFETY()
	if Me.Settings == nil then return end
	if Me.Settings.UsePCCountSafety == nil then
		Me.Settings.UsePCCountSafety = true
	else
		Me.Settings.UsePCCountSafety = not Me.Settings.UsePCCountSafety
	end
	SaveSetting();
end





function TOUKIBI_LBLPCCOUNT_CLICKED(frame)
	if Me.Settings.EnableOneClickPCCUpdate then
		Me.UpdatePCCount();
	end
end

-- ***** ミニマップを変更する *****

-- コントロールを追加する
local function AddControlToMiniMap()
	local Parent = ui.GetFrame('minimap');
	-- Map名など
	local lblMapName = tolua.cast(Parent:CreateOrGetControl("richtext", "MapMate_MapName", 0, 0, 200, 20), "ui::CRichText");
	lblMapName:SetGravity(ui.LEFT, ui.BOTTOM);
	lblMapName:SetMargin(4, 0, 0, 2);
	lblMapName:EnableHitTest(1);
	lblMapName:SetText(" ");
	-- 走破率
	local lblFogRate = tolua.cast(Parent:CreateOrGetControl("richtext", "MapMate_FogRate", 0, 0, 80, 20), "ui::CRichText");
	lblFogRate:SetGravity(ui.LEFT, ui.TOP);
	lblFogRate:SetMargin(4, 2, 0, 0);
	lblFogRate:EnableHitTest(0);
	lblFogRate:SetText(" ");
	lblFogRate:ShowWindow(0);

	local lblPCCount = tolua.cast(Parent:CreateOrGetControl("richtext", "MapMate_PCCount", 0, 0, 200, 20), "ui::CRichText");
	lblPCCount:SetGravity(ui.RIGHT, ui.BOTTOM);
	lblPCCount:SetMargin(0, 0, 36, 20);
	lblPCCount:EnableHitTest(1);
	lblPCCount:SetText("{img minimap_0_old 16 16}{s14}{ol}--{/}{/}");

	local lblPCCountRemainingTime = tolua.cast(Parent:CreateOrGetControl("richtext", "MapMate_PCCountRemainingTime", 0, 0, 200, 20), "ui::CRichText");
	lblPCCountRemainingTime:SetGravity(ui.RIGHT, ui.BOTTOM);
	lblPCCountRemainingTime:SetMargin(0, 0, 76, 20);
	lblPCCountRemainingTime:EnableHitTest(1);
	lblPCCountRemainingTime:SetText("{#888888}{s8}{ol}--{/}{/}{/}");

	lblMapName:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_PCCOUNT');
	lblPCCount:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_PCCOUNT');
	lblPCCountRemainingTime:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_PCCOUNT');
	lblPCCount:SetEventScript(ui.LBUTTONDOWN, 'TOUKIBI_LBLPCCOUNT_CLICKED');
	lblPCCountRemainingTime:SetEventScript(ui.LBUTTONDOWN, 'TOUKIBI_LBLPCCOUNT_CLICKED');
end

-- コントロールを移動する
local function ChangeMiniMapControl()
	local strTemp = "";
	local Parent = ui.GetFrame('minimap');
	local TargetControl = GET_CHILD(Parent, "ZOOM_OUT", "ui::CButton");
	TargetControl:SetGravity(ui.RIGHT, ui.BOTTOM);
	TargetControl:SetMargin(0, 0, 2, 2);
	TargetControl:Resize(30, 24);

	TargetControl = GET_CHILD(Parent, "ZOOM_IN", "ui::CButton");
	TargetControl:SetGravity(ui.RIGHT, ui.BOTTOM);
	TargetControl:SetMargin(0, 0, 2, 24);
	TargetControl:Resize(30, 24);

	TargetControl = GET_CHILD(Parent, "open_map", "ui::CButton");
	TargetControl:SetGravity(ui.RIGHT, ui.TOP);
	TargetControl:SetMargin(0, 0, 2, 0);
	TargetControl:Resize(30, 30);

	TargetControl = GET_CHILD(Parent, "ZOOM_INFO", "ui::CRichText");
	TargetControl:SetGravity(ui.RIGHT, ui.TOP);
	TargetControl:SetMargin(0, 4, 36, 0);

	local tmpRight = Parent:GetMargin().right + 30;
	local tmpTop = Parent:GetMargin().top + Parent:GetHeight() - 24;
	local TimeParent = ui.GetFrame('time');
	TimeParent:SetGravity(ui.RIGHT, ui.TOP);
	TimeParent:SetMargin(0, tmpTop, tmpRight, 0);
	TimeParent:Resize(80, 24);

	TargetControl = GET_CHILD(TimeParent, "ampmText", "ui::CRichText");
	TargetControl:SetGravity(ui.LEFT, ui.BOTTOM);
	TargetControl:SetMargin(0, 0, 0, 0);
	TargetControl:Resize(30, 16);
	TargetControl:SetFormat("{s13}{ol}%s{/}");
	strTemp = TargetControl:GetTextByKey("ampm");
	TargetControl:SetTextByKey("ampm", " ");
	TargetControl:SetTextByKey("ampm", strTemp);

	TargetControl = GET_CHILD(TimeParent, "timeText", "ui::CRichText");
	TargetControl:SetGravity(ui.LEFT, ui.BOTTOM);
	TargetControl:SetMargin(36, 0, 0, 0);
	TargetControl:Resize(80, 30);
	TargetControl:SetFormat("{s14}{ol}%s:%s{/}");
	strTemp = TargetControl:GetTextByKey("hour");
	TargetControl:SetTextByKey("hour", " ");
	TargetControl:SetTextByKey("hour", strTemp);

	Me.frame:SetGravity(ui.RIGHT, ui.TOP);
	Me.frame:SetMargin(0, Parent:GetMargin().top, 4, 0);
	Me.frame:ShowWindow(1);

end

function Me.CustomizeMiniMap()
	ChangeMiniMapControl()
	AddControlToMiniMap()
	Me.lblFogRateHideTimer = nil;
	Me.UpdateMapInfo();
	Me.UpdateFogRevealRate();
	UpdatelblPCCount();
	Me.PCCountRemainingTime = 3 * Me.BrinkRadix;
	TOUKIBI_MAPMATE_TIMER_PCCOUNT_START();
-- MapMate.CustomizeMiniMap()
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取

-- 使い方のテキストを出力する
local function PrintHelpToLog()
	local HelpMsg = "{#333333}MapMateのパラメータ説明{/}{nl}{#92D2A0}MapMateは次のパラメータで設定を呼び出してください。{/}{nl}{#333333}'/mapmate [パラメータ]' または '/MapMate [パラメータ]'{/}{nl}{#333333}使用可能なコマンド：{nl}/MapMate reset    :設定リセット{nl}/MapMate update   :表示を更新{nl} ";
	AddLog(HelpMsg, "None", false, false);
end

function TOUKIBI_MAPMATE_PROCESS_COMMAND(command)
	AddLog("スラッシュコマンドが呼び出されました", "Info", true, true);
	local cmd = ""; 
	if #command > 0 then 
		cmd = table.remove(command, 1); 
	else 
		-- Me.Show();
		-- return;
	end 
	if cmd == "reset" then 
		-- すべてをリセット
		MargeDefaultSetting(true, true);
		AddLog("設定をリセットしました。", "Notice", true, false);
		return;
	elseif cmd == "update" then
		-- 表示値の更新
		Me.CustomizeMiniMap();
		return;
	elseif cmd ~= nil and cmd ~= "?" and cmd ~= "" then
		local strError = "無効なコマンドが呼び出されました";
		if #SlashCommandList > 0 then
			strError = strError .. string.format("{nl}コマンド一覧を見るには[ %s ? ]を用いてください", SlashCommandList[1]);
		end
		AddLog(strError, "Warning", true, false);
	end 
	PrintHelpToLog()
end

function TOUKIBI_MAPMATE_BEFORELOADING(frame)
	--CHAT_SYSTEM("ロードします")
end

function TOUKIBI_MAPMATE_ON_GAME_START()
	-- GAME_STARTイベント時から0.5秒待ってみる
	ReserveScript("TOUKIBI_MAPMATE_UPDATE_ALL()", 0.5);
end

function TOUKIBI_MAPMATE_UPDATE_ALL(frame)
	Me.CustomizeMiniMap()
end

function Me.MINIMAP_CHAR_UDT_HOOKED(frame, msg, argStr, argNum)
	Me.HoockedOrigProc["MINIMAP_CHAR_UDT"](frame, msg, argStr, argNum);
	--CHAT_SYSTEM("MINIMAP_CHAR_UDT_HOOKED")
	if ui.GetFrame("loadingbg") ~= nil then return end
	Me.UpdateFogRevealRate()
end

function MAPMATE_ON_INIT(addon, frame)
	Me.addon = addon;
	Me.frame = frame;

	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	if Me.Settings.DoNothing then return end

	Me.timer_pccount = GET_CHILD(Me.frame, "timer_pccount", "ui::CAddOnTimer");
	Me.timer_pccount:SetUpdateScript("TOUKIBI_MAPMATE_TIMER_PCCOUNT_TICK");
	-- イベントを登録する
	addon:RegisterMsg('GAME_START', 'TOUKIBI_MAPMATE_ON_GAME_START');
	addon:RegisterMsg('START_LOADING', 'TOUKIBI_MAPMATE_BEFORELOADING');

	Me.setHook("MINIMAP_CHAR_UDT", Me.MINIMAP_CHAR_UDT_HOOKED);

	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_MAPMATE_PROCESS_COMMAND);
	end
end

-- イベントの飛び先を変更するためのプロシージャ
function Me.setHook(hookedFunctionStr, newFunction)
	if Me.HoockedOrigProc[hookedFunctionStr] == nil then
		Me.HoockedOrigProc[hookedFunctionStr] = _G[hookedFunctionStr];
		_G[hookedFunctionStr] = newFunction;
	else
		_G[hookedFunctionStr] = newFunction;
	end
end 
