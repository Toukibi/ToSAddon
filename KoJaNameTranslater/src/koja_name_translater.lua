local addonName = "KoJa_Name_Translater";
local verText = "1.01";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/kojatrans", "/kjtrans"} -- {"/コマンド1", "/コマンド2", .......};
local CommandParamList = {
	reset = {jp = "設定リセット", en = "Reset the all settings."},
	update = {jp = "表示を更新", en = "The additional information displayed will be updated."},
	restart = {jp = "現在の翻訳データを破棄して再始動", en = "Discard current translation data and restart."}
};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
KoJaTranslater = Me;
local DebugMode = false;
Me.MemoriseList = {};
Me.PCHandleList = {};
Me.ShopHandleList = {};
Me.SwitchPCFrameList = {};
Me.SwitchShopFrameList = {};
local SendTsvFile = string.format("../addons/%s/%s/%s", addonNameLower, "KoJaSimpleTransrator", "SendData.dat");
local ResultTsvFile = string.format("../addons/%s/%s/%s", addonNameLower, "KoJaSimpleTransrator", "ResultData.dat");
local MemoriseTsvFile = string.format("../addons/%s/%s", addonNameLower, "MemoriseData.dat");
local TranslaterExe = string.format("..\\addons\\%s\\%s\\%s", addonNameLower, "KoJaSimpleTransrator", "start.bat");

-- テキストリソース
local ResText = {
	jp = {
		Menu = {
			Title = "{#006666}==== KoJa簡易翻訳の設定(接続人数更新) ===={/}"
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
			Title = "{#006666}======= KoJa_Translater setting ======={nl}(connection number update){/}"
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
--	Me.Settings.Movable = Toukibi:GetValueOrDefault(Me.Settings.Movable, false, Force);
--	Me.Settings.Visible = Toukibi:GetValueOrDefault(Me.Settings.Visible, true, Force);




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
local function funcSetMargin(pTarget, pLeft, pTop, pRight, pBottom)
	if pTarget ~= nil then
		local BeforeMargin = pTarget:GetMargin();
		pLeft = pLeft or BeforeMargin.left;
		pTop = pTop or BeforeMargin.top;
		pRight = pRight or BeforeMargin.right;
		pBottom = pBottom or BeforeMargin.bottom;
		pTarget:SetMargin(pLeft, pTop, pRight, pBottom);
	end
end

local function LoadMemoriseList()
	local hFile, err = io.open(MemoriseTsvFile, "r");
	if hFile and not err then
		for rawText in hFile:lines() do
			local StartNum, EndNum, pOriginalText, pResultText = string.find(rawText, "^([^\t]+)\t([^\t]+)$");
			if Me.MemoriseList[pOriginalText] == nil then
				-- 未登録のものだけテーブルに追加する
				Me.MemoriseList[pOriginalText] = pResultText;
			end
		end
		hFile:close();
	end
end

local function AppendMemoriseList(pOriginalText, pResultText)
	if Me.MemoriseList[pOriginalText] == nil then
		-- 未登録のものだけテーブルに追加する
		Me.MemoriseList[pOriginalText] = pResultText;
		local hFile, err = io.open(MemoriseTsvFile, "a");
		if hFile and not err then
			hFile:write(string.format("%s\t%s\n", pOriginalText, pResultText));
			hFile:close();
		end
	end
end

function Me.AddNamePlateList()
	local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 1000, "ALL");
	for i = 1, selectedObjectsCount do
		local handle = GetHandle(selectedObjects[i]);
		if handle ~= nil then
			if info.IsPC(handle) == 1 then
				local shopFrame = ui.GetFrame("SELL_BALLOON_" .. handle);
				if shopFrame ~= nil then
					-- 露店の場合
					local FrameName = "SELL_BALLOON_" .. handle;
					if Me.ShopHandleList[FrameName] == nil then
						local sellType = tonumber(shopFrame:GetUserValue("SELL_TYPE"));
						if sellType == AUTO_SELL_BUFF or sellType == AUTO_SELL_GEM_ROASTING or sellType == AUTO_SELL_SQUIRE_BUFF or sellType == AUTO_SELL_ENCHANTERARMOR or sellType == AUTO_SELL_APPRAISE	or sellType == AUTO_SELL_PORTAL then
							local frameLvBox = shopFrame:GetChild("withLvBox");
							if frameLvBox ~= nil then
								frameShopName = frameLvBox:GetChild("lv_title");
								if frameShopName ~= nil then
									local ShopFrameText = frameShopName:GetText();
									local TranslatedText = ShopFrameText;
									local NeedTranslate = true;
									if Me.MemoriseList[ShopFrameText] ~= nil then
										-- 過去の翻訳履歴がある場合はそれを取得して設定する
										TranslatedText = Me.MemoriseList[ShopFrameText];
										NeedTranslate = false;
									end
									Me.ShopHandleList[FrameName] = {
										LiveChecked = true;
										DataSend = not NeedTranslate;
										Original = {
											type = "lv_title";
											title = ShopFrameText;
										};
										Translated = {
											type = "lv_title";
											title = TranslatedText;
										};
									};
								end
							end
						else
							local frameShopName = shopFrame:GetChild("text");
							if frameShopName ~= nil then
								local ShopFrameText = frameShopName:GetText();
								local TranslatedText = ShopFrameText;
								local NeedTranslate = true;
								if Me.MemoriseList[ShopFrameText] ~= nil then
									-- 過去の翻訳履歴がある場合はそれを取得して設定する
									TranslatedText = Me.MemoriseList[ShopFrameText];
									NeedTranslate = false;
								end
								Me.ShopHandleList[FrameName] = {
									LiveChecked = true;
									DataSend = not NeedTranslate;
									Original = {
										type = "text";
										title = ShopFrameText;
									};
									Translated = {
										type = "text";
										title = TranslatedText;
									};
								};
							end
						end
					else
						-- 生存確認
						Me.ShopHandleList[FrameName].LiveChecked = true;
					end
					if not Me.ShopHandleList[FrameName].DataSend then
						-- 翻訳依頼を行う
						local CurrentData = Me.ShopHandleList[FrameName].Original;
						local hFile = io.open(SendTsvFile, "a");
						hFile:write(string.format("%s\t%s\t%s\n", FrameName, CurrentData.type, CurrentData.title));
						hFile:close();
						Me.ShopHandleList[FrameName].DataSend = true;
					end
				else
					local FrameName = "charbaseinfo1_" .. handle;
					local pcTxtFrame = ui.GetFrame(FrameName);
					if pcTxtFrame ~= nil then
						--人名の場合
						local strHandle = tostring(handle);
						if Me.PCHandleList[strHandle] == nil or Me.PCHandleList[strHandle].DataSend == false then
							local NeedTranslate = false;
							local frameGuildName = pcTxtFrame:GetChild("guildName");
							local strGuildName = "GuildName";
							local strOriginalGuildName = strGuildName;
							local strTranslatedGuildName = strGuildName;
							local strEscapeGuildName = "";
							local guildNameFrameWidth = 400;
							if nil ~= frameGuildName then
								strOriginalGuildName = frameGuildName:GetText();
								guildNameFrameWidth = frameGuildName:GetWidth();
								-- log(guildNameFrameWidth)
								local foundPlace = string.find(strOriginalGuildName, "}");
								if foundPlace == nil then
									-- {}で挟まれた文字がない場合、すべての文字を返す
									strEscapeGuildName = "";
									strGuildName = strOriginalGuildName;
								else
									-- {}で挟まれた文字がある場合、{}の部分とその外の部分とに分ける
									strEscapeGuildName = string.sub(strOriginalGuildName, 1, foundPlace);
									strGuildName = string.sub(strOriginalGuildName, foundPlace + 1);
								end
								if Me.MemoriseList[strGuildName] ~= nil then
									-- 過去の翻訳履歴がある場合はそれを取得して設定する
									strTranslatedGuildName = Me.MemoriseList[strGuildName];
								else
									strTranslatedGuildName = strGuildName;
									NeedTranslate = true;
								end
							end
							local frameGuildEmblem = pcTxtFrame:GetChild("guildEmblem");
							local PosX_GuildEmblem = 0;
							local PosY_GuildEmblem = 0;
							if frameGuildEmblem ~= nil then
								local BeforeMargin = frameGuildEmblem:GetMargin();
								-- log(BeforeMargin.left .. ", " .. BeforeMargin.top)
								PosX_GuildEmblem = BeforeMargin.left;
								PosY_GuildEmblem = BeforeMargin.top;
							end
							local frameFamilyName = pcTxtFrame:GetChild("familyName");
							local strFamilyName = "FamilyName";
							local strOriginalFamilyName = strFamilyName;
							local strTranslatedFamilyName = strFamilyName;
							local strEscapeFamilyName = "";
							local PosX_FamilyName = 0;
							local PosY_FamilyName = 0;
							if nil ~= frameFamilyName then
								strOriginalFamilyName = frameFamilyName:GetText();
								local BeforeMargin = frameFamilyName:GetMargin();
								-- log(BeforeMargin.left .. ", " .. BeforeMargin.top)
								PosX_FamilyName = BeforeMargin.left;
								PosY_FamilyName = BeforeMargin.top;
								local foundPlace = string.find(strOriginalFamilyName, "}");
								if foundPlace == nil then
									-- {}で挟まれた文字がない場合、すべての文字を返す
									strEscapeFamilyName = "";
									strFamilyName = strOriginalFamilyName;
								else
									-- {}で挟まれた文字がある場合、{}の部分とその外の部分とに分ける
									strEscapeFamilyName = string.sub(strOriginalFamilyName, 1, foundPlace);
									strFamilyName = string.sub(strOriginalFamilyName, foundPlace + 1);
								end
								if Me.MemoriseList[strFamilyName] ~= nil then
									-- 過去の翻訳履歴がある場合はそれを取得して設定する
									strTranslatedFamilyName = Me.MemoriseList[strFamilyName];
								else
									strTranslatedFamilyName = strFamilyName;
									NeedTranslate = true;
								end
							end
							local frameGivenName = pcTxtFrame:GetChild("givenName");
							local strGivenName = "GivenName";
							local strOriginalGivenName = strGivenName;
							local strTranslatedGivenName = strGivenName;
							local strEscapeGivenName = "";
							local PosX_GivenName = 0;
							local PosY_GivenName = 0;
							if nil ~= frameGivenName then
								strOriginalGivenName = frameGivenName:GetText();
								local BeforeMargin = frameGivenName:GetMargin();
								-- log(BeforeMargin.left .. ", " .. BeforeMargin.top)
								PosX_GivenName = BeforeMargin.left;
								PosY_GivenName = BeforeMargin.top;
								local foundPlace = string.find(strOriginalGivenName, "}");
								if foundPlace == nil then
									-- {}で挟まれた文字がない場合、すべての文字を返す
									strEscapeGivenName = "";
									strGivenName = strOriginalGivenName;
								else
									-- {}で挟まれた文字がある場合、{}の部分とその外の部分とに分ける
									strEscapeGivenName = string.sub(strOriginalGivenName, 1, foundPlace);
									strGivenName = string.sub(strOriginalGivenName, foundPlace + 1);
								end
								if Me.MemoriseList[strGivenName] ~= nil then
									-- 過去の翻訳履歴がある場合はそれを取得して設定する
									strTranslatedGivenName = Me.MemoriseList[strGivenName];
								else
									strTranslatedGivenName = strGivenName;
									NeedTranslate = true;
								end
							end
							-- 新規登録
							Me.PCHandleList[strHandle] = {
								LiveChecked = true;
								DataSend = not NeedTranslate;
								Original = {
									guildName = strGuildName;
									givenName = strGivenName;
									familyName = strFamilyName;
									escapeGuildName = strEscapeGuildName;
									escapeGivenName = strEscapeGivenName;
									escapeFamilyName = strEscapeFamilyName;
									w_GuildName = guildNameFrameWidth;
									x_GuildEmblem = PosX_GuildEmblem;
									y_GuildEmblem = PosY_GuildEmblem;
									x_FamilyName = PosX_FamilyName;
									y_FamilyName = PosY_GivenName;
									x_GivenName = PosX_GivenName;
									y_GivenName = PosY_GivenName;
								};
								Translated = {
									guildName = strTranslatedGuildName;
									givenName = strTranslatedGivenName;
									familyName = strTranslatedFamilyName;
									escapeGuildName = strEscapeGuildName;
									escapeGivenName = strEscapeGivenName;
									escapeFamilyName = strEscapeFamilyName;
									w_GuildName = guildNameFrameWidth;
									x_GuildEmblem = PosX_GuildEmblem;
									y_GuildEmblem = PosY_GuildEmblem;
									x_FamilyName = PosX_GivenName;
									y_FamilyName = PosY_GivenName + 24;
									x_GivenName = PosX_GivenName;
									y_GivenName = PosY_GivenName;
								};
							};
							-- log("add [" .. strHandle .. "]=> Guild:" .. strGuildName .. " FamilyName:" .. strFamilyName .. " GivenName:" .. strGivenName)
						else
							-- 生存確認
							Me.PCHandleList[strHandle].LiveChecked = true;
						end
						if not Me.PCHandleList[strHandle].DataSend then
							-- 翻訳依頼を行う
							local CurrentData = Me.PCHandleList[strHandle].Original;
							local hFile = io.open(SendTsvFile, "a");
							if Me.MemoriseList[CurrentData.guildName] == nil then
								hFile:write(string.format("%s\t%s\t%s\n", strHandle, "guildName", CurrentData.guildName));
							end
							if Me.MemoriseList[CurrentData.familyName] == nil then
								hFile:write(string.format("%s\t%s\t%s\n", strHandle, "familyName", CurrentData.familyName));
							end
							if Me.MemoriseList[CurrentData.givenName] == nil then
								hFile:write(string.format("%s\t%s\t%s\n", strHandle, "givenName", CurrentData.givenName));
							end
							hFile:close();
							Me.PCHandleList[strHandle].DataSend = true;
						end
					end
				end
			end
		end
	end
end

function Me.ReceiveFile()
	local hFile, err = io.open(ResultTsvFile, "r");
	if hFile and not err then
		for rawText in hFile:lines() do
			local StartNum, EndNum, pHandle, pType, pResultText, pOriginalText = string.find(rawText, "^%c?([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)$");
			local FoundResult = string.find(tostring(pHandle), "SELL_BALLOON_");
			if FoundResult ~= nil then
				-- 露店名の場合
				if Me.ShopHandleList[pHandle] ~= nil then
					if pResultText ~= "" then
						-- 翻訳成功
						local CurrentData = Me.ShopHandleList[pHandle].Translated;
						CurrentData.title = pResultText;
						AppendMemoriseList(Me.ShopHandleList[pHandle].Original.title, pResultText)
					else
						-- 翻訳失敗
						Me.ShopHandleList[pHandle].DataSend = false;
					end
				end
			else
				-- 人名の場合
				if Me.PCHandleList[pHandle] ~= nil then
					if pResultText ~= "" then
						-- 翻訳成功
						local CurrentData = Me.PCHandleList[pHandle].Translated;
						CurrentData[pType] = pResultText;
						AppendMemoriseList(Me.PCHandleList[pHandle].Original[pType], pResultText)
					else
						-- 翻訳失敗
						Me.PCHandleList[pHandle].DataSend = false;
					end
				end
			end
		end
		hFile:close();
		os.remove(ResultTsvFile);
		Toukibi:AddLog("新しい翻訳結果が追加されました。", "Notice", true, false);
	end
end

-- 全プレイヤーの名前を入れ替える
function Me.Switch_NamePlate()
	local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 1000, "ALL");
	for i = 1, selectedObjectsCount do
		local handle = GetHandle(selectedObjects[i]);
		if handle ~= nil then
			if info.IsPC(handle) == 1 then
				local shopFrame = ui.GetFrame("SELL_BALLOON_" .. handle);
				if shopFrame ~= nil then
					-- 露店の場合
					local strHandle = tostring("SELL_BALLOON_" .. handle);
					if Me.ShopHandleList[strHandle] ~= nil then
						local CurrentData = Me.ShopHandleList[strHandle].Translated;
						local sellType = tonumber(shopFrame:GetUserValue("SELL_TYPE"));
						if  sellType == AUTO_SELL_BUFF 
								or sellType == AUTO_SELL_GEM_ROASTING 
								or sellType == AUTO_SELL_SQUIRE_BUFF 
								or sellType == AUTO_SELL_ENCHANTERARMOR 
								or sellType == AUTO_SELL_APPRAISE
								or sellType == AUTO_SELL_PORTAL then

							local frameLvBox = shopFrame:GetChild("withLvBox");
							if frameLvBox ~= nil then
								frameShopName = frameLvBox:GetChild(CurrentData.type);
								if frameShopName ~= nil then
									table.insert(Me.SwitchShopFrameList, strHandle);
									frameShopName:SetTextByKey("value", CurrentData.title);
								end
							end
						else
							local frameShopName = shopFrame:GetChild(CurrentData.type);
							if frameShopName ~= nil then
								table.insert(Me.SwitchShopFrameList, strHandle);
								frameShopName:SetTextByKey("value", CurrentData.title);
							end
						end
					end
				else
					-- 人名の場合
					local strHandle = tostring(handle);
					if Me.PCHandleList[strHandle] ~= nil then
						local CurrentData = Me.PCHandleList[strHandle].Translated;
						local FrameName = "charbaseinfo1_" .. strHandle;
						local pcTxtFrame = ui.GetFrame(FrameName);
						if pcTxtFrame ~= nil then
							table.insert(Me.SwitchPCFrameList, FrameName);
							local frameGuildName = pcTxtFrame:GetChild("guildName");
							local newGuildNameWidth = 400;
							if nil ~= frameGuildName then
								frameGuildName:SetText(CurrentData.escapeGuildName .. CurrentData.guildName);
								newGuildNameWidth = frameGuildName:GetWidth();
							end
							local frameGuildEmblem = pcTxtFrame:GetChild("guildEmblem");
							if nil ~= frameGuildEmblem then
								funcSetMargin(frameGuildEmblem, CurrentData.x_GuildEmblem - (newGuildNameWidth - CurrentData.w_GuildName) / 2, nil, nil, nil);
							end
							local frameFamilyName = pcTxtFrame:GetChild("familyName");
							if nil ~= frameFamilyName then
								frameFamilyName:SetText(CurrentData.escapeFamilyName .. CurrentData.familyName);
								funcSetMargin(frameFamilyName, CurrentData.x_FamilyName, CurrentData.y_FamilyName, nil, nil);
							end
							local frameGivenName = pcTxtFrame:GetChild("givenName");
							if nil ~= frameGivenName then
								frameGivenName:SetText(CurrentData.escapeGivenName .. CurrentData.givenName);
							end
						end
					end
				end
			end
		end
	end
end

-- 全プレイヤーの名前を元に戻す
function Me.Restore_NamePlate()
	-- 人名
	while #Me.SwitchPCFrameList >= 1 do
		local v = table.remove(Me.SwitchPCFrameList);
		local strHandle = string.gsub(v, "charbaseinfo1_", "");
		local pcTxtFrame = ui.GetFrame(v);
		-- log(strHandle)
		if pcTxtFrame ~= nil then
			-- log("Frame Found")
			if Me.PCHandleList[strHandle] ~= nil then
				-- log("Data Found")
				local CurrentData = Me.PCHandleList[strHandle].Original;
				local frameGuildName = pcTxtFrame:GetChild("guildName");
				if nil ~= frameGuildName then
					frameGuildName:SetText(CurrentData.escapeGuildName .. CurrentData.guildName);
				end
				local frameGuildEmblem = pcTxtFrame:GetChild("guildEmblem");
				if nil ~= frameGuildEmblem then
					funcSetMargin(frameGuildEmblem, CurrentData.x_GuildEmblem, nil, nil, nil);
				end
				local frameFamilyName = pcTxtFrame:GetChild("familyName");
				if nil ~= frameFamilyName then
					frameFamilyName:SetText(CurrentData.escapeFamilyName .. CurrentData.familyName);
					-- log(CurrentData.familyName)
					funcSetMargin(frameFamilyName, CurrentData.x_FamilyName, CurrentData.y_FamilyName, nil, nil);
					-- log("Position Restored")
				end
				local frameGivenName = pcTxtFrame:GetChild("givenName");
				if nil ~= frameGivenName then
					frameGivenName:SetText(CurrentData.escapeGivenName .. CurrentData.givenName);
				end
			end
		end
	end
	-- 露店名
	while #Me.SwitchShopFrameList >= 1 do
		local v = table.remove(Me.SwitchShopFrameList);
		local strHandle = v;
		local objShopFrame = ui.GetFrame(v);
		if objShopFrame ~= nil then	
			if Me.ShopHandleList[strHandle] ~= nil then
				local sellType = tonumber(objShopFrame:GetUserValue("SELL_TYPE"));
				if  sellType == AUTO_SELL_BUFF 
						or sellType == AUTO_SELL_GEM_ROASTING 
						or sellType == AUTO_SELL_SQUIRE_BUFF 
						or sellType == AUTO_SELL_ENCHANTERARMOR 
						or sellType == AUTO_SELL_APPRAISE
						or sellType == AUTO_SELL_PORTAL then

					local frameLvBox = objShopFrame:GetChild("withLvBox");
					if frameLvBox ~= nil then
						local CurrentData = Me.ShopHandleList[strHandle].Original;
						local frameShopName = frameLvBox:GetChild(CurrentData.type);
						if nil ~= frameShopName then
							frameShopName:SetTextByKey("value", CurrentData.title);
						end
					end
				else
					local CurrentData = Me.ShopHandleList[strHandle].Original;
					local frameShopName = objShopFrame:GetChild(CurrentData.type);
					if nil ~= frameShopName then
						frameShopName:SetTextByKey("value", CurrentData.title);
					end
				end
			end
		end
	end
end

function Me.UpdateData()
	Me.ReceiveFile();
	Me.AddNamePlateList();

	-- Ctrlの押下状態に応じて処理を切り替える
	local isPressed = false;
	if FunctionExists(keyboard.IsPressed) then
		-- 2018/06/27パッチ前
		isPressed = (keyboard.IsPressed(KEY_CTRL) == 1);
	elseif FunctionExists(keyboard.IsKeyPressed) then
		-- 2018/06/27パッチ後
		isPressed = (keyboard.IsKeyPressed("LCTRL") == 1 or keyboard.IsKeyPressed("RCTRL") == 1);
	else
		-- どっちの関数もなかった場合
		isPressed = false;
	end
	
	if isPressed then
		-- Ctrlキーが押されている間はキャラクター情報を翻訳結果の表示にする
		Me.Switch_NamePlate();
	else
		-- 押されていない場合は名前を入れ替えたフレームをすべて元に戻す
		Me.Restore_NamePlate();
	end
end

function Me.RestartAddon()
	-- はじめにCtrlを押している状態を解除する
	Me.Restore_NamePlate();
	-- 保持している翻訳データを開放する
	Me.PCHandleList = {};
	Me.ShopHandleList = {};
	Toukibi:AddLog("現在保持していた翻訳データを放棄しました。(ファイルに保存したデータは破棄していません)", "Caution", true, false);
	-- 通常処理に戻る 
	Me.UpdateData();
end

function TOUKIBI_KOJA_NAME_TRANSLATER_UPDATE()
	Me.UpdateData();
end

function TOUKIBI_KOJA_NAME_TRANSLATER_RECEIVEFILE()
	Me.ReceiveFile();
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取
function TOUKIBI_KOJA_NAME_TRANSLATER_PROCESS_COMMAND(command)
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
	elseif cmd == "restart" then
		-- 保持している翻訳結果を破棄して再度1から処理を行う(ファイルに保存した結果は破棄しない)
		Me.RestartAddon();
		
		return;
	elseif cmd == "update" then
		-- Updateの処理をここに書く
		Me.UpdateData();
		
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

LoadMemoriseList()
Me.HoockedOrigProc = Me.HoockedOrigProc or {};
function KOJA_NAME_TRANSLATER_ON_INIT(addon, frame)
	-- 設定を読み込む
	if not Me.Loaded then
		Me.Loaded = true;
		os.execute('cmd /c ""' .. TranslaterExe .. ' & exit""');
		LoadSetting();
	end
	if Me.Settings.DoNothing then return end
	
	--タイマーを使う場合
	Me.Timer_FileReceive = GET_CHILD(ui.GetFrame("koja_name_translater"), "timer_filereceive", "ui::CAddOnTimer");
	Me.Timer_FileReceive:SetUpdateScript("TOUKIBI_KOJA_NAME_TRANSLATER_RECEIVEFILE");
	Me.Timer_FileReceive:Start(1);
	-- イベントを登録する
	--addon:RegisterMsg('GAME_START', 'TOUKIBI_KOJA_NAME_TRANSLATER_ON_GAME_START');
	addon:RegisterMsg("FPS_UPDATE", "TOUKIBI_KOJA_NAME_TRANSLATER_UPDATE");

	--Toukibi:SetHook("MAP_OPEN", Me.MAP_OPEN_HOOKED);


	-- スラッシュコマンドを使う場合
	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_KOJA_NAME_TRANSLATER_PROCESS_COMMAND);
	end
end

