local addonName = "ShopHelper";
local verText = "0.50beta";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
Me.HoockedOrigProc = Me.HoockedOrigProc or {};
Me.BuyHistory = Me.BuyHistory or {};
Me.SettingFilePathName = string.format("../addons/%s/settings.json", addonNameLower);
Me.DebugMode = false;
Me.loaded = false;

-- ==================================
--  初期化関連
-- ==================================

CHAT_SYSTEM(string.format("{#333333}[Add-ons]%s %s loaded!{/}", addonName, verText));
-- For Debbug use
if Me.DebugMode then ShopHelper = Me end

function SHOPHELPER_ON_INIT(addon, frame)
	Me.SettingFrame = frame
	Me.AddonHandle = addon
	-- 各種設定を読み込む
	if not Me.loaded then
		Me.LoadSetting();
		Me.SetResText();
	end
	Me.RefreshMe(addon, frame)
	-- 非表示中のフレームのリスト
	Me.HiddenFrameList = {};
	-- 読み込み完了処理を記述
	Me.loaded = true;
end

function Me.CreateValueWithStyleCode(Value, Styles)
	-- ValueにStylesで与えたスタイルタグを付加した文字列を返します
	local ReturnValue;
	if Styles == nil or #Styles == 0 then
		-- スタイル指定なし
		ReturnValue = Value
	else
		local TagHeader = ""
		for i, StyleTag in ipairs(Styles) do
			TagHeader = TagHeader .. string.format( "{%s}", StyleTag)
		end
		ReturnValue = string.format( "%s%s%s", TagHeader, Value, string.rep("{/}", #Styles))
	end
	return ReturnValue;
end

function TOUKIBI_SHOPHELPER_ADDLOG(Message, Mode, DisplayAddonName, OnlyDebugMode)
	if Me.Settings == nil then return end
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
function Me.SetDefaultSetting()
	TOUKIBI_SHOPHELPER_ADDLOG("設定がリセットされました", "Warning", true, false);
	Me.Settings = {
		DoNothing = true,
		LangMode = "jp",
		ShowMessageLog = false,
		ShowMsgBoxOnBuffShop = true;
		UpdateAverage = true,
		AddInfoToBaloon = false,
		EnableBaloonRightClick = false,
		AverageNCount = 30,
		RecalcInterval = 60
	};
	Me.SetDefaultPrice();
end

-- 平均価格をリセット
function Me.SetDefaultPrice()
	TOUKIBI_SHOPHELPER_ADDLOG("平均価格がリセットされました", "Warning", true, false);
	Me.Settings.AveragePrice = {};
	Me.Settings.AveragePrice['GemRoasting'] = 6500; -- ClassID = 21003
	Me.Settings.AveragePrice['SquireBuff'] = 170; -- ClassID = 10703
	Me.Settings.AveragePrice['21003'] = 6500; -- ClassID = 21003
	Me.Settings.AveragePrice['10703'] = 170; -- ClassID = 10703
	Me.Settings.AveragePrice['40203'] = 750; -- ブレス
	Me.Settings.AveragePrice['40205'] = 850; -- サクラ
	Me.Settings.AveragePrice['40201'] = 1050; -- アスパ
end

-- 設定読み込み
function Me.LoadSetting()
	TOUKIBI_SHOPHELPER_ADDLOG("Me.LoadSettingが呼び出されました", "Info", true, true)
	local acutil = require("acutil");
	local objReadValue, error = acutil.loadJSON(Me.SettingFilePathName);
	if error then
		Me.SetDefaultSetting();
		Me.SaveSetting();
	else
		Me.Settings = objReadValue;
	end
end

-- 設定書き込み
function Me.SaveSetting()
	TOUKIBI_SHOPHELPER_ADDLOG("Me.SaveSettingが呼び出されました", "Info", true, true)
	if Me.Settings == nil then
		TOUKIBI_SHOPHELPER_ADDLOG("Me.Settingが存在しないので標準の設定が呼び出されます", "Warning", true, false)
		Me.SetDefaultSetting()
	end
	TOUKIBI_SHOPHELPER_ADDLOG("保存先:" .. Me.SettingFilePathName, "Info", true, true)
	local acutil = require("acutil");
	acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
end

function Me.SettingFrame_BeforeDisplay()
	local BaseFrame = ui.GetFrame("shophelper");
	if BaseFrame == nil then
		TOUKIBI_SHOPHELPER_ADDLOG("設定画面のハンドルが取得できませんでした", "Warning", true, false);
		return;
	end
	Me.InitSettingText(BaseFrame);
	Me.InitSettingValue(BaseFrame);
	BaseFrame:ShowWindow(1);
end

function Me.InitSettingText(BaseFrame)
	-- 微調整
	-- local HeaderFrame = GET_CHILD(BaseFrame, "pnlMain", "ui::CGroupBox");
	-- BaseFrame:SetSkinName("test_frame_low");



	-- ここまで転記完了
	-- GET_CHILD_GROUPBOX(frame, name) でグループボックスが取得可能
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");
	local TargetGBox = GET_CHILD_GROUPBOX(BodyGBox, "pnlPrice");
	BaseFrame:Resize(640, 900);
	BodyGBox:Resize(640, 800);
	Me.ChangeControlMargin_Top(TargetGBox, 370 + 40);


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
end

function Me.OpenSettingFrame()
	Me.SettingFrame_BeforeDisplay();
end

function Me.CloseSettingFrame()
	local BaseFrame = ui.GetFrame("shophelper");
	if BaseFrame == nil then
		TOUKIBI_SHOPHELPER_ADDLOG("設定画面のハンドルが取得できませんでした", "Warning", true, false);
		return;
	end
	BaseFrame:ShowWindow(0);
end

function Me.ExecSetting()
	local BaseFrame = ui.GetFrame("shophelper");
	if BaseFrame == nil then
		TOUKIBI_SHOPHELPER_ADDLOG("設定画面のハンドルが取得できませんでした", "Warning", true, false);
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


	Me.SaveSetting()
	Me.CloseSettingFrame()
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
	InitSettingText(frame);
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

-- 言語切替
function TOUKIBI_SHOPHELPER_CHANGE_LANGMODE()
	CHAT_SYSTEM(Me.GetSelectedRadioButton(Me.GetLangSeedRadioButton("lang_jp")));
	-- Me.ChangeLanguage("jp");
end

-- コマンド受取
function TOUKIBI_SHOPHELPER_PROCESS_COMMAND(command)
	TOUKIBI_SHOPHELPER_ADDLOG("TOUKIBI_SHOPHELPER_PROCESS_COMMANDが呼び出されました", "Info", true, true)
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
		TOUKIBI_SHOPHELPER_ADDLOG("プログラムを初期化します", "Notice", true, false);
		Me.RefreshMe(Me.AddonHandle, Me.SettingFrame);
		return;
	elseif cmd == "jp" or cmd == "en" or string.len(cmd) == 2 then
		-- 言語モードと勘違いした？
		ChangeLanguage(cmd);
		return;
	elseif cmd ~= "?" then
		TOUKIBI_SHOPHELPER_ADDLOG("無効なコマンドが呼び出されました{nl}コマンド一覧を見るには[ /sh ? ]を用いてください", "Warning", true, false);
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
		-- Me.Settings[SettingName] = CurrentValue;
		if BuddyText ~= nil then
			BuddyText:SetTextByKey("opValue", CurrentValue);
		end
	end
end

--コンテキストメニュー表示 
function TOUKIBI_SHOPHELPER_OPEN_BALOON_CONTEXT_MENU(frame, msg, clickedGroupName, argNum) 
	-- local context = ui.CreateContextMenu("TEMPLATE_RBTN", addonName, 0, 0, 300, 100); 
	-- ui.AddContextMenuItem(context, "Hide", "TEMPLATE_TOGGLE_FRAME()"); 
	-- context:Resize(300, context:GetHeight()); 
	-- ui.OpenContextMenu(context); 
end 

-- ==================================
--  メイン
-- ==================================

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
		objSkillName = string.format("スキルID[%s]", skillID);
	end
	TOUKIBI_SHOPHELPER_ADDLOG(string.format("%sの%sを%ssで受けました。"
							, OwnerFamilyName
							, objSkillName
							, Me.GetCommaedTextEx(LatestPrice)
							), "Info", true, false);

	if Me.Settings.UpdateAverage then
		Me.BuyHistory[handle] = Me.BuyHistory[handle] or {};
		Me.BuyHistory[handle][skillID] = Me.BuyHistory[handle][skillID] or {};
		local CurrentHistory = Me.BuyHistory[handle][skillID];
		if CurrentHistory.LatestUse == nil or os.clock() - CurrentHistory.LatestUse >= Me.Settings.RecalcInterval then
			-- 修正移動平均を求めて平均値を更新する
			Me.Settings.AveragePrice[tostring(skillID)] = (Me.Settings.AveragePrice[tostring(skillID)] * (Me.Settings.AverageNCount - 1) + LatestPrice) / Me.Settings.AverageNCount
			CurrentHistory.LatestUse = os.clock();
			TOUKIBI_SHOPHELPER_ADDLOG(string.format("%sの平均価格を%sに更新しました"
									, objSkillName
									, Me.GetCommaedTextEx(Me.Settings.AveragePrice[tostring(skillID)], nil, 2)
									), "Info", true, false);

			Me.SaveSetting()
		else
			TOUKIBI_SHOPHELPER_ADDLOG(string.format("まだ%d秒しか経過していないため、平均価格の更新は行いません。(設定待機時間:%d秒)"
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
function Me.GetPriceInfo(skillID)
	local ReturnValue = {};
	ReturnValue.AveragePrice = Me.Settings.AveragePrice[tostring(skillID)];
	if ReturnValue.AveragePrice == nil then
		ReturnValue.AveragePrice = 100;
	end
	if skillID == 40203 then
		-- ブレス
		ReturnValue.CostPrice = 400;
		ReturnValue.Span = 10;
		ReturnValue.MaxLv = 15;
		ReturnValue.DoAddInfo = true
	elseif skillID == 40205 then
		-- サクラ
		ReturnValue.CostPrice = 700;
		ReturnValue.Span = 10;
		ReturnValue.MaxLv = 10;
		ReturnValue.DoAddInfo = true
	elseif skillID == 40201 then
		-- アスパ
		ReturnValue.CostPrice = 1000;
		ReturnValue.Span = 10;
		ReturnValue.MaxLv = 15;
		ReturnValue.DoAddInfo = true
	elseif skillID == 10703 then
		-- 修理
		ReturnValue.CostPrice = 160;
		ReturnValue.Span = 1;
		ReturnValue.MaxLv = 15;
		ReturnValue.DoAddInfo = true
	elseif skillID == 21003 then
		-- ジェムロースティング
		ReturnValue.CostPrice = 6000;
		ReturnValue.Span = 50;
		ReturnValue.MaxLv = 10;
		ReturnValue.DoAddInfo = true
	else
		-- それ以外
		ReturnValue.CostPrice = 100;
		ReturnValue.Span = 20;
		ReturnValue.MaxLv = 15;
		ReturnValue.DoAddInfo = false;
	end
	return ReturnValue;
end

-- 値段のテキスト情報を作成する
function Me.GetPriceText(Price, PriceInfo)
	local ReturnValue = {};
	local CustomFormat = {};
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
	elseif Price < PriceInfo.AveragePrice - PriceInfo.Span * 2 then
		-- お値打ち1
		ReturnValue.ImpressionValue = "GoodValue"
		CustomFormat.Price = {"@st41b", "#9999FF"};
		CustomFormat.Impression = {"#3333FF"};
	elseif Price < PriceInfo.AveragePrice then
		-- お値打ち2 だけど大体平均
		ReturnValue.ImpressionValue = "WithinAverage"
		CustomFormat.Price = {"@st41b", "#CCCCFF"};
	elseif Price <= PriceInfo.AveragePrice + PriceInfo.Span * 5 then
		-- 普通
		ReturnValue.ImpressionValue = "WithinAverage"
		CustomFormat.Price = {"@st41b"};
	elseif Price <= PriceInfo.AveragePrice + PriceInfo.Span * 20 then
		-- ちょい高
		ReturnValue.ImpressionValue = "ALittleExpensive"
		CustomFormat.Price = {"@st41b", "#FF9999"};
	elseif Price >= PriceInfo.AveragePrice * 1.8 then
		-- 異常に高い2
		ReturnValue.ImpressionValue = "RipOff"
		CustomFormat.Price = {"img NOTICE_Dm_! 26 26", "@st41b", "#FF0000"};
	elseif Price >= PriceInfo.AveragePrice + PriceInfo.Span * 100 then
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

		ReturnValue.ToolTipText = Me.MakePriceToolTipText(Price, PriceInfo.CostPrice, PriceInfo.AveragePrice);
	elseif ReturnValue.ImpressionValue == "AtCost" then
		-- 原価との比較のみ表示
		ReturnValue.ComparsionText = string.format("%s%s"
												 , Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
												 , Me.GetCommaedTextEx(Price - PriceInfo.CostPrice, 0, 0, true, true));
		ReturnValue.ToolTipText = Me.MakePriceToolTipText(Price, PriceInfo.CostPrice, PriceInfo.AveragePrice);
	elseif ReturnValue.ImpressionValue == "RipOff" and  Price >= PriceInfo.AveragePrice * 1.8 then
		-- 原価・平均との割合で表示(ぼったくり対応)
		ReturnValue.ComparsionText = string.format("%sx%s  %sx%s"
												 , Me.ResText[Me.Settings.LangMode]["data"]["AveragePrice"]
												 , Me.GetCommaedTextEx(Price / PriceInfo.AveragePrice, nil, 2)
												 , Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
												 , Me.GetCommaedTextEx(Price / PriceInfo.CostPrice, nil, 2));

		ReturnValue.ToolTipText = Me.MakePriceToolTipText(Price, PriceInfo.CostPrice, PriceInfo.AveragePrice, true);
	else
		-- 通常表示(原価と平均比較)
		ReturnValue.ComparsionText = string.format("%s%s  %s%s"
												 , Me.ResText[Me.Settings.LangMode]["data"]["AveragePrice"]
												 , Me.GetCommaedTextEx(Price - PriceInfo.AveragePrice, nil, nil, true)
												 , Me.ResText[Me.Settings.LangMode]["data"]["CostPrice"]
												 , Me.GetCommaedTextEx(Price - PriceInfo.CostPrice, nil, nil, true));

		ReturnValue.ToolTipText = Me.MakePriceToolTipText(Price, PriceInfo.CostPrice, PriceInfo.AveragePrice);
	end
	if ReturnValue.ImpressionValue == "RipOff" then ReturnValue.DoAlart = true end
	return ReturnValue;
end

function Me.ADDTO_SHOPBALOON(title, sellType, handle, skillID, skillLv)
	-- デフォルト状態のショップバルーンを作ってもらう
	Me.HoockedOrigProc["AUTOSELLER_BALLOON"](title, sellType, handle, skillID, skillLv); 
	-- 以下カスタム用
	-- 作られたフレームを再取得する
	local frame = ui.GetFrame("SELL_BALLOON_" .. handle);
	if true or (frame == nil) then
		return nil;
	end
	if true then
		return nil;
	end
	--	CHAT_SYSTEM("AUTOSELLER_BALLOON_HOOKED実行");
	-- 落書きする
	local lvBox = frame:GetChild("withLvBox");
	local text = frame:GetChild("text");
	if sellType == AUTO_SELL_BUFF or sellType == AUTO_SELL_GEM_ROASTING or sellType == AUTO_SELL_SQUIRE_BUFF or sellType == AUTO_SELL_ENCHANTERARMOR then
		local lvText = lvBox:GetChild("lv_text");
		local lvTitle = lvBox:GetChild('lv_title');
		lvText:SetTextByKey("value", skillLv);
		if sellType == AUTO_SELL_BUFF then
			lvTitle:SetTextByKey("value", title .. 'のつもり');
		elseif sellType == AUTO_SELL_SQUIRE_BUFF then
			lvTitle:SetTextByKey("value", title .. 'だといいな');
		else
			lvTitle:SetTextByKey("value", title);
		end
		text:ShowWindow(0);
	else
		-- 現状は何もしない
		text:SetTextByKey("value", title);
		lvBox:ShowWindow(0);
	end	


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
				BuyButton:SetText(Me.ResText[Me.Settings.LangMode].data.lblBuy);
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
		TOUKIBI_SHOPHELPER_ADDLOG("設定画面のハンドルが取得できませんでした", "Warning", true, false);
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
function Me.MakePriceToolTipText(Price, CostPrice, AveragePrice, MultiplicationMode)
	local lMultiplicationMode = MultiplicationMode or false;
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
		ReturnText = string.format("%s %s   (%s:%ss){nl}%s %s   (%s:%ss)"
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
	Me.LoadSetting()
	Me.SetResText()
	
	-- フックしたいイベントを記述
	--	Me.setHook(Me.AUTOSELLER_BALLOON_HOOKED, "AUTOSELLER_BALLOON"); 
	Me.setHook(Me.OPEN_ITEMBUFF_UI_HOOKED, "OPEN_ITEMBUFF_UI");
	Me.setHook(Me.UPDATE_BUFFSELLER_SLOT_TARGET_HOOKED, "UPDATE_BUFFSELLER_SLOT_TARGET");
	Me.setHook(Me.BUY_BUFF_AUTOSELL_HOOKED, "BUY_BUFF_AUTOSELL");
	Me.setHook(Me.SQIORE_REPAIR_EXCUTE_HOOKED, "SQIORE_REPAIR_EXCUTE");
	Me.setHook(Me.GEMROASTING_EXCUTE_HOOKED, "GEMROASTING_EXCUTE");
	addon:RegisterMsg("FPS_UPDATE", "TOUKIBI_SHOPHELPER_HIDE_PLAYERS");
	-- CHAT_SYSTEM("{#333333}[ShopHelper]イベントのフック登録が完了しました{/}");
	local acutil = require("acutil");
	acutil.slashCommand("/shophelper", TOUKIBI_SHOPHELPER_PROCESS_COMMAND);
	acutil.slashCommand("/shelper", TOUKIBI_SHOPHELPER_PROCESS_COMMAND);
	acutil.slashCommand("/sh", TOUKIBI_SHOPHELPER_PROCESS_COMMAND);

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
		GemRoasting = "%sのジェムロースティング商店"
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
		lblBuy = "{@st41}購入{/}",
		lblWarning = "{img NOTICE_Dm_! 32 32}{@st41}{#FF3333}高いよ？{/}{/}",
		WarningMsg = {
			title = "価格確認",
			body = "{#111111}この商品は{s24}{b}{ol}{#FF0000}異常に高い{/}{/}{/}{/}ですが、{nl}本当に購入してもいいですか？{/}"
		},
		HelpMsg = "{#333333}Shop Helperのコマンド説明{/}{nl}{#92D2A0}ShopHelperは次のコマンドで設定を呼び出してください。{/}{nl}{#333333}'/shophelper [コマンド]' または '/shelper [コマンド]' または '/sh [コマンド]'{/}{nl}{#333366}コマンドなしで呼び出された場合は設定ウィンドウを開きます。(例： /sh ){/}{nl}{#333333}使用可能なコマンド：{nl}/sh jp       :日本語モードに切り替え{nl}/sh en       :Switch to English mode.{nl}/sh reset    :価格の平均値設定をリセット{nl}/sh resetall :すべての設定をリセット{/}{nl} "
	};

	-- Set string resource for English.
	enres.ShopName = {
		SquireBuff = "%s の修理商店",
		GemRoasting = "%sのジェムロースティング商店"
	};
	enres.data = {
		CostPrice = "Cost price",
		AveragePrice = "Average price",
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
		lblBuy = "{@st41}Buy",
		lblWarning = "{@st41}{#FF3333}Not regret?{/}{/}",
		WarningMsg = {
			title = "Warning!!",
			body = "{#111111}This item is {nl}{s24}{b}{ol}{#FF0000}abnormally expensive{/}{/}{/}{/}.{nl}Are you sure you're not gonna regret this?{/}"
		},
		HelpMsg = "{nl}{#92D2A0}To change settings of 'ShopHelper', please call the following command.{/}{nl}{#333333}'/shophelper [paramaters]' or '/shelper [paramaters]' or '/sh [paramaters]'{/}{nl}{#333366}The setting screen will be displayed when you call the comannd without paramaters.(e.g. /sh ){/}{nl}{#333333}Available commands:{nl}/sh jp       :Switch to Japanese mode.(日本語へ){nl}/sh en       :Switch to English mode.{nl}/sh reset    :Reset the paramaters of price average settings.{nl}/sh resetall :Reset the all settings.{/}{nl} "
	};
	TOUKIBI_SHOPHELPER_ADDLOG("文字情報の読み込みが完了しました", "Info", true, true);
end
