local addonName = "CollectionSorter";
local verText = "1.00";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
--[アドオン名] = Me;
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

-- ***** 変数の宣言と設定 *****
Me.Country = nil;

local collectionView = {
    isUnknown  = 0,			-- 미확인
	isIncomplete = 1,		-- 미완성
	isComplete = 2,			-- 완성
};

local collectionStatus = {
    isNormal = 0,			-- 기본
	isNew  = 1,				-- 새로등록됨
	isComplete = 2,			-- 완성
	isAddAble = 3			-- 수집가능
};

-- ===== アドオンの内容ここから =====
local function gsubCollectionTitle(text)
	local strTemp = text;
	if Me.Country == "Japanese" then
		strTemp = string.gsub(strTemp, "コレクション:", "");
		strTemp = string.gsub(strTemp, "コレクション：", "");
	elseif Me.Country == "Korean" then
		strTemp = string.gsub(strTemp, "Collection: ", "");
	else
		strTemp = string.gsub(strTemp, "Collection: ", "");
	end
	return strTemp;
end

function TOUKIBI_COLLECTIONSORTER_GET_COLLECTION_INFO_HOOKED(collectionClass, collection, etcObject, collectionCompleteMagicList)
	-- view 
	local curCount, maxCount = GET_COLLECTION_COUNT(collectionClass.ClassID, collection);
	local collView = collectionView.isIncomplete;
	if collection == nil then
		collView = collectionView.isUnknown;
	elseif curCount >= maxCount then 
		collView = collectionView.isComplete;
	end

	-- status
	local cls = GetClassByType("Collection", collectionClass.ClassID);	
	local isread = TryGetProp(etcObject, 'CollectionRead_' .. cls.ClassID);
	local addNumCnt= GET_COLLECT_ABLE_ITEM_COUNT(collection,collectionClass.ClassID);
	local collStatus = collectionStatus.isNormal;

	if curCount >= maxCount then	-- 컴플리트
		collStatus = collectionStatus.isComplete;
		-- complete 상태면 magicList에 추가해줌.
		ADD_MAGIC_LIST(collectionClass.ClassID, collection, collectionCompleteMagicList );
	elseif isread == nil or isread == 0 then	-- 읽지 않음(new) etcObj의 항목에 1이 들어있으면 읽었다는 뜻.		
		if collection ~= nil then -- 미확인 상태가 아닐때만 new를 입력
			collStatus = collectionStatus.isNew;
		end
	end

	-- 위에 new/complete를 체크했는데 기본값이며 추가가능한지 확인. 이렇게 안하면 미확인에서 정렬 제대로 안됨.
	if collStatus == collectionStatus.isNormal then
		-- cnt가 0보다 크면 num아이콘활성화
		if addNumCnt > 0 then
			collStatus = collectionStatus.isAddAble;
		end
	end

	
	-- name
	local collectionName = dictionary.ReplaceDicIDInCompStr(cls.Name);
	collectionName = string.gsub(collectionName, ClMsg("CollectionReplace"), ""); -- "콜렉션:" 을 공백으로 치환한다.
	collectionName = gsubCollectionTitle(collectionName);
	
	return { 
			 name = collectionName,		-- "콜렉션:" 이 제거된 이름
			 status = collStatus,		-- 콜렉션 상태
			 view = collView,			-- 콜랙션 보여주기 상태
			 addNum = addNumCnt			-- 추가 가능한 아이템 개수.
			};
end

Me.HoockedOrigProc = Me.HoockedOrigProc or {};
function COLLECTIONSORTER_ON_INIT(addon, frame)
	Me.Country = option.GetCurrentCountry();
	-- イベントを登録する
	Toukibi:SetHook("GET_COLLECTION_INFO", TOUKIBI_COLLECTIONSORTER_GET_COLLECTION_INFO_HOOKED);

end

