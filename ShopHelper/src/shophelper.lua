local addonName = "ShopHelper";
local verText = "0.70";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
Me.HoockedOrigProc = Me.HoockedOrigProc or {};
Me.BuyHistory = Me.BuyHistory or {};
Me.SettingFilePathName = string.format("../addons/%s/settings.json", addonNameLower);
Me.FavoriteFilePathName = string.format("../addons/%s/favorite.json", addonNameLower);
Me.DebugMode = false;
Me.IsVillage = nil;
Me.loaded = false;

Me.enmFavoriteState = {
	NoData = 0,
	Blocked = -3,
	Liked = 3,
	Favorite = 5,
	Friend = 9
};
Me.enmDisplayState = {
	NoMark = 0,
	Never = -9,
	HateMark = -3,
	Dislike = -1,
	Liked = 1,
	Favorite = 3,
	Love = 9
};
-- ==================================
--  初期化関連
-- ==================================
-- For Debbug use
if Me.DebugMode then ShopHelper = Me end

function SHOPHELPER_ON_INIT(addon, frame)
	Me.SettingFrame = frame
	Me.AddonHandle = addon
	Me.RefreshMe(addon, frame);
	-- 現在地情報
	Me.IsVillage = (GetClass("Map", session.GetMapName()).isVillage == "YES") or false;
	-- 非表示中のフレームのリスト
	Me.HiddenFrameList = {};
	-- 読み込み完了処理を記述
	if not Me.loaded then
		--CHAT_SYSTEM(nil);
		session.ui.GetChatMsg():AddSystemMsg("[Add-ons]" .. addonName .. verText .. " loaded!", true);
	end
	Me.loaded = true;
end

function Me.CreateValueWithStyleCode(Value, Styles)
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
end

function TOUKIBI_SHOPHELPER_ADDLOG(Message, Mode, DisplayAddonName, OnlyDebugMode)
	if Me.Settings == nil then return end
	if Message == nil then return end
	if (not Me.DebugMode) and (not Me.Settings.ShowMessageLog) and Mode == "Info" then return end
	if (not Me.DebugMode) and OnlyDebugMode then return end
	local HeaderText = "";
	if DisplayAddonName then
		HeaderText = string.format("[%s]", addonName);
	end
	local MsgText = HeaderText .. Message;
	if Mode == "Info" then
		MsgText = Me.CreateValueWithStyleCode(MsgText, {"#333333"});
	elseif Mode == "Warning" then
		MsgText = Me.CreateValueWithStyleCode(MsgText, {"#331111"});
	elseif Mode == "Notice" then
		MsgText = Me.CreateValueWithStyleCode(MsgText, {"#333366"});
	else
		-- 何もしない
	end
	CHAT_SYSTEM(MsgText);
end

-- ==================================
--  設定関連
-- ==================================

-- デフォルトの設定に戻す
function Me.SetDefaultSetting(HideMsg)
	if not HideMsg then
		local LogMsg = "";
		if Me.Settings == nil or Me.ResText == nil or Me.ResText[Me.Settings.LangMode].Log == nil then
			if Me.Settings == nil or Me.Settings.LangMode == "jp" then
				LogMsg = "設定がリセットされました";
			else
				LogMsg = "Configuration was resetted.";
			end
		else
			LogMsg = Me.ResText[Me.Settings.LangMode].Log.ResetConfig
		end
		TOUKIBI_SHOPHELPER_ADDLOG(LogMsg, "Warning", true, false);
	end
	Me.Settings = Me.Settings or {};
	Me.Settings.DoNothing = Me.Settings.DoNothing or true;
	Me.Settings.LangMode = Me.Settings.LangMode or "jp";
	Me.Settings.ShowMessageLog = Me.Settings.ShowMessageLog or false;
	Me.Settings.ShowMsgBoxOnBuffShop = Me.Settings.ShowMsgBoxOnBuffShop or true;
	Me.Settings.UpdateAverage = Me.Settings.UpdateAverage or true;
	Me.Settings.AddInfoToBaloon = Me.Settings.AddInfoToBaloon or true;
	Me.Settings.EnableBaloonRightClick = Me.Settings.EnableBaloonRightClick or true;
	Me.Settings.AverageNCount = Me.Settings.AverageNCount or 30;
	Me.Settings.RecalcInterval = Me.Settings.RecalcInterval or 60;
	Me.Settings.IgnoreAwayValue = Me.Settings.IgnoreAwayValue or true;
	Me.SetDefaultPrice(HideMsg);
end

-- 平均価格をリセット
function Me.SetDefaultPrice(HideMsg)
	if not HideMsg then
		local LogMsg = "";
		if Me.Settings == nil or Me.ResText == nil or Me.ResText[Me.Settings.LangMode].Log == nil then
			if Me.Settings == nil or Me.Settings.LangMode == "jp" then
				LogMsg = "平均価格がリセットされました";
			else
				LogMsg = "Data of average-prices was resetted.";
			end
		else
			LogMsg = Me.ResText[Me.Settings.LangMode].Log.ResetAveragePrice
		end
		TOUKIBI_SHOPHELPER_ADDLOG(LogMsg, "Warning", true, false);
	end
	Me.Settings.AveragePrice = Me.Settings.AveragePrice or {};
	-- 平均価格
	Me.Settings.AveragePrice['21003'] = Me.Settings.AveragePrice['21003'] or 6500; -- ジェムロースティング
	Me.Settings.AveragePrice['10703'] = Me.Settings.AveragePrice['10703'] or 170; -- リペア
	Me.Settings.AveragePrice['40203'] = Me.Settings.AveragePrice['40203'] or 750; -- ブレス
	Me.Settings.AveragePrice['40205'] = Me.Settings.AveragePrice['40205'] or 850; -- サクラ
	Me.Settings.AveragePrice['40201'] = Me.Settings.AveragePrice['40201'] or 1050; -- アスパ
	-- 基数
	Me.Settings.Radix = Me.Settings.Radix or {};
	Me.Settings.Radix['21003'] = Me.Settings.Radix['21003'] or 50; -- ジェムロースティング
	Me.Settings.Radix['10703'] = Me.Settings.Radix['10703'] or 1; -- リペア
	Me.Settings.Radix['40203'] = Me.Settings.Radix['40203'] or 10; -- ブレス
	Me.Settings.Radix['40205'] = Me.Settings.Radix['40205'] or 10; -- サクラ
	Me.Settings.Radix['40201'] = Me.Settings.Radix['40201'] or 10; -- アスパ
	-- 郊外価格
	Me.Settings.Suburb = Me.Settings.Suburb or {};
	Me.Settings.Suburb['21003'] = Me.Settings.Suburb['21003'] or 100; -- ジェムロースティング
	Me.Settings.Suburb['10703'] = Me.Settings.Suburb['10703'] or 100; -- リペア
	Me.Settings.Suburb['40203'] = Me.Settings.Suburb['40203'] or 100; -- ブレス
	Me.Settings.Suburb['40205'] = Me.Settings.Suburb['40205'] or 100; -- サクラ
	Me.Settings.Suburb['40201'] = Me.Settings.Suburb['40201'] or 100; -- アスパ
end

-- 設定読み込み
function Me.LoadSetting()
	local LogMsg = "";
	if Me.Settings == nil or Me.ResText == nil or Me.ResText[Me.Settings.LangMode].Log == nil then
		if Me.Settings == nil or Me.Settings.LangMode == "jp" then
			LogMsg = "Me.LoadSettingが呼び出されました";
		else
			LogMsg = "[Me.LoadSetting] was called.";
		end
	else
		LogMsg = Me.ResText[Me.Settings.LangMode].Log.CallLoadSetting
	end
	TOUKIBI_SHOPHELPER_ADDLOG(LogMsg, "Info", true, true)
	local acutil = require("acutil");
	local objReadValue, error = acutil.loadJSON(Me.SettingFilePathName);
	if error then
		Me.SetDefaultSetting();
		Me.SaveSetting();
	else
		Me.Settings = objReadValue;
		Me.SetDefaultSetting(true)
	end
	-- お気に入り情報を読み出す
	objReadValue, error = acutil.loadJSON(Me.FavoriteFilePathName);
	if error then
		Me.FavoriteList = Me.FavoriteList or {};
		Me.SaveSetting();
	else
		Me.FavoriteList = objReadValue;
		Me.FavoriteList = Me.FavoriteList or {};
	end
	Me.Settings.OptionFrameIsAvailable = false;
end

-- 設定書き込み
function Me.SaveSetting()
	local LogMsg = "";
	if Me.Settings == nil or Me.ResText == nil or Me.ResText[Me.Settings.LangMode].Log == nil then
		if Me.Settings == nil or Me.Settings.LangMode == "jp" then
			LogMsg = "Me.SaveSettingが呼び出されました";
		else
			LogMsg = "[Me.SaveSetting] was called.";
		end
	else
		LogMsg = Me.ResText[Me.Settings.LangMode].Log.CallSaveSetting
	end
	TOUKIBI_SHOPHELPER_ADDLOG(LogMsg, "Info", true, true)
	if Me.Settings == nil then
		if Me.Settings == nil or Me.ResText == nil or Me.ResText[Me.Settings.LangMode].Log == nil then
			if Me.Settings == nil or Me.Settings.LangMode == "jp" then
				LogMsg = "Me.Settingが存在しないので標準の設定が呼び出されます";
			else
				LogMsg = "Since [Me.Setting] does not exist, use the default settings.";
			end
		else
			LogMsg = Me.ResText[Me.Settings.LangMode].Log.UseDefaultSetting
		end
		TOUKIBI_SHOPHELPER_ADDLOG(LogMsg, "Warning", true, false)
		Me.SetDefaultSetting()
	end
	if Me.Settings == nil or Me.ResText == nil or Me.ResText[Me.Settings.LangMode].Log == nil then
		if Me.Settings == nil or Me.Settings.LangMode == "jp" then
			LogMsg = "保存先:";
		else
			LogMsg = "Storage destination:";
		end
	else
		LogMsg = Me.ResText[Me.Settings.LangMode].data.SaveTo
	end
	TOUKIBI_SHOPHELPER_ADDLOG(LogMsg .. Me.SettingFilePathName, "Info", true, true)
	local acutil = require("acutil");
	acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
end

function Me.SaveFavoriteList()
	if Me.FavoriteList ~= nil then
		local acutil = require("acutil");
		acutil.saveJSON(Me.FavoriteFilePathName, Me.FavoriteList);
	end
end

function Me.SettingFrame_BeforeDisplay()
	local BaseFrame = ui.GetFrame("shophelper");
	if BaseFrame == nil then
		TOUKIBI_SHOPHELPER_ADDLOG(Me.ResText[Me.Settings.LangMode].Log.CannotGetSettingFrameHandle, "Warning", true, false);
		return;
	end
	Me.InitSettingValue(BaseFrame);
	Me.InitSettingText(BaseFrame);
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");
	if BodyGBox ~= nil then
		local objTab = GET_CHILD(BodyGBox, "ShopHelperSettingTab", "ui::CTabControl");
		if objTab ~= nil then
			objTab:SelectTab(0);
		end
		Me.ChangeActiveTab(BodyGBox);
	end
	Me.Settings.OptionFrameIsAvailable = true;
	BaseFrame:ShowWindow(1);
end

function Me.InitSettingText(BaseFrame, LangMode)
	LangMode = LangMode or Me.Settings.LangMode or "jp";
	-- 微調整
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");
	local OptionGBox = GET_CHILD_GROUPBOX(BodyGBox, "pnlOption");
	local PriceGBox = GET_CHILD_GROUPBOX(BodyGBox, "pnlPrice");

--[[
	OptionGBox:Resize(640,320);
	PriceGBox:Resize(640,440);
	PriceGBox:SetScrollBar(440);
	BodyGBox:Resize(650,610);
	BaseFrame:Resize(650, 640);
	GET_CHILD_GROUPBOX(BaseFrame, "pipwin_top"):Resize(650,60);

	-- ここまで転記完了
	-- GET_CHILD_GROUPBOX(frame, name) でグループボックスが取得可能
]]

	-- 言語切替対応
	local CurrentRes = Me.ResText[LangMode];
	if CurrentRes == nil then return end
	Me.SetControlText(GET_CHILD(BaseFrame, "title", "ui::CRichText"), 
					  CurrentRes.data.SettingFrameTitle, {"@st43"});
	local objTab = GET_CHILD(BodyGBox, "ShopHelperSettingTab", "ui::CTabControl");
	if objTab ~= nil then
		objTab:ChangeCaption(0, Me.CreateValueWithStyleCode(CurrentRes.data.TabGeneralSetting, {"@st66b"}));
		objTab:ChangeCaption(1, Me.CreateValueWithStyleCode(CurrentRes.data.TabAverageSetting, {"@st66b"}));
	end
	local TargetGBox = GET_CHILD_GROUPBOX(BodyGBox, "pnlOption");
	if TargetGBox ~= nil then
		Me.SetControlText(GET_CHILD(TargetGBox, "option_title", "ui::CRichText"), 
						  CurrentRes.data.GeneralSetting, {"@st43"});
		Me.SetControlText(GET_CHILD(TargetGBox, "ShowMessageLog", "ui::CCheckBox"), 
						  CurrentRes.data.ShowMessageLog, {"@st66b"});
		Me.SetControlText(GET_CHILD(TargetGBox, "ShowMsgBoxOnBuffShop", "ui::CCheckBox"), 
						  CurrentRes.data.ShowMsgBoxOnBuffShop, {"@st66b"});
		Me.SetControlText(GET_CHILD(TargetGBox, "AddInfoToBaloon", "ui::CCheckBox"), 
						  CurrentRes.data.AddInfoToBaloon, {"@st66b"});
		Me.SetControlText(GET_CHILD(TargetGBox, "EnableBaloonRightClick", "ui::CCheckBox"), 
						  CurrentRes.data.EnableBaloonRightClick, {"@st66b"});
		Me.SetControlText(GET_CHILD(TargetGBox, "UpdateAverage", "ui::CCheckBox"), 
						  CurrentRes.data.UpdateAverage, {"@st66b"});

		local TargetControl = GET_CHILD(TargetGBox, "AverageNCount_text", "ui::CRichText");
		Me.SetControlTextByKey(TargetControl, "opCaption", CurrentRes.data.AverageWeight)
		Me.SetControlTextByKey(TargetControl, "opUnit", CurrentRes.data.AverageWeightUnit)
		local TargetControl = GET_CHILD(TargetGBox, "RecalcInterval_text", "ui::CRichText");
		Me.SetControlTextByKey(TargetControl, "opCaption", CurrentRes.data.AverageUpdateInterval)
		Me.SetControlTextByKey(TargetControl, "opUnit", CurrentRes.data.AverageUpdateIntervalUnit)
		Me.SetControlText(GET_CHILD(TargetGBox, "NoUpdateIfFarther", "ui::CCheckBox"), 
						  CurrentRes.data.NoUpdateIfFartherValue, {"@st66b"});
	end
	TargetGBox = GET_CHILD_GROUPBOX(BodyGBox, "pnlPrice");
	local cnt = TargetGBox:GetChildCount();
	for i = 0, cnt - 1 do
		local ctrl = TargetGBox:GetChildByIndex(i);
		if string.find(ctrl:GetName(), "pnlPrice_") then
			Me.ChangePricePanelLang(ctrl, LangMode)
		end
	end
	Me.SetControlText(GET_CHILD(BodyGBox, "btn_excute", "ui::CButton"), 
						CurrentRes.data.Save, {"@st42"});
	Me.SetControlText(GET_CHILD(BodyGBox, "btn_cencel", "ui::CButton"), 
						CurrentRes.data.CloseMe, {"@st42"});
end

function Me.GetNumericValueFromEdit(ctrl)
	if ctrl == nil then return nil end
	return GetNumberFromCommaText(ctrl:GetText());
end

function Me.GetPriceInputValue(frame)
	if frame == nil then return end
	local AverageValue = Me.GetNumericValueFromEdit(GET_CHILD(frame, "txtAverage", "ui::CEditControl"));
	local RadixValue = Me.GetNumericValueFromEdit(GET_CHILD(frame, "txtRadix", "ui::CEditControl"));
	local SuburbValue = Me.GetNumericValueFromEdit(GET_CHILD(frame, "txtSuburb", "ui::CEditControl"));
	return AverageValue, RadixValue, SuburbValue;
end

function Me.UpdatePriceText(parent, ControlBaseName, value, CurrentHighestValue)
	local ctrl = GET_CHILD(parent, "value_" .. ControlBaseName, "ui::CRichText");
	if ctrl == nil then return CurrentHighestValue end
	Me.SetControlText(ctrl, Me.GetCommaedTextEx(value), {"@st66b", "s16"});
	if value > CurrentHighestValue then
		ctrl:ShowWindow(1);
		GET_CHILD(parent, "zone_" .. ControlBaseName, "ui::CRichText"):ShowWindow(1);
		GET_CHILD(parent, "bar_" .. ControlBaseName, "ui::CRichText"):ShowWindow(1);
		GET_CHILD(parent, "pointer_" .. ControlBaseName, "ui::CRichText"):ShowWindow(1);
		return value;
	else
		ctrl:ShowWindow(0);
		GET_CHILD(parent, "zone_" .. ControlBaseName, "ui::CRichText"):ShowWindow(0);
		GET_CHILD(parent, "bar_" .. ControlBaseName, "ui::CRichText"):ShowWindow(0);
		GET_CHILD(parent, "pointer_" .. ControlBaseName, "ui::CRichText"):ShowWindow(0);
		return CurrentHighestValue;
	end
end

function Me.UpdatePricePanel(ctrl)
	local pnlInput = nil;
	local Container = nil;
	if ctrl:GetName() == "pnlInput" then
		Container = ctrl:GetParent():GetParent();
		pnlInput = ctrl;
	else
		Container = ctrl;
		pnlInput = GET_CHILD(ctrl, "pnlInput", "ui::CGroupBox");
	end
	if Container ~= nil then
		-- 入力されている値を読む
		local AverageValue, RadixValue, SuburbValue = Me.GetPriceInputValue(pnlInput);
		local pnlGauge = GET_CHILD(Container, "pnlGauge", "ui::CGroupBox");
		local SkillID = Container:GetUserValue("SkillID");
		if pnlGauge ~= nil and SkillID ~= nil then
			local PriceInfo = Me.GetPriceInfo(tonumber(SkillID));
			local HighestValue = 0;
			HighestValue = Me.UpdatePriceText(pnlGauge, "BelowCost", PriceInfo.CostPrice, HighestValue);
			HighestValue = Me.UpdatePriceText(pnlGauge, "NearCost", PriceInfo.CostPrice + RadixValue * 3, HighestValue);
			HighestValue = Me.UpdatePriceText(pnlGauge, "GoodValue", AverageValue - RadixValue * 2, HighestValue);
			HighestValue = Me.UpdatePriceText(pnlGauge, "WithinAverage", AverageValue + RadixValue * 5, HighestValue);
			HighestValue = Me.UpdatePriceText(pnlGauge, "ALittleExpensive", AverageValue + RadixValue * 20, HighestValue);
			local RipOffValue = math.min(AverageValue * 1.8, AverageValue + RadixValue * 100);
			HighestValue = Me.UpdatePriceText(pnlGauge, "Expensive", RipOffValue, HighestValue);
		end
	end
end

function Me.ChangePricePanelLang(BaseContainer, LangMode)
	LangMode = LangMode or Me.Settings.LangMode or "jp";
	if BaseContainer == nil then return end
	local CurrentRes = Me.ResText[LangMode];
	if CurrentRes == nil then return end
	local pnlInput = GET_CHILD(BaseContainer, "pnlInput", "ui::CGroupBox");
	if pnlInput ~= nil then
		Me.SetControlText(GET_CHILD(pnlInput, "lblSuburb", "ui::CRichText"), 
						  CurrentRes.data.RuralCharge, {"@st66b"});
		Me.SetControlText(GET_CHILD(pnlInput, "lblRadix", "ui::CRichText"), 
						  CurrentRes.data.PriceRadix, {"@st66b"});
		Me.SetControlText(GET_CHILD(pnlInput, "lblAverage", "ui::CRichText"), 
						  CurrentRes.data.AveragePrice, {"@st66b"});

	end
	local pnlGauge = GET_CHILD(BaseContainer, "pnlGauge", "ui::CGroupBox");
	if pnlGauge ~= nil then
		Me.SetControlText(GET_CHILD(pnlGauge, "zone_BelowCost", "ui::CRichText"), 
						  CurrentRes.data.zone_BelowCost, {"@st66b", "s12"});
		Me.SetControlText(GET_CHILD(pnlGauge, "zone_NearCost", "ui::CRichText"), 
						  CurrentRes.data.zone_NearCost, {"@st66b", "s12"});
		Me.SetControlText(GET_CHILD(pnlGauge, "zone_GoodValue", "ui::CRichText"), 
						  CurrentRes.data.zone_GoodValue, {"@st66b", "s12"});
		Me.SetControlText(GET_CHILD(pnlGauge, "zone_WithinAverage", "ui::CRichText"), 
						  CurrentRes.data.zone_WithinAverage, {"@st66b", "s12"});
		Me.SetControlText(GET_CHILD(pnlGauge, "zone_ALittleExpensive", "ui::CRichText"), 
						  CurrentRes.data.zone_ALittleExpensive, {"@st66b", "s12"});
		Me.SetControlText(GET_CHILD(pnlGauge, "zone_Expensive", "ui::CRichText"), 
						  CurrentRes.data.zone_Expensive, {"@st66b", "s12"});
		Me.SetControlText(GET_CHILD(pnlGauge, "zone_RipOff", "ui::CRichText"), 
						  CurrentRes.data.zone_RipOff, {"@st66b", "s12"});
	end
end

function Me.InitSettingValue(BaseFrame)
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");
	if BodyGBox == nil then return end
	local ModeGBox = GET_CHILD_GROUPBOX(BodyGBox, "pnlOption");
	Me.SetCheckedStateByName(ModeGBox, "ShowMessageLog", Me.Settings.ShowMessageLog);
	Me.SetCheckedStateByName(ModeGBox, "ShowMsgBoxOnBuffShop", not Me.Settings.ShowMsgBoxOnBuffShop);
	Me.SetCheckedStateByName(ModeGBox, "AddInfoToBaloon", Me.Settings.AddInfoToBaloon);
	Me.SetCheckedStateByName(ModeGBox, "EnableBaloonRightClick", Me.Settings.EnableBaloonRightClick);
	Me.SetCheckedStateByName(ModeGBox, "UpdateAverage", Me.Settings.UpdateAverage);
	Me.SetSliderValue(ModeGBox, "AverageNCount", "AverageNCount_text", math.floor(Me.Settings.AverageNCount / 10), Me.Settings.AverageNCount);
	Me.SetSliderValue(ModeGBox, "RecalcInterval", "RecalcInterval_text", math.floor(Me.Settings.RecalcInterval / 10), Me.Settings.RecalcInterval);
	Me.SetCheckedStateByName(ModeGBox, "NoUpdateIfFarther", Me.Settings.IgnoreAwayValue);

	local PriceGBox = GET_CHILD_GROUPBOX(BodyGBox, "pnlPrice");
	PriceGBox:RemoveAllChild();
	Me.CreatePriceBaseCtrlSet(PriceGBox, 40203, 1);
	Me.CreatePriceBaseCtrlSet(PriceGBox, 40205, 2);
	Me.CreatePriceBaseCtrlSet(PriceGBox, 40201, 3);
	Me.CreatePriceBaseCtrlSet(PriceGBox, 10703, 4);
	Me.CreatePriceBaseCtrlSet(PriceGBox, 21003, 5);
end

function Me.OpenSettingFrame()
	Me.SettingFrame_BeforeDisplay();
end

function Me.CloseSettingFrame()
	local BaseFrame = ui.GetFrame("shophelper");
	if BaseFrame == nil then
		TOUKIBI_SHOPHELPER_ADDLOG(Me.ResText[Me.Settings.LangMode].Log.CannotGetSettingFrameHandle, "Warning", true, false);
		return;
	end
	Me.Settings.OptionFrameIsAvailable = false;
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");
	if BodyGBox ~= nil then
		local PriceGBox = GET_CHILD_GROUPBOX(BodyGBox, "pnlPrice");
		if PriceGBox ~= nil then
			PriceGBox:RemoveAllChild();
		end
	end
	BaseFrame:ShowWindow(0);
end

function Me.ExecSetting()
	local BaseFrame = ui.GetFrame("shophelper");
	if BaseFrame == nil then
		TOUKIBI_SHOPHELPER_ADDLOG(Me.ResText[Me.Settings.LangMode].Log.CannotGetSettingFrameHandle, "Warning", true, false);
		return;
	end
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");
	if BodyGBox == nil then return end
	Me.Settings.LangMode = Me.GetSelectedRadioButton(Me.GetLangSeedRadioButton("lang_jp"));
	local ModeGBox = GET_CHILD_GROUPBOX(BodyGBox, "pnlOption");
	Me.Settings.ShowMessageLog = Me.GetCheckedStateByName(ModeGBox, "ShowMessageLog");
	Me.Settings.ShowMsgBoxOnBuffShop = not Me.GetCheckedStateByName(ModeGBox, "ShowMsgBoxOnBuffShop");
	Me.Settings.AddInfoToBaloon = Me.GetCheckedStateByName(ModeGBox, "AddInfoToBaloon");
	Me.Settings.EnableBaloonRightClick = Me.GetCheckedStateByName(ModeGBox, "EnableBaloonRightClick");
	Me.Settings.UpdateAverage = Me.GetCheckedStateByName(ModeGBox, "UpdateAverage");
	local intValue;
	intValue = Me.GetSliderValueByName(ModeGBox, "AverageNCount");
	if intValue ~= nil then
		Me.Settings.AverageNCount = intValue * 10
	end
	intValue = Me.GetSliderValueByName(ModeGBox, "RecalcInterval");
	if intValue ~= nil then
		Me.Settings.RecalcInterval = intValue * 10
	end
	Me.Settings.IgnoreAwayValue = Me.GetCheckedStateByName(ModeGBox, "NoUpdateIfFarther");

	local PriceGBox = GET_CHILD_GROUPBOX(BodyGBox, "pnlPrice");
	if PriceGBox ~= nil then
		local cnt = PriceGBox:GetChildCount();
		for i = 0, cnt - 1 do
			local Container = PriceGBox:GetChildByIndex(i);
			if string.find(Container:GetName(), "pnlPrice_") then
				-- 入力されている値を読む
				local SkillID = Container:GetUserValue("SkillID");
				local AverageValue, RadixValue, SuburbValue = Me.GetPriceInputValue(GET_CHILD(Container, "pnlInput", "ui::CGroupBox"));
				-- CHAT_SYSTEM(string.format("%s: %s, %s, %s", SkillID, AverageValue, RadixValue, SuburbValue))
				Me.Settings.AveragePrice[tostring(SkillID)] = AverageValue;
				Me.Settings.Radix[tostring(SkillID)] = RadixValue;
				Me.Settings.Suburb[tostring(SkillID)] = SuburbValue;
			end
		end
	end

	Me.SaveSetting();
	Me.CloseSettingFrame();
	Me.RedrawAllShopBaloon();
end

function Me.ChangeLanguage(Mode)
	local SettingTest = Me.ResText[Mode];
	local msg;
	if SettingTest == nil then
		msg = string.format("Sorry, 'ShopHelper' does not implement '%s' mode.{nl}Language mode has not been changed from '%s'.", 
							Mode, Me.Settings.LangMode);
		TOUKIBI_SHOPHELPER_ADDLOG(msg, "Warning", true, false)
		return;
	end
	Me.Settings.LangMode = Mode;
	Me.SaveSetting();
	if Me.Settings.LangMode == "jp" then
		msg = "日本語モードに切り替わりました";
	else
		msg = string.format("Language mode has been changed to '%s'.", Mode);
	end
	TOUKIBI_SHOPHELPER_ADDLOG(msg, "Notice", true, false);
end

function Me.ChangeActiveTab(frame, SelectedIndex)
	if frame == nil then return end
	SelectedIndex = SelectedIndex or 0;
	GET_CHILD_GROUPBOX(frame, "pnlLang"  ):ShowWindow((0 == SelectedIndex) and 1 or 0);
	GET_CHILD_GROUPBOX(frame, "pnlOption"):ShowWindow((0 == SelectedIndex) and 1 or 0);
	GET_CHILD_GROUPBOX(frame, "pnlPrice" ):ShowWindow((1 == SelectedIndex) and 1 or 0);
end

Me.LoadSetting();
-- Me.Settings.LangMode = "jp";


-- ==================================
--  イベント処理関連
-- ==================================

-- イベントの飛び先を変更するためのプロシージャ
function Me.setHook(newFunction, hookedFunctionStr)
	if Me.HoockedOrigProc[hookedFunctionStr] == nil then
		Me.HoockedOrigProc[hookedFunctionStr] = _G[hookedFunctionStr];
		_G[hookedFunctionStr] = newFunction;
	else
		_G[hookedFunctionStr] = newFunction;
	end
end 

function Me.AUTOSELLER_BALLOON_HOOKED(title, sellType, handle, skillID, skillLv) 
	-- CHAT_SYSTEM("AUTOSELLER_BALLOON_HOOKED実行");
	-- デフォルト状態のショップバルーンを作ってもらう
	Me.HoockedOrigProc["AUTOSELLER_BALLOON"](title, sellType, handle, skillID, skillLv); 
	Me.ADDTO_SHOPBALOON(title, sellType, handle, skillID, skillLv); 
end 

-- フックイベント中継
-- 修理/ジェムロースティング店を開くイベント
function Me.OPEN_ITEMBUFF_UI_HOOKED(groupName, sellType, handle) 
	Me.HoockedOrigProc["OPEN_ITEMBUFF_UI"](groupName, sellType, handle); 
	if sellType == AUTO_SELL_GEM_ROASTING then
		Me.AddInfoToGemRoasting(ui.GetFrame("itembuffgemroasting"));
	elseif sellType == AUTO_SELL_SQUIRE_BUFF then
		Me.AddInfoToSquireBuff(ui.GetFrame("itembuffrepair"));
	end
end 

-- バフ屋の各バフの項目が描画される時のイベント
function Me.UPDATE_BUFFSELLER_SLOT_TARGET_HOOKED(ctrlSet, info)
	Me.HoockedOrigProc["UPDATE_BUFFSELLER_SLOT_TARGET"](ctrlSet, info);
	Me.AddInfoToBuffSellerSlot(ctrlSet, info);
end

-- バフ屋の購入ボタンを押した時のイベント
function Me.BUY_BUFF_AUTOSELL_HOOKED(ctrlSet, btn)
	Me.btnBuyBuffAutosell_Click(ctrlSet, btn);
	-- 元の処理は下の通りだけど置き換えて元の処理には返さない
	-- Me.HoockedOrigProc["BUY_BUFF_AUTOSELL"](ctrlSet, btn);
end

-- 修理商店の修理ボタンを押した時のイベント (さりげに公式がスペルミス)
function Me.SQIORE_REPAIR_EXCUTE_HOOKED(parent)
	Me.btnBuySquireRepair_Click(parent)
	-- 元の処理は下の通りだけど置き換えて元の処理には返さない
	-- Me.HoockedOrigProc["SQIORE_REPAIR_EXCUTE"](parent);
end

-- ジェムロースティング商店の確認ボタンを押した時のイベント
function Me.GEMROASTING_EXCUTE_HOOKED(parent)
	Me.btnBuyGemRoasting_Click(parent)
	-- 元の処理は下の通りだけど置き換えて元の処理には返さない
	-- Me.HoockedOrigProc["GEMROASTING_EXCUTE"](parent);
end

-- 設定画面オープン
function TOUKIBI_SHOPHELPER_OPEN_SETTING()
	Me.SettingFrame_BeforeDisplay();
end

-- 設定保存
function TOUKIBI_SHOPHELPER_EXEC_SETTING()
	Me.ExecSetting();
end

-- 設定画面クローズ
function TOUKIBI_SHOPHELPER_CLOSE_SETTING()
	Me.CloseSettingFrame();
end

-- 右クリックイベント受取(マーク変更)
function TOUKIBI_SHOPHELPER_CHANGE_DISPLAYSTATE(handle, value)
	if handle == nil then return end
	local AID = world.GetActor(handle):GetPCApc():GetAID();
	if value == Me.enmDisplayState.NoMark then value = nil end
	Me.FavoriteList[AID] = value;
	Me.SaveFavoriteList()
	Me.RedrawShopBaloon(handle)
end

-- 言語切替
function TOUKIBI_SHOPHELPER_CHANGE_LANGMODE(frame, ctrl, str, num)
	local SelectedLang = Me.GetSelectedRadioButton(Me.GetLangSeedRadioButton("lang_jp"));
	Me.InitSettingText(frame:GetTopParentFrame(), SelectedLang);
end

-- コマンド受取
function TOUKIBI_SHOPHELPER_PROCESS_COMMAND(command)
	-- TOUKIBI_SHOPHELPER_ADDLOG("TOUKIBI_SHOPHELPER_PROCESS_COMMANDが呼び出されました", "Info", true, true)
	local cmd = ""; 
	if #command > 0 then 
		cmd = table.remove(command, 1); 
	else 
		Me.OpenSettingFrame();
		return;
	end 
	if cmd == "reset" then 
		-- 平均値をリセット
		Me.SetDefaultPrice(); 
		return; 
	elseif cmd == "resetall" then
		-- すべてをリセット
		Me.SetDefaultSetting()
		return;
	elseif cmd == "refresh" and Me.DebugMode then
		-- プログラムをリセット
		TOUKIBI_SHOPHELPER_ADDLOG(Me.ResText[Me.Settings.LangMode].Log.InitializeMe, "Notice", true, false);
		Me.RefreshMe(Me.AddonHandle, Me.SettingFrame);
		return;
	elseif cmd == "redraw" and Me.DebugMode then
		-- プログラムをリセット
		TOUKIBI_SHOPHELPER_ADDLOG(Me.ResText[Me.Settings.LangMode].Log.RedrawAllShopBaloon, "Notice", true, false);
		Me.RedrawAllShopBaloon();
		return;
	elseif cmd == "jp" or cmd == "en" or string.len(cmd) == 2 then
		-- 言語モードと勘違いした？
		Me.ChangeLanguage(cmd);
		return;
	elseif cmd ~= "?" then
		TOUKIBI_SHOPHELPER_ADDLOG(Me.ResText[Me.Settings.LangMode].data.InvalidCommand, "Warning", true, false);
	end 
	Me.PrintHelpToLog()
end

-- スライダーの値が変わった時のイベント
function TOUKIBI_SHOPHELPER_SLIDER_CHANGED(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	local ControlName = ctrl:GetName();
	local SettingName = nil;
	local CurrentValue = nil;
	local BuddyText = nil;
	if ControlName == "AverageNCount" or ControlName == "RecalcInterval" then
		SettingName = ControlName;
		CurrentValue = num * 10;
		BuddyText = GET_PARENT(ctrl):GetChild(ControlName .. "_text");
	end
	if SettingName ~= nil then
		Me.SetControlTextByKey(BuddyText, "opValue", CurrentValue)
	end
end

-- タブコントロールが押されたときのイベント
function TOUKIBI_SHOPHELPER_TAB_LMOUSEDOWN(frame, ctrl, str, num)
	local tabObj = frame:GetChild('ShopHelperSettingTab');
	local itembox_tab = tolua.cast(tabObj, "ui::CTabControl");
	local SelectedIndex = itembox_tab:GetSelectItemIndex();
	Me.ChangeActiveTab(frame, SelectedIndex);
end

function TOUKIBI_SHOPHELPER_PRICETEXT_CHANGED(parent, ctrl)
	if Me.Settings ~= nil and Me.Settings.OptionFrameIsAvailable then
		Me.UpdatePricePanel(parent, ctrl)
	end
end

-- 価格ゾーンポップアップ表示
function TOUKIBI_SHOPHELPER_SHOW_PRICETIP(frame, ctrl, str, num) 
	-- CHAT_SYSTEM(string.format( "%s, %s, %s, %s", frame:GetName(), ctrl:GetName(), str, num))
end 

function Me.MakeContextMenuSeparator(parent, width)
	width = width or 300;
	ui.AddContextMenuItem(parent, string.format("{img fullgray %s 1}", width), "None");
end

function Me.MakeContextMenuItem(parent, text, eventscp, icon, checked)
	local CheckIcon = "";
	local ImageIcon = "";
	local eventscp = eventscp or "None";
	if checked == nil then
		CheckIcon = "";
	elseif checked == true then
		CheckIcon = "{img socket_slot_check 24 24} ";
	elseif checked == false  then
		CheckIcon = "{img channel_mark_empty 24 24} "
	end
	if icon == nil then
		ImageIcon = "";
	else
		ImageIcon = string.format("{img %s 24 24} ", icon);
	end
	ui.AddContextMenuItem(parent, string.format("%s%s%s", CheckIcon, ImageIcon, text), eventscp);
end

--コンテキストメニュー表示 
function TOUKIBI_SHOPHELPER_OPEN_BALOON_CONTEXT_MENU(frame, ctrl)
	if not Me.Settings.EnableBaloonRightClick then return end
	if session.world.IsIntegrateServer() == true then
		ui.SysMsg(ScpArgMsg("CantUseThisInIntegrateServer"));
		return;
	end
	local handle = frame:GetUserIValue("HANDLE");
	local ownerTitle = string.format(Me.ResText[Me.Settings.LangMode].ShopName.General, info.GetFamilyName(handle));
	local context = ui.CreateContextMenu("SHOPHELPER_BALOON_RBTN", ownerTitle, 0, 0, 300, 0);
	local DisplayState = Me.GetFavoriteStatus(handle);
	local Liked = session.likeit.AmILikeYou(info.GetFamilyName(handle)) or false;
	Me.MakeContextMenuItem(context, Me.ResText[Me.Settings.LangMode].data.Favorite, string.format("TOUKIBI_SHOPHELPER_CHANGE_DISPLAYSTATE(%s, %s)", handle, Me.enmDisplayState.Favorite), nil, (DisplayState == Me.enmDisplayState.Favorite));
	Me.MakeContextMenuItem(context, Me.ResText[Me.Settings.LangMode].data.AsNormal, string.format("TOUKIBI_SHOPHELPER_CHANGE_DISPLAYSTATE(%s, %s)", handle, Me.enmDisplayState.NoMark), nil, (DisplayState == Me.enmDisplayState.NoMark));
	Me.MakeContextMenuItem(context, Me.ResText[Me.Settings.LangMode].data.Hate, string.format("TOUKIBI_SHOPHELPER_CHANGE_DISPLAYSTATE(%s, %s)", handle, Me.enmDisplayState.HateMark), nil, (DisplayState == Me.enmDisplayState.HateMark));
	Me.MakeContextMenuItem(context, Me.ResText[Me.Settings.LangMode].data.NeverShow, string.format("TOUKIBI_SHOPHELPER_CHANGE_DISPLAYSTATE(%s, %s)", handle, Me.enmDisplayState.Never), nil, (DisplayState == Me.enmDisplayState.Never));
	Me.MakeContextMenuSeparator(context, 300);
	local strRequestLikeItScp = string.format("SEND_PC_INFO(%d)", handle);
	Me.MakeContextMenuItem(context, Me.ResText[Me.Settings.LangMode].data.LikeYou, strRequestLikeItScp, nil, Liked);
	Me.MakeContextMenuSeparator(context, 301);
	Me.MakeContextMenuItem(context, Me.ResText[Me.Settings.LangMode].data.CloseMe);
	ui.OpenContextMenu(context);
	return context;
end 

-- ==================================
--  メイン
-- ==================================

-- 指定したバフがかかっているかをチェックする
function Me.BuffIsOngoing(SkillID)
	local dicBuffID = {};
	dicBuffID[40203] = 147; -- ブレス
	dicBuffID[40205] = 100; -- サクラ
	dicBuffID[40201] = 146; -- アスパ
	local handle = session.GetMyHandle();
	local buffCount = info.GetBuffCount(handle);
	for i = 0, buffCount - 1 do
		local buff = info.GetBuffIndexed(handle, i);
		if buff ~= nil and buff.buffID == dicBuffID[SkillID] then
			return true;
		end
	end
	return false;
end

-- バフ商店の購入ボタンをクリックしたときの処理
function Me.btnBuyBuffAutosell_Click(ctrlSet, btn)
	local frame = ctrlSet:GetTopParentFrame();
	local sellType = frame:GetUserIValue("SELLTYPE");
	local groupName = frame:GetUserValue("GROUPNAME");
	local index = ctrlSet:GetUserIValue("INDEX");
	local itemInfo = session.autoSeller.GetByIndex(groupName, index);
	local buycount =  GET_CHILD(ctrlSet, "price");
	-- 勝手に埋め込んだパラメータを取り出す
	local DoAlart = (ctrlSet:GetUserValue("ImpressionValue") == "RipOff");
	if itemInfo == nil then
		return;
	end

	local cnt = 1;
	if buycount ~= nil then
		cnt = buycount:GetNumber();
	end

	local totalPrice = itemInfo.price * cnt;
	local myMoney = GET_TOTAL_MONEY();
	if totalPrice > myMoney or  myMoney <= 0 then
		ui.SysMsg(ClMsg("NotEnoughMoney"));
		return;
	end

	-- 飛び先も自前で偽装する(価格情報が欲しいため)
	local strscp = string.format("TOUKIBI_SHOPHELPER_EXEC_BUY_BUFF(%d, %d, %d, %d, %d, %d)", frame:GetUserIValue("HANDLE"), index, cnt, sellType, itemInfo.classID, itemInfo.price);
	if DoAlart then
		-- 価格データを作り直す(本当はポインター的な手法で渡したかった)
		local BuffPriceInfo = Me.GetPriceInfo(itemInfo.classID);
		local PriceTextData = Me.GetPriceText(itemInfo.price, BuffPriceInfo);
		local objSkill = GetClassByType("Skill", itemInfo.classID);

		local msg_title = string.format("%s  {s40}{b}{ol}{#CC0808}%s{/}{/}{/}{/}  %s"
									  , "{img NOTICE_Dm_! 56 56}{/}"
									  , Me.ResText[Me.Settings.LangMode].data.WarningMsg.title
									  , "{img NOTICE_Dm_! 56 56}{/}");

		local msg_body = string.format(Me.ResText[Me.Settings.LangMode].data.WarningMsg.body);
		
		local msg_skillinfo = string.format("{img icon_%s 60 60}{/}  %s Lv.%s"
										  , objSkill.Icon
										  , objSkill.Name
										  , string.format("{@st41}{#%s}%d{/}{/}"
														, Me.GetBuffLvColor(itemInfo.level, BuffPriceInfo.MaxLv)
														, itemInfo.level
														)
											);

		local msg_priceinfo = string.format("%s:%s {#111111}(%s){/}{nl} {nl}{#111111}{s16}%s{/}{/}"
										  , Me.ResText[Me.Settings.LangMode].data.CurrentPrice
										  , PriceTextData.PriceText
										  , PriceTextData.ImpressionText
										  , PriceTextData.ToolTipText);

		local msg = string.format("%s{nl} {nl}%s{nl} {nl} {nl}%s{nl} {nl}%s"
								, msg_title
								, msg_body
								, msg_skillinfo
								, msg_priceinfo);
		
		ui.MsgBox(msg, strscp, "None");
	else
		if Me.Settings.ShowMsgBoxOnBuffShop then
			local msg = ClMsg("ReallyBuy?")
			ui.MsgBox(msg, strscp, "None");
		else
			TOUKIBI_SHOPHELPER_EXEC_BUY_BUFF(frame:GetUserIValue("HANDLE"), index, cnt, sellType, itemInfo.classID, itemInfo.price);
		end
	end
end

-- 修理商店の修理ボタンをクリックしたときの処理
function Me.btnBuySquireRepair_Click(frame)
	local ParentFrame = frame:GetTopParentFrame();
	local SLv = ParentFrame:GetUserIValue("SKILLLEVEL");
	local RepairPrice = ParentFrame:GetUserIValue("PRICE");
	-- 勝手に埋め込んだパラメータを取り出す
	local DoAlart = (ParentFrame:GetUserValue("ImpressionValue") == "RipOff");

	if DoAlart then
		local strscp = string.format("TOUKIBI_SHOPHELPER_EXEC_SQUIRE_REPAIR('%s')", ParentFrame:GetName());
		local msg = Me.MakeWarningMsg(10703, SLv, RepairPrice)
		ui.MsgBox(msg, strscp, "None");
	else
		TOUKIBI_SHOPHELPER_EXEC_SQUIRE_REPAIR(ParentFrame:GetName())
	end
end

-- ジェムロースティング商店の確認ボタンをクリックしたときの処理
function Me.btnBuyGemRoasting_Click(frame)
	session.ResetItemList();

	local ParentFrame = frame:GetTopParentFrame();
	local SLv = ParentFrame:GetUserIValue("SKILLLEVEL");
	local Price = ParentFrame:GetUserIValue("PRICE");
	-- 勝手に埋め込んだパラメータを取り出す
	local DoAlart = (ParentFrame:GetUserValue("ImpressionValue") == "RipOff");

	if DoAlart then
		local strscp = string.format("TOUKIBI_SHOPHELPER_EXEC_GEM_ROASTING('%s')", ParentFrame:GetName());
		local msg = Me.MakeWarningMsg(21003, SLv, Price)
		ui.MsgBox(msg, strscp, "None");
	else
		TOUKIBI_SHOPHELPER_EXEC_GEM_ROASTING(ParentFrame:GetName())
	end
end

-- 修理アクション
function TOUKIBI_SHOPHELPER_EXEC_SQUIRE_REPAIR(ParentFrameName)
	local ParentFrame = ui.GetFrame(ParentFrameName);
	local handle = ParentFrame:GetUserValue("HANDLE");
	local skillName = ParentFrame:GetUserValue("SKILLNAME");
	local RepairPrice = ParentFrame:GetUserIValue("PRICE");
	
	session.ResetItemList();
	local slotSet = GET_CHILD_RECURSIVELY(ParentFrame, "slotlist", "ui::CSlotSet")
	
	if slotSet:GetSelectedSlotCount() < 1 then
		ui.MsgBox(ScpArgMsg("SelectRepairItemPlz"))
		return;
	end

	-- 最終使用時間を記憶する
	Me.UpdateAveragePrice(handle, 10703, RepairPrice)

	for i = 0, slotSet:GetSelectedSlotCount() -1 do
		local slot = slotSet:GetSelectedSlot(i);
		local Icon = slot:GetIcon();
		local iconInfo = Icon:GetInfo();

		session.AddItemID(iconInfo:GetIESID());
	end
	session.autoSeller.BuyItems(handle, AUTO_SELL_SQUIRE_BUFF, session.GetItemIDList(), skillName);
end

-- バフ屋のバフの購入アクション
function TOUKIBI_SHOPHELPER_EXEC_BUY_BUFF(handle, index, cnt, sellType, skillID, Price)
	-- すでにバフがかかっている場合はメッセージを出して強制的に処理中止する
	if Me.BuffIsOngoing(skillID) then
		local objSkill = GetClassByType("Skill", skillID);
		local objSkillName;
		if objSkill ~= nil then
			objSkillName = objSkill.Name;
		else
			objSkillName = string.format(Me.ResText[Me.Settings.LangMode].data.UnknownSkillID, skillID);
		end
		ui.MsgBox(string.format(Me.ResText[Me.Settings.LangMode].data.IsGoingMsg, objSkillName))
		return;
	end
	-- 最終使用時間を記憶する
	Me.UpdateAveragePrice(handle, skillID, Price)
	EXEC_BUY_AUTOSELL(handle, index, cnt, sellType);
end

--ジェムローストアクション
function TOUKIBI_SHOPHELPER_EXEC_GEM_ROASTING(ParentFrameName)
	session.ResetItemList();

	local ParentFrame = ui.GetFrame(ParentFrameName);
	local targetbox = ParentFrame:GetChild("roasting");
	local slot = GET_CHILD(targetbox, "slot", "ui::CSlot");
	local itemIESID = slot:GetUserValue("GEM_IESID");

	if itemIESID == "0" or itemIESID == "" then
		ui.MsgBox(ScpArgMsg("DropItemPlz"))
		return;
	end

	local handle = ParentFrame:GetUserValue("HANDLE");
	local skillName = ParentFrame:GetUserValue("SKILLNAME");
	local RoastPrice = ParentFrame:GetUserIValue("PRICE");
	-- 最終使用時間を記憶する
	Me.UpdateAveragePrice(handle, 21003, RoastPrice)

	session.AddItemID(itemIESID);
	session.autoSeller.BuyItems(handle, AUTO_SELL_GEM_ROASTING, session.GetItemIDList(), skillName);
end

-- 最終使用時間を記憶して修正移動平均とsetting.jsonを更新する
function Me.UpdateAveragePrice(handle, skillID, LatestPrice)
	local OwnerFamilyName = info.GetFamilyName(handle);
	local objSkill = GetClassByType("Skill", skillID);
	local objSkillName;
	if objSkill ~= nil then
		objSkillName = objSkill.Name;
	else
		objSkillName = string.format(Me.ResText[Me.Settings.LangMode].data.UnknownSkillID, skillID);
	end
	TOUKIBI_SHOPHELPER_ADDLOG(string.format(Me.ResText[Me.Settings.LangMode].Log.BuySomething
							, OwnerFamilyName
							, objSkillName
							, Me.GetCommaedTextEx(LatestPrice)
							), "Info", true, false);

	if Me.IsVillage == nil then
		Me.IsVillage = (GetClass("Map", session.GetMapName()).isVillage == "YES") or false;
	end
	if Me.Settings.UpdateAverage then
		Me.BuyHistory[handle] = Me.BuyHistory[handle] or {};
		Me.BuyHistory[handle][skillID] = Me.BuyHistory[handle][skillID] or {};
		local CurrentHistory = Me.BuyHistory[handle][skillID];
		if CurrentHistory.LatestUse == nil or os.clock() - CurrentHistory.LatestUse >= Me.Settings.RecalcInterval then
			-- 修正移動平均を求めて平均値を更新する
			if not Me.IsVillage and Me.Settings.Suburb[tostring(skillID)] ~= nil then
				TOUKIBI_SHOPHELPER_ADDLOG(string.format(Me.ResText[Me.Settings.LangMode].Log.IsSuburbMsg
													  , Me.GetCommaedTextEx(LatestPrice)
													  , Me.GetCommaedTextEx(Me.Settings.Suburb[tostring(skillID)])
													  , Me.GetCommaedTextEx(LatestPrice - Me.Settings.Suburb[tostring(skillID)])
										), "Notice", true, true);
				LatestPrice = LatestPrice - Me.Settings.Suburb[tostring(skillID)]
			end
			if Me.Settings.IgnoreAwayValue then
				local PriceInfo = Me.GetPriceInfo(tonumber(skillID));
				if PriceInfo.DoAddInfo and LatestPrice < PriceInfo.CostPrice then
					TOUKIBI_SHOPHELPER_ADDLOG(Me.ResText[Me.Settings.LangMode].Log.IsBelowCostMsg, "Notice", true, false);
					LatestPrice = PriceInfo.CostPrice;
				elseif PriceInfo.DoAddInfo and math.abs(LatestPrice - PriceInfo.AveragePrice) > PriceInfo.Span * 30 then
					TOUKIBI_SHOPHELPER_ADDLOG(Me.ResText[Me.Settings.LangMode].Log.IsFartherValueMsg, "Notice", true, false);
					return;
				end
			end
			Me.Settings.AveragePrice[tostring(skillID)] = (Me.Settings.AveragePrice[tostring(skillID)] * (Me.Settings.AverageNCount - 1) + LatestPrice) / Me.Settings.AverageNCount
			CurrentHistory.LatestUse = os.clock();
			TOUKIBI_SHOPHELPER_ADDLOG(string.format(Me.ResText[Me.Settings.LangMode].Log.UpdateAveragePrice
									, objSkillName
									, Me.GetCommaedTextEx(Me.Settings.AveragePrice[tostring(skillID)], nil, 2)
									), "Info", true, false);

			Me.SaveSetting()
		else
			TOUKIBI_SHOPHELPER_ADDLOG(string.format(Me.ResText[Me.Settings.LangMode].Log.IsShorterInterval
									, os.clock() - CurrentHistory.LatestUse
									, Me.Settings.RecalcInterval
									), "Info", true, false);
		end
	end
end

-- 全プレイヤーの名前を隠す
function TOUKIBI_SHOPHELPER_HIDE_PLAYERS()
	if keyboard.IsPressed(KEY_ALT) == 1 then
		-- Altキーが押されている間はキャラクター情報を非表示にする
		local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 1000000, "ALL");
		for i = 1, selectedObjectsCount do
			local handle = GetHandle(selectedObjects[i]);
			if handle ~= nil then
				if info.IsPC(handle) == 1 then
					local shopFrame = ui.GetFrame("SELL_BALLOON_" .. handle);
					-- 露店には何もしない
					if shopFrame == nil then
						local FrameName = "charbaseinfo1_" .. handle;
						local ytxtFrame = ui.GetFrame(FrameName);
						if ytxtFrame ~= nil then
							if ytxtFrame:IsVisible() == 1 then
								table.insert(Me.HiddenFrameList, FrameName);
								ytxtFrame:ShowWindow(0);
							end
						end
					end
				end
			end
		end
	else
		-- 押されていない場合は隠されたフレームをすべて元に戻す
		while table.maxn(Me.HiddenFrameList) >= 1 do
			local v = table.remove(Me.HiddenFrameList)
			local frame = ui.GetFrame(v);
			if frame ~= nil then
				frame:ShowWindow(1);
			end
		end
	end
end

-- FPS更新ごとに受け取るイベント
function TOUKIBI_SHOPHELPER_FPS_UPDATE()
--	if Me.Settings ~= nil and Me.Settings.OptionFrameIsAvailable then
--		Me.UpdatePricePanel()
--	end
end

function Me.GetBuffLvColor(SLv, MaxLv)
	local ResultValue = "FFFFFF";
	if MaxLv >= 15 then
		if SLv <= 6 then
			ResultValue = "FFFFFF";
		elseif SLv < 15 then
			ResultValue = "108CFF";
		elseif SLv == 15 then
			ResultValue = "9F30FF";
		elseif SLv > 15 then
			ResultValue = "FF4F00";
		end
	elseif MaxLv >= 10 then
		if SLv < 5 then
			ResultValue = "FFFFFF";
		elseif SLv <= 6 then
			ResultValue = "108CFF";
		elseif SLv == 10 then
			ResultValue = "9F30FF";
		elseif SLv > 10 then
			ResultValue = "FF4F00";
		end
	elseif MaxLv >= 5 then
		if SLv < 5 then
			ResultValue = "FFFFFF";
		elseif SLv == 5 then
			ResultValue = "9F30FF";
		elseif SLv > 5 then
			ResultValue = "FF4F00";
		end
	else
	end
	return ResultValue;
end

-- 価格情報を取り出す
function Me.GetPriceInfo(SkillID)
	local ReturnValue = {};
	if SkillID == 40203 then
		-- ブレス
		ReturnValue.CostPrice = 400;
		ReturnValue.MaxLv = 15;
		ReturnValue.DoAddInfo = true
	elseif SkillID == 40205 then
		-- サクラ
		ReturnValue.CostPrice = 700;
		ReturnValue.MaxLv = 10;
		ReturnValue.DoAddInfo = true
	elseif SkillID == 40201 then
		-- アスパ
		ReturnValue.CostPrice = 1000;
		ReturnValue.MaxLv = 15;
		ReturnValue.DoAddInfo = true
	elseif SkillID == 10703 then
		-- 修理
		ReturnValue.CostPrice = 160;
		ReturnValue.MaxLv = 15;
		ReturnValue.DoAddInfo = true
	elseif SkillID == 21003 then
		-- ジェムロースティング
		ReturnValue.CostPrice = 6000;
		ReturnValue.MaxLv = 10;
		ReturnValue.DoAddInfo = true
	end
	-- 転ばぬ先の杖
	ReturnValue.AveragePrice = Me.Settings.AveragePrice[tostring(SkillID)] or 100;
	ReturnValue.CostPrice = ReturnValue.CostPrice or 100;
	ReturnValue.Span = Me.Settings.Radix[tostring(SkillID)] or 20;
	ReturnValue.MaxLv = ReturnValue.MaxLv or 15;
	ReturnValue.Suburb = Me.Settings.Suburb[tostring(SkillID)] or 100;
	ReturnValue.DoAddInfo = ReturnValue.DoAddInfo or false;
	return ReturnValue;
end

-- 値段のテキスト情報を作成する
function Me.GetPriceText(Price, PriceInfo)
	local ReturnValue = {};
	local CustomFormat = {};
	PriceInfo.AverageWithCharge = PriceInfo.AveragePrice;
	if Me.IsVillage == nil then
		Me.IsVillage = (GetClass("Map", session.GetMapName()).isVillage == "YES") or false;
	end
	if not Me.IsVillage then
		PriceInfo.AverageWithCharge = PriceInfo.AverageWithCharge + PriceInfo.Suburb;
	end
	ReturnValue.ImpressionValue = "Empty";
	if Price < PriceInfo.CostPrice then
		ReturnValue.ImpressionValue = "BelowCost"
		CustomFormat.Price = {"#0000FF"};
		CustomFormat.Impression = {"#0000FF"};
	elseif Price == PriceInfo.CostPrice then
		ReturnValue.ImpressionValue = "AtCost"
		CustomFormat.Price = {"#0000FF"};
		CustomFormat.Impression = {"#0000FF"};
	elseif Price <= PriceInfo.CostPrice + PriceInfo.Span * 3 then
		ReturnValue.ImpressionValue = "NearCost"
		CustomFormat.Price = {"@st41b", "#00CC00"};
		CustomFormat.Impression = {"#006633"};
	elseif Price < PriceInfo.AverageWithCharge - PriceInfo.Span * 2 then
		-- お値打ち1
		ReturnValue.ImpressionValue = "GoodValue"
		CustomFormat.Price = {"@st41b", "#9999FF"};
		CustomFormat.Impression = {"#3333FF"};
	elseif Price < PriceInfo.AverageWithCharge then
		-- お値打ち2 だけど大体平均
		ReturnValue.ImpressionValue = "WithinAverage"
		CustomFormat.Price = {"@st41b", "#CCCCFF"};
	elseif Price <= PriceInfo.AverageWithCharge + PriceInfo.Span * 5 then
		-- 普通
		ReturnValue.ImpressionValue = "WithinAverage"
		CustomFormat.Price = {"@st41b"};
	elseif Price <= PriceInfo.AverageWithCharge + PriceInfo.Span * 20 then
		-- ちょい高
		ReturnValue.ImpressionValue = "ALittleExpensive"
		CustomFormat.Price = {"@st41b", "#FF9999"};
	elseif Price >= PriceInfo.AverageWithCharge * 1.8 then
		-- 異常に高い2
		ReturnValue.ImpressionValue = "RipOff"
		CustomFormat.Price = {"img NOTICE_Dm_! 26 26", "@st41b", "#FF0000"};
	elseif Price >= PriceInfo.AverageWithCharge + PriceInfo.Span * 100 then
		-- 異常に高い1
		ReturnValue.ImpressionValue = "RipOff"
		CustomFormat.Price = {"img NOTICE_Dm_! 26 26", "@st41b", "#FF0000"};
	else
		ReturnValue.ImpressionValue = "Expensive"
		CustomFormat.Price = {"@st41b", "#FF3333"};
	end
	-- 備考の文字を作成する
	ReturnValue.PriceText = Me.CreateValueWithStyleCode(Me.GetCommaedTextEx(Price), CustomFormat.Price);
	ReturnValue.ImpressionText = Me.CreateValueWithStyleCode(Me.ResText[Me.Settings.LangMode]["data"][ReturnValue.ImpressionValue], CustomFormat.Impression);
	if ReturnValue.ImpressionValue == "BelowCost" or ReturnValue.ImpressionValue == "AtCost" then
		-- 原価を表示
		ReturnValue.ComparsionText = string.format("%s:%ss"
												 , Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
												 , Me.GetCommaedTextEx(PriceInfo.CostPrice));

		ReturnValue.ToolTipText = Me.MakePriceToolTipText(Price, PriceInfo.CostPrice, PriceInfo.AverageWithCharge, not Me.IsVillage and PriceInfo.Suburb or 0);
	elseif ReturnValue.ImpressionValue == "AtCost" then
		-- 原価との比較のみ表示
		ReturnValue.ComparsionText = string.format("%s%s"
												 , Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
												 , Me.GetCommaedTextEx(Price - PriceInfo.CostPrice, 0, 0, true, true));
		ReturnValue.ToolTipText = Me.MakePriceToolTipText(Price, PriceInfo.CostPrice, PriceInfo.AverageWithCharge, not Me.IsVillage and PriceInfo.Suburb or 0);
	elseif ReturnValue.ImpressionValue == "RipOff" and  Price >= PriceInfo.AverageWithCharge * 1.8 then
		-- 原価・平均との割合で表示(ぼったくり対応)
		ReturnValue.ComparsionText = string.format("%sx%s  %sx%s"
												 , Me.ResText[Me.Settings.LangMode]["data"]["AveragePrice"]
												 , Me.GetCommaedTextEx(Price / PriceInfo.AverageWithCharge, nil, 2)
												 , Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
												 , Me.GetCommaedTextEx(Price / PriceInfo.CostPrice, nil, 2));

		ReturnValue.ToolTipText = Me.MakePriceToolTipText(Price, PriceInfo.CostPrice, PriceInfo.AverageWithCharge, not Me.IsVillage and PriceInfo.Suburb or 0, true);
	else
		-- 通常表示(原価と平均比較)
		ReturnValue.ComparsionText = string.format("%s%s  %s%s"
												 , Me.ResText[Me.Settings.LangMode]["data"]["AveragePrice"]
												 , Me.GetCommaedTextEx(Price - PriceInfo.AverageWithCharge, nil, nil, true)
												 , Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
												 , Me.GetCommaedTextEx(Price - PriceInfo.CostPrice, nil, nil, true));

		ReturnValue.ToolTipText = Me.MakePriceToolTipText(Price, PriceInfo.CostPrice, PriceInfo.AverageWithCharge, not Me.IsVillage and PriceInfo.Suburb or 0);
	end
	if ReturnValue.ImpressionValue == "RipOff" then ReturnValue.DoAlart = true end
	return ReturnValue;
end

-- その人のお気に入り度を返す
function Me.GetFavoriteStatus(handle)
	local AID = world.GetActor(handle):GetPCApc():GetAID();
	local FavoriteItem = Me.FavoriteList[AID];
	local FavoriteState = Me.enmFavoriteState.NoData;
	local DisplayState = Me.enmDisplayState.NoMark;
	-- フレンドリストへ情報を照合する
	if session.friends.GetFriendByAID(FRIEND_LIST_BLOCKED, AID) ~= nil then
		-- ブロック対象者
		FavoriteState = Me.enmFavoriteState.Blocked;
	elseif session.friends.GetFriendByAID(FRIEND_LIST_COMPLETE, AID) ~= nil then
		-- フレンド対象者
		FavoriteState = Me.enmFavoriteState.Friend;
	end
	-- いいねしているかチェック
	if FavoriteState == Me.enmFavoriteState.NoData and not session.world.IsIntegrateServer() then -- 統合サーバー状態でなければ
		if session.likeit.AmILikeYou(info.GetFamilyName(handle)) then
			FavoriteState = Me.enmFavoriteState.Liked;
		end
	end
	if FavoriteItem ~= nil then
		-- カスタム記録値がある場合はその結果を使用する
		DisplayState = FavoriteItem;
	else
		-- カスタム記録値がない場合はいいね・フレンド・ブロック情報から結果を返す
		if FavoriteState == Me.enmFavoriteState.Blocked then
			-- ブロック対象者
			DisplayState = Me.enmDisplayState.HateMark;
		elseif FavoriteState == Me.enmFavoriteState.Friend then
			-- フレンド対象者
			DisplayState = Me.enmDisplayState.Liked;
		elseif FavoriteState == Me.enmFavoriteState.Liked then
			-- いいね対象者
			DisplayState = Me.enmDisplayState.Liked;
		end
	end
	return DisplayState, FavoriteState;
end

function Me.RedrawShopBaloon(handle)
	if handle == nil or info.IsPC(handle) ~= 1 then return end
	local frame = ui.GetFrame("SELL_BALLOON_" .. handle);
	if frame == nil then return end
	local sellType = frame:GetUserIValue("SELL_TYPE");
	local handle = frame:GetUserIValue("HANDLE");
	local originalText = frame:GetUserValue("SHOPHELPER_ORIGINAL_TEXT");
	if originalText == nil or originalText == "None" then
		if sellType == AUTO_SELL_BUFF or sellType == AUTO_SELL_GEM_ROASTING 
										or sellType == AUTO_SELL_SQUIRE_BUFF 
										or sellType == AUTO_SELL_ENCHANTERARMOR then

			originalText = frame:GetChild("withLvBox"):GetChild('lv_title'):GetTextByKey("value");
		else
			originalText = frame:GetChild("text"):GetTextByKey("value");
		end	
	end
	Me.ADDTO_SHOPBALOON(originalText, sellType, handle);
end

function Me.RedrawAllShopBaloon()
	local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 1000000, "ALL");
	for i = 1, selectedObjectsCount do
		Me.RedrawShopBaloon(GetHandle(selectedObjects[i]));
	end
end

function Me.ADDTO_SHOPBALOON(title, sellType, handle, skillID, skillLv)
	-- CHAT_SYSTEM("AUTOSELLER_BALLOON_HOOKED実行");
	-- 以下カスタム用
	-- 作られたフレームを再取得する
	local frame = ui.GetFrame("SELL_BALLOON_" .. handle);
	if frame == nil then return end
	-- CHAT_SYSTEM("SELL_BALLOON_" .. handle)
	local originalText = frame:GetUserValue("SHOPHELPER_ORIGINAL_TEXT");
	if originalText == nil or originalText == "None" then
		frame:SetUserValue("SHOPHELPER_ORIGINAL_TEXT", title);
		originalText = title;
	end
	-- if not Me.Settings.AddInfoToBaloon then return end
	-- オリジナルのテキストを保存しておく
	local NewLabelText = "";
	if Me.Settings.AddInfoToBaloon then
		-- 落書きする文字
		NewLabelText = originalText
		-- NewLabelText = "{img NOTICE_Dm_! 32 32}" .. originalText
	else
		-- 元の文字
		NewLabelText = originalText
	end
	local BasePic = frame:GetChild("bg");
	local lvBox = frame:GetChild("withLvBox");
	local lblNotmalText = frame:GetChild("text");
	local lvTitle = lvBox:GetChild('lv_title');
	if sellType == AUTO_SELL_BUFF or sellType == AUTO_SELL_GEM_ROASTING or sellType == AUTO_SELL_SQUIRE_BUFF or sellType == AUTO_SELL_ENCHANTERARMOR then
		Me.SetControlTextByKey(lvTitle, "value", NewLabelText);
		lblNotmalText:ShowWindow(0);
	else
		Me.SetControlTextByKey(lblNotmalText, "value", NewLabelText);
		lvBox:ShowWindow(0);
	end	
	-- オリジナルのアイコンを上書きする
	local DisplayState = Me.GetFavoriteStatus(handle);
	-- CHAT_SYSTEM(string.format("[%s] %s: %s", handle, info.GetFamilyName(handle)	, DisplayState))
	DESTROY_CHILD_BYNAME(frame, "SHOPHELPER_");
	if Me.Settings.AddInfoToBaloon and DisplayState ~= nil and DisplayState ~= Me.enmDisplayState.NoMark then
		local objAdditionalIcon = nil;
		if DisplayState <= Me.enmDisplayState.HateMark then
			objAdditionalIcon = tolua.cast(frame:CreateOrGetControl("picture", "SHOPHELPER_ADDITIONAL_ICON", 22, 18, 28, 28), "ui::CPicture");
		elseif DisplayState >= Me.enmDisplayState.Liked then
			objAdditionalIcon = tolua.cast(frame:CreateOrGetControl("picture", "SHOPHELPER_ADDITIONAL_ICON", 0, 0, 48, 48), "ui::CPicture");
		end
		if objAdditionalIcon ~= nil then
			objAdditionalIcon:EnableHitTest(0); 
			objAdditionalIcon:SetEnable(1);
			objAdditionalIcon:SetEnableStretch(1);
			objAdditionalIcon:EnableChangeMouseCursor(0);
			if DisplayState <= Me.enmDisplayState.HateMark then
				objAdditionalIcon:SetImage("barrack_delete_btn_clicked"); 
			elseif DisplayState >= Me.enmDisplayState.Favorite then
				objAdditionalIcon:SetImage("Hit_indi_icon"); 
			end
			objAdditionalIcon:ShowWindow(1); 
		end
		if DisplayState <= Me.enmDisplayState.Never then
			frame:ShowWindow(0);
		else
			frame:ShowWindow(1);
		end
	end
	BasePic:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_SHOPHELPER_OPEN_BALOON_CONTEXT_MENU');
	lvBox:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_SHOPHELPER_OPEN_BALOON_CONTEXT_MENU');
end

-- 修理商店に情報を付加する
function Me.AddInfoToSquireBuff(BaseFrame)
	if BaseFrame == nil then return nil end
	if BaseFrame:GetUserIValue("HANDLE") ==  session.GetMyHandle() then return nil end

	local RepairFrame = BaseFrame:GetChild("repair");
	if RepairFrame ~= nil then
		-- 各種パネルの位置を下へ動かす
		local TargetControl = nil;
		Me.ChangeControlMargin_Top(RepairFrame:GetChild("TitleSkin"), 94 + 30);
		Me.ChangeControlMargin_Top(RepairFrame:GetChild("Money"), 102 + 30);
		Me.ChangeControlMargin_Top(RepairFrame:GetChild("reqitemMoney"), 100 + 30);
		Me.ChangeControlMargin_Top(RepairFrame:GetChild("selectAllBtn"), 92 + 30);

		TargetControl = RepairFrame:GetChild("repairlistGbox");
			Me.ChangeControlMargin_Top(TargetControl, 140 + 30 + 30);

		-- できたスペースに追加情報を書き込む
		local OwnerFamilyName = tostring(info.GetFamilyName(BaseFrame:GetUserIValue("HANDLE")));
		local SLv = BaseFrame:GetUserIValue("SKILLLEVEL");
		local Price = BaseFrame:GetUserIValue("PRICE");
		local PriceInfo = Me.GetPriceInfo(10703); -- リペアのスキルID
		local PriceTextData = Me.GetPriceText(Price, PriceInfo)
		Me.AddRichText(BaseFrame
					 , "lblOwnerInfo"
					 , string.format("{@st42b}{#%s}Lv.%d{/}{/}  %s"
					 			   , Me.GetBuffLvColor(SLv, PriceInfo.MaxLv)
								   , SLv
								   , string.format(Me.ResText[Me.Settings.LangMode].ShopName.SquireBuff, OwnerFamilyName)
					 				)
					 , 40, 120, 420, 20, 16);
		local lblPrice = Me.AddRichText(BaseFrame
									  , "lblPriceInfo"
									  , string.format("%s：%s  %s (%s)"
													, Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
													, PriceTextData.PriceText
													, PriceTextData.ImpressionText
													, PriceTextData.ComparsionText)
									  , 40, 200, 420, 20, 16);
		lblPrice:SetTextTooltip(PriceTextData.ToolTipText);
		-- 購入時の注意フラグを追加する
		BaseFrame:SetUserValue("ImpressionValue", PriceTextData.ImpressionValue);
	end
end

-- ジェムロースティング店に情報を付加する
function Me.AddInfoToGemRoasting(BaseFrame)
	if BaseFrame == nil then return nil end
	if BaseFrame:GetUserIValue("HANDLE") ==  session.GetMyHandle() then return nil end

	local RepairFrame = BaseFrame:GetChild("roasting");
	if RepairFrame ~= nil then
		-- 各種パネルの位置を下へ動かす
		local TargetControl = nil;
		Me.ChangeControlMargin_Top(RepairFrame:GetChild("slot_bg_img"), 50 + 30 + 60);
		Me.ChangeControlMargin_Top(RepairFrame:GetChild("slot"), 110 + 30 + 60);
		Me.ChangeControlMargin_Top(RepairFrame:GetChild("slotName"), 250 + 30 + 60);
		Me.ChangeControlMargin_Top(RepairFrame:GetChild("TitleSkin"), 47 + 30);
		Me.ChangeControlMargin_Top(RepairFrame:GetChild("Money"), 56 + 30);
		Me.ChangeControlMargin_Top(RepairFrame:GetChild("reqitemMoney"), 56 + 30);

		TargetControl = RepairFrame:GetChild("effectGbox");
			Me.ChangeControlMargin_Top(TargetControl, 230 + 30 + 60);

		-- できたスペースに追加情報を書き込む
		local OwnerFamilyName = tostring(info.GetFamilyName(BaseFrame:GetUserIValue("HANDLE")));
		local SLv = BaseFrame:GetUserIValue("SKILLLEVEL");
		local Price = BaseFrame:GetUserIValue("PRICE");
		local PriceInfo = Me.GetPriceInfo(21003);
		local PriceTextData = Me.GetPriceText(Price, PriceInfo)

		Me.AddRichText(BaseFrame
					 , "lblOwnerInfo"
					 , string.format("{@st42b}{#%s}Lv.%d{/}{/}  %s"
					 			   , Me.GetBuffLvColor(SLv, PriceInfo.MaxLv)
								   , SLv
								   , string.format(Me.ResText[Me.Settings.LangMode].ShopName.GemRoasting, OwnerFamilyName)
					 				)
					 , 40, 120, 420, 20, 16);
		local lblPrice = Me.AddRichText(BaseFrame
									  , "lblPriceInfo"
									  , string.format("%s：%s  %s (%s)"
													, Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
													, PriceTextData.PriceText
													, PriceTextData.ImpressionText
													, PriceTextData.ComparsionText)
									  , 40, 200, 420, 20, 16);
		lblPrice:SetTextTooltip(PriceTextData.ToolTipText);
		-- 購入時の注意フラグを追加する
		BaseFrame:SetUserValue("ImpressionValue", PriceTextData.ImpressionValue);
	end
end

-- バフ商店に情報を付加する
function Me.AddInfoToBuffSellerSlot(BaseFrame, info)
	if BaseFrame == nil then return nil end
	local ParentFrame = BaseFrame:GetTopParentFrame();
	if ParentFrame == nil then return nil end
	if ParentFrame:GetUserIValue("HANDLE") ==  session.GetMyHandle() then return nil end
	local BuffPriceInfo = Me.GetPriceInfo(info.classID);

	if BuffPriceInfo.DoAddInfo then
		local PriceTextData = Me.GetPriceText(info.price, BuffPriceInfo)
		local lblSLv = BaseFrame:GetChild("skilllevel");
		lblSLv:SetTextByKey("value", string.format("{@st41}{#%s}%d{/}{/}"
												 , Me.GetBuffLvColor(info.level, BuffPriceInfo.MaxLv)
												 , info.level));


		local lblPrice = BaseFrame:GetChild("price")
		lblPrice:SetTextByKey("value", PriceTextData.PriceText);
		lblPrice:SetTextTooltip(PriceTextData.ToolTipText);

		-- ボタンを上へ動かす
		local objTextItem = Me.AddRichTextToCenter(BaseFrame, "lblPriceInfo", PriceTextData.ImpressionText, 250, 40, 150, 20, 16);
		objTextItem:SetTextTooltip(PriceTextData.ToolTipText);
		local BuyButton = BaseFrame:GetChild("btn");
		if BuyButton ~= nil then
			tolua.cast(BuyButton, 'ui::CButton');
			Me.ChangeControlMargin_Left(BuyButton, 280 - 30);
			BuyButton:Resize(118 + 30, 45);
			if PriceTextData.DoAlart then
				BuyButton:SetText(Me.ResText[Me.Settings.LangMode].data.lblWarning);
			else
				BuyButton:SetText("");
				if Me.BuffIsOngoing(info.classID) then
					BuyButton:SetText(Me.ResText[Me.Settings.LangMode].data.lblOngoing);
				else
					BuyButton:SetText(Me.ResText[Me.Settings.LangMode].data.lblBuy);
				end
			end
			-- 購入時の注意フラグを追加する
			BaseFrame:SetUserValue("ImpressionValue", PriceTextData.ImpressionValue);
		end
	end
end

-- ==================================
--  UI関連
-- ==================================
function Me.ChangeControlMargin_Top(TargetControl, NewValue)
	if TargetControl ~= nil then
		local BeforeMargin = TargetControl:GetMargin();
		TargetControl:SetMargin(BeforeMargin.left, NewValue, BeforeMargin.right, BeforeMargin.bottom);
	end
end

function Me.ChangeControlMargin_Left(TargetControl, NewValue)
	if TargetControl ~= nil then
		local BeforeMargin = TargetControl:GetMargin();
		TargetControl:SetMargin(NewValue, BeforeMargin.top, BeforeMargin.right, BeforeMargin.bottom);
	end
end

function Me.ChangeControlMargin_Right(TargetControl, NewValue)
	if TargetControl ~= nil then
		local BeforeMargin = TargetControl:GetMargin();
		TargetControl:SetMargin(BeforeMargin.left, BeforeMargin.top, NewValue, BeforeMargin.bottom);
	end
end

function Me.ChangeControlMargin_Bottom(TargetControl, NewValue)
	if TargetControl ~= nil then
		local BeforeMargin = TargetControl:GetMargin();
		TargetControl:SetMargin(BeforeMargin.left, BeforeMargin.top, BeforeMargin.right, NewValue);
	end
end

function Me.ChangeControlMargin(TargetControl, NewLeft, NewTop, NewRight, NewBottom)
	if TargetControl ~= nil then
		TargetControl:SetMargin(NewLeft, NewTop, NewRight, NewBottom);
	end
end

function Me.AddRichText(BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize)
	local txtItem = BaseFrame:CreateOrGetControl('richtext', NewLabelName, NewLeft, NewTop, NewWidth, NewHeight); 
	tolua.cast(txtItem, "ui::CRichText");
	txtItem:SetTextAlign("left", "top"); 
	txtItem:SetText("{@st66}" .. NewText); 
	txtItem:SetGravity(ui.LEFT, ui.TOP);
	txtItem:ShowWindow(1);
	return txtItem;
end

function Me.AddRichTextToCenter(BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize)
	local objTextItem = Me.AddRichText(BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize); 
	Me.ChangeControlMargin(objTextItem, NewLeft + math.floor((NewWidth - objTextItem:GetWidth()) / 2), NewTop + math.floor((NewHeight - objTextItem:GetHeight()) / 2), 0, 0);
	return objTextItem;
end

function Me.SetControlText(ctrl, NewText, Styles)
	local StyledText = NewText;
	if Styles ~= nil and #Styles > 0 then
		-- スタイル指定あり
		StyledText = Me.CreateValueWithStyleCode(NewText, Styles);
	end
	if ctrl ~= nil then
		ctrl:SetText(StyledText);
	end
end

function Me.SetControlFormat(ctrl, NewFormat, Styles, ValuePropName)
	local StyledText = NewFormat;
	if Styles ~= nil and #Styles > 0 then
		-- スタイル指定あり
		StyledText = Me.CreateValueWithStyleCode(NewFormat, Styles);
	end
	if ctrl ~= nil then
		ctrl:SetFormat(StyledText);
		-- 注意 SetFormat()だけではリアルタイムに表示は変更されません
		if ValuePropName ~= nil then
			local Value = ctrl:GetTextByKey(ValuePropName);
			if Value ~= nil then
				-- ctrl:SetTextByKey(ValuePropName, Value);
				Me.SetControlTextByKey(ctrl, ValuePropName, Value)
			end
		end
	end
end

function Me.SetControlTextByKey(ctrl, propName, NewText, Styles)
	local StyledText = NewText;
	if Styles ~= nil and #Styles > 0 then
		-- スタイル指定あり
		StyledText = Me.CreateValueWithStyleCode(NewText, Styles);
	end
	if ctrl ~= nil then
		ctrl:SetTextByKey(propName, StyledText);
	end
end

-- チェックボックスの状態を設定する
function Me.SetCheckedStateByName(frame, ControlName, pValue)
	if frame == nil then return nil end
	local TargetCheckBox = GET_CHILD(frame, ControlName, "ui::CCheckBox");
	if TargetCheckBox ~= nil then
		return Me.SetCheckedState(TargetCheckBox, pValue);
	else
		return nil;
	end
end
function Me.SetCheckedState(TargetCheckBox, pValue)
	if TargetCheckBox == nil then return nil end
	local intValue = 0;
	if type(pValue) == "boolean" and pValue then
		intValue = 1;
	elseif type(pValue) == "string" and (pValue ~= "" and pValue ~= "false" and pValue ~= "0") then
		intValue = 1;
	elseif type == nil then
		intValue = false;
	end
	tolua.cast(TargetCheckBox, "ui::CCheckBox");
	TargetCheckBox:SetCheck(intValue);
end
-- チェックボックスの状態を取得する
function Me.GetCheckedStateByName(frame, ControlName)
	if frame == nil then return nil end
	local TargetCheckBox = GET_CHILD(frame, ControlName, "ui::CCheckBox");
	if TargetCheckBox ~= nil then
		return Me.GetCheckedState(TargetCheckBox);
	else
		return nil;
	end
end
function Me.GetCheckedState(TargetCheckBox)
	if TargetCheckBox == nil then return nil end
	tolua.cast(TargetCheckBox, "ui::CCheckBox");
	return TargetCheckBox:IsChecked() == 1;
end

-- スライダーの値を設定する
function Me.SetSliderValue(frame, ControlName, LabelName, pValue, pValueText)
	local objSlider = GET_CHILD(frame, ControlName, "ui::CSlideBar");
	if objSlider ~= nil then
		objSlider:SetLevel(pValue);
	end
	local txtTarget = GET_CHILD(frame, LabelName, "ui::CRichText");
	if txtTarget ~= nil then
		txtTarget:SetTextByKey("opValue", pValueText);
	end
end
-- スライダーの値を取得する
function Me.GetSliderValueByName(frame, ControlName)
	if frame == nil then return nil end
	local TargetSlider = GET_CHILD(frame, ControlName, "ui::CSlideBar");
	if TargetSlider ~= nil then
		return Me.GetSliderValue(TargetSlider);
	else
		return nil;
	end
end
function Me.GetSliderValue(TargetSlider)
	if TargetSlider == nil then return nil end
	tolua.cast(TargetSlider, "ui::CSlideBar");
	return TargetSlider:GetLevel();
end

-- 選択されているラジオボタンの名前を取得する
function Me.GetSelectedRadioButton(SeedControl)
	if SeedControl == nil then return nil end
	local radioBtn = tolua.cast(SeedControl, "ui::CRadioButton");
	radioBtn = radioBtn:GetSelectedButton();
	return string.match(radioBtn:GetName(),".-_(.+)");
end
function Me.GetLangSeedRadioButton(SeedName)
	local BaseFrame = ui.GetFrame("shophelper");
	if BaseFrame == nil then
		TOUKIBI_SHOPHELPER_ADDLOG(Me.ResText[Me.Settings.LangMode].Log.CannotGetSettingFrameHandle, "Warning", true, false);
		return nil;
	end
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");
	if BodyGBox == nil then return nil end
	local LangGBox = GET_CHILD_GROUPBOX(BodyGBox, "pnlLang");
	local radioBtn = GET_CHILD(LangGBox, SeedName, "ui::CRadioButton");
	if radioBtn == nil then return nil end
	return radioBtn
end

function Me.GetCommaedTextEx(value, MaxTextLen, AfterTheDecimalPointLen, usePlusMark, AddSpaceAfterSign)
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
			if Me.Settings.LangMode == "jp" and IntegerPartValue == 0 and DecimalPartValue == 0 then
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

-- 価格参考のツールチップテキストを作成する
function Me.MakePriceToolTipText(Price, CostPrice, AveragePrice, SuburbPrice, MultiplicationMode)
	local lMultiplicationMode = MultiplicationMode or false;
	local lSuburbPrice = SuburbPrice or 0;
	local ReturnText = "";
	if lMultiplicationMode then
		-- 倍率モード
		ReturnText = string.format("%s x %s   (%s:%ss){nl}%s x %s   (%s:%ss)"
								 , Me.ResText[Me.Settings.LangMode]["data"]["AveragePrice"]
								 , Me.GetCommaedTextEx(Price / AveragePrice, 7, 2)
								 , Me.ResText[Me.Settings.LangMode]["data"]["AveragePrice"]
								 , Me.GetCommaedTextEx(AveragePrice, 7)
								 , Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
								 , Me.GetCommaedTextEx(Price / CostPrice, 7, 2)
								 , Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
								 , Me.GetCommaedTextEx(CostPrice, 7));

	else
		-- 通常モード
		local SuburbText = "";
		if lSuburbPrice > 0 then
			SuburbText = string.format("{#FF8888}%s %s{/}{nl}"
									 , Me.ResText[Me.Settings.LangMode]["data"]["RuralCharge"]
									 , Me.GetCommaedTextEx(lSuburbPrice))
		end
		ReturnText = string.format("%s%s %s   (%s:%ss){nl}%s %s   (%s:%ss)"
								 , SuburbText
								 , Me.ResText[Me.Settings.LangMode]["data"]["AveragePrice"]
								 , Me.GetCommaedTextEx(Price - AveragePrice, 7, nil, true)
								 , Me.ResText[Me.Settings.LangMode]["data"]["AveragePrice"]
								 , Me.GetCommaedTextEx(AveragePrice, 7)
								 , Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
								 , Me.GetCommaedTextEx(Price - CostPrice, 7, nil, true)
								 , Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
								 , Me.GetCommaedTextEx(CostPrice, 7));

	end
	return ReturnText;
end

-- 警告メッセージを作成する
function Me.MakeWarningMsg(usrSkillID, SLv, Price)
	local BuffPriceInfo = Me.GetPriceInfo(usrSkillID);
	local PriceTextData = Me.GetPriceText(Price, BuffPriceInfo);
	local objSkill;
	objSkill = GetClassByType("Skill", usrSkillID);

	local msg_title = string.format("%s  {s40}{b}{ol}{#CC0808}%s{/}{/}{/}{/}  %s"
									, "{img NOTICE_Dm_! 56 56}{/}"
									, Me.ResText[Me.Settings.LangMode].data.WarningMsg.title
									, "{img NOTICE_Dm_! 56 56}{/}");

	local msg_body = string.format(Me.ResText[Me.Settings.LangMode].data.WarningMsg.body);
	
	local msg_skillinfo = string.format("{img icon_%s 60 60}{/}  %s Lv.%s"
										, objSkill.Icon
										, objSkill.Name
										, string.format("{@st41}{#%s}%d{/}{/}"
													, Me.GetBuffLvColor(SLv, BuffPriceInfo.MaxLv)
													, SLv
													)
										);

	local msg_priceinfo = string.format("%s:%s {#111111}(%s){/}{nl} {nl}{#111111}{s16}%s{/}{/}"
										, Me.ResText[Me.Settings.LangMode].data.CurrentPrice
										, PriceTextData.PriceText
										, PriceTextData.ImpressionText
										, PriceTextData.ToolTipText);

	return string.format("%s{nl} {nl}%s{nl} {nl} {nl}%s{nl} {nl}%s"
					   , msg_title
					   , msg_body
					   , msg_skillinfo
					   , msg_priceinfo);
end

-- 使い方のテキストを出力する
function Me.PrintHelpToLog()
	local helpmsg = Me.ResText[Me.Settings.LangMode].data.HelpMsg;
	if helpmsg == nil then
		helpmsg = Me.ResText["en"].data.HelpMsg;
	end
	TOUKIBI_SHOPHELPER_ADDLOG(helpmsg, "None", false, false);
end

function Me.RefreshMe(addon, frame)
	Me.SetResText()
	Me.LoadSetting()
	
	-- フックしたいイベントを記述
	Me.setHook(Me.AUTOSELLER_BALLOON_HOOKED, "AUTOSELLER_BALLOON"); 
	Me.setHook(Me.OPEN_ITEMBUFF_UI_HOOKED, "OPEN_ITEMBUFF_UI");
	Me.setHook(Me.UPDATE_BUFFSELLER_SLOT_TARGET_HOOKED, "UPDATE_BUFFSELLER_SLOT_TARGET");
	Me.setHook(Me.BUY_BUFF_AUTOSELL_HOOKED, "BUY_BUFF_AUTOSELL");
	Me.setHook(Me.SQIORE_REPAIR_EXCUTE_HOOKED, "SQIORE_REPAIR_EXCUTE");
	Me.setHook(Me.GEMROASTING_EXCUTE_HOOKED, "GEMROASTING_EXCUTE");
	addon:RegisterMsg("FPS_UPDATE", "TOUKIBI_SHOPHELPER_HIDE_PLAYERS");
	addon:RegisterMsg("FPS_UPDATE", "TOUKIBI_SHOPHELPER_FPS_UPDATE");
	-- CHAT_SYSTEM("{#333333}[ShopHelper]イベントのフック登録が完了しました{/}");
	local acutil = require("acutil");
	acutil.slashCommand("/shophelper", TOUKIBI_SHOPHELPER_PROCESS_COMMAND);
	acutil.slashCommand("/shelper", TOUKIBI_SHOPHELPER_PROCESS_COMMAND);
	acutil.slashCommand("/sh", TOUKIBI_SHOPHELPER_PROCESS_COMMAND);

end

-- ==================================
--  コントロールセット作成
-- ==================================

function Me.CreateDivText(ParetFrame, name, left, right, text, value)
	local MarginBottom = 0;
	local textWidth = math.abs(right - left);
	local lblZone = tolua.cast(ParetFrame:CreateOrGetControl("richtext", "zone_" .. name, math.floor((left + right) / 2), 0, textWidth, 12),
							   "ui::CRichText");
	lblZone:SetGravity(ui.CENTER_HORZ, ui.BOTTOM);
	Me.ChangeControlMargin_Bottom(lblZone, MarginBottom);
	lblZone:EnableHitTest(0);
	lblZone:SetText(string.format("{@st66b}{s12}%s{/}{/}", text));

	if value ~= nil then
		local lblBar = tolua.cast(ParetFrame:CreateOrGetControl("richtext","bar_" .. name, right + 1, 0, 12, 12),
								"ui::CRichText");
		lblBar:SetGravity(ui.CENTER_HORZ, ui.BOTTOM);
		Me.ChangeControlMargin_Bottom(lblBar, 6);
		lblBar:EnableHitTest(0);
		lblBar:SetText("{@st66b}{s12}|{/}{/}");

		local lblPointer = tolua.cast(ParetFrame:CreateOrGetControl("richtext","pointer_" .. name, right + 1, 0, 12, 12),
								"ui::CRichText");
		lblPointer:SetGravity(ui.CENTER_HORZ, ui.BOTTOM);
		Me.ChangeControlMargin_Bottom(lblPointer, 22);
		lblPointer:EnableHitTest(0);
		lblPointer:SetText("{@st66b}{s12}▼{/}{/}");

		local MarginBottom = 36;
		local lblValue = tolua.cast(ParetFrame:CreateOrGetControl("richtext", "value_" .. name, right, 0, 60, 12),
								"ui::CRichText");
		lblValue:SetGravity(ui.CENTER_HORZ, ui.BOTTOM);
		Me.ChangeControlMargin_Bottom(lblValue, MarginBottom);
		lblValue:EnableHitTest(0);
		lblValue:SetText(string.format("{@st66b}{s16}%s{/}{/}", Me.GetCommaedTextEx(value)));
	end
end

function Me.CreatePriceGauge(ParentFrame, PriceInfo)
	local ParentWidth = ParentFrame:GetWidth();
	local height = 60;
	local pnlBase = tolua.cast(ParentFrame:CreateOrGetControl("groupbox", "pnlGauge", 0, 0, ParentWidth - 10, height), 
							   "ui::CGroupBox");
	
	pnlBase:SetGravity(ui.CENTER_HORZ, ui.BOTTOM);
	Me.ChangeControlMargin_Bottom(pnlBase, 5);
	pnlBase:EnableHitTest(0);
	pnlBase:SetSkinName("None");

	Me.CreateDivText(pnlBase, "BelowCost", -275, -220, "原価割れ", PriceInfo.CostPrice);
	Me.CreateDivText(pnlBase, "NearCost", -220, -165, "ほぼ原価", PriceInfo.CostPrice + PriceInfo.Span * 3);
	Me.CreateDivText(pnlBase, "GoodValue", -165, -55, "お値打ち", PriceInfo.AveragePrice - PriceInfo.Span * 2);
	Me.CreateDivText(pnlBase, "WithinAverage", -55, 55, "平均", PriceInfo.AveragePrice + PriceInfo.Span * 5);
	Me.CreateDivText(pnlBase, "ALittleExpensive", 55, 165, "高くない？", PriceInfo.AveragePrice + PriceInfo.Span * 20);
	local RipOffValue = math.min(PriceInfo.AveragePrice * 1.8, PriceInfo.AveragePrice + PriceInfo.Span * 100);
	Me.CreateDivText(pnlBase, "Expensive", 165, 220, "高い", RipOffValue);
	Me.CreateDivText(pnlBase, "RipOff", 230, 275, "異常に高い");


	local gaugeHMargin = 20;
	local imageMarginTop = 60;
	local gaugeWidth = pnlBase:GetWidth() - gaugeHMargin * 2;
	local picGauge = tolua.cast(pnlBase:CreateOrGetControl("picture", "pricegauge", 0, 0, gaugeWidth, 6), "ui::CPicture");
	picGauge:SetGravity(ui.CENTER_HORZ, ui.BOTTOM);
	Me.ChangeControlMargin_Bottom(picGauge, 20);
	picGauge:EnableHitTest(0);
	picGauge:SetEnableStretch(1);
	picGauge:SetImage("inventory_weight");
end

function Me.CreatePriceInputBox(BaseFrame, PriceInfo)
	local ParentWidth = 310;
	local height = 60;
	local pnlBase = tolua.cast(BaseFrame:CreateOrGetControl("groupbox", "pnlInput", 0, 8, ParentWidth , height), 
							   "ui::CGroupBox");
	
	pnlBase:SetGravity(ui.RIGHT, ui.TOP);
	Me.ChangeControlMargin_Right(pnlBase, 10);
	-- pnlBase:SetSkinName("test_frame_midle");
	pnlBase:EnableScrollBar(0);
	pnlBase:EnableHitTest(1);
	pnlBase:SetSkinName("None");

	local lblSuburb = tolua.cast(pnlBase:CreateOrGetControl("richtext", "lblSuburb", 0, 35, 40, 20), "ui::CRichText");
	lblSuburb:SetGravity(ui.RIGHT, ui.TOP);
	Me.ChangeControlMargin_Right(lblSuburb, 50);
	lblSuburb:EnableHitTest(0);
	lblSuburb:SetText("{@st66b}郊外価格{/}");

	local txtSuburb = tolua.cast(pnlBase:CreateOrGetControl("edit", "txtSuburb", 0, 30, 50, 26), "ui::CEditControl");
	txtSuburb:SetGravity(ui.RIGHT, ui.TOP);
	Me.ChangeControlMargin_Right(txtSuburb, 0);
	txtSuburb:EnableHitTest(1);
	txtSuburb:SetSkinName("test_weight_skin");
	txtSuburb:SetClickSound("button_click_big");
	txtSuburb:SetOverSound("button_over");
	txtSuburb:SetFontName("white_18_ol");
	txtSuburb:SetMaxLen(4);
	txtSuburb:SetOffsetXForDraw(0);
	txtSuburb:SetOffsetYForDraw(-1);
	txtSuburb:SetTextAlign("center", "center");
	txtSuburb:SetText(PriceInfo.Suburb);

	local lblRadix = tolua.cast(pnlBase:CreateOrGetControl("richtext", "lblRadix", 0, 5, 50, 20), "ui::CRichText");
	lblRadix:SetGravity(ui.RIGHT, ui.TOP);
	Me.ChangeControlMargin_Right(lblRadix, 50);
	lblRadix:EnableHitTest(0);
	lblRadix:SetText("{@st66b}単位{/}");

	local txtRadix = tolua.cast(pnlBase:CreateOrGetControl("edit", "txtRadix", 0, 0, 50, 26), "ui::CEditControl");
	txtRadix:SetGravity(ui.RIGHT, ui.TOP);
	Me.ChangeControlMargin_Right(txtRadix, 0);
	txtRadix:EnableHitTest(1);
	txtRadix:SetSkinName("test_weight_skin");
	txtRadix:SetClickSound("button_click_big");
	txtRadix:SetOverSound("button_over");
	txtRadix:SetFontName("white_18_ol");
	txtRadix:SetMaxLen(3);
	txtRadix:SetOffsetXForDraw(0);
	txtRadix:SetOffsetYForDraw(-1);
	txtRadix:SetTextAlign("center", "center");
	txtRadix:SetText(PriceInfo.Span);
	txtRadix:SetTypingScp("TOUKIBI_SHOPHELPER_PRICETEXT_CHANGED");

	local lblAverage = tolua.cast(pnlBase:CreateOrGetControl("richtext", "lblAverage", 0, 5, 40, 20), "ui::CRichText");
	lblAverage:SetGravity(ui.RIGHT, ui.TOP);
	Me.ChangeControlMargin_Right(lblAverage, 180);
	lblAverage:EnableHitTest(0);
	lblAverage:SetText("{@st66b}平均値{/}");

	local txtAverage = tolua.cast(pnlBase:CreateOrGetControl("edit", "txtAverage", 0, 0, 80, 26), "ui::CEditControl");
	txtAverage:SetGravity(ui.RIGHT, ui.TOP);
	Me.ChangeControlMargin_Right(txtAverage, 100);
	txtAverage:EnableHitTest(1);
	txtAverage:SetSkinName("test_weight_skin");
	txtAverage:SetClickSound("button_click_big");
	txtAverage:SetOverSound("button_over");
	txtAverage:SetFontName("white_18_ol");
	txtAverage:SetMaxLen(5);
	txtAverage:SetOffsetXForDraw(0);
	txtAverage:SetOffsetYForDraw(-1);
	txtAverage:SetTextAlign("center", "center");
	txtAverage:SetText(Me.GetCommaedTextEx(PriceInfo.AveragePrice));
	txtAverage:SetTypingScp("TOUKIBI_SHOPHELPER_PRICETEXT_CHANGED");

end

function Me.CreatePriceBaseCtrlSet(BaseFrame, SkillID, Index)
	local width = BaseFrame:GetWidth() - 40;
	local height = 140;

	local pnlPriceBase = tolua.cast(BaseFrame:CreateOrGetControl("controlset", "pnlPrice_" .. SkillID, 
																 0, (height + 5) * (Index - 1), width, height), 
									"ui::CControlSet");

	pnlPriceBase:SetSkinName("test_skin_01_btn");
	pnlPriceBase:EnableHitTest(1);
	pnlPriceBase:SetGravity(ui.CENTER_HORZ, ui.TOP);

	local imageSize = 24;
	local imageMarginLeft = 20;
	local imageMarginRight = 2;
	local imageMarginTop = 10;
	local left = imageMarginLeft;
	local picSkillIcon = tolua.cast(pnlPriceBase:CreateOrGetControl("picture", "skillicon", left, imageMarginTop, imageSize, imageSize), "ui::CPicture");
	picSkillIcon:SetGravity(ui.LEFT, ui.TOP);
	picSkillIcon:EnableHitTest(0);
	picSkillIcon:SetEnableStretch(1);
	left = left + imageSize + imageMarginRight;

	local countControlWidth = 90;
	local textHMargin = 10;
	local textMarginTOP = 12;
	local nameWidth = width - left - countControlWidth - textHMargin * 2;
	local nameControl = pnlPriceBase:CreateOrGetControl("richtext", "name", left, textMarginTOP, nameWidth, 24);
	nameControl:SetGravity(ui.LEFT, ui.TOP);
	nameControl:EnableHitTest(0);
	nameControl:SetText("{@st66b}スキル名がありませんでした{/}");
	left = left + nameWidth;

	local objSkill = GetClassByType("Skill", SkillID);
	if objSkill ~= nil then
		picSkillIcon:SetImage("icon_" .. objSkill.Icon);
		nameControl:SetText(string.format("{@st66b}%s{/}", objSkill.Name));
	end
	-- スキル・価格情報を埋め込んでおく
	pnlPriceBase:SetUserValue("SkillID", SkillID);
	local PriceInfo = Me.GetPriceInfo(SkillID)
	Me.CreatePriceGauge(pnlPriceBase, PriceInfo);
	Me.CreatePriceInputBox(pnlPriceBase, PriceInfo);
	Me.UpdatePricePanel(pnlPriceBase);
end

-- ==================================
--  リソース関連
-- ==================================
function Me.SetResText()
	Me.ResText = Me.ResText or {};
	Me.ResText.jp = Me.ResText.jp or {};
	Me.ResText.en = Me.ResText.en or {};
	local jpres = Me.ResText.jp;
	local enres = Me.ResText.en;
	-- Set string resource for Japanese.
	jpres.ShopName = {
		SquireBuff = "%s の修理商店",
		GemRoasting = "%sのジェムロースティング商店",
		General = "%s の露店"
	};
	jpres.Log = {
		ResetConfig = "設定がリセットされました",
		ResetAveragePrice = "平均価格がリセットされました",
		CallLoadSetting = "Me.LoadSettingが呼び出されました",
		CallSaveSetting = "Me.SaveSettingが呼び出されました",
		UseDefaultSetting = "Me.Settingが存在しないので標準の設定が呼び出されます",
		CannotGetSettingFrameHandle = "設定画面のハンドルが取得できませんでした",
		InitializeMe = "プログラムを初期化します",
		RedrawAllShopBaloon = "すべての露店バルーンを再描画します",
		BuySomething = "%sの%sを%ssで受けました。",
		UpdateAveragePrice = "%sの平均価格を%sに更新しました",
		IsSuburbMsg = "支払金額%ssですが、ここは郊外なので郊外割増の%ssを差し引いた金額%ssで記録します。",
		IsBelowCostMsg = "この価格は原価割れしているため、平均値推移に原価を記録します。",
		IsFartherValueMsg = "この価格は平均値からあまりに離れているため、平均値推移を更新しません。",
		IsShorterInterval = "まだ%d秒しか経過していないため、平均価格の更新は行いません。(設定待機時間:%d秒)",
		LoadTextResource = "文字情報の読み込みが完了しました"
	};
	jpres.data = {
		CostPrice = "原価",
		AveragePrice = "平均",
		CurrentPrice = "価格",
		BelowCost = "原価割れ",
		AtCost = "原価販売",
		NearCost = "ほぼ原価",
		GoodValue = "お値打ち",
		WithinAverage = "平均近く",
		ALittleExpensive = "高くない？",
		Expensive = "高いと思います",
		RipOff = "異常に高額!!",
		Empty = "予想外のパターン(バグ)",
		SaveTo = "保存先:",
		ShowMessageLog = "ログを表示する",
		ShowMsgBoxOnBuffShop = "バフ購入時の確認メッセージを表示しない",
		AddInfoToBaloon = "露店の看板に情報を追記する",
		EnableBaloonRightClick = "露店の看板の右クリックを有効にする",
		UpdateAverage = "平均値を更新する",
		AverageWeight = "移動平均の重み",
		AverageWeightUnit = ":",
		AverageUpdateInterval = "次の更新までの待機時間",
		AverageUpdateIntervalUnit = "秒",
		NoUpdateIfFartherValue = "値が平均から離れすぎているときは更新しない",
		PriceRadix = "基数",
		RuralCharge = "郊外割増 +",
		zone_BelowCost = "原価割れ",
		zone_NearCost = "ほぼ原価",
		zone_GoodValue = "お値打ち",
		zone_WithinAverage = "平均",
		zone_ALittleExpensive = "高くない？",
		zone_Expensive = "高い",
		zone_RipOff = "異常に高い",
		SettingFrameTitle = "Shop Helperの設定",
		TabGeneralSetting = "基本設定",
		TabAverageSetting = "平均価格設定",
		TabHowToUse = "使い方",
		GeneralSetting = "全般設定",
		Favorite = "お気に入り",
		AsNormal = "マークなし",
		Hate = "使いたくない",
		NeverShow = "見たくもない",
		LikeYou = "いいね",
		Save = "保存",
		CloseMe = "閉じる",
		UnknownSkillID = "スキルID[%s]",
		lblBuy = "{@st41}購入{/}",
		lblOngoing = "{@st41}{#FFAA33}バフ継続中{/}{/}",
		lblWarning = "{img NOTICE_Dm_! 32 32}{@st41}{#FF3333}高いよ？{/}{/}",
		WarningMsg = {
			title = "価格確認",
			body = "{#111111}この商品は{s24}{b}{ol}{#FF0000}異常に高い{/}{/}{/}{/}ですが、{nl}本当に購入してもいいですか？{/}"
		},
		HelpMsg = "{#333333}Shop Helperのコマンド説明{/}{nl}{#92D2A0}ShopHelperは次のコマンドで設定を呼び出してください。{/}{nl}{#333333}'/shophelper [コマンド]' または '/shelper [コマンド]' または '/sh [コマンド]'{/}{nl}{#333366}コマンドなしで呼び出された場合は設定ウィンドウを開きます。(例： /sh ){/}{nl}{#333333}使用可能なコマンド：{nl}/sh jp       :日本語モードに切り替え{nl}/sh en       :Switch to English mode.{nl}/sh reset    :価格の平均値設定をリセット{nl}/sh resetall :すべての設定をリセット{/}{nl} ",
		IsGoingMsg = "%s は既に付与されているため、購入を中止しました。",
		InvalidCommand = "無効なコマンドが呼び出されました{nl}コマンド一覧を見るには[ /sh ? ]を用いてください"
	};
	-- Me.ResText[Me.Settings.LangMode]["ResGroup"]["ResName"] で呼び出す

	-- Set string resource for English.
	enres.ShopName = {
		SquireBuff = "%s's repair stalls",
		GemRoasting = "%s's Gem-roasting stalls",
		General = "%s's stalls"
	};
	enres.Log = {
		ResetConfig = "Configuration was resetted.",
		ResetAveragePrice = "Data of average-prices was resetted.",
		CallLoadSetting = "[Me.LoadSetting] was called",
		CallSaveSetting = "[Me.SaveSetting] was called",
		UseDefaultSetting = "Since [Me.Setting] does not exist, use the default settings.",
		CannotGetSettingFrameHandle = "Failed to get the handle of setting screen.",
		InitializeMe = "Initialized the ShopHelper add-on.",
		RedrawAllShopBaloon = "Updated signs of all the stalls",
		BuySomething = "Received %s's %s in %ss.",
		UpdateAveragePrice = "The average price of %s has been updated to %s",
		IsSuburbMsg = "The payment amount is %ss, but since it is a suburb, minus a suburban charge of %ss. So, recorded at the amount of %ss.",
		IsBelowCostMsg = "As this price is broken down, Recorded the cost in the average value transition.",
		IsFartherValueMsg = "Since this price is too far from the average value, the average value transition was not updated.",
		IsShorterInterval = "Since only %d seconds have elapsed, the average price was not renewed. (Standby time setting: %d seconds)",
		LoadTextResource = "Reading of character information is completed."
	};
	enres.data = {
		CostPrice = "Cost price",
		AveragePrice = "Average price",
		PriceRadix = "Radix",
		CurrentPrice = "Current price",
		BelowCost = "Below cost",
		AtCost = "At cost price",
		NearCost = "Near cost price",
		GoodValue = "Good value",
		WithinAverage = "Within Average price range",
		ALittleExpensive = "Is't it a little expensive?",
		Expensive = "Expensive",
		RipOff = "Rip-off!",
		Empty = "Out of implementation(Bugs?)",
		SaveTo = "Storage destination:",
		ShowMessageLog = "Enable log display to chat log",
		ShowMsgBoxOnBuffShop = "Disable confirmation messages when buying buffs",
		AddInfoToBaloon = "Enable Additional draws to the sign board",
		EnableBaloonRightClick = "Enable right-click-menus of sign board",
		UpdateAverage = "Update the average price",
		AverageWeight = "The weight of the moving average",
		AverageWeightUnit = " to ",
		AverageUpdateInterval = "Interval to next update",
		AverageUpdateIntervalUnit = "seconds",
		NoUpdateIfFartherValue = "Disable update when the price is too far from the average",
		PriceRadix = "Radix",
		RuralCharge = "In the suburbs, raise the price",
		zone_BelowCost = "Below cost",
		zone_NearCost = "Near cost",
		zone_GoodValue = "Good value",
		zone_WithinAverage = "Within Average",
		zone_ALittleExpensive = "a little expensive",
		zone_Expensive = "Expensive",
		zone_RipOff = "Rip-off!",
		SettingFrameTitle = "Setting  -Shop Helper-",
		TabGeneralSetting = "Generals",
		TabAverageSetting = "Averages",
		TabHowToUse = "How to use",
		GeneralSetting = "General Settings",
		Favorite = "It's my Favorite!!",
		AsNormal = "As normal.",
		Hate = "I do not want to use.",
		NeverShow = "Never show it!!",
		LikeYou = "Like!",
		Save = "Save",
		CloseMe = "Close",
		UnknownSkillID = "Unknown Skill-ID [%s]",
		lblBuy = "{@st41}Buy",
		lblOngoing = "{@st41}{#FFAA33}Currently ongoing{/}{/}",
		lblWarning = "{@st41}{#FF3333}Not regret?{/}{/}",
		WarningMsg = {
			title = "Warning!!",
			body = "{#111111}This item is {nl}{s24}{b}{ol}{#FF0000}abnormally expensive{/}{/}{/}{/}.{nl}Are you sure you're not gonna regret this?{/}"
		},
		HelpMsg = "{nl}{#92D2A0}To change settings of 'ShopHelper', please call the following command.{/}{nl}{#333333}'/shophelper [paramaters]' or '/shelper [paramaters]' or '/sh [paramaters]'{/}{nl}{#333366}The setting screen will be displayed when you call the comannd without paramaters.(e.g. /sh ){/}{nl}{#333333}Available commands:{nl}/sh jp       :Switch to Japanese mode.(日本語へ){nl}/sh en       :Switch to English mode.{nl}/sh reset    :Reset the paramaters of price average settings.{nl}/sh resetall :Reset the all settings.{/}{nl} ",
		IsGoingMsg = "Since the buff '%s' has already been granted, it ceased to purchase.",
		InvalidCommand = "An invalid command was invoked.{nl}To see the command list, please using the command{nl}[/sh ?]"
	};
	TOUKIBI_SHOPHELPER_ADDLOG(Me.ResText[Me.Settings.LangMode].Log.LoadTextResource, "Info", true, true);
end
