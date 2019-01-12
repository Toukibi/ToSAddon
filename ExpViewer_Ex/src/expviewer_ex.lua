local addonName = "ExpViewer_Ex";
local verText = "1.02";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/expv", "/expviewer"};
local CommandParamList = {
	reset = {jp = "設定リセット", en = "Reset the all settings."}
  , update = {jp = "表示を更新", en = "The additional information displayed will be updated."}
  , jp = {jp = "日本語モードに切り替え", en = "Switch to Japanese mode.(日本語へ)"}
  , en = {jp = "英語モードに切り替え(Switch to English mode.)", en = "Switch to English mode."}
  };
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
expv = Me;
local DebugMode = false;

-- テキストリソース
local ResText = {
	jp = {
		Menu = {
			Title = "{#006666}=== Exp Viewerの設定 ==={/}"
			, ResetSession = "{#FFFF88}リセットする{/}"
			, UpdateNow = "今すぐ更新する"
			, DisplayItems = "表示項目"
			, BufferLen = "サンプル時間の長さ"
			, Minutes = "分"
			, AutoReset = "オートリセット機能"
			, UseAutoReset = "使用する"
			, TimeToBeIdle = "放置時間の長さ"
			, useMetricPrefix = "単位表記を用いる"
			, LockPosition = "位置を固定する"
			, Close = "{#666666}閉じる{/}"
		},
		Display= {
			Title_Current = "現在 / 要求"
		  , Title_Rate = "％"
		  , Title_Gain = "最終取得"
		  , Title_TNL = "予想討伐数"
		  , Title_ExpPerHour = "時給"
		  , Title_ETA = "予想時間"
		  , PercentChar = "％"
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
			Title = "{#006666}=== Exp Viewer setting ==={/}"
			, ResetSession = "{#FFFF88}Reset Session{/}"
			, UpdateNow = "Update now!"
			, DisplayItems = "Display Items"
			, BufferLen = "Buffer Length"
			, Minutes = "min."
			, AutoReset = "Auto Reset"
			, UseAutoReset = "Use Auto Reset"
			, TimeToBeIdle = "Time to be idle"
			, useMetricPrefix = "Use metric prefix"
			, LockPosition = "Lock position"
			, Close = "{#666666}Close{/}"
		  },
		  Display= {
			Title_Current = "Current / Required"
		  , Title_Rate = "%"
		  , Title_Gain = "Gain"
		  , Title_TNL = "TNL"
		  , Title_ExpPerHour = "Exp/Hr"
		  , Title_ETA = "ETA"
		  , PercentChar = "%"
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
	MakeCMenuSeparator = function(self, parent, width)
		width = width or 300;
		ui.AddContextMenuItem(parent, string.format("{img fullgray %s 1}", width), "None");
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


-- ***** 変数の宣言と設定 *****
Me.SettingFilePathName = string.format("../addons/%s/%s", addonNameLower, SettingFileName);
Me.Loaded = false;
Me.Data = Me.Data or {};
Me.Data.ExpData = Me.Data.ExpData or {};
Me.Data.Buffer = Me.Data.Buffer or {};
Me.Data.Display = Me.Data.Display or {};

-- 設定書き込み
local function SaveSetting()
	Toukibi:SaveTable(Me.SettingFilePathName, Me.Settings);
end

-- デフォルト設定(ForceがTrueでない場合は、既存の値はそのまま引き継ぐ)
local function MargeDefaultSetting(Force, DoSave)
	DoSave = Toukibi:GetValueOrDefault(DoSave, true);
	Me.Settings = Me.Settings or {};
	Me.Settings.DoNothing	 = Toukibi:GetValueOrDefault(Me.Settings.DoNothing		, false, Force);
	Me.Settings.Lang		 = Toukibi:GetValueOrDefault(Me.Settings.Lang			, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.Movable		 = Toukibi:GetValueOrDefault(Me.Settings.Movable		, true, Force);
	Me.Settings.Visible		 = Toukibi:GetValueOrDefault(Me.Settings.Visible		, true, Force);
	Me.Settings.PosX		 = Toukibi:GetValueOrDefault(Me.Settings.PosX			, 0, Force);
	Me.Settings.PosY		 = Toukibi:GetValueOrDefault(Me.Settings.PosY			, 250, Force);

	Me.Settings.showCurrent	 = Toukibi:GetValueOrDefault(Me.Settings.showCurrent	, true, Force);
	Me.Settings.showRate	 = Toukibi:GetValueOrDefault(Me.Settings.showRate		, true, Force);
	Me.Settings.showGain	 = Toukibi:GetValueOrDefault(Me.Settings.showGain		, true, Force);
	Me.Settings.showTNL		 = Toukibi:GetValueOrDefault(Me.Settings.showTNL		, true, Force);
	Me.Settings.showPerHour	 = Toukibi:GetValueOrDefault(Me.Settings.showPerHour	, true, Force);
	Me.Settings.showETA		 = Toukibi:GetValueOrDefault(Me.Settings.showETA		, true, Force);
	
	Me.Settings.useMetricPrefix = Toukibi:GetValueOrDefault(Me.Settings.useMetricPrefix, false, Force);
	Me.Settings.BufferLen	 = Toukibi:GetValueOrDefault(Me.Settings.BufferLen		, 100, Force);
	Me.Settings.useAutoReset = Toukibi:GetValueOrDefault(Me.Settings.useAutoReset	, true, Force);
	Me.Settings.IdleLen		 = Toukibi:GetValueOrDefault(Me.Settings.IdleLen		, 100, Force);
	

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
		SignMark = " " .. SignMark .. " ";
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

local function GetValueTextEx(value, MaxTextLen)
	if Me.Settings.useMetricPrefix then
		local prefixList = {"", "k", "M", "G", "T", "P", "E", "Z", "Y"}
		local nowIndex = 1;
		local tmpValue = value;
		while tmpValue >= 1000 do
			tmpValue = tmpValue / 1000
			nowIndex = nowIndex + 1
		end
		local fmtText = "%s";
		if nowIndex == 1 and tmpValue - math.floor(tmpValue) == 0 then
			fmtText = "%d"
		elseif tmpValue > 100 then
			fmtText = "%3.1f"
		elseif tmpValue > 10 then
			fmtText = "%2.2f"
		elseif tmpValue > 1 then
			fmtText = "%1.3f"
		else
			fmtText = "%0.3f"
		end
		return string.format(fmtText .. "%s", tmpValue, prefixList[nowIndex])
	else
		return GetCommaedTextEx(value, MaxTextLen);
	end
end

local function GetETAText(value)
	local resultText =  "";
	local tmpValue = value;
	if value >= 25 then
		resultText = resultText .. string.format("%sd  ", math.floor(tmpValue / 24));
	end
	tmpValue = (tmpValue % 24) * 3600;
	resultText = resultText .. string.format("%02d:", math.floor(tmpValue / 3600));
	tmpValue = tmpValue % 3600;
	resultText = resultText .. string.format("%02d:", math.floor(tmpValue / 60));
	tmpValue = tmpValue % 60;
	resultText = resultText .. string.format("%02d", math.ceil(tmpValue));
	return resultText;
end

local function GetBufferIndex()
	--ローカル時刻を取る
	local clock = os.date("*t");
	local hourNum = clock.hour;
	local minNum = clock.min;
	local secNum = clock.sec;
	local indexNum = minNum * 20 + math.floor(secNum / 3) + 1
	return hourNum, indexNum;
end

local function HasBufferData(objBuffer)
	if objBuffer == nil then return false end
	return Toukibi:GetTableLen(objBuffer) > 0
end

local function HasBufferDataByIndex(index)
	if Me.Data.Buffer[index] == nil then return false end
	return Toukibi:GetTableLen(Me.Data.Buffer[index]) > 0
end

local function isBufferItemAvailable(index, hour)
	if Me.Data.Buffer[index] == nil or Me.Data.Buffer[index].Hour == nil or Me.Data.Buffer[index].Hour ~= hour then
		return false;
	end
	return true;
end

local function ResetBufferItem(index, newHour)
	Me.Data.Buffer[index] = {};
	Me.Data.Buffer[index].Hour = newHour;
	Me.Data.Buffer[index].BaseExp = 0;
	Me.Data.Buffer[index].JobExp = 0;
	Me.Data.Buffer[index].Money = 0;
end

function Me.isIdle(length)
	local hour, nowIndex = GetBufferIndex();
	local objBuffer = Me.Data.Buffer[nowIndex];

	local useBufferLen = length or Me.Settings.IdleLen; -- recomend 100(5min) to 600(30min)
	for i = 1, useBufferLen do
		objBuffer = Me.Data.Buffer[nowIndex];
		if objBuffer ~= nil and HasBufferData(objBuffer) then
			if (objBuffer.BaseExp or 0) + (objBuffer.JobExp or 0) > 0 then
				return false;
			end
		end
		nowIndex = nowIndex - 1;
		if nowIndex == 0 then nowIndex = 1200 end
	end
	return true;
end

function Me.EraseIdleBuffer()
	local hour, nowIndex = GetBufferIndex();
	local objBuffer = Me.Data.Buffer[nowIndex];

	for i = 1, 1200 do
		objBuffer = Me.Data.Buffer[nowIndex];
		if objBuffer ~= nil and HasBufferData(objBuffer) then
			if (objBuffer.BaseExp or 0) + (objBuffer.JobExp or 0) > 0 then
				return;
			end
			Me.Data.Buffer[nowIndex] = {};
		end
		nowIndex = nowIndex - 1;
		if nowIndex == 0 then nowIndex = 1200 end
	end
end

function Me.EraseAllBuffer()
	Me.Data.Buffer = {};
end

function Me.DoAutoReset()
	if not Me.Settings.useAutoReset then return end
	if Me.isIdle() then
		Me.EraseIdleBuffer()
	end
end

function Me.UpdateBaseExpData()
	-- 更新前の現在値を前回値に移動する
	Me.Data.ExpData.prevBaseExp = Me.Data.ExpData.nowBaseExp;
	Me.Data.ExpData.prevBaseTotalExp = Me.Data.ExpData.nowBaseTotalExp;
	-- 現在値を更新する
	Me.Data.ExpData.nowBaseExp = session.GetEXP();
	Me.Data.ExpData.reqBaseExp = session.GetMaxEXP();
	local clsXp = GetClass('Xp', GetMyPCObject().Lv - 1);
	if clsXp ~= nil then
		Me.Data.ExpData.nowBaseTotalExp = clsXp.TotalXp + Me.Data.ExpData.nowBaseExp;
	else
		Me.Data.ExpData.nowBaseTotalExp = nil;
	end
	-- 差分を求める(今回と前回のどちらかのデータが欠けている場合は行わない)
	if Me.Data.ExpData.prevBaseTotalExp ~= nil and Me.Data.ExpData.nowBaseTotalExp ~= nil then
		Me.DoAutoReset();
		local diffExp = Me.Data.ExpData.nowBaseTotalExp - Me.Data.ExpData.prevBaseTotalExp;
		Me.Data.ExpData.diffBaseExp = diffExp;
		local hour, index = GetBufferIndex();
		-- リングバッファーがない場合や古い場合はリセットする
		if not isBufferItemAvailable(index, hour) then
			ResetBufferItem(index, hour);
		end
		-- リングバッファーに加算する
		Me.Data.Buffer[index].BaseExp = Me.Data.Buffer[index].BaseExp + diffExp;
	else
		Me.Data.ExpData.diffBaseExp = nil;
	end
end

function Me.UpdateJobExpData(exp, tableinfo)
	-- 更新前の現在値を前回値に移動する
	Me.Data.ExpData.prevJobExp = Me.Data.ExpData.nowJobExp;
	Me.Data.ExpData.prevJobTotalExp = Me.Data.ExpData.nowJobTotalExp;
	-- 現在値を更新する
	local nowExp = exp;
	local nowClassLevel = tableinfo.level;
	Me.Data.ExpData.nowJobExp = exp - tableinfo.startExp;
	Me.Data.ExpData.nowJobTotalExp = exp;
	Me.Data.ExpData.reqJobExp = tableinfo.endExp - tableinfo.startExp;
	-- 差分を求める(今回と前回のどちらかのデータが欠けている場合は行わない)
	if Me.Data.ExpData.prevJobTotalExp ~= nil and Me.Data.ExpData.nowJobTotalExp ~= nil then
		Me.DoAutoReset();
		local diffExp = Me.Data.ExpData.nowJobTotalExp - Me.Data.ExpData.prevJobTotalExp;
		Me.Data.ExpData.diffJobExp = diffExp;
		local hour, index = GetBufferIndex();
		-- リングバッファーがない場合や古い場合はリセットする
		if not isBufferItemAvailable(index, hour) then
			ResetBufferItem(index, hour);
		end
		-- リングバッファーに加算する
		Me.Data.Buffer[index].JobExp = Me.Data.Buffer[index].JobExp + diffExp;
	else
		Me.Data.ExpData.diffJobExp = nil;
	end
end

function Me.UpdateItemPickData(itemType, itemCount)
	local item = session.GetInvItemByType(itemType);
	if item == nil then return end
	local itemCls = GetClassByType("Item", tonumber(itemType));
	if itemCls == nil then return end
	-- お金であるか
	if itemCls.ClassName == "Vis" then
		-- 更新前の現在値を前回値に移動する
		Me.Data.ExpData.prevMoney = Me.Data.ExpData.nowMoney;
		-- 現在値を更新する
		Me.Data.ExpData.nowMoney = item.count;
		Me.Data.ExpData.diffMoney = itemCount;
		Me.DoAutoReset();
		local hour, index = GetBufferIndex();
		-- リングバッファーがない場合や古い場合はリセットする
		if not isBufferItemAvailable(index, hour) then
			ResetBufferItem(index, hour);
		end
		-- リングバッファーに加算する
		Me.Data.Buffer[index].Money = Me.Data.Buffer[index].Money + itemCount;
	end
end

function Me.UpdateDisplayData()
	local baseLen = string.len(GetCommaedTextEx(Me.Data.ExpData.reqBaseExp));
	local jobLen = string.len(GetCommaedTextEx(Me.Data.ExpData.reqJobExp));
	local intTemp = baseLen;
	if jobLen > baseLen then intTemp = jobLen end
	Me.Data.Display.nowBaseExp = GetValueTextEx(Me.Data.ExpData.nowBaseExp, intTemp);
	Me.Data.Display.reqBaseExp = GetValueTextEx(Me.Data.ExpData.reqBaseExp, intTemp);
	Me.Data.Display.nowJobExp = GetValueTextEx(Me.Data.ExpData.nowJobExp, intTemp);
	Me.Data.Display.reqJobExp = GetValueTextEx(Me.Data.ExpData.reqJobExp, intTemp);
	Me.Data.Display.nowMoney = GetValueTextEx(Me.Data.ExpData.nowMoney);
	
	Me.Data.Display.baseRate = "--.--";
	if Me.Data.ExpData.reqBaseExp > 0 then
		Me.Data.Display.baseRate = GetCommaedTextEx(Me.Data.ExpData.nowBaseExp * 100 / Me.Data.ExpData.reqBaseExp, 6, 2);
	end
	Me.Data.Display.jobRate = "--.--";
	if Me.Data.ExpData.reqJobExp > 0 then
		Me.Data.Display.jobRate = GetCommaedTextEx(Me.Data.ExpData.nowJobExp * 100 / Me.Data.ExpData.reqJobExp, 6, 2);
	end

	Me.Data.Display.baseGain = "---";
	if Me.Data.ExpData.diffBaseExp ~= nil then
		Me.Data.Display.baseGain = GetValueTextEx(Me.Data.ExpData.diffBaseExp);
	end
	Me.Data.Display.jobGain = "---";
	if Me.Data.ExpData.diffJobExp ~= nil then
		Me.Data.Display.jobGain = GetValueTextEx(Me.Data.ExpData.diffJobExp);
	end
	Me.Data.Display.moneyGain = "---";
	if Me.Data.ExpData.diffMoney ~= nil then
		Me.Data.Display.moneyGain = GetValueTextEx(Me.Data.ExpData.diffMoney);
	end

	Me.Data.Display.baseTNL = "---";
	if Me.Data.ExpData.diffBaseExp ~= nil and Me.Data.ExpData.diffBaseExp > 0 then
		Me.Data.Display.baseTNL = GetCommaedTextEx((Me.Data.ExpData.reqBaseExp - Me.Data.ExpData.nowBaseExp) / Me.Data.ExpData.diffBaseExp);
	end
	Me.Data.Display.jobTNL = "---";
	if Me.Data.ExpData.diffJobExp ~= nil and Me.Data.ExpData.diffJobExp > 0  then
		Me.Data.Display.jobTNL = GetCommaedTextEx((Me.Data.ExpData.reqJobExp - Me.Data.ExpData.nowJobExp) / Me.Data.ExpData.diffJobExp);
	end

	local hour, nowIndex = GetBufferIndex();
	local objBuffer = Me.Data.Buffer[nowIndex];
	-- リングバッファーがない場合や古い場合はリセットする
	if not isBufferItemAvailable(nowIndex, hour) then
		ResetBufferItem(nowIndex, hour)
	end

	local useBufferLen = Me.Settings.BufferLen;
	local sumBase, sumJob, sumMoney, bufferCount = 0, 0, 0, 0;
	for i = 1, useBufferLen do
		objBuffer = Me.Data.Buffer[nowIndex];
		if objBuffer ~= nil and HasBufferData(objBuffer) then
			bufferCount = bufferCount + 1;
			sumBase = sumBase + (objBuffer.BaseExp or 0);
			sumJob = sumJob + (objBuffer.JobExp or 0);
			sumMoney = sumMoney + (objBuffer.Money or 0);
		end
		nowIndex = nowIndex - 1;
		if nowIndex == 0 then nowIndex = 1200 end
	end
	Me.Data.ExpData.baseExpPerHour = nil;
	Me.Data.ExpData.jobExpPerHour = nil;
	Me.Data.ExpData.moneyPerHour = nil;
	Me.Data.Display.baseExpPerHour = "---";
	Me.Data.Display.jobExpPerHour = "---";
	Me.Data.Display.moneyPerHour = "---";
	if bufferCount > 0 then
		Me.Data.ExpData.baseExpPerHour = sumBase * 1200 / bufferCount;
		Me.Data.ExpData.jobExpPerHour = sumJob * 1200 / bufferCount;
		Me.Data.ExpData.moneyPerHour = sumMoney * 1200 / bufferCount;
		Me.Data.Display.baseExpPerHour = GetValueTextEx(Me.Data.ExpData.baseExpPerHour);
		Me.Data.Display.jobExpPerHour = GetValueTextEx(Me.Data.ExpData.jobExpPerHour);
		Me.Data.Display.moneyPerHour = GetValueTextEx(Me.Data.ExpData.moneyPerHour);
	end
	Me.Data.Display.baseETA = "--:--:--";
	if Me.Data.ExpData.baseExpPerHour >= 1 then
		Me.Data.Display.baseETA = GetETAText((Me.Data.ExpData.reqBaseExp - Me.Data.ExpData.nowBaseExp) / Me.Data.ExpData.baseExpPerHour);
	end
	Me.Data.Display.jobETA = "--:--:--";
	if Me.Data.ExpData.jobExpPerHour >= 1 then
		Me.Data.Display.jobETA = GetETAText((Me.Data.ExpData.reqJobExp - Me.Data.ExpData.nowJobExp) / Me.Data.ExpData.jobExpPerHour);
	end

	Me.UpdateFrame()
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

local function HideLabel(parent, ctrlName)
	if parent == nil then return end
	if ctrlName == nil or ctrlName == "" then return end
	local objLabel = tolua.cast(parent:CreateOrGetControl("richtext", ctrlName, 0, 0, 10, 4), "ui::CRichText");
	objLabel:ShowWindow(0);
	return objLabel;
end

local function AdjustLabelPos(lblTitle, lblBase, lblJob, lblMoney, widthData)
	local MaxWidth = math.max(widthData[1], widthData[2], widthData[3], widthData[4]);
	local baseX = lblTitle:GetX();
	lblBase:SetMargin(baseX + MaxWidth - lblBase:GetWidth(), lblBase:GetY(), 0, 0);
	lblJob:SetMargin(baseX + MaxWidth - lblJob:GetWidth(), lblJob:GetY(), 0, 0);
	lblMoney:SetMargin(baseX + MaxWidth - lblMoney:GetWidth(), lblMoney:GetY(), 0, 0);
	return MaxWidth;
end

function Me.UpdateFrame()
	local objFrame = ui.GetFrame(addonNameLower);
	if objFrame == nil then return end

	local styleTitle = {"#AAFFAA", "s12", "ol", "b"}
	local styleValue = {"#EEEEEE", "s16", "ol", "b"}
	local LeftMargin = 10;
	
	local lblTitle, lblBase, lblJob, lblMoney;
	local nowWidth, nowHeight = 0, 0;
	local gleft, gTop = 0, 0;
	local tmpWidth = {};
	local titleHeight, valueHeight = 16, 22;

	nowWidth, nowHeight = 2, 2;
	gLeft, gTop = nowWidth, 2;

	if Me.Settings.showCurrent then
		lblTitle = AddLabel(objFrame, "lblCurrentTitle", Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Title_Current"), gLeft, gTop, styleTitle)
		tmpWidth[1] = lblTitle:GetWidth();
		lblBase = AddLabel(objFrame, "lblCurrentBase", string.format("%s / %s", Me.Data.Display.nowBaseExp, Me.Data.Display.reqBaseExp), gLeft + LeftMargin, gTop + titleHeight, styleValue)
		tmpWidth[2] = LeftMargin + lblBase:GetWidth();
		lblJob = AddLabel(objFrame, "lblCurrentJob", string.format("%s / %s", Me.Data.Display.nowJobExp, Me.Data.Display.reqJobExp), gLeft + LeftMargin, gTop + titleHeight + valueHeight, styleValue)
		tmpWidth[3] = LeftMargin + lblJob:GetWidth();
		lblMoney = AddLabel(objFrame, "lblCurrentMoney", string.format("%s s", Me.Data.Display.nowMoney), gLeft + LeftMargin, gTop + titleHeight + valueHeight * 2, styleValue)
		tmpWidth[4] = LeftMargin + lblMoney:GetWidth();
		gLeft = gLeft + AdjustLabelPos(lblTitle, lblBase, lblJob, lblMoney, tmpWidth) + LeftMargin;
	else
		HideLabel(objFrame, "lblCurrentTitle")
		HideLabel(objFrame, "lblCurrentBase")
		HideLabel(objFrame, "lblCurrentJob")
		HideLabel(objFrame, "lblCurrentMoney")
	end

	if Me.Settings.showRate then
		lblTitle = AddLabel(objFrame, "lblRateTitle", Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.PercentChar"), gLeft, gTop, styleTitle)
		tmpWidth[1] = lblTitle:GetWidth();
		lblBase = AddLabel(objFrame, "lblRateBase", string.format("%s%s", Me.Data.Display.baseRate, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.PercentChar")), gLeft, gTop + titleHeight, styleValue)
		tmpWidth[2] = lblBase:GetWidth();
		lblJob = AddLabel(objFrame, "lblRateJob", string.format("%s%s", Me.Data.Display.jobRate, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.PercentChar")), gLeft, gTop + titleHeight + valueHeight, styleValue)
		tmpWidth[3] = lblJob:GetWidth();
		local strTemp = "";
		if not Me.Settings.showCurrent then
			strTemp = string.format("%s s", Me.Data.Display.nowMoney);
		end
		lblMoney = AddLabel(objFrame, "lblRateMoney", strTemp, gLeft, gTop + titleHeight + valueHeight * 2, styleValue)
		tmpWidth[4] = lblMoney:GetWidth();
		gLeft = gLeft + AdjustLabelPos(lblTitle, lblBase, lblJob, lblMoney, tmpWidth) + LeftMargin;
	else
		HideLabel(objFrame, "lblRateTitle")
		HideLabel(objFrame, "lblRateBase")
		HideLabel(objFrame, "lblRateJob")
		HideLabel(objFrame, "lblRateMoney")
	end

	if Me.Settings.showGain then
		lblTitle = AddLabel(objFrame, "lblGainTitle", Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Title_Gain"), gLeft, gTop, styleTitle)
		tmpWidth[1] = lblTitle:GetWidth();
		lblBase = AddLabel(objFrame, "lblGainBase", Me.Data.Display.baseGain, gLeft + LeftMargin, gTop + titleHeight, styleValue)
		tmpWidth[2] = LeftMargin + lblBase:GetWidth();
		lblJob = AddLabel(objFrame, "lblGainJob", Me.Data.Display.jobGain, gLeft + LeftMargin, gTop + titleHeight + valueHeight, styleValue)
		tmpWidth[3] = LeftMargin + lblJob:GetWidth();
		lblMoney = AddLabel(objFrame, "lblGainMoney", string.format("%s s", Me.Data.Display.moneyGain), gLeft + LeftMargin, gTop + titleHeight + valueHeight * 2, styleValue)
		tmpWidth[4] = LeftMargin + lblMoney:GetWidth();
		gLeft = gLeft + AdjustLabelPos(lblTitle, lblBase, lblJob, lblMoney, tmpWidth) + LeftMargin;
	else
		HideLabel(objFrame, "lblGainTitle")
		HideLabel(objFrame, "lblGainBase")
		HideLabel(objFrame, "lblGainJob")
		HideLabel(objFrame, "lblGainMoney")
	end

	if Me.Settings.showTNL then
		lblTitle = AddLabel(objFrame, "lblTNLTitle", Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Title_TNL"), gLeft, gTop, styleTitle)
		tmpWidth[1] = lblTitle:GetWidth();
		lblBase = AddLabel(objFrame, "lblTNLBase", Me.Data.Display.baseTNL, gLeft + LeftMargin, gTop + titleHeight, styleValue)
		tmpWidth[2] = LeftMargin + lblBase:GetWidth();
		lblJob = AddLabel(objFrame, "lblTNLJob", Me.Data.Display.jobTNL, gLeft + LeftMargin, gTop + titleHeight + valueHeight, styleValue)
		tmpWidth[3] = LeftMargin + lblJob:GetWidth();
		lblMoney = AddLabel(objFrame, "lblTNLMoney", "", gLeft + LeftMargin, gTop + titleHeight + valueHeight * 2, styleValue)
		tmpWidth[4] = LeftMargin + lblMoney:GetWidth();
		gLeft = gLeft + AdjustLabelPos(lblTitle, lblBase, lblJob, lblMoney, tmpWidth) + LeftMargin;
	else
		HideLabel(objFrame, "lblTNLTitle")
		HideLabel(objFrame, "lblTNLBase")
		HideLabel(objFrame, "lblTNLJob")
		HideLabel(objFrame, "lblTNLMoney")
	end

	if Me.Settings.showPerHour then
		lblTitle = AddLabel(objFrame, "lblExpHrTitle", Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Title_ExpPerHour"), gLeft, gTop, styleTitle)
		tmpWidth[1] = lblTitle:GetWidth();
		lblBase = AddLabel(objFrame, "lblExpHrBase", Me.Data.Display.baseExpPerHour, gLeft + LeftMargin, gTop + titleHeight, styleValue)
		tmpWidth[2] = LeftMargin + lblBase:GetWidth();
		lblJob = AddLabel(objFrame, "lblExpHrJob", Me.Data.Display.jobExpPerHour, gLeft + LeftMargin, gTop + titleHeight + valueHeight, styleValue)
		tmpWidth[3] = LeftMargin + lblJob:GetWidth();
		lblMoney = AddLabel(objFrame, "lblExpHrMoney", string.format("%s s", Me.Data.Display.moneyPerHour), gLeft + LeftMargin, gTop + titleHeight + valueHeight * 2, styleValue)
		tmpWidth[4] = LeftMargin + lblMoney:GetWidth();
		gLeft = gLeft + AdjustLabelPos(lblTitle, lblBase, lblJob, lblMoney, tmpWidth) + LeftMargin;
	else
		HideLabel(objFrame, "lblExpHrTitle")
		HideLabel(objFrame, "lblExpHrBase")
		HideLabel(objFrame, "lblExpHrJob")
		HideLabel(objFrame, "lblExpHrMoney")
	end

	if Me.Settings.showETA then
		lblTitle = AddLabel(objFrame, "lblETATitle", Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Title_ETA"), gLeft, gTop, styleTitle)
		tmpWidth[1] = lblTitle:GetWidth();
		lblBase = AddLabel(objFrame, "lblETABase", Me.Data.Display.baseETA, gLeft + LeftMargin, gTop + titleHeight, styleValue)
		tmpWidth[2] = LeftMargin + lblBase:GetWidth();
		lblJob = AddLabel(objFrame, "lblETAJob", Me.Data.Display.jobETA, gLeft + LeftMargin, gTop + titleHeight + valueHeight, styleValue)
		tmpWidth[3] = LeftMargin + lblJob:GetWidth();
		lblMoney = AddLabel(objFrame, "lblETAMoney", "", gLeft + LeftMargin, gTop + titleHeight + valueHeight * 2, styleValue)
		tmpWidth[4] = LeftMargin + lblMoney:GetWidth();
		gLeft = gLeft + AdjustLabelPos(lblTitle, lblBase, lblJob, lblMoney, tmpWidth) + LeftMargin;
	else
		HideLabel(objFrame, "lblETATitle")
		HideLabel(objFrame, "lblETABase")
		HideLabel(objFrame, "lblETAJob")
		HideLabel(objFrame, "lblETAMoney")
	end

	objFrame:Resize(gLeft, gTop + titleHeight + valueHeight * 3)

end

function Me.UpdatePos()
	local TopFrame = ui.GetFrame(addonNameLower);
	if TopFrame == nil then return end
	if Me.Settings ~= nil and Me.Settings.PosX ~= nil and Me.Settings.PosY ~= nil then
		TopFrame:SetPos(Me.Settings.PosX, Me.Settings.PosY);
	end
end

-- ===========================
--       イベント受け取り
-- ===========================

function TOUKIBI_EXPVIEWER_EXP_UPDATE(frame, msg, argStr, argNum)
	Me.UpdateBaseExpData();
end

function TOUKIBI_EXPVIEWER_JOB_EXP_UPDATE(frame, msg, str, exp, tableinfo)
	Me.UpdateJobExpData(exp, tableinfo);
end

function TOUKIBI_EXPVIEWER_CALCULATE_TICK()
	Me.UpdateDisplayData();
end

function TOUKIBI_EXPVIEWER_ITEM_PICK(frame, msg, itemType, itemCount)
	Me.UpdateItemPickData(itemType, itemCount);
end

function TOUKIBI_EXPVIEWER_ON_GAME_START()
	Me.UpdateBaseExpData();
	Me.Data.ExpData.nowMoney = session.GetInvItemByName('Vis').count;
end

function TOUKIBI_EXPVIEWER_START_DRAG()
	Me.IsDragging = true;
end

function TOUKIBI_EXPVIEWER_END_DRAG()
	Me.IsDragging = false;
	if not Me.Settings.Movable then return end
	local objFrame = ui.GetFrame(addonNameLower)
	if objFrame == nil then return end
	Me.Settings.PosX = objFrame:GetX();
	Me.Settings.PosY = objFrame:GetY();
	SaveSetting();
end

function TOUKIBI_EXPVIEWER_UPDATE()
	Me.UpdateDisplayData();
end

function TOUKIBI_EXPVIEWER_RESET_BUFFER()
	Me.EraseAllBuffer();
	Me.UpdateDisplayData();
end

function TOUKIBI_EXPVIEWER_CHANGE_MOVABLE()
	if Me.Settings == nil then return end
	Me.Settings.Movable = not Me.Settings.Movable;
	local objFrame = ui.GetFrame(addonNameLower)
	if objFrame ~= nil then
		objFrame:EnableMove(Me.Settings.Movable and 1 or 0);
		SaveSetting();
	end
end

function TOUKIBI_EXPVIEWER_TOGGLE_VALUE(propName, value)
	ui.CloseAllContextMenu();
	if Me.Settings == nil then return end
	Me.Settings[propName] = (value == 1);
	SaveSetting();
	Me.UpdateDisplayData();
end

function TOUKIBI_EXPVIEWER_SETVALUE(propName, value)
	ui.CloseAllContextMenu();
	if Me.Settings == nil then return end
	Me.Settings[propName] = value;
	SaveSetting();
end

function TOUKIBI_EXPVIEWER_CONTEXT_MENU(frame, ctrl)
	local context = ui.CreateContextMenu("EXPVIEWER_MAIN_RBTN"
	, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Title")
	, 0, 0, 250, 0);
	Toukibi:MakeCMenuSeparator(context, 240);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ResetSession"), "TOUKIBI_EXPVIEWER_RESET_BUFFER()");
	--Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.UpdateNow"), "TOUKIBI_EXPVIEWER_UPDATE()");
	Toukibi:MakeCMenuSeparator(context, 240.1);

	local subContextDisplay = ui.CreateContextMenu("SUBCONTEXT_DISPLAY", "", 0, 0, 0, 0);
		Toukibi:MakeCMenuItem(subContextDisplay, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Title_Current"), string.format("TOUKIBI_EXPVIEWER_TOGGLE_VALUE('%s', %s)", "showCurrent", not Me.Settings.showCurrent and 1 or 0), nil, Me.Settings.showCurrent);
		Toukibi:MakeCMenuItem(subContextDisplay, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Title_Rate"), string.format("TOUKIBI_EXPVIEWER_TOGGLE_VALUE('%s', %s)", "showRate", not Me.Settings.showRate and 1 or 0), nil, Me.Settings.showRate);
		Toukibi:MakeCMenuItem(subContextDisplay, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Title_Gain"), string.format("TOUKIBI_EXPVIEWER_TOGGLE_VALUE('%s', %s)", "showGain", not Me.Settings.showGain and 1 or 0), nil, Me.Settings.showGain);
		Toukibi:MakeCMenuItem(subContextDisplay, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Title_TNL"), string.format("TOUKIBI_EXPVIEWER_TOGGLE_VALUE('%s', %s)", "showTNL", not Me.Settings.showTNL and 1 or 0), nil, Me.Settings.showTNL);
		Toukibi:MakeCMenuItem(subContextDisplay, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Title_ExpPerHour"), string.format("TOUKIBI_EXPVIEWER_TOGGLE_VALUE('%s', %s)", "showPerHour", not Me.Settings.showPerHour and 1 or 0), nil, Me.Settings.showPerHour);
		Toukibi:MakeCMenuItem(subContextDisplay, Toukibi:GetResText(ResText, Me.Settings.Lang, "Display.Title_ETA"), string.format("TOUKIBI_EXPVIEWER_TOGGLE_VALUE('%s', %s)", "showETA", not Me.Settings.showETA and 1 or 0), nil, Me.Settings.showETA);
	subContextDisplay:Resize(200, subContextDisplay:GetHeight());
	Toukibi:MakeCMenuParentItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.DisplayItems"), subContextDisplay);
	
	local subContextBuffer = ui.CreateContextMenu("SUBCONTEXT_BUFFER", "", 0, 0, 0, 0);
	for i, v in ipairs({3, 5, 10, 15, 20, 30, 60}) do
		Toukibi:MakeCMenuItem(subContextBuffer, v .. Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Minutes"), string.format("TOUKIBI_EXPVIEWER_SETVALUE('%s', %s)", "BufferLen", v * 20), nil, (Me.Settings.BufferLen == v * 20));
	end
	subContextBuffer:Resize(120, subContextBuffer:GetHeight());
	Toukibi:MakeCMenuParentItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.BufferLen"), subContextBuffer);
	
	local subContextAutoReset = ui.CreateContextMenu("SUBCONTEXT_AUTORESET", "", 0, 0, 0, 0);
	Toukibi:MakeCMenuItem(subContextAutoReset, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.UseAutoReset"), string.format("TOUKIBI_EXPVIEWER_TOGGLE_VALUE('%s', %s)", "useAutoReset", not Me.Settings.useAutoReset and 1 or 0), nil, Me.Settings.useAutoReset);
	ui.AddContextMenuItem(subContextAutoReset, "{img fullgray 150 1}{s4} {/}{nl}" .. Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.TimeToBeIdle"), {"ol", "b", "s12", "#AAFFAA"}), "None");
	for i, v in ipairs({3, 5, 10, 15, 20, 30}) do
		Toukibi:MakeCMenuItem(subContextAutoReset, v .. Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Minutes"), string.format("TOUKIBI_EXPVIEWER_SETVALUE('%s', %s)", "IdleLen", v * 20), nil, (Me.Settings.IdleLen == v * 20));
	end
	subContextAutoReset:Resize(180, subContextAutoReset:GetHeight());
	Toukibi:MakeCMenuParentItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoReset"), subContextAutoReset);

	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.useMetricPrefix"), string.format("TOUKIBI_EXPVIEWER_TOGGLE_VALUE('%s', %s)", "useMetricPrefix", not Me.Settings.useMetricPrefix and 1 or 0), nil, Me.Settings.useMetricPrefix);
	
	Toukibi:MakeCMenuSeparator(context, 240.2);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.LockPosition"), "TOUKIBI_EXPVIEWER_CHANGE_MOVABLE()", nil, not Me.Settings.Movable);
	Toukibi:MakeCMenuSeparator(context, 240.3);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Close"));
	context:Resize(270, context:GetHeight());
	ui.OpenContextMenu(context);
	return context;
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取
function TOUKIBI_EXPVIEWER_PROCESS_COMMAND(command)
	Toukibi:AddLog(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ExecuteCommands"), SlashCommandList[1] .. " " .. table.concat(command, " ")), "Info", true, true);
	local cmd = ""; 
	if #command > 0 then 
		-- パラメータが存在した場合はパラメータの1個めを抜き出してみる
		cmd = table.remove(command, 1); 
	else
		-- パラメータなしでコマンドが呼ばれた場合

		-- Me.Show();
		-- return;
	end 
	if cmd == "reset" then 
		-- すべてをリセット
		MargeDefaultSetting(true, true);
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ResetSettings"), "Notice", true, false);
		return;
	elseif cmd == "update" then
		-- Updateの処理をここに書く
		Me.UpdateDisplayData();
		
		return;
	elseif cmd == "jp" or cmd == "en" or string.len(cmd) == 2 then
		-- 言語モードと勘違いした？
		if cmd == "ja" then cmd = "jp" end
		Me.ComLib:ChangeLanguage(cmd);
		-- 何か更新したければ更新処理をここに書く
		Me.UpdateDisplayData();
		
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
function EXPVIEWER_EX_ON_INIT(addon, frame)
	-- 設定を読み込む
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	if Me.Settings.DoNothing then return end

	--[[
	--タイマーを使う場合
	Me.timer_main = GET_CHILD(ui.GetFrame("mapmate"), "timer_main", "ui::CAddOnTimer");
	Me.timer_main:SetUpdateScript("[イベント名に変える]");
	--]]

	-- イベントを登録する
	frame:SetEventScript(ui.LBUTTONDOWN, "TOUKIBI_EXPVIEWER_START_DRAG");
	frame:SetEventScript(ui.LBUTTONUP, "TOUKIBI_EXPVIEWER_END_DRAG");

	frame:SetEventScript(ui.RBUTTONDOWN, "TOUKIBI_EXPVIEWER_CONTEXT_MENU");
	
	addon:RegisterMsg('EXP_UPDATE', 'TOUKIBI_EXPVIEWER_EXP_UPDATE');
	addon:RegisterMsg('JOB_EXP_UPDATE', 'TOUKIBI_EXPVIEWER_JOB_EXP_UPDATE');
	addon:RegisterMsg('JOB_EXP_ADD', 'TOUKIBI_EXPVIEWER_JOB_EXP_UPDATE');
	addon:RegisterMsg("FPS_UPDATE", "TOUKIBI_EXPVIEWER_CALCULATE_TICK");
	addon:RegisterMsg('ITEM_PICK', 'TOUKIBI_EXPVIEWER_ITEM_PICK');
	addon:RegisterMsg('GAME_START', 'TOUKIBI_EXPVIEWER_ON_GAME_START');
	
	Me.IsDragging = false;

	local objFrame = ui.GetFrame(addonNameLower)
	if objFrame ~= nil then
		objFrame:EnableMove(Me.Settings.Movable and 1 or 0);
	end

	Me.UpdatePos()
	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_EXPVIEWER_PROCESS_COMMAND);
	end
end

