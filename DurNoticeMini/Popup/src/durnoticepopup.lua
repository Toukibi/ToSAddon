local addonName = "DurNoticePopup";
local verText = "1.03";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
local MyParent = _G['ADDONS'][autherName].DurNoticeMini;
DurPopup = Me;
local DebugMode = false;

CHAT_SYSTEM(addonName .. " " .. verText .. " loaded!");

-- テキストリソース
local ResText = {
	jp = {
		LabelText = {
			Title = "装備耐久一覧"
		}
	},
	en = {
		LabelText = {
			Title = "Equipment List"
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
	--DEVELOPERCONSOLE_PRINT_TEXT("{#444444}type of {#005500}"  .. objName .. "{/} is {#005500}" .. type(objValue) .. "{/}{/}", "white_16_ol");
	DEVELOPERCONSOLE_PRINT_TEXT("{nl} ")
	DEVELOPERCONSOLE_PRINT_VALUE(frame, "", objValue, "", nil, true);
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
--	CHAT_SYSTEM(string.format("{#333366}[%s]%s{/}", addonName, Toukibi:GetResText(ResText, CurrentLang, "Log.InitMsg")))
end
ShowInitializeMessage()


-- ***** 変数の宣言と設定 *****
Me.SettingFilePathName = string.format("../addons/%s/%s", "durnoticemini", SettingFileName);
Me.Loaded = false;

local function GetColor(pt, max, rev)

	local col = math.floor(pt * max);

	if col < 0 or col > max then
		if rev then
			return 0;
		end
		return max;
	end

	return col;
end

local function GET_RGB(dur, maxDur)

	local pt = dur / maxDur;

	local r = GetColor((1 - pt), 255, true);
	local g = GetColor(pt, 255);
	local b = GetColor(pt, 64);
	
	return string.format("FF%02x%02x%02x", r, g, b);
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

function Me.GetDurData()
	local eqTypes = {"RH", "LH", "SHIRT", "GLOVES", "PANTS", "BOOTS", "RING1", "RING2", "NECK", "TRINKET"};
	local ReturnValue = {}
	for i = 1, #eqTypes do
--		CHECK_DUR(Me.frame, eqTypes[i]);
		local eqTypeName = eqTypes[i]
		local eqlist = session.GetEquipItemList();
		local num = item.GetEquipSpotNum(eqTypeName)
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
	
		ReturnValue[eqTypeName] = nil;
		if eq.type ~= item.GetNoneItem(eq.equipSpot) then
			local obj = GetIES(eq:GetObject());
			ReturnValue[eqTypeName] = {
				eqTypeName = eqTypeName,
				Name = obj.Name,
				Dur = obj.Dur,
				MaxDur = obj.MaxDur,
				imgName = GET_ITEM_ICON_IMAGE(obj)
			};
		end
	end
	--view(ReturnValue)
	return ReturnValue;
end

local function CreateDurPanel(Parent, DurData, Index, Top)
	local width = Parent:GetWidth();
	local MinHeight = 44;
	Top = Top or (MinHeight * (Index - 1));

	local pnlBase = tolua.cast(Parent:CreateOrGetControl("controlset", "pnlDur_" .. Index, 
														0, Top, width, MinHeight), 
							   "ui::CControlSet");

	pnlBase:SetSkinName("None");
--	pnlBase:SetSkinName("tab2_btn");
	pnlBase:EnableHitTest(0);
	pnlBase:SetGravity(ui.LEFT, ui.TOP);

	local picImage = tolua.cast(pnlBase:CreateOrGetControl("picture", "itemimage", 2, 2, 36, 36), "ui::CPicture");
	picImage:SetGravity(ui.LEFT, ui.TOP);
	picImage:EnableHitTest(0);
	picImage:SetEnableStretch(1);
	picImage:EnableChangeMouseCursor(0);
	picImage:SetImage(DurData.imgName);

	local txtName = pnlBase:CreateOrGetControl("richtext", "name", 40, 6, 150, 16);
	txtName:SetGravity(ui.LEFT, ui.TOP);
	txtName:EnableHitTest(0);
	txtName:SetTextFixWidth(1);
	txtName:SetTextMaxWidth(150);
	txtName:SetText(Toukibi:GetStyledText(DurData.Name, {"#888888", "ol", "b", "s12"}));
	local NowTop = 6 + txtName:GetHeight() + 3;

	local intValue = DurData.Dur
	local intMaxValue = DurData.MaxDur
	-- ゲージを追加
	local objDurGauge = tolua.cast(pnlBase:CreateOrGetControl("gauge", "DurGauge", 46, NowTop, 69, 7), "ui::CGauge");
	if objDurGauge ~= nil then
		objDurGauge:ShowWindow(1);
		objDurGauge:SetGravity(ui.LEFT, ui.TOP);
		-- objDurGauge:SetMargin(0, 0, 0, 0);
		objDurGauge:SetSkinName(GetGaugeSkin(intValue, intMaxValue));
		if intValue > intMaxValue then intValue = intValue - intMaxValue end
		if DebugMode then
			objDurGauge:SetPoint(0,100); -- Gaugeのスキン変更を反映させるには値が変わる(厳密にはグラフィック更新)必要があるみたい
		end
		objDurGauge:SetPoint(intValue, intMaxValue);
	end

	local txtDurValue = pnlBase:CreateOrGetControl("richtext", "DurValue", 120, NowTop - 2, 54, 11);
	txtDurValue:SetGravity(ui.LEFT, ui.TOP);
	txtDurValue:EnableHitTest(0);
	txtDurValue:SetTextFixWidth(1);
	txtDurValue:SetTextMaxWidth(54);
	txtDurValue:SetText(Toukibi:GetStyledText(string.format("%4.2f{#222222}/%s{/}", DurData.Dur / 100, DurData.MaxDur / 100), {"#AAAA11", "ol", "b", "s11"}));
	NowTop = NowTop + txtDurValue:GetHeight() + 2

	if NowTop < MinHeight then NowTop = MinHeight end
	pnlBase:Resize(pnlBase:GetWidth(), NowTop);
	return NowTop
end

local function getKeysSortedByValue(tbl, sortFunction)
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end

  table.sort(keys, function(a, b)
    return sortFunction(tbl[a].Dur, tbl[b].Dur)
  end)

  return keys
end

local function UpdateControl(DurList)
	local BaseFrame = ui.GetFrame("durnoticepopup");
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlBase");
	GET_CHILD(BaseFrame, "title", "ui::CRichText"):SetText(Toukibi:GetStyledText(Toukibi:GetResText(ResText, MyParent.Settings.Lang, "LabelText.Title"), {"#063306", "ol", "b"}));
	local btnClose = GET_CHILD(BaseFrame, "close", "ui::CButton");
	if btnClose ~= nil then btnClose:Resize(24, 24) end
	--btnClose:SetMargin(0, 4, 4, 0);
	local NowTop = 0;
	if BodyGBox ~= nil then
		DESTROY_CHILD_BYNAME(BodyGBox, "pnl");
		local NowIndex = 1
		local sortedKeys = getKeysSortedByValue(DurList, function(a,b) return (a < b) end);
		for _, key in ipairs(sortedKeys) do
			NowTop = NowTop + CreateDurPanel(BodyGBox, DurList[key], NowIndex, NowTop);
			NowIndex = NowIndex + 1;
		end
		BodyGBox:Resize(BodyGBox:GetWidth(), NowTop + 4);
	end
	BaseFrame:Resize(BaseFrame:GetWidth(), NowTop + 34);

end

function Me.Update()
	local DurDataList = Me.GetDurData()
	UpdateControl(DurDataList)
end

function TOUKIBI_DURPOPUP_OPEN()
	Me.Update()
end

function TOUKIBI_DURPOPUP_UPDATE()
	Me.Update()
end

function TOUKIBI_DURPOPUP_LOSTFOCUS()
	--if Me.Settings.FloatMode then return end
	local BaseFrame = ui.GetFrame("durnoticepopup");
	if BaseFrame == nil then return end
	BaseFrame:SetDuration(0.2);
end

function TOUKIBI_DURPOPUP_ADDDURATION()
	local BaseFrame = ui.GetFrame("durnoticepopup");
	BaseFrame:SetDuration(0);
end

function TOUKIBI_DURPOPUP_CALLPOPUP()
	local BaseFrame = ui.GetFrame("durnoticepopup");
	BaseFrame:SetDuration(0);
	if BaseFrame:IsVisible() == 1 then return end
	local ParentFrame = ui.GetFrame("durnoticemini");
	
	BaseFrame:SetMargin(ParentFrame:GetX() + 20, ParentFrame:GetY() + ParentFrame:GetHeight(), 0, 0);
	BaseFrame:ShowWindow(1)
	Me.Update()
end

function TOUKIBI_DURPOPUP_CALLHIDE()
	local BaseFrame = ui.GetFrame("durnoticepopup");
	if BaseFrame:IsVisible() == 0 then return end
	--if Me.Settings.FloatMode then return end
	BaseFrame:ShowWindow(0)
end

function TOUKIBI_DURPOPUP_CALLCLOSE()
	local BaseFrame = ui.GetFrame("durnoticepopup");
	if BaseFrame:IsVisible() == 0 then return end
	--Me.Settings.FloatMode = false;
	--SaveSetting();
	BaseFrame:SetSkinName("tooltip1")
	BaseFrame:ShowWindow(0)
end

function TOUKIBI_DURPOPUP_END_DRAG()
	if not Me.Settings.Movable then return end
	local objFrame = ui.GetFrame("durnoticepopup")
	if objFrame == nil then return end
	--Me.Settings.FloatMode = true;
	--objFrame:SetSkinName("textview")
	objFrame:Invalidate()
	--Me.Settings.PosX = objFrame:GetX();
	--Me.Settings.PosY = objFrame:GetY();
	--SaveSetting();
end

function DURNOTICEPOPUP_ON_INIT(addon, frame)
	-- フックしたいイベントを記述

--	frame:SetEventScript(ui.LBUTTONUP, "DURNOTICE_DRAG_STOP");

	addon:RegisterMsg('UPDATE_ITEM_REPAIR', 'TOUKIBI_DURPOPUP_UPDATE');
	addon:RegisterMsg('ITEM_PROP_UPDATE', 'TOUKIBI_DURPOPUP_UPDATE');
	addon:RegisterMsg('EQUIP_ITEM_LIST_GET', 'TOUKIBI_DURPOPUP_UPDATE');
	addon:RegisterMsg('MYPC_CHANGE_SHAPE', 'TOUKIBI_DURPOPUP_UPDATE');
	addon:RegisterMsg('GAME_START', 'TOUKIBI_DURPOPUP_UPDATE');


	local BaseFrame = ui.GetFrame("durnoticepopup")
	BaseFrame:EnableMove(0);
	BaseFrame:ShowWindow(0);

	-- 読み込み完了処理を記述
	Me.loaded = true;

	frame:SetEventScript(ui.MOUSEMOVE, "TOUKIBI_DURPOPUP_ADDDURATION");
end
