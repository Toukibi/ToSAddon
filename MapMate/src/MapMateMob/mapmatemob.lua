local addonName = "MapMateMob";
local verText = "1.07";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/mmob", "/MMob"} -- {"/コマンド1", "/コマンド2", .......};
local CommandParamList = {
	update = {jp = "表示を更新", en = "The additional information displayed will be updated."}
};
local SettingFileName = "setting_mob.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
local MyParent = _G['ADDONS'][autherName].MapMate;
MMob = Me;
Me.MobInfo = nil;
local DebugMode = false;

-- テキストリソース
local ResText = {
	jp = {
		Menu = {
			Title = "{#006666}==== MapMateの設定(生息モンスター) ===={/}"
		  , UpdateNow = "今すぐ更新する"
		  , Height_Title = "高さの調整："
		  , Height_Space = "            "
		  , HeightByLines = "%s行分"
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
		MobInfo = {
			List_Mob = "生息モンスター一覧"
		  , MobInfoFormat = "{nl}{s14} {/}{s13}{ol}%s :{s14}%s{/}{/}{/}"
		  , RespawnTimeFormat = "{s13}{#66AA33}%s湧き{/}{/}{#333333}%s{/}"
		  , Respawn_WholeArea = "(全域)"
		  , Respawn_SpotArea = "(局地)"
		  , Type = "種族:%s"
		  , Attribute = "属性:%s"
		  , Armor = "防御:%s"
		  , Move = "移動属性:%s"
		  , Fire = "火"
		  , Ice = "氷"
		  , Lightning = "雷"
		  , Earth = "地"
		  , Poison = "毒"
		  , Dark = "闇"
		  , Holy = "聖"
		  , Velnias = "悪魔型"
		  , Widling = "獣型"
		  , Paramune = "変異型"
		  , Klaida = "昆虫型"
		  , Forester = "植物型"
		  , Cloth = "布"
		  , Leather = "皮"
		  , Iron = "鋼"
		  , Ghost = "念"
		  , Mon = "一般"
		  , Elite = "エリート"
		  , Boss = "Boss"
		  , Holding = "固定"
		  , Normal = "通常"
		  , Flying = "飛行"
		},
		DropRatio = {
			TitleFormat = "%sのドロップ情報{nl}{s4} {/}{nl}"
		},
		Other = {
			PercentChar = "％"
		  , Opened = "開封済"
		  , Registed = "登録済"
		  , Hour = "時間"
		  , Minutes = "分"
		  , Seconds = "秒"
		  , Soon = "即"
		}
	},
	en = {
		Menu = {
			Title = "{#006666}======= MapMate setting ======={nl}(Monster List){/}"
		  , UpdateNow = "Update now"
		  , Height_Title = "Display Lines:"
		  , Height_Space = "                          "
		  , HeightByLines = "%slines"
		  , Close = "Close"
		},
		System = {
			ErrorToUseDefaults = "Using default settings because an error occurred while loading the settings."
		  , CompleteLoadDefault = "Default settings loaded."
		  , CompleteLoadSettings = "Settings loaded!"
		  , ExecuteCommands = "Command '{#333366}%s{/}' was called."
		  , ResetSettings = "Settings reset."
		  , InvalidCommand = "Invalid command called."
		  , AnnounceCommandList = "Please use [ %s ? ] to see the command list."
		},
		MobInfo = {
			List_Mob = "Monster List"
		  , MobInfoFormat = "{nl}{s14} {/}{s13}%s :{s14}{ol}{b}%s{/}{/}{/}{/}"
		  , RespawnTimeFormat = "{s13}{#333333} {/}{#66AA33}{b}%s{/} {/}{#333333}%s{/}{/}"
		  , Respawn_WholeArea = "(Throughout)"
		  , Respawn_SpotArea = "(Spot)"
		  , Type = "Race:%s"
		  , Attribute = "Element:%s"
		  , Armor = "Armor:%s"
		  , Move = "Move:%s"
		  , Fire = "Fire"
		  , Ice = "Ice"
		  , Lightning = "Lightning"
		  , Earth = "Earth"
		  , Poison = "Poison"
		  , Dark = "Dark"
		  , Holy = "Holy"
		  , Velnias = "Demon"
		  , Widling = "Beast"
		  , Paramune = "Mutant"
		  , Klaida = "Insect"
		  , Forester = "Plant"
		  , Cloth = "Cloth"
		  , Leather = "Leather"
		  , Iron = "Plate"
		  , Ghost = "Ghost"
		  , Mon = "Normal"
		  , Elite = "Elite"
		  , Boss = "Boss"
		  , Holding = "Holding"
		  , Normal = "Normal"
		  , Flying = "Flying"
		},
		DropRatio = {
			TitleFormat = "Items drop of %s{nl}{s4} {/}{nl}"
		},
		Other = {
			PercentChar = "%"
		  , Opened = "Opened"
		  , Registed = "Registered"
		  , Hour = "Hour"
		  , Minutes = "Min."
		  , Seconds = "Sec."
		  , Soon = "Soon"
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
			  , CompleteLoadSettings = "Settings loaded."
			},
			Command = {
				ExecuteCommands = "Command '{#333366}%s{/}' was called."
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
local function view(objValue)
	local frame = ui.GetFrame("developerconsole");
	if frame == nil then return end
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
Me.SettingFilePathName = string.format("../addons/%s/%s", "mapmate", SettingFileName);
Me.Loaded = false;
Me.CurrentMobCount = 0;

-- 設定書き込み
local function SaveSetting()
	Toukibi:SaveTable(Me.SettingFilePathName, Me.Settings);
end

-- デフォルト設定(ForceがTrueでない場合は、既存の値はそのまま引き継ぐ)
local function MargeDefaultSetting(Force, DoSave)
	DoSave = Toukibi:GetValueOrDefault(DoSave, true);
	Me.Settings = Me.Settings or {};
	Me.Settings.DoNothing = Toukibi:GetValueOrDefault(Me.Settings.DoNothing, false, Force);
	if MyParent ~= nil then
		Me.Settings.Lang = MyParent.Settings.Lang
	else
		Me.Settings.Lang = "en"
	end
	--Me.Settings.Lang = Toukibi:GetValueOrDefault(Me.Settings.Lang, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.Movable		= Toukibi:GetValueOrDefault(Me.Settings.Movable		, true, Force);
	Me.Settings.Visible		= Toukibi:GetValueOrDefault(Me.Settings.Visible		, true, Force);
	Me.Settings.FloatMode	= Toukibi:GetValueOrDefault(Me.Settings.FloatMode	, false, Force);
	Me.Settings.PosX		= Toukibi:GetValueOrDefault(Me.Settings.PosX		, nil, Force);
	Me.Settings.PosY		= Toukibi:GetValueOrDefault(Me.Settings.PosY		, nil, Force);
	Me.Settings.Height		= Toukibi:GetValueOrDefault(Me.Settings.Height		, 540, Force);



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

local function GetPopTimeText(value)
	value = tonumber(value)
	local ForeColor = "#66AA33";
	if value < 1000 then
		return Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Soon");
	end
	local ReturnValue = "";
	local ContainsHour = false;
	if value >= 1000 * 60 * 60 then
		ReturnValue = ReturnValue .. math.floor(value / 60 / 60 / 1000) .. Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Hour");
		ForeColor = "#FF4444";
		ContainsHour = true;
	end
	value = value % (60 * 60 * 1000)
	if value >= 1000 * 60 then
		-- 分を記載(1分・5分・10分で色を変える)
		ForeColor = "#FFFF33";
		if value >= 1000 * 60 * 10 then
			ForeColor = "#FF4444";
		elseif value >= 1000 * 60 * 5 then
			ForeColor = "#FF8833";
		end
		ReturnValue = ReturnValue .. math.floor(value / 60 / 1000) .. Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Minutes");
	end	
	if not ContainsHour then
		-- 1時間未満なら秒も記載
		value = value % (60 * 1000)
		if value >= 1000 then
			ReturnValue = ReturnValue .. math.floor(value / 1000) .. Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Seconds");
		end
	end
	return Toukibi:GetStyledText(ReturnValue, {ForeColor});
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
	elseif (grade == 0) then return "FFFFFF"; -- default
	elseif (grade == 1) then return "FFFFFF"; -- common
	elseif (grade == 2) then return "108CFF"; -- rare
	elseif (grade == 3) then return "9F30FF"; -- epic
	elseif (grade == 4) then return "FF4F00"; -- orange
	elseif (grade == 5) then return "FFFF53"; -- legendary
	else return "E1E1E1"; -- no grade (non-equipment items)
	end
end

local function CreateDropRatioTooltip(MobData)
	-- モンスターごとのドロップリストを作成する
	-- 対象データのみ抽出
	
	local MatchList = {};
	--IToSかJToSかの判別(アイテムドロップテーブルの存在を確認することで判別)
	if GetClassCount("MonsterDropItemList_Onion") < 0 then
		-- ない場合(JToS)
		-- ToolTipHelper (Rebuild by Toukibi)の検出
		if ToolTipR.DropXMLData == nil or #ToolTipR.DropXMLData == 0 then return nil end;
		for _, value in ipairs(ToolTipR.DropXMLData) do
			if value.MobID == MobData.ClassID then
				table.insert(MatchList,  {ItemClassName = value.Item
										, Ratio = value.Ratio})
			end
		end
	else
		-- ある場合(IToS)
		-- ドロップテーブルから直に情報を取得する
		local monCls = GetClass("Monster", MobData.ClassName)
		if monCls.Faction == "Monster" and monCls.GroupName == "Monster" then
			local dropID = monCls.DropItemList;
			if dropID ~= nil and dropID ~= "None" then
				local dropID = 'MonsterDropItemList_' .. dropID;
				local dropClassCount = GetClassCount(dropID);
				if dropClassCount ~= nil and dropClassCount > 0 then
					for j = 0, dropClassCount - 1 do
						local dropIES = GetClassByIndex(dropID, j);
						if dropIES ~= nil and dropIES.GroupName == 'Item' then
							table.insert(MatchList,  {ItemClassName = dropIES.ItemClassName
													, Ratio = dropIES.DropRatio})

						end
					end
				end
			end
		end
	end

	-- 抽出されたリストをソートする
	table.sort(MatchList, function(a, b)
		return a.Ratio > b.Ratio
	end)

	local ReturnValue = Toukibi:GetStyledText(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "DropRatio.TitleFormat"), MobData.Name), {"#66AA33", "s14", "b"});

	-- 抽出されたデータからテキストを作成する
	local clsList, cnt = GetClassList("Collection");
	local MyCollectionList = session.GetMySession():GetCollection();
	for _, value in ipairs(MatchList) do
		local strTemp = "{nl}";
		local strCollectionCount = "";
		local StatusIcon = "channel_mark_empty";
		local CurrentCount, RequireCount = 0, 0;
		local itemCls = GetClass("Item", value.ItemClassName);
		local GradeColor = GetItemRarityColor(itemCls);

		-- TooltipHelper (Rebuild by Toukibi)のコレクションアイテムリストの検出
		if ToolTipR.ApplicationsList.Collection == nil then
			if ToolTipR ~= nil then
				ToolTipR.CreateApplicationsList_Collection();
			end
		end
		if ToolTipR.ApplicationsList.Collection ~= nil then
			local MatchList = ToolTipR.ApplicationsList.Collection[value.ItemClassName];
			if MatchList ~= nil then
				StatusIcon = "icon_item_box";
				for i, MatchData in ipairs(MatchList) do
					-- 該当のコレクションのデータを取得する
					local TargetCollection = GetClassByIndexFromList(clsList, MatchData.Index);
					local collectionJournal = TryGetProp(TargetCollection,'Journal')
					if collectionJournal == 'TRUE' then
						local MyCollection = MyCollectionList:Get(TargetCollection.ClassID);
						RequireCount = RequireCount + MatchData.Count;
						if MyCollection ~= nil then
							CurrentCount = CurrentCount + MyCollection:GetItemCountByType(GetClass("Item", value.ItemClassName).ClassID);
						end
					end
				end
				local CollectionCountTextColor = "#FF8888";
				if RequireCount <= CurrentCount then
					CollectionCountTextColor = "#00FF00";
				end
				strCollectionCount = string.format("{%s}(%s/%s){/}", CollectionCountTextColor, CurrentCount, RequireCount)
			end
		end

		strTemp = strTemp .. string.format("{b}{img %s 24 24} %s%s  {img %s 32 32} {#%s}%s{/} %s{/}"
										 , StatusIcon
										 , GetCommaedTextEx(tonumber(value.Ratio) / 100, 7, 2)
										 , Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.PercentChar")
										 , GET_ITEM_ICON_IMAGE(itemCls)
										 , GradeColor
										 , itemCls.Name
										 , strCollectionCount);
		ReturnValue = ReturnValue .. strTemp;
	end

	return ReturnValue;
end

-- MOB情報GroupBox描画
function CreateMobPanel(Parent, MobData, Index, Top)
	local width = Parent:GetWidth() - 24;
	local MinHeight = 90;
	Top = Top or (MinHeight * (Index - 1));

	local pnlBase = tolua.cast(Parent:CreateOrGetControl("controlset", "pnlMob_" .. MobData.ClassName, 
																0, Top, width, MinHeight), 
									"ui::CControlSet");

	pnlBase:SetSkinName("None");
	pnlBase:EnableHitTest(1);
	--pnlBase:EnableHitTestFrame(1);
	--pnlBase:EnableChangeMouseCursor(0);
	pnlBase:SetGravity(ui.LEFT, ui.TOP);

	local picMobImage = tolua.cast(pnlBase:CreateOrGetControl("picture", "mobimage", 4, 4, 48, 48), "ui::CPicture");
	picMobImage:SetGravity(ui.LEFT, ui.TOP);
	picMobImage:EnableHitTest(1);
	picMobImage:SetEnableStretch(1);
	picMobImage:EnableChangeMouseCursor(0);
	local IconName = MobData.Icon
	if string.find(string.lower(IconName),"mon_") == nil then IconName = "mon_" .. string.lower(IconName) end
	picMobImage:SetImage(IconName);
	local strDropListTooltipText = CreateDropRatioTooltip(MobData)
	if strDropListTooltipText ~= nil then
		picMobImage:SetTextTooltip(strDropListTooltipText);
	else
		picMobImage:SetTextTooltip("");
	end

	local picMobType = tolua.cast(pnlBase:CreateOrGetControl("picture", "mobType", 120, 2, 20, 20), "ui::CPicture");
	picMobType:SetGravity(ui.LEFT, ui.TOP);
	picMobType:EnableHitTest(1);
	picMobType:SetEnableStretch(1);
	picMobType:EnableChangeMouseCursor(0);
	picMobType:SetImage("mon_info_" .. MobData.Type);
	picMobType:SetTextTooltip(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.Type")
										  , Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo." .. MobData.Type)));

	local picMobAttribute = tolua.cast(pnlBase:CreateOrGetControl("picture", "mobAttribute", 140, 2, 20, 20), "ui::CPicture");
	picMobAttribute:SetGravity(ui.LEFT, ui.TOP);
	picMobAttribute:EnableHitTest(1);
	picMobAttribute:SetEnableStretch(1);
	picMobAttribute:EnableChangeMouseCursor(0);
	picMobAttribute:SetImage("mon_info_" .. MobData.Attribute);
	picMobAttribute:SetTextTooltip(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.Attribute")
								 , Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo." .. MobData.Attribute)));


	local picMobArmor = tolua.cast(pnlBase:CreateOrGetControl("picture", "mobArmor", 160, 2, 20, 20), "ui::CPicture");
	picMobArmor:SetGravity(ui.LEFT, ui.TOP);
	picMobArmor:EnableHitTest(1);
	picMobArmor:SetEnableStretch(1);
	picMobArmor:EnableChangeMouseCursor(0);
	picMobArmor:SetImage("mon_info_" .. MobData.Armor);
	picMobArmor:SetTextTooltip(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.Armor")
							 , Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo." .. MobData.Armor)));

	local picMoveType = tolua.cast(pnlBase:CreateOrGetControl("picture", "mobMoveType", 180, 2, 20, 20), "ui::CPicture");
	picMoveType:SetGravity(ui.LEFT, ui.TOP);
	picMoveType:EnableHitTest(1);
	picMoveType:SetEnableStretch(1);
	picMoveType:EnableChangeMouseCursor(0);
	picMoveType:SetImage("mon_info_" .. MobData.MoveType);
	picMoveType:SetTextTooltip(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.Move")
							 , Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo." .. MobData.MoveType)));

	local txtMobSize = pnlBase:CreateOrGetControl("richtext", "mobSize", 204, 4, 20, 20);
	txtMobSize:SetGravity(ui.LEFT, ui.TOP);
	txtMobSize:EnableHitTest(0);
	txtMobSize:SetText(Toukibi:GetStyledText(MobData.Size, {"#CCCCCC", "s16", "ol", "b"}));

	local txtMobRank = pnlBase:CreateOrGetControl("richtext", "mobRank", 4, 54, 60, 16);
	txtMobRank:SetGravity(ui.LEFT, ui.TOP);
	txtMobRank:EnableHitTest(0);
	local RankText = MobData.Rank;
	if RankText == "Boss" then
		RankText = Toukibi:GetStyledText(RankText, {"#FF0000"});
	elseif RankText == "Elite" then
		RankText = Toukibi:GetStyledText(RankText, {"#FF4444"});
	elseif RankText == "Special" then
		RankText = Toukibi:GetStyledText(RankText, {"#4444FF"});
	else
		RankText = Toukibi:GetStyledText(RankText, {"#888888"});
	end
	txtMobRank:SetText(Toukibi:GetStyledText(RankText, {"s12", "b"}));

	local txtMobKillCount = pnlBase:CreateOrGetControl("richtext", "mobKillCount", 4, 70, 20, 20);
	txtMobKillCount:SetGravity(ui.LEFT, ui.TOP);
	txtMobKillCount:EnableHitTest(0);
	local TextColor = "#333333";
	local KillCountText = MobData.KillCount
	local KillCountLimit = 120;
	if MobData.KillCount >= MobData.KillRequired then
		TextColor = "#4444FF"
	end
	if FunctionExists(GetMonKillCount) and MobData.KillCount >= KillCountLimit then
		KillCountText = "over " .. KillCountLimit;
	end
	txtMobKillCount:SetText(Toukibi:GetStyledText(string.format("[%s/%s]", KillCountText, MobData.KillRequired), {TextColor, "s12", "b"}));

	local txtName = pnlBase:CreateOrGetControl("richtext", "name", 54, 24, 180, 16);
	txtName:SetGravity(ui.LEFT, ui.TOP);
	txtName:EnableHitTest(0);
	txtName:SetTextFixWidth(1);
	txtName:SetTextMaxWidth(180);
	txtName:SetText(Toukibi:GetStyledText(MobData.Name, {"#FFFFFF", "ol", "b", "s14"}));
	local NowTop = 24 + txtName:GetHeight()

	local txtLv = pnlBase:CreateOrGetControl("richtext", "lv", 60, 4, 48, 16);
	txtLv:SetGravity(ui.LEFT, ui.TOP);
	txtLv:EnableHitTest(0);
	txtLv:SetText(Toukibi:GetStyledText("Lv." .. MobData.Lv, {"#888888", "s12", "ol"}));


	local txtRespawn = pnlBase:CreateOrGetControl("richtext", "txtRespawn", 70, NowTop + 4, 190, 16);
	txtRespawn:SetGravity(ui.LEFT, ui.TOP);
	txtRespawn:EnableHitTest(0);
	txtRespawn:SetTextFixWidth(1);
	txtRespawn:SetTextMaxWidth(190);

	local SortedPopData = {}
	for _, PopData in pairs(MobData.PopData) do
		table.insert(SortedPopData, PopData)
	end
	table.sort(SortedPopData, function(a, b)
		if a.PopTime ~= b.PopTime then
			return a.PopTime < b.PopTime
		else
			return a[0] > b[0]
		end
	end)

	local RespawnText = "";
	for _, PopData in ipairs(SortedPopData) do
		if true then
			if PopData[1] > 0 then
				RespawnText = RespawnText .. string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.MobInfoFormat")
															, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.RespawnTimeFormat")
																		,GetPopTimeText(PopData.PopTime)
																		,Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.Respawn_WholeArea"))
															, PopData[1]);
			end
			if PopData[2] > 0 then
				RespawnText = RespawnText .. string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.MobInfoFormat")
															, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.RespawnTimeFormat")
																		,GetPopTimeText(PopData.PopTime)
																		,Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.Respawn_SpotArea"))
															, PopData[2]);
			end
		else
				RespawnText = RespawnText .. string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.MobInfoFormat")
															, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.RespawnTimeFormat")
																		,GetPopTimeText(PopData.PopTime)
																		,"")
															, PopData[0]);
		end
	end
	txtRespawn:SetText(RespawnText);
	NowTop = NowTop + txtRespawn:GetHeight() + 8;
	if NowTop < MinHeight then NowTop = MinHeight end
	pnlBase:Resize(pnlBase:GetWidth(), NowTop);
	pnlBase:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATEMOB_CONTEXT_MENU');
	return NowTop
end


function Me.UpdateOnlyMobCount()
	if Me.MobInfo == nil then
		Me.MobInfo = MyParent.GetMapMonsterInfo()
	end
	--log("MOB討伐数更新");
	local BaseFrame = ui.GetFrame("mapmatemob");
	if BaseFrame == nil then return end
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlBase");
	for name, value in pairs(Me.MobInfo) do
		local TargetParent = GET_CHILD(BodyGBox, "pnlMob_" .. value.ClassName);
		if TargetParent ~= nil then
			local txtMobKillCount = GET_CHILD(TargetParent, "mobKillCount", "ui::CRichText");
			if txtMobKillCount ~= nil then
				local pKillCount = 0;
				local pRequired = 0;

				-- 2020/6/24 遅れながらにも新方式に切り替え
				-- pKillCount = ADVENTURE_BOOK_MONSTER_CONTENT.MONSTER_KILL_COUNT(value.ClassID);
				if FunctionExists(GetMonKillCount) then
					pKillCount = GetMonKillCount(nil, value.ClassID);
					local MonGrade = 'BASIC';
					if value.Rank == 'Boss' then
						MonGrade = 'BOSS';
					end
					-- log(GetClass('AdventureBookConst', MonGrade .. '_MON_GRADE_COUNT').Value);
					pRequired = GetClass('AdventureBookConst', MonGrade .. '_MON_KILL_COUNT_GRADE' .. GetClass('AdventureBookConst', MonGrade .. '_MON_GRADE_COUNT').Value).Value;
				end

				local TextColor = "#333333"
				if pKillCount >= pRequired then
					TextColor = "#4444FF"
				end
				local KillCountLimit = 120;
				if FunctionExists(GetMonKillCount) and pKillCount >= KillCountLimit then
					pKillCount = "over " .. KillCountLimit;
				end
				txtMobKillCount:SetText(Toukibi:GetStyledText(string.format("[%s/%s]", pKillCount, pRequired), {TextColor, "s12", "b"}));
			end
		else
			--log("対象発見できず  " .. "pnlMob_" .. value.ClassName)
		end
	end
end



function Me.UpdateMobList()
	if MyParent == nil then return false end
	Me.MobInfo = MyParent.GetMapMonsterInfo()
	local MobSortedList = {};
	for _, value in pairs(Me.MobInfo) do
		table.insert(MobSortedList, value)
	end
	table.sort(MobSortedList, function(a, b)
		if a.MaxNum ~= b.MaxNum then
			return a.MaxNum > b.MaxNum
		else
			return a.Name < b.Name
		end
	end)

	--view(MobInfo)
	local BaseFrame = ui.GetFrame("mapmatemob");
	if BaseFrame == nil then return end
	if Me.Settings.FloatMode then
		BaseFrame:SetSkinName("textview")
	else
		BaseFrame:SetSkinName("tooltip1")
	end
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlBase");
	GET_CHILD(BaseFrame, "title", "ui::CRichText"):SetText(Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "MobInfo.List_Mob"), {"#063306", "ol", "b"}));
	local btnClose = GET_CHILD(BaseFrame, "close", "ui::CButton");
	btnClose:SetImage("button_whisper_talk_exit");
	btnClose:Resize(24, 24);
	--btnClose:SetMargin(0, 4, 4, 0);
	local NowTop = 0;
	Me.CurrentMobCount = 0
	if BodyGBox ~= nil then
		local NowIndex = 1
		for name, value in pairs(MobSortedList) do
			NowTop = NowTop + CreateMobPanel(BodyGBox, value, NowIndex, NowTop);
			NowIndex = NowIndex + 1;
			Me.CurrentMobCount = Me.CurrentMobCount + 1;
		end
		if NowTop > Me.Settings.Height then NowTop = Me.Settings.Height end
		--BodyGBox:Resize(260, NowTop + 4);
		BodyGBox:Resize(BodyGBox:GetWidth(), NowTop);
		BodyGBox:SetScrollBar(NowTop);
	end
	BaseFrame:Resize(BaseFrame:GetWidth(), NowTop + 34);
	return true;
end




function Me.Update()
	if MyParent ~= nil then Me.Settings.Lang = MyParent.Settings.Lang end
	local BaseFrame = ui.GetFrame("mapmatemob");
	if BaseFrame ~= nil then
		BaseFrame:EnableHitTest(1);
		BaseFrame:EnableMove(1);
		BaseFrame:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_MAPMATEMOB_ADDDURATION");	
		BaseFrame:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATEMOB_CONTEXT_MENU');
	end
	Me.UpdateMobList()
end

-- ***** コンテキストメニューを作成する *****

function TOUKIBI_MAPMATEMOB_CONTEXT_MENU(frame, ctrl)
	local Title = Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Title");
	local context = ui.CreateContextMenu("MAPMATEMOB_MAIN_RBTN", Title, 0, 0, 320, 0);
	Toukibi:MakeCMenuSeparator(context, 300);
	Toukibi:MakeCMenuItem(context, string.format("{#FFFF88}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.UpdateNow")), "TOUKIBI_MAPMATEMOB_UPDATE()", nil, nil);
	Toukibi:MakeCMenuSeparator(context, 300.1);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Height_Title"), 
											string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.HeightByLines"), 2), 
											"TOUKIBI_MAPMATEMOB_CHANGEPROP('Height', 180)", nil, Me.Settings.Height == 180);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Height_Space"), 
											string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.HeightByLines"), 4), 
											"TOUKIBI_MAPMATEMOB_CHANGEPROP('Height', 360)", nil, Me.Settings.Height == 360);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Height_Space"), 
											string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.HeightByLines"), 6), 
											"TOUKIBI_MAPMATEMOB_CHANGEPROP('Height', 540)", nil, Me.Settings.Height == 540);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Height_Space"), 
											string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.HeightByLines"), 8), 
											"TOUKIBI_MAPMATEMOB_CHANGEPROP('Height', 720)", nil, Me.Settings.Height == 720);
	Toukibi:MakeCMenuSeparator(context, 300.2);
	Toukibi:MakeCMenuItem(context, string.format("{#666666}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Close")));
	context:Resize(330, context:GetHeight());
	ui.OpenContextMenu(context);
	return context;
end

-- ***** コンテキストメニューのイベント受け *****

function TOUKIBI_MAPMATEMOB_TOGGLEPROP(Name, Value)
	if Name == nil then return end
	if Me.Settings == nil then return end
	if Value == "nil" or type(Value) ~= "boolean" then
		Me.Settings[Name] = not Me.Settings[Name];
	else
		Me.Settings[Name] = Value;
	end
	SaveSetting();
end

function TOUKIBI_MAPMATEMOB_CHANGEPROP(Name, Value)
	if Name == nil then return end
	if Me.Settings == nil then return end
	if Value == "nil" then Value = nil end
	Me.Settings[Name] = Value
	SaveSetting();
	Me.Update();
end


-- ***** その他のイベント受け *****

function TOUKIBI_MAPMATEMOB_COUNTCHANGE(frame, msg, argStr, argNum)
	if msg == "UPDATE_ADVENTURE_BOOK" then
		if argNum == ABT_MON_KILL_COUNT then
			Me.UpdateOnlyMobCount()
		end
	end
end

function TOUKIBI_MAPMATEMOB_OPEN()
	Me.Update()
end

function TOUKIBI_MAPMATEMOB_UPDATE()
	Me.Update()
end

function TOUKIBI_MAPMATEMOB_LOSTFOCUS()
	if Me.Settings.FloatMode then return end
	local BaseFrame = ui.GetFrame("mapmatemob");
	if BaseFrame == nil then return end
	BaseFrame:SetDuration(0.5);
end

function TOUKIBI_MAPMATEMOB_ADDDURATION()
	local BaseFrame = ui.GetFrame("mapmatemob");
	BaseFrame:SetDuration(0);
end

function TOUKIBI_MAPMATEMOB_CALLPOPUP()
	local BaseFrame = ui.GetFrame("mapmatemob");
	BaseFrame:SetDuration(0);
	if BaseFrame:IsVisible() == 1 then return end
	BaseFrame:SetMargin(0, 70, 30, 0);
	BaseFrame:ShowWindow(1)
	Me.Update()
end

function TOUKIBI_MAPMATEMOB_CALLHIDE()
	local BaseFrame = ui.GetFrame("mapmatemob");
	if BaseFrame:IsVisible() == 0 then return end
	if Me.Settings.FloatMode then return end
	BaseFrame:ShowWindow(0)
end

function TOUKIBI_MAPMATEMOB_CALLCLOSE()
	local BaseFrame = ui.GetFrame("mapmatemob");
	if BaseFrame:IsVisible() == 0 then return end
	Me.Settings.FloatMode = false;
	SaveSetting();
	BaseFrame:SetSkinName("tooltip1")
	BaseFrame:ShowWindow(0)
end

function TOUKIBI_MAPMATEMOB_END_DRAG()
	if not Me.Settings.Movable then return end
	local objFrame = ui.GetFrame("mapmatemob")
	if objFrame == nil then return end
	Me.Settings.FloatMode = true;
	objFrame:SetSkinName("textview")
	objFrame:Invalidate()
	Me.Settings.PosX = objFrame:GetX();
	Me.Settings.PosY = objFrame:GetY();
	SaveSetting();
end

function TOUKIBI_MAPMATEMOB_RESIZE(frame)
	frame:CancelReserveScript("_TOUKIBI_MAPMATEMOB_RESIZE");
	--frame:ReserveScript("_TOUKIBI_MAPMATEMOB_RESIZE", 0.3, 0, "");
end

function _TOUKIBI_MAPMATEMOB_RESIZE(frame)
	Me.Settings.Height = frame:GetHeight(); 	
	SaveSetting();
end

-- [DevConsole呼出可] 表示位置を更新する
function Me.UpdatePos()
	local BaseFrame = ui.GetFrame("durnoticemini");
	if BaseFrame == nil then return end
	if Me.Settings == nil or Me.Settings.PosX == nil or Me.Settings.PosY == nil then
		-- デフォルト設定
		local MinimapFrame = ui.GetFrame("minimap");
		if MinimapFrame ~= nil then
			BaseFrame:SetPos(MinimapFrame:GetX() + MinimapFrame:GetWidth() - BaseFrame:GetWidth(), MinimapFrame:GetY() + MinimapFrame:GetHeight() + 50);
		end
	else
		BaseFrame:SetPos(Me.Settings.PosX, Me.Settings.PosY);
	end
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取
function TOUKIBI_MAPMATEMOB_PROCESS_COMMAND(command)
	Toukibi:AddLog(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ExecuteCommands"), SlashCommandList[1] .. " " .. table.concat(command, " ")), "Info", true, true);
	local cmd = ""; 
	if #command > 0 then 
		cmd = table.remove(command, 1); 
	else 
		ui.ToggleFrame("mapmatemob");
		return;
	end 
	if cmd == "reset" then 
		-- すべてをリセット
		MargeDefaultSetting(true, true);
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ResetSettings"), "Notice", true, false);
		return;
	elseif cmd == "update" then
		-- 表示値の更新
		Me.Update();
		return;
	elseif cmd == "jp" or cmd == "en" or string.len(cmd) == 2 then
		-- 言語モードと勘違いした？
		if cmd == "ja" then cmd = "jp" end
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

Me.HoockedOrigProc = Me.HoockedOrigProc or {};
function MAPMATEMOB_ON_INIT(addon, frame)
	-- 設定を読み込む
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	--if true or Me.Settings.DoNothing then return end

	--[[
	--タイマーを使う場合
	Me.timer_main = GET_CHILD(ui.GetFrame("mapmate"), "timer_main", "ui::CAddOnTimer");
	Me.timer_main:SetUpdateScript("[イベント名に変える]");
	--]]

	-- イベントを登録する
	addon:RegisterOpenOnlyMsg("UPDATE_ADVENTURE_BOOK", 'TOUKIBI_MAPMATEMOB_COUNTCHANGE');

	--Me.Settings.FloatMode = false;
	local BaseFrame = ui.GetFrame("mapmatemob")
	BaseFrame:EnableMove(1);
	if Me.Settings.FloatMode then
		Me.UpdatePos()
		Me.Update()
		if Me.CurrentMobCount > 0 then
			BaseFrame:ShowWindow(1);
		else
			BaseFrame:ShowWindow(0);
		end
	else
		BaseFrame:ShowWindow(0);
	end
	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_MAPMATEMOB_PROCESS_COMMAND);
	end
end

