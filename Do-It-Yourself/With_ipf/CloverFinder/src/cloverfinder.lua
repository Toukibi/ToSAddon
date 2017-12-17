local addonName = "CloverFinder";
local verText = "2.00";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/clover"} -- {"/コマンド1", "/コマンド2", .......};
local CommandParamList = {
	reset = {jp = "設定リセット", en = "Reset the all settings."}
  , party = {jp = "パーティーチャットで通知", en = "Notify by party chat", SubParam = "[on/off]"}
  , on = {jp = "マーク付けを行うようにします", en = "Enable marking."}
  , off = {jp = "マーク付けを行わなくします", en = "Disable marking."}
  , jp = {jp = "日本語モードに切り替え", en = "Switch to Japanese mode.(日本語へ)"}
  , en = {jp = "英語モードに切り替え(Switch to English mode.)", en = "Switch to English mode."}
};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
-- Clover = Me;
local DebugMode = false;

-- テキストリソース
local ResText = {
	jp = {
		General = {
			NoticeMsgFormat = "%sの%sを発見！"
		  , EnableMe = "{#CCCCCC}%s{/}が有効になりました"
		  , DisableMe = "{#CCCCCC}%s{/}が無効になりました"
		  , EnableNotify = "{#CCCCCC}'パーティーチャットで通知'{/}が有効になりました"
		  , DisableNotify = "{#CCCCCC}'パーティーチャットで通知'{/}が無効になりました"
		},
		BuffType = {
			Gold = "金色"
		  , Silver = "銀色"
		  , Blue = "青色"
		  , Red = "赤色"
		  , Elite = "エリート"
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
		General = {
			NoticeMsgFormat = "%s %s spotted!!"
		  , EnableMe = "{#CCCCCC}%s{/} has been activated"
		  , DisableMe = "{#CCCCCC}%s{/} has been disabled"
		  , EnableNotify = "{#CCCCCC}'Notify by party chat'{/} has been activated"
		  , DisableNotify = "{#CCCCCC}'Notify by party chat'{/} has been disabled"
		},
		BuffType = {
			Gold = "Gold"
		  , Silver = "Silver"
		  , Blue = "Blue"
		  , Red = "Red"
		  , Elite = "Elite"
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

-- 検出するバフ一覧
local DetectBuffList = {
	{
		ID = 5028
	  , Icon = "icon_item_jewelrybox"
	  , BG = "gacha_01"
	  , Type = "Gold"
	  , checkFn = function(buff) return buff.arg2 == 1 end
	},
	{
		ID = 5028
	  , Icon = "icon_item_jewelrybox"
	  , BG = "gacha_02"
	  , Type = "Silver"
	  , checkFn = nil
	},
	{
		ID = 5079
	  , Icon = "icon_expup_total"
	  , BG = "gacha_01"
	  , Type = "Blue"
	  , checkFn = nil
	},
	{
		ID = 5086
	  , Icon = "icon_state_medium"
	  , BG = "gacha_03"
	  , Type = "Red"
	  , checkFn = nil
	},
	{
		ID = 5087
	  , Icon = "icon_fieldboss"
	  , BG = "gacha_03"
	  , Type = "Elite"
	  , checkFn = nil
	}
};

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
				Title = string.format("{#666666}%sのパラメータ説明{/}", addonName)
			  , Description = string.format("{#92D2A0}%sは次のパラメータで設定を呼び出してください。{/}", addonName)
			  , ParamDummy = "[パラメータ]"
			  , OrText = "または"
			  , EnableTitle = "使用可能なコマンド"
			}
		},
		en = {
			System = {
				InitMsg = "[Add-ons]" .. addonName .. verText .. " loaded!"
			  , NoSaveFileName = "The filename of save settings is not specified."
			  , HasErrorOnSaveSettings = "An error occurred while saving the settings."
			  , CompleteSaveSettings = "Settings saved."
			  , ErrorToUseDefaults = "Using default settings because an error occurred while loading the settings."
			  , CompleteLoadDefault = "Default settings loaded."
			  , CompleteLoadSettings = "Settings loaded!"
			},
			Command = {
				ExecuteCommands = "Command '{#333366}%s{/}' was called."
			  , ResetSettings = "Settings reset."
			  , InvalidCommand = "Invalid command called."
			  , AnnounceCommandList = "Please use [ %s ? ] to see the command list."
				},
			Help = {
				Title = string.format("{#666666}Help for %s commands.{/}", addonName)
			  , Description = string.format("{#3388AA}To change settings of '%s', please call the following command.{/}", addonName)
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
				Title = string.format("{#666666}%s의 패러미터 설명{/}", addonName)
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
			ParamDummyText = ParamDummyText .. "{#EEEEEE}";
			ParamDummyText = ParamDummyText .. string.format("'%s %s'", SlashCommandList[1], self:GetResText(self.CommonResText, Me.Settings.Lang, "Help.ParamDummy"));
			if SlashCommandList[2] ~= nil then
				ParamDummyText = ParamDummyText .. string.format(" %s '%s %s'", self:GetResText(self.CommonResText, Me.Settings.Lang, "Help.OrText"), SlashCommandList[2], self:GetResText(self.CommonResText, Me.Settings.Lang, "Help.ParamDummy"));
			end
			ParamDummyText = ParamDummyText .. "{/}{nl}{s6} {nl}{/}";
		end
		local CommandHelpText = "";
		if CommandParamList ~= nil and self:GetTableLen(CommandParamList) > 0 then
			CommandHelpText = CommandHelpText .. string.format("{#666666}%s: ", self:GetResText(self.CommonResText, Me.Settings.Lang, "Help.EnableTitle"));
			for ParamName, DescriptionKey in pairs(CommandParamList) do
				local SubParam = DescriptionKey.SubParam or "";
				local SpaceCount = 15 - string.len(ParamName) - string.len(SubParam);
				local SpaceText = " ";
				if SpaceCount > 0 then
					SpaceText = string.rep(" ", SpaceCount);
				end
				if string.len(SubParam) > 0 then
					SpaceText = string.format(" {#BB9933}%s{/} ", SubParam) .. SpaceText;
				end
				CommandHelpText = CommandHelpText .. string.format("{nl}{#CCCCCC}%s{/} {#AAAA66}%s{/}%s:%s", SlashCommandList[1], ParamName, SpaceText, self:GetResText(DescriptionKey, Me.Settings.Lang));
			end
			CommandHelpText = CommandHelpText .. "{/}{nl} ";
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
Me.HandleList = {};


-- 設定書き込み
local function SaveSetting()
	Toukibi:SaveTable(Me.SettingFilePathName, Me.Settings);
end

-- デフォルト設定(ForceがTrueでない場合は、既存の値はそのまま引き継ぐ)
local function MargeDefaultSetting(Force, DoSave)
	DoSave = Toukibi:GetValueOrDefault(DoSave, true);
	Me.Settings = Me.Settings or {};
	Me.Settings.Enabled		 = Toukibi:GetValueOrDefault(Me.Settings.Enabled		, true, Force);
	Me.Settings.Lang		 = Toukibi:GetValueOrDefault(Me.Settings.Lang			, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.UsePartyChat = Toukibi:GetValueOrDefault(Me.Settings.UsePartyChat	, false, Force);

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

local function HasBuff(type, handle, checkFn)
	-- 特定のバフをもっているかをチェックする
	if handle == nil then
		return false;
	end
	
	local buffCount = info.GetBuffCount(handle);
	
	for i = 0, buffCount - 1 do
		local buff = info.GetBuffIndexed(handle, i);
		--local cls = GetClassByType('Buff', buff.buffID);
	
		if buff.buffID == type then
			if checkFn ~= nil then
				return checkFn(buff);
			end
			return true;
		end
	end
	
	return false;
end

local function CheckMob(handle)
	local actor = world.GetActor(handle);
	if actor == nil then
		Me.HandleList[tostring(handle)] = nil;
		-- log("erase " .. handle)
		return false;
	end

	local monCls = GetClassByType("Monster", actor:GetType());

	local bolTemp = false;
	for _, buff in ipairs(DetectBuffList) do
		if HasBuff(buff.ID, handle, buff.checkFn) == true then
			bolTemp = true;
			if Me.Settings.UsePartyChat then
				local message = Toukibi:GetResText(ResText, Me.Settings.Lang, "General.NoticeMsgFormat");
				local colorName = Toukibi:GetResText(ResText, Me.Settings.Lang, "BuffType." .. buff.Type);
				ui.Chat(string.format("/p " .. message, colorName, monCls.Name));
			end
	
			imcSound.PlaySoundEvent("sys_levelup");
	
			local popup = ui.CreateNewFrame("hair_gacha_popup", "test" .. handle, 0);
			popup:ShowWindow(1);
			popup:EnableHitTest(0);
			local bonusimg = GET_CHILD_RECURSIVELY(popup, "bonusimg");
			bonusimg:ShowWindow(0);
			local itembgimg = GET_CHILD_RECURSIVELY(popup, "itembgimg");
			local itemimg = GET_CHILD_RECURSIVELY(popup, "itemimg");
			itemimg:SetImage(buff.Icon);
			itembgimg:SetImage(buff.BG);
			itemimg:SetColorTone("CCFFFFFF");
			itembgimg:SetColorTone("CCFFFFFF");
			FRAME_AUTO_POS_TO_OBJ(popup, handle, - popup:GetWidth() / 2, -150, 3, 1);
			break;
		end
	end
	return bolTemp;
end

function Me.AddMobList()
	for _, value in pairs(Me.HandleList) do
		value.LiveChecked = false;
	end
	if not Me.Settings.Enabled then return end
	--近くにいる敵をリストに入れる
	local FoundList, FoundCount = SelectObject(GetMyPCObject(), 200, "ENEMY")
	for i = 1, FoundCount do
		local FoundItem = FoundList[i];
		local handle = GetHandle(FoundItem);
		if Me.HandleList[tostring(handle)] == nil then
			-- 新規登録
			Me.HandleList[tostring(handle)] = {
				TryTimes = 0;
				LiveChecked = true;
				BuffChecked = false;
			};
			-- log("add " .. handle)
		else
			-- 生存確認
			Me.HandleList[tostring(handle)].LiveChecked = true;
		end
		if not Me.HandleList[tostring(handle)].BuffChecked then
			-- バフ判定を行う
			local bolTemp = CheckMob(handle);
			Me.HandleList[tostring(handle)].TryTimes = Me.HandleList[tostring(handle)].TryTimes + 1;
			-- log(Me.HandleList[tostring(handle)].TryTimes .. " times")
			if bolTemp or Me.HandleList[tostring(handle)].TryTimes >= 3 then
				Me.HandleList[tostring(handle)].BuffChecked = true;
			end
		end
	end
end

function Me.RemoveMobList()
	local LostList = {};
	for handle, value in pairs(Me.HandleList) do
		if not value.LiveChecked then
			table.insert(LostList, handle)
			-- log("lost " .. handle)
		end
	end
	for _, handle in ipairs(LostList) do
		Me.HandleList[tostring(handle)] = nil;
		local FrameName = "test" .. handle;
		local objFrame = ui.GetFrame(FrameName);
		if objFrame ~= nil then
			objFrame = nil;
			ui.DestroyFrame(FrameName);
			-- log("destroy frame " .. handle)
		end
		-- log("erase " .. handle)
	end
end

function Me.UpdateData()
	Me.AddMobList();
	Me.RemoveMobList();
end

function TOUKIBI_CLOVERFINDER_UPDATE()
	Me.UpdateData();
end

function Me.ToggleValue(propName, value)
	ui.CloseAllContextMenu();
	if Me.Settings == nil then return end
	Me.Settings[propName] = (value == 1);
	SaveSetting();
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取
function TOUKIBI_CLOVERFINDER_PROCESS_COMMAND(command)
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
		
		
		-- return;
	elseif cmd == "on" then
		Me.ToggleValue("Enabled", 1);
		Toukibi:AddLog(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "General.EnableMe"), addonName), "Notice", true, false);
		return;
	elseif cmd == "off" then
		Me.ToggleValue("Enabled", 0);
		Toukibi:AddLog(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "General.DisableMe"), addonName), "Warning", true, false);
		return;
	elseif cmd == "party" and #command > 0 then
		local arg = string.lower(table.remove(command, 1));
		if arg == "on" then
			Me.ToggleValue("UsePartyChat", 1);
			Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "General.EnableNotify"), "Notice", true, false);
			return;
		elseif arg == "off" then
			Me.ToggleValue("UsePartyChat", 0);
			Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "General.DisableNotify"), "Warning", true, false);
			return;
		end
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
function CLOVERFINDER_ON_INIT(addon, frame)
	-- 設定を読み込む
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end

	-- イベントを登録する
	addon:RegisterMsg("FPS_UPDATE", "TOUKIBI_CLOVERFINDER_UPDATE");
	
	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_CLOVERFINDER_PROCESS_COMMAND);
	end
end

