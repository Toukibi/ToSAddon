local addonName = "MapMate";
local verText = "0.92";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/mapmate", "/mmate", "/MapMate", "/MMate"};
local CommandParamList = {
	reset = {jp = "設定リセット", en = "Reset all settings."},
	update = {jp = "表示を更新", en = "The additional information displayed will be updated."}
};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
MapMate = Me;
local DebugMode = false;

-- テキストリソース
local ResText = {
	jp = {
		Common = {
			PercentMark = "％"
		},
		Menu = {
			Title = "{#006666}==== MapMateの設定(接続人数更新) ===={/}"
		  , TitleNotice = "{#663333}更新機能はサーバーへの通信を行います。{nl}使用は自己責任でお願いします。{/}"
		  , UpdateNow = "今すぐ更新する"
		  , AutoUpdate_Title = "自動更新間隔："
		  , AutoUpdateBySeconds = "%s秒"
		  , AutoUpdateByMinutes = "%s分"
		  , NoAutoUpdate = "更新しない"
		  , ManuallyUpdate = "{img minimap_0_old 20 20}をクリックで手動更新する"
		  , ContinuousUpdatePrevention = "更新後5秒間は更新しない"
		  , ShowMapNameOutside = "マップ名を外部に表示する"
		  , Close = "閉じる"
		},
		ClockMenu = {
			Title = "{#006666}==== 時計設定 ===={/}"
		  , Clock_Title = "時刻選択："
		  , ServerTime = "サーバー時刻"
		  , ServerTimeFull = "サーバー時刻"
		  , LocalTime = "PCの時刻"
		  , LocalTimeFull = "PCの時刻"
		  , ampm_Title = "表記法："
		  , ampm = "AM/PM 表記"
		  , Noampm = "24時間表記"
		  , DisplaySec = "秒も表示(ローカル時計専用)"
		},
		QuestMenu = {
			Title = "{#006666}==== クエスト表示設定 ===={/}"
		  , DisplayImpossibleQuest = "進行不可なクエストも表示"
		  , CountTitle = "件数表示の設定"
		  , CountPossible = "進行可能な件数を表示"
		  , CountAll = "すべての件数を表示"
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
		  , TBox = "宝箱"
		  , ListTitleFormat = "{#66FF66}%s{/}{s24} {/}"
		  , List_NoMeetStatue = "まだ会っていない女神像の一覧"
		  , List_NoMeetNPC = "まだ会っていないNPCの一覧"
		  , List_ClosedTBox = "まだ開けていない宝箱の一覧"
		  , List_Mob = "生息モンスター一覧"
		  , List_Quest = "残っているクエスト一覧"
		  , List_Collection = "コレクション登録状況"
		  , MsgNotPrayed = "まだ祈っていないジェミナ像があります"
		  , MobInfoFormat = "{nl}{s20}    {/}{s14}%s :{s16}%s匹{/}{/}"
		  , RespawnTimeFormat = "{s16}{#66AA33}%s湧き{/}{/}{#333333}%s{/}"
		  , Respawn_WholeArea = "(全域)"
		  , Respawn_SpotArea = "(局地)"
		},
		DeathPenalty = {
			Title = "デスペナ情報"
		  , LostGem = "%s個のジェムをドロップ"
		  , LostSilver = "%s％のシルバーが消失"
		  , LostCard = "%s枚のBossカードをドロップ"
		  , LostBlessStone = "%s％の祝福石が消失"
		  , Other = "その他のペナルティー(%s)"
		},
		GetConnectionNumber = {
			Title = "接続人数"
		  , Failed = "接続人数の取得に失敗しました"
		  , Cannot = "接続人数の取れないMapです"
		  , Closed = "このチャンネルは閉鎖されています"
		  , StateClosed = "閉鎖"
		},
		Other = {
			PercentChar = "％"
		  , Opened = "開封済"
		  , Registed = "登録済"
		  , Hour = "時間"
		  , Minutes = "分"
		  , Seconds = "秒"
		  , Soon = "即"
		  , InProgress = "[進行中]"
		  , Complete = "[完了]"
		}
	},
	en = {
		Common = {
			PercentMark = "%"
		},
		Menu = {
			Title = "{#006666}======= MapMate setting ======={nl}(connection number update){/}"
		  , TitleNotice = "{#663333}The update function communicates with{nl}the server. Use it at your own risk.{/}"
		  , UpdateNow = "Update now"
		  , AutoUpdate_Title = "Auto Update Interval:"
		  , AutoUpdateBySeconds = "%ssec."
		  , AutoUpdateByMinutes = "%smin."
		  , NoAutoUpdate = "Never"
		  , ManuallyUpdate = "Click on{img minimap_0_old 20 20}to update manually"
		  , ContinuousUpdatePrevention = "Wait for 5sec. after updating"
		  , ShowMapNameOutside = "Show map info outside minimap"
		  , Close = "Close"
		},
		ClockMenu = {
			Title = "{#006666}==== Time display setting ===={/}"
		  , Clock_Title = "Time selection:"
		  , ServerTime = "Server time"
		  , ServerTimeFull = "Server time"
		  , LocalTime = "Local Time"
		  , LocalTimeFull = "Local Time"
		  , ampm_Title = "Display:"
		  , ampm = "Standard"
		  , Noampm = "24Hour"
		  , DisplaySec = "Show Sec.(Local time only)"
		},
		QuestMenu = {
			Title = "{#006666}==== Quest display setting ===={/}"
		  , DisplayImpossibleQuest = "Display quests that cannot be started"
		  , CountTitle = "Set badge display"
		  , CountPossible = "Display progressable count"
		  , CountAll = "Display all counts"
		},
		System = {
			ErrorToUseDefaults = "Using default settings because an error occurred while loading the settings."
		  , CompleteLoadDefault = "Default settings loaded."
		  , CompleteLoadSettings = "Settings loaded!"
		  , ExecuteCommands = "Command '{#333366}%s{/}' was called."
		  , ResetSettings = "Settings resetted."
		  , InvalidCommand = "Invalid command called."
		  , AnnounceCommandList = "Please use [ %s ? ] to see the command list."
		},
		MapInfo = {
			Title = "Information of "
		  , ExplorationProgress = "Exploration progress"
		  , CardLv = "Card Level"
		  , MaxHate = "Aggro Limit"
		  , TBox = "Treasure Box"
		  , ListTitleFormat = "{#66FF66}%s{/}{s24} {/}"
		  , List_NoMeetStatue = "List of statues not yet met"
		  , List_NoMeetNPC = "List of NPCs not met yet"
		  , List_ClosedTBox = "List of treasure boxes"
		  , List_Mob = "Monster List"
		  , List_Quest = "List of remaining quests"
		  , List_Collection = "List of collection items:"
		  , MsgNotPrayed = "There is a statue of Zemina that has not yet been prayed."
		  , MobInfoFormat = "{nl}{s20}    {/}%s : %s"
		  , RespawnTimeFormat = "{s16}{#333333}Respawn Time:{/}{#66AA33}{b}%s{/} {/}{#333333}%s{/}{/}"
		  , Respawn_WholeArea = "(Whole Area)"
		  , Respawn_SpotArea = "(Spot)"
		},
		DeathPenalty = {
			Title = "Additional penalty for character's death"
		  , LostGem = "Loss of %s Gems"
		  , LostSilver = "Loss of %s%% silver"
		  , LostCard = "Loss of %s boss-cards"
		  , LostBlessStone = "Loss of %s%% blessed stone"
		  , Other = "Other items(%s)"
		},
		GetConnectionNumber = {
			Title = "Current players"
		  , Failed = "Failed to get players amount"
		  , Cannot = "Unable to get players amount in this map"
		  , Closed = "This channel is closed"
		  , StateClosed = "Closed"
		},
		Other = {
			PercentChar = "%"
		  , Opened = "Opened"
		  , Registed = "Registered"
		  , Hour = "Hour"
		  , Minutes = "Min."
		  , Seconds = "Sec."
		  , Soon = "Soon"
		  , InProgress = "[In Progress]"
		  , Complete = "[Complete]"
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
local function try(func, ...)
	local status, error = pcall(func, ...)
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
	Me.Settings.DoNothing				= Toukibi:GetValueOrDefault(Me.Settings.DoNothing				, false, Force);
	Me.Settings.Lang					= Toukibi:GetValueOrDefault(Me.Settings.Lang					, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.Movable					= Toukibi:GetValueOrDefault(Me.Settings.Movable					, false, Force);
	Me.Settings.Visible					= Toukibi:GetValueOrDefault(Me.Settings.Visible					, true, Force);
	Me.Settings.UpdatePCCountInterval	= Toukibi:GetValueOrDefault(Me.Settings.UpdatePCCountInterval	, nil, Force);
	Me.Settings.EnableOneClickPCCUpdate = Toukibi:GetValueOrDefault(Me.Settings.EnableOneClickPCCUpdate	, false, Force);
	Me.Settings.UsePCCountSafety		= Toukibi:GetValueOrDefault(Me.Settings.UsePCCountSafety		, true, Force);
	Me.Settings.UseServerClock			= Toukibi:GetValueOrDefault(Me.Settings.UseServerClock			, true, Force);
	Me.Settings.UseAMPM					= Toukibi:GetValueOrDefault(Me.Settings.UseAMPM					, true, Force);
	Me.Settings.ShowMapNameOutside		= Toukibi:GetValueOrDefault(Me.Settings.ShowMapNameOutside		, false, Force);
	Me.Settings.DisplaySec				= Toukibi:GetValueOrDefault(Me.Settings.DisplaySec				, false, Force);
	Me.Settings.DisplayImpossibleQuest	= Toukibi:GetValueOrDefault(Me.Settings.DisplayImpossibleQuest	, false, Force);
	Me.Settings.QuestBadge_DisplayAll	= Toukibi:GetValueOrDefault(Me.Settings.QuestBadge_DisplayAll	, false, Force);
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

-- バッジを作る
local function CreateMiniBadge(parentCtrl, noticeName, point)
	--point = point * 100
	if parentCtrl == nil then return end

	local notice = parentCtrl:GetChild(noticeName .. "notice");
	local noticeText = parentCtrl:GetChild(noticeName .. "noticetext");

	if point > 0 then
		notice:ShowWindow(1);
		noticeText:ShowWindow(1);
		noticeText:SetText('{ol}{s11}' .. tostring(point) .. "{/}{/}");
		if point >= 10 and point < 100 then
			notice:Resize(0, 0, 24, 19);
		elseif point >= 100 and point < 1000 then
			notice:Resize(0, 0, 30, 19);
		else
			notice:Resize(0, 0, 18, 19);
		end
	elseif point == 0 then
		notice:ShowWindow(0);
		noticeText:ShowWindow(0);
	end
end

local function CreateToolButton(Parent, Name, left, top, width, height, Icon, NoticeNum)
	local DefSize = 28;
	left = left or 0;
	top = top or 0;
	width = width or DefSize;
	height = height or DefSize;
	local pnlBase = tolua.cast(Parent:CreateOrGetControl("groupbox", Name, left, top, 32, 32), "ui::CGroupBox");
	pnlBase:SetGravity(ui.LEFT, ui.TOP);
	-- pnlBase:Resize(pRect.width , pRect.height);
	pnlBase:SetSkinName("chat_window");
	--pnlBase:SetSkinName("None");
	pnlBase:EnableScrollBar(0);
	pnlBase:EnableHitTest(1);
	pnlBase:ShowWindow(1);

	local picBase = tolua.cast(pnlBase:CreateOrGetControl("picture", "picBase", 0, 0, width, height), "ui::CPicture");
	picBase:SetGravity(ui.LEFT, ui.TOP);
	picBase:EnableHitTest(0);
	picBase:SetEnableStretch(1);
	picBase:SetImage(Icon);
	picBase:ShowWindow(1);

	if NoticeNum ~= nil and type(NoticeNum) == "number" then
		local pnlNoticeBase = tolua.cast(pnlBase:CreateOrGetControl("groupbox", Name .. "notice", 0, 0, 20, 20), "ui::CGroupBox");
		pnlNoticeBase:SetGravity(ui.RIGHT, ui.BOTTOM);
		-- pnlNoticeBase:Resize(pRect.width , pRect.height);
		pnlNoticeBase:SetSkinName("digitnotice_bg");
		pnlNoticeBase:SetMargin(0, 0, 0, 0);
		pnlNoticeBase:EnableScrollBar(0);
		pnlNoticeBase:EnableHitTest(0);
		pnlNoticeBase:ShowWindow(1);
		if NoticeNum < 0 then
			-- 負の数を指定するとチェックマークに
			pnlNoticeBase:SetSkinName("None");
			local objNoticeIcon = tolua.cast(pnlBase:CreateOrGetControl("picture", Name .. "noticeicon", 0, 0, 20, 20), "ui::CPicture");
			objNoticeIcon:SetGravity(ui.RIGHT, ui.BOTTOM);
			objNoticeIcon:SetMargin(0, 0, 3, 1);
			objNoticeIcon:SetEnableStretch(1);
			objNoticeIcon:SetImage("socket_slot_check");
			objNoticeIcon:EnableHitTest(0);
		else
			-- 通常
			local objNoticeText = tolua.cast(pnlBase:CreateOrGetControl("richtext", Name .. "noticetext", 0, 0, 20, 20), "ui::CRichText");
			objNoticeText:SetGravity(ui.RIGHT, ui.BOTTOM);
			objNoticeText:SetTextAlign("left", "center");
			objNoticeText:SetMargin(0, 0, 3, 1);
			objNoticeText:EnableHitTest(0);
			objNoticeText:ShowWindow(1);

			CreateMiniBadge(pnlBase, Name, NoticeNum)
		end
	end

	return pnlBase
end

local function GetPopTimeText(value)
	value = tonumber(value)
	if value < 1000 then
		return Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Soon");
	end
	local ReturnValue = "";
	local ContainsHour = false;
	if value >= 1000 * 60 * 60 then
		ReturnValue = ReturnValue .. math.floor(value / 60 / 60 / 1000) .. Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Hour");
		ContainsHour = true;
	end
	value = value % (60 * 60 * 1000)
	if value >= 1000 * 60 then
		ReturnValue = ReturnValue .. math.floor(value / 60 / 1000) .. Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Minutes");
	end
	if ContainsHour then
		return ReturnValue;
	end
	value = value % (60 * 1000)
	if value >= 1000 then
		ReturnValue = ReturnValue .. math.floor(value / 1000) .. Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Seconds");
	end
	return ReturnValue;
end

local function GetMobListToolTipText()
	local MobInfo = Me.GetMapMonsterInfo()
	local MobSortedList = {};
	for _, value in pairs(MobInfo) do
		table.insert(MobSortedList, value)
	end
	table.sort(MobSortedList, function(a, b)
		if a.MaxNum ~= b.MaxNum then
			return a.MaxNum > b.MaxNum
		else
			return a.Name < b.Name
		end
	end)
	--view(MobSortedList)

	local ToolTipText = "";
	local ToDisplayCount = 0;
	-- Mob
	ToDisplayCount = 0;
	ToolTipText = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ListTitleFormat"), Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.List_Mob"));
	for _, value in ipairs(MobSortedList) do
		if value.Name ~= "None" then
			ToDisplayCount = ToDisplayCount + 1;
			ToolTipText = ToolTipText .. string.format("{nl}{s18}{#AAAAAA}%s{/}{/}  {s14}{#888888}Lv.%s{/}{/}{s12}{#666666}  (%s/%s){/}{/}{s32} {/}", value.Name, value.Lv, value.KillCount, value.KillRequired);
			for PopTime, PopData in pairs(value.PopData) do
				if true then
					if PopData[1] > 0 then
						ToolTipText = ToolTipText .. string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.MobInfoFormat")
																 , string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.RespawnTimeFormat")
																 				,GetPopTimeText(PopTime)
																				,Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.Respawn_WholeArea"))
																 , PopData[1])
					end
					if PopData[2] > 0 then
						ToolTipText = ToolTipText .. string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.MobInfoFormat")
																 , string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.RespawnTimeFormat")
																 				,GetPopTimeText(PopTime)
																				,Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.Respawn_SpotArea"))
																 , PopData[2])
					end
				else
						ToolTipText = ToolTipText .. string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.MobInfoFormat")
																 , string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.RespawnTimeFormat")
																 				,GetPopTimeText(PopTime)
																				,"")
																 , PopData[0])
				end
			end
		end
	end
	if ToDisplayCount == 0 then
		ToolTipText = "";
	end
	return ToolTipText;
end

function Me.UpdateFrame()
	local QuestInfo = Me.GetMapQuestInfo()
	local ParentWidth = 32;
	local height = ParentWidth + 2;
	local FrameMiniMap = ui.GetFrame('minimap');
	local MyFrame = ui.GetFrame('mapmate');

	MyFrame:Resize(ParentWidth , height * 10);
	MyFrame:SetMargin(0, FrameMiniMap:GetMargin().top, 1, 0);
	local pnlBase = tolua.cast(MyFrame:CreateOrGetControl("groupbox", "pnlInput", 0, 8, ParentWidth , height * 5), 
							   "ui::CGroupBox");
	
	pnlBase:SetGravity(ui.RIGHT, ui.TOP);
	pnlBase:SetMargin(0, 0, 0, 0);
	pnlBase:Resize(ParentWidth , height * 10);
	--pnlBase:SetSkinName("chat_window");
	pnlBase:SetSkinName("None");
	pnlBase:EnableScrollBar(0);
	pnlBase:EnableHitTest(1);

	-- アイコン案
	pnlBase:RemoveAllChild();

	-- expert_info_gauge_image :ちょっとしょぼい
	local ToolTipText = "";
	local ButtonCount = 0;
	local ToDisplayCount = 0;
	-- Mob
	ToDisplayCount = 0;
	ToolTipText = GetMobListToolTipText()
	if ToolTipText ~= "" then
		objButton = CreateToolButton(pnlBase, "btnMOB", 0, height * ButtonCount, nil, nil, "icon_state_medium")
		objButton:SetGravity(ui.CENTER_HORZ, ui.TOP);
		--objButton:SetTextTooltip(ToolTipText)
		objButton:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_MAPMATE_SHOWMOBLIST");
		ButtonCount = ButtonCount + 1
	end

	-- クエスト
	ToDisplayCount = 0;
	local QuestBadgeCount = 0;
	ToolTipText = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ListTitleFormat"), Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.List_Quest"));
	local MinModeNo = 10;
	for i,value in ipairs(QuestInfo) do
		if value.ModeNo > 0 or Me.Settings.DisplayImpossibleQuest then
			ToDisplayCount = ToDisplayCount + 1;
			if value.ModeNo > 0 or Me.Settings.QuestBadge_DisplayAll then
				QuestBadgeCount = QuestBadgeCount + 1;
			end
			if string.len(ToolTipText) <= 4020 then
				ToolTipText = ToolTipText .. "{nl}{s28} {/}" .. value.Text
			end
		end
		if value.ModeNo > 0 and MinModeNo > value.ModeNo then
			MinModeNo = value.ModeNo;
		end
	end
	local QuestIconName = "minimap_1_SUB";
	if MinModeNo == 1 then
		QuestIconName = "minimap_1_MAIN";
	end
	if ToDisplayCount > 0 then
		objButton = CreateToolButton(pnlBase, "btnQuest", 0, height * ButtonCount, nil, nil, QuestIconName, QuestBadgeCount)
		objButton:SetGravity(ui.CENTER_HORZ, ui.TOP);
		objButton:SetTextTooltip(ToolTipText)
		objButton:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_MAPMATE_HIDEMOBLIST");
		objButton:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_QUEST');
		ButtonCount = ButtonCount + 1
	end

	local NPCLoadState, NPCInfo = pcall(Me.GetMapNPCInfo)
	if NPCLoadState then
		-- NPC
		ToDisplayCount = 0;
		ToolTipText = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ListTitleFormat"), Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.List_NoMeetNPC"));
		for i,value in ipairs(NPCInfo) do
			if (value.NpcState == nil or value.NpcState == 0) and value.Type == "NPC" and value.X ~= nil and value.Y ~= nil then
				ToDisplayCount = ToDisplayCount + 1;
				ToolTipText = ToolTipText .. string.format("{nl}{s28} {/}{img %s 20 20} %s",value.Icon ,value.Name);
			end
		end
		if ToDisplayCount > 0 then
			objButton = CreateToolButton(pnlBase, "btnNPC", 0, height * ButtonCount, nil, nil, "minimap_0", ToDisplayCount)
			objButton:SetGravity(ui.CENTER_HORZ, ui.TOP);
			objButton:SetTextTooltip(ToolTipText)
			objButton:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_MAPMATE_HIDEMOBLIST");
			ButtonCount = ButtonCount + 1
		end


		-- 女神像
		ToDisplayCount = 0;
		ToolTipText = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ListTitleFormat"), Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.List_NoMeetStatue"));
		local ContainsZemina = false;
		for i,value in ipairs(NPCInfo) do
			if value.NpcState ~= 20 and value.Type == "Statue" then
				ToDisplayCount = ToDisplayCount + 1;
				ToolTipText = ToolTipText .. "{nl}{s28} {/}{img minimap_goddess 20 20} " .. value.Name
				if value.ClassName == "statue_zemina" then
					ContainsZemina = true;
				end
			end
		end
		if ToDisplayCount > 0 then
			local objButton = CreateToolButton(pnlBase, "btnStatue"	, 0, height * ButtonCount, nil, nil, "minimap_goddess", ToDisplayCount)
			objButton:SetTextTooltip(ToolTipText)
			-- objButton:SetTextTooltip(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.MsgNotPrayed"))
			local ColorToneValue = "FF33BBFF";
			if ContainsZemina then
				ColorToneValue = "FFFF7575";
			end
			objButton:GetChild('picBase'):SetColorTone(ColorToneValue)
			ButtonCount = ButtonCount + 1
		end


		-- 宝箱
		ToDisplayCount = 0;
		ToolTipText = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ListTitleFormat"), Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.List_ClosedTBox"));
		local CollBoxOpened = true
		for i,value in ipairs(NPCInfo) do
			local IconText = "compen_btn"
			if (value.NpcState == nil or value.NpcState == 0) and value.Type == "Box" then
				local InsideData = Toukibi:Split(value.ArgStr2, ":");
				local InsideItemText = GetClass("Item", InsideData[2]).Name
				local ForeColor = "#FFFFFF"
				if string.find(string.lower(value.ArgStr2),"collect") then
					-- コレクションボックス
					-- すでに取得済みかを調べる
					if #InsideData >= 2 and InsideData[1] == "ITEM" then
						IconText = "jour_compen_off";
						if session.GetMySession():GetCollection():Get(GetClass("Collection", InsideData[2]).ClassID) == nil then
							CollBoxOpened = false
							IconText = "icon_item_box";
							ToDisplayCount = ToDisplayCount + 1;
						else
							ForeColor = "#333333"
							InsideItemText = string.format("(%s)%s", Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Registed"), InsideItemText);
						end
					else
						ToDisplayCount = ToDisplayCount + 1;
					end
				else
					if value.ArgStr1 ~= "LV1" then
						ForeColor = "#FF8888"
					else
						ForeColor = "#22AAAA"
					end
					ToDisplayCount = ToDisplayCount + 1;
				end
				ToolTipText = ToolTipText .. string.format("{nl}{s28} {/}{%s}{img " .. IconText .. " 20 20} %s %s{/}", ForeColor, value.Name, InsideItemText)
			end
		end
		if ToDisplayCount > 0 then
			local IconText = "compen_btn"
			if not CollBoxOpened then
				IconText = "icon_item_box"
			end
			objButton = CreateToolButton(pnlBase, "btnBox", 0, height * ButtonCount, nil, nil, IconText);
			objButton:SetGravity(ui.CENTER_HORZ, ui.TOP);
			objButton:SetTextTooltip(ToolTipText);
			objButton:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_MAPMATE_HIDEMOBLIST");
			ButtonCount = ButtonCount + 1;
		end
		-- コレクション
		ToDisplayCount = #Me.ThisMapInfo.CollectionID;
		if ToDisplayCount > 0 then
			local MobInfo = Me.GetMapMonsterInfo()
			for i, value in ipairs(Me.ThisMapInfo.CollectionID) do
				local MaxCount = 0;
				local NotCount = 0;
				local Completed = true;
				local ExistsList = {};
				local ToolTipText = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ListTitleFormat"), value.Name);
				ToolTipText = ToolTipText .. string.format("{nl}    %s{nl}{s9} {nl} {nl}{/}{#66FF66}{s11}{b}%s{/}{/}{/}", value.Magic , Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.List_Collection"))
				for j, tmpRecord in ipairs(Me.ThisMapInfo.CollectItem[value.ClassID]) do
					local DropText = "";
					if ToolTipR ~= nil then
						-- ToolTipHelper (Rebuild by Toukibi)の検出
						if ToolTipR.ApplicationsList.DropRatio ~= nil then
							-- ドロップ率データの有無を確認
							-- ドロップ率データを取り出してみる
							local MatchList = ToolTipR.ApplicationsList.DropRatio[tmpRecord.ClassName];
							if MatchList ~= nil then
								for i, MatchData in ipairs(MatchList) do
									if MatchData.Rank ~= "BOSS" then
										if MobInfo ~= nil then
											for _, value in pairs(MobInfo) do
												if value.ClassID == MatchData.ClassID then
													local DropRatioText = GetCommaedTextEx(tonumber(MatchData.DropRatio) / 100, 7, 2);
													local MobText = string.format("{img channel_mark_empty 40 4}{s14}{b}%s%s  %s (Lv.%s){/}{/}", DropRatioText, Toukibi:GetResText(ResText, Me.Settings.Lang, "Common.PercentMark"), MatchData.Name, MatchData.Lv);
													DropText = DropText .. "{nl}" .. MobText;
												end
											end
										end
									end
								end
							end
						end
					end
					MaxCount = MaxCount + 1;
					local CheckIcon = "socket_slot_check";
					local TextColor = "#88FFFF";
					if not tmpRecord.isCollected then
						Completed = false;
						ExistsList[tmpRecord.ClassName] = (ExistsList[tmpRecord.ClassName] or 0) + 1
						-- 持っているかを評価する
						local TargetInvData = session.GetInvItemByName(tmpRecord.ClassName);
						if TargetInvData == nil or ExistsList[tmpRecord.ClassName] > TargetInvData.count then
							-- 持っていない
							NotCount = NotCount + 1;
							CheckIcon = "chat_close_btn_clicked";
							TextColor = "#FF8888";
						else
							-- 持っている
							CheckIcon = "channel_mark_empty";
							TextColor = "#FFFFFF";
						end
					end
					ToolTipText = ToolTipText .. string.format("{nl}{img %s 32 32} {img %s 20 20}{%s}{s9} {/}{ol}%s{/}{/}{s36} {/}", tmpRecord.imgName, CheckIcon, TextColor, tmpRecord.Name);
					ToolTipText = ToolTipText .. "{nl}" .. DropText
				end
				if NotCount == 0 then NotCount = nil end
				if Completed then NotCount = -1 end
				objButton = CreateToolButton(pnlBase, "btnBox" .. i, 0, height * ButtonCount, nil, nil, "icon_item_box", NotCount);
				objButton:SetGravity(ui.CENTER_HORZ, ui.TOP);
				objButton:SetTextTooltip(ToolTipText);
				objButton:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_MAPMATE_HIDEMOBLIST");
				ButtonCount = ButtonCount + 1;
			end
		end
	else
		local objButton = CreateToolButton(pnlBase, "btnNPCError"	, 0, height * ButtonCount, nil, nil, "NOTICE_Dm_!")
		objButton:SetTextTooltip("{#AA3333}NPC情報の取得中にエラー発生{nl}" .. NPCInfo)
		ButtonCount = ButtonCount + 1
		Toukibi:AddLog(NPCInfo, "Warning", true, true);
	end
	pnlBase:Resize(ParentWidth , height * ButtonCount);
	MyFrame:Resize(ParentWidth , height * ButtonCount);
	
end

-- MobのToolTipだけ更新する
function Me.UpdateMobToolTip()
	--対象コントロールを探す
	local MyFrame = ui.GetFrame('mapmate');
	if MyFrame == nil then return end
	local pnlBase = GET_CHILD_RECURSIVELY(MyFrame, "btnMOB", "ui::CGroupBox");
	if pnlBase == nil then return end
	local ToolTipText = GetMobListToolTipText();
	if ToolTipText == nil or ToolTipText == "" then return end
	--pnlBase:SetTextTooltip(ToolTipText);
	Toukibi:AddLog("モンスター情報が更新されました", "Info", true, false);
end


-- 宝箱の情報を取得する
local function GetBoxInfo(value)
	local ReturnValue = {};
	local InsideData = Toukibi:Split(value.ArgStr2, ":");
	ReturnValue.Inside = GetClass("Item", InsideData[2]).Name
	ReturnValue.IsCollection = false;
	ReturnValue.IsOpened = false;
	ReturnValue.Registed = false;
	ReturnValue.Lv = 1;
	ReturnValue.Icon = "compen_btn"
	ReturnValue.OpenStateText = ""
	if string.find(string.lower(value.ArgStr2), "collect") then
		-- コレクションボックス
		ReturnValue.IsCollection = true;
		-- すでに取得済みかを調べる
		if #InsideData >= 2 and InsideData[1] == "ITEM" then
			--中身の取得に成功
			if session.GetMySession():GetCollection():Get(GetClass("Collection", InsideData[2]).ClassID) ~= nil then
				-- 登録済
				ReturnValue.Registed = true;
				ReturnValue.Icon = "jour_compen_off";
				ReturnValue.OpenStateText = string.format(" (%s)", Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Registed"));
			end
		end
	else
		local LvNum = string.gsub(value.ArgStr1, "LV", "")
		ReturnValue.Lv = tonumber(LvNum)
	end
	if value.NpcState ~= nil and value.NpcState ~= 0 then
		-- 開封済
		ReturnValue.IsOpened = true;
		ReturnValue.Icon = "M_message_open";
		if ReturnValue.OpenStateText == "" then
			ReturnValue.OpenStateText = string.format(" (%s)", Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Opened"));
		end
	end
	ReturnValue.TextColor = "#44FFFF"
	if ReturnValue.Lv > 1 then
		ReturnValue.TextColor = "#FF8888";
	end
	return ReturnValue;
end

-- Mapにアイコンを追加する
local function AddMMapIcon(Parent, X, Y, Name, Icon, Size)
	Size = Size or 24;
	local objPic = tolua.cast(Parent:CreateOrGetControl("picture", "Toukibi_".. Name, X, Y, Size, Size), "ui::CPicture"); 
	objPic:EnableHitTest(0);
	objPic:ShowWindow(1);
	objPic:SetImage(Icon);
	objPic:SetEnableStretch(1);
	return objPic;
end
-- アイコンに重ねるようにチェックマークを追加する
local function AddRegistedIcon(Parent, X, Y, Name, Size)
	Size = Size or 24;
	local objPic = tolua.cast(Parent:CreateOrGetControl("picture", "Toukibi_".. Name, X - 4, Y - 8, Size * 1.5, Size * 1.5), "ui::CPicture");
	objPic:EnableHitTest(0);
	objPic:SetImage("socket_slot_check");
	objPic:SetEnableStretch(1);
	objPic:ShowWindow(1);
	return objPic;
end
-- アイコンに重ねるように警告マークを追加する
local function AddFakeIcon(Parent, X, Y, Name, Size)
	Size = Size or 24;
	local objPic = tolua.cast(Parent:CreateOrGetControl("picture", "Toukibi_".. Name, X + Size / 6, Y + Size / 6, Size * 1.2, Size * 1.2), "ui::CPicture");
	objPic:EnableHitTest(0);
	objPic:SetImage("NOTICE_Dm_!");
	objPic:SetEnableStretch(1);
	objPic:ShowWindow(1);
	return objPic;
end
-- アイコンの上に宝箱のレベルを表示する
local function AddBoxLevel(Parent, X, Y, Name, Level, IsOpened, TextColor)
	local objText = tolua.cast(Parent:CreateOrGetControl('richtext', "Toukibi_".. Name, X - 8, Y - 24 + 4, 40, 20), "ui::CRichText");
	local OpenStateText = ""
	if IsOpened then
		OpenStateText = Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Opened")
	end
	objText:SetTextAlign("center", "bottom"); 
	objText:SetText("{@st42b}{s12}{" .. TextColor .. "}Lv." .. Level .. "{nl}" ..OpenStateText .. "{/}");
	objText:EnableHitTest(0);
	objText:SetGravity(ui.LEFT, ui.TOP);
	objText:ShowWindow(1);
	return objText;
end
-- 指定したオブジェクトの上にアイコンを描画する
local function DrawIconToObjEx(objTarget, Zoom)
	-- 対象フレームを取得する
	DESTROY_CHILD_BYNAME(objTarget, "Toukibi_");
	local NPCInfo = Me.GetMapNPCInfo()
	for i,value in ipairs(NPCInfo) do
		if value.X ~= nil and value.Y ~= nil then 
			if value.Type == "Box" then
				local BoxInfo = GetBoxInfo(value)
				local XC = math.ceil((value.X +10 ) * Zoom) - 12;
				local YC = math.ceil((value.Y - 8) * Zoom) - 12;
	-- log(string.format("%s (%s, %s)", value.Name, XC, YC))
				local objBoxIcon = AddMMapIcon(objTarget, XC, YC, "BoxIcon_" .. i, BoxInfo.Icon);
				if BoxInfo.IsCollection then
					if BoxInfo.Registed then
						AddRegistedIcon(objTarget, XC, YC, "BoxIcon_Additional_" .. i)
					end
				else
					AddBoxLevel(objTarget, XC, YC, "BoxIcon_BoxLv_" .. i, BoxInfo.Lv, BoxInfo.IsOpened, BoxInfo.TextColor)
				end
				objBoxIcon:SetTooltipType("texthelp");
				objBoxIcon:EnableHitTest(1);
				objBoxIcon:SetTooltipArg(string.format("{@st42b}{%s}%s Lv.%s%s{nl}%s"
													, BoxInfo.TextColor
													, Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.TBox")
													, BoxInfo.Lv
													, BoxInfo.OpenStateText
													, BoxInfo.Inside));
			elseif (value.Type == "NPC" or value.Type == "Arrow" or value.Type == "Statue") and (value.NpcState == nil or value.NpcState == 0) then
				-- まだ会っていないNPC
				local XC = math.ceil((value.X) * Zoom) - 16;
				local YC = math.ceil((value.Y) * Zoom) - 16;
				local objNPCIcon = AddMMapIcon(objTarget, XC, YC, "NPCIcon_" .. i, value.Icon, 30);
				objNPCIcon:SetTooltipType("texthelp");
				objNPCIcon:SetAlpha(50);
				objNPCIcon:EnableHitTest(1);
				objNPCIcon:SetTooltipArg(value.Name);
			end
		end
	end
end
local function ChangeMapIcon(objParent)
	local NPCInfo = Me.GetMapNPCInfo();
	for i,value in ipairs(NPCInfo) do
		if value.Icon == "minimap_indun" then
			local objPic = GET_CHILD(objParent, "_NPC_GEN_" .. value.GenType, 'ui::CPicture');
			objPic:SetImage(value.Icon);
		end
	end
end

-- ミニマップにアイコンを追加する
function Me.DrawMiniMapIconEx()
	-- 対象フレームを取得する
	local Parent = ui.GetFrame('minimap');
	local npcList = Parent:GetChild('npclist')
	local mapZoom = math.abs((GET_MINIMAPSIZE() + 100) / 100); 
	DrawIconToObjEx(npcList, mapZoom)
	ChangeMapIcon(npcList)

	--メインマップにアイコンを追加
	Parent = ui.GetFrame('map');
	local MainMap = Parent:GetChild('map')
	DrawIconToObjEx(MainMap, 1)
	ChangeMapIcon(Parent)
end

-- マップとミニマップにFogを描く
function Me.DrawFog(frame)
	frame = frame or ui.GetFrame('map');
	local mapPic = GET_CHILD(frame, "map", 'ui::CPicture');
	HIDE_CHILD_BYNAME(mapPic, "Toukibi_Fog_");
	if MAP_USE_FOG(Me.ThisMapInfo.MapClassName) == 0 then
		return
	end

	local offsetX = mapPic:GetOffsetX();
	local offsetY = mapPic:GetOffsetY();

	local mapZoom = math.abs((GET_MINIMAPSIZE() + 100) / 100);
	if frame == ui.GetFrame("map") then
		mapZoom = 1;
	end

	local list = session.GetMapFogList(session.GetMapName());
	local cnt = list:Count();
	for i = 0 , cnt - 1 do
		local tile = list:PtrAt(i);

		if tile.revealed == 0 then
			local name = string.format("Toukibi_Fog_%d", i);
			local tilePosX = (tile.x * mapZoom)-- + offsetX;
			local tilePosY = (tile.y * mapZoom)-- + offsetY;
			local tileWidth = math.ceil(tile.w * mapZoom);
			local tileHeight = math.ceil(tile.h * mapZoom);
			local pic = mapPic:CreateOrGetControl("picture", name, tilePosX, tilePosY, tileWidth, tileHeight);
			tolua.cast(pic, "ui::CPicture");
			pic:ShowWindow(1);
			pic:SetImage("fullred");
			pic:SetEnableStretch(1);
			pic:SetAlpha(30);
			pic:EnableHitTest(0);
			if tile.selected == 1 then
				pic:ShowWindow(0);
			end
		end
	end

	frame:Invalidate();
end









-- Map名のラベルを更新
local function UpdatelblMapName()
	local Parent = ui.GetFrame('minimap');
	if Parent == nil then return end
	local lblTarget = GET_CHILD(Parent, "MapMate_MapName", "ui::CRichText");
	if lblTarget ~= nil then
		if not Me.Settings.ShowMapNameOutside then
			lblTarget:ShowWindow(1)
			lblTarget:SetText(string.format("{s14}{ol}%s%s{nl}%s%s{/}{/}"
										  , Me.ThisMapInfo.Stars
										  , Me.ThisMapInfo.strLv
										  , Me.ThisMapInfo.MapSymbol
										  , Me.ThisMapInfo.Name));
		else
			lblTarget:ShowWindow(0)
		end
	end

	local strTemp = "";
	if Me.ThisMapInfo.IESData.isVillage == "YES" then
		strTemp = string.format("{s14}{ol}%s%s [%s]"
							  , Me.ThisMapInfo.MapSymbol
							  , Me.ThisMapInfo.Name
							  , Me.ThisMapInfo.MapClassName);
	else
		strTemp = string.format("{s14}{ol}%s%s{nl}"
							 .. "%s%s [%s]{nl}"
							 .. "{s20}  {/}{img journal_map_icon 16 16}%s:%s{nl}"
							 .. "{s20}  {/}{img icon_item_expcard 16 16}%s: %s{nl}"
							 .. "{s20}  {/}{img channel_mark_empty 16 16}%s: %s{nl}"
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

	--公式対応のMap名をいじる
	local MapNameFrame = ui.GetFrame("mapareatext");
	if MapNameFrame ~= nil then
		lblTarget = GET_CHILD(MapNameFrame, "mapName", "ui::CRichText");
		local AreaText = "";
		if Me.ThisMapInfo.SubAreaName ~= nil and Me.ThisMapInfo.SubAreaName ~= "" then
			AreaText = "{nl}{s4} {nl}{/}   " .. Me.ThisMapInfo.SubAreaName
		else
			AreaText = ""
		end
		lblTarget:Resize(300, 20);
		if Me.Settings.ShowMapNameOutside then
			lblTarget:SetTextByKey('name', string.format("{s14}{ol}%s%s{nl}%s%s{#CCCCCC}%s{/}{/}{/}"
										  , Me.ThisMapInfo.Stars
										  , Me.ThisMapInfo.strLv
										  , Me.ThisMapInfo.MapSymbol
										  , Me.ThisMapInfo.Name
										  , AreaText));
			lblTarget:SetMargin(0, 4, 0, 0);
		else
			lblTarget:SetTextByKey('name', string.format("{s14}{ol}{b}{#CCCCCC}%s{/}{/}{/}{/}"
										  , AreaText));
			lblTarget:SetMargin(0, 0, 0, 0);
		end
		lblTarget:SetTextTooltip(strTemp);
	end
end

-- 探索率を求める
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

-- 接続人数を取得する
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
			--elseif Me.ThisMapInfo.IESData.EliteMobLimitCount > 0 then
			--	Me.ThisMapInfo.MapSymbol = "{img minimap_erosion 14 14}";
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
		local strTemp = "{#663333}" .. Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.Title") .. " : ";
		for w in string.gmatch(strReadData, "%w+") do
			if string.find(w, "gem") then
				strTemp = strTemp .. string.format("{nl}  " .. Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.LostGem"), string.gsub(w, "gem", ""));
			elseif string.find(w, "silver") then
				strTemp = strTemp .. string.format("{nl}  " .. Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.LostSilver"), string.gsub(w, "silver", ""));
			elseif string.find(w, "card") then
				strTemp = strTemp .. string.format("{nl}  " .. Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.LostCard"), string.gsub(w, "card", ""));
			elseif string.find(w, "blessstone") then
				strTemp = strTemp .. string.format("{nl}  " .. Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.LostBlessStone"), string.gsub(w, "blessstone", ""));
			else
				strTemp = strTemp .. string.format("{nl}  %s (%s)", Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.Other"), w)
			end
		end
		strTemp = strTemp .. "{nl}{/}";
		Me.ThisMapInfo.DeathPenaltyText = strTemp;
	else
		Me.ThisMapInfo.DeathPenaltyText = nil
	end
	-- コレクション情報
	Me.ThisMapInfo.CollectionID = {};
	Me.ThisMapInfo.CollectItem = {};
	Me.ThisMapInfo.RegistedItem = {};
	local MapInfo = {};
	MapInfo.Property = geMapTable.GetMapProp(Me.ThisMapInfo.MapClassName);
	MapInfo.ClassList, MapInfo.ClassCount = GetClassList("GenType_" .. Me.ThisMapInfo.MapClassName);
	MapInfo.MonGens = MapInfo.Property.mongens;
	if MapInfo.MonGens == nil then return MapInfo end
	local cnt = MapInfo.MonGens:Count();
	for i = 0 , cnt - 1 do 
		local MonProp = MapInfo.MonGens:Element(i);
		local IESData_GenType = GetClassByIndexFromList(MapInfo.ClassList, i);
	-- log(i .. ":" .. MonProp:GetName() .. ":" .. g.mapNpcState:FindAndGet(MonProp.GenType));
		if string.find(string.lower(IESData_GenType.ClassType),"treasure.*box") and string.find(string.lower(MonProp:GetDialog()),"treasurebox_lv") then
			local InsideData = Toukibi:Split(IESData_GenType.ArgStr2, ":");
			if #InsideData >= 2 and InsideData[1] == "ITEM" and string.find(string.lower(InsideData[2]), "collect") then
				local ItemList = {}
				local clsCollection = GetClass("Collection", InsideData[2]);
				local collectedItemSet = {};
				local Index = 1;
				local objSessionCollection = session.GetMySession():GetCollection():Get(GetClass("Collection", InsideData[2]).ClassID);
				while clsCollection ~= nil do
					local itemName = TryGetProp(clsCollection, "ItemName_" .. Index);
					if itemName == nil or itemName == "None" then break end
					local itemCls = GetClass("Item", itemName);
					local currentInfo = nil;
					if objSessionCollection ~= nil then
						currentInfo = GET_COLLECTION_DETAIL_ITEM_INFO(objSessionCollection, itemCls , collectedItemSet);
					end
					local itemData = {};
					itemData.Name = itemCls.Name;
					itemData.ClassName = itemCls.ClassName;
					itemData.imgName = GET_ITEM_ICON_IMAGE(itemCls);
					if currentInfo ~= nil then
						itemData.isCollected = currentInfo.isCollected;
					else
						itemData.isCollected = false;
					end
					table.insert(ItemList, itemData);
					Index = Index + 1;
				end
				local MagicText = "";
				local MagicListInfo = geCollectionTable.Get(clsCollection.ClassID);
				local MagicCount = MagicListInfo:GetPropCount();
				local isForAccount = false;
				if 0 == MagicCount then
					MagicCount = MagicListInfo:GetAccPropCount();
					isForAccount = true;
				end
				for i = 0 , MagicCount - 1 do
					local objMagicItem = nil;
					if false == isForAccount then
						objMagicItem = MagicListInfo:GetProp(i);
					else
						objMagicItem = MagicListInfo:GetAccProp(i);
					end

					if objMagicItem ~= nil then
						if string.len(MagicText) > 0 then
							MagicText = MagicText .. ", "
						end
						MagicText = MagicText .. ClMsg(objMagicItem:GetPropName()) .. string.format(" %+d", objMagicItem.value);
					end
				end
				table.insert(Me.ThisMapInfo.CollectionID, {	ClassID = InsideData[2],
															Name = clsCollection.Name,
															Magic = MagicText});
				
				--??ClMsg(geCollectionTable.Get(255):GetAccProp(0):GetPropName())
				Me.ThisMapInfo.CollectItem[InsideData[2]] = ItemList;
			end
		end
	end

	--view(Me.ThisMapInfo)
	UpdatelblMapName();
end

-- NPC情報
function Me.GetMapNPCInfo(MapClassName)
	-- session.GetMapNPCState(session.GetMapName()):FindAndGet(GenType)
	-- で会ったかどうかがわかる(0かnil:まだ  それ以外:話した・開けた事がある)
	--if ui.GetFrame("loadingbg") ~= nil then return nil end
	MapClassName = MapClassName or session.GetMapName();
	if MapClassName == nil or MapClassName == "" or MapClassName == "None" then return end

	local MapInfo = {};
	MapInfo.ClassName = MapClassName;
	local myColls = session.GetMySession():GetCollection();
	
	-- 2019/3/13のIToSのアップデートで取得方法が変更
	local status, ResultValue = pcall(session.GetMapNPCState, MapInfo.ClassName);
	local UseOldMethod = false;
	if status then
		-- 変更前
		UseOldMethod = true;
		MapInfo.NpcState = ResultValue;
	else
		-- 変更後
		UseOldMethod = false;
		MapInfo.NpcState = nil;
	end

	MapInfo.Property = geMapTable.GetMapProp(MapInfo.ClassName);
	
	MapInfo.ClassList, MapInfo.ClassCount = GetClassList("GenType_" .. MapInfo.ClassName);
	MapInfo.MonGens = MapInfo.Property.mongens;
	if MapInfo.MonGens == nil then return MapInfo end

	local NoMeetNPC = {};
	local cnt = MapInfo.MonGens:Count();
	for i = 0 , cnt - 1 do 
		local MonProp = MapInfo.MonGens:Element(i);
		local IESData_GenType = GetClassByIndexFromList(MapInfo.ClassList, i);
		-- if string.find(string.lower(MonProp:GetDialog()),"treasurebox") then
		if (IESData_GenType.Faction == "Neutral" and IESData_GenType.Minimap > 0 and string.find(string.lower(IESData_GenType.ClassType),"hidden") == nil and string.find(string.lower(IESData_GenType.ClassType),"trigger") == nil and string.find(string.lower(IESData_GenType.Name),"visible") == nil and string.find(string.lower(IESData_GenType.Name),"none") == nil) or string.find(string.lower(IESData_GenType.ClassType),"treasure.*box") then

		--log(string.format("[%s]%s (%s)", IESData_GenType.GenType, IESData_GenType.Name, IESData_GenType.Minimap))
			local NPCType = "NPC"

			-- 2019/3/13のIToSのアップデートで取得方法が変更
			local NpcState = 0;
			if UseOldMethod then
				-- 変更前
				NpcState = MapInfo.NpcState:FindAndGet(IESData_GenType.GenType);
			else
				-- 変更後
				NpcState = GetNPCState(MapInfo.ClassName, IESData_GenType.GenType);
			end

			if string.find(string.lower(IESData_GenType.ClassType),"statue_zemina") then
				NPCType = "Statue"
			elseif string.find(string.lower(IESData_GenType.ClassType),"statue_vakarine") then
				-- ヴァカリネ像(ワープ)
				NPCType = "Statue"
				NpcState = 0;
				local sObj_main = GET_MAIN_SOBJ();
				if sObj_main ~= nil then
					local gentype_classcount = GetClassCount('camp_warp')
					if gentype_classcount > 0 then
						for i = 0 , gentype_classcount - 1 do
							local cls = GetClassByIndex('camp_warp', i);
							if cls.Zone == MapClassName then
								-- 該当データ発見
								if sObj_main[cls.ClassName] == 300 then
									-- ヴァカリネ像は会っただけで祈ったことにしておく
									NpcState = 20;
								else
									NpcState = 0;
								end
								break;
							end
						end
						--log(NpcState)
					end
				end
			elseif string.find(string.lower(IESData_GenType.ClassType),"warp_arrow") then
				NPCType = "Arrow"
			elseif string.find(string.lower(IESData_GenType.ClassType),"treasure.*box") then
				if string.find(string.lower(MonProp:GetDialog()),"treasurebox_lv") then
					NPCType = "Box"
				else
					NPCType = "Fake"
				end
			end
			local IconText = MonProp:GetMinimapIcon()
	--log(string.format("[icon_%s]:%s", IESData_GenType.GenType, IconText))
			if string.find(string.lower(IESData_GenType.ClassType),"id_gate_npc") then
				IconText = "minimap_indun"
			elseif IconText == nil or IconText == "None" then
				IconText = "minimap_0"
			end
	--log(string.format( "%s (%s)(%s)", IESData_GenType.Name, IESData_GenType.ClassType, IESData_GenType.Minimap))
			local GenList = MonProp.GenList;
			local MapPos;
			if GenList:Count() > 0 then
				MapPos = MapInfo.Property:WorldPosToMinimapPos(GenList:Element(0), m_mapWidth, m_mapHeight);
			else
				MapPos = {};
				MapPos.x = nil
				MapPos.y = nil
			end
	--log(string.format("[%s](%s) %s (%s)", IESData_GenType.GenType, tostring(NpcState), IESData_GenType.Name, NPCType))
			table.insert(NoMeetNPC, {
				Name = IESData_GenType.Name -- .. "(" .. IESData_GenType.ClassType .. ")"
				, NpcState = NpcState
				, Type = NPCType
				, ClassID = IESData_GenType.ClassID
				, ClassName = IESData_GenType.ClassType
				, GenType = IESData_GenType.GenType
				, Hide = IESData_GenType.Hide
				, Dialog = IESData_GenType.Dialog
				, ArgStr1 = IESData_GenType.ArgStr1
				, ArgStr2 = IESData_GenType.ArgStr2
				, ArgStr3 = IESData_GenType.ArgStr3
				, X = MapPos.x
				, Y = MapPos.y
				, Icon = IconText
			});
		end
	end
	-- view(NoMeetNPC)
	return NoMeetNPC;
	-- return MapInfo
end

-- モンスター情報
function Me.GetMapMonsterInfo(MapClassName)

	--if ui.GetFrame("loadingbg") ~= nil then return nil end
	MapClassName = MapClassName or session.GetMapName();
	if MapClassName == nil or MapClassName == "" or MapClassName == "None" then return end
	local MapInfo = {};
	MapInfo.ClassName = MapClassName;
	local myColls = session.GetMySession():GetCollection();
	-- MapInfo.Collection = 
	MapInfo.Property = geMapTable.GetMapProp(MapInfo.ClassName);
	
	MapInfo.ClassList, MapInfo.ClassCount = GetClassList("GenType_" .. MapInfo.ClassName);
	MapInfo.MonGens = MapInfo.Property.mongens;
	if MapInfo.MonGens == nil then return MapInfo end

	local MobList = {};
	local cnt = MapInfo.MonGens:Count();
	for i = 0 , cnt - 1 do 
		local MonProp = MapInfo.MonGens:Element(i);
		local IESData_GenType = GetClassByIndexFromList(MapInfo.ClassList, i);
	-- log(string.format("%s : [%s] %s", i, IESData_GenType.Faction, IESData_GenType.ClassType))
		if IESData_GenType.Faction == "Monster" and string.find(string.lower(IESData_GenType.ClassType),"hidden") == nil and string.find(string.lower(IESData_GenType.ClassType),"trigger") == nil then
			local MobClass = GetClass("Monster", IESData_GenType.ClassType)
			if MobList[IESData_GenType.ClassType] == nil then
	-- log(string.format("%s : %s (%s)", MobClass.ClassID, MobClass.Name, MobClass.MonRank))
				local pKillCount = 0;
				local pRequired = 0;
				if FunctionExists(GetMonKillCount) then
					-- 新方式(20170926～)
					pKillCount = GetMonKillCount(nil, MobClass.ClassID)
					-- pKillCount = ADVENTURE_BOOK_MONSTER_CONTENT.MONSTER_KILL_COUNT(MobClass.ClassID)
					local MonGrade = 'BASIC'
					if MobClass.MonRank == 'Boss' then
						MonGrade = 'BOSS'
					end
		-- log(GetClass('AdventureBookConst', MonGrade .. '_MON_GRADE_COUNT').Value)
					pRequired = GetClass('AdventureBookConst', MonGrade .. '_MON_KILL_COUNT_GRADE' .. GetClass('AdventureBookConst', MonGrade .. '_MON_GRADE_COUNT').Value).Value
				elseif FunctionExists(GetWikiByName) then
					-- 旧方式(～20170926)
					local wiki = GetWikiByName(MobClass.Journal);
					if wiki ~= nil then
						pKillCount =GetWikiIntProp(wiki, "KillCount")
					end
					if GetClass('Journal_monkill_reward', MobClass.Journal) ~= nil then
						pRequired = GetClass('Journal_monkill_reward', MobClass.Journal).Count1
					end
				else
					-- 関数が取れなかった場合
					pKillCount = 0;
					pRequired = 0;
				end
	-- log(string.format("%s : [%s] Lv.%s %s (%s)", i, IESData_GenType.GenType, MobClass.Level, MobClass.Name, IESData_GenType.ClassType))
	-- log(SCR_Get_MON_INT(MobClass))
				MobList[IESData_GenType.ClassType] = {
					  Name = dictionary.ReplaceDicIDInCompStr(MobClass.Name)
					, ClassID = MobClass.ClassID
					, JournalID = MobClass.Journal
					, Lv = MobClass.Level
					, Attribute = MobClass.Attribute
					, Type = MobClass.RaceType
					, Armor = MobClass.ArmorMaterial
					, MoveType = MobClass.MoveType
					, Size = MobClass.Size
					, Icon = MobClass.Icon
					, Rank = MobClass.MonRank
					, MaxNum = 0
					, ClassName = IESData_GenType.ClassType
					, ArgStr1 = IESData_GenType.ArgStr1
					, ArgStr2 = IESData_GenType.ArgStr2
					, ArgStr3 = IESData_GenType.ArgStr3
					, KillCount = pKillCount
					, KillRequired = pRequired
				};
			end
			MobList[IESData_GenType.ClassType].MaxNum = MobList[IESData_GenType.ClassType].MaxNum + IESData_GenType.MaxPop
			if MobList[IESData_GenType.ClassType].PopData == nil then
				MobList[IESData_GenType.ClassType].PopData = {}
			end
			local AreaType = ((IESData_GenType.GenRange == 9999) and 1) or 2;
			if MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)] == nil then
				MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)] = {}
				MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)].PopTime = IESData_GenType.RespawnTime
				MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][0] = 0
				MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][1] = 0
				MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][2] = 0
			end
			MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][0] = MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][0] + IESData_GenType.MaxPop
			MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][AreaType] = MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][AreaType] + IESData_GenType.MaxPop
		end
	end
	-- view(MobList)
	return MobList
end

-- クエスト情報
function Me.GetMapQuestInfo(MapClassName)
	MapClassName = MapClassName or session.GetMapName();
	local QuestInfo = {};
	local pc = GetMyPCObject();
	local questClsList, questCnt = GetClassList('QuestProgressCheck');
	for index = 0, questCnt-1 do
		local questIES = GetClassByIndexFromList(questClsList, index);
		if questIES.StartMap == MapClassName
				and questIES.PossibleUI_Notify ~= 'NO'
				and questIES.QuestMode ~= 'KEYITEM'
				and questIES.Level ~= 9999
				and questIES.Lvup ~= -9999
				and questIES.QuestStartMode ~= 'NPCENTER_HIDE'
				and questIES.QuestMode ~= "PARTY"
				and string.find(questIES.ClassName, 'JOB_') ~= 1
				and string.find(questIES.ClassName, 'EV_') ~= 1
				and string.find(questIES.ClassName, 'TUTO_.*_TECH') ~= 1
				then

			local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName)
			if result ~= "COMPLETE" then
				local ModeNo = 2;
				local ColorStyle = {"@st70_s"};
				if questIES.QuestMode == "REPEAT" then
					ColorStyle = {"@st70_d"};
					ModeNo = 3;
				elseif questIES.QuestMode == "MAIN" then
					ColorStyle = {"@st70_m"};
					ModeNo = 1;
				end
				if result == "IMPOSSIBLE" then
					ColorStyle = {"ol", "s14", "#101010"};
					ModeNo = ModeNo * -1;
				end
				local strState = "";
				if result == "PROGRESS" then
					strState = Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.InProgress"), {"s12", "ol"});
				elseif result == "SUCCESS" then
					strState = Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.Complete"), {"s12", "ol"});
				end
				table.insert(QuestInfo, { ModeNo = ModeNo
										, Name = dictionary.ReplaceDicIDInCompStr(questIES.Name)
										, Text =  string.format("{img %s 24 24}%s{s6} {/}%s"
												, GET_QUESTINFOSET_ICON_BY_STATE_MODE("POSSIBLE", questIES)
												, Toukibi:GetStyledText(dictionary.ReplaceDicIDInCompStr(questIES.Name), ColorStyle)
												, strState)
										}
							);
			end
		end
	end
	if #QuestInfo > 0 then
		table.sort(QuestInfo, function(a, b)
			if a.ModeNo ~= b.ModeNo then
				return a.ModeNo < b.ModeNo
			else
				return a.Name < b.Name
			end
		end)
	end
	-- view(QuestInfo)
	return QuestInfo;
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
		Me.ThisMapInfo.FogRevealRate = string.format("{s14}{ol}%s%.1f%s{/}{/}"
													,CompSymbol
													,CompRate
													,Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.PercentChar"));
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

	if Me.Settings ~= nil and Me.Settings.UseServerClock == false and Me.Settings.DisplaySec == true then
		Me.UpdateOnlyLocalTime();
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

-- MapMateMobを呼び出す
function TOUKIBI_MAPMATE_SHOWMOBLIST()
	TOUKIBI_MAPMATEMOB_CALLPOPUP()
end
function TOUKIBI_MAPMATE_HIDEMOBLIST()
	TOUKIBI_MAPMATEMOB_CALLHIDE()
end

-- ***** コンテキストメニューを作成する *****

-- 接続人数更新設定のコンテキストメニュー
function TOUKIBI_MAPMATE_CONTEXT_MENU_PCCOUNT(frame, ctrl)
	local Title = string.format("%s{nl}%s"
							  , Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Title")
							  , Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.TitleNotice")
							  );
	local context = ui.CreateContextMenu("MAPMATE_PCCOUNT_RBTN", Title, 0, 0, 320, 0);
	Toukibi:MakeCMenuSeparator(context, 300);
	Toukibi:MakeCMenuItem(context, string.format("{#FFFF88}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.UpdateNow")), "TOUKIBI_MAPMATE_EXEC_PCCUPDATE()", nil, nil);
	Toukibi:MakeCMenuSeparator(context, 300.1, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdate_Title"));
	Toukibi:MakeCMenuItem(context
						, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateBySeconds"), 10)
						, "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(10)"
						, nil
						, Me.Settings.UpdatePCCountInterval == 10);
	Toukibi:MakeCMenuItem(context
						, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateBySeconds"), 20)
						, "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(20)"
						, nil
						, Me.Settings.UpdatePCCountInterval == 20);
	Toukibi:MakeCMenuItem(context
						, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateBySeconds"), 30)
						, "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(30)"
						, nil
						, Me.Settings.UpdatePCCountInterval == 30);
	Toukibi:MakeCMenuItem(context
						, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateByMinutes"), 1)
						, "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(60)"
						, nil
						, Me.Settings.UpdatePCCountInterval == 60);
	Toukibi:MakeCMenuItem(context
						, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateByMinutes"), 3)
						, "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(180)"
						, nil
						, Me.Settings.UpdatePCCountInterval == 180);
	Toukibi:MakeCMenuItem(context
						, string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateByMinutes"), 5)
						, "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(300)"
						, nil
						, Me.Settings.UpdatePCCountInterval == 300);
	Toukibi:MakeCMenuItem(context
						, string.format("{#8888FF}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.NoAutoUpdate"))
						, "TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(nil)"
						, nil
						, Me.Settings.UpdatePCCountInterval == nil);
	Toukibi:MakeCMenuSeparator(context, 300.2);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ManuallyUpdate"), "TOUKIBI_MAPMATE_TOGGLEPROP('EnableOneClickPCCUpdate')", nil, Me.Settings.EnableOneClickPCCUpdate);
	Toukibi:MakeCMenuItem(context, string.format("{#8888FF}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ContinuousUpdatePrevention")), "TOUKIBI_MAPMATE_TOGGLEPROP('UsePCCountSafety')", nil, Me.Settings.UsePCCountSafety);
	Toukibi:MakeCMenuSeparator(context, 300.3);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ShowMapNameOutside"), "TOUKIBI_MAPMATE_TOGGLEPROP('ShowMapNameOutside')", nil, Me.Settings.ShowMapNameOutside);
	Toukibi:MakeCMenuSeparator(context, 300.4);
	Toukibi:MakeCMenuItem(context, string.format("{#666666}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Close")));
	context:Resize(330, context:GetHeight());
	ui.OpenContextMenu(context);
	return context;
end

-- 時計設定のコンテキストメニュー
function TOUKIBI_MAPMATE_CONTEXT_MENU_CLOCK(frame, ctrl)
	local Title = Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.Title");
	local context = ui.CreateContextMenu("MAPMATE_CLOCK_RBTN", Title, 0, 0, 320, 0);
	Toukibi:MakeCMenuSeparator(context, 300, Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.Clock_Title"));
	Toukibi:MakeCMenuItem(context
						, Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.ServerTime")
						, "TOUKIBI_MAPMATE_CHANGEPROP('UseServerClock', true)"
						, nil
						, Me.Settings.UseServerClock);
	Toukibi:MakeCMenuItem(context
						, Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.LocalTime")
						, "TOUKIBI_MAPMATE_CHANGEPROP('UseServerClock', false)"
						, nil
						, not Me.Settings.UseServerClock);
	Toukibi:MakeCMenuSeparator(context, 300.1, Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.ampm_Title"));
	Toukibi:MakeCMenuItem(context
						, Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.ampm")
						, "TOUKIBI_MAPMATE_CHANGEPROP('UseAMPM', true)"
						, nil
						, Me.Settings.UseAMPM);
	Toukibi:MakeCMenuItem(context
						, Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.Noampm")
						, "TOUKIBI_MAPMATE_CHANGEPROP('UseAMPM', false)"
						, nil
						, not Me.Settings.UseAMPM);
	Toukibi:MakeCMenuSeparator(context, 300.2);
	Toukibi:MakeCMenuItem(context
						, Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.DisplaySec")
						, "TOUKIBI_MAPMATE_TOGGLEPROP('DisplaySec')"
						, nil
						, Me.Settings.DisplaySec);
	-- 閉じる
	Toukibi:MakeCMenuSeparator(context, 300.3);
	Toukibi:MakeCMenuItem(context, string.format("{#666666}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Close")));
	context:Resize(330, context:GetHeight());
	ui.OpenContextMenu(context);
	return context;
end

-- クエスト表示のコンテキストメニュー
function TOUKIBI_MAPMATE_CONTEXT_MENU_QUEST(frame, ctrl)
	local Title = Toukibi:GetResText(ResText, Me.Settings.Lang, "QuestMenu.Title");
	local context = ui.CreateContextMenu("MAPMATE_QUEST_RBTN", Title, 0, 0, 320, 0);
	Toukibi:MakeCMenuSeparator(context, 300);
	Toukibi:MakeCMenuItem(context
						, Toukibi:GetResText(ResText, Me.Settings.Lang, "QuestMenu.DisplayImpossibleQuest")
						, "TOUKIBI_MAPMATE_TOGGLEPROP_WITH_UPDATE('DisplayImpossibleQuest')"
						, nil
						, Me.Settings.DisplayImpossibleQuest);
	Toukibi:MakeCMenuSeparator(context, 300.1, Toukibi:GetResText(ResText, Me.Settings.Lang, "QuestMenu.CountTitle"));
	Toukibi:MakeCMenuItem(context
						, Toukibi:GetResText(ResText, Me.Settings.Lang, "QuestMenu.CountPossible")
						, "TOUKIBI_MAPMATE_CHANGEPROP_WITH_UPDATE('QuestBadge_DisplayAll', false)"
						, nil
						, not Me.Settings.QuestBadge_DisplayAll);
	Toukibi:MakeCMenuItem(context
						, Toukibi:GetResText(ResText, Me.Settings.Lang, "QuestMenu.CountAll")
						, "TOUKIBI_MAPMATE_CHANGEPROP_WITH_UPDATE('QuestBadge_DisplayAll', true)"
						, nil
						, Me.Settings.QuestBadge_DisplayAll);

	-- 閉じる
	Toukibi:MakeCMenuSeparator(context, 300.2);
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
	Me.UpdateOnlyLocalTime()
end

function TOUKIBI_MAPMATE_TOGGLEPROP_WITH_UPDATE(Name, Value)
	if Name == nil then return end
	if Me.Settings == nil then return end
	if Value == "nil" or type(Value) ~= "boolean" then
		Me.Settings[Name] = not Me.Settings[Name];
	else
		Me.Settings[Name] = Value;
	end
	SaveSetting();
	Me.CustomizeMiniMap()
end

function TOUKIBI_MAPMATE_CHANGEPROP(Name, Value)
	if Name == nil then return end
	if Me.Settings == nil then return end
	if Value == "nil" then Value = nil end
	Me.Settings[Name] = Value
	SaveSetting();
	Me.UpdateClock();
end

function TOUKIBI_MAPMATE_CHANGEPROP_WITH_UPDATE(Name, Value)
	if Name == nil then return end
	if Me.Settings == nil then return end
	if Value == "nil" then Value = nil end
	Me.Settings[Name] = Value
	SaveSetting();
	Me.CustomizeMiniMap();
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
	lblMapName:SetTextFixWidth(1);
	lblMapName:SetTextMaxWidth(200);
	lblMapName:EnableHitTest(1);
	lblMapName:SetText(" ");
	lblMapName:ShowWindow(1);
	-- 走破率
	local pleft = 0;
	local pTop = 0;
	if CHSURF_CREATE_BUTTONS ~= nil then
		-- channelsurfer検知
		pleft = 70;
		pTop = 5;
	end
	local lblFogRate = tolua.cast(Parent:CreateOrGetControl("richtext", "MapMate_FogRate", 0, 0, 80, 20), "ui::CRichText");
	lblFogRate:SetGravity(ui.RIGHT, ui.TOP);
	lblFogRate:SetMargin(pleft + 4, pTop + 4, 4, 0);
	lblFogRate:EnableHitTest(0);
	lblFogRate:SetText(" ");
	lblFogRate:ShowWindow(0);

	local lblPCCount = tolua.cast(Parent:CreateOrGetControl("richtext", "MapMate_PCCount", 0, 0, 200, 20), "ui::CRichText");
	lblPCCount:SetGravity(ui.RIGHT, ui.BOTTOM);
	lblPCCount:SetMargin(0, 0, 8, 20);
	lblPCCount:EnableHitTest(1);
	lblPCCount:SetText("{img minimap_0_old 16 16}{s14}{ol}--{/}{/}");

	local lblPCCountRemainingTime = tolua.cast(Parent:CreateOrGetControl("richtext", "MapMate_PCCountRemainingTime", 0, 0, 200, 20), "ui::CRichText");
	lblPCCountRemainingTime:SetGravity(ui.RIGHT, ui.BOTTOM);
	lblPCCountRemainingTime:SetMargin(0, 0, 46, 20);
	lblPCCountRemainingTime:EnableHitTest(1);
	lblPCCountRemainingTime:SetText("{#888888}{s8}{ol}--{/}{/}{/}");

	lblMapName:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_PCCOUNT');
	lblPCCount:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_PCCOUNT');
	lblPCCountRemainingTime:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_PCCOUNT');
	lblPCCount:SetEventScript(ui.LBUTTONDOWN, 'TOUKIBI_LBLPCCOUNT_CLICKED');
	lblPCCountRemainingTime:SetEventScript(ui.LBUTTONDOWN, 'TOUKIBI_LBLPCCOUNT_CLICKED');
	local clock = ui.GetFrame('time');
	if clock ~= nil then
		local timeRichText = tolua.cast(clock:GetChild("timeText"), "ui::CRichText");
		local ampmRichText = tolua.cast(clock:GetChild("ampmText"), "ui::CRichText");
		timeRichText:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_CLOCK');
		timeRichText:EnableHitTest(1);
		ampmRichText:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_CLOCK');
		ampmRichText:EnableHitTest(1);
	end
	local MapNameFrame = ui.GetFrame("mapareatext");
	MapNameFrame:ShowWindow(1);
	GET_CHILD(MapNameFrame, "mapname", "ui::CRichText"):SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_PCCOUNT');

end

-- コントロールを移動する
local function ChangeMiniMapControl()
	local strTemp = "";
	local Parent = ui.GetFrame('minimap');
	local TargetControl = GET_CHILD(Parent, "ZOOM_OUT", "ui::CButton");
	if TargetControl ~= nil then
		TargetControl:SetGravity(ui.RIGHT, ui.BOTTOM);
		TargetControl:SetMargin(0, 0, 2, 2);
		TargetControl:Resize(30, 24);
	end

	TargetControl = GET_CHILD(Parent, "ZOOM_IN", "ui::CButton");
	if TargetControl ~= nil then
		TargetControl:SetGravity(ui.RIGHT, ui.BOTTOM);
		TargetControl:SetMargin(0, 0, 2, 24);
		TargetControl:Resize(30, 24);
	end

	TargetControl = GET_CHILD(Parent, "open_map", "ui::CButton");
	if TargetControl ~= nil then
		TargetControl:SetGravity(ui.RIGHT, ui.TOP);
		TargetControl:SetMargin(0, 0, 2, 0);
		TargetControl:Resize(30, 30);
	end

	TargetControl = GET_CHILD(Parent, "ZOOM_INFO", "ui::CRichText");
	if TargetControl ~= nil then
		TargetControl:SetGravity(ui.RIGHT, ui.TOP);
		TargetControl:SetMargin(0, 4, 36, 0);
	end

	local tmpRight = Parent:GetMargin().right + 0;
	local tmpTop = Parent:GetMargin().top + Parent:GetHeight() - 24 - 2;
	local TimeParent = ui.GetFrame('time');
	TimeParent:SetGravity(ui.RIGHT, ui.TOP);
	TimeParent:SetMargin(0, tmpTop, tmpRight, 0);
	TimeParent:Resize(100, 24);

	TargetControl = GET_CHILD(TimeParent, "ampmText", "ui::CRichText");
	if TargetControl ~= nil then
		TargetControl:SetGravity(ui.RIGHT, ui.BOTTOM);
		TargetControl:SetMargin(0, 0, 4, 0);
		TargetControl:Resize(30, 16);
		TargetControl:SetFormat("{s13}{ol}%s{/}");
		strTemp = TargetControl:GetTextByKey("ampm");
		TargetControl:SetTextByKey("ampm", " ");
		TargetControl:SetTextByKey("ampm", strTemp);
		TargetControl:ShowWindow(0);
	end

	TargetControl = GET_CHILD(TimeParent, "timeText", "ui::CRichText");
	if TargetControl ~= nil then
		TargetControl:SetGravity(ui.RIGHT, ui.BOTTOM);
		TargetControl:Resize(80, 25);
		TargetControl:SetMargin(0, 0, 4, 0);
		TargetControl:SetTextAlign("right", "bottom");
		TargetControl:SetFormat("{s14}{ol}%s:%s{/}");
		strTemp = TargetControl:GetTextByKey("hour");
		TargetControl:SetTextByKey("hour", " ");
		TargetControl:SetTextByKey("hour", strTemp);
	end

	local MyFrame = ui.GetFrame("mapmate")
	MyFrame:SetGravity(ui.RIGHT, ui.TOP);
	MyFrame:SetMargin(0, Parent:GetMargin().top, 4, 0);
	MyFrame:ShowWindow(1);

	local MapNameFrame = ui.GetFrame("mapareatext");
	MapNameFrame:ShowWindow(1);
	GET_CHILD(MapNameFrame, "areaname", "ui::CRichText"):ShowWindow(0);
	TargetControl = GET_CHILD(MapNameFrame, "mapName", "ui::CRichText");
	if TargetControl ~= nil then
		TargetControl:SetGravity(ui.LEFT, ui.TOP);
		TargetControl:SetMargin(0, 0, 0, 0);
		TargetControl:EnableHitTest(1)
		TargetControl:SetTextFixWidth(1);
		TargetControl:SetTextMaxWidth(300);
	end

end

function Me.CustomizeMiniMap()
	ChangeMiniMapControl()
	AddControlToMiniMap()
	Me.lblFogRateHideTimer = nil;
	try(Me.UpdateMapInfo);
	Me.UpdateFogRevealRate();
	UpdatelblPCCount();
	Me.PCCountRemainingTime = 3 * Me.BrinkRadix;
	TOUKIBI_MAPMATE_TIMER_PCCOUNT_START();
	Me.UpdateClock();
	try(Me.DrawMiniMapIconEx)
	try(Me.UpdateFrame)
	try(Me.DrawFog, ui.GetFrame('map'))
	try(Me.DrawFog, ui.GetFrame('minimap'))
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

function TOUKIBI_MAPMATE_UPDATE_MAINFRAME(frame)
	Me.DrawMiniMapIconEx()
	Me.UpdateFrame()
end

function Me.MINIMAP_CHAR_UDT_HOOKED(frame, msg, argStr, argNum)
	Me.HoockedOrigProc["MINIMAP_CHAR_UDT"](frame, msg, argStr, argNum);
	--CHAT_SYSTEM("MINIMAP_CHAR_UDT_HOOKED")
	if ui.GetFrame("loadingbg") ~= nil then return end
	Me.UpdateFogRevealRate()
	Me.DrawFog(ui.GetFrame('map'))
	Me.DrawFog(ui.GetFrame('minimap'))
end

function Me.UPDATE_MINIMAP_HOOKED(frame, isFirst)
	Me.HoockedOrigProc["UPDATE_MINIMAP"](frame, isFirst);
	Me.DrawMiniMapIconEx()
end

function Me.MAP_OPEN_HOOKED(frame)
	Me.HoockedOrigProc["MAP_OPEN"](frame);
	Me.DrawMiniMapIconEx();
	Me.DrawFog(ui.GetFrame('map'));
end

function Me.ON_MAP_AREA_TEXT_HOOKED(frame, msg, name, range)
	--Me.HoockedOrigProc["ON_MAP_AREA_TEXT"](frame, msg, argStr, argNum);
	Me.ThisMapInfo = Me.ThisMapInfo or {};
	Me.ThisMapInfo.SubAreaName = name;
	UpdatelblMapName()
end

function Me.TARGETINFO_ON_MSG_HOOKED(frame, msg, argStr, argNum)
	Me.HoockedOrigProc["TARGETINFO_ON_MSG"](frame, msg, argStr, argNum);
	log("TARGETINFO_ON_MSG")
	if frame == nil then
		log("nil")
		return;
	end
	log(frame:GetName())
end

function Me.TGTINFO_TARGET_SET_HOOKED(frame, msg, argStr, argNum)
	Me.HoockedOrigProc["TGTINFO_TARGET_SET"](frame, msg, argStr, argNum);
	log("TGTINFO_TARGET_SET")
	log(argStr)
end

local function GetTimeTipString(Title, pHour, pMin, UseAMPM)
	local ampmText;
	if UseAMPM ~= false then
		if pHour >= 12 then
			pHour = pHour - 12;
			ampmText = "pm";
		else
			ampmText = "am";
		end
		if pHour == 0 then
			pHour = 12;
		end
	else
		ampmText = "";
	end
	return string.format("%s : {s16}%s {/}{s20}%s:%s{/}"
						,Title
						,ampmText
						,string.format("%02d", pHour)
						,string.format("%02d", pMin));
end

-- 時刻を秒付きで表示させる
function Me.SetTimeEx(pHour, pMin, pSec)
	local clock = ui.GetFrame('time');
	if clock == nil then return end

	if type(pSec) == "number" and Me.Settings.DisplaySec then
		pSec = ":" .. string.format("%02d", pSec);
	else
		pSec = "";
	end
	-- AMPM法を適用
	local ampmText = "";
	if Me.Settings == nil or Me.Settings.UseAMPM == nil or Me.Settings.UseAMPM then
		if pHour >= 12 then
			pHour = pHour - 12;
			ampmText = "pm";
		else
			ampmText = "am";
		end
		if pHour == 0 then
			pHour = 12;
		end
	end
	if ampmText ~= "" then ampmText = "{s4} {/}{s13}" .. ampmText .. "{/}" end
	local timeRichText = tolua.cast(clock:GetChild("timeText"), "ui::CRichText");
	timeRichText:SetTextByKey("hour"  , " ");
	timeRichText:SetTextByKey("hour"  , string.format("%02d", pHour));
	timeRichText:SetTextByKey("minute", string.format("%02d%s%s", pMin, pSec, ampmText));
	local ampmRichText = tolua.cast(clock:GetChild("ampmText"), "ui::CRichText");
	ampmRichText:SetTextByKey("ampm", " ");
end

-- 時刻表示を編集する
function Me.UpdateClock(frame, msg, argStr, argNum)
	-- Me.HoockedOrigProc["TIEM_ON_MSG"](frame, msg, argStr, argNum);
	-- argNum を使う場合はこう書く
	-- local hour = math.floor(argNum / 100)
	-- local minNum = argNum % 100;

	local clock = ui.GetFrame('time');
	if clock ~= nil then
		local timeRichText = tolua.cast(clock:GetChild("timeText"), "ui::CRichText");
		local ampmRichText = tolua.cast(clock:GetChild("ampmText"), "ui::CRichText");
		local ampmText;
		local hourNum;
		local minNum;
		local secNum = nil;
		local tipText

		--サーバー時刻を直接取る
		local Clock_s = geTime.GetServerSystemTime();
		local hourNum_s = Clock_s.wHour;
		local minNum_s = Clock_s.wMinute;
		--ローカル時刻を取る
		local Clock_l = os.date("*t");
		local hourNum_l = Clock_l.hour;
		local minNum_l = Clock_l.min;
		if Me.Settings == nil or Me.Settings.UseServerClock == nil or Me.Settings.UseServerClock then
			--サーバー時刻を選択
			hourNum = hourNum_s;
			minNum = minNum_s;
			timeRichText:SetFormat("{s14}{ol}%s:%s{/}{/}");
			ampmRichText:SetFormat("{s13}{ol}%s{/}{/}");
			tipText = GetTimeTipString(Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.LocalTimeFull")
									 , hourNum_l, minNum_l, Me.Settings.UseAMPM);
			tipText = "{#66FFFF}" .. tipText .. "{/}"
		else
			hourNum = hourNum_l;
			minNum = minNum_l;
			secNum = Clock_l.sec;
			tipText = GetTimeTipString(Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.ServerTimeFull")
									 , hourNum_s, minNum_s, Me.Settings.UseAMPM);
			timeRichText:SetFormat("{s14}{ol}{#66FFFF}%s:%s{/}{/}{/}");
			ampmRichText:SetFormat("{s13}{ol}{#66FFFF}%s{/}{/}{/}");
		end

		-- 表示する
		Me.SetTimeEx(hourNum, minNum, secNum);
		timeRichText:SetTextTooltip(tipText);
	end
end
function Me.UpdateOnlyLocalTime()
	local Clock_l = os.date("*t");
	local hourNum = Clock_l.hour;
	local minNum = Clock_l.min;
	local secNum = Clock_l.sec;
	Me.SetTimeEx(hourNum, minNum, secNum);
end

function Me.TIEM_ON_MSG_HOOKED(frame, msg, argStr, argNum)
	Me.UpdateClock(frame, msg, argStr, argNum)
end

--function TOUKIBI_MAPMATE_TEST(frame, msg, str, type)
	--Me.UpdateMobToolTip()
--end

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

	addon:RegisterMsg('QUEST_UPDATE', 'TOUKIBI_MAPMATE_UPDATE_MAINFRAME');
	addon:RegisterMsg('GET_NEW_QUEST', 'TOUKIBI_MAPMATE_UPDATE_MAINFRAME');
	addon:RegisterMsg('NPC_STATE_UPDATE', 'TOUKIBI_MAPMATE_UPDATE_MAINFRAME');
	addon:RegisterMsg("INV_ITEM_ADD", "TOUKIBI_MAPMATE_UPDATE_MAINFRAME");
	addon:RegisterMsg('INV_ITEM_POST_REMOVE', 'TOUKIBI_MAPMATE_UPDATE_MAINFRAME');
	addon:RegisterMsg('INV_ITEM_CHANGE_COUNT', 'TOUKIBI_MAPMATE_UPDATE_MAINFRAME');
	--addon:RegisterMsg('WIKI_PROP_UPDATE', 'TOUKIBI_MAPMATE_TEST');


	Toukibi:SetHook("MINIMAP_CHAR_UDT", Me.MINIMAP_CHAR_UDT_HOOKED);
	Toukibi:SetHook("TIEM_ON_MSG", Me.TIEM_ON_MSG_HOOKED);
	Toukibi:SetHook("UPDATE_MINIMAP", Me.UPDATE_MINIMAP_HOOKED); 
	Toukibi:SetHook("MAP_OPEN", Me.MAP_OPEN_HOOKED);
	Toukibi:SetHook("ON_MAP_AREA_TEXT", Me.ON_MAP_AREA_TEXT_HOOKED);

	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_MAPMATE_PROCESS_COMMAND);
	end
end
