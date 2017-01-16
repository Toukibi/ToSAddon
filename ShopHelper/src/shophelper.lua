local addonName = "ShopHelper";
local verText = "0.01e";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
Me.HoockedOrigProc = Me.HoockedOrigProc or {};

if (not Me.Settings) then
	Me.Settings = {};
	Me.Settings.DoNothing = true;
end


Me.loaded = false;
CHAT_SYSTEM(addonName .. " " .. verText .. " loaded!");

function SHOPHELPER_ON_INIT(addon, frame)
	-- フックしたいイベントを記述
--	Me.setHook(Me.AUTOSELLER_BALLOON_HOOKED, "AUTOSELLER_BALLOON"); 
	Me.setHook(Me.OPEN_ITEMBUFF_UI_HOOKED, "OPEN_ITEMBUFF_UI");
	Me.setHook(Me.UPDATE_BUFFSELLER_SLOT_TARGET_HOOKED, "UPDATE_BUFFSELLER_SLOT_TARGET");
	-- 読み込み完了処理を記述
	Me.loaded = true;
end

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

function Me.OPEN_ITEMBUFF_UI_HOOKED(groupName, sellType, handle) 
	Me.HoockedOrigProc["OPEN_ITEMBUFF_UI"](groupName, sellType, handle); 
	if sellType == AUTO_SELL_GEM_ROASTING then
		Me.AddInfoToGemRoasting(ui.GetFrame("itembuffgemroasting"));
	elseif sellType == AUTO_SELL_SQUIRE_BUFF then
		Me.AddInfoToSquireBuff(ui.GetFrame("itembuffrepair"));
	end
end 

function Me.UPDATE_BUFFSELLER_SLOT_TARGET_HOOKED(ctrlSet, info)
	Me.HoockedOrigProc["UPDATE_BUFFSELLER_SLOT_TARGET"](ctrlSet, info);
	Me.AddInfoToBuffSellerSlot(ctrlSet, info)
end

function Me.PrintShopInfo(sellType)
	if sellType == AUTO_SELL_BUFF then
	elseif sellType == AUTO_TITLE_FOOD_TABLE then
	elseif sellType == AUTO_SELL_GEM_ROASTING then
		Me.AddInfoToGemRoasting(ui.GetFrame("itembuffgemroasting"));
	elseif sellType == AUTO_SELL_SQUIRE_BUFF then
		Me.AddInfoToSquireBuff(ui.GetFrame("itembuffrepair"));
	elseif sellType == AUTO_SELL_OBLATION then
	elseif sellType == AUTO_SELL_ORACLE_SWITCHGENDER then
	elseif sellType == AUTO_ENCHANTAROR_STORE_OPEN then
	elseif sellType == AUTO_SELL_ENCHANTERARMOR then
	elseif sellType == AUTO_SELL_ORACLE_SWITCHGENDER then
	else
	end
end

function Me.GetBuffLvColorFor15(SLv)
	local ResultValue = "FFFFFF";
	if SLv <= 6 then
		ResultValue = "FFFFFF";
	elseif SLv < 15 then
		ResultValue = "108CFF";
	elseif SLv == 15 then
		ResultValue = "9F30FF";
	elseif SLv > 15 then
		ResultValue = "FF4F00";
	end
	return ResultValue;
end

function Me.GetBuffLvColorFor10(SLv)
	local ResultValue = "FFFFFF";
	if SLv < 5 then
		ResultValue = "FFFFFF";
	elseif SLv <= 6 then
		ResultValue = "108CFF";
	elseif SLv == 10 then
		ResultValue = "9F30FF";
	elseif SLv > 10 then
		ResultValue = "FF4F00";
	end
	return ResultValue;
end

function Me.ReturnBuffPriceInfo(SkillID)
	if SkillID == 40203 then
		return 400, 750, 10, 15, true; -- ブレス
	elseif SkillID == 40205 then
		return 700, 850, 10, 10, true; -- サクラ
	elseif SkillID == 40201 then
		return 1000, 1050, 10, 15, true; -- アスパ
	else
		return 100, 100, 20, 15, false; -- それ以外
	end
end

function Me.PriceText(Price, CostPrice, MeanPrice, Span, ShowCostPrice, ShowComment, ShowPriceComparison)
	local PriceText = Price;
	local Comment = "";
	local Comparsion = "";
	local DoAlart = false;
	if Price < CostPrice then
		PriceText = "{#0000FF}" .. Price .. "{/}";
		Comment = "{#0000FF}原価割れ{/}";
		Comparsion = "原価:160s";
	elseif Price == CostPrice then
		PriceText = "{#0000FF}" .. Price .. "{/}";
		Comment = "{#0000FF}原価販売{/}";
		Comparsion = "原価:160s";
	elseif Price <= CostPrice + Span * 3 then
		PriceText = "{@st41b}{#00CC00}" .. Price .. "{/}{/}";
		Comment = "{#006633}ほぼ原価{/}";
		Comparsion = "原価+" .. Price - CostPrice;
	elseif Price < MeanPrice - Span * 2 then
		-- お値打ち1
		PriceText = "{@st41b}{#9999FF}" .. Price .. "{/}{/}";
		Comment = "{#3333FF}お値打ち!!{/}";
		Comparsion = "平均-" .. MeanPrice - Price .. "  原価+" .. Price - CostPrice;
	elseif Price < MeanPrice then
		-- お値打ち2
		PriceText = "{@st41b}{#CCCCFF}" .. Price .. "{/}{/}";
		Comment = "平均近く";
		Comparsion = "平均-" .. MeanPrice - Price .. "  原価+" .. Price - CostPrice;
	elseif Price <= MeanPrice + Span * 5 then
		-- 普通
		PriceText = "{@st41b}" .. Price .. "{/}";
		Comment = "平均近く";
		Comparsion = "平均+" .. Price - MeanPrice .. "  原価+" .. Price - CostPrice;
	elseif Price <= MeanPrice + Span * 20 then
		-- ちょい高
		PriceText = "{@st41b}{#FF9999}" .. Price .. "{/}{/}";
		Comment = "高くない？";
		Comparsion = "平均+" .. Price - MeanPrice .. "  原価+" .. Price - CostPrice;
	elseif Price >= MeanPrice * 1.8 then
		-- 異常に高い2
		PriceText = "{img NOTICE_Dm_! 26 26}{@st41b}{#FF0000}" .. Price .. "{/}{/}";
		local CostRate = math.floor(Price * 100 / CostPrice);
		local MeanRate = math.floor(Price * 100 / CostPrice);
		Comment = "異常に高額!!";
		Comparsion = "平均×" .. math.floor(MeanRate / 100) .. "." .. MeanRate % 100 .. "  原価×" .. math.floor(CostRate / 100) .. "." .. CostRate % 100;
		DoAlart = true;
	elseif Price >= MeanPrice + Span * 100 then
		-- 異常に高い1
		PriceText = "{img NOTICE_Dm_! 26 26}{@st41b}{#FF0000}" .. Price .. "{/}{/}";
		Comment = "異常に高額!!";
		Comparsion = "平均+" .. Price - MeanPrice .. "  原価+" .. Price - CostPrice;
		DoAlart = true;
	else
		PriceText = "{@st41b}{#FF3333}" .. Price .. "{/}{/}";
		Comment = "高いと思います";
		Comparsion = "平均+" .. Price - MeanPrice .. "  原価+" .. Price - CostPrice;
	end
	local ReturnText = "";
	if ShowCostPrice then
		if ReturnText ~= "" then ReturnText = ReturnText .. "  " end
		ReturnText = ReturnText .. PriceText;
	end
	if ShowComment then
		if ReturnText ~= "" then ReturnText = ReturnText .. "  " end
		ReturnText = ReturnText .. Comment;
	end
	if ShowPriceComparison then
		local AddBrackets = (ShowCostPrice or ShowComment)
		if AddBrackets then ReturnText = ReturnText .. " (" end
		ReturnText = ReturnText .. Comparsion;
		if AddBrackets then ReturnText = ReturnText .. ")" end
	end
	return ReturnText, DoAlart;
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
		local TextColor = Me.GetBuffLvColorFor15(SLv);
		Me.AddRichText(BaseFrame, "lblOwnerInfo", "{@st42b}{#" .. TextColor .. "}Lv." .. SLv .. "{/}{/}    " .. OwnerFamilyName .. " の修理露店", 40, 120, 420, 20, 16);
		Me.AddRichText(BaseFrame, "lblPriceInfo", "単価：" .. Me.PriceText(Price, 160, 170, 1, true, true, true), 40, 200, 420, 20, 16);
	end
end

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
		local TextColor = Me.GetBuffLvColorFor10(SLv);
		Me.AddRichText(BaseFrame, "lblOwnerInfo", "{@st42b}{#" .. TextColor .. "}Lv." .. SLv .. "{/}{/}    " .. OwnerFamilyName .. " のジェムロースティング店", 40, 120, 420, 20, 16);
		Me.AddRichText(BaseFrame, "lblPriceInfo", "単価：" .. Me.PriceText(Price, 6000, 6500, 50, true, true, true), 40, 200, 420, 20, 16);
	end
end

function Me.AddInfoToBuffSellerSlot(BaseFrame, info)
	if BaseFrame == nil then return nil end
	local ParentFrame = BaseFrame:GetTopParentFrame();
	if ParentFrame == nil then return nil end
	if ParentFrame:GetUserIValue("HANDLE") ==  session.GetMyHandle() then return nil end
	local CostPrice, MeanPrice, Span, MaxLv, DoAddInfo = Me.ReturnBuffPriceInfo(info.classID);

	if DoAddInfo then
		local strPrice = Me.PriceText(info.price, CostPrice, MeanPrice, Span, true, false, false);
		local strComment, DoAlart = Me.PriceText(info.price, CostPrice, MeanPrice, Span, false, true, false);
		local strComparsion = Me.PriceText(info.price, CostPrice, MeanPrice, Span, false, false, true);
		local TextColor = "FFFFFF";
		if MaxLv == 15 then
			TextColor = Me.GetBuffLvColorFor15(info.level);
		elseif MaxLv == 10 then
			TextColor = Me.GetBuffLvColorFor10(info.level);
		else
			TextColor = Me.GetBuffLvColorFor15(info.level);
		end
		local lblSLv = BaseFrame:GetChild("skilllevel");
		lblSLv:SetTextByKey("value", "{@st41}{#" .. TextColor .. "}" .. info.level .. "{/}{/}");
		local lblPrice = BaseFrame:GetChild("price")
		lblPrice:SetTextByKey("value", strPrice);
		lblPrice:SetTextTooltip(strComparsion);

		-- ボタンを上へ動かす
		local objTextItem = Me.AddRichTextToCenter(BaseFrame, "lblPriceInfo", strComment, 250, 40, 150, 20, 16);
		objTextItem:SetTextTooltip(strComparsion);
		local BuyButton = BaseFrame:GetChild("btn");
		if BuyButton ~= nil then
			tolua.cast(BuyButton, 'ui::CButton');
			Me.ChangeControlMargin_Left(BuyButton, 280 - 30);
			BuyButton:Resize(118 + 30, 45);
			if DoAlart then
				BuyButton:SetText("{img NOTICE_Dm_! 32 32}{@st41}{#FF3333}高いよ？{/}{/}");
			else
				BuyButton:SetText("");
				BuyButton:SetText("{@st41}購入");
			end
		end
	end
end

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