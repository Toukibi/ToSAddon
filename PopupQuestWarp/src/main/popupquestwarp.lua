local addonName = "PopupQuestWarp";
local verText = "1.00";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/ppqw"} -- {"/コマンド1", "/コマンド2", .......};
local CommandParamList = {
	reset = {jp = "設定リセット", en = "Reset the all settings."}
  , resetpos = {jp = "位置をリセット", en = "Reset the position."}
  , rspos = {jp = "位置をリセット", en = "Reset the position."}
  , refresh = {jp = "表示と位置を更新", en = "Update the position and values."}
  , update = {jp = "表示を更新", en = "Redraw main window."}
};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
--PPQW = Me;
local DebugMode = false;

-- テキストリソース
local ResText = {
	jp = {
		Menu = {
			Title = "{#006666}==== PopupQuestWarpの設定 ===={/}"
		  , Title_Horizontal = "縦/横 表示"
		  , Vertical = "縦"
		  , Horizontal = "横"
		  , Title_EscapeStoneVisible = "表示する帰還石"
		  , EscapeStone = "帰還石"
		  , EscapeStone_Klaipeda = "クラペダ帰還石"
		  , EscapeStone_Orsha = "オルシャ帰還石"
		  , UpdateNow = "{#FFFF88}今すぐ更新する{/}"
		  , LockPosition = "位置を固定する"
		  , ResetPosition = "位置をリセット"
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
		}
	},
	en = {
		Menu = {
			Title = "{#006666}======= PopupQuestWarp setting ======={/}"
		  , Title_Horizontal = "Orientation"
		  , Vertical = "Vertical"
		  , Horizontal = "Horizontal"
		  , Title_EscapeStoneVisible = "Display Buttons"
		  , EscapeStone = "Warpstone"
		  , EscapeStone_Klaipeda = "Klaipeda Warpstone"
		  , EscapeStone_Orsha = "Orsha Warpstone"
		  , UpdateNow = "{#FFFF88}Update now!{/}"
		  , LockPosition = "Lock position"
		  , ResetPosition = "Reset position"
		  , Close = "Close"
		},
		System = {
			ErrorToUseDefaults = "Using default settings because an error occurred while loading the settings."
			, CompleteLoadDefault = "Default settings loaded."
			, CompleteLoadSettings = "Settings loaded!"
			, ExecuteCommands = "Command '{#333366}%s{/}' was called."
			, ResetSettings = "Settings resetted."
			, InvalidCommand = "Invalid command called."
			, AnnounceCommandList = "Please use [ %s ? ] to see the command list."
		  }
	}
};
Me.ResText = ResText;

-- コモンモジュール(の代わり)
local Toukibi = {
	CommonResText = {
		jp = {
			System = {
				NoSaveFileName = "設定の保存ファイル名が指定されていません"
			  , HasErrorOnSaveSettings = "設定の保存でエラーが発生しました"
			  , CompleteSaveSettings = "設定の保存が完了しました"
			  , ErrorToUseDefaults = "設定の読み込みでエラーが発生したのでデフォルトの設定を使用します。"
			  , CompleteLoadDefault = "デフォルトの設定の読み込みが完了しました。"
			  , CompleteLoadSettings = "設定の読み込みが完了しました"
			},
			Command = {
				ExecuteCommands = "コマンド '{#333366}%s{/}' が呼び出されました"
			  , ResetSettings = "設定をリセットしました。"
			  , InvalidCommand = "無効なコマンドが呼び出されました"
			  , AnnounceCommandList = "コマンド一覧を見るには[ %s ? ]を用いてください"
				},
			Help = {
				Title = string.format("{#333333}%sのパラメータ説明{/}", addonName)
			  , Description = string.format("{#92D2A0}%sは次のパラメータで設定を呼び出してください。{/}", addonName)
			  , ParamDummy = "[パラメータ]"
			  , OrText = "または"
			  , EnableTitle = "使用可能なコマンド"
			}
		},
		en = {
			System = {
				InitMsg = "[Add-ons]" .. addonName .. verText .. " loaded!"
			  , NoSaveFileName = "Save settings filename is not specified."
			  , HasErrorOnSaveSettings = "An error occurred while saving the settings."
			  , CompleteSaveSettings = "Settings saved."
			  , ErrorToUseDefaults = "Using default settings because an error occurred while loading the settings."
			  , CompleteLoadDefault = "Default settings loaded."
			  , CompleteLoadSettings = "Settings loaded!"
			},
			Command = {
				ExecuteCommands = "Command '{#333366}%s{/}' was called"
			  , ResetSettings = "Settings have been reset."
			  , InvalidCommand = "Invalid command called."
			  , AnnounceCommandList = "Please use [ %s ? ] to see the command list."
				},
			Help = {
				Title = string.format("{#333333}Help for %s commands.{/}", addonName)
			  , Description = string.format("{#92D2A0}To change settings of '%s', please call the following command.{/}", addonName)
			  , ParamDummy = "[paramaters]"
			  , OrText = "or"
			  , EnableTitle = "Commands available"
			}
		},
		kr = {
			System = {
				NoSaveFileName = "설정의 저장파일명이 지정되지 않았습니다"
			  , HasErrorOnSaveSettings = "설정 저장중 에러가 발생했습니다"
			  , CompleteSaveSettings = "설정 저장이 완료되었습니다"
			  , ErrorToUseDefaults = "설정 불러오기에 에러가 발생했으므로 기본 설정을 사용합니다"
			  , CompleteLoadDefault = "기본 설정 불러오기가 완료되었습니다"
			  , CompleteLoadSettings = "설정을 불러들였습니다"
			},
			Command = {
				ExecuteCommands = "명령 '{#333366}%s{/}' 를 불러왔습니다"
			  , ResetSettings = "설정을 초기화하였습니다"
			  , InvalidCommand = "무효한 명령을 불러왔습니다"
			  , AnnounceCommandList = "명령일람을 보려면[ %s ? ]를 사용해주세요"
				},
			Help = {
				Title = string.format("{#333333}%s의 패러미터 설명{/}", addonName)
			  , Description = string.format("{#92D2A0}%s는 다음 패러미터로 설정을 불러와주세요{/}", addonName)
			  , ParamDummy = "[패러미터]"
			  , OrText = "또는"
			  , EnableTitle = "사용가능한 명령"
			}
		}
	},
	
	Log = function(self, Caption)
		if Caption == nil then Caption = "Test Printing" end
		Caption = tostring(Caption) or "Test Printing";
		CHAT_SYSTEM(tostring(Caption));
	end,

	GetDefaultLangCode = function(self)
		if option.GetCurrentCountry() == "Japanese" then
			return "jp";
		elseif option.GetCurrentCountry() == "Korean" then
			return "kr";
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
			local index = KeyList[i]
			obj = obj[index];
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
			CommandHelpText = CommandHelpText .. string.format("{#333333}%s: ", self:GetResText(self.CommonResText, Me.Settings.Lang, "Help.EnableTitle"));
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
	MakeCMenuSeparator = function(self, parent, width, text, style)
		width = width or 300;
		text = text or "";
		style = style or {"ol", "b", "s12", "#AAFFAA"}
		local strTemp = string.format("{img fullgray %s 1}", width);
		if text ~= "" then
			strTemp = strTemp .. "{s4} {/}{nl}" .. self:GetStyledText(text, style);
		end
		ui.AddContextMenuItem(parent, string.format(strTemp, width), "None");
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
	-- コンテキストメニュー項目を作成(中間にチェックがあるタイプ)
	MakeCMenuItemHasCheckInTheMiddle = function(self, parent, textBefore, textAfter, eventscp, icon, checked)
		textBefore = textBefore or "";
		textAfter = textAfter or "";
		local CheckIcon = "";
		local ImageIcon = "";
		local eventscp = eventscp or "None";
		if checked == nil then
			CheckIcon = "";
		elseif checked == true then
			CheckIcon = "{img socket_slot_check 24 24}";
		elseif checked == false  then
			CheckIcon = "{img channel_mark_empty 24 24}";
		end
		if icon == nil then
			ImageIcon = "";
		else
			ImageIcon = string.format("{img %s 24 24} ", icon);
		end
		ui.AddContextMenuItem(parent, string.format("%s%s%s%s", ImageIcon, textBefore, CheckIcon, textAfter), eventscp);
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
local function log(value)
	Toukibi:Log(value);
end
local function view(objValue)
	local frame = ui.GetFrame("developerconsole");
	--DEVELOPERCONSOLE_PRINT_TEXT("{#444444}type of {#005500}"  .. objName .. "{/} is {#005500}" .. type(objValue) .. "{/}{/}", "white_16_ol");
	DEVELOPERCONSOLE_PRINT_TEXT("{nl} ")
	DEVELOPERCONSOLE_PRINT_VALUE(frame, "", objValue, "", nil, true);
end
local function try(f, ...)
	local status, error = pcall(f, ...)
	if not status then
		return tostring(error);
	else
		return "OK"
	end
end
local function FunctionExists(func)
	if func == nil then
		return false
	else
		return true
	end
end

local function ShowInitializeMessage()
	local CurrentLang = "en"
	if Me.Settings == nil then
		CurrentLang = Toukibi:GetDefaultLangCode() or CurrentLang;
	else
		CurrentLang = Me.Settings.Lang or CurrentLang;
	end

	CHAT_SYSTEM(string.format("{#333333}%s{/}", Toukibi:GetResText(Toukibi.CommonResText, CurrentLang, "System.InitMsg")))
--	CHAT_SYSTEM(string.format("{#333366}[%s]%s{/}", addonName, Toukibi:GetResText(ResText, CurrentLang, "Log.InitMsg")))
end
ShowInitializeMessage()

-- ==================================
--  設定関連
-- ==================================

Me.SettingFilePathName = string.format("../addons/%s/%s", addonNameLower, SettingFileName);
Me.Loaded = false;

-- 設定書き込み
local function SaveSetting()
	Toukibi:SaveTable(Me.SettingFilePathName, Me.Settings);
end

-- デフォルト設定(ForceがTrueでない場合は、既存の値はそのまま引き継ぐ)
local function MargeDefaultSetting(Force, DoSave)
	DoSave = Toukibi:GetValueOrDefault(DoSave, true);
	Me.Settings = Me.Settings or {};
	Me.Settings.DoNothing	= Toukibi:GetValueOrDefault(Me.Settings.DoNothing	, false, Force);
	Me.Settings.Lang		= Toukibi:GetValueOrDefault(Me.Settings.Lang		, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.PosX		= Toukibi:GetValueOrDefault(Me.Settings.PosX		, nil, Force);
	Me.Settings.PosY		= Toukibi:GetValueOrDefault(Me.Settings.PosY		, nil, Force);
	Me.Settings.Movable		= Toukibi:GetValueOrDefault(Me.Settings.Movable		, true, Force);
	Me.Settings.Visible		= Toukibi:GetValueOrDefault(Me.Settings.Visible		, true, Force);
	Me.Settings.Horizontal	= Toukibi:GetValueOrDefault(Me.Settings.Horizontal	, true, Force);

	Me.Settings.DisplayEscapeStone			= Toukibi:GetValueOrDefault(Me.Settings.DisplayEscapeStone			, true, Force);
	Me.Settings.DisplayEscapeStoneKlaipeda	= Toukibi:GetValueOrDefault(Me.Settings.DisplayEscapeStoneKlaipeda	, true, Force);
	Me.Settings.DisplayEscapeStoneOrsha		= Toukibi:GetValueOrDefault(Me.Settings.DisplayEscapeStoneOrsha		, false, Force);



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

Me.InvItemData = {};
function Me.GetInvItemData()
	-- ヒットさせるリストを作る
	local SearchTarget = {};
	SearchTarget["EscapeStone_Orsha"] = 1;
	SearchTarget["EscapeStone_Klaipeda"] = 1;
	SearchTarget["Escape_Orb"] = 1;
	SearchTarget["Scroll_Warp_Klaipe"] = 1;
	SearchTarget["Scroll_Warp_Orsha"] = 1;
	SearchTarget["Scroll_Warp_Fedimian"] = 1;

	local tmpList = {};
	session.BuildInvItemSortedList();
	local InvList = session.GetInvItemList();
	local GuidList = InvList:GetGuidList();
	local GuidCount = GuidList:Count();
	for i = 0, GuidCount - 1 do
		local Guid = GuidList:Get(i);
		local InvItem = InvList:GetItemByGuid(Guid);
		if InvItem ~= nil then
			local ItemObj = InvItem:GetObject();
			if ItemObj ~= nil then
				local ItemIESObj = GetIES(ItemObj);
				if ItemIESObj ~= nil then
					if SearchTarget[ItemIESObj.ClassName] == 1 then
						local tmpRecord		= {};
						tmpRecord.Guid		= Guid;
						tmpRecord.IESObj	= ItemIESObj;
						tmpRecord.Name		= ItemIESObj.Name;
						tmpRecord.Count		= InvItem.count;
						tmpRecord.Icon		= ItemIESObj.Icon;

						tmpList[ItemIESObj.ClassName] = tmpRecord;
					end
				end
			end
		end
	end
	return tmpList;
end

-- メインフレームの描写更新

local function CreateToolButton(Parent, Name, left, top, width, height, Icon)
	local DefSize = 28;
	left = left or 0;
	top = top or 0;
	width = width or DefSize;
	height = height or DefSize;
	local pnlBase = tolua.cast(Parent:CreateOrGetControl("groupbox", Name, left, top, width, height), "ui::CGroupBox");
	pnlBase:SetGravity(ui.LEFT, ui.TOP);
	pnlBase:SetSkinName("chat_window");
	pnlBase:EnableScrollBar(0);
	pnlBase:EnableHitTest(1);
	pnlBase:ShowWindow(1);
	pnlBase:SetOverSound('button_cursor_over_3');
	pnlBase:SetClickSound('button_click_stats');

	local picBase = tolua.cast(pnlBase:CreateOrGetControl("picture", "picBase", 0, 0, width, height), "ui::CPicture");
	picBase:SetGravity(ui.LEFT, ui.TOP);
	picBase:EnableHitTest(0);
	picBase:SetEnableStretch(1);
	picBase:SetImage(Icon);
	picBase:ShowWindow(1);

	return pnlBase
end

local function CreateSpacer(Parent, Name, left, top, width, height, SkinName)
	SkinName = SkinName or "chat_window";
	local pnlBase = tolua.cast(Parent:CreateOrGetControl("groupbox", Name, left, top, width, height), "ui::CGroupBox");
	pnlBase:SetGravity(ui.LEFT, ui.TOP);
	pnlBase:SetSkinName(SkinName);
	pnlBase:EnableScrollBar(0);
	pnlBase:EnableHitTest(0);
	pnlBase:ShowWindow(1);

	return pnlBase;
end

local function UpdateMainFrame()
	local BaseSize = 28;
	local Margin = 2;
	local TopFrame = ui.GetFrame(addonNameLower);
	if TopFrame == nil then return end
	TopFrame:SetSkinName("chat_window");
	TopFrame:SetEventScript(ui.RBUTTONDOWN, "TOUKIBI_POPUPQUESTWARP_CONTEXT_MENU");
	DESTROY_CHILD_BYNAME(TopFrame, "btn")

	local objButton = nil;
	local objPanel = nil;
	local ButtonCount = 0;
	local CurX = 0;
	local CurY = 0;

	-- セパレータ挿入1
	if Me.Settings.Horizontal then
		-- objPanel = CreateSpacer(TopFrame, "pnlSpacer1", CurX, CurY, 8, BaseSize, "systemmenu_vertical");
		objPanel = CreateSpacer(TopFrame, "pnlSpacer1", CurX, CurY, 8, BaseSize);
		CurX = CurX + 8;
	else
		objPanel = CreateSpacer(TopFrame, "pnlSpacer1", CurX, CurY, BaseSize, 8);
		CurY = CurY + 8;
	end

	objButton = CreateToolButton(TopFrame, "btnQuestPopup", CurX, CurY, BaseSize, BaseSize, "questinfo_return");
	objButton:SetGravity(ui.LEFT, ui.TOP);
	objButton:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_POPUPQUESTWARP_MOUSEMOVE");
	objButton:SetEventScript(ui.RBUTTONDOWN, "TOUKIBI_POPUPQUESTWARP_CONTEXT_MENU");
	ButtonCount = ButtonCount + 1
	if Me.Settings.Horizontal then
		CurX = CurX + BaseSize;
	else
		CurY = CurY + BaseSize;
	end

	if Me.Settings.DisplayEscapeStone or Me.Settings.DisplayEscapeStoneKlaipeda or Me.Settings.DisplayEscapeStoneOrsha then
		-- セパレータ挿入2
		if Me.Settings.Horizontal then
			objPanel = CreateSpacer(TopFrame, "pnlSpacer2", CurX + 1, CurY, 18, BaseSize, "None");
			CurX = CurX + 20;
		else
			objPanel = CreateSpacer(TopFrame, "pnlSpacer2", CurX, CurY + 1, BaseSize, 18, "None");
			CurY = CurY + 20;
		end
	end

	local tmpItemClassName = "";
	local ItemData = nil;
	if Me.Settings.DisplayEscapeStone then
		tmpItemClassName = "Escape_Orb"
		ItemData =  Me.InvItemData[tmpItemClassName];
		if ItemData ~= nil then
			objButton = CreateToolButton(TopFrame, "btnEscapeOrb", CurX, CurY, BaseSize, BaseSize, ItemData.Icon);
			objButton:SetGravity(ui.LEFT, ui.TOP);
			objButton:SetTextTooltip(ItemData.Name)
			objButton:SetEventScript(ui.LBUTTONUP, "TOUKIBI_POPUPQUESTWARP_ITEMBTNCLICK");
			objButton:SetEventScriptArgString(ui.LBUTTONUP, tmpItemClassName);
			objButton:SetEventScript(ui.RBUTTONDOWN, "TOUKIBI_POPUPQUESTWARP_CONTEXT_MENU");
			ButtonCount = ButtonCount + 1
			if Me.Settings.Horizontal then
				CurX = CurX + BaseSize + Margin;
			else
				CurY = CurY + BaseSize + Margin;
			end
		end
	end

	if Me.Settings.DisplayEscapeStoneKlaipeda then
		tmpItemClassName = "EscapeStone_Klaipeda"
		ItemData =  Me.InvItemData[tmpItemClassName];
		if ItemData ~= nil then
			objButton = CreateToolButton(TopFrame, "btnEscapeKlaipeda", CurX, CurY, BaseSize, BaseSize, ItemData.Icon);
			objButton:SetGravity(ui.LEFT, ui.TOP);
			objButton:SetTextTooltip(ItemData.Name)
			objButton:SetEventScript(ui.LBUTTONUP, "TOUKIBI_POPUPQUESTWARP_ITEMBTNCLICK");
			objButton:SetEventScriptArgString(ui.LBUTTONUP, tmpItemClassName);
			objButton:SetEventScript(ui.RBUTTONDOWN, "TOUKIBI_POPUPQUESTWARP_CONTEXT_MENU");
			ButtonCount = ButtonCount + 1
			if Me.Settings.Horizontal then
				CurX = CurX + BaseSize + Margin;
			else
				CurY = CurY + BaseSize + Margin;
			end
		end
	end

	if Me.Settings.DisplayEscapeStoneOrsha then
		tmpItemClassName = "EscapeStone_Orsha"
		ItemData =  Me.InvItemData[tmpItemClassName];
		if ItemData ~= nil then
			objButton = CreateToolButton(TopFrame, "btnEscapeOrsha", CurX, CurY, BaseSize, BaseSize, ItemData.Icon);
			objButton:SetGravity(ui.LEFT, ui.TOP);
			objButton:SetTextTooltip(ItemData.Name)
			objButton:SetEventScript(ui.LBUTTONUP, "TOUKIBI_POPUPQUESTWARP_ITEMBTNCLICK");
			objButton:SetEventScriptArgString(ui.LBUTTONUP, tmpItemClassName);
			objButton:SetEventScript(ui.RBUTTONDOWN, "TOUKIBI_POPUPQUESTWARP_CONTEXT_MENU");
			ButtonCount = ButtonCount + 1
			if Me.Settings.Horizontal then
				CurX = CurX + BaseSize + Margin;
			else
				CurY = CurY + BaseSize + Margin;
			end
		end
	end

	-- 伸びない方のサイズを求める
	if Me.Settings.Horizontal then
		CurY = BaseSize;
	else
		CurX = BaseSize;
	end
	TopFrame:Resize(CurX, CurY);


	TopFrame:ShowWindow(1);

	--log("Update Complete!")
end



local function ChangeRotateStatus()
	local TopFrame = ui.GetFrame(addonNameLower);
	if TopFrame == nil then return end
	local objSubFrame = ui.GetFrame("popupquestwarpsub");
	if objSubFrame == nil then return end
	local objBtnQuest = TopFrame:GetChild("btnQuestPopup");
	if objBtnQuest == nil then return end
	local picBtnQuest = objBtnQuest:GetChild("picBase");
	if picBtnQuest == nil then return end
	if 0 == objSubFrame:IsVisible() then
		picBtnQuest:SetAngleLoop(0);
	else
		picBtnQuest:SetAngleLoop(-4);
	end
end

local function GetTimeEx(Sec)
	local timeTxt = "";
	local d, h, m, s = GET_DHMS(math.ceil(Sec));
	local ret = "";
	local started = 0;
	if d > 0 then
		timeTxt = string.format("%sd", d);
	elseif h > 1 then
		timeTxt = string.format("%sh", h);
	elseif m > 1 then
		timeTxt = string.format("%sm", m + h * 60);
	else
		timeTxt = string.format("%ss", s + m * 60);
	end
	return Toukibi:GetStyledText(timeTxt, {"ol", "b", "s11"});
end

local function SetCooldownText(objParent, InvItem)
	if objParent == nil then return end
	local CdTime = item.GetCoolDown(InvItem.type) / 1000;
	local lblCoolDown = tolua.cast(objParent:CreateOrGetControl("richtext", "CdText", 0, 0, 28, 20), "ui::CRichText");
	lblCoolDown:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);
	lblCoolDown:SetTextAlign("left", "center");
	lblCoolDown:SetMargin(0, 0, 0, 1);
	lblCoolDown:EnableHitTest(0);
	lblCoolDown:SetText(GetTimeEx(CdTime));
	if CdTime > 0 then
		objParent:GetChild('picBase'):SetColorTone("80000000");
	else
		objParent:GetChild('picBase'):SetColorTone("FFFFFFFF");
	end
	lblCoolDown:ShowWindow((CdTime > 0) and 1 or 0);
end

function Me.UpdateCooldownText()
	local TopFrame = ui.GetFrame(addonNameLower);
	if TopFrame == nil then return end
	local ItemData = nil;
	if Me.Settings.DisplayEscapeStone then
		ItemData =  Me.InvItemData["Escape_Orb"];
		if ItemData ~= nil then
			local InvItem = GET_PC_ITEM_BY_GUID(ItemData.Guid);
			if InvItem ~= nil then
				SetCooldownText(TopFrame:GetChild("btnEscapeOrb"), InvItem)
			end
		end
	end

	if Me.Settings.DisplayEscapeStoneKlaipeda then
		ItemData =  Me.InvItemData["EscapeStone_Klaipeda"];
		if ItemData ~= nil then
			local InvItem = GET_PC_ITEM_BY_GUID(ItemData.Guid);
			if InvItem ~= nil then
				SetCooldownText(TopFrame:GetChild("btnEscapeKlaipeda"), InvItem)
			end
		end
	end

	if Me.Settings.DisplayEscapeStoneOrsha then
		ItemData =  Me.InvItemData["EscapeStone_Orsha"];
		if ItemData ~= nil then
			local InvItem = GET_PC_ITEM_BY_GUID(ItemData.Guid);
			if InvItem ~= nil then
				SetCooldownText(TopFrame:GetChild("btnEscapeOrsha"), InvItem)
			end
		end
	end
end

function Me.Update()
	Me.InvItemData = Me.GetInvItemData();
	UpdateMainFrame();
end

-- 表示がはみ出していないかチェックしてはみ出していたら画面内に戻す
function Me.CheckPos()
	local TopFrame = ui.GetFrame(addonNameLower);
	if TopFrame == nil then return end
	local screenWidth = ui.GetSceneWidth();
	local screenHeight = ui.GetSceneHeight();

	local Pos = {};
	Pos.X = TopFrame:GetX()
	Pos.Y = TopFrame:GetY()
	local FrameSize = {};
	FrameSize.Width  = TopFrame:GetWidth()
	FrameSize.Height = TopFrame:GetHeight()

	-- 右へのはみ出し判定とX位置調整
	if Pos.X + FrameSize.Width > screenWidth then
		Pos.X = screenWidth - FrameSize.Width;
	end
	if Pos.X < 0 then Pos.X = 0 end

	-- 下へのはみ出し判定とY位置調整
	if Pos.Y + FrameSize.Height > screenHeight then
		Pos.Y = screenHeight - FrameSize.Height;
	end
	if Pos.Y < 0 then Pos.Y = 0 end

	Me.Settings.PosX = Pos.X;
	Me.Settings.PosY = Pos.Y;
	Me.UpdatePos();
end

-- 表示位置を更新する
function Me.UpdatePos()
	local TopFrame = ui.GetFrame(addonNameLower);
	if TopFrame == nil then return end
	if Me.Settings == nil or Me.Settings.PosX == nil or Me.Settings.PosY == nil then
		-- デフォルト設定(ステータス表示にドッキング)
		local StatusFrame = ui.GetFrame("headsupdisplay");
		if StatusFrame ~= nil then
			TopFrame:SetPos(StatusFrame:GetX() + 120, StatusFrame:GetY());
		end
	else
		TopFrame:SetPos(Me.Settings.PosX, Me.Settings.PosY);
	end
end

-- 表示/非表示を切り替える(1:表示 0:非表示 nil:トグル)
function Me.Show(value)
	if value == nil or value == 0 or value == 1 then
		local BaseFrame = ui.GetFrame(addonNameLower);
		if BaseFrame == nil then
			log(Toukibi:GetResText(ResText, Me.Settings.Lang, "Msg.CannotGetHandle"));
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

local function UseWarpItem(ItemClassName)
	if os.clock() < (Me.LastWarpTime or 0) + 3 then return end
	Me.LastWarpTime = os.clock();
	ItemData =  Me.InvItemData[ItemClassName];
	if ItemData ~= nil then
		local InvItem = GET_PC_ITEM_BY_GUID(ItemData.Guid);
		if InvItem ~= nil then
			INV_ICON_USE(InvItem);
		end
	end
end

function Me.ItemBtnClick(frame, ctrl, argStr, argNum)
	UseWarpItem(argStr);
end

-- コンテキストメニューを作成する
function TOUKIBI_POPUPQUESTWARP_CONTEXT_MENU(frame, ctrl)
	local context = ui.CreateContextMenu("POPUPQUESTWARP_MAIN_RBTN"
										, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Title")
										, 0, 0, 180, 0);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.UpdateNow"), "TOUKIBI_POPUPQUESTWARP_UPDATE()");
	Toukibi:MakeCMenuSeparator(context, 270.1, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Title_EscapeStoneVisible"));
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.EscapeStone"), "TOUKIBI_POPUPQUESTWARP_TOGGLEPROP('DisplayEscapeStone')", nil, Me.Settings.DisplayEscapeStone);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.EscapeStone_Klaipeda"), "TOUKIBI_POPUPQUESTWARP_TOGGLEPROP('DisplayEscapeStoneKlaipeda')", nil, Me.Settings.DisplayEscapeStoneKlaipeda);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.EscapeStone_Orsha"), "TOUKIBI_POPUPQUESTWARP_TOGGLEPROP('DisplayEscapeStoneOrsha')", nil, Me.Settings.DisplayEscapeStoneOrsha);
	Toukibi:MakeCMenuSeparator(context, 270.2, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Title_Horizontal"));
	Toukibi:MakeCMenuItem(context
						, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Vertical")
						, "TOUKIBI_POPUPQUESTWARP_TOGGLEPROP('Horizontal', false)"
						, nil
						, not Me.Settings.Horizontal);
	Toukibi:MakeCMenuItem(context
						, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Horizontal")
						, "TOUKIBI_POPUPQUESTWARP_TOGGLEPROP('Horizontal', true)"
						, nil
						, Me.Settings.Horizontal);
	Toukibi:MakeCMenuSeparator(context, 270.4);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.LockPosition"), "TOUKIBI_POPUPQUESTWARP_CHANGE_MOVABLE()", nil, not Me.Settings.Movable);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ResetPosition"), "TOUKIBI_POPUPQUESTWARP_RESETPOS()");
	-- 閉じる
	Toukibi:MakeCMenuSeparator(context, 270.5);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Close"));
	context:Resize(300, context:GetHeight());
	ui.OpenContextMenu(context);
	return context;
end

-- ***** コンテキストメニュー選択イベント受取 *****

function TOUKIBI_POPUPQUESTWARP_TOGGLEPROP(Name, Value)
	if Name == nil then return end
	if Me.Settings == nil then return end
	if Value == "nil" or type(Value) ~= "boolean" then
		Me.Settings[Name] = not Me.Settings[Name];
	else
		Me.Settings[Name] = Value;
	end
	SaveSetting();
	Me.Update();
	if Name == "Horizontal" then
		Me.CheckPos();
	end
end

function TOUKIBI_POPUPQUESTWARP_CHANGEPROP(Name, Value)
	if Name == nil then return end
	if Me.Settings == nil then return end
	if Value == "nil" then Value = nil end
	Me.Settings[Name] = Value
	SaveSetting();
	Me.Update();
end

function TOUKIBI_POPUPQUESTWARP_CHANGE_MOVABLE()
	if Me.Settings == nil then return end
	Me.Settings.Movable = not Me.Settings.Movable;
	local objFrame = ui.GetFrame(addonNameLower)
	if objFrame ~= nil then
		objFrame:EnableMove(Me.Settings.Movable and 1 or 0);
		SaveSetting();
	end
end

function TOUKIBI_POPUPQUESTWARP_RESETPOS()
	if Me.Settings == nil then return end
	Me.Settings.PosX = nil;
	Me.Settings.PosY = nil;
	Me.UpdatePos();
	local objFrame = ui.GetFrame(addonNameLower)
	if objFrame ~= nil then
		Me.Settings.PosX = objFrame:GetX();
		Me.Settings.PosY = objFrame:GetY();
	end
	SaveSetting();
	Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "Msg.UpdateFrmaePos"), "Info", true, false);
end

-- イベント受け取り用

function TOUKIBI_POPUPQUESTWARP_ON_GAME_START()
	-- GAME_STARTイベント時から0.5秒待ってみる
	ReserveScript("TOUKIBI_POPUPQUESTWARP_UPDATE_ALL()", 0.5);
end

function TOUKIBI_POPUPQUESTWARP_UPDATE_ALL(frame)
	Me.Update();
end

function TOUKIBI_POPUPQUESTWARP_END_DRAG()
	if not Me.Settings.Movable then return end
	local objFrame = ui.GetFrame(addonNameLower)
	if objFrame == nil then return end
	-- objFrame:SetSkinName("textview")
	-- objFrame:Invalidate()
	Me.Settings.PosX = objFrame:GetX();
	Me.Settings.PosY = objFrame:GetY();
	SaveSetting();
end

function TOUKIBI_POPUPQUESTWARP_LOSTFOCUS()
	TOUKIBI_POPUPQUESTWARPSUB_LOSTFOCUS();
end

function TOUKIBI_POPUPQUESTWARP_MOUSEMOVE()
	TOUKIBI_POPUPQUESTWARPSUB_CALLPOPUP();
end

function TOUKIBI_POPUPQUESTWARP_TIMER_COOLDOWN_TICK(frame)
	Me.UpdateCooldownText();
	ChangeRotateStatus();
end

function TOUKIBI_POPUPQUESTWARP_ITEMBTNCLICK(frame, ctrl, argStr, argNum)
	Me.ItemBtnClick(frame, ctrl, argStr, argNum);
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取
function TOUKIBI_POPUPQUESTWARP_PROCESS_COMMAND(command)
	Toukibi:AddLog(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ExecuteCommands"), SlashCommandList[1] .. " " .. table.concat(command, " ")), "Info", true, true);
	local cmd = ""; 
	if #command > 0 then 
		-- パラメータが存在した場合はパラメータの1個めを抜き出してみる
		cmd = table.remove(command, 1); 
	else
		-- パラメータなしでコマンドが呼ばれた場合
		Me.Show();
		return;
	end 
	if cmd == "reset" then 
		-- すべてをリセット
		MargeDefaultSetting(true, true);
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ResetSettings"), "Notice", true, false);
		return;
	elseif cmd == "resetpos" or cmd == "rspos" then 
		-- 位置をリセット
		TOUKIBI_POPUPQUESTWARP_RESETPOS();
		return;
	elseif cmd == "refresh" then
		-- プログラムをリセット
		TOUKIBI_POPUPQUESTWARP_UPDATE_ALL();
		return;
	elseif cmd == "update" then
		-- Updateの処理をここに書く
		Me.Update();
		return;
	elseif cmd == "updatepos" then
		Me.UpdatePos();
		return;
	elseif cmd == "jp" or cmd == "en" or string.len(cmd) == 2 then
		-- 言語モードと勘違いした？
		if cmd == "ja" then cmd = "jp" end
		Me.ComLib:ChangeLanguage(cmd);
		-- 何か更新したければ更新処理をここに書く
		
		
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

Me.HoockedOrigProc = Me.HoockedOrigProc or {};
function POPUPQUESTWARP_ON_INIT(addon, frame)
	-- 設定を読み込む
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	if Me.Settings.DoNothing then return end

	--タイマーを使う場合
	Me.timer_main = GET_CHILD(ui.GetFrame(addonNameLower), "timer_cd", "ui::CAddOnTimer");
	Me.timer_main:SetUpdateScript("TOUKIBI_POPUPQUESTWARP_TIMER_COOLDOWN_TICK");
	Me.timer_main:Start(0.25)

	-- イベントを登録する
	addon:RegisterMsg('GAME_START', 'TOUKIBI_POPUPQUESTWARP_ON_GAME_START');

	-- スラッシュコマンドを使う場合
	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_POPUPQUESTWARP_PROCESS_COMMAND);
	end

	ui.GetFrame(addonNameLower):EnableMove(Me.Settings.Movable and 1 or 0);
	Me.Show(1);
	Me.Update();
	Me.UpdatePos()
end

