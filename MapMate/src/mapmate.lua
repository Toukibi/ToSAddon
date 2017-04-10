local addonName = "MapMate";
local verText = "0.16";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/mapmate", "/mmate", "/MapMate", "/MMate"};
local CommandParamList = {
	reset = {jp = "設定リセット", en = "Reset the all settings."},
	update = {jp = "表示を更新", en = "The additional information displayed will be updated."}
};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
MapMate = Me;
local DebugMode = false;

-- コモンモジュール(の代わり)
local Toukibi = {
	CommonResText = {
		jp = {
			System = {
				NoSaveFileName = "設定の保存ファイル名が指定されていません",
				HasErrorOnSaveSettings = "設定の保存でエラーが発生しました",
				CompleteSaveSettings = "設定の保存が完了しました"
			},
			Help = {
				Title = string.format("{#333333}%sのパラメータ説明{/}", addonName),
				Description = string.format("{#92D2A0}%sは次のパラメータで設定を呼び出してください。{/}", addonName),
				ParamDummy = "[パラメータ]",
				OrText = "または",
				EnableTitle = "使用可能なコマンド"
			}
		},
		en = {
			System = {
				NoSaveFileName = "The filename of save settings is not specified.",
				HasErrorOnSaveSettings = "An error occurred while saving the settings.",
				CompleteSaveSettings = "Saving settings completed."
			},
			Help = {
				Title = string.format("{#333333}Help for %s commands.{/}", addonName),
				Description = string.format("{#92D2A0}To change settings of '%s', please call the following command.{/}", addonName),
				ParamDummy = "[paramaters]",
				OrText = "or",
				EnableTitle = "Available commands"
			}
		}
	},
	
	test = function(self, Caption)
		Caption = Caption or "てすと";
		CHAT_SYSTEM(tostring(Caption));
	end,

	GetDefaultLangCode = function(self)
		if option.GetCurrentCountry() == "Japanese" then
			return "jp";
		else
			return "en";
		end
	end,

	GetTableLen = function(self, tbl)
		local n = 0;
		for _ in pairs(tbl) do
			n = n + 1;
		end
		return n;
	end,

	Split = function(self, str, delim)
		local ReturnValue = {};
		for match in string.gmatch(str, "[^" .. delim .. "]+") do
			table.insert(ReturnValue, match);
		end
		return ReturnValue;
	end,

	GetValue = function(self, obj, Key)
		if obj == nil then return nil end
		if Key == nil or Key == "" then return obj end
		local KeyList = self:Split(Key, ".");
		for i = 1, #KeyList do
			obj = obj[KeyList[i]];
			if obj == nil then return nil end
		end
		return obj;
	end,

	GetResData = function(self, TargetRes, Lang, Key)
		if TargetRes == nil then return nil end
		--CHAT_SYSTEM(string.format("TargetLang : %s", self:GetValue(TargetRes[Lang], Key)))
		--CHAT_SYSTEM(string.format("En : %s", self:GetValue(TargetRes["en"], Key)))
		--CHAT_SYSTEM(string.format("Jp : %s", self:GetValue(TargetRes["jp"], Key)))
		local CurrentRes = self:GetValue(TargetRes[Lang], Key) or self:GetValue(TargetRes["en"], Key) or self:GetValue(TargetRes["jp"], Key);
		return CurrentRes;
	end,

	GetResText = function(self, TargetRes, Lang, Key)
		local ReturnValue = self:GetResData(TargetRes, Lang, Key);
		if ReturnValue == nil then return "<No Data!!>" end
		if type(ReturnValue) == "string" then return ReturnValue end
		return tostring("tostring ==>" .. ReturnValue);
	end,

	-- ***** ログ表示関連 *****
	GetStyledText = function(self, Value, Styles)
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
	end,

	AddLog = function(self, Message, Mode, DisplayAddonName, OnlyDebugMode)
		if Message == nil then return end
		Mode = Mode or "Info";
		if (not DebugMode) and Mode == "Info" then return end
		if (not DebugMode) and OnlyDebugMode then return end
		local HeaderText = "";
		if DisplayAddonName then
			HeaderText = string.format("[%s]", addonName);
		end
		local MsgText = HeaderText .. Message;
		if Mode == "Info" then
			MsgText = self:GetStyledText(MsgText, {"#333333"});
		elseif Mode == "Warning" then
			MsgText = self:GetStyledText(MsgText, {"#331111"});
		elseif Mode == "Caution" then
			MsgText = self:GetStyledText(MsgText, {"#666622"});
		elseif Mode == "Notice" then
			MsgText = self:GetStyledText(MsgText, {"#333366"});
		else
			-- 何もしない
		end
		CHAT_SYSTEM(MsgText);
	end,

	-- 言語切替
	ChangeLanguage = function(self, Lang)
		local msg;
		if self.CommonResText[Lang] == nil then
			msg = string.format("Sorry, '%s' does not implement '%s' mode.{nl}Language mode has not been changed from '%s'.", 
								addonName, Lang, Me.Settings.Lang);
			self:AddLog(msg, "Warning", true, false)
			return;
		end
		Me.Settings.Lang = Lang;
		self:SaveTable(Me.SettingFilePathName, Me.Settings);
		if Me.Settings.Lang == "jp" then
			msg = "日本語モードに切り替わりました";
		else
			msg = string.format("Language mode has been changed to '%s'.", Lang);
		end
		self:AddLog(msg, "Notice", true, false);
	end,

	-- ヘルプテキストを自動生成する
	ShowHelpText = function(self)
		local ParamDummyText = "";
		if SlashCommandList ~= nil and SlashCommandList[1] ~= nil then
			ParamDummyText = ParamDummyText .. "{#333333}";
			ParamDummyText = ParamDummyText .. string.format("'%s %s'", SlashCommandList[1], self:GetResText(self.CommonResText, Me.Settings.Lang, "Help.ParamDummy"));
			if SlashCommandList[2] ~= nil then
				ParamDummyText = ParamDummyText .. string.format(" %s '%s %s'", self:GetResText(self.CommonResText, Me.Settings.Lang, "Help.OrText"), SlashCommandList[2], self:GetResText(self.CommonResText, Me.Settings.Lang, "Help.ParamDummy"));
			end
			ParamDummyText = ParamDummyText .. "{/}{nl}";
		end
		local CommandHelpText = "";
		if CommandParamList ~= nil and self:GetTableLen(CommandParamList) > 0 then
			CommandHelpText = CommandHelpText .. string.format("{#333333}%s：", self:GetResText(self.CommonResText, Me.Settings.Lang, "Help.EnableTitle"));
			for ParamName, DescriptionKey in pairs(CommandParamList) do
				local SpaceCount = 10 - string.len(ParamName);
				local SpaceText = ""
				if SpaceCount > 0 then
					SpaceText = string.rep(" ", SpaceCount)
				end
				CommandHelpText = CommandHelpText .. string.format("{nl}%s %s%s:%s", SlashCommandList[1], ParamName, SpaceText, self:GetResText(DescriptionKey, Me.Settings.Lang));
			end
			CommandHelpText = CommandHelpText .. "{/}{nl} "
		end
		
		self:AddLog(string.format("%s{nl}%s{nl}%s%s"
								, self:GetResText(self.CommonResText, Me.Settings.Lang, "Help.Title")
								, self:GetResText(self.CommonResText, Me.Settings.Lang, "Help.Description")
								, ParamDummyText
								, CommandHelpText
								)
				  , "None", false, false);
	end,

	-- ***** 設定読み書き関連 *****
	SaveTable = function(self, FilePathName, objTable)
		if FilePathName == nil then
			self:AddLog(self:GetResText(self.CommonResText, Me.Settings.Lang, "System.NoSaveFileName"), "Warning", true, false);
		end
		local objFile, objError = io.open(FilePathName, "w")
		if objError then
			self:AddLog(string.format("%s:{nl}%s"
									, self:GetResText(self.CommonResText, Me.Settings.Lang, "System.HasErrorOnSaveSettings")
									, tostring(objError)), "Warning", true, false);
		else
			local json = require('json');
			objFile:write(json.encode(objTable));
			objFile:close();
			self:AddLog(self:GetResText(self.CommonResText, Me.Settings.Lang, "System.CompleteSaveSettings"), "Info", true, true);
		end
	end,

	LoadTable = function(self, FilePathName)
		local acutil = require("acutil");
		local objReadValue, objError = acutil.loadJSON(FilePathName);
		return objReadValue, objError;
	end,

	-- 既存の値がない場合にデフォルト値をマージする
	GetValueOrDefault = function(self, Value, DefaultValue, Force)
		Force = Force or false;
		if Force or Value == nil then
			return DefaultValue;
		else
			return Value;
		end
	end,

	-- ***** コンテキストメニュー関連 *****
	-- セパレータを挿入
	MakeCMenuSeparator = function(self, parent, width)
		width = width or 300;
		ui.AddContextMenuItem(parent, string.format("{img fullgray %s 1}", width), "None");
	end,

	-- コンテキストメニュー項目を作成
	MakeCMenuItem = function(self, parent, text, eventscp, icon, checked)
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
	end,

	-- イベントの飛び先を変更するためのプロシージャ
	SetHook = function(self, hookedFunctionStr, newFunction)
		if Me.HoockedOrigProc[hookedFunctionStr] == nil then
			Me.HoockedOrigProc[hookedFunctionStr] = _G[hookedFunctionStr];
			_G[hookedFunctionStr] = newFunction;
		else
			_G[hookedFunctionStr] = newFunction;
		end
	end 
};
Me.ComLib = Toukibi;

-- テキストリソース
local ResText = {
	jp = {
		Menu = {
			Title = "{#006666}==== MapMateの設定(接続人数更新) ===={/}"
		  , TitleNotice = "{#663333}更新機能はサーバーへの通信を行います。{nl}使用は自己責任でお願いします。{/}"
		  , UpdateNow = "今すぐ更新する"
		  , AutoUpdateBySeconds = "%s秒毎に自動更新"
		  , AutoUpdateByMinutes = "%s分毎に自動更新"
		  , NoAutoUpdate = "自動更新しない"
		  , ManuallyUpdate = "{img minimap_0_old 20 20}をクリックで手動更新する"
		  , ContinuousUpdatePrevention = "更新後5秒間は更新しない"
		  , Close = "閉じる"
		},
		System = {
			ErrorToUseDefaults = "設定の読み込みでエラーが発生したのでデフォルトの設定を使用します。"
		  , CompleteLoadDefault = "デフォルトの設定の読み込みが完了しました。"
		  , CompleteLoadSettings = "設定の読み込みが完了しました"
		  , ExecuteCommands = "コマンド '{#333366}%s{/}' が呼び出されました"
		  , ResetSettings = "設定をリセットしました。"
		  , InvalidCommand = "無効なコマンドが呼び出されました"
		  , AnnounceCommandList = "コマンド一覧を見るには[ %s ? ]を用いてください"
		},
		MapInfo = {
			Title = "のMAP情報"
		  , ExplorationProgress = "探査率"
		  , CardLv = "カードLv"
		  , MaxHate = "最大被ターゲット数"
		},
		DeathPenalty = {
			Title = "デスペナ情報"
		  , LostGem = "ジェム消失"
		  , LostSilver = "%s％のシルバーを消失"
		  , LostCard = "Bossカード消失"
		  , LostBlessStone = "祝福石消失"
		  , Other = "その他のペナルティー(%s)"
		},
		GetConnectionNumber = {
			Title = "接続人数"
		  , Failed = "接続人数の取得に失敗しました"
		  , Cannot = "接続人数の取れないMapです"
		  , Closed = "このチャンネルは閉鎖されています"
		  , StateClosed = "閉鎖"
		}
	},
	en = {
		Menu = {
			Title = "{#006666}======= MapMate setting ======={nl}(connection number update){/}"
		  , TitleNotice = "{#663333}The update function communicates with{nl}the server. Use it at your own risk.{/}"
		  , UpdateNow = "Update now"
		  , AutoUpdateWithInterval = function(self, Value,Unit) string.format("%s%s毎に自動更新", Value, Unit) end
		  , AutoUpdateBySeconds = "Every %ssec. to auto update"
		  , AutoUpdateByMinutes = "Every %smin. to auto update"
		  , NoAutoUpdate = "Do not auto-update"
		  , ManuallyUpdate = "Click on{img minimap_0_old 20 20}to update manually"
		  , ContinuousUpdatePrevention = "Wait for 5sec. after updating"
		  , Close = "Close"
		},
		System = {
			ErrorToUseDefaults = "Since an error occurred in setting loading, switch to the default setting."
		  , CompleteLoadDefault = "Loading of default settings has been completed."
		  , CompleteLoadSettings = "Loading of setting is completed"
		  , ExecuteCommands = "Command '{#333366}%s{/}' was called"
		  , ResetSettings = "The setting was reset."
		  , InvalidCommand = "Invalid command called"
		  , AnnounceCommandList = "Please use [ %s ? ] To see the command list"
		},
		MapInfo = {
			Title = "Infomation of "
		  , ExplorationProgress = "Progress of exploration"
		  , CardLv = "Card Level"
		  , MaxHate = "Maximum number targeted"
		},
		DeathPenalty = {
			Title = "Additional penalty for character's death"
		  , LostGem = "Loss of Gems"
		  , LostSilver = "Loss of %s％ silver"
		  , LostCard = "Loss of boss-cards"
		  , LostBlessStone = "Loss of blessed stone"
		  , Other = "その他のペナルティー(%s)"
		},
		GetConnectionNumber = {
			Title = "Number of people"
		  , Failed = "Failed to get the number of people"
		  , Cannot = "Here is a map that cannot get the number of people"
		  , Closed = "This channel is closed"
		  , StateClosed = "Closed"
		}
	}
};
Me.ResText = ResText;

CHAT_SYSTEM("{#333333}[Add-ons]" .. addonName .. verText .. " loaded!{/}");
--CHAT_SYSTEM("{#333333}[MapMate]コマンド /mmate で表示のON/OFFが切り替えられます{/}");

-- ***** 変数の宣言と設定 *****
Me.SettingFilePathName = string.format("../addons/%s/%s", addonNameLower, SettingFileName);
Me.PCCountSafetyCount = 0;
Me.Loaded = false;
Me.BrinkRadix = 4;


-- 設定書き込み
local function SaveSetting()
	Toukibi:SaveTable(Me.SettingFilePathName, Me.Settings);
end

-- デフォルト設定(ForceがTrueでない場合は、既存の値はそのまま引き継ぐ)
local function MargeDefaultSetting(Force, DoSave)
	DoSave = Toukibi:GetValueOrDefault(DoSave, true);
	Me.Settings = Me.Settings or {};
	Me.Settings.DoNothing = Toukibi:GetValueOrDefault(Me.Settings.DoNothing, false, Force);
	Me.Settings.Lang = Toukibi:GetValueOrDefault(Me.Settings.Lang, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.Movable = Toukibi:GetValueOrDefault(Me.Settings.Movable, false, Force);
	Me.Settings.Visible = Toukibi:GetValueOrDefault(Me.Settings.Visible, true, Force);
	Me.Settings.UpdatePCCountInterval = Toukibi:GetValueOrDefault(Me.Settings.UpdatePCCountInterval, nil, Force);
	Me.Settings.EnableOneClickPCCUpdate = Toukibi:GetValueOrDefault(Me.Settings.EnableOneClickPCCUpdate, false, Force);
	Me.Settings.UsePCCountSafety = Toukibi:GetValueOrDefault(Me.Settings.UsePCCountSafety, true, Force);
	if Force then
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.CompleteLoadDefault"), "Info", true, false);
	end
	if DoSave then SaveSetting() end
end

-- 設定読み込み
local function LoadSetting()
	local objReadValue, objError = Toukibi:LoadTable(Me.SettingFilePathName);
	if objError then

		local CurrentLang = "en"
		if Me.Settings == nil then
			CurrentLang = Toukibi:GetDefaultLangCode() or CurrentLang;
		else
			CurrentLang = Me.Settings.Lang or CurrentLang;
		end
		Toukibi:AddLog(string.format("%s{nl}{#331111}%s{/}", Toukibi:GetResText(ResText, CurrentLang, "System.ErrorToUseDefaults"), tostring(objError)), "Caution", true, false);
		MargeDefaultSetting(true, false);

	else
		Me.Settings = objReadValue;
		MargeDefaultSetting(false, false);
	end
	Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.CompleteLoadSettings"), "Info", true, false);
end

-- ===== アドオンの内容ここから =====

local function CreateToolButton(Parent, Name, left, top, width, height, Icon, StateIcon, Spray)
	local DefSize = 32;
	left = left or 0;
	top = top or 0;
	width = width or DefSize;
	height = height or DefSize;
	local pnlBase = tolua.cast(Parent:CreateOrGetControl("groupbox", Name, left, top, width, height), "ui::CGroupBox");
	pnlBase:SetGravity(ui.LEFT, ui.TOP);
	-- pnlBase:Resize(pRect.width , pRect.height);
	pnlBase:SetSkinName("chat_window");
	pnlBase:EnableScrollBar(0);
	pnlBase:EnableHitTest(1);
	pnlBase:ShowWindow(1);

	local picBase = tolua.cast(pnlBase:CreateOrGetControl("picture", "picBase", 0, 0, width, height), "ui::CPicture");
	picBase:SetGravity(ui.LEFT, ui.TOP);
	picBase:EnableHitTest(0);
	picBase:SetEnableStretch(1);
	picBase:SetImage(Icon);
	picBase:ShowWindow(1);

	return pnlBase
end

function Me.UpdateFrame()
	local ParentWidth = 32;
	local height = 32 + 1;
	local FrameMiniMap = ui.GetFrame('minimap');
	local MyFrame = ui.GetFrame('mapmate');

	MyFrame:Resize(ParentWidth , height * 8);
	MyFrame:SetMargin(0, FrameMiniMap:GetMargin().top, 1, 0);
	local pnlBase = tolua.cast(MyFrame:CreateOrGetControl("groupbox", "pnlInput", 0, 8, ParentWidth , height * 8), 
							   "ui::CGroupBox");
	
	pnlBase:SetGravity(ui.RIGHT, ui.TOP);
	pnlBase:SetMargin(0, 0, 0, 0);
	pnlBase:Resize(ParentWidth , height * 8);
	pnlBase:SetSkinName("chat_window");
	pnlBase:EnableScrollBar(0);
	pnlBase:EnableHitTest(1);

	-- アイコン案
	-- expert_info_gauge_image :ちょっとしょぼい
	CreateToolButton(pnlBase, "btnMOB"		, 0, height * 0, nil, nil, "icon_state_medium")
	CreateToolButton(pnlBase, "btnQuest"	, 0, height * 1, nil, nil, "minimap_1_SUB")
	CreateToolButton(pnlBase, "btnNPC"		, 0, height * 2, nil, nil, "minimap_0")
	CreateToolButton(pnlBase, "btnConnect"	, 0, height * 3, nil, nil, "minimap_goddess")
end












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
							 .. "  {img journal_map_icon 16 16}%s:%s{nl}"
							 .. "  {img icon_item_expcard 16 16}%s: %s{nl}"
							 .. "  {img channel_mark_empty 16 16}%s: %s{nl}"
							 .. "%s{/}{/}"
							  , Me.ThisMapInfo.Stars
							  , Me.ThisMapInfo.strLv
							  , Me.ThisMapInfo.MapSymbol
							  , Me.ThisMapInfo.Name
							  , Me.ThisMapInfo.MapClassName
							  , Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ExplorationProgress")
							  , Me.ThisMapInfo.FogRevealRate or ""
							  , Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.CardLv")
							  , Me.ThisMapInfo.strExpCardLv
							  , Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.MaxHate")
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
		elseif Me.lblFogRateHideTimer >= 0 and math.fmod(Me.lblFogRateHideTimer, Me.BrinkRadix) > 0 then
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
		strTipTemp = Toukibi:GetResText(ResText, Me.Settings.Lang, "GetConnectionNumber.Failed");
	elseif Me.ThisMapInfo.PCCount < -1 then
		-- 取れないMap
		strTemp = "--";
		strTipTemp = Toukibi:GetResText(ResText, Me.Settings.Lang, "GetConnectionNumber.Cannot");
	elseif Me.ThisMapInfo.PCCount == -1 then
		-- 閉鎖
		strTemp = Toukibi:GetResText(ResText, Me.Settings.Lang, "GetConnectionNumber.StateClosed");
		strTipTemp = Toukibi:GetResText(ResText, Me.Settings.Lang, "GetConnectionNumber.Closed");
	else
		strTemp = Me.ThisMapInfo.PCCount;
		strTipTemp = string.format("%s:%s/%s", Toukibi:GetResText(ResText, Me.Settings.Lang, "GetConnectionNumber.Title"), Me.ThisMapInfo.PCCount, session.serverState.GetMaxPCCount())
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
		local strTemp = "{#663333}" .. Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.Title") .. "：";
		for w in string.gmatch(strReadData, "%w+") do
			if string.find(w, "gem") then
				strTemp = strTemp .. string.format("{nl}  %s Lv.%s", Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.LostGem"), string.gsub(w, "gem", ""));
			elseif string.find(w, "silver") then
				strTemp = strTemp .. string.format("{nl}  " .. Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.LostSilver"), string.gsub(w, "silver", ""));
			elseif string.find(w, "card") then
				strTemp = strTemp .. string.format("{nl}  %s Lv.%s", Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.LostCard"), string.gsub(w, "card", ""));
			elseif string.find(w, "blessstone") then
				strTemp = strTemp .. string.format("{nl}  %s Lv.%s", Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.LostBlessStone"), string.gsub(w, "blessstone", ""));
			else
				strTemp = strTemp .. string.format("{nl}  %s (%s)", Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.Other"), w)
			end
		end
		strTemp = strTemp .. "{nl}{/}";
		Me.ThisMapInfo.DeathPenaltyText = strTemp;
	else
		Me.ThisMapInfo.DeathPenaltyText = nil
	end
	UpdatelblMapName();
end

-- NPC情報
function Me.GetMapNPCInfo(MapClassName)
	-- session.GetMapNPCState(session.GetMapName()):FindAndGet(GenType)
	-- で会ったかどうかがわかる(0：まだ　それ以外：話した・開けた事がある)


	if ui.GetFrame("loadingbg") ~= nil then return nil end
	MapClassName = MapClassName or session.GetMapName();

	local MapInfo = {};
	MapInfo.ClassName = MapClassName;
	local myColls = session.GetMySession():GetCollection();
	-- MapInfo.Collection = 
	MapInfo.NpcState = session.GetMapNPCState(MapInfo.ClassName);
	MapInfo.Property = geMapTable.GetMapProp(MapInfo.ClassName);
	
	MapInfo.ClassList, MapInfo.ClassCount = GetClassList("GenType_" .. MapInfo.ClassName);
	MapInfo.MonGens = MapInfo.Property.mongens;
	if MapInfo.MonGens == nil then return MapInfo end

	local NoMeetNPC = {};
	local cnt = MapInfo.MonGens:Count();
	for i = 0 , cnt - 1 do 
		local MonProp = MapInfo.MonGens:Element(i);
		local IESData_GenType = GetClassByIndexFromList(MapInfo.ClassList, i);

-- CHAT_SYSTEM(i .. ":" .. MonProp:GetName() .. ":" .. g.mapNpcState:FindAndGet(MonProp.GenType));
		-- if string.find(string.lower(MonProp:GetDialog()),"treasurebox") then
		if IESData_GenType.Faction == "Neutral" and IESData_GenType.Minimap > 0 then
			CHAT_SYSTEM(string.format("[%s](%s) %s", IESData_GenType.GenType, MapInfo.NpcState:FindAndGet(IESData_GenType.GenType), IESData_GenType.Name))
			if MapInfo.NpcState:FindAndGet(IESData_GenType.GenType) == 0 then
				table.insert(NoMeetNPC, {
					Name = IESData_GenType.Name
				  , NpcState = MapInfo.NpcState:FindAndGet(IESData_GenType.GenType)
				  , ClassID = IESData_GenType.ClassID
				  , ClassName = IESData_GenType.ClassType
				  , GenType = IESData_GenType.GenType
				  , Hide = IESData_GenType.Hide
				  , Dialog = IESData_GenType.Dialog
				  , ArgStr1 = IESData_GenType.ArgStr1
				  , ArgStr2 = IESData_GenType.ArgStr2
				  , ArgStr3 = IESData_GenType.ArgStr3
				});
			end
		end
	end
	return NoMeetNPC;
	-- return MapInfo
end

-- モンスター情報
function Me.GetMapMonsterInfo()

end
-- Mapの接続人数を更新する
function Me.UpdatePCCount()
	if ui.GetFrame("loadingbg") ~= nil then return end
	if Me.PCCountSafetyCount ~= nil and Me.PCCountSafetyCount > 0 then return end
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
		Me.PCCountSafetyCount = Me.BrinkRadix * 5;
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
	if Me.PCCountSafetyCount ~= nil and Me.PCCountSafetyCount > 0 then
		Me.PCCountSafetyCount = Me.PCCountSafetyCount - 1;
	end
	local Parent = ui.GetFrame('minimap');
	local TargetControl = GET_CHILD(Parent, "MapMate_PCCountRemainingTime", "ui::CRichText");
	local strRemainingTime = "---";
	if Me.Settings.UpdatePCCountInterval ~= nil then
		strRemainingTime = string.format("%d", Me.PCCountRemainingTime / Me.BrinkRadix + 0.9);
	end
	if TargetControl ~= nil then
		local TextColor = "#888888";
		if Me.PCCountSafetyCount ~= nil and Me.PCCountSafetyCount > 0 then
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
	if Me.BrinkRadix == nil or (Me.BrinkRadix <= 0 and Me.BrinkRadix > 100) then
		Me.BrinkRadix = 4;
	end
	Me.timer_pccount:Start(1 / Me.BrinkRadix);
end

function TOUKIBI_MAPMATE_TIMER_PCCOUNT_STOP()
	CHAT_SYSTEM("timer stop!");
	Me.timer_pccount:Stop();
end

-- ***** コンテキストメニューを作成する *****

-- 接続人数更新設定のコンテキストメニュー
function TOUKIBI_MAPMATE_CONTEXT_MENU_PCCOUNT(frame, ctrl)
	local Title = string.format("%s{nl}%s"
							  , Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Title")
							  , Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.TitleNotice")
							  );
	local context = ui.CreateContextMenu("DURMINI_MAIN_RBTN", Title, 0, 0, 320, 0);
	Toukibi:MakeCMenuSeparator(context, 300);
	Toukibi:MakeCMenuItem(context, string.format("{#FFFF88}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.UpdateNow")), "TOUKIBI_MAPMATE_EXEC_PCCUPDATE()", nil, nil);
	Toukibi:MakeCMenuSeparator(context, 301);
	Toukibi:MakeCMenuItem(context, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateBySeconds"), 10), "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(10)", nil, Me.Settings.UpdatePCCountInterval == 10);
	Toukibi:MakeCMenuItem(context, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateBySeconds"), 20), "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(20)", nil, Me.Settings.UpdatePCCountInterval == 20);
	Toukibi:MakeCMenuItem(context, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateBySeconds"), 30), "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(30)", nil, Me.Settings.UpdatePCCountInterval == 30);
	Toukibi:MakeCMenuItem(context, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateByMinutes"), 1) , "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(60)", nil, Me.Settings.UpdatePCCountInterval == 60);
	Toukibi:MakeCMenuItem(context, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateByMinutes"), 3) , "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(180)", nil, Me.Settings.UpdatePCCountInterval == 180);
	Toukibi:MakeCMenuItem(context, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateByMinutes"), 5) , "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(300)", nil, Me.Settings.UpdatePCCountInterval == 300);
	Toukibi:MakeCMenuItem(context, string.format("{#8888FF}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.NoAutoUpdate")), "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(nil)", nil, Me.Settings.UpdatePCCountInterval == nil);
	Toukibi:MakeCMenuSeparator(context, 302);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ManuallyUpdate"), "TOUKIBI_MAPMATE_TOGGLEPROP('EnableOneClickPCCUpdate')", nil, Me.Settings.EnableOneClickPCCUpdate);
	Toukibi:MakeCMenuItem(context, string.format("{#8888FF}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ContinuousUpdatePrevention")), "TOUKIBI_MAPMATE_TOGGLEPROP('UsePCCountSafety')", nil, Me.Settings.UsePCCountSafety);
	Toukibi:MakeCMenuSeparator(context, 303);
	Toukibi:MakeCMenuItem(context, string.format("{#666666}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Close")));
	context:Resize(330, context:GetHeight());
	ui.OpenContextMenu(context);
	return context;
end

-- ***** コンテキストメニューのイベント受け *****

function TOUKIBI_MAPMATE_TOGGLEPROP(Name, Value)
	if Name == nil then return end
	if Me.Settings == nil then return end
	if Value == "nil" or type(Value) ~= "boolean" then
		Me.Settings[Name] = not Me.Settings[Name];
	else
		Me.Settings[Name] = Value;
	end
	SaveSetting();
end

function TOUKIBI_MAPMATE_CHANGEPROP(Name, Value)
	if Name == nil then return end
	if Me.Settings == nil then return end
	if Value == "nil" then Value = nil end
	Me.Settings[Name] = Value
	SaveSetting();
end

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

	local MyFrame = ui.GetFrame("mapmate")
	MyFrame:SetGravity(ui.RIGHT, ui.TOP);
	MyFrame:SetMargin(0, Parent:GetMargin().top, 4, 0);
	MyFrame:ShowWindow(1);

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
function TOUKIBI_MAPMATE_PROCESS_COMMAND(command)
	Toukibi:AddLog(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ExecuteCommands"), SlashCommandList[1] .. " " .. table.concat(command, " ")), "Info", true, true);
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
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ResetSettings"), "Notice", true, false);
		return;
	elseif cmd == "update" then
		-- 表示値の更新
		Me.CustomizeMiniMap();
		return;
	elseif cmd == "jp" or cmd == "en" or string.len(cmd) == 2 then
		-- 言語モードと勘違いした？
		Me.ComLib:ChangeLanguage(cmd);
		Me.CustomizeMiniMap()
		return;
	elseif cmd ~= nil and cmd ~= "?" and cmd ~= "" then
		local strError = Toukibi:GetResText(ResText, Me.Settings.Lang, "System.InvalidCommand");
		if #SlashCommandList > 0 then
			strError = strError .. string.format("{nl}" .. Toukibi:GetResText(ResText, Me.Settings.Lang, "System.AnnounceCommandList"), SlashCommandList[1]);
		end
		Toukibi:AddLog(strError, "Warning", true, false);
	end 
	Me.ComLib:ShowHelpText()
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

Me.HoockedOrigProc = Me.HoockedOrigProc or {};
function MAPMATE_ON_INIT(addon, frame)
	Me.addon = addon;
	Me.frame = frame;

	-- 設定を読み込む
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	if Me.Settings.DoNothing then return end

	Me.timer_pccount = GET_CHILD(ui.GetFrame("mapmate"), "timer_pccount", "ui::CAddOnTimer");
	Me.timer_pccount:SetUpdateScript("TOUKIBI_MAPMATE_TIMER_PCCOUNT_TICK");
	-- イベントを登録する
	addon:RegisterMsg('GAME_START', 'TOUKIBI_MAPMATE_ON_GAME_START');
	addon:RegisterMsg('START_LOADING', 'TOUKIBI_MAPMATE_BEFORELOADING');

	Toukibi:SetHook("MINIMAP_CHAR_UDT", Me.MINIMAP_CHAR_UDT_HOOKED);

	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_MAPMATE_PROCESS_COMMAND);
	end
end
