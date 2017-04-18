local addonName = "MapMate";
local verText = "0.70";
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

-- テキストリソース
local ResText = {
	jp = {
		Menu = {
			Title = "{#006666}==== MapMateの設定(接続人数更新) ===={/}"
		  , TitleNotice = "{#663333}更新機能はサーバーへの通信を行います。{nl}使用は自己責任でお願いします。{/}"
		  , UpdateNow = "今すぐ更新する"
		  , AutoUpdate_Title = "自動更新間隔："
		  , AutoUpdate_Space = "              "
		  , AutoUpdateBySeconds = "%s秒"
		  , AutoUpdateByMinutes = "%s分"
		  , NoAutoUpdate = "更新しない"
		  , ManuallyUpdate = "{img minimap_0_old 20 20}をクリックで手動更新する"
		  , ContinuousUpdatePrevention = "更新後5秒間は更新しない"
		  , Close = "閉じる"
		},
		ClockMenu = {
			Title = "{#006666}==== 時計設定 ===={/}"
		  , Clock_Title = "時刻選択："
		  , Clock_Space = "          "
		  , ServerTime = "サーバー時刻"
		  , ServerTimeFull = "サーバー時刻"
		  , LocalTime = "PCの時刻"
		  , LocalTimeFull = "PCの時刻"
		  , ampm_Title = "表記法  ："
		  , ampm_Space = "          "
		  , ampm = "AM/PM 表記"
		  , Noampm = "24時間表記"
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
		  , MobInfoFormat = "{nl}{s20}    {/}{s14}%s :{s16}%s匹{/}{/}"
		  , RespawnTimeFormat = "{s16}{#66AA33}%s湧き{/}{/}{#333333}%s{/}"
		  , Respawn_WholeArea = "(全域)"
		  , Respawn_SpotArea = "(局地)"
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
			Title = "{#006666}======= MapMate setting ======={nl}(connection number update){/}"
		  , TitleNotice = "{#663333}The update function communicates with{nl}the server. Use it at your own risk.{/}"
		  , UpdateNow = "Update now"
		  , AutoUpdate_Title = "Auto Update Interval:"
		  , AutoUpdate_Space = "                                       "
		  , AutoUpdateBySeconds = "%ssec."
		  , AutoUpdateByMinutes = "%smin."
		  , NoAutoUpdate = "Never"
		  , ManuallyUpdate = "Click on{img minimap_0_old 20 20}to update manually"
		  , ContinuousUpdatePrevention = "Wait for 5sec. after updating"
		  , Close = "Close"
		},
		ClockMenu = {
			Title = "{#006666}==== Time display setting ===={/}"
		  , Clock_Title = "Time selection:"
		  , Clock_Space = "                            "
		  , ServerTime = "Server time"
		  , ServerTimeFull = "Server time"
		  , LocalTime = "Local Time"
		  , LocalTimeFull = "Local Time"
		  , ampm_Title = "Display:             "
		  , ampm_Space = "                            "
		  , ampm = "Standard"
		  , Noampm = "24Hour"
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
		  , MaxHate = "Aggro Limit"
		  , TBox = "Treasure Box"
		  , ListTitleFormat = "{#66FF66}%s{/}{s24} {/}"
		  , List_NoMeetStatue = "List of statues that have not yet met"
		  , List_NoMeetNPC = "List of NPCs that have not met yet"
		  , List_ClosedTBox = "List of treasure boxes that is not open yet"
		  , List_Mob = "Monster List"
		  , List_Quest = "List of remaining quests"
		  , MobInfoFormat = "{nl}{s20}    {/}%s : %s"
		  , RespawnTimeFormat = "{s16}{#333333}Respawn Time:{/}{#66AA33}{b}%s{/} {/}{#333333}%s{/}{/}"
		  , Respawn_WholeArea = "(Whole Area)"
		  , Respawn_SpotArea = "(Spot)"
		},
		DeathPenalty = {
			Title = "Additional penalty for character's death"
		  , LostGem = "Loss of Gems"
		  , LostSilver = "Loss of %s% silver"
		  , LostCard = "Loss of boss-cards"
		  , LostBlessStone = "Loss of blessed stone"
		  , Other = "Other items(%s)"
		},
		GetConnectionNumber = {
			Title = "Number of people"
		  , Failed = "Failed to get the number of people"
		  , Cannot = "Here is a map that cannot get the number of people"
		  , Closed = "This channel is closed"
		  , StateClosed = "Closed"
		},
		Other = {
			PercentChar = "%"
		  , Opened = "Opened"
		  , Registed = "Registed"
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
			  , CompleteSaveSettings = "Saving settings completed."
			  , ErrorToUseDefaults = "Change to use default setting because of an error occurred while loading the settings."
			  , CompleteLoadDefault = "An error occurred while loading the default settings."
			  , CompleteLoadSettings = "Loading settings completed."
			},
			Command = {
				ExecuteCommands = "Command '{#333366}%s{/}' was called"
			  , ResetSettings = "The setting was reset."
			  , InvalidCommand = "Invalid command called"
			  , AnnounceCommandList = "Please use [ %s ? ] To see the command list"
				},
			Help = {
				Title = string.format("{#333333}Help for %s commands.{/}", addonName)
			  , Description = string.format("{#92D2A0}To change settings of '%s', please call the following command.{/}", addonName)
			  , ParamDummy = "[paramaters]"
			  , OrText = "or"
			  , EnableTitle = "Available commands"
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
	Me.Settings.DoNothing = Toukibi:GetValueOrDefault(Me.Settings.DoNothing, false, Force);
	Me.Settings.Lang = Toukibi:GetValueOrDefault(Me.Settings.Lang, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.Movable = Toukibi:GetValueOrDefault(Me.Settings.Movable, false, Force);
	Me.Settings.Visible = Toukibi:GetValueOrDefault(Me.Settings.Visible, true, Force);
	Me.Settings.UpdatePCCountInterval = Toukibi:GetValueOrDefault(Me.Settings.UpdatePCCountInterval, nil, Force);
	Me.Settings.EnableOneClickPCCUpdate = Toukibi:GetValueOrDefault(Me.Settings.EnableOneClickPCCUpdate, false, Force);
	Me.Settings.UsePCCountSafety = Toukibi:GetValueOrDefault(Me.Settings.UsePCCountSafety, true, Force);
	Me.Settings.UseServerClock = Toukibi:GetValueOrDefault(Me.Settings.UseServerClock, true, Force);
	Me.Settings.UseAMPM = Toukibi:GetValueOrDefault(Me.Settings.UseAMPM, true, Force);
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
		local objNoticeText = tolua.cast(pnlBase:CreateOrGetControl("richtext", Name .. "noticetext", 0, 0, 20, 20), "ui::CRichText");
		objNoticeText:SetGravity(ui.RIGHT, ui.BOTTOM);
		objNoticeText:SetTextAlign("left", "center");
		objNoticeText:SetMargin(0, 0, 3, 1);
		objNoticeText:EnableHitTest(0);
		objNoticeText:ShowWindow(1);

		CreateMiniBadge(pnlBase, Name, NoticeNum)
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

function Me.UpdateFrame()
	local NPCInfo = Me.GetMapNPCInfo()
	local MobInfo = Me.GetMapMonsterInfo()
	local QuestInfo = Me.GetMapQuestInfo()
	local ParentWidth = 32;
	local height = ParentWidth + 2;
	local FrameMiniMap = ui.GetFrame('minimap');
	local MyFrame = ui.GetFrame('mapmate');

	MyFrame:Resize(ParentWidth , height * 5);
	MyFrame:SetMargin(0, FrameMiniMap:GetMargin().top, 1, 0);
	local pnlBase = tolua.cast(MyFrame:CreateOrGetControl("groupbox", "pnlInput", 0, 8, ParentWidth , height * 5), 
							   "ui::CGroupBox");
	
	pnlBase:SetGravity(ui.RIGHT, ui.TOP);
	pnlBase:SetMargin(0, 0, 0, 0);
	pnlBase:Resize(ParentWidth , height * 8);
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
	--[[
	-- 女神像
	ToDisplayCount = 0;
	ToolTipText = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ListTitleFormat"), Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.List_NoMeetStatue"));
	for i,value in ipairs(NPCInfo) do
		if value.NpcState == 0 and value.Type == "Statue" then
			ToDisplayCount = ToDisplayCount + 1;
			ToolTipText = ToolTipText .. "{nl}{s28} {/}{img minimap_goddess 20 20} " .. value.Name
		end
	end
	if ToDisplayCount > 0 then
		local objButton = CreateToolButton(pnlBase, "btnStatue"	, 0, height * ButtonCount, nil, nil, "minimap_goddess")
		objButton:SetTextTooltip(ToolTipText)
		ButtonCount = ButtonCount + 1
	end
	--]]

	-- Mob
	ToDisplayCount = 0;
	ToolTipText = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ListTitleFormat"), Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.List_Mob"));
	for name, value in pairs(MobInfo) do
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
	if ToDisplayCount > 0 then
		objButton = CreateToolButton(pnlBase, "btnMOB", 0, height * ButtonCount, nil, nil, "icon_state_medium")
		objButton:SetGravity(ui.CENTER_HORZ, ui.TOP);
		objButton:SetTextTooltip(ToolTipText)
		ButtonCount = ButtonCount + 1
	end

	-- クエスト
	ToDisplayCount = 0;
	ToolTipText = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ListTitleFormat"), Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.List_Quest"));
	for i,value in ipairs(QuestInfo) do
		ToDisplayCount = ToDisplayCount + 1;
		ToolTipText = ToolTipText .. "{nl}{s28} {/}" .. value
	end
	if ToDisplayCount > 0 then
		objButton = CreateToolButton(pnlBase, "btnQuest", 0, height * ButtonCount, nil, nil, "minimap_1_SUB", ToDisplayCount)
		objButton:SetGravity(ui.CENTER_HORZ, ui.TOP);
		objButton:SetTextTooltip(ToolTipText)
		ButtonCount = ButtonCount + 1
	end

	-- NPC
	ToDisplayCount = 0;
	ToolTipText = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ListTitleFormat"), Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.List_NoMeetNPC"));
	for i,value in ipairs(NPCInfo) do
		if value.NpcState == 0 and value.Type == "NPC" then
			ToDisplayCount = ToDisplayCount + 1;
			ToolTipText = ToolTipText .. string.format("{nl}{s28} {/}{img %s 20 20} %s",value.Icon ,value.Name);
		end
	end
	if ToDisplayCount > 0 then
		objButton = CreateToolButton(pnlBase, "btnNPC", 0, height * ButtonCount, nil, nil, "minimap_0", ToDisplayCount)
		objButton:SetGravity(ui.CENTER_HORZ, ui.TOP);
		objButton:SetTextTooltip(ToolTipText)
		ButtonCount = ButtonCount + 1
	end

	-- 宝箱
	ToDisplayCount = 0;
	ToolTipText = string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.ListTitleFormat"), Toukibi:GetResText(ResText, Me.Settings.Lang, "MapInfo.List_ClosedTBox"));
	local CollBoxOpened = true
	for i,value in ipairs(NPCInfo) do
		local IconText = "compen_btn"
		if value.NpcState == 0 and value.Type == "Box" then
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
		objButton = CreateToolButton(pnlBase, "btnBox", 0, height * ButtonCount, nil, nil, IconText)
		objButton:SetGravity(ui.CENTER_HORZ, ui.TOP);
		objButton:SetTextTooltip(ToolTipText)
		ButtonCount = ButtonCount + 1
	end


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
	if value.NpcState ~= 0 then
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
		if value.Type == "Box" then
			local BoxInfo = GetBoxInfo(value)
			local XC = math.ceil((value.X + 10) * Zoom) - 12;
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
		elseif value.Type == "NPC" and value.NpcState == 0 then
			-- まだ会っていないNPC
			local XC = math.ceil((value.X) * Zoom) - 12;
			local YC = math.ceil((value.Y) * Zoom) - 12;
			local objNPCIcon = AddMMapIcon(objTarget, XC, YC, "NPCIcon_" .. i, value.Icon, 30);
			objNPCIcon:SetTooltipType("texthelp");
			objNPCIcon:SetAlpha(50);
			objNPCIcon:EnableHitTest(1);
			objNPCIcon:SetTooltipArg(value.Name);
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

	--メインマップにアイコンを追加
	Parent = ui.GetFrame('map');
	local MainMap = Parent:GetChild('map')
	DrawIconToObjEx(MainMap, 1)
end

-- マップとミニマップにFogを描く
function Me.DrawFog(frame)
	frame = frame or ui.GetFrame('map');
	local mapPic = GET_CHILD(frame, "map", 'ui::CPicture');
	HIDE_CHILD_BYNAME(mapPic, "Toukibi_Fog_");
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
		local strTemp = "{#663333}" .. Toukibi:GetResText(ResText, Me.Settings.Lang, "DeathPenalty.Title") .. " : ";
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
	-- で会ったかどうかがわかる(0:まだ  それ以外:話した・開けた事がある)
	--if ui.GetFrame("loadingbg") ~= nil then return nil end
	MapClassName = MapClassName or session.GetMapName();
	if MapClassName == nil or MapClassName == "" or MapClassName == "None" then return end

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
	-- log(i .. ":" .. MonProp:GetName() .. ":" .. g.mapNpcState:FindAndGet(MonProp.GenType));
		-- if string.find(string.lower(MonProp:GetDialog()),"treasurebox") then
		if (IESData_GenType.Faction == "Neutral" and IESData_GenType.Minimap > 0 and string.find(string.lower(IESData_GenType.ClassType),"hidden") == nil and string.find(string.lower(IESData_GenType.ClassType),"trigger") == nil and string.find(string.lower(IESData_GenType.Name),"visible") == nil) or string.find(string.lower(IESData_GenType.ClassType),"treasure.*box") then
			local NPCType = "NPC"
			if string.find(string.lower(IESData_GenType.ClassType),"statue_*") then
				NPCType = "Statue"
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
			if IconText == nil or IconText == "None" then
				IconText = "minimap_0"
			end
			local GenList = MonProp.GenList;
			local MapPos = nil;
			if GenList:Count() > 0 then
				MapPos = MapInfo.Property:WorldPosToMinimapPos(GenList:Element(0), m_mapWidth, m_mapHeight);
			end
	-- log(string.format("[%s](%s) %s (%s)", IESData_GenType.GenType, MapInfo.NpcState:FindAndGet(IESData_GenType.GenType), IESData_GenType.Name, NPCType))
			table.insert(NoMeetNPC, {
				Name = IESData_GenType.Name
				, NpcState = MapInfo.NpcState:FindAndGet(IESData_GenType.GenType)
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
	MapInfo.NpcState = session.GetMapNPCState(MapInfo.ClassName);
	MapInfo.Property = geMapTable.GetMapProp(MapInfo.ClassName);
	
	MapInfo.ClassList, MapInfo.ClassCount = GetClassList("GenType_" .. MapInfo.ClassName);
	MapInfo.MonGens = MapInfo.Property.mongens;
	if MapInfo.MonGens == nil then return MapInfo end

	local MobList = {};
	local cnt = MapInfo.MonGens:Count();
	for i = 0 , cnt - 1 do 
		local MonProp = MapInfo.MonGens:Element(i);
		local IESData_GenType = GetClassByIndexFromList(MapInfo.ClassList, i);
		if IESData_GenType.Faction == "Monster" and string.find(string.lower(IESData_GenType.ClassType),"hidden") == nil and string.find(string.lower(IESData_GenType.ClassType),"trigger") == nil then
			local MobClass = GetClass("Monster", IESData_GenType.ClassType)
			if MobList[IESData_GenType.ClassType] == nil then
				local wiki = GetWikiByName(MobClass.Journal);
				local pKillCount = 0;
				if wiki ~= nil then
					pKillCount =GetWikiIntProp(wiki, "KillCount")
				end
				local pRequired = 0;
				if GetClass('Journal_monkill_reward', MobClass.Journal) ~= nil then
					pRequired = GetClass('Journal_monkill_reward', MobClass.Journal).Count1
				end
	--log(string.format("[%s] Lv.%s %s (%s)", IESData_GenType.GenType, MobClass.Level, MobClass.Name, IESData_GenType.ClassType))
				MobList[IESData_GenType.ClassType] = {
					Name = MobClass.Name
					, Lv = MobClass.Level
					, MaxNum = 0
					, ClassName = IESData_GenType.ClassType
					, ArgStr1 = IESData_GenType.ArgStr1
					, ArgStr2 = IESData_GenType.ArgStr2
					, ArgStr3 = IESData_GenType.ArgStr3
					, KillCount = pKillCount
					, KillRequired = pRequired
				};
				local killCount = GetWikiIntProp(wiki, "KillCount");
			end
			MobList[IESData_GenType.ClassType].MaxNum = MobList[IESData_GenType.ClassType].MaxNum + IESData_GenType.MaxPop
			if MobList[IESData_GenType.ClassType].PopData == nil then
				MobList[IESData_GenType.ClassType].PopData = {}
			end
			local AreaType = ((IESData_GenType.GenRange == 9999) and 1) or 2;
			if MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)] == nil then
				MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)] = {}
				MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][0] = 0
				MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][1] = 0
				MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][2] = 0
			end
			MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][0] = MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][0] + IESData_GenType.MaxPop
			MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][AreaType] = MobList[IESData_GenType.ClassType].PopData[tostring(IESData_GenType.RespawnTime)][AreaType] + IESData_GenType.MaxPop
		end
	end
	--view(MobList)
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
		if questIES.StartMap == MapClassName and questIES.PossibleUI_Notify ~= 'NO' and questIES.QuestMode ~= 'KEYITEM' and questIES.Level ~= 9999 and questIES.Lvup ~= -9999 and questIES.QuestStartMode ~= 'NPCENTER_HIDE' then
			local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName)
			if result == "POSSIBLE" then
				local ColorStyle = "@st70_s"
				if questIES.QuestMode == "REPEAT" then
					ColorStyle = "@st70_d"
				elseif questIES.QuestMode == "MAIN" then
					ColorStyle = "@st70_m"
				end
				table.insert(QuestInfo, string.format("{img %s 24 24}{%s}%s{/}"
													  , GET_QUESTINFOSET_ICON_BY_STATE_MODE(result, questIES)
													  , ColorStyle
													  , questIES.Name))
			end
		end
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
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdate_Title"), 
											string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateBySeconds"), 10), 
											"TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(10)", nil, Me.Settings.UpdatePCCountInterval == 10);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdate_Space"), 
											string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateBySeconds"), 20), 
											"TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(20)", nil, Me.Settings.UpdatePCCountInterval == 20);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdate_Space"), 
											string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateBySeconds"), 30), 
											"TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(30)", nil, Me.Settings.UpdatePCCountInterval == 30);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdate_Space"), 
											string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateByMinutes"), 1), 
											"TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(60)", nil, Me.Settings.UpdatePCCountInterval == 60);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdate_Space"), 
											string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateByMinutes"), 3), 
											"TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(180)", nil, Me.Settings.UpdatePCCountInterval == 180);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdate_Space"), 
											string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdateByMinutes"), 5), 
											"TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(300)", nil, Me.Settings.UpdatePCCountInterval == 300);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.AutoUpdate_Space"), 
											string.format("{#8888FF}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.NoAutoUpdate")), 
											"TOUKIBI_MAPMATE_CHANGE_PCCUPDATEINTERVAL(nil)", nil, Me.Settings.UpdatePCCountInterval == nil);
	Toukibi:MakeCMenuSeparator(context, 302);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ManuallyUpdate"), "TOUKIBI_MAPMATE_TOGGLEPROP('EnableOneClickPCCUpdate')", nil, Me.Settings.EnableOneClickPCCUpdate);
	Toukibi:MakeCMenuItem(context, string.format("{#8888FF}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ContinuousUpdatePrevention")), "TOUKIBI_MAPMATE_TOGGLEPROP('UsePCCountSafety')", nil, Me.Settings.UsePCCountSafety);
	Toukibi:MakeCMenuSeparator(context, 303);
	Toukibi:MakeCMenuItem(context, string.format("{#666666}%s{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Close")));
	context:Resize(330, context:GetHeight());
	ui.OpenContextMenu(context);
	return context;
end

-- 時計設定のコンテキストメニュー
function TOUKIBI_MAPMATE_CONTEXT_MENU_CLOCK(frame, ctrl)
	local Title = Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.Title");
	local context = ui.CreateContextMenu("DURMINI_MAIN_RBTN", Title, 0, 0, 320, 0);
	Toukibi:MakeCMenuSeparator(context, 300);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.Clock_Title"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.ServerTime"), 
											"TOUKIBI_MAPMATE_CHANGEPROP('UseServerClock', true)", nil, Me.Settings.UseServerClock);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.Clock_Space"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.LocalTime"), 
											"TOUKIBI_MAPMATE_CHANGEPROP('UseServerClock', false)", nil, not Me.Settings.UseServerClock);
	Toukibi:MakeCMenuSeparator(context, 300.1);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.ampm_Title"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.ampm"), 
											"TOUKIBI_MAPMATE_CHANGEPROP('UseAMPM', true)", nil, Me.Settings.UseAMPM);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.ampm_Space"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.Noampm"), 
											"TOUKIBI_MAPMATE_CHANGEPROP('UseAMPM', false)", nil, not Me.Settings.UseAMPM);
	-- 閉じる
	Toukibi:MakeCMenuSeparator(context, 300.3);
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
	Me.UpdateClock();
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
	local pleft = 0;
	local pTop = 0;
	if CHSURF_CREATE_BUTTONS ~= nil then
		-- channelsurfer検知
		pleft = 70;
		pTop = 5;
	end
	local lblFogRate = tolua.cast(Parent:CreateOrGetControl("richtext", "MapMate_FogRate", 0, 0, 80, 20), "ui::CRichText");
	lblFogRate:SetGravity(ui.LEFT, ui.TOP);
	lblFogRate:SetMargin(pleft + 4, pTop + 2, 0, 0);
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
	local clock = ui.GetFrame('time');
	if clock ~= nil then
		local timeRichText = tolua.cast(clock:GetChild("timeText"), "ui::CRichText");
		local ampmRichText = tolua.cast(clock:GetChild("ampmText"), "ui::CRichText");
		timeRichText:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_CLOCK');
		timeRichText:EnableHitTest(1);
		ampmRichText:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_MAPMATE_CONTEXT_MENU_CLOCK');
		ampmRichText:EnableHitTest(1);
	end
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

	local MapNameFrame = ui.GetFrame("mapareatext");
	MapNameFrame:ShowWindow(1 - Parent:IsVisible());

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
	--ReserveScript("TOUKIBI_MAPMATE_UPDATE_MAINFRAME()", 0.5);
	Me.UpdateClock();
	Me.DrawFog(ui.GetFrame('map'))
	Me.DrawFog(ui.GetFrame('minimap'))
	Me.DrawMiniMapIconEx()
	Me.UpdateFrame()
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
	Me.DrawFog(ui.GetFrame('map'))
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
			tipText = GetTimeTipString(Toukibi:GetResText(ResText, Me.Settings.Lang, "ClockMenu.ServerTimeFull")
									 , hourNum_s, minNum_s, Me.Settings.UseAMPM);
			timeRichText:SetFormat("{s14}{ol}{#66FFFF}%s:%s{/}{/}{/}");
			ampmRichText:SetFormat("{s13}{ol}{#66FFFF}%s{/}{/}{/}");
		end
		-- AMPM法を適用
		if Me.Settings == nil or Me.Settings.UseAMPM == nil or Me.Settings.UseAMPM then
			if hourNum >= 12 then
				hourNum = hourNum - 12;
				ampmText = "pm";
			else
				ampmText = "am";
			end
			if hourNum == 0 then
				hourNum = 12;
			end
		else
			ampmText = "";
		end

		-- 表示する
		timeRichText:SetTextByKey("hour"  , " ");
		timeRichText:SetTextByKey("hour"  , string.format("%02d", hourNum));
		timeRichText:SetTextByKey("minute", string.format("%02d", minNum));
		timeRichText:SetTextTooltip(tipText);
		ampmRichText:SetTextByKey("ampm", " ");
		ampmRichText:SetTextByKey("ampm", ampmText);
		ampmRichText:SetTextTooltip(tipText);
	end
end

function Me.TIEM_ON_MSG_HOOKED(frame, msg, argStr, argNum)
	Me.UpdateClock(frame, msg, argStr, argNum)
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

	addon:RegisterMsg('QUEST_UPDATE', 'TOUKIBI_MAPMATE_UPDATE_MAINFRAME');
	addon:RegisterMsg('GET_NEW_QUEST', 'TOUKIBI_MAPMATE_UPDATE_MAINFRAME');
	addon:RegisterMsg('NPC_STATE_UPDATE', 'TOUKIBI_MAPMATE_UPDATE_MAINFRAME');

	Toukibi:SetHook("MINIMAP_CHAR_UDT", Me.MINIMAP_CHAR_UDT_HOOKED);
	Toukibi:SetHook("TIEM_ON_MSG", Me.TIEM_ON_MSG_HOOKED);
	Toukibi:SetHook("UPDATE_MINIMAP", Me.UPDATE_MINIMAP_HOOKED); 
	Toukibi:SetHook("MAP_OPEN", Me.MAP_OPEN_HOOKED);
	--Toukibi:SetHook("TARGETINFO_ON_MSG", Me.TARGETINFO_ON_MSG_HOOKED);
	--Toukibi:SetHook("TGTINFO_TARGET_SET", Me.TGTINFO_TARGET_SET_HOOKED);

	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_MAPMATE_PROCESS_COMMAND);
	end
end
