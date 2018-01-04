local addonName = "BuffCounter";
local verText = "1.18";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/buffc", "/buffcounter", "/BuffCounter"} -- {"/コマンド1", "/コマンド2", .......};
local CommandParamList = {
	reset = {jp = "設定をリセット", en = "Reset the settings.", kr = "설정을 초기화"}
  , resetpos = {jp = "位置をリセット", en = "Reset the position.", kr = "위치를 초기화"}
  , rspos = {jp = "位置をリセット", en = "Reset the position.", kr = "위치를 초기화"}
  , refresh = {jp = "表示と位置を更新", en = "Update the position and values.", kr = "표시와 설정을 갱신한다"}
  , update = {jp = "表示を更新", en = "Reset the values.", kr = "표시와 설정을 갱신한다"}
  , jp = {jp = "日本語モードに切り替え", en = "Switch to Japanese mode.(日本語へ)", kr = "일본어 모드로 전환하십시오.(Japanese Mode)"}
  , en = {jp = "Switch to English mode.", en = "Switch to English mode.", kr = "Switch to English mode."}
  , kr = {jp = "한국어 모드로 변경(Korean Mode)", en = "Switch to Korean mode.(한국어로)", kr = "한국어 모드로 변경"};
};
local SettingFileName = "setting.json"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
BuffCounter = Me;
local DebugMode = false;

-- ***** 変数の宣言と設定 *****
Me.SettingFilePathName = string.format("../addons/%s/%s", addonNameLower, SettingFileName);
Me.Loaded = false;
Me.BuffFromShop = Me.BuffFromShop or {};


-- テキストリソース
local ResText = {
	jp = {
		Menu = {
			Title = "{#006666}===== Buff Counterの設定 ====={/}"
		  , UpdateNow = "{#FFFF88}今すぐ更新する{/}"
		  , FixPosition = "位置を固定する"
		  , ResetPosition = "位置をリセット"
		  , Mode_Title = "表示モード："
		  , Mode_Space = "            "
		  , Mode_Use = "バフ使用数"
		  , Mode_Left = "バフ残り枠"
		  , Mode_UltraMini = "極小表示"
		  , Back_Title = "背景：      "
		  , Back_Space = "            "
		  , Back_Deep = "濃い"
		  , Back_Thin = "薄い"
		  , Back_None = "なし"
		  , Gauge_Title = "残枠表示：  "
		  , Gauge_Space = "            "
		  , Gauge_Block = "ブロック"
		  , Gauge_Bar = "棒グラフ"
		  , Close = "{#666666}閉じる{/}"
		},
		Msg = {
			UpdateFrmaePos = "耐久表示の表示位置をリセットしました"
		  , EndDragAndSave = "ドラッグ終了。現在位置を保存します。"
		  , CannotGetHandle = "耐久表示画面の取得に失敗しました"
		},
		InFrame = {
			Myself = "自"
		  , PTMember = "PT"
		},
		System = {
			InitMsg = "コマンド /buffc で表示のON/OFFが切り替えられます"
		}
	},
	en = {
		Menu = {
			Title = "{#006666}===== Settings - Buff Counter - ====={/}"
		  , UpdateNow = "{#FFFF88}Update now!{/}"
		  , FixPosition = "Lock position"
		  , ResetPosition = "Reset position"
		  , Mode_Title = "Mode:             "
		  , Mode_Space = "                        "
		  , Mode_Use = "Buff Using Count"
		  , Mode_Left = "Vacant frames on Buff"
		  , Mode_UltraMini = "Ultra mini size"
		  , Back_Title = "Background: "
		  , Back_Space = "                         "
		  , Back_Deep = "Deep"
		  , Back_Thin = "Thin"
		  , Back_None = "None"
		  , Gauge_Title = "Gauge style:  "
		  , Gauge_Space = "                        "
		  , Gauge_Block = "Blocks"
		  , Gauge_Bar = "Continuous"
		  , Close = "{#666666}Close{/}"
		},
		Msg = {
			UpdateFrmaePos = "Display position was reset."
		  , EndDragAndSave = "Dragging ends. Save the current position."
		  , CannotGetHandle = "Failed to get the display screen."
		},
		InFrame = {
			Myself = "T"
		  , PTMember = "S"
		},
		System = {
			InitMsg = 'With command "/buffc", you can toggle display ON/OFF'
		}
	},
	kr = {
		Menu = {
			Title = "{#006666}===== Buff Counter의 설정 ====={/}"
		  , UpdateNow = "{#FFFF88}지금 당장 갱신한다{/}"
		  , FixPosition = "위치를 저장한다"
		  , ResetPosition = "위치를 리셋"
		  , Mode_Title = "표시모드：   "
		  , Mode_Space = "                      "
		  , Mode_Use = "버프사용수"
		  , Mode_Left = "버프남은수"
		  , Mode_UltraMini = "최소화표시"
		  , Back_Title = "배경：          "
		  , Back_Space = "                      "
		  , Back_Deep = "진하게"
		  , Back_Thin = "연하게"
		  , Back_None = "없음"
		  , Gauge_Title = "테두리표시："
		  , Gauge_Space = "                      "
		  , Gauge_Block = "블록"
		  , Gauge_Bar = "막대그래프"
		  , Close = "{#666666}닫는다{/}"
		},
		Msg = {
			UpdateFrmaePos = "내구도 표시의 표시위치를 리셋했습니다"
		  , EndDragAndSave = "드래그 종료. 현재 위치를 저장합니다."
		  , CannotGetHandle = "화면의 핸들을 취득하지 못했습니다"
		},
		InFrame = {
			Myself = "나"
		  , PTMember = "파티"
		},
		System = {
			InitMsg = nil
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
			  , ResetSettings = "Settings reset."
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

local function ShowInitializeMessage()
	local CurrentLang = "en"
	if Me.Settings == nil then
		CurrentLang = Toukibi:GetDefaultLangCode() or CurrentLang;
	else
		CurrentLang = Me.Settings.Lang or CurrentLang;
	end

	CHAT_SYSTEM(string.format("{#333333}%s{/}", Toukibi:GetResText(Toukibi.CommonResText, CurrentLang, "System.InitMsg")))
	CHAT_SYSTEM(string.format("{#333366}[%s]%s{/}", addonName, Toukibi:GetResText(ResText, CurrentLang, "System.InitMsg")))
end
ShowInitializeMessage()

-- ***** 変数の宣言と設定 *****

Me.BuffPrintInfo = {
	 [100] = {arg = "custom", fmt = "+%s"}, --サクラメント
--	 [146] = {arg = "arg1", fmt = "%s"}, --アスパ
	 [147] = {arg = "custom", fmt = "+%s"}, --ブレス
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

-- Customに設定したバフの表示値を返す
local function IsFromShop(buff)
	local ReturnValue = false; -- わからない場合は「露店バフではない」とする
	local currentIndex = tostring(buff.buffID)
	if Me.BuffFromShop ~= nil and Me.BuffFromShop[currentIndex] ~= nil then
		-- 記録があれば記録を使う
		ReturnValue = Me.BuffFromShop[currentIndex];
		-- log(string.format("記録有り (%s)", tostring(ReturnValue)))
	else
		-- 記録がない場合は、バフ主がDummyPCかで判断する
		local OwnerHandle = buff:GetHandle();
		if OwnerHandle ~= 0 and info.GetTargetInfo(OwnerHandle) ~= nil then
			-- バフ主が見つかった場合
			local TargetInfo = info.GetTargetInfo(OwnerHandle);
			ReturnValue = (TargetInfo.IsDummyPC ~= 0);
			-- log(string.format("主がいる (%s)", tostring(ReturnValue)))
			Me.BuffFromShop[currentIndex] = ReturnValue;
		else
			-- バフ主が見つからない場合は、時間で判定する
			if buff.buffID == 147 and buff.time > 300 * 1000 then
				ReturnValue = true;
				-- log(string.format("時間で判定 (%s)", tostring(ReturnValue)))
				Me.BuffFromShop[currentIndex] = ReturnValue;
			elseif buff.buffID == 100 and buff.time > 440 * 1000 then
				ReturnValue = true;
				Me.BuffFromShop[currentIndex] = ReturnValue;
			end
		end
	end
	return ReturnValue;
end

local function GetCustomeBuffValue(buff)
	local ReturnValue = 0;
	if buff.buffID == 147 then
		-- ブレス
		ReturnValue = 55 + ((buff.arg1 - 1) * 25) + ((buff.arg1 / 5) * (buff.arg3 ^ 0.9));
		ReturnValue = math.floor(ReturnValue * (1 + buff.arg4 * 0.01));
		if IsFromShop(buff) then
			-- 露店で受けた可能性あり
			ReturnValue = math.floor(ReturnValue * 0.7);
		end
		--log(ReturnValue)
	elseif buff.buffID == 100 then
		-- サクラ
		ReturnValue = buff.arg3
		if IsFromShop(buff) then
			-- 露店で受けた可能性あり
			ReturnValue = math.floor(ReturnValue * 0.7);
		end
	end
	return ReturnValue;
end

-- ==================================
--  設定関連
-- ==================================

local function SaveSetting()
	Toukibi:SaveTable(Me.SettingFilePathName, Me.Settings);
end

function Me.Save()
	SaveSetting()
end

-- デフォルト設定(ForceがTrueでない場合は、既存の値はそのまま引き継ぐ)
local function MargeDefaultSetting(Force, DoSave)
	DoSave = Toukibi:GetValueOrDefault(DoSave, true);
	Me.Settings = Me.Settings or {};

	Me.Settings.DoNothing	= Toukibi:GetValueOrDefault(Me.Settings.DoNothing	, false, Force);
	Me.Settings.Lang		= Toukibi:GetValueOrDefault(Me.Settings.Lang		, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.PosX		= Toukibi:GetValueOrDefault(Me.Settings.PosX		, nil, Force);
	Me.Settings.PosY		= Toukibi:GetValueOrDefault(Me.Settings.PosY		, nil, Force);
	Me.Settings.Movable		= Toukibi:GetValueOrDefault(Me.Settings.Movable		, false, Force);
	Me.Settings.Visible		= Toukibi:GetValueOrDefault(Me.Settings.Visible		, true, Force);
	Me.Settings.DisplayGauge= Toukibi:GetValueOrDefault(Me.Settings.DisplayGauge, true, Force);
	Me.Settings.GaugeStyle	= Toukibi:GetValueOrDefault(Me.Settings.GaugeStyle	, "block", Force); --block/continuous
	Me.Settings.DisplayMode	= Toukibi:GetValueOrDefault(Me.Settings.DisplayMode	, "left", Force); --use/left/ultramini
	Me.Settings.SkinName	= Toukibi:GetValueOrDefault(Me.Settings.SkinName	, "None", Force); --None/chat_window/systemmenu_vertical

	if Force then
		Toukibi:AddLog(Toukibi:GetResText(Toukibi.CommonResText, Me.Settings.Lang, "System.CompleteLoadDefault"), "Info", true, false);
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
		Toukibi:AddLog(string.format("%s{nl}{#331111}%s{/}", Toukibi:GetResText(Toukibi.CommonResText, CurrentLang, "System.ErrorToUseDefaults"), tostring(objError)), "Caution", true, false);
		MargeDefaultSetting(true, false);
	else
		Me.Settings = objReadValue;
		MargeDefaultSetting(false, false);
	end
	Toukibi:AddLog(Toukibi:GetResText(Toukibi.CommonResText, Me.Settings.Lang, "System.CompleteLoadSettings"), "Info", true, false);
end

function Me.Load()
	LoadSetting()
end

-- ===== アドオンの内容ここから =====

-- 残り時間を見やすく加工する
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

-- バフの右下にレベルなど付加情報を書き込む
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
						if DrawInfo.arg == "custom" then
							lblParam:SetText(string.format("{#38FBEE}{ol}{s11}" .. DrawInfo.fmt .. "{/}{/}{/}", GetCustomeBuffValue(buff)));
						else
							lblParam:SetText(string.format("{#38FBEE}{ol}{s11}" .. DrawInfo.fmt .. "{/}{/}{/}", buff[DrawInfo.arg]));
						end
						lblParam:ShowWindow(1);
						pnlBack:Resize(lblParam:GetWidth() + 1, lblParam:GetHeight());
						pnlBack:ShowWindow(1);
						-- log(string.format("{#AAAAAA}{ol}{s11}" .. DrawInfo.fmt .. "{/}{/}{/}",buff[DrawInfo.arg]))
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

-- バフの残り時間を書き込む
function Me.UpdateBuffTimeText(handle, buff_ui)
	local updated = 0;
	-- log("てすと")
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

-- バフの数を取得する
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
		-- 上段バフの上限をプラスする
		if buff.buffID == 70002 then
			-- トークン
			Additional = Additional + 1;
		elseif buff.buffID == 3016 then
			-- ダイノ
			ReturnValue.DainoLv = buff.arg1;
		elseif buff.buffID == 147 then
			-- ブレッシング(デバッグ用)
--			Toukibi:AddLog(string.format("%s(Lv.%s):%s", buffCls.Name, buff.arg1, buff.arg2), "Info", false, false);
		end
-- log(string.format("[%s]%s : %s, %s, %s", buff.buffID, buffCls.Name, buff.arg1, buff.arg2, buff.arg3, buff.arg4, buff.arg5))
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
--log(string.format("[%s]%s : %s, %s, %s", buff.buffID, buffCls.Name, buff.arg1, buff.arg2, buff.arg3, buff.arg4, buff.arg5))
	end
	-- JOBランクを取得する
	local cid = info.GetCID(ReturnValue.handle);
--log("CID : " .. cid)
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
			--log("キャラ情報の取得に失敗")
		end
	end
	ReturnValue.UpperBuffLimit = ReturnValue.MaxBuffCountBase + ReturnValue.MaxBuffAdditional;
	ReturnValue.LeftCount = ReturnValue.UpperBuffLimit - ReturnValue.UpperBuffCount;
	if ReturnValue.DainoLv > 0 then
		ReturnValue.LeftCount = ReturnValue.LeftCount + ReturnValue.DainoLv + 1
	end
	-- log(string.format("%s/%s", ReturnValue.UpperBuffCount, ReturnValue.MaxBuffCountBase + ReturnValue.MaxBuffAdditional))
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
			-- log(string.format("Me:%s  PTM(%s):%s", myInfo:GetMapID(), i, pcInfo:GetMapID()))
			if myInfo ~= pcInfo and myInfo:GetMapID() == pcInfo:GetMapID() and myInfo:GetChannel() == pcInfo:GetChannel() then
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
--	log(string.format("自分:%s/%s   PTM:%s/%s", ReturnValue.Self.CurrentCount, ReturnValue.Self.LimitCount + ReturnValue.Self.DainoLv, ReturnValue.PTM.CurrentCount, ReturnValue.PTM.LimitCount + ReturnValue.PTM.DainoLv))
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
	local TopFrame = ui.GetFrame("buffcounter");
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
		lblBuffSelf:SetMargin(2, 9, 0, 0);
		lblBuffPTM:Resize(36, 20);
		lblBuffPTM:SetMargin(40, 9, 0, 0);
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
		lblBuffSelf:SetMargin(2, 9, 0, 0);
		lblBuffPTM:Resize(96, 20);
		lblBuffPTM:SetMargin(2, 25, 0, 0);
		objGauge:ShowWindow(1);
		objGauge:SetMargin(5, 2, 0, 0);
		pnlBase:Resize(80, 43);
		TopFrame:Resize(80, 43);
	end
	lblBuffSelf:SetText(GetCountText(Toukibi:GetResText(ResText, Me.Settings.Lang, "InFrame.Myself"), Me.Settings.DisplayMode, BuffData.Self));
	lblBuffPTM:SetText(GetCountText(Toukibi:GetResText(ResText, Me.Settings.Lang, "InFrame.PTMember"), Me.Settings.DisplayMode, BuffData.PTM));
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

		local GaugeText = "";
		local DotImage = "{img dot_green 8 8}"
		local SeparatorImage = "{img channel_mark_empty 4 8}"
		local TotalCount = 0;
		if intValue >= intMaxValue - 1 then
			DotImage = "{img dot_red 8 8}"
		elseif intValue >= intMaxValue - 3 then
			DotImage = "{img dot_orange 8 8}"
		elseif intValue * 10 >= intMaxValue * 3 then
			DotImage = "{img dot_yellow 8 8}"
		else
			DotImage = "{img dot_green 8 8}"
		end
		for i = 1, intValue do
			GaugeText = GaugeText .. DotImage;
			TotalCount = TotalCount + 1;
			if math.fmod(TotalCount, 5) == 0 then
				GaugeText = GaugeText .. SeparatorImage;
			end
		end
		for i = TotalCount + 1, intMaxValue - AddByDaino do
			GaugeText = GaugeText .. "{img dot_dark 8 8}";
			TotalCount = TotalCount + 1;
			if math.fmod(TotalCount, 5) == 0 then
				GaugeText = GaugeText .. SeparatorImage;
			end
		end
		for i =  TotalCount + 1, intMaxValue do
			GaugeText = GaugeText .. "{img dot_darkblue 8 8}";
			TotalCount = TotalCount + 1;
			if math.fmod(TotalCount, 5) == 0 then
				GaugeText = GaugeText .. SeparatorImage;
			end
		end

		lblGauge:SetText(GaugeText);
		lblGauge:ShowWindow(1);

		local NewWidth = 4 + lblGauge:GetWidth()
		if NewWidth > 80 then
			pnlBase:Resize(NewWidth, 43);
			TopFrame:Resize(NewWidth, 43);
		end
	end

	TopFrame:Invalidate()
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
	local context = ui.CreateContextMenu("BUFFCOUNTER_MAIN_RBTN"
										, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Title")
										, 0, 0, 180, 0);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.UpdateNow"), "TOUKIBI_BUFFCOUNTER_UPDATE()");
	Toukibi:MakeCMenuSeparator(context, 300);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.FixPosition"), "TOUKIBI_BUFFCOUNTER_CHANGE_MOVABLE()", nil, not Me.Settings.Movable);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.ResetPosition"), "TOUKIBI_BUFFCOUNTER_RESETPOS()", nil, false);
	Toukibi:MakeCMenuSeparator(context, 300.1);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Mode_Title"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Mode_Use"), 
											"TOUKIBI_BUFFCOUNTER_CHANGEPROP('DisplayMode', 'use')", nil, (Me.Settings.DisplayMode == "use"));
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Mode_Space"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Mode_Left"), 
											"TOUKIBI_BUFFCOUNTER_CHANGEPROP('DisplayMode', 'left')", nil, (Me.Settings.DisplayMode == "left"));
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Mode_Space"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Mode_UltraMini"), 
											"TOUKIBI_BUFFCOUNTER_CHANGEPROP('DisplayMode', 'ultramini')", nil, (Me.Settings.DisplayMode == "ultramini"));
	Toukibi:MakeCMenuSeparator(context, 300.2);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Back_Title"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Back_Deep"), 
											"TOUKIBI_BUFFCOUNTER_CHANGEPROP('SkinName', 'systemmenu_vertical')", nil, (Me.Settings.SkinName == "systemmenu_vertical"));
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Back_Space"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Back_Thin"), 
											"TOUKIBI_BUFFCOUNTER_CHANGEPROP('SkinName', 'chat_window')", nil, (Me.Settings.SkinName == "chat_window"));
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Back_Space"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Back_None"), 
											"TOUKIBI_BUFFCOUNTER_CHANGEPROP('SkinName', 'None')", nil, (Me.Settings.SkinName == "None"));
	Toukibi:MakeCMenuSeparator(context, 300.3);
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Gauge_Title"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Gauge_Block"), 
											"TOUKIBI_BUFFCOUNTER_CHANGEPROP('GaugeStyle', 'block')", nil, (Me.Settings.GaugeStyle == "block"));
	Toukibi:MakeCMenuItemHasCheckInTheMiddle(context, 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Gauge_Space"), 
											Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Gauge_Bar"), 
											"TOUKIBI_BUFFCOUNTER_CHANGEPROP('GaugeStyle', 'continuous')", nil, (Me.Settings.GaugeStyle == "continuous"));
	Toukibi:MakeCMenuSeparator(context, 300.4);
	Toukibi:MakeCMenuItem(context, Toukibi:GetResText(ResText, Me.Settings.Lang, "Menu.Close"));
	if Me.Settings.Lang == "en" then
		context:Resize(330, context:GetHeight());
	else
		context:Resize(250, context:GetHeight());
	end
	ui.OpenContextMenu(context);
	return context;
end

-- ***** コンテキストメニュー選択イベント受取 *****

function TOUKIBI_BUFFCOUNTER_CHANGE_MOVABLE()
	if Me.Settings == nil then return end
	Me.Settings.Movable = not Me.Settings.Movable;
	local objFrame = ui.GetFrame("buffcounter")
	if objFrame ~= nil then
		objFrame:EnableMove(Me.Settings.Movable and 1 or 0);
		SaveSetting();
	end
end

function TOUKIBI_BUFFCOUNTER_RESETPOS()
	if Me.Settings == nil then return end
	Me.Settings.PosX = nil;
	Me.Settings.PosY = nil;
	Me.UpdatePos();
	SaveSetting();
	Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "Msg.UpdateFrmaePos"), "Info", true, false);
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
	local objFrame = ui.GetFrame("buffcounter")
	if objFrame == nil then return end
	Me.Settings.PosX = objFrame:GetX();
	Me.Settings.PosY = objFrame:GetY();
	SaveSetting();
	Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "Msg.EndDragAndSave"), "Info", true, true);
end

function TOUKIBI_BUFFCOUNTER_ON_GAME_START()
	-- GAME_STARTイベント時ではheadsupdisplayフレームの移動が完了していないみたいなので0.5秒待ってみる
	ReserveScript("TOUKIBI_BUFFCOUNTER_UPDATE_ALL()", 0.5);
end

function TOUKIBI_BUFFCOUNTER_UPDATE_ALL(frame)
	Me.UpdatePos();
	Me.Update();
end

function TOUKIBI_BUFFCOUNTER_UPDATE(frame, msg, argStr, argNum)
	--log(string.format("%s : %s (%s)", msg, argStr, argNum));
	if msg == "BUFF_ADD" or msg == "BUFF_UPDATE" then
		-- 露店のバフかを確認する
		local handle = session.GetMyHandle();
		local BuffCount = info.GetBuffCount(handle);
		for i = 0, BuffCount - 1 do
			local buff = info.GetBuffIndexed(handle, i);
			if buff ~= nil and buff.buffID == argNum then
				--log("buffID : " .. buff.buffID)
				local OwnerHandle = buff:GetHandle();
				--log("owner : " .. OwnerHandle)
				if OwnerHandle ~= 0 and info.GetTargetInfo(OwnerHandle) ~= nil then
					local TargetInfo = info.GetTargetInfo(OwnerHandle);
					--log("Target : " .. tostring(TargetInfo))
					--log("IsDummy : " .. tostring(TargetInfo.IsDummyPC ~= 0))
					Me.BuffFromShop[tostring(argNum)] = (TargetInfo.IsDummyPC ~= 0);
				end
			end
		end
	end
	Me.Update();
end

-- [DevConsole呼出可] 表示を更新する
function Me.Update()
	UpdateMainFrame();
	WriteBuffParam();
end

-- [DevConsole呼出可] 表示位置を更新する
function Me.UpdatePos()
	local TopFrame = ui.GetFrame("buffcounter");
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
		local BaseFrame = ui.GetFrame("buffcounter");
		if BaseFrame == nil then
			log(Toukibi:GetResText(ResText, Me.Settings.Lang, "Msg.CannotGetHandle"));
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

function TOUKIBI_BUFFCOUNTER_TIMER_UPDATE_TICK()
	if ui.GetFrame("loadingbg") ~= nil then return end
	Me.Update();
end

function TOUKIBI_BUFFCOUNTER_TIMER_PCCOUNT_START()
	Me.timer_update:Start(5);
end

function TOUKIBI_BUFFCOUNTER_TIMER_PCCOUNT_STOP()
	Me.timer_update:Stop();
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取
function TOUKIBI_BUFFCOUNTER_PROCESS_COMMAND(command)
	Toukibi:AddLog(string.format(Toukibi:GetResText(Toukibi.CommonResText, Me.Settings.Lang, "Command.ExecuteCommands"), SlashCommandList[1] .. " " .. table.concat(command, " ")), "Info", true, true);
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
		TOUKIBI_BUFFCOUNTER_UPDATE_ALL();
		return;
	elseif cmd == "resetpos" or cmd == "rspos" then 
		-- 位置をリセット
		TOUKIBI_BUFFCOUNTER_RESETPOS();
		return;
	elseif cmd == "refresh" then
		-- プログラムをリセット
		TOUKIBI_BUFFCOUNTER_UPDATE_ALL();
		return;
	elseif cmd == "update" then
		-- 表示値の更新
		Me.Update();
		return;
	-- elseif cmd == "joke" then
	-- 	--Me.Joke(true);
	-- 	return;
	elseif cmd == "jp" or cmd == "ja" or cmd == "en" or string.len(cmd) == 2 then
		if cmd == "ja" then cmd = "jp" end
		-- 言語モードと勘違いした？
		Toukibi:ChangeLanguage(cmd);
		TOUKIBI_BUFFCOUNTER_UPDATE_ALL();
		return;
	elseif cmd ~= "?" then
		local strError = Toukibi:GetResText(Toukibi.CommonResText, Me.Settings.Lang, "Command.InvalidCommand");
		if #SlashCommandList > 0 then
			strError = strError .. string.format("{nl}" .. Toukibi:GetResText(Toukibi.CommonResText, Me.Settings.Lang, "Command.AnnounceCommandList"), SlashCommandList[1]);
		end
		Toukibi:AddLog(strError, "Warning", true, false);
	end 
	Me.ComLib:ShowHelpText()
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

function Me.ICON_USE_HOOKED(object, reAction)
	Me.HoockedOrigProc["ICON_USE"](object, reAction);
	if ui.GetFrame("loadingbg") ~= nil then return end
	ReserveScript("TOUKIBI_BUFFCOUNTER_UPDATE()", 0.3);
end

Me.HoockedOrigProc = Me.HoockedOrigProc or {};
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
	Me.setHook("ICON_USE", Me.ICON_USE_HOOKED);

	Me.timer_update = GET_CHILD(ui.GetFrame("buffcounter"), "timer_update", "ui::CAddOnTimer");
	Me.timer_update:SetUpdateScript("TOUKIBI_BUFFCOUNTER_TIMER_UPDATE_TICK");

	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_BUFFCOUNTER_PROCESS_COMMAND);
	end

	ui.GetFrame("buffcounter"):EnableMove(Me.Settings.Movable and 1 or 0);
	Me.Show(1);
	-- Me.Update();
	Me.UpdatePos()
	frame:SetEventScript(ui.RBUTTONDOWN, 'TOUKIBI_BUFFCOUNTER_CONTEXT_MENU');
	Me.IsDragging = false;
	-- Me.Joke(OSRandom(1, 100) < 5)
	TOUKIBI_BUFFCOUNTER_TIMER_PCCOUNT_START()
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


