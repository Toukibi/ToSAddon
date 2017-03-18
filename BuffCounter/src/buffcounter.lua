local addonName = "BuffCounter";
local verText = "1.0.0";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/buffcounter", "/BuffCounter", "/buffc"} -- {"/コマンド1", "/コマンド2", .......};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
BuffCounter = Me;
local DebugMode = false;

local floor = math.floor;
local fmod = math.fmod;

CHAT_SYSTEM("{#333333}[Add-ons]" .. addonName .. verText .. " loaded!{/}");
--CHAT_SYSTEM("{#333333}[Buff Counter]コマンド /buffc で表示のON/OFFが切り替えられます{/}");

-- ***** 変数の宣言と設定 *****
Me.SettingFilePathName = string.format("../addons/%s/%s", addonNameLower, SettingFileName);
Me.HoockedOrigProc = Me.HoockedOrigProc or {};
Me.Loaded = false;

Me.BuffPrintInfo = {
--	 [100] = {arg = "arg1", fmt = "%s"}, --サクラメント
--	 [146] = {arg = "arg1", fmt = "%s"}, --アスパ
	 [147] = {arg = "arg2", fmt = "+%s"}, --ブレス
	[3016] = {arg = "arg1", fmt = "%s"}, --ダイノ
	 [114] = {arg = "arg1", fmt = "%s"}, --リバイブ
	 [144] = {arg = "arg1", fmt = "%s"}, --ディバインマイト
	 [138] = {arg = "arg1", fmt = "%s"}, --スウィストステップ
	  [67] = {arg = "arg1", fmt = "%s"}, --リフレクトシールド
	 [156] = {arg = "arg1", fmt = "%s"}, --シュアスペル
	 [157] = {arg = "arg1", fmt = "%s"}, --クイックキャスト
	  [71] = {arg = "arg1", fmt = "%s"}, --ヘイスト
	 [165] = {arg = "arg1", fmt = "%s"}, --クイッケン
	 [184] = {arg = "arg1", fmt = "%s"}, --エンチャントファイア
	[1028] = {arg = "arg1", fmt = "%s"}, --インヴォケーション
	[2057] = {arg = "arg1", fmt = "%s"}, --エンチャントライトニング
	[1019] = {arg = "arg1", fmt = "%s"}, --カウンタースペル
	[4532] = {arg = "arg1", fmt = "%s"} --チームLv
};

-- ***** ログ表示関連 *****
local function CreateValueWithStyleCode(Value, Styles)
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

local function AddLog(Message, Mode, DisplayAddonName, OnlyDebugMode)
	if Me.Settings == nil then return end
	if Message == nil then return end
	if (not DebugMode) and Mode == "Info" then return end
	if (not DebugMode) and OnlyDebugMode then return end
	local HeaderText = "";
	if DisplayAddonName then
		HeaderText = string.format("[%s]", addonName);
	end
	local MsgText = HeaderText .. Message;
	if Mode == "Info" then
		MsgText = CreateValueWithStyleCode(MsgText, {"#333333"});
	elseif Mode == "Warning" then
		MsgText = CreateValueWithStyleCode(MsgText, {"#331111"});
	elseif Mode == "Caution" then
		MsgText = CreateValueWithStyleCode(MsgText, {"#666622"});
	elseif Mode == "Notice" then
		MsgText = CreateValueWithStyleCode(MsgText, {"#333366"});
	else
		-- 何もしない
	end
	CHAT_SYSTEM(MsgText);
end

-- ***** 設定読み書き関連 *****
-- 設定書き込み
local function SaveTable(FilePathName, objTable)
	if FilePathName == nil then
		AddLog("設定の保存ファイル名が指定されていません", "Warning", true, false);
	end
	local objFile, objError = io.open(FilePathName, "w")
	if objError then
		AddLog(string.format("設定の保存でエラーが発生しました:{nl}%s", tostring(objError)), "Warning", true, false);
	else
		local json = require('json');
		objFile:write(json.encode(objTable));
		objFile:close();
		AddLog("設定の保存が完了しました", "Info", true, true);
	end
end
local function SaveSetting()
	SaveTable(Me.SettingFilePathName, Me.Settings);
end

-- 既存の値がない場合にデフォルト値をマージする
local function GetValueOrDefault(Value, DefaultValue, Force)
	Force = Force or false;
	if Force or Value == nil then
		return DefaultValue;
	else
		return Value;
	end
end

-- デフォルト設定(ForceがTrueでない場合は、既存の値はそのまま引き継ぐ)
local function MargeDefaultSetting(Force, DoSave)
	DoSave = GetValueOrDefault(DoSave, true);
	Me.Settings = Me.Settings or {};
	Me.Settings.PosX = GetValueOrDefault(Me.Settings.PosX, nil, Force);
	Me.Settings.PosY = GetValueOrDefault(Me.Settings.PosY, nil, Force);
	Me.Settings.Movable = GetValueOrDefault(Me.Settings.Movable, false, Force);
	Me.Settings.Visible = GetValueOrDefault(Me.Settings.Visible, true, Force);
	Me.Settings.DisplayGauge = GetValueOrDefault(Me.Settings.DisplayGauge, true, Force);
	Me.Settings.GaugeStyle = GetValueOrDefault(Me.Settings.GaugeStyle, "block", Force); --block/continuous
	Me.Settings.DisplayMode = GetValueOrDefault(Me.Settings.DisplayMode, "left", Force); --use/left/ultramini
	Me.Settings.SkinName = GetValueOrDefault(Me.Settings.SkinName, "systemmenu_vertical", Force); --None/chat_window/systemmenu_vertical
	if Force then
		AddLog("デフォルトの設定の読み込みが完了しました。", "Info", true, false);
	end
	if DoSave then SaveSetting() end
end

-- 設定読み込み
local function LoadSetting()
	local acutil = require("acutil");
	local objReadValue, objError = acutil.loadJSON(Me.SettingFilePathName);
	if objError then
		AddLog(string.format("設定の読み込みでエラーが発生したのでデフォルトの設定を使用します。{nl}{#331111}%s{/}", tostring(objError)), "Caution", true, false);
		MargeDefaultSetting(true, false);
	else
		Me.Settings = objReadValue;
		MargeDefaultSetting(false, false);
	end
	AddLog("設定の読み込みが完了しました", "Info", true, false);
end

-- ===== アドオンの内容ここから =====

local function GetTimeEx(Sec)
	local timeTxt = "";
	local d, h, m, s = GET_DHMS(math.floor(Sec));
	local ret = "";
	local started = 0;
	if d > 0 then
		timeTxt = ScpArgMsg("{Day}", "Day", d);
	elseif h > 1 then
		timeTxt = ScpArgMsg("{Hour}", "Hour", h);
	elseif m > 0 then
		timeTxt = ScpArgMsg("{Min}", "Min", m + h * 60);
	else
		timeTxt = ScpArgMsg("{Sec}", "Sec", s + m * 60);
	end
	return "{#FFFF00}{ol}{s12}" .. timeTxt .. "{/}{/}{/}";
end

local function WriteBuffParam()

	for RowNo = 0 , 1 do -- 0:上段バフ /1:下段バフ /2:デバフ
		if s_buff_ui["slotcount"][RowNo] ~= nil and s_buff_ui["slotcount"][RowNo] >= 0 then

			for ColNo = 0,  s_buff_ui["slotcount"][RowNo] - 1 do
				local CurrentSlot = s_buff_ui["slotlist"][RowNo][ColNo];
				local CurrentTimeText = s_buff_ui["captionlist"][RowNo][ColNo];
				if CurrentSlot:IsVisible() == 1 then
					local BuffIcon = CurrentSlot:GetIcon();
					--local IconInfo = BuffIcon:GetInfo();
					local buffIndex = BuffIcon:GetUserIValue("BuffIndex");
					local buff = info.GetBuff(session.GetMyHandle(), BuffIcon:GetInfo().type, buffIndex);
					local DrawInfo = Me.BuffPrintInfo[buff.buffID];
					-- DESTROY_CHILD_BYNAME(CurrentSlot, "TOUKIBI");
					if DrawInfo ~= nil then
						local pnlBack = tolua.cast(CurrentSlot:CreateOrGetControl("groupbox", "TOUKIBI_pnlBack", 0, 0, 8, 8), "ui::CGroupBox");
						pnlBack:SetSkinName("systemmenu_vertical");
						pnlBack:SetGravity(ui.RIGHT, ui.BOTTOM);
						pnlBack:SetMargin(0, 0, 0, 0);
						pnlBack:EnableHitTest(0);
						local lblParam = tolua.cast(pnlBack:CreateOrGetControl("richtext", "TOUKIBI_lblParam", 0, 0, 8, 8), "ui::CRichText");
						lblParam:SetTextAlign("right", "bottom"); 
						lblParam:SetGravity(ui.RIGHT, ui.BOTTOM);
						lblParam:SetMargin(0, 0, 0, 0);
						lblParam:EnableHitTest(0);
						--色見本 #06FAE9 結構いい感じ、だけどちょっと暗い
						--色見本 #6AFCF2 結構いい感じ、だけどちょっと薄い

						lblParam:SetText(string.format("{#38FBEE}{ol}{s11}" .. DrawInfo.fmt .. "{/}{/}{/}",buff[DrawInfo.arg]));
						lblParam:ShowWindow(1);
						pnlBack:Resize(lblParam:GetWidth() + 1, lblParam:GetHeight());
						pnlBack:ShowWindow(1);
						-- CHAT_SYSTEM(string.format("{#AAAAAA}{ol}{s11}" .. DrawInfo.fmt .. "{/}{/}{/}",buff[DrawInfo.arg]))
					else
						local pnlBack = GET_CHILD(CurrentSlot, "TOUKIBI_pnlBack", "ui::CGroupBox");
						if pnlBack ~= nil then
							pnlBack:ShowWindow(0);
						end
						local lblParam = GET_CHILD(pnlBack, "TOUKIBI_lblParam", "ui::CRichText");
						if lblParam ~= nil then
							lblParam:ShowWindow(0);
						end
					end
				end
			end
		end
	end
end

function Me.UpdateBuffTimeText(handle, buff_ui)
	local updated = 0;
	-- CHAT_SYSTEM("てすと")
	for RowNo = 0 , buff_ui["buff_group_cnt"] do -- 0:上段バフ /1:下段バフ /2:デバフ
		if buff_ui["slotcount"][RowNo] ~= nil and buff_ui["slotcount"][RowNo] >= 0 then
    		for ColNo = 0,  buff_ui["slotcount"][RowNo] - 1 do
    			local CurrentSlot = buff_ui["slotlist"][RowNo][ColNo];
    			local CurrentTimeText = buff_ui["captionlist"][RowNo][ColNo];
    			if CurrentSlot:IsVisible() == 1 then
    				local icon = CurrentSlot:GetIcon();
    				local iconInfo = icon:GetInfo();
					local buffIndex = icon:GetUserIValue("BuffIndex");
    				local buff = info.GetBuff(handle, iconInfo.type, buffIndex);
    				if buff ~= nil then

						-- ***** 変更箇所始まり
						if buff.buffID == 70002 then
							-- トークンの残り時間
							CurrentTimeText:SetText(Me.TokenRemainTimeText);
						else
							-- その他のバフ
							SET_BUFF_TIME_TO_TEXT(CurrentTimeText, buff.time);
						end
						-- ***** 変更箇所終わり

    					updated = 1;
    					if buff.time < 5000 and buff.time ~= 0.0 then
    						if CurrentSlot:IsBlinking() == 0 then
    							CurrentSlot:SetBlink(600000, 1.0, "55FFFFFF", 1);
    						end
    					else
    						if CurrentSlot:IsBlinking() == 1 then
    							CurrentSlot:ReleaseBlink();
    						end
    					end
    				end
    			end
    		end
		end
	end
	if updated == 1 then
		ui.UpdateVisibleToolTips("buff");
	end
end

function TOUKIBI_BUFFCOUNTER_UPDATE_TOKEN_TIME()
	local elapsedSec = imcTime.GetAppTime() - Me.TokenGetTime;
	Me.TokenRemainSec = Me.TokenRemainBaseSec - (imcTime.GetAppTime() - Me.TokenGetTime);
	if 0 > Me.TokenRemainSec then
		return 0;
	end
	Me.TokenRemainTimeText = GetTimeEx(Me.TokenRemainSec);
	return 1;
end

function Me.GetBuffInfo(RowNo, ColNo)
	if s_buff_ui["slotcount"][RowNo] ~= nil and s_buff_ui["slotcount"][RowNo] >= 0 then
		local CurrentSlot = s_buff_ui["slotlist"][RowNo][ColNo];
		local CurrentTimeText = s_buff_ui["captionlist"][RowNo][ColNo];
		if CurrentSlot:IsVisible() == 1 then
			local BuffIcon = CurrentSlot:GetIcon();
			--local IconInfo = BuffIcon:GetInfo();
			local buffIndex = BuffIcon:GetUserIValue("BuffIndex");
			return info.GetBuff(session.GetMyHandle(), BuffIcon:GetInfo().type, buffIndex);
		end
	end
end
--???GetBuffInfo(0,0)

function Me.DrawParam()
	WriteBuffParam()
end

local function GetMyBuffCount()
	local ReturnValue = {};

	ReturnValue.handle = session.GetMyHandle();
	local BuffCount = info.GetBuffCount(ReturnValue.handle);
	local BaseCount = 5;
	local CtrlType = GetClassString('Job', info.GetJob(ReturnValue.handle), 'CtrlType')
	if 'Warrior' == CtrlType or 'Cleric' == CtrlType then
		BaseCount = 7;
	end
	local Additional = 0;
	ReturnValue.DainoLv = 0;
	ReturnValue.CurrentCount = 0;
	for i = 0, BuffCount - 1 do
		local buff = info.GetBuffIndexed(ReturnValue.handle, i);
		local buffCls = GetClassByType("Buff", buff.buffID);
		if buffCls.ApplyLimitCountBuff == "YES" then
			ReturnValue.CurrentCount = ReturnValue.CurrentCount + 1;
		end
		if buff.buffID == 70002 then
			-- トークン
			Additional = Additional + 1;
		elseif buff.buffID == 3016 then
			-- ダイノ
			ReturnValue.DainoLv = buff.arg1;
		elseif buff.buffID == 147 then
			-- ブレッシング
--			AddLog(string.format("%s(Lv.%s):%s", buffCls.Name, buff.arg1, buff.arg2), "Info", false, false);
		end
-- CHAT_SYSTEM(string.format("[%s]%s : %s, %s, %s", buff.buffID, buffCls.Name, buff.arg1, buff.arg2, buff.arg3, buff.arg4, buff.arg5))
	end
	-- バフ+1のアビリティの有無を調べる
	if GetAbility(GetMyPCObject(), "AddBuffCount") ~= nil then
		Additional = Additional + 1;
	end
	ReturnValue.LimitCount = BaseCount + Additional;
	ReturnValue.LeftCount = ReturnValue.LimitCount - ReturnValue.CurrentCount;
	if ReturnValue.DainoLv > 0 then
		ReturnValue.LeftCount = ReturnValue.LeftCount + ReturnValue.DainoLv + 1
	end
	return ReturnValue;
end

function GetPTMBuffCount(handle)
	handle = handle or session.GetMyHandle();
	local ReturnValue = {};

	ReturnValue.Succeed = false;
	ReturnValue.handle = handle
	ReturnValue.BuffCount = info.GetBuffCount(ReturnValue.handle);
	ReturnValue.MaxBuffCountBase = 5;
	local CtrlType = GetClassString('Job', info.GetJob(ReturnValue.handle), 'CtrlType')
	if 'Warrior' == CtrlType or 'Cleric' == CtrlType then
		ReturnValue.MaxBuffCountBase = 7;
	end
	ReturnValue.MaxBuffAdditional = 0;
	ReturnValue.UpperBuffCount = 0;
	ReturnValue.TokenAvailable = false;
	ReturnValue.DainoLv = 0;
	for i = 0, ReturnValue.BuffCount - 1 do
		local buff = info.GetBuffIndexed(ReturnValue.handle, i);
		local buffCls = GetClassByType("Buff", buff.buffID);
		if buffCls.ApplyLimitCountBuff == "YES" then
			ReturnValue.UpperBuffCount = ReturnValue.UpperBuffCount + 1;
		end
		if buff.buffID == 70002 then
			ReturnValue.TokenAvailable = true;
			ReturnValue.MaxBuffAdditional = ReturnValue.MaxBuffAdditional + 1;
		elseif buff.buffID == 3016 then
			-- ダイノ
			ReturnValue.DainoLv = buff.arg1;
		end
--CHAT_SYSTEM(string.format("[%s]%s : %s, %s, %s", buff.buffID, buffCls.Name, buff.arg1, buff.arg2, buff.arg3, buff.arg4, buff.arg5))
	end
	-- JOBランクを取得する
	local cid = info.GetCID(ReturnValue.handle);
--CHAT_SYSTEM("CID : " .. cid)
	if cid ~= nil and cid ~= "0" then
		local OtherPCInfo = session.otherPC.GetByStrCID(cid);
		if OtherPCInfo ~= nil then
			local objJobHistory = OtherPCInfo.jobHistory;
			ReturnValue.Rank = objJobHistory:GetJobHistoryCount();
			if objJobHistory:GetJobHistoryCount() >= 5 then
				ReturnValue.MaxBuffAdditional = ReturnValue.MaxBuffAdditional + 1
			end
			ReturnValue.Succeed = true;
		else
			ReturnValue.Rank = nil;
			--CHAT_SYSTEM("キャラ情報の取得に失敗")
		end
	end
	ReturnValue.UpperBuffLimit = ReturnValue.MaxBuffCountBase + ReturnValue.MaxBuffAdditional;
	ReturnValue.LeftCount = ReturnValue.UpperBuffLimit - ReturnValue.UpperBuffCount;
	if ReturnValue.DainoLv > 0 then
		ReturnValue.LeftCount = ReturnValue.LeftCount + ReturnValue.DainoLv + 1
	end
	-- CHAT_SYSTEM(string.format("%s/%s", ReturnValue.UpperBuffCount, ReturnValue.MaxBuffCountBase + ReturnValue.MaxBuffAdditional))
	return ReturnValue;
end

-- ???BuffCounter.GetPartyBuffCount()
function Me.GetPartyBuffCount()
	local ReturnValue = {};
	ReturnValue.Self = {};
	ReturnValue.PTM = nil;
	local MemberList = session.party.GetPartyMemberList(PARTY_NORMAL);
	local MemberCount = MemberList:Count();
	local myInfo = session.party.GetMyPartyObj(PARTY_NORMAL);
	ReturnValue.Self = GetMyBuffCount();
	if MemberCount >= 1 then
		-- 0:PTを組んでいない  1:自分しかいないPT
		for i = 0 , MemberCount - 1 do
			local pcInfo = MemberList:Element(i);
			-- CHAT_SYSTEM(string.format("Me:%s  PTM(%s):%s", myInfo:GetMapID(), i, pcInfo:GetMapID()))
			if myInfo ~= pcInfo and myInfo:GetMapID() == pcInfo:GetMapID() then
				if ReturnValue.PTM == nil then
					ReturnValue.PTM = {};
					ReturnValue.PTM.CurrentCount = 0;
					ReturnValue.PTM.DainoLv = 0;
					ReturnValue.PTM.LimitCount = 0;	
					ReturnValue.PTM.LeftCount = nil;
				end
				local tmpValue = GetPTMBuffCount(pcInfo:GetHandle());
				if ReturnValue.PTM.LeftCount == nil or ReturnValue.PTM.LeftCount > tmpValue.LeftCount then
					ReturnValue.PTM.CurrentCount = tmpValue.UpperBuffCount
					ReturnValue.PTM.LimitCount = tmpValue.UpperBuffLimit
					ReturnValue.PTM.DainoLv = tmpValue.DainoLv
					ReturnValue.PTM.LeftCount = tmpValue.LeftCount
				end
			end
		end
	end
--	CHAT_SYSTEM(string.format("自分:%s/%s   PTM:%s/%s", ReturnValue.Self.CurrentCount, ReturnValue.Self.LimitCount + ReturnValue.Self.DainoLv, ReturnValue.PTM.CurrentCount, ReturnValue.PTM.LimitCount + ReturnValue.PTM.DainoLv))
	return ReturnValue;
end

-- ゲージのスキンを選択する(30/50/70/残3/残1で色が変わる)
local function GetGaugeSkin(current, max)
	local GaugeColor = "blue";
	if current >= max - 1 then
		GaugeColor = "red";
	elseif current >= max - 3 then
		GaugeColor = "orange";
	elseif current * 10 >= max * 7 then
		GaugeColor = "orange";
	elseif current * 10 >= max * 5 then
		GaugeColor = "yellow";
	elseif current * 10 >= max * 3 then
		GaugeColor = "green";
	else
		GaugeColor = "blue";
	end
	return "toukibi_gauge_" .. GaugeColor;
end

-- メインフレームの描写更新
local function GetCountText(TitleText, Mode, BuffCountData)
	local ReturnText = "";
	local strNewLine = "{nl}";
	local Color = "#DDAA55"
	if BuffCountData ~= nil and BuffCountData.LeftCount <= 3 then
		Color = "#FF1111"
	end
	if Mode ~= "ultramini" then
		strNewLine = "";
	end
	if BuffCountData == nil then	
		ReturnText = string.format( "{#333333}{ol}{s11}%s:" .. strNewLine .. "--{/}{/}{/}", TitleText)
	elseif Mode == "left" or Mode == "ultramini" then
		ReturnText = string.format( "{#AAAAAA}{ol}{s11}%s:" .. strNewLine .. "{b}{/}{s14}{%s}%s{/}{/}{/}{/}{/}",
									TitleText, Color,
									BuffCountData.LeftCount)
	else
		local strDinoValue = "";
		if BuffCountData.DainoLv > 0 then
			strDinoValue = "+" .. BuffCountData.DainoLv + 1;
		end
		ReturnText = string.format( "{#AAAAAA}{ol}{s11}%s:{b}{s14}{%s}%s{/}{/}{/}/{s11}%s{#44AA44}%s{/}{/}{/}{/}{/}",
									TitleText, Color,
									BuffCountData.CurrentCount,
									BuffCountData.LimitCount,
									strDinoValue)
	end
	return ReturnText;
end

local function UpdateMainFrame()
	local BuffData = Me.GetPartyBuffCount();
	local TopFrame = Me.frame;
	local pnlBase = GET_CHILD(TopFrame, "pnlBase", "ui::CControlSet");
	if Me.Settings.SkinName ~= nil then
		pnlBase:SetSkinName(Me.Settings.SkinName);
	end

	local picIcon = GET_CHILD(pnlBase, "skillicon", "ui::CPicture");
	--picIcon:SetImage("jokeicon_helmet");

	local lblBuffSelf = GET_CHILD(pnlBase, "lblBuffSelf", "ui::CRichText");
	local lblBuffPTM = GET_CHILD(pnlBase, "lblBuffPTM", "ui::CRichText");
	local objGauge = GET_CHILD(pnlBase, "Gauge1", "ui::CGauge");
	local lblGauge = GET_CHILD(pnlBase, "lblGauge", "ui::CRichText");

	if Me.Settings.DisplayMode == "left" then
		lblBuffSelf:Resize(36, 20);
		lblBuffSelf:SetMargin(2, 7, 0, 0);
		lblBuffPTM:Resize(36, 20);
		lblBuffPTM:SetMargin(40, 7, 0, 0);
		objGauge:ShowWindow(1);
		objGauge:SetMargin(5, 2, 0, 0);
		pnlBase:Resize(80, 27);
		TopFrame:Resize(80, 27);
	elseif Me.Settings.DisplayMode == "ultramini" then
		lblBuffSelf:Resize(96, 20);
		lblBuffSelf:SetMargin(2, 2, 0, 0);
		lblBuffPTM:Resize(96, 20);
		lblBuffPTM:SetMargin(2, 34, 0, 0);
		objGauge:ShowWindow(0);
		objGauge:SetMargin(5, 2, 0, 0);
		pnlBase:Resize(24, 63);
		TopFrame:Resize(24, 63);
	else
		lblBuffSelf:Resize(96, 20);
		lblBuffSelf:SetMargin(2, 7, 0, 0);
		lblBuffPTM:Resize(96, 20);
		lblBuffPTM:SetMargin(2, 23, 0, 0);
		objGauge:ShowWindow(1);
		objGauge:SetMargin(5, 2, 0, 0);
		pnlBase:Resize(80, 43);
		TopFrame:Resize(80, 43);
	end
	lblBuffSelf:SetText(GetCountText("自", Me.Settings.DisplayMode, BuffData.Self));
	lblBuffPTM:SetText(GetCountText("PT", Me.Settings.DisplayMode, BuffData.PTM));
	-- ゲージを更新する
	local CurrentData = BuffData.Self;
	if BuffData.PTM ~= nil and BuffData.Self.LeftCount > BuffData.PTM.LeftCount then
		CurrentData = BuffData.PTM;
	end
	local intValue = CurrentData.CurrentCount;
	local intMaxValue = CurrentData.LimitCount;
	local AddByDaino = 0;
	if CurrentData.DainoLv > 0 then
		AddByDaino = CurrentData.DainoLv + 1;
		intMaxValue = intMaxValue + AddByDaino;
	end
	objGauge:SetSkinName(GetGaugeSkin(intValue, intMaxValue));
	if DebugMode then
		objGauge:SetPoint(0,100); -- Gaugeのスキン変更を反映させるには値が変わる(厳密にはグラフィック更新)必要があるみたい
	end
	objGauge:SetPoint(intValue, intMaxValue);
	
	if Me.Settings.DisplayMode == "ultramini" then
		objGauge:ShowWindow(0)
		lblGauge:ShowWindow(0);
	elseif Me.Settings.GaugeStyle == "continuous" then
		objGauge:ShowWindow(1)
		lblGauge:ShowWindow(0);
	else
		objGauge:ShowWindow(0)

		local GaugeText = "{ol}{s7}";
		local TotalCount = 0;
		local GaugeTextColor = "{#33FF33}"
		if intValue >= intMaxValue - 1 then
			GaugeColor = "{#FF1100}";
		elseif intValue >= intMaxValue - 3 then
			GaugeColor = "{#FF4400}";
		elseif intValue * 10 >= intMaxValue * 7 then
			GaugeColor = "{#FFEE00}";
		else
			GaugeColor = "{#33FF33}";
		end
		GaugeText = GaugeText .. GaugeColor
		for i = 1, intValue do
			GaugeText = GaugeText .. "●";
			TotalCount = TotalCount + 1;
			if fmod(TotalCount, 5) == 0 then
				GaugeText = GaugeText .. " ";
			end
		end
		GaugeText = GaugeText .. "{/}{#060606}"
		for i = TotalCount + 1, intMaxValue - AddByDaino do
			GaugeText = GaugeText .. "●";
			TotalCount = TotalCount + 1;
			if fmod(TotalCount, 5) == 0 then
				GaugeText = GaugeText .. " ";
			end
		end
		GaugeText = GaugeText .. "{/}{#060633}"
		for i =  TotalCount + 1, intMaxValue do
			GaugeText = GaugeText .. "●";
			TotalCount = TotalCount + 1;
			if fmod(TotalCount, 5) == 0 then
				GaugeText = GaugeText .. " ";
			end
		end
		GaugeText = GaugeText .. "{/}{/}{/}";

		lblGauge:SetText(GaugeText);
		lblGauge:ShowWindow(1);

		local NewWidth = 4 + lblGauge:GetWidth()
		if NewWidth > 80 then
			pnlBase:Resize(NewWidth, 43);
			TopFrame:Resize(NewWidth, 43);
		end
	end

	Me.frame:Invalidate()
end

-- ***** コンテキストメニュー周り *****
-- セパレータを挿入
local function MakeContextMenuSeparator(parent, width)
	width = width or 300;
	ui.AddContextMenuItem(parent, string.format("{img fullgray %s 1}", width), "None");
end

-- コンテキストメニュー項目を作成
local function MakeContextMenuItem(parent, text, eventscp, icon, checked)
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

-- コンテキストメニューを作成する
function TOUKIBI_BUFFCOUNTER_CONTEXT_MENU(frame, ctrl)
	local Title = "{#006666}===== Buff Counterの設定 ====={/}";
	local context = ui.CreateContextMenu("BUFFCOUNTER_MAIN_RBTN", Title, 0, 0, 180, 0);
	MakeContextMenuItem(context, "{#FFFF88}今すぐ更新する{/}", "TOUKIBI_BUFFCOUNTER_UPDATE()");
	MakeContextMenuSeparator(context, 240);
	MakeContextMenuItem(context, "位置を固定する", "TOUKIBI_BUFFCOUNTER_CHANGE_MOVABLE()", nil, not Me.Settings.Movable);
	MakeContextMenuItem(context, "位置をリセット", "TOUKIBI_BUFFCOUNTER_RESETPOS()");
	MakeContextMenuSeparator(context, 240.1);
	MakeContextMenuItem(context, "表示モード：バフ使用数", "TOUKIBI_BUFFCOUNTER_CHANGEPROP('DisplayMode', 'use')", nil, (Me.Settings.DisplayMode == "use"));
	MakeContextMenuItem(context, "表示モード：バフ残り枠", "TOUKIBI_BUFFCOUNTER_CHANGEPROP('DisplayMode', 'left')", nil, (Me.Settings.DisplayMode == "left"));
	MakeContextMenuItem(context, "表示モード：極小表示", "TOUKIBI_BUFFCOUNTER_CHANGEPROP('DisplayMode', 'ultramini')", nil, (Me.Settings.DisplayMode == "ultramini"));
	MakeContextMenuSeparator(context, 240.2);
	MakeContextMenuItem(context, "背景：濃い", "TOUKIBI_BUFFCOUNTER_CHANGEPROP('SkinName', 'systemmenu_vertical')", nil, (Me.Settings.SkinName == "systemmenu_vertical"));
	MakeContextMenuItem(context, "背景：薄い", "TOUKIBI_BUFFCOUNTER_CHANGEPROP('SkinName', 'chat_window')", nil, (Me.Settings.SkinName == "chat_window"));
	MakeContextMenuItem(context, "背景なし", "TOUKIBI_BUFFCOUNTER_CHANGEPROP('SkinName', 'None')", nil, (Me.Settings.SkinName == "None"));
	MakeContextMenuSeparator(context, 240.3);
	MakeContextMenuItem(context, "残枠表示：ブロック", "TOUKIBI_BUFFCOUNTER_CHANGEPROP('GaugeStyle', 'block')", nil, (Me.Settings.GaugeStyle == "block"));
	MakeContextMenuItem(context, "残枠表示：棒グラフ", "TOUKIBI_BUFFCOUNTER_CHANGEPROP('GaugeStyle', 'continuous')", nil, (Me.Settings.GaugeStyle == "continuous"));
	MakeContextMenuSeparator(context, 240.4);
	MakeContextMenuItem(context, "{#666666}閉じる{/}");
	context:Resize(250, context:GetHeight());
	ui.OpenContextMenu(context);
	return context;
end

-- ***** コンテキストメニュー選択イベント受取 *****

function TOUKIBI_BUFFCOUNTER_CHANGE_MOVABLE()
	if Me.Settings == nil then return end
	Me.Settings.Movable = not Me.Settings.Movable;
	Me.frame:EnableMove(Me.Settings.Movable and 1 or 0);
	SaveSetting();
end

function TOUKIBI_BUFFCOUNTER_RESETPOS()
	if Me.Settings == nil then return end
	Me.Settings.PosX = nil;
	Me.Settings.PosY = nil;
	Me.UpdatePos();
	SaveSetting();
	AddLog("耐久表示の表示位置をリセットしました", "Info", true, false);
end

function TOUKIBI_BUFFCOUNTER_CHANGEPROP(Name, Value)
	if Name == nil then return end
	if Value == "nil" then Value = nil end
	Me.Settings[Name] = Value
	SaveSetting();
	Me.Update();
end

-- ***** その他イベント受取 *****

function TOUKIBI_BUFFCOUNTER_TOKEN_ON_MSG(frame, msg, argStr, argNum)
	if argNum ~= ITEM_TOKEN or "NO" == argStr then
		return;
	end

	local sysTime = geTime.GetServerSystemTime();
	local endTime = session.loginInfo.GetTokenTime();
	Me.TokenRemainBaseSec = imcTime.GetDifSec(endTime, sysTime);
	Me.TokenGetTime = imcTime.GetAppTime();

	local BuffFrame = ui.GetFrame("buff")
	if Me.TokenRemainBaseSec > 0 then
		TOUKIBI_BUFFCOUNTER_UPDATE_TOKEN_TIME();
		BuffFrame:RunUpdateScript("TOUKIBI_BUFFCOUNTER_UPDATE_TOKEN_TIME", 1);
	else
		BuffFrame:StopUpdateScript("TOUKIBI_BUFFCOUNTER_UPDATE_TOKEN_TIME");
	end
end
--ui.GetFrame("buff"):RunUpdateScript("TOUKIBI_BUFFCOUNTER_UPDATE_TOKEN_TIME")
--ui.GetFrame("buff"):StopUpdateScript("TOUKIBI_BUFFCOUNTER_UPDATE_TOKEN_TIME")

function TOUKIBI_BUFFCOUNTER_START_DRAG()
	Me.IsDragging = true;
end

function TOUKIBI_BUFFCOUNTER_END_DRAG()
	Me.IsDragging = false;
	if not Me.Settings.Movable then return end
	Me.Settings.PosX = Me.frame:GetX();
	Me.Settings.PosY = Me.frame:GetY();
	SaveSetting();
	AddLog("ドラッグ終了。現在位置を保存します。", "Info", true, true);
end

function TOUKIBI_BUFFCOUNTER_ON_GAME_START()
	-- GAME_STARTイベント時ではheadsupdisplayフレームの移動が完了していないみたいなので0.5秒待ってみる
	ReserveScript("TOUKIBI_BUFFCOUNTER_UPDATE_ALL()", 0.5);
end

function TOUKIBI_BUFFCOUNTER_UPDATE_ALL(frame)
	Me.UpdatePos();
	Me.Update();
end

function TOUKIBI_BUFFCOUNTER_UPDATE(frame)
	Me.Update();
end

-- [DevConsole呼出可] 表示を更新する
function Me.Update()
	UpdateMainFrame();
	WriteBuffParam();
end

-- [DevConsole呼出可] 表示位置を更新する
function Me.UpdatePos()
	local TopFrame = Me.frame;
	if TopFrame == nil then return end
	if Me.Settings == nil or Me.Settings.PosX == nil or Me.Settings.PosY == nil then
		TopFrame:SetPos(450, 30);
	else
		TopFrame:SetPos(Me.Settings.PosX, Me.Settings.PosY);
	end
end

-- [DevConsole呼出可] 表示/非表示を切り替える(1:表示 0:非表示 nil:トグル)
function Me.Show(Value)
	if Value == nil or Value == 0 or Value == 1 then
		local BaseFrame = Me.frame;
		if BaseFrame == nil then
			CHAT_SYSTEM("画面のハンドルが取得できませんでした");
			return;
		end
		if Value == nil then
			if BaseFrame:IsVisible() == 0 then
				Value = 1;
			else
				Value = 0;
			end
		end
		BaseFrame:ShowWindow(Value);
	end 
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取

-- 使い方のテキストを出力する
local function PrintHelpToLog()
	local HelpMsg = "{#333333}Buff Counterのパラメータ説明{/}{nl}{#92D2A0}Buff Counterは次のパラメータで設定を呼び出してください。{/}{nl}{#333333}'/buffc [パラメータ]' または '/buffcounter [パラメータ]'{/}{nl}{#333366}パラメータなしで呼び出された場合は表示画面のON/OFFが切り替わります。(例： /buffc ){/}{nl}{#333333}使用可能なコマンド：{nl}/buffc reset    :設定リセット{nl}/buffc resetpos :耐久値表示画面の位置をリセット{nl}/buffc rspos    :  〃{nl}/buffc refresh  :位置・表示を更新{nl}/buffc update   :耐久値表示を更新{nl}/buffc ?        :このヘルプを表示{nl} ";
	AddLog(HelpMsg, "None", false, false);
end

function TOUKIBI_BUFFCOUNTER_PROCESS_COMMAND(command)
	AddLog("スラッシュコマンドが呼び出されました", "Info", true, true);
	local cmd = ""; 
	if #command > 0 then 
		cmd = table.remove(command, 1); 
	else 
		Me.Show();
		return;
	end 
	if cmd == "reset" then 
		-- すべてをリセット
		MargeDefaultSetting(true, true);
		return;
	elseif cmd == "resetpos" or cmd == "rspos" then 
		-- 位置をリセット
		TOUKIBI_BUFFCOUNTER_RESETPOS();
		return;
	elseif cmd == "refresh" then
		-- プログラムをリセット
		TOUKIBI_BUFFCOUNTER_UPDATE_ALL();
		return;
	-- elseif cmd == "showme" then
	-- 	GetMyBuffCount();
	-- 	return;
	elseif cmd == "update" then
		-- 表示値の更新
		Me.Update();
		return;
	-- elseif cmd == "joke" then
	-- 	--Me.Joke(true);
	-- 	return;
	elseif cmd ~= "?" then
		local strError = "無効なコマンドが呼び出されました";
		if #SlashCommandList > 0 then
			strError = strError .. string.format("{nl}コマンド一覧を見るには[ %s ? ]を用いてください", SlashCommandList[1]);
		end
		AddLog(strError, "Warning", true, false);
	end 
	PrintHelpToLog()
end

function Me.BUFF_TIME_UPDATE_HOOKED(handle, buff_ui)
	if handle == session.GetMyHandle() then
		-- 自分の場合はトークンの時間表示付きを使用する
		Me.UpdateBuffTimeText(handle, buff_ui);
	else
		-- そうでない場合は通常の処理を行う
		Me.HoockedOrigProc["BUFF_TIME_UPDATE"](handle, buff_ui);
	end
end

function BUFFCOUNTER_ON_INIT(addon, frame)
	Me.addon = addon;
	Me.frame = frame;

	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	if Me.Settings.DoNothing then return end

	-- イベントを登録する
	addon:RegisterMsg('BUFF_ADD', 'TOUKIBI_BUFFCOUNTER_UPDATE');
	addon:RegisterMsg('BUFF_REMOVE', 'TOUKIBI_BUFFCOUNTER_UPDATE');
	addon:RegisterMsg('BUFF_UPDATE', 'TOUKIBI_BUFFCOUNTER_UPDATE');
	-- addon:RegisterMsg('MYPC_CHANGE_SHAPE', 'TOUKIBI_DURMINI_UPDATE');
	addon:RegisterMsg('GAME_START', 'TOUKIBI_BUFFCOUNTER_ON_GAME_START');
	addon:RegisterMsg("TOKEN_STATE", "TOUKIBI_BUFFCOUNTER_TOKEN_ON_MSG");
	Me.setHook("BUFF_TIME_UPDATE", Me.BUFF_TIME_UPDATE_HOOKED);


	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_BUFFCOUNTER_PROCESS_COMMAND);
	end

	Me.frame:EnableMove(Me.Settings.Movable and 1 or 0);
	Me.Show(1);
	-- Me.Update();
	Me.UpdatePos()
	frame:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_BUFFCOUNTER_CONTEXT_MENU');
	Me.IsDragging = false;
	-- Me.Joke(OSRandom(1, 100) < 5)
end

-- イベントの飛び先を変更するためのプロシージャ
function Me.setHook(hookedFunctionStr, newFunction)
	if Me.HoockedOrigProc[hookedFunctionStr] == nil then
		Me.HoockedOrigProc[hookedFunctionStr] = _G[hookedFunctionStr];
		_G[hookedFunctionStr] = newFunction;
	else
		_G[hookedFunctionStr] = newFunction;
	end
end 


