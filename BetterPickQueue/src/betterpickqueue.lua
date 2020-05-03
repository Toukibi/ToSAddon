local addonName = "BetterPickQueue";
local verText = "1.15";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/pickq", "/pickqueue"} -- {"/コマンド1", "/コマンド2", .......};
local CommandParamList = {
	reset = {jp = "計測リセット", en = "Reset Session."},
	resetpos = {jp = "位置をリセット", en = "Reset Position."},
	resetsetting = {jp = "設定リセット", en = "Reset the all settings."},
	update = {jp = "表示を更新", en = "Update display."}
};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
pickq = Me;
local DebugMode = false;

-- テキストリソース
local ResText = {
	jp = {
		Menu = {
			Title = "{#006666}=== BetterPickQueueの設定 ==={/}"
		  , SecondaryInfo = "{nl}{s4} {/}{nl}{s12}{b}{#66AA99}Shift+右クリックで{#AAAA66}{ol}第2設定画面{/}{/}を表示{/}{/}{/}"
		  , SecondaryTitle = "{nl}{#66AA99}第2設定画面{/}"
		  , ResetSession = "{#FFFF88}計測をリセット{/}"
		  , UpdateNow = "表示を更新"
		  , DisplayItems = "表示項目"
		  , SortedBy = "並び順"
		  , AllwaysDisplay = "常に表示するもの"
		  , AutoReset = "オートリセット"
		  , BackGround = "背景の濃さ"
		  , LockPosition = "位置を固定する"
		  , ResetPosition = "位置をリセット"
		  , useSimpleMenu = "かんたん表示切り替え"
		  , HideOriginalQueue = "標準機能のアイテム獲得の{nl}{img channel_mark_empty 24 24}    表示を消す"
		  , ExpandTo_Vertical = "表示が伸びる方向(垂直方向)"
		  , ExpandTo_Up = "上へ"
		  , ExpandTo_Down = "下へ"
		  , ExpandTo_Horizonal = "表示が伸びる方向(水平方向)"
		  , ExpandTo_Left = "左へ"
		  , ExpandTo_Right = "右へ"
		  , Close = "{#666666}閉じる{/}"
		},
		Display = {
			CurrentCount = "所持数"
		  , GuessCount = "1時間あたりの取得量"
		  , SimpleLog = "簡易ログ"
		  , Silver = "シルバー"
		  , WeightData = "所持重量"
		  , OldItem = "拾って時間の経った物"
		  , ElapsedTime = "経過時間"
		},
		Order = {
			byName = "名前順"
		  , byCount = "取得数順"
		  , byGetTime = "拾った順"
		},
		AutoReset = {
			byMap = "マップ移動時"
		  , byChannel = "チャンネル変更時"
		},
		SimpleMenuSelect = {
			Title = "表示モード選択"
		  , Normal = "標準モード"
		  , Counter = "カウンターモード"
		  , Detail = "獲得履歴モード"
		},
		BackGround = {
			Deep = "濃い"
		  , Thin = "薄い"
		  , None = "なし"
		},
		Log = {
			ResetSession = "計測をリセットしました。"
		},
		Other = {
			Multiple = "×"
		  , Percent = "％"
		  , WeightTitle = "所持重量："
		  , LogSpacer = "        "
		  , TotalTitle = "{s4} {/}/{s4} {/}"
		  , GuessFormat = "約{#FFFF33}%s{/}個/h"
		  , GuessFormatLong = "{#FFFF33}%s{/}ほどで入手"
		  , ElapsedTimeFormat = "{#FFFF33}%s{/}経過"
		  , Day = "日"
		  , Hour = "時間"
		  , Minutes = "分"
		  , Second = "秒"
		  , Ago = "前"
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
			Title = "{#006666}=== BetterPickQueue setting ==={/}"
		  , SecondaryInfo = "{nl}{s4} {/}{nl}{s12}{b}{#66AA99}Shift + Right-Click to display{nl}the {#AAAA66}{ol}2nd setting menu{/}{/}{/}{/}{/}"
		  , SecondaryTitle = "{nl}{#66AA99}Secondary Setting menu{/}"
		  , ResetSession = "{#FFFF88}Reset Session{/}"
		  , UpdateNow = "Update now!"
		  , DisplayItems = "Display Items"
		  , SortedBy = "Sorted by"
		  , AllwaysDisplay = "Always display"
		  , AutoReset = "Auto reset function"
		  , BackGround = "Background"
		  , LockPosition = "Lock position"
		  , ResetPosition = "Reset position"
		  , useSimpleMenu = "Use Simple menu"
		  , HideOriginalQueue = "Hide default{nl}{img channel_mark_empty 24 24}       item-obtention display"
		  , ExpandTo_Vertical = "Vertical display extension"
		  , ExpandTo_Up = "Upward"
		  , ExpandTo_Down = "Downward"
		  , ExpandTo_Horizonal = "Horizonal display extension"
		  , ExpandTo_Left = "To the Left"
		  , ExpandTo_Right = "To the Right"
		  , Close = "{#666666}Close{/}"
		},
		Display = {
			CurrentCount = "Total Obtained Count"
		  , GuessCount = "pcs/Hr"
		  , SimpleLog = "Simple log"
		  , Silver = "Silver"
		  , WeightData = "Weight Info."
		  , OldItem = "Items picked up long ago"
		  , ElapsedTime = "Elapsed time"
		},
		Order = {
			byName = "by Name"
		  , byCount = "by Count"
		  , byGetTime = "In order of acquisition"
		},
		AutoReset = {
			byMap = "When changing the map"
		  , byChannel = "When changing channel"
		},
		SimpleMenuSelect = {
			Title = "Select mode"
		  , Normal = "Normal mode"
		  , Counter = "Obtained counter mode"
		  , Detail = "Obtained history mode"
		},
		BackGround = {
			Deep = "Deep"
		  , Thin = "Thin"
		  , None = "None"
		},
		Log = {
			ResetSession = "Session resetted."
		},
		Other = {
			Multiple = " x "
		  , Percent = "%"
		  , WeightTitle = "Weight : "
		  , LogSpacer = "              "
		  , TotalTitle = " /"
		  , GuessFormat = "{#FFFF33}%s{/}/Hr"
		  , GuessFormatLong = "{#FFFF33}%s{/} to get."
		  , ElapsedTimeFormat = "{#FFFF33}%s{/} elapsed."
		  , Day = "day"
		  , Hour = "hour"
		  , Minutes = "min."
		  , Second = "sec."
		  , Ago = "ago"
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
	-- 子を持つメニュー項目を作成
	MakeCMenuParentItem = function(self, parent, text, child)
		ui.AddContextMenuItem(parent, text .. "  {img white_right_arrow 8 16}", "", nil, 0, 1, child);
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
	if frame == nil then return end
	--DEVELOPERCONSOLE_PRINT_TEXT("{#444444}type of {#005500}"  .. objName .. "{/} is {#005500}" .. type(objValue) .. "{/}{/}", "white_16_ol");
	DEVELOPERCONSOLE_PRINT_TEXT("{nl} ");
	DEVELOPERCONSOLE_PRINT_VALUE(frame, "", objValue, "", nil, true);
end
local function try(f, ...)
	local status, error = pcall(f, ...)
	if not status then
		return tostring(error);
	else
		return "OK";
	end
end
local function FunctionExists(func)
	if func == nil then
		return false;
	else
		return true;
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


-- ***** 変数の宣言と設定 *****
Me.SettingFilePathName = string.format("../addons/%s/%s", addonNameLower, SettingFileName);
Me.Loaded = false;
Me.Data = Me.Data or {};
Me.Data.Pick = Me.Data.Pick or {};
Me.Data.StartTime = Me.Data.StartTime or nil
Me.Data.BeforeMap = Me.Data.BeforeMap or nil;

-- 設定書き込み
local function SaveSetting()
	Toukibi:SaveTable(Me.SettingFilePathName, Me.Settings);
end

-- デフォルト設定(ForceがTrueでない場合は、既存の値はそのまま引き継ぐ)
local function MargeDefaultSetting(Force, DoSave)
	DoSave = Toukibi:GetValueOrDefault(DoSave, true);
	Me.Settings = Me.Settings or {};
	Me.Settings.DoNothing		 = Toukibi:GetValueOrDefault(Me.Settings.DoNothing		, false, Force);
	Me.Settings.Lang			 = Toukibi:GetValueOrDefault(Me.Settings.Lang			, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.Movable			 = Toukibi:GetValueOrDefault(Me.Settings.Movable		, true, Force);
	Me.Settings.Visible			 = Toukibi:GetValueOrDefault(Me.Settings.Visible		, true, Force);
	Me.Settings.PosX			 = Toukibi:GetValueOrDefault(Me.Settings.PosX			, 0, Force);
	Me.Settings.PosY			 = Toukibi:GetValueOrDefault(Me.Settings.PosY			, 250, Force);
	Me.Settings.MarginBottom	 = Toukibi:GetValueOrDefault(Me.Settings.MarginBottom	, 90, Force);
	Me.Settings.MarginRight		 = Toukibi:GetValueOrDefault(Me.Settings.MarginRight	, 20, Force);
	
	Me.Settings.useSimpleMenu	 = Toukibi:GetValueOrDefault(Me.Settings.useSimpleMenu	, true, Force);
	Me.Settings.CurrentMode		 = Toukibi:GetValueOrDefault(Me.Settings.CurrentMode	, "Normal", Force); -- Normal/Counter/Detail
	
	Me.Settings.ShowElapsedTime	 = Toukibi:GetValueOrDefault(Me.Settings.ShowElapsedTime, false, Force);
	Me.Settings.ShowCurrent		 = Toukibi:GetValueOrDefault(Me.Settings.ShowCurrent	, true, Force);
	Me.Settings.ShowGuess		 = Toukibi:GetValueOrDefault(Me.Settings.ShowGuess		, false, Force);
	Me.Settings.ShowLog			 = Toukibi:GetValueOrDefault(Me.Settings.ShowLog		, true, Force);
	
	Me.Settings.OrderBy			 = Toukibi:GetValueOrDefault(Me.Settings.OrderBy		, "byGetTime", Force); -- byName/byCount/byGetTime
	Me.Settings.AutoResetByMap	 = Toukibi:GetValueOrDefault(Me.Settings.AutoResetByMap	, true, Force);
	Me.Settings.AutoResetByCh	 = Toukibi:GetValueOrDefault(Me.Settings.AutoResetByCh	, false, Force);
	
	Me.Settings.ShowVis			 = Toukibi:GetValueOrDefault(Me.Settings.ShowVis		, true, Force);
	Me.Settings.ShowWeight		 = Toukibi:GetValueOrDefault(Me.Settings.ShowWeight		, true, Force);
	Me.Settings.ShowOldItem		 = Toukibi:GetValueOrDefault(Me.Settings.ShowOldItem	, false, Force);

	Me.Settings.DueDateDisplay	 = Toukibi:GetValueOrDefault(Me.Settings.DueDateDisplay	, 10, Force);
	Me.Settings.SkinName		 = Toukibi:GetValueOrDefault(Me.Settings.SkinName		, "None", Force); --None/chat_window/systemmenu_vertical
	Me.Settings.HideOriginalQueue = Toukibi:GetValueOrDefault(Me.Settings.HideOriginalQueue, false, Force);
	Me.Settings.ExpandTo_Up		 = Toukibi:GetValueOrDefault(Me.Settings.ExpandTo_Up	, true, Force);
	Me.Settings.ExpandTo_Left	 = Toukibi:GetValueOrDefault(Me.Settings.ExpandTo_Left	, true, Force);
	
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
local function GetCommaedTextEx(value, MaxTextLen, AfterTheDecimalPointLen, usePlusMark, AddSpaceAfterSign)
	local lMaxTextLen = MaxTextLen or 0;
	local lAfterTheDecimalPointLen = AfterTheDecimalPointLen or 0;
	local lusePlusMark = usePlusMark or false;
	local lAddSpaceAfterSign = AddSpaceAfterSign or lusePlusMark;

	if lAfterTheDecimalPointLen < 0 then lAfterTheDecimalPointLen = 0 end
	local IsNegative = (value < 0);
	local SourceValue = math.floor(math.abs(value) * math.pow(10, lAfterTheDecimalPointLen) + 0.5);
	local IntegerPartValue = math.floor(SourceValue * math.pow(10, -1 *lAfterTheDecimalPointLen));
	local DecimalPartValue = SourceValue - IntegerPartValue * math.pow(10, lAfterTheDecimalPointLen);
	local IntegerPartText = GetCommaedText(IntegerPartValue);
	local DecimalPartText = tostring(DecimalPartValue);

	-- 記号をつける
	local SignMark = "";
	if IsNegative then
		-- 負の数の場合は頭にマイナスをつける
		SignMark = "-";
	else
		-- 正の数の場合はusePlusMarkがTrueの場合のみ付加する
		if lusePlusMark then
			if Me.Settings.Lang == "jp" and IntegerPartValue == 0 and DecimalPartValue == 0 then
			-- 日本語の場合はゼロぴったり時に±を実装
				SignMark = "±";
			else
				SignMark = "+";
			end
		end
	end
	if lAddSpaceAfterSign and string.len(SignMark) > 0 then
		SignMark = SignMark .. "{s4} {/}";
	end
	-- 整数部を成形
	local RoughFinish = SignMark .. IntegerPartText;
	-- 小数部を成形
	if DecimalPartValue > 0 or lAfterTheDecimalPointLen > 0 then
		RoughFinish = RoughFinish .. string.format(string.format(".%%0%dd", lAfterTheDecimalPointLen), DecimalPartValue);
	end
	-- 長さに合わせて整形する
	-- すでに文字長オーバーの場合はそのまま返す
	if string.len(RoughFinish) >= lMaxTextLen then return RoughFinish end
	-- 挿入する空白を作成する
	local PaddingText = string.rep(" ", lMaxTextLen - string.len(RoughFinish));
	return PaddingText .. RoughFinish;
end

local function GetItemGrade(itemObj)
	local grade = itemObj.ItemGrade;

	if (itemObj.ItemType == "Recipe") then
		local recipeGrade = tonumber(itemObj.Icon:match("misc(%d)")) - 1;
		if (recipeGrade <= 0) then recipeGrade = 1 end;
		grade = recipeGrade;
	end
	return grade;
end

local function GetItemRarityColor(itemObj)
	local itemProp = geItemTable.GetProp(itemObj.ClassID);
	local grade = GetItemGrade(itemObj);

	if (itemProp.setInfo ~= nil) then return "00FF00"; -- set piece
	elseif (grade == 0) then return "FFBF33"; -- premium
	elseif (grade == 1) then return "FFFFFF"; -- common
	elseif (grade == 2) then return "108CFF"; -- rare
	elseif (grade == 3) then return "9F30FF"; -- epic
	elseif (grade == 4) then return "FF4F00"; -- orange
	elseif (grade == 5) then return "FFFF53"; -- legendary
	else return "E1E1E1"; -- no grade (non-equipment items)
	end
end

local function GetTimeText(value, length)
	length = length or 1;
	local tmpValue = value;
	local strResult, strSplitter = "", " ";
	local index = 1;
	if value >= 3600 * 24 then
		if strResult ~= "" then strResult = strResult .. strSplitter end
		strResult = strResult .. string.format("%d%s", math.floor(tmpValue / 3600 / 24), Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Day"));
		index = index + 1;
	end
	if index > length then return strResult end
	tmpValue = (tmpValue % (24 * 3600));
	if value >= 3600 then
		if strResult ~= "" then strResult = strResult .. strSplitter end
		strResult = strResult .. string.format("%d%s", math.floor(tmpValue / 3600), Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Hour"));
		index = index + 1;
	end
	if index > length then return strResult end
	tmpValue = tmpValue % 3600;
	if value >= 60 then
		if strResult ~= "" then strResult = strResult .. strSplitter end
		strResult = strResult .. string.format("%d%s", math.floor(tmpValue / 60), Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Minutes"));
		index = index + 1;
	end
	if index > length then return strResult end
	tmpValue = tmpValue % 60;
	if strResult ~= "" then strResult = strResult .. strSplitter end
	strResult = strResult .. string.format("%d%s", math.ceil(tmpValue), Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Second"));
	return strResult;
end

-- 状態判定
local function GetState_ShowElapsedTime()
	if Me.Settings.useSimpleMenu then
		-- かんたんモード使用中
		--if Me.Settings.CurrentMode == "Normal" then
			return Me.Settings.ShowElapsedTime;
		--else
		--	return true;
		--end
	else
		return Me.Settings.ShowElapsedTime;
	end
end

local function GetState_ShowCurrent()
	if Me.Settings.useSimpleMenu then
		return true;
	else
		return Me.Settings.ShowCurrent;
	end
end

local function GetState_ShowGuess()
	if Me.Settings.useSimpleMenu then
		return false;
	else
		return Me.Settings.ShowGuess;
	end
end

local function GetState_ShowLog()
	if Me.Settings.useSimpleMenu then
		return true;
	else
		return Me.Settings.ShowLog;
	end
end

local function GetState_OrderBy()
	if Me.Settings.useSimpleMenu then
		-- かんたんモード使用中
		if Me.Settings.CurrentMode == "Normal" then
			return "byGetTime";
		else
			return "byCount";
		end
	else
		return Me.Settings.OrderBy;
	end
end

local function GetState_ShowOldItem()
	if Me.Settings.useSimpleMenu then
		-- かんたんモード使用中
		if Me.Settings.CurrentMode == "Counter" or Me.Settings.CurrentMode == "Detail" then
			return true;
		else
			return false;
		end
	else
		return Me.Settings.ShowOldItem;
	end
end

local function GetState_ShowOldItemInLog()
	if Me.Settings.useSimpleMenu then
		-- かんたんモード使用中
		if Me.Settings.CurrentMode == "Detail" then
			return true;
		else
			return false;
		end
	else
		return Me.Settings.ShowOldItem;
	end
end

-- 個数取得
local function GetEquipInvCount(itemClsName)
	if itemClsName == nil or itemClsName == "" or itemClsName == "None" then
		return 0;
	end
	local invItemList = session.GetInvItemList();
	local retTable = {Value = 0};
	FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem, retTable, itemClsName)
			if invItem ~= nil then
				local objItem = GetIES(invItem:GetObject());
				if objItem.ClassName == itemClsName then
					retTable.Value = retTable.Value + 1;
				end
			end
		end, false, retTable, itemClsName);
	return retTable.Value;
end

function Me.Test(itemClsName)
	return GetEquipInvCount(itemClsName)
end

local function GetCurrentCount(itemClsName)
	if itemClsName == nil or itemClsName == "" or itemClsName == "None" then
		return 0;
	end
	local PickData = Me.Data.Pick[itemClsName];
	if PickData.ItemType == nil then
		PickData.ItemType = GetClass("Item", itemClsName).ItemType;
	end
	if PickData.ItemType == "Equip" then
		return GetEquipInvCount(itemClsName)
	elseif session.GetInvItemByName(itemClsName) == nil then
		return 0;
	else
		return session.GetInvItemByName(itemClsName).count;
	end
end

local function GetDiffCount(itemClsName)
	if itemClsName == nil or itemClsName == "" or itemClsName == "None" then
		return 0;
	end
	local PickData = Me.Data.Pick[itemClsName];
	local CurrentNum = GetCurrentCount(itemClsName) or 0
	local StartNum = PickData.StartNum or 0;
	return CurrentNum - StartNum;
end

-- バッファー初期化
local function InitPickData(itemClsName, pickedCount)
	Me.Data.Pick[itemClsName] = {};
	Me.Data.Pick[itemClsName].ClassName = itemClsName;
	Me.Data.Pick[itemClsName].Name = dictionary.ReplaceDicIDInCompStr(GetClass("Item", itemClsName).Name);
	Me.Data.Pick[itemClsName].StartNum = GetCurrentCount(itemClsName) - pickedCount;
	Me.Data.Pick[itemClsName].Log = {};
end

function Me.UpdateItemPickData(itemType, itemCount)
	-- 開始時間がない場合は開始時間を登録する
	if Me.Data.StartTime == nil then
		Me.Data.StartTime = os.clock();
	end
	-- バッファー領域がない場合は作成する
	if Me.Data.Pick == nil then
		Me.Data.Pick = {};
	end

	local itemCls = GetClassByType("Item", tonumber(itemType));
	if itemCls == nil then return end
	local itemClsName = itemCls.ClassName
	
	
	-- データが無い場合は新規に作成する
	if Me.Data.Pick[itemClsName] == nil then
		InitPickData(itemClsName, itemCount)
	end
	Me.Data.LastTime = os.clock();
	Me.Data.Pick[itemClsName].LastTime = os.clock();
	Me.Data.Pick[itemClsName].CurrentNum = GetCurrentCount(itemClsName);
	local PickLog = Me.Data.Pick[itemClsName].Log;
	-- データを登録する
	table.insert(PickLog, {
		  time = os.clock()
		, count = itemCount
	})
	if Toukibi:GetTableLen(PickLog) > 5 then
		table.remove(PickLog, 1)
	end
	Me.Data.Pick[itemClsName].DiffCount = GetDiffCount(itemClsName);
	Me.UpdateFrame()
end

local function MakeItemText(itemClsName)
	local styleTitle = {"#AAFFAA", "s12", "ol", "b"}
	local styleValue = {"#EEEEEE", "s16", "ol", "b"}
	if itemClsName == nil or itemClsName == "" or itemClsName == "None" then
		return nil
	end
	local strResult = "";
	local PickData = Me.Data.Pick[itemClsName];
	-- メインの表示
	local itemCls = GetClass("Item", itemClsName);
	strResult = string.format("{img %s 24 24} {#%s}%s{/} {#33FFFF}( %s ){/}"
		, itemCls.Icon
		, GetItemRarityColor(itemCls)
		, dictionary.ReplaceDicIDInCompStr(itemCls.Name)
		, GetCommaedTextEx(GetDiffCount(itemClsName), 0, 0, true, false)
	)
	
	if GetState_ShowCurrent() then
		-- 現在数の表示
		strResult = strResult .. Toukibi:GetStyledText(
			string.format("%s%s"
				, Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.TotalTitle")
				, GetCommaedTextEx(GetCurrentCount(itemClsName))
			)
			, {"s12", "#CCFFFF"}
		)
	end
	
	local logLength = Toukibi:GetTableLen(PickData.Log);
	local NowIndex, MaxIndex = logLength, logLength;
	local StartTime = Me.Data.StartTime;
	if MaxIndex >= 3 then
		MaxIndex = 3;
		StartTime = PickData.Log[logLength - 2].time;
	end
	if GetState_ShowGuess() and logLength > 0 then
		-- 予測取得数の表示
		local sumCount = 0;
		for i = 1, MaxIndex do
			sumCount = sumCount + PickData.Log[i].count
		end
		local ElapsedTime = os.clock() - StartTime;
		local GuessNum = sumCount / ElapsedTime * 3600;
		local strGuess = ""
		if GuessNum >= 10 then
			strGuess = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.GuessFormat"), GetCommaedTextEx(GuessNum));
		elseif GuessNum >= 5 then
			strGuess = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.GuessFormat"), GetCommaedTextEx(GuessNum, 0, 1));
		else
			GuessNum = ElapsedTime / sumCount;
			strGuess = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.GuessFormatLong"), GetTimeText(GuessNum))
		end
		if GetState_ShowOldItem() or (os.clock() - PickData.LastTime) <= Me.Settings.DueDateDisplay then
			strResult = strResult .. string.format("{nl}{s13}%s%s{#CCCC88}%s{/}{/}"
				, Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.LogSpacer")
				, Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.LogSpacer")
				, strGuess
			)
		end
	end
	if GetState_ShowLog() then
		-- 簡易ログの表示
		NowIndex = logLength;
		for i = 1, MaxIndex do
			if GetState_ShowOldItemInLog() or PickData.Log[NowIndex].time ~= nil and (os.clock() - PickData.Log[NowIndex].time) <= Me.Settings.DueDateDisplay then
				strResult = strResult .. string.format("{nl}{s12}%s{s%s}{#FFCCAA}%s{/}  {#AAAA88}%s{/}{#666644}%s{/}{/}{/}"
					, Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.LogSpacer")
					, 12 - i
					, GetCommaedTextEx(PickData.Log[NowIndex].count, 0, 0, true, false)
					, GetTimeText(os.clock() - PickData.Log[NowIndex].time)
					, Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Ago")
				)
			end
			NowIndex = NowIndex - 1
		end
	end
	return strResult
end

local function GetMyWeightText()
	local GaugeWidth = 160;
	local RedZone = 90;
	local pc = GetMyPCObject();
	local NowWeight, MaxWeight = pc.NowWeight, pc.MaxWeight;
	local textColor = "FFFFFF";
	local WeightRate = 0;
	if MaxWeight > 0 then
		WeightRate = NowWeight * 100 / MaxWeight;
	end
	if MaxWeight < NowWeight then
		textColor = "FF1111";
	elseif WeightRate >= 95 then
		textColor = "FF3333";
	elseif WeightRate >= RedZone then
		textColor = "FF9999";
	end
	local strResult = string.format("%s%s/%s {s12}(%d%s){/}"
								, Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.WeightTitle")
								, Toukibi:GetStyledText(string.format("%.1f", NowWeight), {"#" .. textColor})
								, MaxWeight
								, WeightRate
								, Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Percent")
								);

	local widthYellow, widthRed, widthBack = 0, 0, GaugeWidth;
	widthYellow = math.floor(NowWeight * GaugeWidth / MaxWeight);
	if widthYellow > GaugeWidth then
		widthYellow = GaugeWidth;
	end
	widthBack = GaugeWidth - widthYellow;
	if widthYellow * 100 > GaugeWidth * RedZone then
		local tmpValue = GaugeWidth * RedZone / 100;
		widthRed = widthYellow - tmpValue;
		widthYellow = tmpValue;
	end
	strResult = strResult .. "{nl}{s6} {/}";
	if widthYellow > 0 then
		strResult = strResult .. string.format("{img fullyellow %d 2}", widthYellow);
	end
	if widthRed > 0 then
		strResult = strResult .. string.format("{img fullred %d 2}", widthRed);
	end
	if widthBack > 0 then
		strResult = strResult .. string.format("{img fullblack %d 2}", widthBack);
	end
	return strResult;
end

local function AddLabel(parent, ctrlName, text, left, top, style)
	if parent == nil then return end
	if ctrlName == nil or ctrlName == "" then return end
	left = left or 0;
	top = top or 0;
	style = style or {};
	local objLabel = tolua.cast(parent:CreateOrGetControl("richtext", ctrlName, left, top, 10, 4), "ui::CRichText");
	objLabel:SetGravity(ui.LEFT, ui.TOP);
	objLabel:EnableHitTest(0);
	objLabel:SetText(Toukibi:GetStyledText(text, style));
	objLabel:ShowWindow(1);
	return objLabel;
end

local function SortByName(a, b)
	if a.ClassName == "Vis" then -- お金であるか
		return false
	elseif b.ClassName == "Vis" then
		return true
	end
	return a.Name < b.Name
end

local function SortByCount(a, b)
	if a.ClassName == "Vis" then -- お金であるか
		return false
	elseif b.ClassName == "Vis" then
		return true
	end
	if a.DiffCount ~= b.DiffCount then
		return a.DiffCount > b.DiffCount
	end
	return a.Name < b.Name
end

local function SortByGetTime(a, b)
	if a.ClassName == "Vis" then -- お金であるか
		return false
	elseif b.ClassName == "Vis" then
		return true
	end
	if a.LastTime ~= b.LastTime then
		return a.LastTime > b.LastTime
	end
	return a.Name < b.Name
end

function Me.UpdateFrame()
	local objFrame = ui.GetFrame(addonNameLower);
	if objFrame == nil then return end
	
	if Me.Settings.ShowVis and Me.Data.Pick.Vis == nil then
		-- シルバー情報がない場合は追加する
		InitPickData("Vis", 0)
	end
	
	-- 並べ替えの準備を行う
	local tmpTable = {};
	for _, value in pairs(Me.Data.Pick) do
		-- 表示の条件に見合うものだけを並べ替えの対象にする
		if GetState_ShowOldItem() or (value.ClassName == "Vis" and Me.Settings.ShowVis) or (os.clock() - value.LastTime) <= Me.Settings.DueDateDisplay then
			table.insert(tmpTable, value);
		else
			-- 表示の対象にならなかったコントロールは削除する
			local TargetLabelName = "lbl" .. value.ClassName;
			local lblTarget = objFrame:GetChild(TargetLabelName);
			if lblTarget ~= nil then
				objFrame:RemoveChild(TargetLabelName);
			end
		end
	end
	-- 並べ替えを行う
	local currentOrderBy = GetState_OrderBy()
	if currentOrderBy == "byGetTime" then
		table.sort(tmpTable, SortByGetTime);
	elseif currentOrderBy == "byName" then
		table.sort(tmpTable, SortByName);
	else
		table.sort(tmpTable, SortByCount);
	end
	-- 結果の表示を行う
	local cPosY = 2;
	local MarginBottom = 0;
	local MaxWeight = 0;
	local strResult, TargetLabelName = "";
	local hasDisplayData = false;

	-- 経過時間
	TargetLabelName = "lblElapsedTime";
	if GetState_ShowElapsedTime() and Me.Data.StartTime ~= nil then
		strResult = Toukibi:GetStyledText(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.ElapsedTimeFormat"), GetTimeText(os.clock() - Me.Data.StartTime, 2)),{"#EEEEEE", "s12", "ol", "b"});
		local lblResult = AddLabel(objFrame, TargetLabelName, strResult, 2, cPosY)
		cPosY = cPosY + lblResult:GetHeight() + MarginBottom;
		if lblResult:GetWidth() > MaxWeight then MaxWeight = lblResult:GetWidth() end
		hasDisplayData = true;
	else
		local lblTarget = objFrame:GetChild(TargetLabelName);
		if lblTarget ~= nil then
			objFrame:RemoveChild(TargetLabelName);
		end
	end

	for _, value in ipairs(tmpTable) do
		local itemClsName = value.ClassName
		TargetLabelName = "lbl" .. itemClsName;
		local strTemp = MakeItemText(itemClsName);
		if strTemp ~= nil and strTemp ~= "" then
			local lblResult = AddLabel(objFrame, TargetLabelName, strTemp, 2, cPosY, {"#EEEEEE", "s16", "ol", "b"})
			cPosY = cPosY + lblResult:GetHeight() + MarginBottom;
			if lblResult:GetWidth() > MaxWeight then MaxWeight = lblResult:GetWidth() end
			hasDisplayData = true;
		else
			local lblTarget = objFrame:GetChild(TargetLabelName);
			if lblTarget ~= nil then
				objFrame:RemoveChild(TargetLabelName);
			end
		end
	end
	
	TargetLabelName = "lblFooter";
	strResult = "";
	if Me.Settings.ShowWeight then
		strResult = GetMyWeightText();
		cPosY = cPosY + 6;
	elseif not hasDisplayData then
		strResult = Toukibi:GetStyledText("Better Pick Queue ver. " .. verText, {"#666666", "s12"});
	end
	if strResult ~= "" then
		local lblFooter = AddLabel(objFrame, TargetLabelName, strResult, 2, cPosY, {"#EEEEEE", "s16", "ol", "b"});
		cPosY = cPosY + lblFooter:GetHeight() + 2;
		if lblFooter:GetWidth() > MaxWeight then MaxWeight = lblFooter:GetWidth() end
	else
		local lblTarget = objFrame:GetChild(TargetLabelName);
		if lblTarget ~= nil then
			objFrame:RemoveChild(TargetLabelName);
		end
	end

	if Me.Settings.SkinName ~= nil then
		objFrame:SetSkinName(Me.Settings.SkinName);
	end
	objFrame:Resize(MaxWeight + 4, cPosY);
end



function Me.UpdatePos()
	local objFrame = ui.GetFrame(addonNameLower)
	if objFrame == nil then return end

	if Me.Settings.ExpandTo_Up then
		if Me.Settings.ExpandTo_Left then
			if Me.Settings ~= nil and Me.Settings.MarginRight ~= nil and Me.Settings.MarginBottom ~= nil then
				objFrame:SetGravity(ui.RIGHT, ui.BOTTOM);
				objFrame:SetMargin(0, 0, Me.Settings.MarginRight, Me.Settings.MarginBottom);
			end
		else
			if Me.Settings ~= nil and Me.Settings.PosX ~= nil and Me.Settings.MarginBottom ~= nil then
				objFrame:SetGravity(ui.LEFT, ui.BOTTOM);
				objFrame:SetMargin(Me.Settings.PosX, 0, 0, Me.Settings.MarginBottom);
			end
		end
	else
		if Me.Settings.ExpandTo_Left then
			if Me.Settings ~= nil and Me.Settings.MarginBottom ~= nil and Me.Settings.PosY ~= nil then
				objFrame:SetGravity(ui.RIGHT, ui.TOP);
				objFrame:SetMargin(0, Me.Settings.PosY, Me.Settings.MarginRight, 0);
			end
		else
			if Me.Settings ~= nil and Me.Settings.PosX ~= nil and Me.Settings.PosY ~= nil then
				objFrame:SetGravity(ui.LEFT, ui.TOP);
				objFrame:SetMargin(Me.Settings.PosX, Me.Settings.PosY, 0, 0);
			end
		end
	end
end

function Me.ResetPos()
	Me.Settings.PosX		 = 0;
	Me.Settings.PosY		 = 250;
	Me.Settings.MarginBottom = 90;
	Me.Settings.MarginRight	 = 20;
	Me.UpdatePos();
end
-- ===========================
--       イベント受け取り
-- ===========================

function Me.ITEMMSG_SHOW_GET_ITEM_HOOKED(frame, itemType, count)
	-- log("ITEMMSG_SHOW_GET_ITEM_HOOKED実行");
	if not Me.Settings.HideOriginalQueue then
		Me.HoockedOrigProc["ITEMMSG_SHOW_GET_ITEM"](frame, itemType, count); 
	end
end

function TOUKIBI_BETTERPICKQUEUE_ON_ITEM_PICK(frame, msg, itemType, itemCount)
	Me.UpdateItemPickData(itemType, itemCount);
end

function TOUKIBI_BETTERPICKQUEUE_START_DRAG()
	Me.IsDragging = true;
end

function TOUKIBI_BETTERPICKQUEUE_END_DRAG()
	Me.IsDragging = false;
	if not Me.Settings.Movable then return end
	local objFrame = ui.GetFrame(addonNameLower)
	if objFrame == nil then return end
	Me.Settings.PosX = objFrame:GetX();
	Me.Settings.PosY = objFrame:GetY();
	Me.Settings.MarginBottom = ui.GetClientInitialHeight() - Me.Settings.PosY - objFrame:GetHeight();
	Me.Settings.MarginRight = ui.GetClientInitialWidth() - Me.Settings.PosX - objFrame:GetWidth();
	SaveSetting();
end

function TOUKIBI_BETTERPICKQUEUE_UPDATE()
	Me.UpdateFrame();
end

function TOUKIBI_BETTERPICKQUEUE_RESET_DATA()
	Me.Data = {};
	Me.Data.Pick = {};
	local objFrame = ui.GetFrame(addonNameLower);
	if objFrame ~= nil then
		objFrame:RemoveAllChild();
	end
	Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "Log.ResetSession"), "Notice", true, false);
	Me.UpdateFrame();
end

function TOUKIBI_BETTERPICKQUEUE_RESET_POSITION()
	Me.ResetPos();
	SaveSetting();
end

function TOUKIBI_BETTERPICKQUEUE_CHANGE_MOVABLE()
	if Me.Settings == nil then return end
	Me.Settings.Movable = not Me.Settings.Movable;
	local objFrame = ui.GetFrame(addonNameLower)
	if objFrame ~= nil then
		objFrame:EnableMove(Me.Settings.Movable and 1 or 0);
		SaveSetting();
	end
end

function TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE(propName, value)
	ui.CloseAllContextMenu();
	if Me.Settings == nil then return end
	Me.Settings[propName] = (value == 1);
	SaveSetting();
	Me.UpdateFrame();
	if propName == "ExpandTo_Up" or propName == "ExpandTo_Left" then
		Me.UpdatePos()
	end
end

function TOUKIBI_BETTERPICKQUEUE_SETVALUE(propName, value)
	ui.CloseAllContextMenu();
	if Me.Settings == nil then return end
	Me.Settings[propName] = value;
	SaveSetting();
	Me.UpdateFrame();
end

function TOUKIBI_BETTERPICKQUEUE_CONTEXT_MENU(frame, ctrl)
	local titleText = Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Title");
	local cmenuWidth = 270;
	local CallSubMenu = false;
	if FunctionExists(keyboard.IsPressed) then
		-- 2018/06/27パッチ前
		CallSubMenu = (keyboard.IsPressed(KEY_SHIFT) == 1);
	elseif FunctionExists(keyboard.IsKeyPressed) then
		-- 2018/06/27パッチ後
		CallSubMenu = (keyboard.IsKeyPressed("LSHIFT") == 1 or keyboard.IsKeyPressed("RSHIFT") == 1);
	else
		-- どっちの関数もなかった場合
		CallSubMenu = false;
	end
	if not CallSubMenu then
		titleText = titleText .. Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.SecondaryInfo");
	else
		titleText = titleText .. Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.SecondaryTitle");
		CallSubMenu = true;
	end
	local context = ui.CreateContextMenu("BETTERPICKQUEUE_MAIN_RBTN", titleText, 0, 0, cmenuWidth - 10, 0);
	
	if not CallSubMenu then
		-- 通常メニュー
		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30);
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.useSimpleMenu"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "useSimpleMenu", not Me.Settings.useSimpleMenu and 1 or 0), nil, Me.Settings.useSimpleMenu);
		if Me.Settings.useSimpleMenu then
			-- 簡単メニュー
			Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.1, Toukibi:GetResText(ResText, Me.Settings.Lang, "SimpleMenuSelect.Title"));
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "SimpleMenuSelect.Normal"), string.format("TOUKIBI_BETTERPICKQUEUE_SETVALUE('%s', '%s')", "CurrentMode", "Normal"), nil, (Me.Settings.CurrentMode == "Normal"));
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "SimpleMenuSelect.Counter"), string.format("TOUKIBI_BETTERPICKQUEUE_SETVALUE('%s', '%s')", "CurrentMode", "Counter"), nil, (Me.Settings.CurrentMode == "Counter"));
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "SimpleMenuSelect.Detail"), string.format("TOUKIBI_BETTERPICKQUEUE_SETVALUE('%s', '%s')", "CurrentMode", "Detail"), nil, (Me.Settings.CurrentMode == "Detail"));
		else
			-- カスタム設定
			Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.1, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.DisplayItems"));
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.CurrentCount"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ShowCurrent", not Me.Settings.ShowCurrent and 1 or 0), nil, Me.Settings.ShowCurrent);
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.GuessCount"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ShowGuess", not Me.Settings.ShowGuess and 1 or 0), nil, Me.Settings.ShowGuess);
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.SimpleLog"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ShowLog", not Me.Settings.ShowLog and 1 or 0), nil, Me.Settings.ShowLog);
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.ElapsedTime"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ShowElapsedTime", not Me.Settings.ShowElapsedTime and 1 or 0), nil, Me.Settings.ShowElapsedTime);
			
			Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.2, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.SortedBy"));
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Order.byName"), string.format("TOUKIBI_BETTERPICKQUEUE_SETVALUE('%s', '%s')", "OrderBy", "byName"), nil, (Me.Settings.OrderBy == "byName"));
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Order.byCount"), string.format("TOUKIBI_BETTERPICKQUEUE_SETVALUE('%s', '%s')", "OrderBy", "byCount"), nil, (Me.Settings.OrderBy == "byCount"));
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Order.byGetTime"), string.format("TOUKIBI_BETTERPICKQUEUE_SETVALUE('%s', '%s')", "OrderBy", "byGetTime"), nil, (Me.Settings.OrderBy == "byGetTime"));
		end
		
		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.3, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AllwaysDisplay"));
		if Me.Settings.useSimpleMenu then
			-- かんたんメニューときだけ表示
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.ElapsedTime"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ShowElapsedTime", not Me.Settings.ShowElapsedTime and 1 or 0), nil, Me.Settings.ShowElapsedTime);
		end
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Silver"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ShowVis", not Me.Settings.ShowVis and 1 or 0), nil, Me.Settings.ShowVis);
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.WeightData"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ShowWeight", not Me.Settings.ShowWeight and 1 or 0), nil, Me.Settings.ShowWeight);
		if not Me.Settings.useSimpleMenu then
			-- カスタムメニューのときだけ表示
			Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.OldItem"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ShowOldItem", not Me.Settings.ShowOldItem and 1 or 0), nil, Me.Settings.ShowOldItem);
		end
		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.4);
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.LockPosition"), "TOUKIBI_BETTERPICKQUEUE_CHANGE_MOVABLE()", nil, not Me.Settings.Movable);
		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.5);
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ResetSession"), "TOUKIBI_BETTERPICKQUEUE_RESET_DATA()");
		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.6);
	else
		cmenuWidth = 270
		--第2メニュー
		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.1);
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.HideOriginalQueue"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "HideOriginalQueue", not Me.Settings.HideOriginalQueue and 1 or 0), nil, Me.Settings.HideOriginalQueue);
		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.2, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoReset"));
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "AutoReset.byMap"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "AutoResetByMap", not Me.Settings.AutoResetByMap and 1 or 0), nil, Me.Settings.AutoResetByMap);
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "AutoReset.byChannel"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "AutoResetByCh", not Me.Settings.AutoResetByCh and 1 or 0), nil, Me.Settings.AutoResetByCh);
		
		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.3, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.BackGround"));
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "BackGround.Deep"), string.format("TOUKIBI_BETTERPICKQUEUE_SETVALUE('%s', '%s')", "SkinName", "systemmenu_vertical"), nil, (Me.Settings.SkinName == "systemmenu_vertical"));
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "BackGround.Thin"), string.format("TOUKIBI_BETTERPICKQUEUE_SETVALUE('%s', '%s')", "SkinName", "chat_window"), nil, (Me.Settings.SkinName == "chat_window"));
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "BackGround.None"), string.format("TOUKIBI_BETTERPICKQUEUE_SETVALUE('%s', '%s')", "SkinName", "None"), nil, (Me.Settings.SkinName == "None"));
		
		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.4, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ExpandTo_Horizonal"));
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ExpandTo_Left"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ExpandTo_Left", 1), nil, Me.Settings.ExpandTo_Left);
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ExpandTo_Right"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ExpandTo_Left", 0), nil, not Me.Settings.ExpandTo_Left);
		
		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.5, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ExpandTo_Vertical"));
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ExpandTo_Up"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ExpandTo_Up", 1), nil, Me.Settings.ExpandTo_Up);
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ExpandTo_Down"), string.format("TOUKIBI_BETTERPICKQUEUE_TOGGLE_VALUE('%s', %s)", "ExpandTo_Up", 0), nil, not Me.Settings.ExpandTo_Up);

		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.6);
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ResetPosition"), "TOUKIBI_BETTERPICKQUEUE_RESET_POSITION()");
		Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.UpdateNow"), "TOUKIBI_BETTERPICKQUEUE_UPDATE()");

		Toukibi:MakeCMenuSeparator(context, cmenuWidth - 30 + 0.7);
	end
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Close"));
	context:Resize(cmenuWidth, context:GetHeight());
	ui.OpenContextMenu(context);
	return context;
end

function TOUKIBI_BETTERPICKQUEUE_ON_GAME_START()
	local NowMapClassName = session.GetMapName();
	local isMapChanged = (Me.Data.BeforeMap ~= NowMapClassName)
	if Me.Settings.AutoResetByCh or (Me.Settings.AutoResetByMap and isMapChanged) then
		TOUKIBI_BETTERPICKQUEUE_RESET_DATA();
	end
	Me.Data.BeforeMap = NowMapClassName;
	Me.UpdateFrame();
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取
function TOUKIBI_BETTERPICKQUEUE_PROCESS_COMMAND(command)
	Toukibi:AddLog(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ExecuteCommands"), SlashCommandList[1] .. " " .. table.concat(command, " ")), "Info", true, true);
	local cmd = ""; 
	if #command > 0 then 
		-- パラメータが存在した場合はパラメータの1個めを抜き出してみる
		cmd = table.remove(command, 1); 
	else
		-- パラメータなしでコマンドが呼ばれた場合
		ui.ToggleFrame(addonNameLower)
		return;
	end 
	if cmd == "reset" then 
		-- 計測をリセット
		TOUKIBI_BETTERPICKQUEUE_RESET_DATA();
		return;
	elseif cmd == "resetpos" then 
		-- 位置をリセット
		Me.ResetPos();
		return;
	elseif cmd == "resetsetting" then 
		-- 設定をリセット
		MargeDefaultSetting(true, true);
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ResetSettings"), "Notice", true, false);
		Me.UpdatePos();
		TOUKIBI_BETTERPICKQUEUE_UPDATE();
		return;
	elseif cmd == "update" then
		-- Updateの処理をここに書く
		TOUKIBI_BETTERPICKQUEUE_UPDATE();
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
function BETTERPICKQUEUE_ON_INIT(addon, frame)
	-- 設定を読み込む
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	if Me.Settings.DoNothing then return end

	-- イベントを登録する
	frame:SetEventScript(ui.LBUTTONDOWN, "TOUKIBI_BETTERPICKQUEUE_START_DRAG");
	frame:SetEventScript(ui.LBUTTONUP, "TOUKIBI_BETTERPICKQUEUE_END_DRAG");

	frame:SetEventScript(ui.RBUTTONDOWN, "TOUKIBI_BETTERPICKQUEUE_CONTEXT_MENU");

	addon:RegisterMsg('ITEM_PICK', 'TOUKIBI_BETTERPICKQUEUE_ON_ITEM_PICK');
	addon:RegisterMsg('GAME_START', 'TOUKIBI_BETTERPICKQUEUE_ON_GAME_START');
	addon:RegisterMsg("FPS_UPDATE", "TOUKIBI_BETTERPICKQUEUE_UPDATE");
	
	-- フックしたいイベントを記述
	Toukibi:SetHook("ITEMMSG_SHOW_GET_ITEM", Me.ITEMMSG_SHOW_GET_ITEM_HOOKED); 
	

	Me.IsDragging = false;
	ui.GetFrame(addonNameLower):EnableMove(Me.Settings.Movable and 1 or 0);
	
	Me.UpdatePos()

	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_BETTERPICKQUEUE_PROCESS_COMMAND);
	end
end

