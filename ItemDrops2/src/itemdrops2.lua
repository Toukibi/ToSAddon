local addonName = "ItemDrops2";
local verText = "2.01";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/drops2"} -- {"/コマンド1", "/コマンド2", .......};
local CommandParamList = {
	reset = {jp = "設定リセット", en = "Reset the all settings."}
  , jp = {jp = "日本語モードに切り替え", en = "Switch to Japanese mode.(日本語へ)"}
  , en = {jp = "英語モードに切り替え(Switch to English mode.)", en = "Switch to English mode."}
};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
-- IDrops = Me;
local DebugMode = false;

-- テキストリソース
local ResText = {
	jp = {
		General = {
			NoticeMsgFormat = "%sの%sを発見！"
		  , YourName = "あなた"
		  , SomeonesName = "誰か"
		  , DropMsgFormat = "%sに%sがドロップしました"
		},
		Option = {
			Title = "ItemDropsの設定"
		  , Save = "保存"
		  , Close = "閉じる"
		  , LangTitle = "Language (言語)"
		  , Japanese = "Japanese (日本語)"
		  , English = "English"
		  , DisplayTitle = "表示設定"
		  , effectFilter_title = "ハイライト表示をするアイテムランク"
		  , msgFilter_title = "チャットログに表示するアイテムランク"
		  , nameTagFilter_title = "アイテム名を表示をするアイテムランク"
		  , showAlways_title = "次のものもハイライト表示する"
		  , XPCards = "経験値カード"
		  , MonGems = "モンスタージェム"
		  , Cubes = "キューブ"
		  , SomeoneDrops = "誰かが拾い忘れたアイテム"
		  , ptMemberDrop_title = "PTメンバーのドロップ品の処理"
		  , doHighlight = "ハイライト表示する"
		  , doNoticeMsg = "チャットログに表示する"
		  , hideSilverNameTag = "シルバーのアイテム名を表示しない"
		},
		RankType = {
			Normal = "一般"
		  , Magic = "マジック"
		  , Rare = "レア"
		  , Unique = "ユニーク"
		  , Legend = "伝説"
		  , Set = "セット品"
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
		  , YourName = "You"
		  , SomeonesName = "Someone"
		  , DropMsgFormat = "%s drops %s."
		},
		Option = {
			Title = "Settings  -ItemDrops-"
		  , Save = "Save"
		  , Close = "Close"
		  , LangTitle = "Language"
		  , Japanese = "Japanese"
		  , English = "English"
		  , DisplayTitle = "Display setting"
		  , effectFilter_title = "Item rank to highlight display."
		  , msgFilter_title = "Item rank to display in chat log."
		  , nameTagFilter_title = "Item rank to display name tag"
		  , showAlways_title = "Also highlight the following things."
		  , XPCards = "XP Cards"
		  , MonGems = "Mon Gems"
		  , Cubes = "Cubes"
		  , SomeoneDrops = "Someone's drops"
		  , ptMemberDrop_title = "When the PT members drop somethings."
		  , doHighlight = "Do highlight."
		  , doNoticeMsg = "Display in chat log."
		  , hideSilverNameTag = "Hide item name tag of silver."
		},
		RankType = {
			Normal = "Normal"
		  , Magic = "Magic"
		  , Rare = "Rare"
		  , Unique = "Unique"
		  , Legend = "Legendary"
		  , Set = "Set items"
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
				Title = string.format("{#666666}%sのパラメータ説明{/}", addonName)
			  , Description = string.format("{#92D2A0}%sは次のパラメータで設定を呼び出してください。{/}", addonName)
			  , ParamDummy = "[パラメータ]"
			  , OrText = "または"
			  , EnableTitle = "使用可能なコマンド"
			}
		},
		en = {
			System = {
				InitMsg = "[Add-ons]" .. addonName .. " ver." .. verText .. " loaded!"
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
	Me.Settings.Enabled				 = Toukibi:GetValueOrDefault(Me.Settings.Enabled			, true, Force);
	Me.Settings.Lang				 = Toukibi:GetValueOrDefault(Me.Settings.Lang				, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.msgFilterGrade		 = Toukibi:GetValueOrDefault(Me.Settings.msgFilterGrade		, 2, Force);
	Me.Settings.effectFilterGrade	 = Toukibi:GetValueOrDefault(Me.Settings.effectFilterGrade	, 1, Force);
	Me.Settings.nameTagFilterGrade	 = Toukibi:GetValueOrDefault(Me.Settings.nameTagFilterGrade, 1, Force);
	Me.Settings.alwaysShowXPCards	 = Toukibi:GetValueOrDefault(Me.Settings.alwaysShowXPCards	, true, Force);
	Me.Settings.alwaysShowMonGems	 = Toukibi:GetValueOrDefault(Me.Settings.alwaysShowMonGems	, true, Force);
	Me.Settings.alwaysShowCubes		 = Toukibi:GetValueOrDefault(Me.Settings.alwaysShowCubes	, true, Force);
	Me.Settings.showSilverNameTag	 = Toukibi:GetValueOrDefault(Me.Settings.showSilverNameTag	, false, Force);
	Me.Settings.showSomeoneDrops	 = Toukibi:GetValueOrDefault(Me.Settings.showSomeoneDrops	, false, Force);
	Me.Settings.showPartyDrops		 = Toukibi:GetValueOrDefault(Me.Settings.showPartyDrops		, false, Force);
	Me.Settings.showPartyDropsNotice = Toukibi:GetValueOrDefault(Me.Settings.showPartyDropsNotice, false, Force);

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

local function GetItemGrade(itemObj)
	local grade = itemObj.ItemGrade;

	if (itemObj.ItemType == "Recipe") then
		local recipeGrade = tonumber(itemObj.Icon:match("misc(%d)")) - 1;
		if (recipeGrade <= 0) then recipeGrade = 1 end;
		return recipeGrade;
	end
	if (grade == 0 and itemObj.GroupName ~= "Premium") then
		return nil
	end
	return grade;
end

local function GetItemRarityColor(itemObj)
	local itemProp = geItemTable.GetProp(itemObj.ClassID);
	local grade = GetItemGrade(itemObj);

	if (itemProp.setInfo ~= nil) then return "00FF00"; -- set piece
	elseif (grade == 0 or itemObj.GroupName == "Premium") then return "FFBF33"; -- premium
	elseif (grade == 1) then return "FFFFFF"; -- common
	elseif (grade == 2) then return "108CFF"; -- rare
	elseif (grade == 3) then return "9F30FF"; -- epic
	elseif (grade == 4) then return "FF4F00"; -- orange
	elseif (grade == 5) then return "FFFF53"; -- legendary
	else return "E1E1E1"; -- no grade (non-equipment items)
	end
end

--F_light080_blue_loop
--F_cleric_MagnusExorcismus_shot_burstup
--F_magic_prison_line

local function GetItemRarityEffect(itemObj)
	local itemProp = geItemTable.GetProp(itemObj.ClassID);
	local grade = GetItemGrade(itemObj);


	if (itemProp.setInfo ~= nil) then
		-- セット品
		return {
			Name = "F_magic_prison_line_green";
			scale = 6;
		};
	elseif (grade == 0 or itemObj.GroupName == "Premium") then
		-- プレミアム
		return {
			Name = "F_magic_prison_line_white";
			scale = 6;
		};
	elseif (grade == 1) then
		-- 普通
		return {
			Name = "F_magic_prison_line_white";
			scale = 6;
		};
	elseif (grade == 2) then
		-- 青
		return {
			Name = "F_magic_prison_line_blue";
			scale = 6;
		};
	elseif (grade == 3) then
		-- 紫
		return {
			Name = "F_magic_prison_line_dark";
			scale = 6;
		};
	elseif (grade == 4) then
		-- オレンジ
		return {
			Name = "F_magic_prison_line_red";
			scale = 6;
		};
	elseif (grade == 5) then
		-- 黄色
		return {
			Name = "F_magic_prison_line_orange";
			scale = 6;
		};
	else
		-- その他(一般アイテムなど)
		return {
			Name = "F_magic_prison_line_white";
			scale = 6;
		};
	end
end

local function CreateHighlightFrame(handle, itemData)
	-- いない場合は処理を中止して、ハンドル一覧から抹消する
	local actor = world.GetActor(handle);
	if actor == nil then
		Me.HandleList[tostring(handle)] = nil;
		-- log("erase " .. handle)
		return false;
	end

	if itemData.doHighlight then
		bolTemp = true;

		local itemFrame = ui.CreateNewFrame("itembaseinfo", "itemdrops_" .. handle, 0);
		itemFrame:EnableHitTest(0);

		local nameRichText = GET_CHILD(itemFrame, "name", "ui::CRichText");
		local tagText = " "
		if itemData.showNameTag then
			tagText = Toukibi:GetStyledText(itemData.itemName, {"#" .. itemData.itemColor})
			if (Me.Settings.showPartyDrops and itemData.ownerMode == 2) or (Me.Settings.showSomeoneDrops and itemData.ownerMode == -1) then
				tagText = tagText .. "{nl}{s4} {/}{nl}" .. Toukibi:GetStyledText(string.format("(%s)", itemData.dropOwner), {"#88FFFF", "s14", "ol"})
			end
		end
		nameRichText:SetText(tagText);

		itemFrame:SetUserValue("_AT_OFFSET_HANDLE", handle);
		itemFrame:SetUserValue("_AT_OFFSET_X", -itemFrame:GetWidth() / 2);
		itemFrame:SetUserValue("_AT_OFFSET_Y", 3);
		itemFrame:SetUserValue("_AT_OFFSET_TYPE", 1);
		itemFrame:SetUserValue("_AT_AUTODESTROY", 1);
	
		-- makes frame blurry, see FRAME_AUTO_POS_TO_OBJ function
		--AUTO_CAST(itemFrame);
		--itemFrame:SetFloatPosFrame(true);
	
		_FRAME_AUTOPOS(itemFrame);
		itemFrame:RunUpdateScript("_FRAME_AUTOPOS");
	
		itemFrame:ShowWindow(1);

		--pcall(effect.AddActorEffectByOffset(world.GetActor(handle) or 0, itemData.Effect.Name, itemData.Effect.scale, 0))
		ReserveScript(string.format('pcall(effect.AddActorEffectByOffset(world.GetActor(%d) or 0, "%s", %d, 0))', handle, itemData.Effect.Name, itemData.Effect.scale), 0.7);

		--itemimg:SetColorTone("CCFFFFFF");
		--itembgimg:SetColorTone("CCFFFFFF");
		--FRAME_AUTO_POS_TO_OBJ(popup, handle, - popup:GetWidth() / 2, -150, 3, 1);
	elseif itemData.doHighlight == false then
		bolTemp = true
	end
	return bolTemp;
end

local function GetItemLinkText(itemObj)
	if itemObj == nil then return "" end
	local imgHeight = 30;
	local itemImage =  "";
	local imageName = GET_ITEM_ICON_IMAGE(itemObj);
	local itemImage = string.format("{img %s %d %d}", imageName, imgHeight, imgHeight);
	local properties = "";
	local itemName = GET_FULL_NAME(itemObj);

	if tostring(itemObj.RefreshScp) ~= "None" then
		_G[itemObj.RefreshScp](itemObj);
	end

	if itemObj.ClassName == 'Scroll_SkillItem' then		
		local sklCls = GetClassByType("Skill", itemObj.SkillType)
		itemName = itemName .. "(" .. sklCls.Name ..")";
		properties = GetSkillItemProperiesString(itemObj);
	else
		properties = GetModifiedPropertiesString(itemObj);
	end

	if properties == "" then
		properties = 'nullval'
	end

	return string.format("{a SLI %s %d}{#0000FF}%s%s{/}{/}{/}", properties, itemObj.ClassID, itemImage, itemName);
end

function Me.AddObjList()
	for _, value in pairs(Me.HandleList) do
		value.LiveChecked = false;
	end
	if not Me.Settings.Enabled then return end
	--近くにいる物すべてをリストに入れる
	local FoundList, FoundCount = SelectObject(GetMyPCObject(), 400, "ALL")
	for i = 1, FoundCount do
		local FoundItem = FoundList[i];
		local handle = GetHandle(FoundItem);
		local actor = world.GetActor(handle);
		if actor:GetObjType() == GT_ITEM then
			-- アイテムのみに絞る
			if Me.HandleList[tostring(handle)] == nil then
				-- 新規登録
				local ownersName = Toukibi:GetResText(ResText, Me.Settings.Lang, "General.SomeonesName");
				local dropOwnerMode = -1;
				local ownersAID = actor:GetUniqueName();
				local isPartysDrop = false;
				local doHighlightByOwner = false;
				local doHighlightByItem = false;
				local showMessage = false;
				local showItemNameTag = false;
				local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, ownersAID)
				if nil ~= memberInfo then
					-- PTメンバーのドロップ
					isPartysDrop = true;
					ownersName = memberInfo:GetName();
					dropOwnerMode = 2;
					if Me.Settings.showPartyDrops then
						doHighlightByOwner = true;
					end
					if Me.Settings.showPartyDropsNotice then
						showMessage = true;
					end
				end

				if ownersAID == session.loginInfo.GetAID() then
					-- 自身のドロップ
					ownersName = Toukibi:GetResText(ResText, Me.Settings.Lang, "General.YourName");
					dropOwnerMode = 1;
					doHighlightByOwner = true;
					showMessage = true
				end

				if dropOwnerMode < 0 and Me.Settings.showSomeoneDrops then
					-- 第三者のドロップでも設定がONならハイライトする
					doHighlightByOwner = true;
				end

				local itemObj = GetClass("Item", FoundItem.ClassName);
				if string.find(string.lower(FoundItem.ClassName),"moneybag") then 
					-- シルバーの場合
					itemObj = GetClass("Item", "Vis");
				end

				if itemObj ~= nil then
					local itemIcon = tostring(itemObj.Icon);
					local gradeNo = tonumber(GetItemGrade(itemObj));
					if gradeNo == nil then gradeNo = 1 end -- グレードなし(None)は1にしておく

					-- アイテムごとのハイライトをセットする
					if itemIcon:match("gem_mon") and Me.Settings.alwaysShowMonGems == true then
						doHighlightByItem = true;
					elseif itemIcon:match("item_expcard") and Me.Settings.alwaysShowXPCards == true then
						doHighlightByItem = true;
					elseif itemIcon:match("item_cube") and Me.Settings.alwaysShowCubes == true then
						doHighlightByItem = true;
					else
						-- その他のアイテムの場合はグレードに従ってハイライトの有無を決める
						if tonumber(Me.Settings.effectFilterGrade) == nil then
							doHighlightByItem = true;
						else
							doHighlightByItem = (Me.Settings.effectFilterGrade <= gradeNo)
						end
					end
					if itemObj.ClassName == "Vis" then
						showMessage = false; -- お金は毎回表示すると鬱陶しいのでログに出さないようにしておく
						if Me.Settings.showSilverNameTag then
							showItemNameTag = (Me.Settings.nameTagFilterGrade <= gradeNo);
						end
					else
						if tonumber(Me.Settings.nameTagFilterGrade) == nil then
							showItemNameTag = true;
						else
							showItemNameTag = (Me.Settings.nameTagFilterGrade <= gradeNo)
						end
					end
					Me.HandleList[tostring(handle)] = {
						TryTimes = 0;
						LiveChecked = true;
						HighlightChecked = false;
						groupName = itemObj.GroupName;
						itemName = dictionary.ReplaceDicIDInCompStr(itemObj.Name);
						dropOwner = ownersName;
						ownerMode = dropOwnerMode;
						itemGrade = gradeNo;
						itemColor = GetItemRarityColor(itemObj);
						itemType = itemObj.ItemType;
						doHighlight = doHighlightByOwner and doHighlightByItem;
						Effect = GetItemRarityEffect(itemObj);
						showNameTag = showItemNameTag;
					};
					-- log("add " .. handle)

					-- ドロップログを作る
					if tonumber(Me.Settings.msgFilterGrade) == nil then
						showMessage = showMessage and true;
					else
						showMessage = showMessage and (Me.Settings.msgFilterGrade <= gradeNo)
					end
					if showMessage then
						CHAT_SYSTEM(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "General.DropMsgFormat")
													, ownersName
													, GetItemLinkText(itemObj)
													)
									)
					end

				end
			else
				-- 生存確認
				Me.HandleList[tostring(handle)].LiveChecked = true;
			end
			if not Me.HandleList[tostring(handle)].HighlightChecked then
				-- ハイライトを行う
				local bolTemp = CreateHighlightFrame(handle, Me.HandleList[tostring(handle)]);
				Me.HandleList[tostring(handle)].TryTimes = Me.HandleList[tostring(handle)].TryTimes + 1;
				-- log(Me.HandleList[tostring(handle)].TryTimes .. " times")
				if bolTemp or Me.HandleList[tostring(handle)].TryTimes >= 3 then
					-- 成功するか3回失敗するかのいずれかで処理終了にする
					Me.HandleList[tostring(handle)].HighlightChecked = true;
				end
			end
		end
	end
end

function Me.RemoveObjList()
	local LostList = {};
	for handle, value in pairs(Me.HandleList) do
		if not value.LiveChecked then
			table.insert(LostList, handle)
			-- log("lost " .. handle)
		end
	end
	for _, handle in ipairs(LostList) do
		Me.HandleList[tostring(handle)] = nil;
		local FrameName = "itemdrops_" .. handle;
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
	Me.AddObjList();
	Me.RemoveObjList();
end

function TOUKIBI_ITEMDROPS2_UPDATE()
	Me.UpdateData();
end

function Me.ToggleValue(propName, value)
	ui.CloseAllContextMenu();
	if Me.Settings == nil then return end
	Me.Settings[propName] = (value == 1);
	SaveSetting();
end

-- ===========================
--         設定画面関連
-- ===========================

local ToukibiUI = {
	-- マージンを指定する
	SetMargin = function(self, pTarget, pLeft, pTop, pRight, pBottom)
		if pTarget ~= nil then
			local BeforeMargin = pTarget:GetMargin();
			pLeft = pLeft or BeforeMargin.left;
			pTop = pTop or BeforeMargin.top;
			pRight = pRight or BeforeMargin.right;
			pBottom = pBottom or BeforeMargin.bottom;
			pTarget:SetMargin(pLeft, pTop, pRight, pBottom);
		end
	end,

	-- テキストコントロールを追加
	AddRichText = function(self, BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize)
		local txtItem = tolua.cast(BaseFrame:CreateOrGetControl('richtext', NewLabelName, NewLeft, NewTop, NewWidth, NewHeight), "ui::CRichText"); 
		txtItem:SetTextAlign("left", "top"); 
		txtItem:SetText("{@st66}" .. NewText); 
		txtItem:SetGravity(ui.LEFT, ui.TOP);
		txtItem:ShowWindow(1);
		return txtItem;
	end,

	-- テキストコントロールを指定した領域の中心になるように追加
	AddRichTextToCenter = function(self, BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize)
		local objTextItem = self:AddRichText(BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize); 
		self:SetMargin(objTextItem, NewLeft + math.floor((NewWidth - objTextItem:GetWidth()) / 2), NewTop + math.floor((NewHeight - objTextItem:GetHeight()) / 2), 0, 0);
		return objTextItem;
	end,

	-- コントロールのテキストを変更する
	SetText = function(self, ctrl, NewText, Styles)
		local StyledText = NewText;
		if Styles ~= nil and #Styles > 0 then
			-- スタイル指定あり
			StyledText = Toukibi:GetStyledText(NewText, Styles);
		end
		if ctrl ~= nil then
			ctrl:SetText(StyledText);
		end
	end,

	-- コントロールのプロパティーに入っているテキストを入れ替える
	SetTextByKey = function(self, ctrl, propName, NewText, Styles)
		local StyledText = NewText;
		if Styles ~= nil and #Styles > 0 then -- スタイル指定あり
			StyledText = Toukibi:GetStyledText(NewText, Styles);
		end
		if ctrl ~= nil then
			ctrl:SetTextByKey(propName, StyledText);
		end
	end,

	-- ***** ボタン関連 *****
	AddButton = function(self, BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize)
		local objButton = tolua.cast(BaseFrame:CreateOrGetControl('button', NewLabelName, NewLeft, NewTop, NewWidth, NewHeight), "ui::CButton"); 
		objButton:SetText("{@st66}" .. NewText .. "{/}"); 
		objButton:SetGravity(ui.LEFT, ui.TOP);
		objButton:SetClickSound("button_click_big");
		objButton:SetOverSound("button_over");
		objButton:SetSkinName("test_normal_button");
		return objButton;
	end,

	-- チェックボックスの状態を設定する
	SetCheckedByName = function(self, frame, ControlName, pValue)
		if frame == nil then return nil end
		local TargetCheckBox = GET_CHILD(frame, ControlName, "ui::CCheckBox");
		if TargetCheckBox ~= nil then
			return self:SetChecked(TargetCheckBox, pValue);
		else
			return nil;
		end
	end,
	SetChecked = function(self, TargetCheckBox, pValue)
		if TargetCheckBox == nil then return nil end
		local intValue = 0;
		if type(pValue) == "boolean" and pValue then
			intValue = 1;
		elseif type(pValue) == "string" and (pValue ~= "" and pValue ~= "false" and pValue ~= "0") then
			intValue = 1;
		elseif type == nil then
			intValue = false;
		elseif type(pValue) == "number" and pValue ~= 0 then
			intValue = 1;
		end
		tolua.cast(TargetCheckBox, "ui::CCheckBox");
		TargetCheckBox:SetCheck(intValue);
	end,
	-- チェックボックスの状態を取得する
	GetCheckedByName = function(self, frame, ControlName)
		if frame == nil then return nil end
		local TargetCheckBox = GET_CHILD(frame, ControlName, "ui::CCheckBox");
		if TargetCheckBox ~= nil then
			return self:GetChecked(TargetCheckBox);
		else
			return nil;
		end
	end,
	GetChecked = function(self, TargetCheckBox)
		if TargetCheckBox == nil then return nil end
		tolua.cast(TargetCheckBox, "ui::CCheckBox");
		return TargetCheckBox:IsChecked() == 1;
	end,

	-- ***** チェックボックス関連 *****
	AddCheckBox = function(self, BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize)
		local objCheck = tolua.cast(BaseFrame:CreateOrGetControl('checkbox', NewLabelName, NewLeft, NewTop, NewWidth, NewHeight), "ui::CCheckBox");
		objCheck:SetText("{@st66}" .. NewText .. "{/}"); 
		objCheck:SetGravity(ui.LEFT, ui.TOP);
		objCheck:SetClickSound("button_click_big");
		objCheck:SetOverSound("button_over");
		objCheck:ShowWindow(1);
		return objCheck;
	end,

	-- ***** スライダー関連 *****
	-- スライダーを追加する
	AddSlider = function(self, BaseFrame, CtrlName, NewLeft, NewTop, NewWidth, NewHeight)
		local objSlider = tolua.cast(BaseFrame:CreateOrGetControl('slidebar', CtrlName, NewLeft, NewTop, NewWidth, NewHeight), "ui::CSlideBar"); 
		objSlider:SetGravity(ui.LEFT, ui.TOP);
		objSlider:ShowWindow(1);
		objSlider:SetClickSound("button_click_big");
		objSlider:SetOverSound("button_over");
		return objSlider;
	end,

	-- スライダーの値を設定する
	SetSliderValue = function(self, frame, ControlName, LabelName, pValue, pValueText)
		local objSlider = GET_CHILD(frame, ControlName, "ui::CSlideBar");
		if objSlider ~= nil then
			objSlider:SetLevel(pValue);
		end
		local txtTarget = GET_CHILD(frame, LabelName, "ui::CRichText");
		if txtTarget ~= nil then
			txtTarget:SetTextByKey("opValue", pValueText);
		end
	end,

	-- スライダーの値を取得する
	GetSliderValueByName = function(self, frame, ControlName)
		if frame == nil then return nil end
		local TargetSlider = GET_CHILD(frame, ControlName, "ui::CSlideBar");
		if TargetSlider ~= nil then
			return self:GetSliderValue(TargetSlider);
		else
			return nil;
		end
	end,
	GetSliderValue = function(self, TargetSlider)
		if TargetSlider == nil then return nil end
		tolua.cast(TargetSlider, "ui::CSlideBar");
		return TargetSlider:GetLevel();
	end,

	-- ***** ラジオボタン関連 *****
	-- 選択されているラジオボタンの名前を取得する
	GetSelectedRadioValue = function(self, SeedRadio, DefaultValue)
		if SeedRadio == nil then return nil end
		local radioBtn = tolua.cast(SeedRadio, "ui::CRadioButton");
		radioBtn = radioBtn:GetSelectedButton();
		if radioBtn ~= nil then
			return string.match(radioBtn:GetName(),".-_(.+)");
		else
			return DefaultValue;
		end
	end,

	-- ***** テキストボックス関連 *****
	-- テキストボックスを追加
	AddTextBox = function(self, BaseFrame, NewObjName, pText, NewLeft, NewTop, NewWidth, NewHeight)
		local objTextBox = tolua.cast(BaseFrame:CreateOrGetControl("edit", NewObjName, NewLeft, NewTop, NewWidth, NewHeight), "ui::CEditControl");
		objTextBox:SetGravity(ui.LEFT, ui.TOP);
		objTextBox:EnableHitTest(1);
		objTextBox:SetSkinName("test_weight_skin");
		objTextBox:SetClickSound("button_click_big");
		objTextBox:SetOverSound("button_over");
		objTextBox:SetFontName("white_18_ol");
		objTextBox:SetOffsetXForDraw(0);
		objTextBox:SetOffsetYForDraw(-1);
		objTextBox:SetTextAlign("center", "center");
		objTextBox:SetText(pText);
		return objTextBox;
	end,

	GetNumValue = function(self, objTarget)
		if objTarget == nil then return nil end
		return GetNumberFromCommaText(objTarget:GetText());
	end


};
Me.UI = ToukibiUI;

-- 設定データを設定画面に反映
function Me.InitSettingValue(BaseFrame)
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");

	local CurrentRadio = GET_CHILD(BodyGBox, "lang_en", "ui::CRadioButton");
	if Me.Settings.Lang == "jp" then
		CurrentRadio = GET_CHILD(BodyGBox, "lang_jp", "ui::CRadioButton");
	end
	CurrentRadio:Select()

	CurrentRadio = GET_CHILD(BodyGBox, "effectFilter_" .. Me.Settings.effectFilterGrade, "ui::CRadioButton");
	if CurrentRadio ~= nil then
		CurrentRadio:Select();
	end
	CurrentRadio = GET_CHILD(BodyGBox, "msgFilter_" .. Me.Settings.msgFilterGrade, "ui::CRadioButton");
	if CurrentRadio ~= nil then
		CurrentRadio:Select();
	end
	CurrentRadio = GET_CHILD(BodyGBox, "nameTagFilter_" .. Me.Settings.nameTagFilterGrade, "ui::CRadioButton");
	if CurrentRadio ~= nil then
		CurrentRadio:Select();
	end

	ToukibiUI:SetCheckedByName(BodyGBox, "alwaysShowXPCards"	, Me.Settings.alwaysShowXPCards);
	ToukibiUI:SetCheckedByName(BodyGBox, "alwaysShowMonGems"	, Me.Settings.alwaysShowMonGems);
	ToukibiUI:SetCheckedByName(BodyGBox, "alwaysShowCubes"		, Me.Settings.alwaysShowCubes);
	ToukibiUI:SetCheckedByName(BodyGBox, "showSomeoneDrops"		, Me.Settings.showSomeoneDrops);

	ToukibiUI:SetCheckedByName(BodyGBox, "showPartyDrops"		, Me.Settings.showPartyDrops);
	ToukibiUI:SetCheckedByName(BodyGBox, "showPartyDropsNotice"	, Me.Settings.showPartyDropsNotice);
	ToukibiUI:SetCheckedByName(BodyGBox, "showSilverNameTag"	, not Me.Settings.showSilverNameTag);
end

-- 設定画面を設定データに反映
function Me.ExecSetting()
	local BaseFrame = ui.GetFrame(addonNameLower);
	if BaseFrame == nil then
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "SettingFrame.CannotGetSettingFrameHandle"), "Warning", true, false);
		return;
	end
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");
	if BodyGBox == nil then return end

	Me.Settings.Lang = ToukibiUI:GetSelectedRadioValue(BodyGBox:GetChild("lang_jp"));

	Me.Settings.effectFilterGrade = tonumber(ToukibiUI:GetSelectedRadioValue(BodyGBox:GetChild("effectFilter_1"), 1));
	Me.Settings.msgFilterGrade = tonumber(ToukibiUI:GetSelectedRadioValue(BodyGBox:GetChild("msgFilter_1"), 2));
	Me.Settings.nameTagFilterGrade = tonumber(ToukibiUI:GetSelectedRadioValue(BodyGBox:GetChild("nameTagFilter_1"), 1));

	Me.Settings.alwaysShowXPCards	 = ToukibiUI:GetCheckedByName(BodyGBox, "alwaysShowXPCards");
	Me.Settings.alwaysShowMonGems	 = ToukibiUI:GetCheckedByName(BodyGBox, "alwaysShowMonGems");
	Me.Settings.alwaysShowCubes		 = ToukibiUI:GetCheckedByName(BodyGBox, "alwaysShowCubes");
	Me.Settings.showSomeoneDrops	 = ToukibiUI:GetCheckedByName(BodyGBox, "showSomeoneDrops");
	Me.Settings.showPartyDrops		 = ToukibiUI:GetCheckedByName(BodyGBox, "showPartyDrops");
	Me.Settings.showPartyDropsNotice = ToukibiUI:GetCheckedByName(BodyGBox, "showPartyDropsNotice");
	Me.Settings.showSilverNameTag	 = not ToukibiUI:GetCheckedByName(BodyGBox, "showSilverNameTag");

	SaveSetting();
	Me.CloseSettingFrame();
end

local function ChangeRankOptionText(Parent, BaseControlName, LangMode)
	LangMode = LangMode or Me.Settings.Lang or "jp";

	ToukibiUI:SetText(GET_CHILD(Parent, BaseControlName .. "_1", "ui::CRadioButton"), 
					  Toukibi:GetResText(ResText, LangMode, "RankType.Normal"), {"@st66b"});
	ToukibiUI:SetText(GET_CHILD(Parent, BaseControlName .. "_2", "ui::CRadioButton"), 
					  Toukibi:GetResText(ResText, LangMode, "RankType.Magic"), {"#006ACD", "s16", "b"});
	ToukibiUI:SetText(GET_CHILD(Parent, BaseControlName .. "_3", "ui::CRadioButton"), 
					  Toukibi:GetResText(ResText, LangMode, "RankType.Rare"), {"#6E00CE", "s16", "b"});
	ToukibiUI:SetText(GET_CHILD(Parent, BaseControlName .. "_4", "ui::CRadioButton"), 
					  Toukibi:GetResText(ResText, LangMode, "RankType.Unique"), {"#B53800", "s16", "b"});
end

-- 設定画面のテキストを再設定する
function Me.InitSettingText(BaseFrame, LangMode)
	LangMode = LangMode or Me.Settings.Lang or "jp";

	ToukibiUI:SetText(GET_CHILD(BaseFrame, "title", "ui::CRichText"), 
					  Toukibi:GetResText(ResText, LangMode, "Option.Title"), {"@st43"});

	local TargetGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");
	if TargetGBox ~= nil then
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "lang_title", "ui::CRichText"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.LangTitle"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "lang_jp", "ui::CRadioButton"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.Japanese"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "lang_en", "ui::CRadioButton"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.English"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "display_title", "ui::CRichText"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.DisplayTitle"), {"@st66b"});

		ToukibiUI:SetText(GET_CHILD(TargetGBox, "effectFilter_title", "ui::CRichText"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.effectFilter_title"), {"@st66b"});
		ChangeRankOptionText(TargetGBox, "effectFilter", LangMode);

		ToukibiUI:SetText(GET_CHILD(TargetGBox, "msgFilter_title", "ui::CRichText"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.msgFilter_title"), {"@st66b"});
		ChangeRankOptionText(TargetGBox, "msgFilter", LangMode);

		ToukibiUI:SetText(GET_CHILD(TargetGBox, "nameTagFilter_title", "ui::CRichText"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.nameTagFilter_title"), {"@st66b"});
		ChangeRankOptionText(TargetGBox, "nameTagFilter", LangMode);

		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showAlways_title", "ui::CRichText"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.showAlways_title"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "alwaysShowXPCards", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.XPCards"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "alwaysShowMonGems", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.MonGems"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "alwaysShowCubes", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.Cubes"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showSomeoneDrops", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.SomeoneDrops"), {"@st66b"});

		ToukibiUI:SetText(GET_CHILD(TargetGBox, "ptMemberDrop_title", "ui::CRichText"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.ptMemberDrop_title"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showPartyDrops", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.doHighlight"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showPartyDropsNotice", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.doNoticeMsg"), {"@st66b"});

		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showSilverNameTag", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "Option.hideSilverNameTag"), {"@st66b"});

		ToukibiUI:SetText(GET_CHILD(TargetGBox, "btn_excute", "ui::CButton"), 
							Toukibi:GetResText(ResText, LangMode, "Option.Save"), {"@st42"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "btn_cencel", "ui::CButton"), 
							Toukibi:GetResText(ResText, LangMode, "Option.Close"), {"@st42"});
	end
end

-- 設定画面を開く
function Me.SettingFrame_BeforeDisplay()
	local BaseFrame = ui.GetFrame(addonNameLower);
	if BaseFrame == nil then
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "SettingFrame.CannotGetSettingFrameHandle"), "Warning", true, false);
		return;
	end
	Me.InitSettingValue(BaseFrame);
	Me.InitSettingText(BaseFrame);
	Me.SettingFrameIsAvailable = true;
	BaseFrame:ShowWindow(1);
end

function Me.OpenSettingFrame()
	Me.SettingFrame_BeforeDisplay();
end

-- 設定画面を閉じる
function Me.CloseSettingFrame()
	local BaseFrame = ui.GetFrame(addonNameLower);
	if BaseFrame == nil then
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "SettingFrame.CannotGetSettingFrameHandle"), "Warning", true, false);
		return;
	end
	Me.SettingFrameIsAvailable = false;
	BaseFrame:ShowWindow(0);
end

-- 設定画面オープン
function TOUKIBI_ITEMDROPS2_OPEN_SETTING()
	Me.SettingFrame_BeforeDisplay();
end

-- 設定保存
function TOUKIBI_ITEMDROPS2_EXEC_SETTING()
	Me.ExecSetting();
end

-- 設定画面クローズ
function TOUKIBI_ITEMDROPS2_CLOSE_SETTING()
	Me.CloseSettingFrame();
end

-- 言語切替
function TOUKIBI_ITEMDROPS2_CHANGE_LANGMODE(frame, ctrl, str, num)
	local SelectedLang = ToukibiUI:GetSelectedRadioValue(ctrl);
	Me.InitSettingText(frame:GetTopParentFrame(), SelectedLang);
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取
function TOUKIBI_ITEMDROPS2_PROCESS_COMMAND(command)
	Toukibi:AddLog(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ExecuteCommands"), SlashCommandList[1] .. " " .. table.concat(command, " ")), "Info", true, true);
	local cmd = ""; 
	if #command > 0 then 
		-- パラメータが存在した場合はパラメータの1個めを抜き出してみる
		cmd = table.remove(command, 1); 
	else
		-- パラメータなしでコマンドが呼ばれた場合

		Me.OpenSettingFrame();
		return;
	end 
	if cmd == "reset" then 
		-- すべてをリセット
		MargeDefaultSetting(true, true);
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ResetSettings"), "Notice", true, false);
		return;
	elseif cmd == "update" then
		-- Updateの処理をここに書く
		Me.UpdateData()
		
		-- return;
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
function ITEMDROPS2_ON_INIT(addon, frame)
	-- 設定を読み込む
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end

	-- イベントを登録する
	addon:RegisterMsg("FPS_UPDATE", "TOUKIBI_ITEMDROPS2_UPDATE");
	
	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_ITEMDROPS2_PROCESS_COMMAND);
	end
end

