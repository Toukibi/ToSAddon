local addonName = "EquipMarker";
local verText = "1.00";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
EMarker = Me;
local DebugMode = false;

-- コモンモジュール(の代わり)
local Toukibi = {
	
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
local function logdev(value)
	if value == nil then Caption = "nil value!!" end
	local Caption = tostring(value) or "Test Printing";
	DEVELOPERCONSOLE_PRINT_TEXT(Caption);
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


-- ***** 変数の宣言と設定 *****
Me.Loaded = false;

-- ===== アドオンの内容ここから =====

local function GetItemGrade(objItem)
	local grade = objItem.ItemGrade;

	if (objItem.ItemType == "Recipe") then
		local recipeGrade = tonumber(objItem.Icon:match("misc(%d)")) - 1;
		if (recipeGrade <= 0) then recipeGrade = 1 end;
		grade = recipeGrade;
	end
	return grade;
end

local function GetItemRarityColor(objItem)
	local itemProp = geItemTable.GetProp(objItem.ClassID);
	local grade = GetItemGrade(objItem);

	if (itemProp.setInfo ~= nil) then return "00FF00"; -- set piece
	elseif (grade == 0) then return "FFBF33"; -- premium
	elseif (grade == 1) then return "FFFFFF"; -- common
	elseif (grade == 2) then return "108CFF"; -- rare
	elseif (grade == 3) then return "9F30FF"; -- epic
	elseif (grade == 4) then return "FF4F00"; -- orange
	elseif (grade == 5) then return "FFFF53"; -- legendary
	else return "E1E1E1"; -- no grade (non-equipment items)
	end
end

-- 本当はこんなコード書きたくない!!
local function GetItemStatus(objItem)
	local ReinforceValue = TryGetProp(objItem, "Reinforce_2");
	local NeedAppraisal = TryGetProp(objItem, "NeedAppraisal");
	local NeedRandomOption = TryGetProp(objItem, "NeedRandomOption");

	local NotAppraisal = false;
	if NeedAppraisal ~= nil or NeedRandomOption ~= nil then
		if NeedAppraisal == 1 or NeedRandomOption == 1 then
			NotAppraisal = true;
		end
	end
	local itemGrade = GetItemGrade(objItem);
	if itemGrade == nil then
		itemGrade = 0;
	end
	return ReinforceValue, NotAppraisal, itemGrade;
end

local function AddInfoToSlot(objSlot, ReinforceValue, NeedAppraisal, itemGrade, AvoidShopHelper)
	local TextBOffset = -1
	local IconBOffset = 1

	DESTROY_CHILD_BYNAME(objSlot, addonName);
	if ReinforceValue > 0 then
		-- 強化済み品は数値を表記する
		local txtReinforce = tolua.cast(objSlot:CreateOrGetControl("richtext", addonName .. "_ReinforceValue", 0, 0, 30, 16), "ui::CRichText");
		if AvoidShopHelper then
			-- ShopHelperが有効な時は、耐久ゲージ等がある場合があるので右上に表示する
			txtReinforce:SetGravity(ui.RIGHT, ui.TOP);
			txtReinforce:SetMargin(0, 2, 2, 0);
		else
			txtReinforce:SetGravity(ui.RIGHT, ui.BOTTOM);
			txtReinforce:SetMargin(0, 0, 1, TextBOffset);
		end
		txtReinforce:EnableHitTest(0);
		txtReinforce:SetText(string.format("{#EEEEEE}{s16}{ol}{b}{ds}+%d{/}{/}{/}{/}{/}", ReinforceValue));
	end

	if NeedAppraisal then
		-- 未鑑定品は虫眼鏡マークを右下につける
		-- かつ、アイテムの表示色を暗くする
		local size = 24;
		local picNotAppraisal = tolua.cast(objSlot:CreateOrGetControl("picture", addonName .. "_NotAppraisal", 0, 0, size, size), "ui::CPicture");
		picNotAppraisal:SetGravity(ui.RIGHT, ui.BOTTOM);
		picNotAppraisal:SetMargin(0, 0, 3, IconBOffset);
		picNotAppraisal:EnableHitTest(0);
		picNotAppraisal:SetEnableStretch(1);
		picNotAppraisal:SetImage("minimap_Appraisers");
		picNotAppraisal:ShowWindow(1);
		local objIcon = objSlot:GetIcon()
		if objIcon ~= nil then
			objIcon:SetColorTone("FF111111");
		end
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
		-- 等級リボンをつける
		local size = 16;
		local picRank = tolua.cast(objSlot:CreateOrGetControl("picture", addonName .. "_Rank", 0, 0, size, size), "ui::CPicture");
		picRank:SetGravity(ui.LEFT, ui.TOP);
		picRank:SetMargin(0, 0, 0, 0);
		picRank:EnableHitTest(0);
		picRank:SetEnableStretch(1);
		picRank:SetImage("equipmarker_mini_" .. rankName);
		picRank:ShowWindow(1);
	end
end

local function UpdateEquipSlot()
	local objParentFrame = ui.GetFrame("inventory");
	local equipItemList = session.GetEquipItemList()
	for i = 0, equipItemList:Count() - 1 do
		local equipItem = equipItemList:Element(i);
		
		local spotName = item.GetEquipSpotName(equipItem.equipSpot);
		if spotName ~= nil then
			if SET_EQUIP_ICON_FORGERY(objParentFrame, spotName) == false then
				if spotName == "HELMET" then
					if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) then
						spotName = "HAIR";
					end
				end
				local objSlot = tolua.cast(objParentFrame:GetChild(spotName), 'ui::CSlot');
				if objSlot ~= nil then
					local objIcon = objSlot:GetIcon()
					DESTROY_CHILD_BYNAME(objSlot, addonName);
					if objIcon ~= nil then
						-- アイテムあり
						local iconInfo = objIcon:GetInfo();
						local objItem = GetIES(GET_ITEM_BY_GUID(iconInfo:GetIESID()):GetObject());
						local ReinforceValue, NeedAppraisal, itemGrade = GetItemStatus(objItem);
						AddInfoToSlot(objSlot, ReinforceValue, NeedAppraisal, itemGrade);
					end
				end
			end
		end
	end
end

local function UpdateInvSlot(slotName)
	local objParentFrame = ui.GetFrame("inventory");
	local objSlotSet = GET_CHILD_RECURSIVELY(objParentFrame, slotName, 'ui::CSlotSet')
	if objSlotSet ~= nil then
		-- スロットの中身を調べる
		local slotCount = objSlotSet:GetSlotCount();
		for i = 0, slotCount - 1 do
			local objSlot = objSlotSet:GetSlotByIndex(i);
			local objIcon = objSlot:GetIcon()
			DESTROY_CHILD_BYNAME(objSlot, addonName);
			if objIcon ~= nil then
				-- アイテムあり
				local iconInfo = objIcon:GetInfo();
				local objItem = GetIES(GET_ITEM_BY_GUID(iconInfo:GetIESID()):GetObject());
				local ReinforceValue, NeedAppraisal, itemGrade = GetItemStatus(objItem);
				AddInfoToSlot(objSlot, ReinforceValue, NeedAppraisal, itemGrade);
			end
		end
	end
-- body
end

function Me.UpdateInv()
	UpdateEquipSlot();
	UpdateInvSlot("sset_Weapon");
	UpdateInvSlot("sset_SubWeapon");
	UpdateInvSlot("sset_Armor");
	UpdateInvSlot("sset_Outer");
	UpdateInvSlot("sset_Accessory");
end

function Me.UpdateWHouse(frameName)
	local objParentFrame = ui.GetFrame(frameName);
	if objParentFrame:IsVisible() == 0 then
		return;
	end
	local objSlotSet = GET_CHILD_RECURSIVELY(objParentFrame, "slotset", 'ui::CSlotSet')
	if objSlotSet ~= nil then
		-- スロットの中身を調べる
		local slotCount = objSlotSet:GetSlotCount();
		for i = 0, slotCount - 1 do
			local objSlot = objSlotSet:GetSlotByIndex(i);
			local objIcon = objSlot:GetIcon()
			DESTROY_CHILD_BYNAME(objSlot, addonName);
			if objIcon ~= nil then
				-- アイテムあり
				local iconInfo = objIcon:GetInfo();
				local objItem = GetObjectByGuid(iconInfo:GetIESID());

				if objItem.ItemType == "Equip" then
					-- 装備アイテムの場合
					local ReinforceValue, NeedAppraisal, itemGrade = GetItemStatus(objItem);
					AddInfoToSlot(objSlot, ReinforceValue, NeedAppraisal, itemGrade);
					--数量は1のはずなので数量のテキストを消す
					objSlot:SetText("")
				else
					-- その他の場合
				end
			end
		end
	end
end

function Me.UpdateRepairList(frameName)
	local objParentFrame = ui.GetFrame(frameName);
	if objParentFrame == nil or objParentFrame:IsVisible() == 0 then return end
	-- ShopHelper検出
	local ExistsShopHelper = _G["ADDONS"]["TOUKIBI"]["ShopHelper"] ~= nil
	-- スロットの中身を調べる
	local objSlotSet = GET_CHILD_RECURSIVELY(objParentFrame, "slotlist", "ui::CSlotSet")	
	local slotCount = objSlotSet:GetSlotCount();
	for i = 0, slotCount - 1 do
		local objSlot = objSlotSet:GetSlotByIndex(i);
		local objIcon = objSlot:GetIcon();
		DESTROY_CHILD_BYNAME(objSlot, addonName);
		if objIcon ~= nil then
			-- アイテムあり
			local iconInfo = objIcon:GetInfo();
			local objItem = GetIES(GET_ITEM_BY_GUID(iconInfo:GetIESID()):GetObject());
			local ReinforceValue, NeedAppraisal, itemGrade = GetItemStatus(objItem);
			AddInfoToSlot(objSlot, ReinforceValue, NeedAppraisal, itemGrade, ExistsShopHelper);
		end
	end
end

function Me.UpdateAppraisalList(frameName)
	local objParentFrame = ui.GetFrame(frameName);
	if objParentFrame == nil or objParentFrame:IsVisible() == 0 then return end
	-- ShopHelper検出
	local ExistsShopHelper = _G["ADDONS"]["TOUKIBI"]["ShopHelper"] ~= nil
	-- スロットの中身を調べる
	local objSlotSet = GET_CHILD_RECURSIVELY(objParentFrame, "slotlist", "ui::CSlotSet")	
	local slotCount = objSlotSet:GetSlotCount();
	for i = 0, slotCount - 1 do
		local objSlot = objSlotSet:GetSlotByIndex(i);
		local objIcon = objSlot:GetIcon();
		DESTROY_CHILD_BYNAME(objSlot, addonName);
		if objIcon ~= nil then
			-- アイテムあり
			local iconInfo = objIcon:GetInfo();
			local objItem = GetIES(GET_ITEM_BY_GUID(iconInfo:GetIESID()):GetObject());
			local ReinforceValue = TryGetProp(objItem, "Reinforce_2");
			local useLv = TryGetProp(objItem, "UseLv");

			local itemGrade = GetItemGrade(objItem);
			if itemGrade == nil then
				itemGrade = 0;
			end
			AddInfoToSlot(objSlot, ReinforceValue, false, itemGrade);
			-- 装備レベルを書いておく (鬱陶しいので要望が来るまでは封印)
			-- objSlot:SetText(Toukibi:GetStyledText(useLv, {"#EEEEEE", "s14", "ol", "ds"}), "count", "right", "top", -2, 1);
		end
	end
end

function Me.UpdateDecomposeList()
	local objParentFrame = ui.GetFrame("itemdecompose");
	if objParentFrame == nil or objParentFrame:IsVisible() == 0 then return end
	-- スロットの中身を調べる
	local objSlotSet = GET_CHILD_RECURSIVELY(objParentFrame, "itemSlotset", "ui::CSlotSet")	
	local slotCount = objSlotSet:GetSlotCount();
	for i = 0, slotCount - 1 do
		local objSlot = objSlotSet:GetSlotByIndex(i);
		local objIcon = objSlot:GetIcon();
		DESTROY_CHILD_BYNAME(objSlot, addonName);
		if objIcon ~= nil then
			local iconInfo = objIcon:GetInfo();
			local objItem = GetObjectByGuid(iconInfo:GetIESID());
			local ReinforceValue, NeedAppraisal, itemGrade = GetItemStatus(objItem);
			AddInfoToSlot(objSlot, ReinforceValue, NeedAppraisal, itemGrade);
		end
	end
end


function TOUKIBI_EQUIPMARKER_INV_UPDATE()
	Me.UpdateInv();
end

function TOUKIBI_EQUIPMARKER_WHOUSE_UPDATE()
	Me.UpdateWHouse("warehouse");
end

function TOUKIBI_EQUIPMARKER_AWHOUSE_UPDATE()
	Me.UpdateWHouse("accountwarehouse");
end

function TOUKIBI_EQUIPMARKER_NPCREPAIR_UPDATE()
	Me.UpdateRepairList("repair140731");
end

function TOUKIBI_EQUIPMARKER_NPCREPAIR_UPDATE_CALLER()
	ReserveScript("TOUKIBI_EQUIPMARKER_NPCREPAIR_UPDATE()", 0.5);
end

function TOUKIBI_EQUIPMARKER_APPRAISAL_UPDATE()
	Me.UpdateAppraisalList("appraisal_pc");
end

function TOUKIBI_EQUIPMARKER_APPRAISAL_UPDATE_CALLER()
	ReserveScript("TOUKIBI_EQUIPMARKER_APPRAISAL_UPDATE()", 0.5);
end

function TOUKIBI_EQUIPMARKER_NPCAPPRAISAL_UPDATE()
	Me.UpdateAppraisalList("appraisal");
end

function TOUKIBI_EQUIPMARKER_NPCAPPRAISAL_UPDATE_CALLER()
	ReserveScript("TOUKIBI_EQUIPMARKER_NPCAPPRAISAL_UPDATE()", 0.5);
end


-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- インベントリーを開くイベント
function Me.INVENTORY_OPEN_HOOKED(frame)
	Me.HoockedOrigProc["INVENTORY_OPEN"](frame);
	Me.UpdateInv();
end

-- 修理/ジェムロースティング店を開くイベント
function Me.OPEN_ITEMBUFF_UI_HOOKED(groupName, sellType, handle) 
	Me.HoockedOrigProc["OPEN_ITEMBUFF_UI"](groupName, sellType, handle);
	local groupInfo = session.autoSeller.GetByIndex(groupName, 0);
	if groupInfo == nil then return end
	local sklName = GetClassByType("Skill", groupInfo.classID).ClassName;
	-- log(sklName .. ", " .. tostring(sellType) .. " : " .. tostring(handle))
	if "Squire_Repair" == sklName then
		Me.UpdateRepairList("itembuffrepair")
	elseif "Alchemist_Roasting" == sklName then

	elseif sklName == 'Appraiser_Apprise' then
		Me.UpdateAppraisalList("appraisal_pc")
	end
end 

-- アイテム分解を開くイベント
function Me.ITEM_DECOMPOSE_ITEM_LIST_HOOKED(frame, itemGradeList)
	Me.HoockedOrigProc["ITEM_DECOMPOSE_ITEM_LIST"](frame, itemGradeList);
	-- Don't Decompose Meを検出する
	local ExistsDontDecomposeMe = _G["ADDONS"]["TOUKIBI"]["DontDecomposeMe"] ~= nil
	if ExistsDontDecomposeMe then
		-- Don't Decompose Meがある場合はそっちに任せる
		-- よって何もしない
	else
		-- ない場合はスロットに情報を付加する
		Me.UpdateDecomposeList();
	end
end

Me.HoockedOrigProc = Me.HoockedOrigProc or {};
function EQUIPMARKER_ON_INIT(addon, frame)
	if not Me.Loaded then
		Me.Loaded = true;
	end

	-- イベントを登録する
	addon:RegisterMsg('EQUIP_ITEM_LIST_GET', 'TOUKIBI_EQUIPMARKER_INV_UPDATE');

	addon:RegisterMsg('INV_ITEM_ADD', 'TOUKIBI_EQUIPMARKER_INV_UPDATE');
	addon:RegisterMsg('INV_ITEM_REMOVE', 'TOUKIBI_EQUIPMARKER_INV_UPDATE');

	addon:RegisterMsg("WAREHOUSE_ITEM_LIST", "TOUKIBI_EQUIPMARKER_WHOUSE_UPDATE");
	addon:RegisterMsg("WAREHOUSE_ITEM_ADD", "TOUKIBI_EQUIPMARKER_WHOUSE_UPDATE");
	addon:RegisterMsg("WAREHOUSE_ITEM_REMOVE", "TOUKIBI_EQUIPMARKER_WHOUSE_UPDATE");
	addon:RegisterMsg("WAREHOUSE_ITEM_CHANGE_COUNT", "TOUKIBI_EQUIPMARKER_WHOUSE_UPDATE");
	addon:RegisterMsg("WAREHOUSE_ITEM_IN", "TOUKIBI_EQUIPMARKER_WHOUSE_UPDATE");

	addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_LIST", "TOUKIBI_EQUIPMARKER_AWHOUSE_UPDATE");
	addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_ADD", "TOUKIBI_EQUIPMARKER_AWHOUSE_UPDATE");
	addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_REMOVE", "TOUKIBI_EQUIPMARKER_AWHOUSE_UPDATE");
	addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT", "TOUKIBI_EQUIPMARKER_AWHOUSE_UPDATE");
	addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_IN", "TOUKIBI_EQUIPMARKER_AWHOUSE_UPDATE");

	addon:RegisterMsg('OPEN_DLG_REPAIR', 'TOUKIBI_EQUIPMARKER_NPCREPAIR_UPDATE');
	addon:RegisterMsg('UPDATE_DLG_REPAIR', 'TOUKIBI_EQUIPMARKER_NPCREPAIR_UPDATE');
	addon:RegisterMsg('UPDATE_ITEM_REPAIR', 'TOUKIBI_EQUIPMARKER_NPCREPAIR_UPDATE');

	addon:RegisterMsg("OPEN_DLG_APPRAISAL", "TOUKIBI_EQUIPMARKER_NPCAPPRAISAL_UPDATE_CALLER");
	addon:RegisterMsg("SUCCESS_APPRALSAL", "TOUKIBI_EQUIPMARKER_NPCAPPRAISAL_UPDATE_CALLER");

	addon:RegisterMsg("SUCCESS_APPRALSAL_PC", "TOUKIBI_EQUIPMARKER_APPRAISAL_UPDATE_CALLER");

	Toukibi:SetHook("INVENTORY_OPEN", Me.INVENTORY_OPEN_HOOKED);
	Toukibi:SetHook("OPEN_ITEMBUFF_UI", Me.OPEN_ITEMBUFF_UI_HOOKED);
	Toukibi:SetHook("ITEM_DECOMPOSE_ITEM_LIST", Me.ITEM_DECOMPOSE_ITEM_LIST_HOOKED);
end

