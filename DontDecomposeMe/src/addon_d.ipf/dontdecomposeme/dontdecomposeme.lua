local addonName = "DontDecomposeMe";
local verText = "1.01";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {} -- {"/コマンド1", "/コマンド2", .......};
local CommandParamList = {
	reset = {jp = "設定リセット", en = "Reset the all settings."},
	update = {jp = "表示を更新", en = "The additional information displayed will be updated."}
};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
--[アドオン名] = Me;
local DebugMode = false;

-- テキストリソース
local ResText = {
	jp = {
		UI = {
			Reinforced = "強化済み品"
		  , Appraised = "鑑定済み品"
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
		UI = {
			Reinforced = "Reinforced Item"
		  , Appraised = "Identified Item"
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
	Me.Settings.Movable = Toukibi:GetValueOrDefault(Me.Settings.Movable, false, Force);
	Me.Settings.Visible = Toukibi:GetValueOrDefault(Me.Settings.Visible, true, Force);




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

function Me.AddItemInfo()
	local TopParent = ui.GetFrame("itemdecompose");
	if TopParent == nil or TopParent:IsVisible() == 0 then return end
	-- スロットの中身を調べる
	local slotSet = GET_CHILD_RECURSIVELY(TopParent, "itemSlotset", "ui::CSlotSet")	
	local slotCount = slotSet:GetSlotCount();
	for i = 0, slotCount - 1 do
		local slot = slotSet:GetSlotByIndex(i);
		local objIcon = slot:GetIcon();
		DESTROY_CHILD_BYNAME(slot, "Toukibi");
		if objIcon ~= nil then
			local iconInfo = objIcon:GetInfo();
			local objItem = GetIES(GET_ITEM_BY_GUID(iconInfo:GetIESID()):GetObject());
			local ReinforceValue = TryGetProp(objItem, "Reinforce_2")
			if ReinforceValue > 0 then
				-- 強化済み品は数値を表記する
				local txtReinforce = tolua.cast(slot:CreateOrGetControl("richtext", "Toukibi_ReinforceValue", 0, 0, 30, 16), "ui::CRichText");
				txtReinforce:SetGravity(ui.RIGHT, ui.BOTTOM);
				txtReinforce:SetMargin(0, 0, 1, -1);
				txtReinforce:EnableHitTest(0);
				txtReinforce:SetText(string.format("{#EEEEEE}{s16}{ol}{b}{ds}+%d{/}{/}{/}{/}{/}", ReinforceValue));
			end
			local NeedAppraisal = TryGetProp(objItem, "NeedAppraisal");
			local NeedRandomOption = TryGetProp(objItem, "NeedRandomOption");	
			objIcon:SetColorTone("FFFFFFFF");
			if NeedAppraisal ~= nil  or  NeedRandomOption ~= nil then
				if NeedAppraisal == 1 or NeedRandomOption == 1 then
					-- 未鑑定品は虫眼鏡マークを右下につける
					-- かつ、アイテムの表示色を暗くする
					local size = 24;
					local picNotAppraisal = tolua.cast(slot:CreateOrGetControl("picture", "Toukibi_NotAppraisal", 0, 0, size, size), "ui::CPicture");
					picNotAppraisal:SetGravity(ui.RIGHT, ui.BOTTOM);
					picNotAppraisal:SetMargin(0, 0, 3, 1);
					picNotAppraisal:EnableHitTest(0);
					picNotAppraisal:SetEnableStretch(1);
					picNotAppraisal:SetImage("minimap_Appraisers");
					picNotAppraisal:ShowWindow(1);
					objIcon:SetColorTone("FF111111");
				end
			end
		
			local itemGrade = TryGetProp(objItem, 'ItemGrade');
			if itemGrade == nil then
				itemGrade = 0;
			end
			local rankName = "";
			if     itemGrade == 0 then rankName = "";
			elseif itemGrade == 1 then rankName = "";
			elseif itemGrade == 2 then rankName = "rare";
			elseif itemGrade == 3 then rankName = "epic";
			elseif itemGrade == 4 then rankName = "unique";
			elseif itemGrade == 5 then rankName = "legendary";
			else rankName = ""; -- no grade
			end

			if rankName ~= "" then
				-- 未鑑定品は虫眼鏡マークを右下につける
				-- かつ、アイテムの表示色を暗くする
				local size = 16;
				local picRank = tolua.cast(slot:CreateOrGetControl("picture", "Toukibi_Rank", 0, 0, size, size), "ui::CPicture");
				picRank:SetGravity(ui.LEFT, ui.TOP);
				picRank:SetMargin(0, 0, 0, 0);
				picRank:EnableHitTest(0);
				picRank:SetEnableStretch(1);
				picRank:SetImage("dontdecomposeme_mini_" .. rankName);
				picRank:ShowWindow(1);
			end
		end
	end
end

function Me.AddInfo(frame, itemGradeList)
	Me.AddItemInfo();
end

function Me.MakeBasicInfo()
	-- チェックボックスのチェック状態を取得する
	local TopParent = ui.GetFrame("itemdecompose");
	ITEM_DECOMPOSE_ALL_UNSELECT(TopParent);
	local itemTypeBoxFrame = GET_CHILD_RECURSIVELY(TopParent, "itemTypeBox", "ui::CGroupBox")

	local itemGradeList = {};
	
	itemGradeList[#itemGradeList + 1] = GET_CHILD_RECURSIVELY(itemTypeBoxFrame, "normal", "ui::CCheckBox"):IsChecked();
	itemGradeList[#itemGradeList + 1] = GET_CHILD_RECURSIVELY(itemTypeBoxFrame, "magic"	, "ui::CCheckBox"):IsChecked();
	itemGradeList[#itemGradeList + 1] = GET_CHILD_RECURSIVELY(itemTypeBoxFrame, "rare"	, "ui::CCheckBox"):IsChecked();
	itemGradeList[#itemGradeList + 1] = GET_CHILD_RECURSIVELY(itemTypeBoxFrame, "unique", "ui::CCheckBox"):IsChecked();
	-- 残金の項目を更新
	ITEM_DECOMPOSE_UPDATE_MONEY(itemTypeBoxFrame);

	local IncludeReinforced = GET_CHILD_RECURSIVELY(TopParent, "chkIncludeReinforced", "ui::CCheckBox"):IsChecked();
	local IncludeAppraised  = GET_CHILD_RECURSIVELY(TopParent, "chkIncludeAppraised" , "ui::CCheckBox"):IsChecked();
	-- ここからメイン処理
	local itemSlotSet = GET_CHILD_RECURSIVELY(TopParent, "itemSlotset", "ui::CSlotSet")
	local miscSlotSet = GET_CHILD_RECURSIVELY(TopParent, "slotlist", "ui::CSlotSet")

	itemSlotSet:ClearIconAll();
	miscSlotSet:ClearIconAll();
	
	local itemSlotCnt = 0
	
	local invItemList = session.GetInvItemList();
	local itemCount = session.GetInvItemList():Count();
	local index = invItemList:Head();
	for i = 0, itemCount - 1 do
		local invItem = invItemList:Element(index);
		if invItem ~= nil then
			local itemobj = GetIES(invItem:GetObject());

			
			local itemGrade = TryGetProp(itemobj, 'ItemGrade');
			if itemGrade == nil then itemGrade = 0 end

			local needToShow = true;
			if itemGradeList[itemGrade] == 0 then needToShow = false end

			if needToShow == true then
				if itemobj.ItemType == 'Equip' and itemobj.DecomposeAble ~= nil and itemobj.DecomposeAble == "YES" and itemobj.ItemType == 'Equip' and itemobj.UseLv >= 75 and invItem.isLockState == false  and itemGrade <= 4 then

					-- 追加条件
					local ReinforceValue = TryGetProp(itemobj, "Reinforce_2")
					if IncludeReinforced == 0 and ReinforceValue > 0 then needToShow = false end

					if IncludeAppraised == 0 then
						local NeedAppraisal = TryGetProp(itemobj, "NeedAppraisal");
						local NeedRandomOption = TryGetProp(itemobj, "NeedRandomOption");	
						if NeedAppraisal == 0 and NeedRandomOption == 0 then
							needToShow = false;
						end
					end

					if needToShow == true then
						local itemSlot = itemSlotSet:GetSlotByIndex(itemSlotCnt)
						if itemSlot == nil then
							break;
						end
						
						local icon = CreateIcon(itemSlot);
						icon:Set(itemobj.Icon, 'Item', invItem.type, itemSlotCnt, invItem:GetIESID());
						local class = GetClassByType('Item', invItem.type);
						ICON_SET_INVENTORY_TOOLTIP(icon, invItem, nil, class);
						
						itemSlotCnt = itemSlotCnt + 1;
					end
				end
			end
		end
		index = invItemList:Next(index);
	end

	RESET_SUCCESS(TopParent)
end

function Me.AddCheckBox()
	local TopParent = ui.GetFrame("itemdecompose");

	local chkIncludeAppraised = tolua.cast(TopParent:CreateOrGetControl('checkbox', "chkIncludeAppraised", 20, 465, 10, 10), "ui::CCheckBox");
	chkIncludeAppraised:SetText(Toukibi:GetStyledText(Toukibi:GetResText(ResText, Toukibi:GetDefaultLangCode(), "UI.Appraised"), {"@st66"})); 
	chkIncludeAppraised:SetGravity(ui.LEFT, ui.TOP);
	chkIncludeAppraised:SetClickSound("button_click_big");
	chkIncludeAppraised:SetOverSound("button_over");
	chkIncludeAppraised:ShowWindow(1);
	chkIncludeAppraised:SetEventScript(ui.LBUTTONDOWN, "DECOMPOSE_ITEM_GRADE_SET");

	local chkIncludeReinforced = tolua.cast(TopParent:CreateOrGetControl('checkbox', "chkIncludeReinforced", 200, 465, 100, 10), "ui::CCheckBox");
	chkIncludeReinforced:SetText(Toukibi:GetStyledText(Toukibi:GetResText(ResText, Toukibi:GetDefaultLangCode(), "UI.Reinforced"), {"@st66"})); 
	chkIncludeReinforced:SetGravity(ui.LEFT, ui.TOP);
	chkIncludeReinforced:SetClickSound("button_click_big");
	chkIncludeReinforced:SetOverSound("button_over");
	chkIncludeReinforced:ShowWindow(1);
	chkIncludeReinforced:SetEventScript(ui.LBUTTONDOWN, "DECOMPOSE_ITEM_GRADE_SET");
end

function Me.ITEMDECOMPOSE_UI_OPEN_HOOKED(frame, msg, arg1, arg2)
	Me.AddCheckBox();
	Me.HoockedOrigProc["ITEMDECOMPOSE_UI_OPEN"](frame, msg, arg1, arg2);
end

function Me.ITEM_DECOMPOSE_ITEM_LIST_HOOKED(frame, itemGradeList)
	-- Me.HoockedOrigProc["ITEM_DECOMPOSE_ITEM_LIST"](frame, itemGradeList);
	Me.MakeBasicInfo();
	Me.AddInfo(frame, itemGradeList);
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====


Me.HoockedOrigProc = Me.HoockedOrigProc or {};
function DONTDECOMPOSEME_ON_INIT(addon, frame)
	--[[
	-- 設定を読み込む
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	if Me.Settings.DoNothing then return end
	--]]

	-- イベントを登録する

	Toukibi:SetHook("ITEMDECOMPOSE_UI_OPEN", Me.ITEMDECOMPOSE_UI_OPEN_HOOKED);
	Toukibi:SetHook("ITEM_DECOMPOSE_ITEM_LIST", Me.ITEM_DECOMPOSE_ITEM_LIST_HOOKED);


end

