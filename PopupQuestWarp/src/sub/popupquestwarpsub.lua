local addonName = "PopupQuestWarpSub";
local verText = "1.00";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/puqwsub"} -- {"/コマンド1", "/コマンド2", .......};
local CommandParamList = {
	update = {jp = "表示を更新", en = "The additional information displayed will be updated."}
};
local SettingFileName = "setting_sub.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
local MyParent = _G['ADDONS'][autherName].PopupQuestWarp;
--PPQWSUB = Me;
local DebugMode = false;
Me.MaxHeight = 600;

-- テキストリソース
local ResText = {
	jp = {
		Menu = {
			TitleTown = "{#006666}==== 表示する街の設定 ===={/}"
		  , Klaipeda = "クラペダ"
		  , Orsha = "オルシャ"
		  , Fedimian = "フェディミアン"
		  , AddBookMark = "お気に入りに追加"
		  , RemoveBookMark = "お気に入りから外す"
		  , Close = "閉じる"
		},
		Main = {
			Title = "ワープ先一覧"
		  , IconName_Home = "friend_team"
		  , IconName_Home_Off = "friend_team_off"
		  , Title_Klaipeda = "クラペダ"
		  , Title_Orsha = "オルシャ"
		  , Title_Fedimian = "フェディミアン"
		  , Title_BookMark = "お気に入りMAP一覧"
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
			Title = "{#006666}======= Quest list setting ======={/}"
		  , Klaipeda = "Klaipeda"
		  , Orsha = "Orsha"
		  , Fedimian = "Fedimian"
		  , AddBookMark = "Add to Favourites"
		  , RemoveBookMark = "Remove from Favorites"
		  , Close = "Close"
		},
		Main = {
			Title = "Warp destination list"
		  , IconName_Home = "friend_team"
		  , IconName_Home_Off = "friend_team_off"
		  , Title_Klaipeda = "Klaipeda"
		  , Title_Orsha = "Orsha"
		  , Title_Fedimian = "Fedimian"
		  , Title_BookMark = "Favorite map list"
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


-- ***** 変数の宣言と設定 *****
Me.SettingFilePathName = string.format("../addons/%s/%s", "popupquestwarp", SettingFileName);
Me.Loaded = false;

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

	Me.Settings.DisplayKlaipeda	= Toukibi:GetValueOrDefault(Me.Settings.DisplayKlaipeda	, true, Force);
	Me.Settings.DisplayOrsha	= Toukibi:GetValueOrDefault(Me.Settings.DisplayOrsha	, true, Force);
	Me.Settings.DisplayFedimian	= Toukibi:GetValueOrDefault(Me.Settings.DisplayFedimian	, true, Force);

	Me.Settings.BookMarkList	= Toukibi:GetValueOrDefault(Me.Settings.BookMarkList	, {}, Force);


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

Me.QuestList = {};
local function GetQuestList()
	local tmpList = {};
	local questClsList, questCnt = GetClassList('QuestProgressCheck');
	local pc = SCR_QUESTINFO_GET_PC();
	local index = 0;
	for index = 0, questCnt - 1 do
		local questIES = GetClassByIndexFromList(questClsList, index);
		if questIES.ClassName ~= "None" then
			local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName);
			if ((result == 'POSSIBLE' and questIES.POSSI_WARP == 'YES') or (result == 'PROGRESS' and questIES.PROG_WARP == 'YES') or (result == 'SUCCESS' and questIES.SUCC_WARP == 'YES')) then
				local questNPC_State = GET_QUEST_NPC_STATE(questIES, result);
				if questNPC_State ~= nil then
					local mapProp = geMapTable.GetMapProp(questIES[questNPC_State .. 'Map']);
					if mapProp ~= nil then
						local npcProp = mapProp:GetNPCPropByDialog(questIES[questNPC_State ..'NPC']);
						if npcProp~= nil then
							local genList = npcProp.GenList;
							if genList ~= nil and genList:Count() > 0 then
								local genPos = genList:Element(0);

								local tmpRecord		= {};
								tmpRecord.MapClassName	 = mapProp:GetClassName();
								local mapIESData = GetClass("Map", tmpRecord.MapClassName);
								tmpRecord.MapName		 = dictionary.ReplaceDicIDInCompStr(mapProp:GetName());
								tmpRecord.MapIsVillage	 = (mapIESData.isVillage == "YES");
								if mapIESData.isVillage == "YES" then
									tmpRecord.MapSymbol	 = "friend_team";
								else
									if mapIESData.MapType == "Dungeon" then
										if string.find(string.lower(tmpRecord.MapClassName), "id_") or string.find(string.lower(tmpRecord.MapClassName), "mission_") or mapIESData.Mission == "YES" then
											tmpRecord.MapSymbol = "minimap_indun";
										else
											tmpRecord.MapSymbol = "minimap_dungeon";
										end
									else
										tmpRecord.MapSymbol = "";
									end
								end
								tmpRecord.NPCName		 = dictionary.ReplaceDicIDInCompStr(npcProp:GetName());
								tmpRecord.QuestName		 = questIES.Name;
								tmpRecord.QuestClassName = questIES.ClassName;
								tmpRecord.QuestClassID	 = questIES.ClassID;
								tmpRecord.QuestMode		 = questIES.QuestMode;
								tmpRecord.QuestIconName	 = GET_QUESTINFOSET_ICON_BY_STATE_MODE("POSSIBLE", questIES)
								tmpRecord.genPos		 = genPos;

								tmpList[#tmpList + 1] = tmpRecord;
							else
								log("Error : Quest ".. questIES.ClassID .. " : " .. questIES.ClassName .. " : " .. questNPC_State .. 'Map' .. " : ".. questNPC_State ..'NPC'.." search data null")
							end
						end
					end
				end
			end
		end
	end
	if #tmpList > 0 then
		table.sort(tmpList, function(a, b)
			if a.MapName ~= b.MapName then
				return a.MapName < b.MapName
			else
				return a.QuestName < b.QuestName
			end
		end)
	end

	return tmpList;
end

local function GetQuestMapName(QuestData)
	local MarkDefSize = 14;
	local IconImageText = QuestData.MapSymbol;
	if IconImageText ~= "" then
		-- IconImageText = "channel_mark_empty";
		IconImageText = string.format("{img %s %s %s}", IconImageText, MarkDefSize, MarkDefSize);
	end
	return string.format("%s%s", IconImageText, QuestData.MapName);
end

local function GetQuestTitle(QuestData)
	local MarkDefSize = 20;
	local IconImageText = QuestData.QuestIconName;
	if IconImageText ~= "" then
		IconImageText = string.format("{img %s %s %s}", IconImageText, MarkDefSize, MarkDefSize);
	end
	return string.format("%s %s", IconImageText, QuestData.QuestName);
end

local function CreateToolButton(Parent, Name, left, top, width, height, Icon)
	local DefSize = 36;
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

	return pnlBase;
end

local function CreateMapNameLabel(Parent, left, top, width, height, QuestData)
	local DefWidth = 300;
	local DefHeight = 20;
	left = left or 0;
	top = top or 0;
	width = width or DefWidth;
	height = height or DefHeight;

	local ExclusionList = {"c_Klaipe", "c_orsha", "c_fedimian"};
	local isVillage = (table.find(ExclusionList, QuestData.MapClassName) ~= 0);

	if not isVillage then
		local BookMarkIconName = "star_out_arrow";
		if Me.Settings.BookMarkList[QuestData.MapClassName] ~= nil then
			-- お気に入り登録対象MAP
			BookMarkIconName = "star_in_arrow"
		end
		local objButton = CreateToolButton(Parent, "btnMapBookMark_" .. QuestData.QuestClassID, left, top, 16, 16, BookMarkIconName);
		objButton:SetSkinName("None");
		objButton:SetClickSound('button_click');
		objButton:SetEventScript(ui.LBUTTONUP, "TOUKIBI_POPUPQUESTWARPSUB_BTNBOOKMARK_CLICK")
		objButton:SetEventScriptArgString(ui.LBUTTONUP, QuestData.MapClassName);
		left = left + 16;
	end

	local objLabel = tolua.cast(Parent:CreateOrGetControl("richtext", "lblMapName_" .. QuestData.QuestClassID, left, top, width, height), "ui::CRichText");
	objLabel:SetGravity(ui.LEFT, ui.TOP);
	objLabel:SetTextAlign("left", "center");
	objLabel:EnableHitTest(0);
	objLabel:SetText(Toukibi:GetStyledText(GetQuestMapName(QuestData), {"ol", "b", "s12", "#226611"})); -- #66AA33がオリジナル
	objLabel:ShowWindow(1);

	return objLabel;
end

local function CreateQuestWarpButton(Parent, Name, left, top, width, height, QuestData)
	local DefWidth = 280;
	local DefHeight = 30;
	local Margin = 5;
	left = left or 0;
	top = top or 0;
	width = width or DefWidth;
	height = height or DefHeight;

	local pnlBase = tolua.cast(Parent:CreateOrGetControl("groupbox", Name, left, top, width, height), "ui::CGroupBox");
	pnlBase:SetGravity(ui.LEFT, ui.TOP);
	pnlBase:SetSkinName("None");
	pnlBase:EnableScrollBar(0);
	pnlBase:EnableHitTest(1);
	pnlBase:SetEventScript(ui.LBUTTONUP, "QUESTION_QUEST_WARP");
	pnlBase:SetEventScriptArgNumber(ui.LBUTTONUP, QuestData.QuestClassID);
	pnlBase:SetUserValue("PC_FID", GET_QUESTINFO_PC_FID());
	pnlBase:SetUserValue("RETURN_QUEST_NAME", QuestData.QuestClassName);
	pnlBase:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_POPUPQUESTWARPSUB_QUESTLABEL_MOUSEMOVE");
	pnlBase:SetEventScript(ui.LOST_FOCUS, "TOUKIBI_POPUPQUESTWARPSUB_QUESTLABEL_LOSTFOCUS");
	pnlBase:ShowWindow(1);
	-- pnlBase:SetOverSound('button_over');
	pnlBase:SetOverSound('button_cursor_over_3');
	pnlBase:SetClickSound('button_click_stats');

	local objLabel = tolua.cast(pnlBase:CreateOrGetControl("richtext", "lblText", Margin, Margin, width - Margin * 2, height - Margin * 2), "ui::CRichText");
	objLabel:SetGravity(ui.LEFT, ui.TOP);
	objLabel:SetTextAlign("left", "center");
	objLabel:EnableHitTest(0);
	objLabel:SetText(Toukibi:GetStyledText(GetQuestTitle(QuestData), {"ol", "b", "s14"}));
	objLabel:SetColorTone("FF606060");
	objLabel:ShowWindow(1);

	return pnlBase;
end

local function CreateHomeWarpGroup(BasePanel, GroupName, LastPos, Title, ItemClassName_EscapeStone, ItemClassName_Scroll, MapClassName, pVisible)
	local DefBtnSize = 36;
	local objLabel = nil;
	local objButton = nil;
	if pVisible == nil then pVisible = true end

	-- 見出し
	local IconImageText = Toukibi:GetResText(ResText, Me.Settings.Lang, "Main.IconName_Home_Off");
	if pVisible then
		IconImageText = Toukibi:GetResText(ResText, Me.Settings.Lang, "Main.IconName_Home");
	end
	objButton = CreateToolButton(BasePanel, "btnExpand_" .. GroupName, 0, LastPos.Y, 16, 16, IconImageText);
	objButton:SetSkinName("None");
	objButton:SetClickSound('button_click');
	objButton:SetEventScript(ui.LBUTTONUP, "TOUKIBI_POPUPQUESTWARPSUB_BTNHOMEEXPAND_CLICK")
	objButton:SetEventScriptArgString(ui.LBUTTONUP, "Display" .. GroupName);


	objLabel = tolua.cast(BasePanel:CreateOrGetControl("richtext", "lblTitle_" .. GroupName, 16, LastPos.Y, 100, 20), "ui::CRichText");
	objLabel:SetGravity(ui.LEFT, ui.TOP);
	objLabel:SetTextAlign("left", "center");
	objLabel:EnableHitTest(0);
	objLabel:SetText(Toukibi:GetStyledText(Title, {"ol", "b", "s14", "#CCCCCC"}));
	objLabel:ShowWindow(1);
	LastPos.Y = LastPos.Y + 24

	if not pVisible then
		return;
	end

	-- 街帰還石
	ItemData =  MyParent.InvItemData[ItemClassName_EscapeStone];
	if ItemData ~= nil then
		objButton = CreateToolButton(BasePanel, "btnEscape_" .. GroupName, 80, LastPos.Y, DefBtnSize, DefBtnSize, ItemData.Icon);
		objButton:SetGravity(ui.LEFT, ui.TOP);
		objButton:SetTextTooltip(ItemData.Name)
		objButton:SetEventScript(ui.LBUTTONUP, "TOUKIBI_POPUPQUESTWARP_ITEMBTNCLICK");
		objButton:SetEventScriptArgString(ui.LBUTTONUP, ItemClassName_EscapeStone);
	end

	-- 街スクロール
	ItemData =  MyParent.InvItemData[ItemClassName_Scroll];
	if ItemData ~= nil then
		objButton = CreateToolButton(BasePanel, "btnScroll_" .. GroupName, 40, LastPos.Y, DefBtnSize, DefBtnSize, ItemData.Icon);
		objButton:SetGravity(ui.LEFT, ui.TOP);
		objButton:SetTextTooltip(ItemData.Name)
		objButton:SetEventScript(ui.LBUTTONUP, "TOUKIBI_POPUPQUESTWARP_ITEMBTNCLICK");
		objButton:SetEventScriptArgString(ui.LBUTTONUP, ItemClassName_Scroll);

		-- 残数を表示する
		objLabel = tolua.cast(objButton:CreateOrGetControl("richtext", "lblCount", 0, 0, DefBtnSize, DefBtnSize), "ui::CRichText");
		objLabel:SetGravity(ui.LEFT, ui.TOP);
		objLabel:SetTextAlign("right", "bottom");
		objLabel:EnableHitTest(0);
		objLabel:SetText(Toukibi:GetStyledText(ItemData.Count, {"ol", "b", "s14"}));
		objLabel:ShowWindow(1);
	else
		-- アイテムが存在しないか、持っていないか
		local objItemClass = GetClass("Item", ItemClassName_Scroll)
		if objItemClass ~= nil then
			-- 存在するアイテムの場合
			objButton = CreateToolButton(BasePanel, "btnScroll_" .. GroupName, 40, LastPos.Y, DefBtnSize, DefBtnSize, objItemClass.Icon);
			objButton:SetGravity(ui.LEFT, ui.TOP);
			objButton:SetTextTooltip(objItemClass.Name)
			objButton:GetChild('picBase'):SetColorTone("C0FF0000");
			-- 残数を表示する
			objLabel = tolua.cast(objButton:CreateOrGetControl("richtext", "lblCount", 0, 0, DefBtnSize, DefBtnSize), "ui::CRichText");
			objLabel:SetGravity(ui.LEFT, ui.TOP);
			objLabel:SetTextAlign("right", "bottom");
			objLabel:EnableHitTest(0);
			objLabel:SetText(Toukibi:GetStyledText("0", {"ol", "b", "s14"}));
			objLabel:ShowWindow(1);
		end
	end
	LastPos.Y = LastPos.Y + 40
	local MaxCount = #Me.QuestList;
	local i = 0;
	for i = 1, MaxCount do
		local QuestData = Me.QuestList[i];
		if MapClassName == QuestData.MapClassName then
			-- 該当の飛び先のクエストがある場合はクエスト一覧に追加する
			objButton = CreateQuestWarpButton(BasePanel, "btnQuest_" .. QuestData.QuestClassID, 20, LastPos.Y, nil, nil, QuestData);

			LastPos.Y = LastPos.Y + objButton:GetHeight()
		end
	end
	LastPos.Y = LastPos.Y + 8
end

local function CreateQuestWarpList(BasePanel)
	local PosY = 0;
	local ExclusionList = {};
	if Me.Settings.DisplayKlaipeda	 then table.insert(ExclusionList, "c_Klaipe") end
	if Me.Settings.DisplayOrsha		 then table.insert(ExclusionList, "c_orsha") end
	if Me.Settings.DisplayFedimian	 then table.insert(ExclusionList, "c_fedimian") end

	local lblMapName = nil;
	local objButton = nil;
	local MaxCount = #Me.QuestList;
	local i = 0;
	local BeforeMapClassName = "";
	local DisplayedCount = 0;
	for i = 1, MaxCount do
		local QuestData = Me.QuestList[i];
		if table.find(ExclusionList, QuestData.MapClassName) == 0 then
			-- ExclusionList以外のクエストを追加する
			
			if BeforeMapClassName ~= QuestData.MapClassName then
				lblMapName = CreateMapNameLabel(BasePanel, 0, PosY, nil, nil, QuestData);
				PosY = PosY + lblMapName:GetHeight();
			end
			BeforeMapClassName = QuestData.MapClassName;

			objButton = CreateQuestWarpButton(BasePanel, "btnQuest_" .. QuestData.QuestClassID, 30, PosY, nil, nil, QuestData);
			DisplayedCount = DisplayedCount + 1;

			PosY = PosY + objButton:GetHeight();
		end
	end

	PosY = PosY + 8;
	if PosY > Me.MaxHeight then PosY = Me.MaxHeight end

	BasePanel:Resize(BasePanel:GetWidth(), PosY);
	return DisplayedCount;
end

local function CreateBookMarkedQuestWarpList(BasePanel, MaxHeight)
	local PosY = 0;
	local ExclusionList = {"c_Klaipe", "c_orsha", "c_fedimian"};

	BasePanel:EnableScrollBar(1);
	local lblMapName = nil;
	local objButton = nil;
	local MaxCount = #Me.QuestList;
	local i = 0;
	local BeforeMapClassName = "";
	local DisplayedCount = 0;
	for i = 1, MaxCount do
		local QuestData = Me.QuestList[i];
		if table.find(ExclusionList, QuestData.MapClassName) == 0 and Me.Settings.BookMarkList[QuestData.MapClassName] ~= nil then
			-- ExclusionList以外でお気に入りに追加されているマップのクエストを追加する
			
			if BeforeMapClassName ~= QuestData.MapClassName then
				lblMapName = CreateMapNameLabel(BasePanel, 0, PosY, nil, nil, QuestData);
				PosY = PosY + lblMapName:GetHeight();
			end
			BeforeMapClassName = QuestData.MapClassName;

			objButton = CreateQuestWarpButton(BasePanel, "btnQuest_" .. QuestData.QuestClassID, 30, PosY, 245, nil, QuestData);
			DisplayedCount = DisplayedCount + 1;

			PosY = PosY + objButton:GetHeight();
		end
	end

	PosY = PosY + 8;

	if PosY > MaxHeight then PosY = MaxHeight end
	BasePanel:EnableScrollBar(1);
	BasePanel:Resize(BasePanel:GetWidth(), PosY);
	BasePanel:InvalidateScrollBar();
	return DisplayedCount;
end

function Me.Update()
	if MyParent ~= nil then Me.Settings.Lang = MyParent.Settings.Lang end
	local BaseFrame = ui.GetFrame(addonNameLower);
	if BaseFrame == nil then return end
	DESTROY_CHILD_BYNAME(BaseFrame, "lblBook")

	MyParent.GetInvItemData();
	Me.QuestList = GetQuestList();

	local ButtonCount = 0;

	-- 左側のパネルを作成
	local pnlLeft = tolua.cast(BaseFrame:CreateOrGetControl("groupbox", "pnlLeft", 20, 40, 300 , 240), "ui::CGroupBox");
	pnlLeft:EnableScrollBar(0);
	pnlLeft:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_POPUPQUESTWARPSUB_ADDDURATION");
	-- pnlLeft:SetEventScript(ui.RBUTTONDOWN, "TOUKIBI_POPUPQUESTWARPSUB_MAIN_CONTEXT_MENU");

	pnlLeft:RemoveAllChild();
	local LastPos = {};
	LastPos.X = 0;
	LastPos.Y = 0;

	-- クラペダ
	CreateHomeWarpGroup(pnlLeft, "Klaipeda", LastPos, Toukibi:GetResText(ResText, Me.Settings.Lang, "Main.Title_Klaipeda"), "EscapeStone_Klaipeda", "Scroll_Warp_Klaipe", "c_Klaipe", Me.Settings.DisplayKlaipeda)
	-- オルシャ
	CreateHomeWarpGroup(pnlLeft, "Orsha", LastPos, Toukibi:GetResText(ResText, Me.Settings.Lang, "Main.Title_Orsha"), "EscapeStone_Orsha", "Scroll_Warp_Orsha", "c_orsha", Me.Settings.DisplayOrsha)
	-- フェディミアン
	CreateHomeWarpGroup(pnlLeft, "Fedimian", LastPos, Toukibi:GetResText(ResText, Me.Settings.Lang, "Main.Title_Fedimian"), "EscapeStone_Fedimian", "Scroll_Warp_Fedimian", "c_fedimian", Me.Settings.DisplayFedimian)

	pnlLeft:Resize(pnlLeft:GetWidth(), LastPos.Y);
	
	-- 右側のパネルを作成
	local pnlRight = tolua.cast(BaseFrame:CreateOrGetControl("groupbox", "pnlRight", pnlLeft:GetX() + pnlLeft:GetWidth() + 20, 40, 340 , 240), "ui::CGroupBox");
	pnlRight:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_POPUPQUESTWARPSUB_ADDDURATION");

	pnlRight:RemoveAllChild();
	local DisplayedCount = CreateQuestWarpList(pnlRight);
	if DisplayedCount > 0 then
		-- クエスト一覧あり
		BaseFrame:Resize(pnlRight:GetX() + pnlRight:GetWidth() + 20, math.max(pnlLeft:GetHeight(), pnlRight:GetHeight()) + 40 + 20);
	else
		-- クエスト一覧なし
		BaseFrame:Resize(pnlLeft:GetX() + pnlLeft:GetWidth() + 20, math.max(pnlLeft:GetHeight(), pnlRight:GetHeight()) + 40 + 20);
	end

	-- お気に入りのパネルを作成
	local MaxHeight = Me.MaxHeight - pnlLeft:GetHeight() - 28
	local pnlBookMark = tolua.cast(BaseFrame:CreateOrGetControl("groupbox", "pnlBookMark", 20, pnlLeft:GetY() + pnlLeft:GetHeight() + 24, 300 , MaxHeight), "ui::CGroupBox");
	pnlBookMark:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_POPUPQUESTWARPSUB_ADDDURATION");
	pnlBookMark:RemoveAllChild();
	local DisplayedBookMarkedCount = CreateBookMarkedQuestWarpList(pnlBookMark, MaxHeight);

	if DisplayedBookMarkedCount > 0 then
		local objLabel = tolua.cast(BaseFrame:CreateOrGetControl("richtext", "lblBookMark_Title", 20, pnlLeft:GetY() + pnlLeft:GetHeight() + 4, 200, 20), "ui::CRichText");
		objLabel:SetGravity(ui.LEFT, ui.TOP);
		objLabel:SetTextAlign("left", "top");
		objLabel:EnableHitTest(0);
		objLabel:SetText(Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "Main.Title_BookMark"), {"ol", "b", "s14", "#003300"}));
		objLabel:ShowWindow(1);

		-- メインフレームの大きさ再調整
		BaseFrame:Resize(pnlRight:GetX() + pnlRight:GetWidth() + 20, math.max(pnlBookMark:GetY() + pnlBookMark:GetHeight(), pnlRight:GetY() + pnlRight:GetHeight()) + 20);
	end

	BaseFrame:GetChild("title"):SetText(Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "Main.Title"), {"ol", "b", "s16", "#003300"}));

	-- 位置とサイズ調整をする
	local screenWidth = ui.GetSceneWidth();
	local screenHeight = ui.GetSceneHeight();
	local Pos = {};
	-- 基本位置の設定
	local ParentFrame = ui.GetFrame("popupquestwarp");
	
	-- BaseFrame:SetMargin(ParentFrame:GetX() - 40, ParentFrame:GetY() + ParentFrame:GetHeight(), 0, 0);
	if MyParent.Settings.Horizontal then
		Pos.X = ParentFrame:GetX() - 40
		Pos.Y = ParentFrame:GetY() + ParentFrame:GetHeight()
	else
		Pos.X = ParentFrame:GetX() + ParentFrame:GetWidth()
		Pos.Y = ParentFrame:GetY() - 40
	end
	local FrameSize = {};
	FrameSize.Width  = BaseFrame:GetWidth()
	FrameSize.Height = BaseFrame:GetHeight()

	-- 右へのはみ出し判定とX位置調整
	if Pos.X + FrameSize.Width > screenWidth then
		if MyParent.Settings.Horizontal then
			-- 横表示の場合は、画面右端にフレームの右端が来るように調整
			Pos.X = screenWidth - FrameSize.Width;
		else
			-- 縦表示の場合は、フレームの左側に表示出来るか調べてみて、できそうなら左側に表示する
			if FrameSize.Width < ParentFrame:GetX() then
				Pos.X = ParentFrame:GetX() - FrameSize.Width;
			else
				Pos.X = screenWidth - FrameSize.Width;
			end
		end
	end
	if Pos.X < 0 then Pos.X = 0 end

	-- 下へのはみ出し判定とY位置調整
	if Pos.Y + FrameSize.Height > screenHeight then
		if MyParent.Settings.Horizontal then
			-- 横表示の場合は、フレームの上側に表示出来るか調べてみて、できそうなら上側に表示する
			if FrameSize.Height < ParentFrame:GetY() then
				Pos.Y = ParentFrame:GetY() - FrameSize.Height;
			else
				Pos.Y = screenHeight - FrameSize.Height;
			end
		else
			-- 縦表示の場合は、画面右端にフレームの右端が来るように調整
			Pos.Y = screenHeight - FrameSize.Height;
		end
	end
	if Pos.Y < 0 then Pos.Y = 0 end

	BaseFrame:SetPos(Pos.X, Pos.Y);
	--log("Update Complete")
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
	local pnlLeft = TopFrame:GetChild("pnlLeft");
	if pnlLeft == nil then return end
	local ItemData = nil;
	local InvItem = nil;

	-- クラペダ帰還石
	ItemData =  MyParent.InvItemData["EscapeStone_Klaipeda"];
	if ItemData ~= nil then
		InvItem = GET_PC_ITEM_BY_GUID(ItemData.Guid);
		if InvItem ~= nil then
			SetCooldownText(pnlLeft:GetChild("btnEscape_Klaipeda"), InvItem)
		end
	end

	-- オルシャ帰還石
	ItemData =  MyParent.InvItemData["EscapeStone_Orsha"];
	if ItemData ~= nil then
		InvItem = GET_PC_ITEM_BY_GUID(ItemData.Guid);
		if InvItem ~= nil then
			SetCooldownText(pnlLeft:GetChild("btnEscape_Orsha"), InvItem)
		end
	end
end

-- コンテキストメニューを作成する
function TOUKIBI_POPUPQUESTWARPSUB_MAIN_CONTEXT_MENU(frame, ctrl)
	local context = ui.CreateContextMenu("POPUPQUESTWARPSUB_MAIN_RBTN"
										, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.TitleTown")
										, 0, 0, 180, 0);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Klaipeda"), "TOUKIBI_POPUPQUESTWARPSUB_TOGGLEPROP('DisplayKlaipeda')", nil, Me.Settings.DisplayKlaipeda);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Orsha"), "TOUKIBI_POPUPQUESTWARPSUB_TOGGLEPROP('DisplayOrsha')", nil, Me.Settings.DisplayOrsha);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Fedimian"), "TOUKIBI_POPUPQUESTWARPSUB_TOGGLEPROP('DisplayFedimian')", nil, Me.Settings.DisplayFedimian);
	-- 閉じる
	Toukibi:MakeCMenuSeparator(context, 210.1);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Close"));
	context:Resize(240, context:GetHeight());
	ui.OpenContextMenu(context);
	Me.LastContextMenu = context;
	return context;
end

-- ***** コンテキストメニュー選択イベント受取 *****
function TOUKIBI_POPUPQUESTWARPSUB_TOGGLEPROP(Name, Value)
	if Name == nil then return end
	if Me.Settings == nil then return end
	if Value == "nil" or type(Value) ~= "boolean" then
		Me.Settings[Name] = not Me.Settings[Name];
	else
		Me.Settings[Name] = Value;
	end
	SaveSetting();
	Me.Update();
end

function TOUKIBI_POPUPQUESTWARPSUB_CHANGEPROP(Name, Value)
	if Name == nil then return end
	if Me.Settings == nil then return end
	if Value == "nil" then Value = nil end
	Me.Settings[Name] = Value
	SaveSetting();
	Me.Update();
end








function TOUKIBI_POPUPQUESTWARPSUB_OPEN()
	Me.Update()
end

function TOUKIBI_POPUPQUESTWARPSUB_UPDATE()
	Me.Update()
end

function TOUKIBI_POPUPQUESTWARPSUB_LOSTFOCUS()
	local BaseFrame = ui.GetFrame(addonNameLower);
	if BaseFrame == nil then return end
	BaseFrame:SetDuration(0.3);
end

function TOUKIBI_POPUPQUESTWARPSUB_ADDDURATION()
	local BaseFrame = ui.GetFrame(addonNameLower);
	BaseFrame:SetDuration(0);
end

function TOUKIBI_POPUPQUESTWARPSUB_CALLPOPUP()
	local BaseFrame = ui.GetFrame(addonNameLower);
	BaseFrame:SetDuration(0);
	if BaseFrame:IsVisible() == 1 then return end
	local ParentFrame = ui.GetFrame("popupquestwarp");
	
	BaseFrame:ShowWindow(1)
	Me.Update()
end

function TOUKIBI_POPUPQUESTWARPSUB_CALLHIDE()
	local BaseFrame = ui.GetFrame(addonNameLower);
	if BaseFrame:IsVisible() == 0 then return end
	BaseFrame:ShowWindow(0)
end

function TOUKIBI_POPUPQUESTWARPSUB_CALLCLOSE()
	local BaseFrame = ui.GetFrame(addonNameLower);
	if BaseFrame:IsVisible() == 0 then return end
	BaseFrame:SetSkinName("tooltip1")
	BaseFrame:ShowWindow(0)
end

function TOUKIBI_POPUPQUESTWARPSUB_TIMER_COOLDOWN_TICK(frame)
	Me.UpdateCooldownText();
end

function TOUKIBI_POPUPQUESTWARPSUB_QUESTLABEL_MOUSEMOVE(frame, control, argStr, argNum)
	control:SetSkinName("chat_window");
	control:GetChild("lblText"):SetColorTone("FFFFFFFF");
end

function TOUKIBI_POPUPQUESTWARPSUB_QUESTLABEL_LOSTFOCUS(frame, control, argStr, argNum)
	control:SetSkinName("None");
	control:GetChild("lblText"):SetColorTone("FF606060");
end

function TOUKIBI_POPUPQUESTWARPSUB_BTNHOMEEXPAND_CLICK(frame, control, argStr, argNum)
	if argStr == nil then return end
	if Me.Settings == nil then return end
	if Me.Settings[argStr] == nil then return end
	Me.Settings[argStr] = not Me.Settings[argStr];
	SaveSetting();
	Me.Update();
end

function TOUKIBI_POPUPQUESTWARPSUB_BTNBOOKMARK_CLICK(frame, control, argStr, argNum)
	if argStr == nil then return end
	if Me.Settings == nil then return end
	if Me.Settings.BookMarkList == nil then return end
	if Me.Settings.BookMarkList[argStr] ~= nil then
		-- お気に入りに入っている場合はお気に入りから外す
		Me.Settings.BookMarkList[argStr] = nil;
	else
		-- お気に入りに入っていない場合はお気に入りに入れる
		Me.Settings.BookMarkList[argStr] = 1;
	end
	SaveSetting();
	Me.Update();
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取
function TOUKIBI_POPUPQUESTWARPSUB_PROCESS_COMMAND(command)
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
		Me.Update();
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
function POPUPQUESTWARPSUB_ON_INIT(addon, frame)
	-- 設定を読み込む
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	--if Me.Settings.DoNothing then return end

	--タイマーを使う場合
	Me.timer_main = GET_CHILD(ui.GetFrame(addonNameLower), "timer_cd", "ui::CAddOnTimer");
	Me.timer_main:SetUpdateScript("TOUKIBI_POPUPQUESTWARPSUB_TIMER_COOLDOWN_TICK");
	Me.timer_main:Start(0.5)

	-- イベントを登録する
	--addon:RegisterMsg('GAME_START', 'TOUKIBI_POPUPQUESTWARPSUB_ON_GAME_START');


	local BaseFrame = ui.GetFrame(addonNameLower)
	BaseFrame:EnableMove(0);
	BaseFrame:ShowWindow(0);

	-- スラッシュコマンドを使う場合
	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_POPUPQUESTWARPSUB_PROCESS_COMMAND);
	end

	frame:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_POPUPQUESTWARPSUB_ADDDURATION");
	-- frame:SetEventScript(ui.RBUTTONDOWN, "TOUKIBI_POPUPQUESTWARPSUB_MAIN_CONTEXT_MENU");
end

