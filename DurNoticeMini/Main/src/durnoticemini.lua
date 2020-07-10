local addonName = "DurNoticeMini";
local verText = "1.24";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/durmini", "/DurMini", "/Durmini", "/durMini"};
local CommandParamList = {
	reset = {jp = "設定をリセット", en = "Reset the settings.", kr = "설정을 초기화"}
  , resetpos = {jp = "位置をリセット", en = "Reset the position.", kr = "위치를 초기화"}
  , rspos = {jp = "位置をリセット", en = "Reset the position.", kr = "위치를 초기화"}
  , refresh = {jp = "表示と位置を更新", en = "Update the position and values.", kr = "표시와 설정을 갱신한다"}
  , update = {jp = "表示を更新", en = "Reset the values.", kr = "표시와 설정을 갱신한다"}
  , jp = {jp = "日本語モードに切り替え", en = "Switch to Japanese mode.(日本語へ)", kr = "일본어 모드로 전환하십시오.(Japanese Mode)"}
  , en = {jp = "Switch to English mode.", en = "Switch to English mode.", kr = "Switch to English mode."}
  , kr = {jp = "한국어 모드로 변경(Korean Mode)", en = "Switch to Korean mode.(한국어로)", kr = "한국어 모드로 변경"}
  , joke = {jp = "？？？", en = "???", kr = "???"}
};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
Me.SettingFilePathName = string.format("../addons/%s/%s", addonNameLower, SettingFileName);
DurMini = Me;
local DebugMode = false;

-- ***** 変数の宣言と設定 *****
Me.SettingFilePathName = string.format("../addons/%s/settings.json", addonNameLower);
local eqTypes = {"RH", "LH", "SHIRT", "GLOVES", "PANTS", "BOOTS", "RING1", "RING2", "NECK", "TRINKET"};
local eqDurData = {}
Me.Loaded = false;

-- テキストリソース
local ResText = {
	jp = {
		Menu = {
			Title = "{#006666}===== DurNotice Miniの設定 ====={/}"
		  , UpdateNow = "{#FFFF88}今すぐ更新する{/}"
		  , LockPosition = "位置を固定する"
		  , ResetPosition = "位置をリセット"
		  , Close = "{#666666}閉じる{/}"
		},
		Msg = {
			UpdateFrmaePos = "耐久表示の表示位置をリセットしました"
		  , EndDragAndSave = "ドラッグ終了。現在位置を保存します。"
		  , CannotGetHandle = "耐久表示画面の取得に失敗しました"
		},
		InFrame = {
			Myself = "自"
		  , PTMember = "PT"
		},
		System = {
			InitMsg = "コマンド /durmini で表示のON/OFFが切り替えられます"
		}
	},
	en = {
		Menu = {
			Title = "{#006666}=== Settings - DurNotice Mini - ==={/}"
		  , UpdateNow = "{#FFFF88}Update now!{/}"
		  , LockPosition = "Lock position"
		  , ResetPosition = "Reset position"
		  , Close = "{#666666}Close{/}"
		},
		Msg = {
			UpdateFrmaePos = "Display position was reset."
		  , EndDragAndSave = "Dragging ends. Save the current position."
		  , CannotGetHandle = "Failed to get the display screen."
		},
		InFrame = {
			Myself = "T"
		  , PTMember = "S"
		},
		System = {
			InitMsg = 'With command "/durmini", you can toggle display ON/OFF'
		}
	},
	kr = {
		Menu = {
			Title = "{#006666}=== DurNotice Mini의 설정 ==={/}"
		  , UpdateNow = "{#FFFF88}지금 당장 갱신한다{/}"
		  , LockPosition = "위치를 저장한다"
		  , ResetPosition = "위치를 리셋"
		  , Close = "{#666666}닫는다{/}"
		},
		Msg = {
			UpdateFrmaePos = "표시위치를 리셋했습니다"
		  , EndDragAndSave = "드래그 종료. 현재 위치를 저장합니다."
		  , CannotGetHandle = "화면의 핸들을 취득하지 못했습니다"
		},
		InFrame = {
			Myself = "나"
		  , PTMember = "파티"
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
			msg = string.format("Sorry, '%s' haven't implemented '%s' mode yet.{nl}Language mode has not been changed from '%s'.", 
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

-- メソッドが存在するかを確認する
local function MethodExists(objValue, MethodName)
	local typeStr = type(objValue);
	if typeStr == "userdata" or typeStr == "table" then
		if typeStr == "userdata" then objValue = getmetatable(objValue) end
		for pName, pValue in pairs(objValue) do
			if tostring(pName) == MethodName then
				return "YES"
			end
		end
	else
		return "NOT TABLE"
	end
	return "NO"
end


local function ShowInitializeMessage()
	local CurrentLang = "en"
	if Me.Settings == nil then
		CurrentLang = Toukibi:GetDefaultLangCode() or CurrentLang;
	else
		CurrentLang = Me.Settings.Lang or CurrentLang;
	end

	CHAT_SYSTEM(string.format("{#333333}%s{/}", Toukibi:GetResText(Toukibi.CommonResText, CurrentLang, "System.InitMsg")))
	CHAT_SYSTEM(string.format("{#333366}[%s]%s{/}", addonName, Toukibi:GetResText(ResText, CurrentLang, "System.InitMsg")))
end
ShowInitializeMessage();

-- ==================================
--  設定関連
-- ==================================

-- 設定書き込み
local function SaveSetting()
	Toukibi:SaveTable(Me.SettingFilePathName, Me.Settings);
end
function Me.Save()
	SaveSetting()
end

-- デフォルト設定(ForceがTrueでない場合は、既存の値はそのまま引き継ぐ)
local function MargeDefaultSetting(Force, DoSave)
	DoSave = Toukibi:GetValueOrDefault(DoSave, true);
	Me.Settings = Me.Settings or {};

	Me.Settings.DoNothing	= Toukibi:GetValueOrDefault(Me.Settings.DoNothing	, false, Force);
	Me.Settings.Lang		= Toukibi:GetValueOrDefault(Me.Settings.Lang		, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.PosX		= Toukibi:GetValueOrDefault(Me.Settings.PosX		, nil, Force);
	Me.Settings.PosY		= Toukibi:GetValueOrDefault(Me.Settings.PosY		, nil, Force);
	Me.Settings.Movable		= Toukibi:GetValueOrDefault(Me.Settings.Movable		, false, Force);
	Me.Settings.Visible		= Toukibi:GetValueOrDefault(Me.Settings.Visible		, true, Force);
	Me.Settings.DisplayGauge= Toukibi:GetValueOrDefault(Me.Settings.DisplayGauge, true, Force);
	if Force then
		Toukibi:AddLog(Toukibi:GetResText(Toukibi.CommonResText, Me.Settings.Lang, "System.CompleteLoadDefault"), "Info", true, false);
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
		Toukibi:AddLog(string.format("%s{nl}{#331111}%s{/}", Toukibi:GetResText(Toukibi.CommonResText, CurrentLang, "System.ErrorToUseDefaults"), tostring(objError)), "Caution", true, false);
		MargeDefaultSetting(true, false);
	else
		Me.Settings = objReadValue;
		MargeDefaultSetting(false, false);
	end
	Toukibi:AddLog(Toukibi:GetResText(Toukibi.CommonResText, Me.Settings.Lang, "System.CompleteLoadSettings"), "Info", true, false);
end
function Me.Load()
	LoadSetting()
end

-- ===== 基本機能 =====
-- ***** 表示周り *****
-- 引数にTrueを設定するとピコハンと安全ヘルメットの絵に変わる。ただそれだけ
function Me.Joke(value)
	value = value or false;
	local TopFrame = ui.GetFrame("durnoticemini");
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

-- 耐久値の取得方法をチェックする
local function CheckGetMethod()
	local eqlist = session.GetEquipItemList();
	if MethodExists(eqlist, "GetEquipItemByIndex") == "YES" then
		-- Re:Build後
		Me.GetDurMethod = "GetEquipItemByIndex"
	elseif MethodExists(eqlist, "Element") == "YES" then
		-- Re:Build前
		Me.GetDurMethod = "Element"
	end
end

-- 装備の耐久値を取得する
local function GetDurData(eqTypeName)
	local eqlist = session.GetEquipItemList();
	local num = item.GetEquipSpotNum(eqTypeName);
	if num == nil then return end
	local eq = nil;
	if Me.GetDurMethod == nil then CheckGetMethod() end
	if Me.GetDurMethod == "GetEquipItemByIndex" then
		-- Re:Build後
		eq = eqlist:GetEquipItemByIndex(num);
	elseif Me.GetDurMethod == "Element" then
		-- Re:Build前
		eq = eqlist:Element(num);
	end

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
		if key == "LH" or key == "RH" or key == "TRINKET" then index = 1 end
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
			ReturnValue[i].DurText = math.floor(ReturnValue[i].Dur / 100);
		end
	end
	return ReturnValue;
end

-- メインフレームの描写更新
local function UpdateMainFrame()
	local MinDur = GetMinimumDur();

	local TopFrame = ui.GetFrame("durnoticemini");
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

-- コンテキストメニューを作成する
function TOUKIBI_DURMINI_CONTEXT_MENU(frame, ctrl)
	local context = ui.CreateContextMenu("DURMINI_MAIN_RBTN"
										, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Title")
										, 0, 0, 180, 0);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.UpdateNow"), "TOUKIBI_DURMINI_UPDATE()");
	Toukibi:MakeCMenuSeparator(context, 240);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.LockPosition"), "TOUKIBI_DURMINI_CHANGE_MOVABLE()", nil, not Me.Settings.Movable);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ResetPosition"), "TOUKIBI_DURMINI_RESETPOS()");
	Toukibi:MakeCMenuSeparator(context, 240.1);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Close"));
	context:Resize(270, context:GetHeight());
	ui.OpenContextMenu(context);
	return context;
end

-- ***** コンテキストメニュー選択イベント受取 *****

function TOUKIBI_DURMINI_CHANGE_MOVABLE()
	if Me.Settings == nil then return end
	Me.Settings.Movable = not Me.Settings.Movable;
	local objFrame = ui.GetFrame("durnoticemini")
	if objFrame ~= nil then
		objFrame:EnableMove(Me.Settings.Movable and 1 or 0);
		SaveSetting();
	end
end

function TOUKIBI_DURMINI_RESETPOS()
	if Me.Settings == nil then return end
	Me.Settings.PosX = nil;
	Me.Settings.PosY = nil;
	Me.UpdatePos();
	local objFrame = ui.GetFrame("durnoticemini")
	if objFrame ~= nil then
		Me.Settings.PosX = objFrame:GetX();
		Me.Settings.PosY = objFrame:GetY();
	end
	SaveSetting();
	Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "Msg.UpdateFrmaePos"), "Info", true, false);
end

-- ***** その他イベント受取 *****

function TOUKIBI_DURMINI_START_DRAG()
	Me.IsDragging = true;
end

function TOUKIBI_DURMINI_END_DRAG()
	Me.IsDragging = false;
	if not Me.Settings.Movable then return end
	local objFrame = ui.GetFrame("durnoticemini")
	if objFrame == nil then return end
	Me.Settings.PosX = objFrame:GetX();
	Me.Settings.PosY = objFrame:GetY();
	SaveSetting();
	Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "Msg.EndDragAndSave"), "Info", true, true);
end

function TOUKIBI_DURMINI_LOSTFOCUS()
	TOUKIBI_DURPOPUP_LOSTFOCUS()
end

function TOUKIBI_DURMINI_MOUSEMOVE()
	TOUKIBI_DURPOPUP_CALLPOPUP()
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
	local TopFrame = ui.GetFrame("durnoticemini");
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
		local BaseFrame = ui.GetFrame("durnoticemini");
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

-- スラッシュコマンド受取
function TOUKIBI_DURMINI_PROCESS_COMMAND(command)
	Toukibi:AddLog(string.format(Toukibi:GetResText(Toukibi.CommonResText, Me.Settings.Lang, "Command.ExecuteCommands"), SlashCommandList[1] .. " " .. table.concat(command, " ")), "Info", true, true);
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
	elseif cmd == "jp" or cmd == "ja" or cmd == "en" or string.len(cmd) == 2 then
		if cmd == "ja" then cmd = "jp" end
		-- 言語モードと勘違いした？
		Toukibi:ChangeLanguage(cmd);
		TOUKIBI_DURMINI_UPDATE_ALL();
		return;
	elseif cmd ~= "?" then
		local strError = Toukibi:GetResText(Toukibi.CommonResText, Me.Settings.Lang, "Command.InvalidCommand");
		if #SlashCommandList > 0 then
			strError = strError .. string.format("{nl}" .. Toukibi:GetResText(Toukibi.CommonResText, Me.Settings.Lang, "Command.AnnounceCommandList"), SlashCommandList[1]);
		end
		Toukibi:AddLog(strError, "Warning", true, false);
	end 
	Me.ComLib:ShowHelpText()
end

function DURNOTICEMINI_ON_INIT(addon, frame)
	addon:RegisterMsg('UPDATE_ITEM_REPAIR', 'TOUKIBI_DURMINI_UPDATE');
	addon:RegisterMsg('ITEM_PROP_UPDATE', 'TOUKIBI_DURMINI_UPDATE');
	addon:RegisterMsg('EQUIP_ITEM_LIST_GET', 'TOUKIBI_DURMINI_UPDATE');
	addon:RegisterMsg('MYPC_CHANGE_SHAPE', 'TOUKIBI_DURMINI_UPDATE');
	addon:RegisterMsg('GAME_START', 'TOUKIBI_DURMINI_ON_GAME_START');

	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_DURMINI_PROCESS_COMMAND);
	end

	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	ui.GetFrame("durnoticemini"):EnableMove(Me.Settings.Movable and 1 or 0);
	Me.Show(1);
	Me.Update();
	Me.UpdatePos()
	frame:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_DURMINI_CONTEXT_MENU');
	Me.IsDragging = false;
	Me.Joke(OSRandom(1, 100) < 5)

	frame:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_DURMINI_MOUSEMOVE");

end


