local addonName = "ToolTipHelper_Toukibi";
local verText = "1.08";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);
local SlashCommandList = {"/tth"} -- {"/コマンド1", "/コマンド2", .......};
local CommandParamList = {
	reset = {jp = "設定リセット", en = "Reset the all settings."}
  , jp = {jp = "日本語モードに切り替え", en = "Switch to Japanese mode.(日本語へ)"}
  , en = {jp = "英語モードに切り替え(Switch to English mode.)", en = "Switch to English mode."}
  , import = {jp = "ドロップ情報の読み込み", en = "No need to run (Already implemented)"}
};
local SettingFileName = "setting.json"
local MagnumOpusRecipeFileName = "recipe_puzzle.xml"

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
ToolTipR = Me;
local DebugMode = false;

-- マグナムオーパスレシピ
local MagnumOpusRecipes = {
	["Drug_HP3"] = {
		{ name = "Drug_HP1", row = 0, col = 0 },
		{ name = "Drug_HP1", row = 1, col = 0 },
		{ name = "Drug_HP2", row = 0, col = 1 }
	},
	["misc_jore14"] = {
		{ name = "misc_jore12", row = 0, col = 0 }
	},
	["misc_jore15"] = {
		{ name = "misc_jore13", row = 0, col = 0 },
		{ name = "misc_jore13", row = 0, col = 1 },
		{ name = "misc_jore13", row = 1, col = 0 },
		{ name = "misc_jore13", row = 1, col = 1 }
	},
	["Hat_628042"] = {
		{ name = "wood_01", row = 0, col = 0 },
		{ name = "wood_01", row = 0, col = 1 },
		{ name = "wood_01", row = 0, col = 3 },
		{ name = "wood_01", row = 0, col = 4 },
		{ name = "misc_ore09", row = 1, col = 0 },
		{ name = "misc_Echad3", row = 1, col = 1 },
		{ name = "wood_01", row = 1, col = 2 },
		{ name = "misc_shtayim3", row = 1, col = 3 },
		{ name = "misc_ore09", row = 1, col = 4 },
		{ name = "wood_01", row = 2, col = 0 },
		{ name = "wood_01", row = 2, col = 1 },
		{ name = "wood_01", row = 2, col = 3 },
		{ name = "wood_01", row = 2, col = 4 }
	},
	["Hat_628047"] = {
		{ name = "misc_goldbar", row = 0, col = 1 },
		{ name = "misc_goldbar", row = 0, col = 2 },
		{ name = "misc_goldbar", row = 1, col = 0 },
		{ name = "misc_goldbar", row = 1, col = 1 },
		{ name = "misc_goldbar", row = 1, col = 2 },
		{ name = "misc_goldbar", row = 1, col = 3 }
	},
	["misc_0019"] = {
		{ name = "misc_0001", row = 0, col = 0 },
		{ name = "misc_0001", row = 0, col = 1 },
		{ name = "misc_0001", row = 1, col = 0 },
		{ name = "misc_0001", row = 1, col = 1 },
		{ name = "misc_0001", row = 2, col = 0 },
		{ name = "misc_0001", row = 2, col = 1 }
	},
	["misc_Grummer"] = {
		{ name = "misc_0010", row = 0, col = 0 },
		{ name = "misc_0010", row = 0, col = 1 },
		{ name = "misc_0010", row = 0, col = 2 },
		{ name = "misc_0010", row = 1, col = 0 },
		{ name = "misc_0010", row = 1, col = 1 },
		{ name = "misc_0010", row = 1, col = 2 }
	},
	["TSF02_105"] = {
		{ name = "misc_ore09", row = 0, col = 0 },
		{ name = "misc_ore09", row = 1, col = 0 },
		{ name = "misc_ore09", row = 2, col = 0 },
		{ name = "misc_ore09", row = 3, col = 0 },
		{ name = "misc_ore09", row = 4, col = 0 },
		{ name = "misc_ore09", row = 5, col = 0 }
	},
	["STF02_107"] = {
		{ name = "misc_ore09", row = 0, col = 0 },
		{ name = "misc_ore09", row = 0, col = 1 },
		{ name = "misc_ore09", row = 1, col = 1 },
		{ name = "misc_ore09", row = 2, col = 1 },
		{ name = "misc_ore09", row = 3, col = 1 }
	},
	["food_Popolion"] = {
		{ name = "misc_0001", row = 0, col = 0 },
		{ name = "misc_0001", row = 0, col = 1 },
		{ name = "misc_0001", row = 1, col = 0 },
		{ name = "misc_0001", row = 1, col = 1 }
	},
	["misc_0006"] = {
		{ name = "misc_0002", row = 0, col = 0 },
		{ name = "misc_0002", row = 0, col = 1 },
		{ name = "misc_0002", row = 1, col = 0 },
		{ name = "misc_0002", row = 1, col = 1 }
	},
	["misc_0008"] = {
		{ name = "misc_0005", row = 0, col = 0 },
		{ name = "misc_0005", row = 0, col = 1 },
		{ name = "misc_0005", row = 1, col = 0 },
		{ name = "misc_0005", row = 1, col = 1 }
	},
	["misc_0009"] = {
		{ name = "misc_0004", row = 0, col = 0 },
		{ name = "misc_0004", row = 0, col = 1 },
		{ name = "misc_0004", row = 1, col = 0 },
		{ name = "misc_0004", row = 1, col = 1 }
	},
	["misc_0010"] = {
		{ name = "misc_0006", row = 0, col = 0 },
		{ name = "misc_0006", row = 0, col = 1 },
		{ name = "misc_0006", row = 1, col = 0 },
		{ name = "misc_0006", row = 1, col = 1 }
	},
	["misc_0013"] = {
		{ name = "misc_0008", row = 0, col = 0 },
		{ name = "misc_0008", row = 0, col = 1 },
		{ name = "misc_0008", row = 1, col = 0 },
		{ name = "misc_0008", row = 1, col = 1 }
	},
	["misc_0119"] = {
		{ name = "misc_0010", row = 0, col = 0 },
		{ name = "misc_0010", row = 0, col = 1 },
		{ name = "misc_0010", row = 1, col = 0 },
		{ name = "misc_0010", row = 1, col = 1 }
	},
	["misc_0014"] = {
		{ name = "misc_0119", row = 0, col = 0 },
		{ name = "misc_0119", row = 0, col = 1 },
		{ name = "misc_0119", row = 1, col = 0 },
		{ name = "misc_0119", row = 1, col = 1 }
	},
	["misc_0016"] = {
		{ name = "misc_0008", row = 0, col = 0 },
		{ name = "misc_0008", row = 0, col = 1 },
		{ name = "misc_0008", row = 1, col = 0 },
		{ name = "misc_0008", row = 1, col = 1 },
		{ name = "misc_0008", row = 2, col = 0 },
		{ name = "misc_0008", row = 2, col = 1 }
	},
	["misc_0106"] = {
		{ name = "misc_0005", row = 0, col = 0 },
		{ name = "misc_0005", row = 1, col = 0 },
		{ name = "misc_0005", row = 2, col = 0 },
		{ name = "misc_0005", row = 3, col = 0 }
	},
	["misc_0015"] = {
		{ name = "misc_0016", row = 0, col = 0 },
		{ name = "misc_0016", row = 0, col = 1 },
		{ name = "misc_0016", row = 1, col = 0 },
		{ name = "misc_0016", row = 1, col = 1 }
	},
	["misc_0019"] = {
		{ name = "misc_0015", row = 0, col = 0 },
		{ name = "misc_0015", row = 0, col = 1 },
		{ name = "misc_0015", row = 1, col = 0 },
		{ name = "misc_0015", row = 1, col = 1 }
	},
	["misc_0018"] = {
		{ name = "misc_0014", row = 0, col = 0 },
		{ name = "misc_0014", row = 0, col = 1 },
		{ name = "misc_0014", row = 1, col = 0 },
		{ name = "misc_0014", row = 1, col = 1 },
		{ name = "misc_0014", row = 2, col = 0 },
		{ name = "misc_0014", row = 2, col = 1 }
	},
	["misc_Grummer"] = {
		{ name = "misc_0010", row = 0, col = 0 },
		{ name = "misc_0010", row = 0, col = 1 },
		{ name = "misc_0019", row = 1, col = 0 },
		{ name = "misc_0019", row = 1, col = 1 }
	},
	["misc_leafly"] = {
		{ name = "misc_0119", row = 0, col = 0 },
		{ name = "misc_0119", row = 0, col = 1 },
		{ name = "misc_0119", row = 0, col = 2 },
		{ name = "misc_0119", row = 1, col = 0 }
	},
	["misc_puragi"] = {
		{ name = "misc_0018", row = 0, col = 0 },
		{ name = "misc_0018", row = 1, col = 0 },
		{ name = "misc_0018", row = 2, col = 0 }
	},
	["misc_0022"] = {
		{ name = "misc_leafly", row = 0, col = 0 },
		{ name = "misc_leafly", row = 0, col = 1 },
		{ name = "misc_leafly", row = 0, col = 2 },
		{ name = "misc_leafly", row = 1, col = 0 },
		{ name = "misc_leafly", row = 1, col = 1 },
		{ name = "misc_leafly", row = 1, col = 2 },
		{ name = "misc_leafly", row = 2, col = 0 },
		{ name = "misc_leafly", row = 2, col = 1 },
		{ name = "misc_leafly", row = 2, col = 2 }
	},
	["misc_banshee"] = {
		{ name = "misc_0018", row = 0, col = 0 },
		{ name = "misc_0018", row = 0, col = 1 },
		{ name = "misc_0018", row = 1, col = 0 },
		{ name = "misc_0018", row = 1, col = 1 }
	},
	["misc_zigri"] = {
		{ name = "misc_puragi", row = 0, col = 0 },
		{ name = "misc_puragi", row = 0, col = 1 },
		{ name = "misc_puragi", row = 1, col = 0 },
		{ name = "misc_puragi", row = 1, col = 1 }
	},
	["misc_humming_bud"] = {
		{ name = "misc_leafly", row = 0, col = 0 },
		{ name = "misc_leafly", row = 0, col = 1 },
		{ name = "misc_leafly", row = 0, col = 3 },
		{ name = "misc_leafly", row = 1, col = 0 },
		{ name = "misc_leafly", row = 1, col = 1 },
		{ name = "misc_leafly", row = 1, col = 3 }
	},
	["misc_seedmia"] = {
		{ name = "misc_0022", row = 0, col = 0 },
		{ name = "misc_0022", row = 0, col = 1 },
		{ name = "misc_0022", row = 1, col = 0 },
		{ name = "misc_0022", row = 1, col = 1 }
	},
	["misc_mallardu"] = {
		{ name = "food_Popolion", row = 0, col = 0 },
		{ name = "food_Popolion", row = 0, col = 1 },
		{ name = "food_Popolion", row = 0, col = 3 },
		{ name = "food_Popolion", row = 1, col = 0 },
		{ name = "food_Popolion", row = 1, col = 1 },
		{ name = "food_Popolion", row = 1, col = 3 }
	},
	["misc_0112"] = {
		{ name = "misc_seedmia", row = 0, col = 0 },
		{ name = "misc_seedmia", row = 1, col = 0 },
		{ name = "misc_seedmia", row = 2, col = 0 }
	},
	["misc_0113"] = {
		{ name = "misc_banshee", row = 0, col = 0 },
		{ name = "misc_banshee", row = 0, col = 1 },
		{ name = "misc_banshee", row = 1, col = 0 },
		{ name = "misc_banshee", row = 1, col = 1 }
	},
	["misc_0035"] = {
		{ name = "misc_0112", row = 0, col = 0 },
		{ name = "misc_0112", row = 1, col = 0 },
		{ name = "misc_0112", row = 2, col = 0 }
	},
	["misc_maize"] = {
		{ name = "misc_0113", row = 0, col = 0 },
		{ name = "misc_0113", row = 0, col = 1 },
		{ name = "misc_0113", row = 1, col = 0 },
		{ name = "misc_0113", row = 1, col = 1 }
	},
	["misc_0037"] = {
		{ name = "misc_humming_bud", row = 0, col = 0 },
		{ name = "misc_humming_bud", row = 0, col = 1 },
		{ name = "misc_humming_bud", row = 1, col = 0 },
		{ name = "misc_humming_bud", row = 1, col = 1 }
	},
	["misc_Rudas_loxodon"] = {
		{ name = "misc_mallardu", row = 0, col = 0 },
		{ name = "misc_mallardu", row = 0, col = 1 },
		{ name = "misc_mallardu", row = 1, col = 0 },
		{ name = "misc_mallardu", row = 1, col = 1 }
	},
	["misc_0040"] = {
		{ name = "misc_0035", row = 0, col = 0 },
		{ name = "misc_0035", row = 0, col = 1 },
		{ name = "misc_0035", row = 1, col = 0 },
		{ name = "misc_0035", row = 1, col = 1 }
	},
	["misc_Caro"] = {
		{ name = "misc_maize", row = 0, col = 0 },
		{ name = "misc_maize", row = 0, col = 1 },
		{ name = "misc_maize", row = 1, col = 0 },
		{ name = "misc_maize", row = 1, col = 1 }
	},
	["misc_Mentiwood"] = {
		{ name = "misc_0040", row = 0, col = 0 },
		{ name = "misc_0040", row = 0, col = 1 },
		{ name = "misc_0040", row = 1, col = 0 },
		{ name = "misc_0040", row = 1, col = 1 }
	},
	["misc_0026"] = {
		{ name = "misc_zigri", row = 0, col = 0 },
		{ name = "misc_zigri", row = 0, col = 1 },
		{ name = "misc_zigri", row = 1, col = 0 },
		{ name = "misc_zigri", row = 1, col = 1 }
	},
	["misc_glizardon"] = {
		{ name = "misc_0018", row = 0, col = 0 },
		{ name = "misc_0018", row = 0, col = 1 },
		{ name = "misc_0018", row = 1, col = 0 },
		{ name = "misc_0018", row = 1, col = 1 },
		{ name = "misc_0018", row = 2, col = 0 },
		{ name = "misc_0018", row = 2, col = 1 }
	},
	["misc_Corylus"] = {
		{ name = "misc_Caro", row = 0, col = 0 },
		{ name = "misc_Caro", row = 1, col = 0 },
		{ name = "misc_Caro", row = 2, col = 0 },
		{ name = "misc_Caro", row = 3, col = 0 }
	},
	["misc_galok"] = {
		{ name = "misc_Mentiwood", row = 0, col = 0 },
		{ name = "misc_Mentiwood", row = 0, col = 1 },
		{ name = "misc_Mentiwood", row = 1, col = 0 },
		{ name = "misc_Mentiwood", row = 1, col = 1 }
	},
	["misc_0025"] = {
		{ name = "misc_0026", row = 0, col = 0 },
		{ name = "misc_0026", row = 0, col = 1 },
		{ name = "misc_0026", row = 1, col = 0 },
		{ name = "misc_0026", row = 1, col = 1 }
	},
	["misc_Spector_Gh"] = {
		{ name = "misc_Corylus", row = 0, col = 0 },
		{ name = "misc_Corylus", row = 0, col = 1 },
		{ name = "misc_Corylus", row = 1, col = 0 },
		{ name = "misc_Corylus", row = 1, col = 1 }
	},
	["misc_0043"] = {
		{ name = "misc_Corylus", row = 0, col = 0 },
		{ name = "misc_Corylus", row = 1, col = 0 },
		{ name = "misc_Corylus", row = 2, col = 0 }
	},
	["misc_0122"] = {
		{ name = "misc_galok", row = 0, col = 0 },
		{ name = "misc_galok", row = 1, col = 0 },
		{ name = "misc_galok", row = 2, col = 0 }
	},
	["misc_Velwriggler"] = {
		{ name = "misc_Spector_Gh", row = 0, col = 0 },
		{ name = "misc_Spector_Gh", row = 1, col = 0 },
		{ name = "misc_Spector_Gh", row = 2, col = 0 },
		{ name = "misc_Spector_Gh", row = 3, col = 0 }
	},
	["misc_0046"] = {
		{ name = "misc_0025", row = 0, col = 0 },
		{ name = "misc_0025", row = 0, col = 1 },
		{ name = "misc_0025", row = 0, col = 2 },
		{ name = "misc_0025", row = 1, col = 0 },
		{ name = "misc_0025", row = 1, col = 1 },
		{ name = "misc_0025", row = 1, col = 2 }
	},
	["misc_0044"] = {
		{ name = "misc_0043", row = 0, col = 0 },
		{ name = "misc_0043", row = 0, col = 1 },
		{ name = "misc_0043", row = 1, col = 0 },
		{ name = "misc_0043", row = 1, col = 1 }
	},
	["misc_0045"] = {
		{ name = "misc_0122", row = 0, col = 0 },
		{ name = "misc_0122", row = 0, col = 1 },
		{ name = "misc_0122", row = 1, col = 0 },
		{ name = "misc_0122", row = 1, col = 1 }
	},
	["misc_0102"] = {
		{ name = "misc_Velwriggler", row = 0, col = 0 },
		{ name = "misc_Velwriggler", row = 0, col = 1 },
		{ name = "misc_Velwriggler", row = 1, col = 0 },
		{ name = "misc_Velwriggler", row = 1, col = 1 }
	},
	["misc_0049"] = {
		{ name = "misc_0044", row = 0, col = 0 },
		{ name = "misc_0044", row = 0, col = 1 },
		{ name = "misc_0044", row = 1, col = 0 },
		{ name = "misc_0044", row = 1, col = 1 },
		{ name = "misc_0044", row = 2, col = 0 },
		{ name = "misc_0044", row = 2, col = 1 }
	},
	["misc_0047"] = {
		{ name = "misc_0045", row = 0, col = 0 },
		{ name = "misc_0045", row = 0, col = 1 },
		{ name = "misc_0045", row = 1, col = 0 },
		{ name = "misc_0045", row = 1, col = 1 }
	},
	["misc_Ammon"] = {
		{ name = "misc_0102", row = 0, col = 0 },
		{ name = "misc_0102", row = 0, col = 1 },
		{ name = "misc_0102", row = 1, col = 0 },
		{ name = "misc_0102", row = 1, col = 1 }
	},
	["misc_0135"] = {
		{ name = "misc_Ammon", row = 0, col = 0 },
		{ name = "misc_Ammon", row = 0, col = 1 },
		{ name = "misc_Ammon", row = 1, col = 0 },
		{ name = "misc_Ammon", row = 1, col = 1 },
		{ name = "misc_Ammon", row = 2, col = 0 },
		{ name = "misc_Ammon", row = 2, col = 1 }
	},
	["misc_0109"] = {
		{ name = "misc_0049", row = 0, col = 0 },
		{ name = "misc_0049", row = 0, col = 1 },
		{ name = "misc_0049", row = 1, col = 0 },
		{ name = "misc_0049", row = 1, col = 1 },
		{ name = "misc_0049", row = 2, col = 0 },
		{ name = "misc_0049", row = 2, col = 1 }
	},
	["misc_0055"] = {
		{ name = "misc_0047", row = 0, col = 0 },
		{ name = "misc_0047", row = 0, col = 1 },
		{ name = "misc_0047", row = 1, col = 0 },
		{ name = "misc_0047", row = 1, col = 1 }
	},
	["misc_0056"] = {
		{ name = "misc_Ammon", row = 0, col = 0 },
		{ name = "misc_Ammon", row = 0, col = 1 },
		{ name = "misc_Ammon", row = 1, col = 0 },
		{ name = "misc_Ammon", row = 1, col = 1 }
	},
	["misc_Dumaro"] = {
		{ name = "misc_0046", row = 0, col = 0 },
		{ name = "misc_0046", row = 0, col = 1 },
		{ name = "misc_0046", row = 0, col = 2 },
		{ name = "misc_0046", row = 1, col = 0 },
		{ name = "misc_0046", row = 1, col = 1 },
		{ name = "misc_0046", row = 1, col = 2 }
	},
	["misc_0058"] = {
		{ name = "misc_0135", row = 0, col = 0 },
		{ name = "misc_0135", row = 0, col = 1 },
		{ name = "misc_0135", row = 1, col = 0 },
		{ name = "misc_0135", row = 1, col = 1 },
		{ name = "misc_0135", row = 2, col = 0 }
	},
	["misc_0059"] = {
		{ name = "misc_0025", row = 0, col = 0 },
		{ name = "misc_0025", row = 0, col = 1 },
		{ name = "misc_0025", row = 1, col = 0 },
		{ name = "misc_0025", row = 1, col = 1 }
	},
	["misc_Ticen"] = {
		{ name = "misc_0058", row = 0, col = 0 },
		{ name = "misc_0058", row = 0, col = 1 },
		{ name = "misc_0058", row = 1, col = 0 },
		{ name = "misc_0058", row = 1, col = 1 }
	},
	["misc_Tucen"] = {
		{ name = "misc_0056", row = 0, col = 0 },
		{ name = "misc_0056", row = 0, col = 1 },
		{ name = "misc_0056", row = 1, col = 0 },
		{ name = "misc_0056", row = 1, col = 1 }
	},
	["misc_0060"] = {
		{ name = "misc_Dumaro", row = 0, col = 0 },
		{ name = "misc_Dumaro", row = 0, col = 1 },
		{ name = "misc_Dumaro", row = 1, col = 0 },
		{ name = "misc_Dumaro", row = 1, col = 1 }
	},
	["misc_0061"] = {
		{ name = "misc_Ticen", row = 0, col = 0 },
		{ name = "misc_Ticen", row = 0, col = 1 },
		{ name = "misc_Ticen", row = 1, col = 0 },
		{ name = "misc_Ticen", row = 1, col = 1 },
		{ name = "misc_Ticen", row = 2, col = 0 },
		{ name = "misc_Ticen", row = 2, col = 1 }
	},
	["misc_0153"] = {
		{ name = "misc_0055", row = 0, col = 0 },
		{ name = "misc_0055", row = 0, col = 1 },
		{ name = "misc_0055", row = 1, col = 0 },
		{ name = "misc_0055", row = 1, col = 1 }
	},
	["misc_Sakmoli"] = {
		{ name = "misc_0047", row = 0, col = 0 },
		{ name = "misc_0047", row = 0, col = 1 },
		{ name = "misc_0047", row = 1, col = 0 },
		{ name = "misc_0047", row = 1, col = 1 },
		{ name = "misc_0047", row = 2, col = 0 },
		{ name = "misc_0047", row = 2, col = 1 }
	},
	["misc_0128"] = {
		{ name = "misc_0060", row = 0, col = 0 },
		{ name = "misc_0060", row = 0, col = 1 },
		{ name = "misc_0060", row = 1, col = 0 },
		{ name = "misc_0060", row = 1, col = 1 }
	},
	["misc_Repusbunny"] = {
		{ name = "misc_0153", row = 0, col = 0 },
		{ name = "misc_0153", row = 0, col = 1 },
		{ name = "misc_0153", row = 1, col = 0 },
		{ name = "misc_0153", row = 1, col = 1 }
	},
	["misc_Hallowventor"] = {
		{ name = "misc_0061", row = 0, col = 0 },
		{ name = "misc_0061", row = 0, col = 1 },
		{ name = "misc_0061", row = 1, col = 0 },
		{ name = "misc_0061", row = 1, col = 1 }
	},
	["misc_Tontulia"] = {
		{ name = "misc_Tucen", row = 0, col = 0 },
		{ name = "misc_Tucen", row = 0, col = 1 },
		{ name = "misc_Tucen", row = 1, col = 0 },
		{ name = "misc_Tucen", row = 1, col = 1 }
	},
	["misc_0062"] = {
		{ name = "misc_0128", row = 0, col = 0 },
		{ name = "misc_0128", row = 0, col = 1 },
		{ name = "misc_0128", row = 1, col = 0 },
		{ name = "misc_0128", row = 1, col = 1 }
	},
	["misc_0105"] = {
		{ name = "misc_Hallowventor", row = 0, col = 0 },
		{ name = "misc_Hallowventor", row = 0, col = 1 },
		{ name = "misc_Hallowventor", row = 1, col = 0 },
		{ name = "misc_Hallowventor", row = 1, col = 1 }
	},
	["misc_0063"] = {
		{ name = "misc_Tontulia", row = 0, col = 0 },
		{ name = "misc_Tontulia", row = 0, col = 1 },
		{ name = "misc_Tontulia", row = 1, col = 0 },
		{ name = "misc_Tontulia", row = 1, col = 1 }
	},
	["misc_Karas"] = {
		{ name = "misc_Dumaro", row = 0, col = 0 },
		{ name = "misc_Dumaro", row = 0, col = 1 },
		{ name = "misc_Dumaro", row = 1, col = 0 },
		{ name = "misc_Dumaro", row = 1, col = 1 },
		{ name = "misc_Dumaro", row = 2, col = 0 },
		{ name = "misc_Dumaro", row = 2, col = 1 }
	},
	["misc_0064"] = {
		{ name = "misc_0105", row = 0, col = 0 },
		{ name = "misc_0105", row = 0, col = 1 },
		{ name = "misc_0105", row = 1, col = 0 },
		{ name = "misc_0105", row = 1, col = 1 }
	},
	["misc_0104"] = {
		{ name = "misc_0062", row = 0, col = 0 },
		{ name = "misc_0062", row = 0, col = 1 },
		{ name = "misc_0062", row = 1, col = 0 },
		{ name = "misc_0062", row = 1, col = 1 }
	},
	["misc_0065"] = {
		{ name = "misc_Karas", row = 0, col = 0 },
		{ name = "misc_Karas", row = 0, col = 1 },
		{ name = "misc_Karas", row = 1, col = 0 },
		{ name = "misc_Karas", row = 1, col = 1 }
	},
	["misc_shtayim"] = {
		{ name = "misc_0064", row = 0, col = 0 },
		{ name = "misc_0064", row = 0, col = 1 },
		{ name = "misc_0064", row = 1, col = 0 },
		{ name = "misc_0064", row = 1, col = 1 }
	},
	["misc_0094"] = {
		{ name = "misc_0065", row = 0, col = 0 },
		{ name = "misc_0065", row = 0, col = 1 },
		{ name = "misc_0065", row = 1, col = 0 },
		{ name = "misc_0065", row = 1, col = 1 }
	},
	["misc_0093"] = {
		{ name = "misc_shtayim", row = 0, col = 0 },
		{ name = "misc_shtayim", row = 0, col = 1 },
		{ name = "misc_shtayim", row = 1, col = 0 },
		{ name = "misc_shtayim", row = 1, col = 1 }
	},
	["misc_schlesien_darkmage"] = {
		{ name = "misc_0104", row = 0, col = 0 },
		{ name = "misc_0104", row = 0, col = 1 },
		{ name = "misc_0104", row = 1, col = 0 },
		{ name = "misc_0104", row = 1, col = 1 }
	},
	["misc_0070"] = {
		{ name = "misc_0093", row = 0, col = 0 },
		{ name = "misc_0093", row = 0, col = 1 },
		{ name = "misc_0093", row = 1, col = 0 },
		{ name = "misc_0093", row = 1, col = 1 }
	},
	["misc_Haming2"] = {
		{ name = "misc_Tontulia", row = 0, col = 0 },
		{ name = "misc_Tontulia", row = 0, col = 1 },
		{ name = "misc_Tontulia", row = 1, col = 0 }
	},
	["misc_0140"] = {
		{ name = "misc_Repusbunny", row = 0, col = 0 },
		{ name = "misc_Repusbunny", row = 0, col = 1 },
		{ name = "misc_Repusbunny", row = 1, col = 0 },
		{ name = "misc_Repusbunny", row = 1, col = 1 }
	},
	["misc_0139"] = {
		{ name = "misc_schlesien_darkmage", row = 0, col = 0 },
		{ name = "misc_schlesien_darkmage", row = 0, col = 1 },
		{ name = "misc_schlesien_darkmage", row = 1, col = 0 },
		{ name = "misc_schlesien_darkmage", row = 1, col = 1 }
	},
	["misc_0155"] = {
		{ name = "misc_Haming2", row = 0, col = 0 },
		{ name = "misc_Haming2", row = 0, col = 1 },
		{ name = "misc_Haming2", row = 1, col = 0 },
		{ name = "misc_Haming2", row = 1, col = 1 }
	},
	["misc_Lizardman"] = {
		{ name = "misc_0070", row = 0, col = 0 },
		{ name = "misc_0070", row = 1, col = 0 },
		{ name = "misc_0070", row = 2, col = 0 }
	},
	["misc_0074"] = {
		{ name = "misc_0139", row = 0, col = 0 },
		{ name = "misc_0139", row = 0, col = 1 },
		{ name = "misc_0139", row = 1, col = 0 },
		{ name = "misc_0139", row = 1, col = 1 }
	},
	["misc_0075"] = {
		{ name = "misc_0070", row = 0, col = 0 },
		{ name = "misc_0070", row = 0, col = 1 },
		{ name = "misc_0070", row = 1, col = 0 },
		{ name = "misc_0070", row = 1, col = 1 }
	},
	["misc_0097"] = {
		{ name = "misc_0093", row = 0, col = 0 },
		{ name = "misc_0093", row = 1, col = 0 },
		{ name = "misc_0093", row = 2, col = 0 },
		{ name = "misc_0093", row = 2, col = 1 }
	},
	["misc_0076"] = {
		{ name = "misc_0075", row = 0, col = 0 },
		{ name = "misc_0075", row = 0, col = 1 },
		{ name = "misc_0075", row = 1, col = 0 },
		{ name = "misc_0075", row = 1, col = 1 }
	},
	["misc_Cockatries"] = {
		{ name = "misc_0140", row = 0, col = 0 },
		{ name = "misc_0140", row = 0, col = 1 },
		{ name = "misc_0140", row = 1, col = 0 },
		{ name = "misc_0140", row = 1, col = 1 }
	},
	["misc_Minos1"] = {
		{ name = "misc_Lizardman", row = 0, col = 0 },
		{ name = "misc_Lizardman", row = 0, col = 1 },
		{ name = "misc_Lizardman", row = 1, col = 0 },
		{ name = "misc_Lizardman", row = 1, col = 1 }
	},
	["misc_Stoulet"] = {
		{ name = "misc_0155", row = 0, col = 0 },
		{ name = "misc_0155", row = 0, col = 1 },
		{ name = "misc_0155", row = 1, col = 0 },
		{ name = "misc_0155", row = 1, col = 1 }
	},
	["misc_0127"] = {
		{ name = "misc_0074", row = 0, col = 0 },
		{ name = "misc_0074", row = 0, col = 1 },
		{ name = "misc_0074", row = 1, col = 0 },
		{ name = "misc_0074", row = 1, col = 1 }
	},
	["misc_Bushspider_purple"] = {
		{ name = "misc_Cockatries", row = 0, col = 0 },
		{ name = "misc_Cockatries", row = 0, col = 1 },
		{ name = "misc_Cockatries", row = 1, col = 0 },
		{ name = "misc_Cockatries", row = 1, col = 1 }
	},
	["misc_Fisherman"] = {
		{ name = "misc_Minos1", row = 0, col = 0 },
		{ name = "misc_Minos1", row = 1, col = 0 },
		{ name = "misc_Minos1", row = 2, col = 0 },
		{ name = "misc_Minos1", row = 3, col = 0 }
	},
	["misc_ellomago"] = {
		{ name = "misc_Bushspider_purple", row = 0, col = 0 },
		{ name = "misc_Bushspider_purple", row = 0, col = 1 },
		{ name = "misc_Bushspider_purple", row = 1, col = 0 },
		{ name = "misc_Bushspider_purple", row = 1, col = 1 }
	},
	["misc_0129"] = {
		{ name = "misc_0127", row = 0, col = 0 },
		{ name = "misc_0127", row = 1, col = 0 },
		{ name = "misc_0127", row = 2, col = 0 },
		{ name = "misc_0127", row = 3, col = 0 }
	},
	["misc_Bume_Goblin"] = {
		{ name = "misc_0013", row = 0, col = 0 },
		{ name = "misc_0013", row = 0, col = 1 },
		{ name = "misc_0013", row = 1, col = 0 },
		{ name = "misc_0013", row = 1, col = 1 },
		{ name = "misc_0013", row = 2, col = 0 },
		{ name = "misc_0013", row = 2, col = 1 }
	},
	["misc_arburn_pokubu_blue2"] = {
		{ name = "misc_Stoulet", row = 0, col = 0 },
		{ name = "misc_Stoulet", row = 0, col = 1 },
		{ name = "misc_Stoulet", row = 1, col = 0 },
		{ name = "misc_Stoulet", row = 1, col = 1 }
	},
	["misc_0100"] = {
		{ name = "misc_Fisherman", row = 0, col = 0 },
		{ name = "misc_Fisherman", row = 0, col = 1 },
		{ name = "misc_Fisherman", row = 1, col = 0 },
		{ name = "misc_Fisherman", row = 1, col = 1 }
	},
	["misc_0079"] = {
		{ name = "misc_arburn_pokubu_blue2", row = 0, col = 0 },
		{ name = "misc_arburn_pokubu_blue2", row = 0, col = 1 },
		{ name = "misc_arburn_pokubu_blue2", row = 1, col = 0 },
		{ name = "misc_arburn_pokubu_blue2", row = 1, col = 1 }
	},
	["misc_rublem"] = {
		{ name = "misc_Bume_Goblin", row = 0, col = 0 },
		{ name = "misc_Bume_Goblin", row = 0, col = 1 },
		{ name = "misc_Bume_Goblin", row = 1, col = 0 },
		{ name = "misc_Bume_Goblin", row = 1, col = 1 }
	},
	["misc_0080"] = {
		{ name = "misc_ellomago", row = 0, col = 0 },
		{ name = "misc_ellomago", row = 0, col = 1 },
		{ name = "misc_ellomago", row = 1, col = 0 },
		{ name = "misc_ellomago", row = 1, col = 1 }
	},
	["misc_Armory"] = {
		{ name = "misc_rublem", row = 0, col = 0 },
		{ name = "misc_rublem", row = 0, col = 1 },
		{ name = "misc_rublem", row = 1, col = 0 },
		{ name = "misc_rublem", row = 1, col = 1 }
	},
	["misc_0081"] = {
		{ name = "misc_0100", row = 0, col = 0 },
		{ name = "misc_0100", row = 0, col = 1 },
		{ name = "misc_0100", row = 1, col = 0 },
		{ name = "misc_0100", row = 1, col = 1 }
	},
	["misc_chromadog"] = {
		{ name = "misc_0129", row = 0, col = 0 },
		{ name = "misc_0129", row = 0, col = 1 },
		{ name = "misc_0129", row = 1, col = 0 },
		{ name = "misc_0129", row = 1, col = 1 }
	},
	["misc_0083"] = {
		{ name = "misc_0079", row = 0, col = 0 },
		{ name = "misc_0079", row = 0, col = 1 },
		{ name = "misc_0079", row = 1, col = 0 },
		{ name = "misc_0079", row = 1, col = 1 }
	},
	["misc_0086"] = {
		{ name = "misc_chromadog", row = 0, col = 0 },
		{ name = "misc_chromadog", row = 0, col = 1 },
		{ name = "misc_chromadog", row = 1, col = 0 },
		{ name = "misc_chromadog", row = 1, col = 1 }
	},
	["misc_minivern"] = {
		{ name = "misc_0080", row = 0, col = 0 },
		{ name = "misc_0080", row = 0, col = 1 },
		{ name = "misc_0080", row = 1, col = 0 },
		{ name = "misc_0080", row = 1, col = 1 }
	},
	["misc_0088"] = {
		{ name = "misc_0081", row = 0, col = 0 },
		{ name = "misc_0081", row = 0, col = 1 },
		{ name = "misc_0081", row = 1, col = 0 },
		{ name = "misc_0081", row = 1, col = 1 }
	},
	["misc_0132"] = {
		{ name = "misc_0083", row = 0, col = 0 },
		{ name = "misc_0083", row = 0, col = 1 },
		{ name = "misc_0083", row = 1, col = 0 },
		{ name = "misc_0083", row = 1, col = 1 }
	},
	["misc_0133"] = {
		{ name = "misc_minivern", row = 0, col = 0 },
		{ name = "misc_minivern", row = 0, col = 1 },
		{ name = "misc_minivern", row = 1, col = 0 },
		{ name = "misc_minivern", row = 1, col = 1 }
	},
	["misc_0134"] = {
		{ name = "misc_0080", row = 0, col = 0 },
		{ name = "misc_0080", row = 1, col = 0 },
		{ name = "misc_0080", row = 2, col = 0 }
	},
	["misc_0136"] = {
		{ name = "misc_0086", row = 0, col = 0 },
		{ name = "misc_0086", row = 1, col = 0 },
		{ name = "misc_0086", row = 1, col = 1 },
		{ name = "misc_0086", row = 2, col = 0 }
	},
	["misc_0137"] = {
		{ name = "misc_minivern", row = 0, col = 0 },
		{ name = "misc_minivern", row = 0, col = 1 },
		{ name = "misc_minivern", row = 1, col = 0 },
		{ name = "misc_minivern", row = 1, col = 1 },
		{ name = "misc_minivern", row = 2, col = 0 },
		{ name = "misc_minivern", row = 2, col = 1 }
	},
	["misc_0138"] = {
		{ name = "misc_0129", row = 0, col = 0 },
		{ name = "misc_0129", row = 0, col = 1 },
		{ name = "misc_0129", row = 0, col = 2 },
		{ name = "misc_0129", row = 1, col = 0 }
	},
	["misc_Infroholder"] = {
		{ name = "misc_chromadog", row = 0, col = 0 },
		{ name = "misc_chromadog", row = 1, col = 0 },
		{ name = "misc_chromadog", row = 2, col = 0 },
		{ name = "misc_chromadog", row = 3, col = 0 }
	},
	["misc_0141"] = {
		{ name = "misc_0136", row = 0, col = 0 },
		{ name = "misc_0136", row = 0, col = 1 },
		{ name = "misc_0136", row = 1, col = 0 },
		{ name = "misc_0136", row = 1, col = 1 }
	},
	["misc_Rubabos"] = {
		{ name = "misc_0137", row = 0, col = 0 },
		{ name = "misc_0137", row = 0, col = 1 },
		{ name = "misc_0137", row = 1, col = 0 },
		{ name = "misc_0137", row = 1, col = 1 }
	},
	["misc_0184"] = {
		{ name = "misc_Infroholder", row = 0, col = 0 },
		{ name = "misc_Infroholder", row = 0, col = 1 },
		{ name = "misc_Infroholder", row = 1, col = 0 },
		{ name = "misc_Infroholder", row = 1, col = 1 }
	},
	["misc_0143"] = {
		{ name = "misc_0134", row = 0, col = 0 },
		{ name = "misc_0134", row = 0, col = 1 },
		{ name = "misc_0134", row = 1, col = 0 },
		{ name = "misc_0134", row = 1, col = 1 }
	},
	["misc_0144"] = {
		{ name = "misc_0138", row = 0, col = 0 },
		{ name = "misc_0138", row = 0, col = 1 },
		{ name = "misc_0138", row = 1, col = 0 },
		{ name = "misc_0138", row = 1, col = 1 }
	},
	["misc_0149"] = {
		{ name = "misc_0141", row = 0, col = 0 },
		{ name = "misc_0141", row = 0, col = 1 },
		{ name = "misc_0141", row = 1, col = 0 },
		{ name = "misc_0141", row = 1, col = 1 }
	},
	["misc_0152"] = {
		{ name = "misc_0184", row = 0, col = 0 },
		{ name = "misc_0184", row = 0, col = 1 },
		{ name = "misc_0184", row = 1, col = 0 },
		{ name = "misc_0184", row = 1, col = 1 }
	},
	["misc_0165"] = {
		{ name = "misc_0143", row = 0, col = 0 },
		{ name = "misc_0143", row = 0, col = 1 },
		{ name = "misc_0143", row = 1, col = 0 },
		{ name = "misc_0143", row = 1, col = 1 }
	},
	["misc_0166"] = {
		{ name = "misc_0144", row = 0, col = 0 },
		{ name = "misc_0144", row = 0, col = 1 },
		{ name = "misc_0144", row = 1, col = 0 },
		{ name = "misc_0144", row = 1, col = 1 }
	},
	["misc_0168"] = {
		{ name = "misc_0149", row = 0, col = 0 },
		{ name = "misc_0149", row = 0, col = 1 },
		{ name = "misc_0149", row = 1, col = 0 },
		{ name = "misc_0149", row = 1, col = 1 }
	},
	["tree_root_mole1"] = {
		{ name = "misc_0165", row = 0, col = 0 },
		{ name = "misc_0165", row = 0, col = 1 },
		{ name = "misc_0165", row = 1, col = 0 },
		{ name = "misc_0165", row = 1, col = 1 }
	},
	["misc_0170"] = {
		{ name = "misc_0152", row = 0, col = 0 },
		{ name = "misc_0152", row = 0, col = 2 },
		{ name = "misc_0152", row = 1, col = 0 },
		{ name = "misc_0152", row = 1, col = 1 },
		{ name = "misc_0152", row = 1, col = 2 },
		{ name = "misc_0152", row = 2, col = 0 },
		{ name = "misc_0152", row = 2, col = 2 }
	},
	["misc_0156"] = {
		{ name = "misc_0166", row = 0, col = 0 },
		{ name = "misc_0166", row = 0, col = 1 },
		{ name = "misc_0166", row = 1, col = 0 },
		{ name = "misc_0166", row = 1, col = 1 }
	},
	["misc_0157"] = {
		{ name = "misc_0088", row = 0, col = 0 },
		{ name = "misc_0088", row = 0, col = 1 },
		{ name = "misc_0088", row = 1, col = 0 },
		{ name = "misc_0088", row = 1, col = 1 }
	},
	["misc_0158"] = {
		{ name = "misc_0157", row = 0, col = 0 },
		{ name = "misc_0157", row = 0, col = 1 },
		{ name = "misc_0157", row = 0, col = 2 },
		{ name = "misc_0157", row = 1, col = 0 },
		{ name = "misc_0157", row = 1, col = 1 },
		{ name = "misc_0157", row = 1, col = 2 },
		{ name = "misc_0157", row = 2, col = 0 },
		{ name = "misc_0157", row = 2, col = 1 },
		{ name = "misc_0157", row = 2, col = 2 }
	},
	["misc_0147"] = {
		{ name = "tree_root_mole1", row = 0, col = 0 },
		{ name = "tree_root_mole1", row = 0, col = 1 },
		{ name = "tree_root_mole1", row = 1, col = 0 },
		{ name = "tree_root_mole1", row = 1, col = 1 }
	},
	["misc_0161"] = {
		{ name = "misc_0158", row = 0, col = 0 },
		{ name = "misc_0158", row = 0, col = 1 },
		{ name = "misc_0158", row = 1, col = 0 },
		{ name = "misc_0158", row = 1, col = 1 }
	},
	["misc_0162"] = {
		{ name = "misc_0170", row = 0, col = 0 },
		{ name = "misc_0170", row = 0, col = 1 },
		{ name = "misc_0170", row = 1, col = 0 },
		{ name = "misc_0170", row = 1, col = 1 }
	},
	["misc_0131"] = {
		{ name = "misc_0147", row = 0, col = 0 },
		{ name = "misc_0147", row = 0, col = 1 },
		{ name = "misc_0147", row = 1, col = 0 },
		{ name = "misc_0147", row = 1, col = 1 }
	},
	["misc_0163"] = {
		{ name = "misc_0168", row = 0, col = 0 },
		{ name = "misc_0168", row = 0, col = 1 },
		{ name = "misc_0168", row = 1, col = 0 },
		{ name = "misc_0168", row = 1, col = 1 }
	},
	["misc_0164"] = {
		{ name = "misc_0162", row = 0, col = 0 },
		{ name = "misc_0162", row = 0, col = 1 },
		{ name = "misc_0162", row = 1, col = 0 },
		{ name = "misc_0162", row = 1, col = 1 }
	},
	["misc_Mushroom_boy"] = {
		{ name = "misc_0131", row = 0, col = 0 },
		{ name = "misc_0131", row = 0, col = 1 },
		{ name = "misc_0131", row = 0, col = 2 },
		{ name = "misc_0131", row = 1, col = 0 },
		{ name = "misc_0131", row = 1, col = 1 },
		{ name = "misc_0131", row = 1, col = 2 }
	},
	["misc_0171"] = {
		{ name = "misc_Mushroom_boy", row = 0, col = 0 },
		{ name = "misc_Mushroom_boy", row = 0, col = 1 },
		{ name = "misc_Mushroom_boy", row = 1, col = 0 },
		{ name = "misc_Mushroom_boy", row = 1, col = 1 }
	},
	["misc_0172"] = {
		{ name = "misc_0163", row = 0, col = 0 },
		{ name = "misc_0163", row = 0, col = 1 },
		{ name = "misc_0163", row = 1, col = 0 },
		{ name = "misc_0163", row = 1, col = 1 }
	},
	["misc_0173"] = {
		{ name = "misc_0148", row = 0, col = 0 },
		{ name = "misc_0148", row = 0, col = 1 },
		{ name = "misc_0148", row = 0, col = 2 },
		{ name = "misc_0148", row = 1, col = 0 },
		{ name = "misc_0148", row = 1, col = 1 },
		{ name = "misc_0148", row = 1, col = 2 }
	},
	["misc_0174"] = {
		{ name = "misc_0172", row = 0, col = 0 },
		{ name = "misc_0172", row = 0, col = 1 },
		{ name = "misc_0172", row = 1, col = 0 },
		{ name = "misc_0172", row = 1, col = 1 }
	},
	["misc_0175"] = {
		{ name = "misc_Mushroom_boy", row = 0, col = 0 },
		{ name = "misc_Mushroom_boy", row = 1, col = 0 },
		{ name = "misc_Mushroom_boy", row = 2, col = 0 }
	},
	["misc_0176"] = {
		{ name = "misc_0171", row = 0, col = 0 },
		{ name = "misc_0171", row = 0, col = 1 },
		{ name = "misc_0171", row = 1, col = 0 },
		{ name = "misc_0171", row = 1, col = 1 }
	},
	["misc_0178"] = {
		{ name = "misc_kowak", row = 0, col = 0 },
		{ name = "misc_kowak", row = 0, col = 1 },
		{ name = "misc_kowak", row = 1, col = 0 },
		{ name = "misc_kowak", row = 1, col = 1 }
	},
	["misc_mushroom_ent"] = {
		{ name = "misc_Mushroom_boy", row = 0, col = 0 },
		{ name = "misc_Mushroom_boy", row = 0, col = 1 },
		{ name = "misc_Mushroom_boy", row = 1, col = 0 },
		{ name = "misc_Mushroom_boy", row = 1, col = 1 },
		{ name = "misc_Mushroom_boy", row = 2, col = 0 },
		{ name = "misc_Mushroom_boy", row = 2, col = 1 }
	},
	["misc_0179"] = {
		{ name = "misc_0176", row = 0, col = 0 },
		{ name = "misc_0176", row = 1, col = 0 },
		{ name = "misc_0176", row = 2, col = 0 },
		{ name = "misc_0176", row = 3, col = 0 }
	},
	["misc_0181"] = {
		{ name = "misc_0175", row = 0, col = 0 },
		{ name = "misc_0175", row = 0, col = 1 },
		{ name = "misc_0175", row = 1, col = 0 },
		{ name = "misc_0175", row = 1, col = 1 }
	},
	["misc_0092"] = {
		{ name = "misc_0178", row = 0, col = 0 },
		{ name = "misc_0178", row = 0, col = 1 },
		{ name = "misc_0178", row = 1, col = 0 },
		{ name = "misc_0178", row = 1, col = 1 }
	},
	["misc_anchor"] = {
		{ name = "misc_0173", row = 0, col = 0 },
		{ name = "misc_0173", row = 0, col = 1 },
		{ name = "misc_0173", row = 1, col = 0 },
		{ name = "misc_0173", row = 1, col = 1 }
	},
	["misc_velffigy"] = {
		{ name = "misc_0181", row = 0, col = 0 },
		{ name = "misc_0181", row = 0, col = 1 },
		{ name = "misc_0181", row = 1, col = 0 },
		{ name = "misc_0181", row = 1, col = 1 }
	},
	["misc_glyquare"] = {
		{ name = "misc_anchor", row = 0, col = 0 },
		{ name = "misc_anchor", row = 0, col = 1 },
		{ name = "misc_anchor", row = 1, col = 0 },
		{ name = "misc_anchor", row = 1, col = 1 }
	},
	["misc_Rambear"] = {
		{ name = "misc_0179", row = 0, col = 0 },
		{ name = "misc_0179", row = 0, col = 1 },
		{ name = "misc_0179", row = 1, col = 0 },
		{ name = "misc_0179", row = 1, col = 1 }
	},
	["misc_goblin"] = {
		{ name = "misc_Bume_Goblin", row = 0, col = 0 },
		{ name = "misc_Bume_Goblin", row = 0, col = 1 },
		{ name = "misc_Bume_Goblin", row = 1, col = 0 },
		{ name = "misc_Bume_Goblin", row = 1, col = 1 },
		{ name = "misc_Bume_Goblin", row = 2, col = 0 },
		{ name = "misc_Bume_Goblin", row = 2, col = 1 }
	},
	["misc_Lemuria"] = {
		{ name = "misc_0092", row = 0, col = 0 },
		{ name = "misc_0092", row = 0, col = 1 },
		{ name = "misc_0092", row = 1, col = 0 },
		{ name = "misc_0092", row = 1, col = 1 }
	},
	["misc_0034"] = {
		{ name = "misc_0019", row = 0, col = 0 },
		{ name = "misc_0019", row = 0, col = 1 },
		{ name = "misc_0019", row = 0, col = 2 },
		{ name = "misc_0019", row = 1, col = 0 },
		{ name = "misc_0019", row = 1, col = 1 },
		{ name = "misc_0019", row = 2, col = 0 }
	},
	["misc_0047"] = {
		{ name = "misc_0034", row = 0, col = 0 },
		{ name = "misc_0034", row = 1, col = 1 },
		{ name = "misc_0034", row = 1, col = 3 },
		{ name = "misc_0034", row = 2, col = 2 },
		{ name = "misc_0034", row = 2, col = 3 },
		{ name = "misc_0034", row = 3, col = 2 }
	},
	["misc_0055"] = {
		{ name = "misc_0047", row = 0, col = 0 },
		{ name = "misc_0047", row = 1, col = 1 },
		{ name = "misc_0047", row = 1, col = 3 },
		{ name = "misc_0047", row = 2, col = 2 },
		{ name = "misc_0047", row = 2, col = 3 },
		{ name = "misc_0047", row = 3, col = 2 }
	},
	["misc_0103"] = {
		{ name = "misc_0055", row = 0, col = 0 },
		{ name = "misc_0055", row = 1, col = 1 },
		{ name = "misc_0055", row = 1, col = 3 },
		{ name = "misc_0055", row = 2, col = 2 },
		{ name = "misc_0055", row = 2, col = 3 },
		{ name = "misc_0055", row = 3, col = 2 }
	},
	["misc_0122"] = {
		{ name = "misc_0103", row = 0, col = 0 },
		{ name = "misc_0103", row = 1, col = 1 },
		{ name = "misc_0103", row = 1, col = 3 },
		{ name = "misc_0103", row = 2, col = 2 },
		{ name = "misc_0103", row = 2, col = 3 },
		{ name = "misc_0103", row = 3, col = 2 }
	},
	["misc_0128"] = {
		{ name = "misc_0122", row = 0, col = 0 },
		{ name = "misc_0122", row = 1, col = 1 },
		{ name = "misc_0122", row = 1, col = 3 },
		{ name = "misc_0122", row = 2, col = 2 },
		{ name = "misc_0122", row = 2, col = 3 },
		{ name = "misc_0122", row = 3, col = 2 }
	},
	["misc_0131"] = {
		{ name = "misc_0128", row = 0, col = 0 },
		{ name = "misc_0128", row = 1, col = 1 },
		{ name = "misc_0128", row = 1, col = 3 },
		{ name = "misc_0128", row = 2, col = 2 },
		{ name = "misc_0128", row = 2, col = 3 },
		{ name = "misc_0128", row = 3, col = 2 }
	},
	["misc_0134"] = {
		{ name = "misc_0131", row = 0, col = 0 },
		{ name = "misc_0131", row = 1, col = 1 },
		{ name = "misc_0131", row = 1, col = 3 },
		{ name = "misc_0131", row = 2, col = 2 },
		{ name = "misc_0131", row = 2, col = 3 },
		{ name = "misc_0131", row = 3, col = 2 }
	},
	["misc_0152"] = {
		{ name = "misc_0134", row = 0, col = 0 },
		{ name = "misc_0134", row = 1, col = 1 },
		{ name = "misc_0134", row = 1, col = 3 },
		{ name = "misc_0134", row = 2, col = 2 },
		{ name = "misc_0134", row = 2, col = 3 },
		{ name = "misc_0134", row = 3, col = 2 }
	},
	["misc_0155"] = {
		{ name = "misc_0152", row = 0, col = 0 },
		{ name = "misc_0152", row = 1, col = 1 },
		{ name = "misc_0152", row = 1, col = 3 },
		{ name = "misc_0152", row = 2, col = 2 },
		{ name = "misc_0152", row = 2, col = 3 },
		{ name = "misc_0152", row = 3, col = 2 }
	},
	["misc_0187"] = {
		{ name = "misc_0155", row = 0, col = 0 },
		{ name = "misc_0155", row = 1, col = 1 },
		{ name = "misc_0155", row = 1, col = 3 },
		{ name = "misc_0155", row = 2, col = 2 },
		{ name = "misc_0155", row = 2, col = 3 },
		{ name = "misc_0155", row = 3, col = 2 }
	},
	["misc_0223"] = {
		{ name = "misc_0187", row = 0, col = 0 },
		{ name = "misc_0187", row = 1, col = 1 },
		{ name = "misc_0187", row = 1, col = 3 },
		{ name = "misc_0187", row = 2, col = 2 },
		{ name = "misc_0187", row = 2, col = 3 },
		{ name = "misc_0187", row = 3, col = 2 }
	},
	["misc_0226"] = {
		{ name = "misc_0223", row = 0, col = 0 },
		{ name = "misc_0223", row = 1, col = 1 },
		{ name = "misc_0223", row = 1, col = 3 },
		{ name = "misc_0223", row = 2, col = 2 },
		{ name = "misc_0223", row = 2, col = 3 },
		{ name = "misc_0223", row = 3, col = 2 }
	},
	["misc_0269"] = {
		{ name = "misc_0226", row = 0, col = 0 },
		{ name = "misc_0226", row = 1, col = 1 },
		{ name = "misc_0226", row = 1, col = 3 },
		{ name = "misc_0226", row = 2, col = 2 },
		{ name = "misc_0226", row = 2, col = 3 },
		{ name = "misc_0226", row = 3, col = 2 }
	},
	["misc_0275"] = {
		{ name = "misc_0269", row = 0, col = 0 },
		{ name = "misc_0269", row = 1, col = 1 },
		{ name = "misc_0269", row = 1, col = 3 },
		{ name = "misc_0269", row = 2, col = 2 },
		{ name = "misc_0269", row = 2, col = 3 },
		{ name = "misc_0269", row = 3, col = 2 }
	},
	["misc_0139"] = {
		{ name = "misc_0132", row = 0, col = 0 },
		{ name = "misc_0132", row = 0, col = 1 },
		{ name = "misc_0132", row = 0, col = 2 },
		{ name = "misc_0132", row = 1, col = 0 },
		{ name = "misc_0132", row = 1, col = 2 },
		{ name = "misc_0132", row = 2, col = 0 },
		{ name = "misc_0132", row = 2, col = 1 },
		{ name = "misc_0132", row = 2, col = 2 }
	},
	["misc_0141"] = {
		{ name = "misc_0139", row = 0, col = 0 },
		{ name = "misc_0139", row = 0, col = 1 },
		{ name = "misc_0139", row = 0, col = 2 },
		{ name = "misc_0139", row = 1, col = 0 },
		{ name = "misc_0139", row = 1, col = 2 },
		{ name = "misc_0139", row = 2, col = 0 },
		{ name = "misc_0139", row = 2, col = 1 },
		{ name = "misc_0139", row = 2, col = 2 }
	},
	["misc_0162"] = {
		{ name = "misc_0141", row = 0, col = 0 },
		{ name = "misc_0141", row = 0, col = 1 },
		{ name = "misc_0141", row = 0, col = 2 },
		{ name = "misc_0141", row = 1, col = 0 },
		{ name = "misc_0141", row = 1, col = 2 },
		{ name = "misc_0141", row = 2, col = 0 },
		{ name = "misc_0141", row = 2, col = 1 },
		{ name = "misc_0141", row = 2, col = 2 }
	},
	["misc_0225"] = {
		{ name = "misc_0162", row = 0, col = 0 },
		{ name = "misc_0162", row = 0, col = 1 },
		{ name = "misc_0162", row = 0, col = 2 },
		{ name = "misc_0162", row = 1, col = 0 },
		{ name = "misc_0162", row = 1, col = 2 },
		{ name = "misc_0162", row = 2, col = 0 },
		{ name = "misc_0162", row = 2, col = 1 },
		{ name = "misc_0162", row = 2, col = 2 }
	},
	["misc_0263"] = {
		{ name = "misc_0225", row = 0, col = 0 },
		{ name = "misc_0225", row = 0, col = 1 },
		{ name = "misc_0225", row = 0, col = 2 },
		{ name = "misc_0225", row = 1, col = 0 },
		{ name = "misc_0225", row = 1, col = 2 },
		{ name = "misc_0225", row = 2, col = 0 },
		{ name = "misc_0225", row = 2, col = 1 },
		{ name = "misc_0225", row = 2, col = 2 }
	},
	["misc_0267"] = {
		{ name = "misc_0263", row = 0, col = 0 },
		{ name = "misc_0263", row = 0, col = 1 },
		{ name = "misc_0263", row = 0, col = 2 },
		{ name = "misc_0263", row = 1, col = 0 },
		{ name = "misc_0263", row = 1, col = 2 },
		{ name = "misc_0263", row = 2, col = 0 },
		{ name = "misc_0263", row = 2, col = 1 },
		{ name = "misc_0263", row = 2, col = 2 }
	},
	["misc_0041"] = {
		{ name = "misc_0020", row = 0, col = 0 },
		{ name = "misc_0020", row = 0, col = 3 },
		{ name = "misc_0020", row = 1, col = 1 },
		{ name = "misc_0020", row = 1, col = 2 },
		{ name = "misc_0020", row = 2, col = 0 },
		{ name = "misc_0020", row = 2, col = 3 }
	},
	["misc_0049"] = {
		{ name = "misc_0041", row = 0, col = 0 },
		{ name = "misc_0041", row = 0, col = 3 },
		{ name = "misc_0041", row = 1, col = 1 },
		{ name = "misc_0041", row = 1, col = 2 },
		{ name = "misc_0041", row = 2, col = 0 },
		{ name = "misc_0041", row = 2, col = 3 }
	},
	["misc_0109"] = {
		{ name = "misc_0049", row = 0, col = 0 },
		{ name = "misc_0049", row = 0, col = 3 },
		{ name = "misc_0049", row = 1, col = 1 },
		{ name = "misc_0049", row = 1, col = 2 },
		{ name = "misc_0049", row = 2, col = 0 },
		{ name = "misc_0049", row = 2, col = 3 }
	},
	["misc_0119"] = {
		{ name = "misc_0109", row = 0, col = 0 },
		{ name = "misc_0109", row = 0, col = 3 },
		{ name = "misc_0109", row = 1, col = 1 },
		{ name = "misc_0109", row = 1, col = 2 },
		{ name = "misc_0109", row = 2, col = 0 },
		{ name = "misc_0109", row = 2, col = 3 }
	},
	["misc_0138"] = {
		{ name = "misc_0119", row = 0, col = 0 },
		{ name = "misc_0119", row = 0, col = 3 },
		{ name = "misc_0119", row = 1, col = 1 },
		{ name = "misc_0119", row = 1, col = 2 },
		{ name = "misc_0119", row = 2, col = 0 },
		{ name = "misc_0119", row = 2, col = 3 }
	},
	["misc_0221"] = {
		{ name = "misc_0138", row = 0, col = 0 },
		{ name = "misc_0138", row = 0, col = 3 },
		{ name = "misc_0138", row = 1, col = 1 },
		{ name = "misc_0138", row = 1, col = 2 },
		{ name = "misc_0138", row = 2, col = 0 },
		{ name = "misc_0138", row = 2, col = 3 }
	},
	["misc_0235"] = {
		{ name = "misc_0221", row = 0, col = 0 },
		{ name = "misc_0221", row = 0, col = 3 },
		{ name = "misc_0221", row = 1, col = 1 },
		{ name = "misc_0221", row = 1, col = 2 },
		{ name = "misc_0221", row = 2, col = 0 },
		{ name = "misc_0221", row = 2, col = 3 }
	},
	["misc_0149"] = {
		{ name = "misc_0147", row = 0, col = 0 },
		{ name = "misc_0147", row = 0, col = 1 },
		{ name = "misc_0147", row = 0, col = 3 },
		{ name = "misc_0147", row = 1, col = 2 },
		{ name = "misc_0147", row = 2, col = 1 },
		{ name = "misc_0147", row = 2, col = 3 },
		{ name = "misc_0147", row = 3, col = 1 },
		{ name = "misc_0147", row = 3, col = 2 }
	},
	["misc_0222"] = {
		{ name = "misc_0149", row = 0, col = 0 },
		{ name = "misc_0149", row = 0, col = 1 },
		{ name = "misc_0149", row = 0, col = 3 },
		{ name = "misc_0149", row = 1, col = 2 },
		{ name = "misc_0149", row = 2, col = 1 },
		{ name = "misc_0149", row = 2, col = 3 },
		{ name = "misc_0149", row = 3, col = 1 },
		{ name = "misc_0149", row = 3, col = 2 }
	},
	["misc_0229"] = {
		{ name = "misc_0222", row = 0, col = 0 },
		{ name = "misc_0222", row = 0, col = 1 },
		{ name = "misc_0222", row = 0, col = 3 },
		{ name = "misc_0222", row = 1, col = 2 },
		{ name = "misc_0222", row = 2, col = 1 },
		{ name = "misc_0222", row = 2, col = 3 },
		{ name = "misc_0222", row = 3, col = 1 },
		{ name = "misc_0222", row = 3, col = 2 }
	},
	["misc_0232"] = {
		{ name = "misc_0229", row = 0, col = 0 },
		{ name = "misc_0229", row = 0, col = 1 },
		{ name = "misc_0229", row = 0, col = 3 },
		{ name = "misc_0229", row = 1, col = 2 },
		{ name = "misc_0229", row = 2, col = 1 },
		{ name = "misc_0229", row = 2, col = 3 },
		{ name = "misc_0229", row = 3, col = 1 },
		{ name = "misc_0229", row = 3, col = 2 }
	},
	["misc_0236"] = {
		{ name = "misc_0232", row = 0, col = 0 },
		{ name = "misc_0232", row = 0, col = 1 },
		{ name = "misc_0232", row = 0, col = 3 },
		{ name = "misc_0232", row = 1, col = 2 },
		{ name = "misc_0232", row = 2, col = 1 },
		{ name = "misc_0232", row = 2, col = 3 },
		{ name = "misc_0232", row = 3, col = 1 },
		{ name = "misc_0232", row = 3, col = 2 }
	},
	["misc_0237"] = {
		{ name = "misc_0236", row = 0, col = 0 },
		{ name = "misc_0236", row = 0, col = 1 },
		{ name = "misc_0236", row = 0, col = 3 },
		{ name = "misc_0236", row = 1, col = 2 },
		{ name = "misc_0236", row = 2, col = 1 },
		{ name = "misc_0236", row = 2, col = 3 },
		{ name = "misc_0236", row = 3, col = 1 },
		{ name = "misc_0236", row = 3, col = 2 }
	},
	["misc_0260"] = {
		{ name = "misc_0237", row = 0, col = 0 },
		{ name = "misc_0237", row = 0, col = 1 },
		{ name = "misc_0237", row = 0, col = 3 },
		{ name = "misc_0237", row = 1, col = 2 },
		{ name = "misc_0237", row = 2, col = 1 },
		{ name = "misc_0237", row = 2, col = 3 },
		{ name = "misc_0237", row = 3, col = 1 },
		{ name = "misc_0237", row = 3, col = 2 }
	},
	["misc_0278"] = {
		{ name = "misc_0260", row = 0, col = 0 },
		{ name = "misc_0260", row = 0, col = 1 },
		{ name = "misc_0260", row = 0, col = 3 },
		{ name = "misc_0260", row = 1, col = 2 },
		{ name = "misc_0260", row = 2, col = 1 },
		{ name = "misc_0260", row = 2, col = 3 },
		{ name = "misc_0260", row = 3, col = 1 },
		{ name = "misc_0260", row = 3, col = 2 }
	},
	["misc_0027"] = {
		{ name = "misc_0012", row = 0, col = 0 },
		{ name = "misc_0012", row = 0, col = 1 },
		{ name = "misc_0012", row = 1, col = 2 },
		{ name = "misc_0012", row = 2, col = 1 },
		{ name = "misc_0012", row = 3, col = 1 }
	},
	["misc_0054"] = {
		{ name = "misc_0027", row = 0, col = 0 },
		{ name = "misc_0027", row = 0, col = 1 },
		{ name = "misc_0027", row = 1, col = 2 },
		{ name = "misc_0027", row = 2, col = 1 },
		{ name = "misc_0027", row = 3, col = 1 }
	},
	["misc_0072"] = {
		{ name = "misc_0054", row = 0, col = 0 },
		{ name = "misc_0054", row = 0, col = 1 },
		{ name = "misc_0054", row = 1, col = 2 },
		{ name = "misc_0054", row = 2, col = 1 },
		{ name = "misc_0054", row = 3, col = 1 }
	},
	["misc_0080"] = {
		{ name = "misc_0072", row = 0, col = 0 },
		{ name = "misc_0072", row = 0, col = 1 },
		{ name = "misc_0072", row = 1, col = 2 },
		{ name = "misc_0072", row = 2, col = 1 },
		{ name = "misc_0072", row = 3, col = 1 }
	},
	["misc_0144"] = {
		{ name = "misc_0080", row = 0, col = 0 },
		{ name = "misc_0080", row = 0, col = 1 },
		{ name = "misc_0080", row = 1, col = 2 },
		{ name = "misc_0080", row = 2, col = 1 },
		{ name = "misc_0080", row = 3, col = 1 }
	},
	["misc_0166"] = {
		{ name = "misc_0144", row = 0, col = 0 },
		{ name = "misc_0144", row = 0, col = 1 },
		{ name = "misc_0144", row = 1, col = 2 },
		{ name = "misc_0144", row = 2, col = 1 },
		{ name = "misc_0144", row = 3, col = 1 }
	},
	["misc_0176"] = {
		{ name = "misc_0166", row = 0, col = 0 },
		{ name = "misc_0166", row = 0, col = 1 },
		{ name = "misc_0166", row = 1, col = 2 },
		{ name = "misc_0166", row = 2, col = 1 },
		{ name = "misc_0166", row = 3, col = 1 }
	},
	["misc_0212"] = {
		{ name = "misc_0176", row = 0, col = 0 },
		{ name = "misc_0176", row = 0, col = 1 },
		{ name = "misc_0176", row = 1, col = 2 },
		{ name = "misc_0176", row = 2, col = 1 },
		{ name = "misc_0176", row = 3, col = 1 }
	},
	["misc_0216"] = {
		{ name = "misc_0212", row = 0, col = 0 },
		{ name = "misc_0212", row = 0, col = 1 },
		{ name = "misc_0212", row = 1, col = 2 },
		{ name = "misc_0212", row = 2, col = 1 },
		{ name = "misc_0212", row = 3, col = 1 }
	},
	["misc_0266"] = {
		{ name = "misc_0216", row = 0, col = 0 },
		{ name = "misc_0216", row = 0, col = 1 },
		{ name = "misc_0216", row = 1, col = 2 },
		{ name = "misc_0216", row = 2, col = 1 },
		{ name = "misc_0216", row = 3, col = 1 }
	},
	["misc_0270"] = {
		{ name = "misc_0266", row = 0, col = 0 },
		{ name = "misc_0266", row = 0, col = 1 },
		{ name = "misc_0266", row = 1, col = 2 },
		{ name = "misc_0266", row = 2, col = 1 },
		{ name = "misc_0266", row = 3, col = 1 }
	},
	["misc_0028"] = {
		{ name = "misc_0022", row = 0, col = 0 },
		{ name = "misc_0022", row = 0, col = 1 },
		{ name = "misc_0022", row = 1, col = 2 },
		{ name = "misc_0022", row = 2, col = 1 },
		{ name = "misc_0022", row = 3, col = 1 }
	},
	["misc_0201"] = {
		{ name = "misc_0028", row = 0, col = 0 },
		{ name = "misc_0028", row = 0, col = 1 },
		{ name = "misc_0028", row = 1, col = 2 },
		{ name = "misc_0028", row = 2, col = 1 },
		{ name = "misc_0028", row = 3, col = 1 }
	},
	["misc_0205"] = {
		{ name = "misc_0201", row = 0, col = 0 },
		{ name = "misc_0201", row = 0, col = 1 },
		{ name = "misc_0201", row = 1, col = 2 },
		{ name = "misc_0201", row = 2, col = 1 },
		{ name = "misc_0201", row = 3, col = 1 }
	},
	["misc_0175"] = {
		{ name = "misc_0130", row = 0, col = 0 },
		{ name = "misc_0130", row = 0, col = 1 },
		{ name = "misc_0130", row = 1, col = 2 },
		{ name = "misc_0130", row = 2, col = 1 },
		{ name = "misc_0130", row = 3, col = 1 }
	},
	["misc_0177"] = {
		{ name = "misc_0175", row = 0, col = 0 },
		{ name = "misc_0175", row = 0, col = 1 },
		{ name = "misc_0175", row = 1, col = 2 },
		{ name = "misc_0175", row = 2, col = 1 },
		{ name = "misc_0175", row = 3, col = 1 }
	},
	["misc_0208"] = {
		{ name = "misc_0177", row = 0, col = 0 },
		{ name = "misc_0177", row = 0, col = 1 },
		{ name = "misc_0177", row = 1, col = 2 },
		{ name = "misc_0177", row = 2, col = 1 },
		{ name = "misc_0177", row = 3, col = 1 }
	},
	["misc_0083"] = {
		{ name = "misc_0018", row = 0, col = 0 },
		{ name = "misc_0018", row = 0, col = 1 },
		{ name = "misc_0018", row = 2, col = 1 },
		{ name = "misc_0018", row = 3, col = 1 },
		{ name = "misc_0018", row = 3, col = 2 },
		{ name = "misc_0018", row = 4, col = 1 }
	},
	["misc_0100"] = {
		{ name = "misc_0083", row = 0, col = 0 },
		{ name = "misc_0083", row = 0, col = 1 },
		{ name = "misc_0083", row = 2, col = 1 },
		{ name = "misc_0083", row = 3, col = 1 },
		{ name = "misc_0083", row = 3, col = 2 },
		{ name = "misc_0083", row = 4, col = 1 }
	},
	["misc_0102"] = {
		{ name = "misc_0100", row = 0, col = 0 },
		{ name = "misc_0100", row = 0, col = 1 },
		{ name = "misc_0100", row = 2, col = 1 },
		{ name = "misc_0100", row = 3, col = 1 },
		{ name = "misc_0100", row = 3, col = 2 },
		{ name = "misc_0100", row = 4, col = 1 }
	},
	["misc_0159"] = {
		{ name = "misc_0102", row = 0, col = 0 },
		{ name = "misc_0102", row = 0, col = 1 },
		{ name = "misc_0102", row = 2, col = 1 },
		{ name = "misc_0102", row = 3, col = 1 },
		{ name = "misc_0102", row = 3, col = 2 },
		{ name = "misc_0102", row = 4, col = 1 }
	},
	["misc_0192"] = {
		{ name = "misc_0159", row = 0, col = 0 },
		{ name = "misc_0159", row = 0, col = 1 },
		{ name = "misc_0159", row = 2, col = 1 },
		{ name = "misc_0159", row = 3, col = 1 },
		{ name = "misc_0159", row = 3, col = 2 },
		{ name = "misc_0159", row = 4, col = 1 }
	},
	["misc_0210"] = {
		{ name = "misc_0192", row = 0, col = 0 },
		{ name = "misc_0192", row = 0, col = 1 },
		{ name = "misc_0192", row = 2, col = 1 },
		{ name = "misc_0192", row = 3, col = 1 },
		{ name = "misc_0192", row = 3, col = 2 },
		{ name = "misc_0192", row = 4, col = 1 }
	},
	["misc_0215"] = {
		{ name = "misc_0210", row = 0, col = 0 },
		{ name = "misc_0210", row = 0, col = 1 },
		{ name = "misc_0210", row = 2, col = 1 },
		{ name = "misc_0210", row = 3, col = 1 },
		{ name = "misc_0210", row = 3, col = 2 },
		{ name = "misc_0210", row = 4, col = 1 }
	},
	["misc_0218"] = {
		{ name = "misc_0215", row = 0, col = 0 },
		{ name = "misc_0215", row = 0, col = 1 },
		{ name = "misc_0215", row = 2, col = 1 },
		{ name = "misc_0215", row = 3, col = 1 },
		{ name = "misc_0215", row = 3, col = 2 },
		{ name = "misc_0215", row = 4, col = 1 }
	},
	["misc_0231"] = {
		{ name = "misc_0218", row = 0, col = 0 },
		{ name = "misc_0218", row = 0, col = 1 },
		{ name = "misc_0218", row = 2, col = 1 },
		{ name = "misc_0218", row = 3, col = 1 },
		{ name = "misc_0218", row = 3, col = 2 },
		{ name = "misc_0218", row = 4, col = 1 }
	},
	["misc_0234"] = {
		{ name = "misc_0231", row = 0, col = 0 },
		{ name = "misc_0231", row = 0, col = 1 },
		{ name = "misc_0231", row = 2, col = 1 },
		{ name = "misc_0231", row = 3, col = 1 },
		{ name = "misc_0231", row = 3, col = 2 },
		{ name = "misc_0231", row = 4, col = 1 }
	},
	["misc_0246"] = {
		{ name = "misc_0234", row = 0, col = 0 },
		{ name = "misc_0234", row = 0, col = 1 },
		{ name = "misc_0234", row = 2, col = 1 },
		{ name = "misc_0234", row = 3, col = 1 },
		{ name = "misc_0234", row = 3, col = 2 },
		{ name = "misc_0234", row = 4, col = 1 }
	},
	["misc_0247"] = {
		{ name = "misc_0246", row = 0, col = 0 },
		{ name = "misc_0246", row = 0, col = 1 },
		{ name = "misc_0246", row = 2, col = 1 },
		{ name = "misc_0246", row = 3, col = 1 },
		{ name = "misc_0246", row = 3, col = 2 },
		{ name = "misc_0246", row = 4, col = 1 }
	},
	["misc_0268"] = {
		{ name = "misc_0247", row = 0, col = 0 },
		{ name = "misc_0247", row = 0, col = 1 },
		{ name = "misc_0247", row = 2, col = 1 },
		{ name = "misc_0247", row = 3, col = 1 },
		{ name = "misc_0247", row = 3, col = 2 },
		{ name = "misc_0247", row = 4, col = 1 }
	},
	["misc_0271"] = {
		{ name = "misc_0268", row = 0, col = 0 },
		{ name = "misc_0268", row = 0, col = 1 },
		{ name = "misc_0268", row = 2, col = 1 },
		{ name = "misc_0268", row = 3, col = 1 },
		{ name = "misc_0268", row = 3, col = 2 },
		{ name = "misc_0268", row = 4, col = 1 }
	},
	["egg_008"] = {
		{ name = "misc_quicksilver", row = 0, col = 0 },
		{ name = "misc_0011", row = 0, col = 1 },
		{ name = "misc_0236", row = 0, col = 2 },
		{ name = "misc_whip_vine_ra2", row = 1, col = 2 },
		{ name = "misc_0244", row = 1, col = 3 },
		{ name = "misc_yekubite3", row = 1, col = 4 },
		{ name = "misc_Fire_Dragon2", row = 2, col = 3 },
		{ name = "misc_goldbar", row = 3, col = 3 },
		{ name = "misc_talt", row = 4, col = 2 },
		{ name = "misc_seedOil", row = 4, col = 3 },
		{ name = "misc_hanaming2", row = 4, col = 4 },
		{ name = "misc_Dumaro", row = 6, col = 1 },
		{ name = "misc_liena_pants_1", row = 6, col = 3 },
		{ name = "rsc_2_1", row = 6, col = 5 },
		{ name = "misc_icepiece", row = 6, col = 7 }
	},
	["misc_quicksilver"] = {
		{ name = "misc_silverbar", row = 0, col = 0 },
		{ name = "misc_silverbar", row = 0, col = 1 },
		{ name = "misc_silverbar", row = 1, col = 0 },
		{ name = "misc_silverbar", row = 3, col = 1 },
		{ name = "misc_silverbar", row = 2, col = 2 }
	},
	["misc_0011"] = {
		{ name = "OnionPiece_Red", row = 0, col = 0 },
		{ name = "OnionPiece_Red", row = 0, col = 2 },
		{ name = "OnionPiece_Red", row = 1, col = 1 },
		{ name = "OnionPiece_Red", row = 2, col = 0 },
		{ name = "OnionPiece_Red", row = 2, col = 2 }
	},
	["misc_whip_vine_ra2"] = {
		{ name = "misc_popolion3", row = 0, col = 0 },
		{ name = "misc_popolion3", row = 0, col = 1 },
		{ name = "misc_popolion3", row = 0, col = 2 },
		{ name = "misc_popolion3", row = 0, col = 3 }
	},
	["misc_0244"] = {
		{ name = "misc_0196", row = 0, col = 0 },
		{ name = "misc_0196", row = 0, col = 2 },
		{ name = "misc_0196", row = 1, col = 3 },
		{ name = "misc_0196", row = 2, col = 4 },
		{ name = "misc_0196", row = 3, col = 3 },
		{ name = "misc_0196", row = 4, col = 1 }
	},
	["misc_yekubite3"] = {
		{ name = "misc_yekubite2", row = 0, col = 0 },
		{ name = "misc_yekubite2", row = 0, col = 1 },
		{ name = "misc_yekubite2", row = 2, col = 1 },
		{ name = "misc_yekubite2", row = 3, col = 1 },
		{ name = "misc_yekubite2", row = 3, col = 2 },
		{ name = "misc_yekubite2", row = 4, col = 1 }
	},
	["misc_Fire_Dragon2"] = {
		{ name = "misc_0079", row = 0, col = 0 },
		{ name = "misc_0079", row = 0, col = 1 },
		{ name = "misc_0079", row = 2, col = 1 },
		{ name = "misc_0079", row = 3, col = 1 },
		{ name = "misc_0079", row = 3, col = 2 },
		{ name = "misc_0079", row = 3, col = 5 }
	},
	["misc_goldbar"] = {
		{ name = "misc_talt", row = 0, col = 0 },
		{ name = "misc_talt", row = 0, col = 1 },
		{ name = "misc_talt", row = 1, col = 0 },
		{ name = "misc_talt", row = 1, col = 1 },
		{ name = "misc_talt", row = 2, col = 0 },
		{ name = "misc_talt", row = 2, col = 1 },
		{ name = "misc_talt", row = 3, col = 0 },
		{ name = "misc_talt", row = 3, col = 1 },
		{ name = "misc_talt", row = 4, col = 0 },
		{ name = "misc_talt", row = 4, col = 1 }
	},
	["misc_talt"] = {
		{ name = "misc_goldbar", row = 0, col = 0 },
		{ name = "misc_goldbar", row = 3, col = 3 }
	},
	["misc_seedOil"] = {
		{ name = "misc_seedmia", row = 0, col = 0 },
		{ name = "misc_seedmia", row = 1, col = 1 },
		{ name = "misc_seedmia", row = 2, col = 2 }
	},
	["misc_hanaming2"] = {
		{ name = "leaf_hanaming", row = 0, col = 0 },
		{ name = "leaf_hanaming", row = 0, col = 4 },
		{ name = "leaf_hanaming", row = 1, col = 1 },
		{ name = "leaf_hanaming", row = 1, col = 3 },
		{ name = "leaf_hanaming", row = 2, col = 2 }
	},
	["misc_liena_pants_1"] = {
		{ name = "misc_0135", row = 0, col = 0 },
		{ name = "misc_0135", row = 0, col = 1 },
		{ name = "misc_0135", row = 1, col = 1 },
		{ name = "misc_0135", row = 2, col = 1 },
		{ name = "misc_0135", row = 3, col = 0 },
		{ name = "misc_0135", row = 3, col = 2 }
	},
	["rsc_2_1"] = {
		{ name = "misc_mud", row = 0, col = 0 },
		{ name = "misc_mud", row = 1, col = 1 },
		{ name = "misc_mud", row = 2, col = 0 },
		{ name = "misc_mud", row = 2, col = 1 },
		{ name = "misc_mud", row = 2, col = 2 }
	},
	["misc_icepiece"] = {
		{ name = "Drug_holywater", row = 0, col = 0 },
		{ name = "Drug_holywater", row = 0, col = 1 },
		{ name = "Drug_holywater", row = 1, col = 0 },
		{ name = "Drug_holywater", row = 1, col = 1 }
	}
}


-- テキストリソース
local ResText = {
	jp = {
		Common = {
			PercentMark = "％"
		},
		ForTitle = {
			RegisteredInTheJournal = "{b}作成経験あり{/}"
		  , UnregisteredInTheJournal = "{b}未作成{/}"
		  , DropsFrom = "{b}アイテムドロップ率：{/}"
		  , FoundMob = "討伐経験あり"
		  , UnfoundMob = "未討伐"
		  , ObtainedCount = "アイテム取得数："
		  , RerollPrice = "キューブ再開封費用："
		  , MagnumOpusCommon = "マグナムオーパス情報"
		  , MagnumOpusFrom = "{b}このアイテムを作るには{/}"
		  , MagnumOpusInto = "{b}このアイテムを使うレシピ{/}"
		  , Mark_UsingXML = " {#229900}{s14}{ol}{b}[xml]{/}{/}{/}{/}"
		  , Close = "閉じる"
		},
		Other = {
			ToggleOpusMap = "{nl}{s6} {/}{nl}{b}  Shiftキーで配置を表示します{/}"
		  , NPCRepair = "NPCで修理"
		  , SquireRepair = "修理露店で修理"
		  , RepairCheaperCommon = "{s14}{b}%sしたほうが安い{/}{/}{s24} {/}"
		  , OtherItems = "    他%s種 ..."
		},
		SettingFrame = {
			CannotGetSettingFrameHandle = "設定画面のハンドルが取得できませんでした"
			, SettingFrameTitle = "Tooltip Helperの設定"
			, Save = "保存"
			, CloseMe = "閉じる"
			, LangTitle = "Language (言語)"
			, Japanese = "Japanese (日本語)"
			, English = "English"
			, DisplayTitle = "表示設定"
			, showCollection = "コレクション"
			, showCompletedCollection = "完成しているコレクションも表示"
			, showRecipe = "アイテム製造書"
			, showRecipeHaveNeedCount = "所持数/必要数を表示"
			, showItemDropRatio = "ドロップ率"
			, UseAutoImportDropData = "外部ファイル(dropdata.tsv)の自動読み込みを行う"
			, showMagnumOpus = "マグナムオーパス"
			, AllwaysDisplayOpusMap_From = "変換元のアイテム配置を常に表示する"
			, AllwaysDisplayOpusMap_Into = "変換先のアイテム配置を常に表示する"
			, useRecipePuzzleXML = "外部ファイル(recipe_puzzle.xml)の読み込みを行う"
			, showJournalStats = "アイテム取得数"
			, showRepairRecommendation = "推奨する修理手段"
			, repairPrice_title = "修理露店の基本修理価格"
			, UseOriginalBgSkin = "背景の透明度を下げる"
		  },
		System = {
			ErrorToUseDefaults = "設定の読み込みでエラーが発生したのでデフォルトの設定を使用します。"
		  , CompleteLoadDefault = "デフォルトの設定の読み込みが完了しました。"
		  , CompleteLoadSettings = "設定の読み込みが完了しました"
		  , ExecuteCommands = "コマンド '{#333366}%s{/}' が呼び出されました"
		  , ResetSettings = "設定をリセットしました。"
		  , InvalidCommand = "無効なコマンドが呼び出されました"
		  , AnnounceCommandList = "コマンド一覧を見るには[ %s ? ]を用いてください"
		  , FailToLoadXMLSimple = "エラー：xmlSimpleの読み込みに失敗しました"
		  , NotFoundMagnumOpusXML = "'recipe_puzzle.xml' は検出されませんでした"
		  , FoundMagnumOpusXML = "'recipe_puzzle.xml' を検出しました"
		  , StartImportDropData = "'dropdata.tsv'の読み込みを開始します。この処理では10秒弱画面がフリーズします。"
		  , NotFoundDropDataXML = "'dropdata.xml' は検出されませんでした"
		  , FoundDropDataXML = "'dropdata.xml' を検出しました"
		  , CompleteImportDropDataXML = "'dropdata.xml' の読み込みが完了しました"
		  , NotFoundDropDataTSV = "'dropdata.tsv' は検出されませんでした"
		  , FoundDropDataTSV = "'dropdata.tsv' を検出しました"
		  , CompleteImportDropDataTSV = "'dropdata.tsv' の読み込みが完了しました"
		}
	},
	en = {
		Common = {
			PercentMark = "%"
		},
		ForTitle = {
			RegisteredInTheJournal = "Registered"
		  , UnregisteredInTheJournal = "Unregistered"
		  , DropsFrom = "Drops From:"
		  , FoundMob = "Encountered"
		  , UnfoundMob = "Not yet encountered"
		  , ObtainedCount = "Obtained Count : "
		  , RerollPrice = "Reroll Price : "
		  , MagnumOpusCommon = "Magnum Opus Info."
		  , MagnumOpusFrom = "Transmuted From:"
		  , MagnumOpusInto = "Transmutes Into:"
		  , Mark_UsingXML = " {#229900}{s14}{ol}[ XML ]{/}{/}{/}"
		  , Close = "Close"
		},
		Other = {
			ToggleOpusMap = "{nl}{s6} {/}{nl}    Press 'Shift' to show details."
		  , NPCRepair = "NPC"
		  , SquireRepair = "Squire"
		  , RepairCheaperCommon = "Repair at: %s"
		  , OtherItems = "         %s other items ..."
		},
		  SettingFrame = {
			CannotGetSettingFrameHandle = "Failed to get the handle of setting dialog."
		  , SettingFrameTitle = "Settings  -Tooltip Helper-"
		  , Save = "Save"
		  , CloseMe = "Close"
		  , LangTitle = "Language (言語)"
		  , Japanese = "Japanese (日本語)"
		  , English = "English"
		  , DisplayTitle = "Display Settings"
		  , showCollection = "Collection"
		  , showCompletedCollection = "Also show completed collections"
		  , showRecipe = "Recipe"
		  , showRecipeHaveNeedCount = "Display possession / required number"
		  , showItemDropRatio = "Drop ratio"
		  , UseAutoImportDropData = "Automatically read the external file (dropdata.tsv)."
		  , showMagnumOpus = "Magnum Opus"
		  , AllwaysDisplayOpusMap_From = "Always display the item placement : Transmuted From"
		  , AllwaysDisplayOpusMap_Into = "Always display the item placement : Transmutes Into"
		  , useRecipePuzzleXML = "Use external file (recipe_puzzle.xml)"
		  , showJournalStats = "Obtained Count"
		  , showRepairRecommendation = "Recommended repair methods"
		  , repairPrice_title = "Basic repair price of repair stalls"
		  , UseOriginalBgSkin = "Decrease the transparency of the background"
		},
		System = {
			ErrorToUseDefaults = "Using default settings because an error occurred while loading the settings."
		  , CompleteLoadDefault = "Default settings loaded."
		  , CompleteLoadSettings = "Settings loaded!"
		  , ExecuteCommands = "Command '{#333366}%s{/}' was called."
		  , ResetSettings = "Settings resetted."
		  , InvalidCommand = "Invalid command called."
		  , AnnounceCommandList = "Please use [ %s ? ] to see the command list."
		  , FailToLoadXMLSimple = "Error: Unable to load xmlSimple"
		  , NotFoundMagnumOpusXML = "Magnum Opus recipe file not found"
		  , FoundMagnumOpusXML = "Magnum Opus recipe file was found"
		  , StartImportDropData = "Start loading 'dropdata.tsv'. In this process, the screen freezes up for about 10 seconds."
		  , NotFoundDropDataXML = "'dropdata.xml' is not found"
		  , FoundDropDataXML = "found 'dropdata.xml'"
		  , CompleteImportDropDataXML = "Import of 'dropdata.xml' is completed"
		  , NotFoundDropDataTSV = "'dropdata.tsv' is not found"
		  , FoundDropDataTSV = "found 'dropdata.tsv'"
		  , CompleteImportDropDataTSV = "Import of 'dropdata.tsv' is completed"
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
			local Index = KeyList[i]
			obj = obj[Index];
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

-- ノードオブジェクト(XMLパーサーで使用)
local function CreateNode(name)
    local objNode = {}
    objNode.___value = nil
    objNode.___name = name
    objNode.___children = {}
    objNode.___attrs = {}

    function objNode:value() return self.___value end
    function objNode:setValue(val) self.___value = val end
    function objNode:name() return self.___name end
    function objNode:setName(name) self.___name = name end
    function objNode:children() return self.___children end
    function objNode:numChildren() return #self.___children end
    function objNode:addChild(child)
        if self[child:name()] ~= nil then
            if type(self[child:name()].name) == "function" then
                local tmpTable = {}
                table.insert(tmpTable, self[child:name()])
                self[child:name()] = tmpTable
            end
            table.insert(self[child:name()], child)
        else
            self[child:name()] = child
        end
        table.insert(self.___children, child)
    end

    function objNode:attributes() return self.___attrs end
    function objNode:numAttributes() return #self.___attrs end
    function objNode:addAttribute(name, value)
        local lName = "@" .. name
        if self[lName] ~= nil then
            if type(self[lName]) == "string" then
                local tmpTable = {}
                table.insert(tmpTable, self[lName])
                self[lName] = tmpTable
            end
            table.insert(self[lName], value)
        else
            self[lName] = value
        end
        table.insert(self.___attrs, { name = name, value = self[name] })
    end

    return objNode
end

-- XMLパーサー
local function CreateXMLParser()

    XmlParser = {};

    function XmlParser:FromXmlString(value)
        value = string.gsub(value, "&#x([%x]+)%;",
            function(h)
                return string.char(tonumber(h, 16))
            end);
        value = string.gsub(value, "&#([0-9]+)%;",
            function(h)
                return string.char(tonumber(h, 10))
            end);
        value = string.gsub(value, "&quot;", "\"");
        value = string.gsub(value, "&apos;", "'");
        value = string.gsub(value, "&gt;", ">");
        value = string.gsub(value, "&lt;", "<");
        value = string.gsub(value, "&amp;", "&");
        return value;
    end

    function XmlParser:ParseArgs(node, s)
        string.gsub(s, "(%w+)=([\"'])(.-)%2", function(w, _, a)
            node:addAttribute(w, self:FromXmlString(a))
        end)
    end

    function XmlParser:ParseXmlText(xmlText)
        local stack = {}
        local top = CreateNode()
        table.insert(stack, top)
        local ni, c, label, xarg, empty
        local i, j = 1, 1
        while true do
            ni, j, c, label, xarg, empty = string.find(xmlText, "<(%/?)([%w_:]+)(.-)(%/?)>", i)
            if not ni then break end
            local text = string.sub(xmlText, i, ni - 1);
            if not string.find(text, "^%s*$") then
                local lVal = (top:value() or "") .. self:FromXmlString(text)
                stack[#stack]:setValue(lVal)
            end
            if empty == "/" then -- empty element tag
                local lNode = CreateNode(label)
                self:ParseArgs(lNode, xarg)
                top:addChild(lNode)
            elseif c == "" then -- start tag
                local lNode = CreateNode(label)
                self:ParseArgs(lNode, xarg)
                table.insert(stack, lNode)
                top = lNode
            else -- end tag
                local toclose = table.remove(stack) -- remove top

                top = stack[#stack]
                if #stack < 1 then
                    error("XmlParser: nothing to close with " .. label)
                end
                if toclose:name() ~= label then
                    error("XmlParser: trying to close " .. toclose.name .. " with " .. label)
                end
                top:addChild(toclose)
            end
            i = j + 1
        end
        local text = string.sub(xmlText, i);
        if #stack > 1 then
            error("XmlParser: unclosed " .. stack[#stack]:name());
        end
        return top
    end

    function XmlParser:loadFile(xmlFilename)
        local path = xmlFilename;
        local hFile, err = io.open(path, "r");

        if hFile and not err then
            local xmlText = hFile:read("*a"); -- read file content
            io.close(hFile);
            return self:ParseXmlText(xmlText), nil;
        else
            print(err);
            return nil;
        end
    end

    return XmlParser;
end


local function log(value)
	Toukibi:Log(value);
end
local function view(objValue)
	local frame = ui.GetFrame("developerconsole");
	if frame ~= nil then
		--DEVELOPERCONSOLE_PRINT_TEXT("{#444444}type of {#005500}"  .. objName .. "{/} is {#005500}" .. type(objValue) .. "{/}{/}", "white_16_ol");
		DEVELOPERCONSOLE_PRINT_TEXT("{nl} ")
		DEVELOPERCONSOLE_PRINT_VALUE(frame, "", objValue, "", nil, true);
	end
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
local function ContainsKey(tbl, key)
    for k, v in pairs (tbl) do
        if k==key then return true end
    end
    return false
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
ShowInitializeMessage();

-- ***** 定数の宣言 *****
local labelColor = "2D281F"; -- 9D8C70
local subLabelColor = "AAFFAA";
local completeColor = "00FF00";
local commonColor = "EEEEEE"; -- FFFFFF
local npcColor = "FF4040";
local squireColor = "40FF40";
local unregisteredColor = "444444"; -- 7B7B7B
local commonMobColor = "1f100b";
local foundBossColor = "665555";
local unFoundBossColor = "663333";
local collectionIcon = "icon_item_box";
local strSeparator = "{s6}{img fulldgray 200 1} {/}{nl}"
local strIntoImage = "{img white_right_arrow 12 14}"

-- ***** 変数の宣言と設定 *****
Me.SettingFilePathName = string.format("../addons/%s/%s", addonNameLower, SettingFileName);
Me.MagnumOpusRecipeFileName = string.format("../addons/%s/%s", addonNameLower, MagnumOpusRecipeFileName);
Me.Loaded = false;
Me.ApplicationsList = {};
Me.UsingXMLRecipeData = false;
Me.DropXMLData = Me.DropXMLData or {};

-- 設定書き込み
local function SaveSetting()
	Toukibi:SaveTable(Me.SettingFilePathName, Me.Settings);
end

-- デフォルト設定(ForceがTrueでない場合は、既存の値はそのまま引き継ぐ)
local function MargeDefaultSetting(Force, DoSave)
	DoSave = Toukibi:GetValueOrDefault(DoSave, true);
	Me.Settings = Me.Settings or {};
	Me.Settings.DoNothing					 = Toukibi:GetValueOrDefault(Me.Settings.DoNothing						, false, Force);
	Me.Settings.Lang						 = Toukibi:GetValueOrDefault(Me.Settings.Lang							, Toukibi:GetDefaultLangCode(), Force);
	Me.Settings.showCollectionCustomTooltips = Toukibi:GetValueOrDefault(Me.Settings.showCollectionCustomTooltips	, true, Force);
	Me.Settings.showCompletedCollections	 = Toukibi:GetValueOrDefault(Me.Settings.showCompletedCollections		, true, Force);
	Me.Settings.showRecipeCustomTooltips	 = Toukibi:GetValueOrDefault(Me.Settings.showRecipeCustomTooltips		, true, Force);
	Me.Settings.showRecipeHaveNeedCount		 = Toukibi:GetValueOrDefault(Me.Settings.showRecipeHaveNeedCount		, true, Force);
	Me.Settings.showMagnumOpus				 = Toukibi:GetValueOrDefault(Me.Settings.showMagnumOpus					, true, Force);
	Me.Settings.AllwaysDisplayOpusMap_From	 = Toukibi:GetValueOrDefault(Me.Settings.AllwaysDisplayOpusMap_From		, true, Force);
	Me.Settings.AllwaysDisplayOpusMap_Into	 = Toukibi:GetValueOrDefault(Me.Settings.AllwaysDisplayOpusMap_Into		, false, Force);
	Me.Settings.useRecipePuzzleXML			 = Toukibi:GetValueOrDefault(Me.Settings.useRecipePuzzleXML				, false, Force);
	Me.Settings.showItemDropRatio			 = Toukibi:GetValueOrDefault(Me.Settings.showItemDropRatio				, true, Force);
	Me.Settings.showItemLevel				 = Toukibi:GetValueOrDefault(Me.Settings.showItemLevel					, true, Force);
	Me.Settings.showJournalStats			 = Toukibi:GetValueOrDefault(Me.Settings.showJournalStats				, true, Force);
	Me.Settings.showRepairRecommendation	 = Toukibi:GetValueOrDefault(Me.Settings.showRepairRecommendation		, true, Force);
	Me.Settings.squireRepairPerKit			 = Toukibi:GetValueOrDefault(Me.Settings.squireRepairPerKit				, 140, Force); -- 160 is the minimum for the Squire to break even
	Me.Settings.UseOriginalBgSkin			 = Toukibi:GetValueOrDefault(Me.Settings.UseOriginalBgSkin				, true, Force);
	Me.Settings.UseAutoImportDropData		 = Toukibi:GetValueOrDefault(Me.Settings.UseAutoImportDropData			, false, Force);
	
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

local function GetItemGrade(itemObj)
	local grade = itemObj.ItemGrade;

	if (itemObj.ItemType == "Recipe") then
		local recipeGrade = tonumber(itemObj.Icon:match("misc(%d)")) - 1;
		if (recipeGrade <= 0) then recipeGrade = 1 end;
		grade = recipeGrade;
	end
	return grade;
end

local function GetItemRarityColor(itemObj)
	local itemProp = geItemTable.GetProp(itemObj.ClassID);
	local grade = GetItemGrade(itemObj);

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

local function GetCommaedTextEx(value, MaxTextLen, AfterTheDecimalPointLen, usePlusMark, AddSpaceAfterSign)
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
			if Me.Settings.Lang == "jp" and IntegerPartValue == 0 and DecimalPartValue == 0 then
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

function Me.GetItemMaxCount(invItem)
	if invItem.ItemType == 'Equip' then    
		local cntCls = GetClass('AdventureBookConst', 'GET_EQUIP_ITEM_GRADE_COUNT');
		return GetClass('AdventureBookConst', 'GET_EQUIP_ITEM_GRADE' .. cntCls.Value).Value;
	else
		local gradeCntCls = GetClass('AdventureBookConst', 'GET_ITEM_GRADE_COUNT');
		return GetClass('AdventureBookConst', 'GET_ITEM_GRADE' .. gradeCntCls.Value).Value;
	end
end

function Me.LoadMagnumOpusRecipeFromXML()
	local xmlMagnumOpus = CreateXMLParser():loadFile(Me.MagnumOpusRecipeFileName);
	if xmlMagnumOpus == nil then
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.NotFoundMagnumOpusXML"), "Caution", true, false);
		return;
	else
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.FoundMagnumOpusXML"), "Notice", true, false);
	end

	MagnumOpusRecipes = {};
	Me.UsingXMLRecipeData = true;
	local RecipeList = xmlMagnumOpus["Recipe_Puzzle"]:children();

	for i = 1, #RecipeList do
		local Recipe = RecipeList[i];
		local TargetItemClassName = Recipe["@TargetItem"];
		local ingredients = Recipe:children();
		MagnumOpusRecipes[TargetItemClassName] = {};
		for j = 1, #ingredients do
			local ingredient = ingredients[j];
			local ingredientItemClassName = ingredient["@Name"];
			local row = ingredient["@Row"];
			local column = ingredient["@Col"];
			table.insert(MagnumOpusRecipes[TargetItemClassName], {name = ingredientItemClassName
																, row = tonumber(row)
																, col = tonumber(column)
																 });
		end
	end
end

function Me.ImportDropData(ShowMessage)
	local ImportFilePathName = string.format("../addons/%s/%s", addonNameLower, "dropdata.tsv");

	if ShowMessage then
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.FoundDropDataTSV"), "Notice", true, false);
	end

	local hFile, err = io.open(ImportFilePathName, "r");

	if hFile and not err then
		Me.DropXMLData = {};

		local StartNum, EndNum, DropMobID, DropRatio, ItemClassName;
		for rawText in hFile:lines() do
			StartNum, EndNum, DropMobID, DropRatio, ItemClassName = string.find(rawText, "^(%d+)\t(%d+)\t([%w_]+)$");
			if StartNum then
				table.insert(Me.DropXMLData, {Item = ItemClassName
											, MobID = tonumber(DropMobID)
											, Ratio = tonumber(DropRatio)
											});
			
			else
				log(string.format( "Error has occured:  MobID=%s Ratio=%s Item=%s", DropMobID, DropRatio, ItemClassName));
			end
		end

		io.close(hFile);
	else
		if ShowMessage then
			Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.NotFoundDropDataTSV"), "Caution", true, false);
		end
	end

	--view(Me.DropXMLData)
	if ShowMessage then
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.CompleteImportDropDataTSV"), "Notice", true, false);
	end

	Me.CreateDropRatioListFromXmlData()
end

function TOUKIBI_TTHELPER_START_IMPORT()
	Me.ImportDropData(true)
end

-- ===========================
--      作業用リスト作成
-- ===========================

function Me.CreateApplicationsList_Collection()
	Me.ApplicationsList.Collection = {};
	local ClassType = 'Collection'
	local tblTarget = Me.ApplicationsList[ClassType];
	local clsList, cnt = GetClassList(ClassType);
	for i = 0 , cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		local DoneList = {};
		for j = 1 , 9 do
			local item = GetClass("Item", cls["ItemName_" .. j]);
			if item == "None" or item == nil
							  or item.NotExist == 'YES'
							  or item.ItemType == 'Unused'
							  or item.GroupName == 'Unused' then

				break;
			end
			local itemClassName = item.ClassName;
			if tblTarget[itemClassName] == nil then
				tblTarget[itemClassName] = {};
			end

			if not ContainsKey(DoneList, itemClassName) then
				DoneList[itemClassName] = 1;
			else
				DoneList[itemClassName] = DoneList[itemClassName] + 1;
			end
		end
		for itemClassName, Count in pairs(DoneList) do
			table.insert(tblTarget[itemClassName],	 {Index = i
													, Count = Count
													 });
		end
	end
	-- log('Collection Finish!!')
end

function Me.CreateApplicationsList_Recipe()
	Me.ApplicationsList.Recipe = {};
	local ClassTypeList = {"Recipe", "Recipe_ItemCraft", "ItemTradeShop"};
	local tblTarget = Me.ApplicationsList.Recipe;
	for _, ClassType in ipairs(ClassTypeList) do
		local clsList, cnt = GetClassList(ClassType);
		for i = 0 , cnt - 1 do
			local cls = GetClassByIndexFromList(clsList, i);
			local DoneList = {};
			local TargetItemID = TryGetProp(cls, 'TargetItem');
			-- 制作先アイテムが書いてあるか確かめる
			if TargetItemID ~= nil and TargetItemID ~= "None" then
				local clsNewItem = GetClass("Item", TargetItemID);
				-- 制作先アイテムが存在するか確かめる
				if clsNewItem ~= nil then
					-- log(cls.ClassID .. ":" .. clsNewItem.Name)
					for j = 1 , 5 do
						local item = GetClass("Item", cls["Item_" .. j .. "_1"]);

						if item == nil  or item.NotExist == 'YES'
										or item.ItemType == 'Unused'
										or item.GroupName == 'Unused' then

							break;
						end

						local itemClassName = item.ClassName;
						-- log(j .. ":" .. itemClassName)
						if tblTarget[itemClassName] == nil then
							tblTarget[itemClassName] = {};
						end

						if not ContainsKey(DoneList, itemClassName) then
							table.insert(DoneList, itemClassName);
							table.insert(tblTarget[itemClassName],	 {ClassType = ClassType
																	, Index = i
																	, Pos = j
																	, ResultItem = TargetItemID
																	});
						end
					end
				else
					-- log(cls.ClassID .. ":" .. TargetItemID)
				end
			end
		end
	end
	-- log('Recipe Finish!!')
end

function Me.CreateDropRatioListFromXmlData()
	if Me.DropXMLData == nil then return end;
	Me.ApplicationsList.DropRatio = {};
	local tblTarget = Me.ApplicationsList.DropRatio;

	for _, value in ipairs(Me.DropXMLData) do
		local clsMob = GetClassByType("Monster", value.MobID)
		if clsMob ~= nil then
			local itemClassName = value.Item;
			local DropRatio = value.Ratio;

			if tblTarget[itemClassName] == nil then
				tblTarget[itemClassName] = {};
			end

			local MobClassID = clsMob.ClassID;
			local MobClassName = clsMob.ClassName;
			local MobName = dictionary.ReplaceDicIDInCompStr(clsMob.Name);
			local MobLv = clsMob.Level;
			local MobRank = clsMob.MonRank;

			local isNewMob = true;
			
			--[[
			for k = 1, #tblTarget[itemClassName] do
				if tblTarget[itemClassName][k].ClassName == MobClassName and tblTarget[itemClassName][k].DropRatio == DropRatio then
					isNewMob = false;
					break
				end
			end
			--]]
			if isNewMob then
				table.insert(tblTarget[itemClassName],	 {ClassID = MobClassID
														, ClassName = MobClassName
														, Name = MobName
														, DropRatio = DropRatio
														, Rank = string.upper(MobRank)
														, Lv = MobLv
														})
			end
		else
			-- log("Cannot found MobID:" .. value.MobID)
		end
	end
	--view(tblTarget)
	--log("Build data from XML is Completed")
end

function Me.CreateDropRatioList()
	Me.ApplicationsList.DropRatio = {};
	if GetClassCount("MonsterDropItemList_Onion") < 0 and Me.DropXMLData ~= nil then
		Me.CreateDropRatioListFromXmlData()
		return;
	end
	local tblTarget = Me.ApplicationsList.DropRatio;
	local clsList, cnt = GetClassList("Monster");
	for i = 0 , cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		local DoneList = {};
		if cls.Faction == "Monster" and cls.GroupName == "Monster" then
			local dropID = cls.DropItemList;
			if dropID ~= nil and dropID ~= "None" then
				local dropID = 'MonsterDropItemList_' .. dropID;
				local dropClassCount = GetClassCount(dropID);
				if dropClassCount ~= nil and dropClassCount > 0 then
					local MobClassID = cls.ClassID;
					local MobClassName = cls.ClassName;
					local MobName = dictionary.ReplaceDicIDInCompStr(cls.Name);
					local MobLv = cls.Level;
					local MobRank = cls.MonRank;
					for j = 0, dropClassCount - 1 do
						local dropIES = GetClassByIndex(dropID, j);
						if dropIES ~= nil and dropIES.GroupName == 'Item' then
							local itemClassName = dropIES.ItemClassName;
							if tblTarget[itemClassName] == nil then
								tblTarget[itemClassName] = {};
							end

							local DropRatio = dropIES.DropRatio;
							local isNewMob = true;
							
							for k = 1, #tblTarget[itemClassName] do
								if tblTarget[itemClassName][k].ClassName == MobClassName and tblTarget[itemClassName][k].DropRatio == DropRatio then
									isNewMob = false;
									break
								end
							end

							if isNewMob then
								table.insert(tblTarget[itemClassName],	 {ClassID = MobClassID
																		, ClassName = MobClassName
																		, Name = MobName
																		, DropRatio = DropRatio
																		, Rank = string.upper(MobRank)
																		, Lv = MobLv
																		 })
							end
						end
					end
				end
			end
		end
	end
	-- log('Drop Ratio Finish!!')
end

-- ===========================
--         テキスト作成
-- ===========================

function Me.GetBasicInfoText(invItem)
	local ResultText = ""
	if Me.Settings.showJournalStats and invItem.Journal then
		local curCount = GetItemObtainCount(pc, invItem.ClassID);
		local maxCount = 0;
		maxCount = Me.GetItemMaxCount(invItem)
		if string.len(ResultText) > 0 then
			ResultText = ResultText .. "{nl}";
		end
		local TextColor = commonColor;
		if curCount >= maxCount then
			TextColor = completeColor;
		end
		ResultText = ResultText .. string.format("{s14}{b}%s{#%s}%s/%s{/}{/}{/}", Toukibi:GetResText(ResText, Me.Settings.Lang, "ForTitle.ObtainedCount"), TextColor, curCount, maxCount)
	end
	if invItem.GroupName == "Cube" then
		local rerollPrice = TryGet(invItem, "NumberArg1")
		if rerollPrice > 0 then
			if string.len(ResultText) > 0 then
				ResultText = ResultText .. "{nl}";
			end
			ResultText = ResultText .. string.format("%s%s", Toukibi:GetResText(ResText, Me.Settings.Lang, "ForTitle.RerollPrice"), GetCommaedText(rerollPrice))
		end
	end
	if Me.Settings.showRepairRecommendation and invItem.ItemType == "Equip" and invItem.Reinforce_Type == 'Moru' then
		local _, RequireCount = ITEMBUFF_NEEDITEM_Squire_Repair(nil, invItem)
		local strTemp, TextColor = Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.NPCRepair"), npcColor;
		if RequireCount * tonumber(Me.Settings.squireRepairPerKit) < GET_REPAIR_PRICE(invItem, 0) then
			strTemp = Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.SquireRepair");
			TextColor = squireColor;
		end
		strTemp = Toukibi:GetStyledText(strTemp, {"#" .. TextColor});
		if string.len(ResultText) > 0 then
			ResultText = ResultText .. "{nl}";
		end
		ResultText = ResultText .. string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.RepairCheaperCommon"), strTemp);
	end
	ResultText = Toukibi:GetStyledText(ResultText, {"#" .. commonColor, "ol"});
	ResultText = ResultText .. "{nl}{s6} {/}";
	-- log(ResultText)
	return ResultText;
end

function Me.GetCollectionText(invItem)
	if not Me.Settings.showCollectionCustomTooltips then
		return "";
	end
	-- 使用先リストが無い場合は再作成する
	if Me.ApplicationsList.Collection == nil then
		Me.CreateApplicationsList_Collection()
	end
	-- log(string.format("%s (%s)", invItem.ClassName, invItem.Name));

	-- 使用先リストに該当アイテムがあるかを調べる
	local MatchList = Me.ApplicationsList.Collection[invItem.ClassName];
	if MatchList == nil then
		return "";
	end

	local clsList, cnt = GetClassList("Collection");
	local MyCollectionList = session.GetMySession():GetCollection();
	local ResultList = {};
	for i, MatchData in ipairs(MatchList) do
		-- 該当のコレクションのデータを取得する
		local TargetCollection = GetClassByIndexFromList(clsList, MatchData.Index);
		local MyCollection = MyCollectionList:Get(TargetCollection.ClassID);
		local NowCount, MaxCount = -1 , 0;
		local isCompleted = false;
		local hasRegistered = false;

		if MyCollection ~= nil then
			NowCount, MaxCount = GET_COLLECTION_COUNT(MyCollection.type, MyCollection);
			if NowCount >= MaxCount then
				isCompleted = true;
			end
			hasRegistered = true;
		end
		if not isCompleted or Me.Settings.showCompletedCollections then
			local CurrentCount = 0;
			if hasRegistered then
				CurrentCount = MyCollection:GetItemCountByType(GetClass("Item", invItem.ClassName).ClassID);
			end

			local CollectionName = dictionary.ReplaceDicIDInCompStr(TargetCollection.Name);
			if option.GetCurrentCountry() == "Japanese" then
				CollectionName = string.gsub(CollectionName, "コレクション:", "");
				CollectionName = string.gsub(CollectionName, "コレクション：", "");
			elseif option.GetCurrentCountry() == "Korean" then
				CollectionName = string.gsub(CollectionName, "Collection: ", "");
			else
				CollectionName = string.gsub(CollectionName, "Collection: ", "");
			end

			local CollectionText = string.format("%s (%s/%s)", CollectionName, CurrentCount, MatchData.Count);
			local TextStyle = {"#" .. unregisteredColor, "s15"}
			if isCompleted then
				TextStyle = {"#" .. completeColor, "b", "ol", "ds", "s15"}
			elseif hasRegistered then
				TextStyle = {"#" .. commonColor, "b", "ol", "ds", "s15"}
			end
			CollectionText = Toukibi:GetStyledText(CollectionText, TextStyle);
			CollectionText = "{img " .. collectionIcon .. " 24 24}" .. CollectionText;
			table.insert(ResultList	, {Name = CollectionName
									, Text = CollectionText
									});
		end
	end
	-- ソートを行う
	table.sort(ResultList,	function(a, b)
								return a.Name < b.Name
							end)
	-- 出力するテキストを生成する
	local ResultText = "";
	for i, value in ipairs(ResultList) do
		if string.len(ResultText) > 0 then
			ResultText = ResultText .. "{nl}";
		end
		ResultText = ResultText .. value.Text;
	end
	-- ResultText = Toukibi:GetStyledText(ResultText, {"#" .. labelColor, "ol", "ds", "s15"});
	-- log(ResultText)
	return ResultText;
end

local function GetEquipInvCount(itemClsName)
	if itemClsName == nil or itemClsName == "" or itemClsName == "None" then
		return 0;
	end
	local invItemList = session.GetInvItemList();
	local retTable = {Value = 0};
	FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem, retTable, itemClsName)
			if invItem ~= nil then
				local objItem = GetIES(invItem:GetObject());
				if objItem.ClassName == itemClsName then
					retTable.Value = retTable.Value + 1;
				end
			end
		end, false, retTable, itemClsName);
	return retTable.Value;
end

function Me.GetRecipeText(invItem)
	if not Me.Settings.showRecipeCustomTooltips then
		return "";
	end
	-- 使用先リストが無い場合は再作成する
	if Me.ApplicationsList.Recipe == nil then
		Me.CreateApplicationsList_Recipe()
	end
	-- log(string.format("%s (%s)", invItem.ClassName, invItem.Name));

	-- 使用先リストに該当アイテムがあるかを調べる
	local MatchList = Me.ApplicationsList.Recipe[invItem.ClassName];
	if MatchList == nil then
		return "";
	end
	local invItemIsRecipe = false;
	if IS_RECIPE_ITEM(invItem) ~= 0 then
		invItemIsRecipe = true
	end

	local HaveCount = 0;
	if invItem.ItemType == "Equip" then
		HaveCount = GetEquipInvCount(invItem.ClassName)
	elseif session.GetInvItemByName(invItem.ClassName) == nil then
		HaveCount = 0;
	else
		HaveCount = session.GetInvItemByName(invItem.ClassName).count;
	end

	local ResultList = {};
	for i, MatchData in ipairs(MatchList) do
		-- 該当のレシピアイテムのデータを取得する
		local TargetRecipe = GetClassByIndexFromList(GetClassList(MatchData.ClassType), MatchData.Index);
		if TargetRecipe ~= nil then
			local ResultItem = GetClass("Item", TargetRecipe.TargetItem);

			local NeedCount = 1;
			if invItemIsRecipe then
				NeedCount = 1;
			else
				-- 一番大本の取得方法
				-- NeedCount = GET_RECIPE_MATERIAL_INFO(TargetRecipe, MatchData.Pos);

				-- GET_RECIPE_MATERIAL_INFO 内での取得方法
				local clsName = "Item_"..MatchData.Pos.."_1";
				local itemName = TargetRecipe[clsName];
				if itemName ~= "None" then
					-- 必要数の取得
					NeedCount = GET_RECIPE_REQITEM_CNT(TargetRecipe, clsName);
				else
					NeedCount = 1;
				end
			end
			
			--log(MatchData.ClassType)
			-- 現在レシピをもっているか
			local HasRecipe = false;
			if MatchData.ClassType == "Recipe" and session.GetInvItemByName(TargetRecipe.ClassName) then
				HasRecipe = true;
			elseif MatchData.ClassType == "Recipe_ItemCraft" then
				HasRecipe = true;
			end

			-- 作成経験はあるか
			local isCrafted = false;
			if ADVENTURE_BOOK_CRAFT_CONTENT.EXIST_IN_HISTORY(ResultItem.ClassID) == 1 then
				isCrafted = true;
			end

			-- イベントアイテムであるか
			local isEventItem = false;
			if string.find(string.lower(TargetRecipe.ClassName), "event") then
				isEventItem = true;
			end

			local strTemp = "";
			if isCrafted then
				strTemp = "(C) "
			elseif HasRecipe then
				strTemp = "(H) "
			end

			local RecipeColor = GetItemRarityColor(ResultItem);
			local TextStyle = {"ol", "s15", "b"};
			if not HasRecipe then
				RecipeColor = unregisteredColor;
				TextStyle = {"s15"};
			end
			local RecipeItemText = string.format("{img %s 24 24}%s"	, TargetRecipe.Icon
																	, Toukibi:GetStyledText(dictionary.ReplaceDicIDInCompStr(ResultItem.Name), {"#" .. RecipeColor})
																	);
			
			local CountText = "";
			if Me.Settings.showRecipeHaveNeedCount then
				local CountColor = RecipeColor;
				if not HasRecipe then
					CountColor = unregisteredColor;
				else
					if invItem.ItemType ~= "Recipe" and HaveCount >= NeedCount then
						CountColor = completeColor;
					end
				end
				CountText = Toukibi:GetStyledText(string.format("  (%s/%s)", HaveCount, NeedCount), {"#" .. CountColor});
			end

			local grade = GetItemGrade(ResultItem);
			if grade == 'None' or grade == nil then
				grade = 0;
			end

	-- log(string.format("  --> %s%s%s", strTemp, RecipeItemText, CountText));
			table.insert(ResultList	, {isCrafted = isCrafted
									, ItemGrade = grade
									, EventRecipe = isEventItem
									, Name = dictionary.ReplaceDicIDInCompStr(ResultItem.Name)
									, Text = Toukibi:GetStyledText(string.format("%s%s", RecipeItemText, CountText), TextStyle)
										});
		end
	end

	-- ソートを行う
	table.sort(ResultList,	function(a, b)
								if a.isCrafted ~= b.isCrafted then
									if a.isCrafted then
										return true
									end
									return false
								end
								if a.EventRecipe ~= b.EventRecipe then
									if a.EventRecipe then
										return false
									end
									return true
								end
								if a.ItemGrade ~= b.ItemGrade then
									return a.ItemGrade < b.ItemGrade
								end
								return a.Name < b.Name
							end)

	
	-- 出力するテキストを生成する
	local ResultText = "{nl}";
	local prevIsCrafted = nil;
	local ItemCount = 0;
	for i, value in ipairs(ResultList) do
		ItemCount = ItemCount + 1;
		if ItemCount > 30 then 
			ResultText = ResultText .. "{nl}{s4} {/}{nl}" .. Toukibi:GetStyledText(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.OtherItems"), #ResultList - 30), {"#FFFFFF", "s15", "ol", "ds"});
			break;
		end
		if prevIsCrafted ~= value.isCrafted then
			local strSplitter = "";
			if value.isCrafted then
				strSplitter = Toukibi:GetResText(ResText, Me.Settings.Lang, "ForTitle.RegisteredInTheJournal");
			else
				strSplitter = Toukibi:GetResText(ResText, Me.Settings.Lang, "ForTitle.UnregisteredInTheJournal");
			end
			strSplitter = Toukibi:GetStyledText(strSplitter, {"#" .. subLabelColor, "s12", "ol"});
			strSplitter = "{nl}{s6} {/}{nl}" .. strSplitter .. "{nl}" .. strSeparator;
			if string.len(ResultText) > 0 then
				ResultText = ResultText .. "{nl}";
			end
			ResultText = ResultText .. strSplitter;
		end
		ResultText = ResultText .. "{nl}" .. value.Text;
		prevIsCrafted = value.isCrafted;
	end
	ResultText = Toukibi:GetStyledText(ResultText, {"#" .. labelColor});

	-- log(ResultText);
	return ResultText;
end

function Me.GetDropRatioText(invItem)
	if not Me.Settings.showItemDropRatio then
		return "";
	end
	-- 使用先リストが無い場合は再作成する
	if Me.ApplicationsList.DropRatio == nil then
		Me.CreateDropRatioList()
	end
	-- log(string.format("%s (%s)", invItem.ClassName, invItem.Name));

	-- 使用先リストに該当アイテムがあるかを調べる
	local MatchList = Me.ApplicationsList.DropRatio[invItem.ClassName];
	if MatchList == nil then
		return "";
	end

	local ResultList = {};
	for i, MatchData in ipairs(MatchList) do
		local isFound = ADVENTURE_BOOK_MONSTER_CONTENT.EXIST_IN_HISTORY(MatchData.ClassID);
		local DropRatioText = GetCommaedTextEx(tonumber(MatchData.DropRatio) / 100, 7, 2);
		local IsBossText = "";
		if MatchData.Rank == "BOSS" then
			IsBossText = " Boss";
		end
		local MobText = string.format("%s%s  %s (Lv.%s%s)", DropRatioText, Toukibi:GetResText(ResText, Me.Settings.Lang, "Common.PercentMark"), MatchData.Name, MatchData.Lv, IsBossText);

		local TextColor = unregisteredColor;
		local TextStyle = {"ol", "s14"}
		--if isFound ~= 0 then
			if MatchData.Rank == "BOSS" then
				TextColor = foundBossColor;
			else
				TextColor = commonMobColor;
			end
			TextStyle = {"#" .. TextColor, "s14"}
		--[[
		else
			if MatchData.Rank == "BOSS" then
				TextColor = unFoundBossColor
			else
				TextColor = unregisteredColor;
			end
			TextStyle = {"#" .. TextColor, "s14"}
		end
		]]

		MobText = Toukibi:GetStyledText(MobText .. "{s18} {/}", TextStyle)
		table.insert(ResultList, {isFound = (isFound ~= 0)
								, isBoss = (MatchData.Rank == "BOSS")
								, Lv = MatchData.Lv
								, DropRatio = MatchData.DropRatio
								, Name = MatchData.Name
								, Text = MobText
								 });
	end
	-- ソートを行う
	table.sort(ResultList,	function(a, b)
		if a.isBoss ~= b.isBoss then
			if b.isBoss then
				return true
			end
			return false
		end
		if a.DropRatio == b.DropRatio then
			if a.Lv == b.Lv then
				return a.Name < b.Name
			end
			return a.Lv < b.Lv
		end
		return a.DropRatio > b.DropRatio
	end)

	-- 出力するテキストを生成する
	local ResultText = "{nl}";
	local prevIsFound = nil;
	for i, value in ipairs(ResultList) do
		ResultText = ResultText .. "{nl}" .. value.Text;
		prevIsFound = value.isFound;
	end
	ResultText = "{s20} {/}{nl}" .. Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "ForTitle.DropsFrom"), {"s15", "ol", "ds", "#AAAAFF"}) .. "{nl}{s6} {/}" .. ResultText
	ResultText = Toukibi:GetStyledText(ResultText, {"#" .. labelColor});
	-- log(ResultText);
	return ResultText;
end

local function GetMagnumOpusMap(ItemList)
	local ListCount = #ItemList;
	
	local MaxRow, MaxCol = 0, 0;
	for i = 1, ListCount do
		MaxRow = math.max(MaxRow, ItemList[i].row);
		MaxCol = math.max(MaxCol, ItemList[i].col);
	end
	
	local MapText = "";
	local BlankIcon = "nomalitem_tooltip_bg";
	for NowRow = 0, MaxRow + 1 do
		MapText = MapText .. "{nl}    "
		for NowCol = 0, MaxCol + 1 do
			local IconName = BlankIcon;

			if NowCol <= MaxCol then
				for i = 1, ListCount do
					if ItemList[i].row == NowRow and ItemList[i].col == NowCol then
						local clsItem = GetClass("Item", ItemList[i].name)
						IconName = clsItem.Icon
						break;
					end
				end
			end
			
			MapText = MapText .. "{img " .. IconName .. " 24 24}{/}"
		end
	end
	-- log(MapText)
	return MapText
end

function Me.GetMagnumOpusFromText(invItem, showRecipeMap)
	if not Me.Settings.showMagnumOpus then
		return "", false;
	end
	-- log(string.format("%s (%s)", invItem.ClassName, invItem.Name));

	-- 使用先リストに該当アイテムがあるかを調べる
	local MatchList = MagnumOpusRecipes[invItem.ClassName];
	if MatchList == nil then
		return "", false;
	end

	local ListCount = #MatchList;
	
	local AggregatedItemList = {};
	for i = 1, #MatchList do
		local ItemClassName = MatchList[i].name;
		
		if AggregatedItemList[ItemClassName] == nil then
			AggregatedItemList[ItemClassName] = 1;
		else
			local intTemp = AggregatedItemList[ItemClassName];
			AggregatedItemList[ItemClassName] = intTemp + 1;
		end
	end
	
	local AggregatedText = "";
	for ItemClassName, Quantity in pairs(AggregatedItemList) do
		local clsItem = GetClass("Item", ItemClassName);
		local ItemName = dictionary.ReplaceDicIDInCompStr(clsItem.Name);
		if string.len(AggregatedText) > 0 then
			AggregatedText = AggregatedText .. "{nl}";
		end
		AggregatedText = AggregatedText .. string.format("{img %s 24 24} %s  x %s", clsItem.Icon, dictionary.ReplaceDicIDInCompStr(clsItem.Name), Quantity);
	end
	local strXMLMark = "";
	if Me.UsingXMLRecipeData then
		strXMLMark = Toukibi:GetResText(ResText, Me.Settings.Lang, "ForTitle.Mark_UsingXML")
	end
	local ResultText = "{S6} {/}{nl}";
	ResultText = ResultText .. Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "ForTitle.MagnumOpusFrom"), {"s12", "#" .. subLabelColor, "ol"}) .. strXMLMark .. "{nl}" .. strSeparator;
	ResultText = ResultText .. Toukibi:GetStyledText(AggregatedText, {"ol", "ds", "s15"});
	if Me.Settings.AllwaysDisplayOpusMap_From or showRecipeMap then
		ResultText = ResultText .. GetMagnumOpusMap(MatchList);
	end
	if not Me.Settings.AllwaysDisplayOpusMap_From and not showRecipeMap then
		ResultText = ResultText .. Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.ToggleOpusMap"), {"s12", "#" .. labelColor})
	end
	-- log(ResultText)
	return ResultText, true;
end

function Me.GetMagnumOpusIntoText(invItem, showRecipeMap)
	if not Me.Settings.showMagnumOpus then
		return "", false;
	end
	-- log(string.format("%s (%s)", invItem.ClassName, invItem.Name));

	-- 使用先リストに該当アイテムがあるかを調べる
	local MatchList = {};
	for TargetItemClassName, ItemList in pairs(MagnumOpusRecipes) do
		for i = 1, #ItemList do
			if ItemList[i].name == invItem.ClassName then
				if MatchList[TargetItemClassName] == nil then
					MatchList[TargetItemClassName] = 1;
				else
					local intTemp = MatchList[TargetItemClassName]
					MatchList[TargetItemClassName] = intTemp + 1;
				end
			end
		end
	end
	if Toukibi:GetTableLen(MatchList) == 0 then
		return "", false;
	end

	local ResultText = "";
	for TargetItemClassName, Quantity in pairs(MatchList) do
		local className = k;
		local qty = v;
		local clsResultItem = GetClass("Item", TargetItemClassName);
		if string.len(ResultText) > 0 then
			ResultText = ResultText .. "{nl}";
				if showRecipeMap then
					ResultText = ResultText .. "{S6} {/}{nl}";
				end
			end
		ResultText = ResultText .. string.format(Toukibi:GetStyledText("{img %s 24 24} x %s{s6} %s {/}{img %s 24 24} %s", {"ol", "ds", "s15"})
												, invItem.Icon
												, Quantity
												, strIntoImage
												, clsResultItem.Icon
												, dictionary.ReplaceDicIDInCompStr(clsResultItem.Name)
												);
		if Me.Settings.AllwaysDisplayOpusMap_Into or showRecipeMap then
			ResultText = ResultText .. GetMagnumOpusMap(MagnumOpusRecipes[TargetItemClassName]);
		end
	end
	local strXMLMark = "";
	if Me.UsingXMLRecipeData then
		strXMLMark = Toukibi:GetResText(ResText, Me.Settings.Lang, "ForTitle.Mark_UsingXML")
	end
	ResultText = "{S6} {/}{nl}" .. Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "ForTitle.MagnumOpusInto"), {"s12", "#" .. subLabelColor, "ol"}) .. strXMLMark .. "{nl}" .. strSeparator .. ResultText;
	if not Me.Settings.AllwaysDisplayOpusMap_Into and not showRecipeMap then
		ResultText = ResultText .. Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "Other.ToggleOpusMap"), {"s12", "#" .. labelColor})
	end
	-- log(ResultText)
	return ResultText, true;
end

function Me.UpdateToolTipData(tooltipFrame, mainFrameName, invItem, strArg, useSubFrame)
	local gBox = GET_CHILD(tooltipFrame, mainFrameName,'ui::CGroupBox');
	local yPos = gBox:GetY() + gBox:GetHeight();

	local txtLeftInfo = tolua.cast(gBox:CreateOrGetControl("richtext", 'TtipH_Left', 0, yPos, 410, 30), "ui::CRichText");
	
	local LBuffer = {};
	local RBuffer = {};
	local ShowExtraInfo = (IS_TOGGLE_EQUIP_ITEM_TOOLTIP_DESC() == 1);

	-- 左側情報
	table.insert(LBuffer, Me.GetBasicInfoText(invItem));
	table.insert(LBuffer, Me.GetCollectionText(invItem));
	table.insert(LBuffer, Me.GetRecipeText(invItem));

	table.insert(LBuffer, Me.GetDropRatioText(invItem));
	-- 右側情報(マグナムオーパス)
	local strTemp, bolTemp, hasMagnumOpusRecipe = "", false, false;
	strTemp, bolTemp = Me.GetMagnumOpusIntoText(invItem, ShowExtraInfo);
	hasMagnumOpusRecipe = hasMagnumOpusRecipe or bolTemp;
	if bolTemp then
		table.insert(RBuffer, strTemp);
	end
	strTemp, bolTemp = Me.GetMagnumOpusFromText(invItem, ShowExtraInfo);
	hasMagnumOpusRecipe = hasMagnumOpusRecipe or bolTemp;
	if bolTemp then
		table.insert(RBuffer, strTemp);
	end
	if hasMagnumOpusRecipe then
		strTemp = "";
		if Me.UsingXMLRecipeData then
			strTemp = Toukibi:GetResText(ResText, Me.Settings.Lang, "ForTitle.Mark_UsingXML")
		end
		-- table.insert(RBuffer, 1, Toukibi:GetStyledText(Toukibi:GetResText(ResText, Me.Settings.Lang, "ForTitle.MagnumOpusCommon"), {"#AAAAFF", "ol", "s15"}) .. strTemp);
	end
	
	local LeftText = table.concat(LBuffer, "{nl}");
	txtLeftInfo:SetText(LeftText);
	txtLeftInfo:SetMargin(20, gBox:GetHeight(), 0, 0)
	txtLeftInfo:SetGravity(ui.LEFT, ui.TOP)

	local RightText = table.concat(RBuffer, "{nl}");
	if string.len(RightText) > 0 then
		local txtRightInfo = tolua.cast(gBox:CreateOrGetControl("richtext", 'TtipH_Right', txtLeftInfo:GetX() + 50, yPos, 410, 30), "ui::CRichText");
		txtRightInfo:SetText(RightText);
		txtRightInfo:SetMargin(0, gBox:GetHeight(), 20, 0)
		txtRightInfo:SetGravity(ui.RIGHT, ui.TOP)
			
		local width = txtLeftInfo:GetWidth() + txtRightInfo:GetWidth() + 50;
		width = math.max(width, gBox:GetWidth());
		if txtLeftInfo:GetHeight() > txtRightInfo:GetHeight() then
			gBox:Resize(width, gBox:GetHeight() + txtLeftInfo:GetHeight() + 10)
		else 
			gBox:Resize(width, gBox:GetHeight() + txtRightInfo:GetHeight() + 10)
		end
		
		local etcCommonTooltip = GET_CHILD(gBox, 'tooltip_etc_common');
		if etcCommonTooltip ~= nil then
			etcCommonTooltip:Resize(width, etcCommonTooltip:GetHeight())
		end
		
		local etcDescTooltip = GET_CHILD(gBox, 'tooltip_etc_desc');
		if etcDescTooltip ~= nil then
			etcDescTooltip:Resize(width, etcDescTooltip:GetHeight())
		end	
		if string.sub(mainFrameName, #mainFrameName - 3) == "_sub" then
			local widthdif = gBox:GetWidth() - gBox:GetOriginalWidth();
			gBox:SetOffset(gBox:GetX() - widthdif, gBox:GetY());
		end
	else
		gBox:Resize(gBox:GetWidth(), gBox:GetHeight() + txtLeftInfo:GetHeight() + 10);
	end

	if Me.Settings.UseOriginalBgSkin then
		local newSkinName = "toukibi_Item_tooltip_normal";
		if mainFrameName == "equip_main" then
			newSkinName = "toukibi_Item_tooltip_equip";
		elseif mainFrameName == "equip_main_addinfo" then
			newSkinName = "toukibi_Item_tooltip_equip_sub";
		elseif mainFrameName == "equip_sub" then
			newSkinName = "toukibi_Item_tooltip_equip";
		elseif mainFrameName == "equip_sub_addinfo" then
			newSkinName = "toukibi_Item_tooltip_equip_sub";
		elseif mainFrameName == "bosscard" then
			newSkinName = "monstercard";
		elseif mainFrameName == "gem" then
			newSkinName = "toukibi_Item_tooltip_equip";
		elseif mainFrameName == "etc" then
			newSkinName = "toukibi_Item_tooltip_normal";
		elseif mainFrameName == "etc_sub" then
			newSkinName = "toukibi_Item_tooltip_normal";
		end

		gBox:SetSkinName(newSkinName)
		gBox:SetColorTone("F0FFFFFF")
	end

	return txtLeftInfo:GetHeight() + txtLeftInfo:GetY();
end

-- ===========================
--         設定画面関連
-- ===========================

local ToukibiUI = {
	-- マージンを指定する
	SetMargin = function(self, pTarget, pLeft, pTop, pRight, pBottom)
		if pTarget ~= nil then
			local BeforeMargin = pTarget:GetMargin();
			pLeft = pLeft or BeforeMargin.left;
			pTop = pTop or BeforeMargin.top;
			pRight = pRight or BeforeMargin.right;
			pBottom = pBottom or BeforeMargin.bottom;
			pTarget:SetMargin(pLeft, pTop, pRight, pBottom);
		end
	end,

	-- テキストコントロールを追加
	AddRichText = function(self, BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize)
		local txtItem = tolua.cast(BaseFrame:CreateOrGetControl('richtext', NewLabelName, NewLeft, NewTop, NewWidth, NewHeight), "ui::CRichText"); 
		txtItem:SetTextAlign("left", "top"); 
		txtItem:SetText("{@st66}" .. NewText); 
		txtItem:SetGravity(ui.LEFT, ui.TOP);
		txtItem:ShowWindow(1);
		return txtItem;
	end,

	-- テキストコントロールを指定した領域の中心になるように追加
	AddRichTextToCenter = function(self, BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize)
		local objTextItem = self:AddRichText(BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize); 
		self:SetMargin(objTextItem, NewLeft + math.floor((NewWidth - objTextItem:GetWidth()) / 2), NewTop + math.floor((NewHeight - objTextItem:GetHeight()) / 2), 0, 0);
		return objTextItem;
	end,

	-- コントロールのテキストを変更する
	SetText = function(self, ctrl, NewText, Styles)
		local StyledText = NewText;
		if Styles ~= nil and #Styles > 0 then
			-- スタイル指定あり
			StyledText = Toukibi:GetStyledText(NewText, Styles);
		end
		if ctrl ~= nil then
			ctrl:SetText(StyledText);
		end
	end,

	-- コントロールのプロパティーに入っているテキストを入れ替える
	SetTextByKey = function(self, ctrl, propName, NewText, Styles)
		local StyledText = NewText;
		if Styles ~= nil and #Styles > 0 then -- スタイル指定あり
			StyledText = Toukibi:GetStyledText(NewText, Styles);
		end
		if ctrl ~= nil then
			ctrl:SetTextByKey(propName, StyledText);
		end
	end,

	-- ***** ボタン関連 *****
	AddButton = function(self, BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize)
		local objButton = tolua.cast(BaseFrame:CreateOrGetControl('button', NewLabelName, NewLeft, NewTop, NewWidth, NewHeight), "ui::CButton"); 
		objButton:SetText("{@st66}" .. NewText .. "{/}"); 
		objButton:SetGravity(ui.LEFT, ui.TOP);
		objButton:SetClickSound("button_click_big");
		objButton:SetOverSound("button_over");
		objButton:SetSkinName("test_normal_button");
		return objButton;
	end,

	-- チェックボックスの状態を設定する
	SetCheckedByName = function(self, frame, ControlName, pValue)
		if frame == nil then return nil end
		local TargetCheckBox = GET_CHILD(frame, ControlName, "ui::CCheckBox");
		if TargetCheckBox ~= nil then
			return self:SetChecked(TargetCheckBox, pValue);
		else
			return nil;
		end
	end,
	SetChecked = function(self, TargetCheckBox, pValue)
		if TargetCheckBox == nil then return nil end
		local intValue = 0;
		if type(pValue) == "boolean" and pValue then
			intValue = 1;
		elseif type(pValue) == "string" and (pValue ~= "" and pValue ~= "false" and pValue ~= "0") then
			intValue = 1;
		elseif type == nil then
			intValue = false;
		elseif type(pValue) == "number" and pValue ~= 0 then
			intValue = 1;
		end
		tolua.cast(TargetCheckBox, "ui::CCheckBox");
		TargetCheckBox:SetCheck(intValue);
	end,
	-- チェックボックスの状態を取得する
	GetCheckedByName = function(self, frame, ControlName)
		if frame == nil then return nil end
		local TargetCheckBox = GET_CHILD(frame, ControlName, "ui::CCheckBox");
		if TargetCheckBox ~= nil then
			return self:GetChecked(TargetCheckBox);
		else
			return nil;
		end
	end,
	GetChecked = function(self, TargetCheckBox)
		if TargetCheckBox == nil then return nil end
		tolua.cast(TargetCheckBox, "ui::CCheckBox");
		return TargetCheckBox:IsChecked() == 1;
	end,

	-- ***** チェックボックス関連 *****
	AddCheckBox = function(self, BaseFrame, NewLabelName, NewText, NewLeft, NewTop, NewWidth, NewHeight, TextSize)
		local objCheck = tolua.cast(BaseFrame:CreateOrGetControl('checkbox', NewLabelName, NewLeft, NewTop, NewWidth, NewHeight), "ui::CCheckBox");
		objCheck:SetText("{@st66}" .. NewText .. "{/}"); 
		objCheck:SetGravity(ui.LEFT, ui.TOP);
		objCheck:SetClickSound("button_click_big");
		objCheck:SetOverSound("button_over");
		objCheck:ShowWindow(1);
		return objCheck;
	end,

	-- ***** スライダー関連 *****
	-- スライダーを追加する
	AddSlider = function(self, BaseFrame, CtrlName, NewLeft, NewTop, NewWidth, NewHeight)
		local objSlider = tolua.cast(BaseFrame:CreateOrGetControl('slidebar', CtrlName, NewLeft, NewTop, NewWidth, NewHeight), "ui::CSlideBar"); 
		objSlider:SetGravity(ui.LEFT, ui.TOP);
		objSlider:ShowWindow(1);
		objSlider:SetClickSound("button_click_big");
		objSlider:SetOverSound("button_over");
		return objSlider;
	end,

	-- スライダーの値を設定する
	SetSliderValue = function(self, frame, ControlName, LabelName, pValue, pValueText)
		local objSlider = GET_CHILD(frame, ControlName, "ui::CSlideBar");
		if objSlider ~= nil then
			objSlider:SetLevel(pValue);
		end
		local txtTarget = GET_CHILD(frame, LabelName, "ui::CRichText");
		if txtTarget ~= nil then
			txtTarget:SetTextByKey("opValue", pValueText);
		end
	end,

	-- スライダーの値を取得する
	GetSliderValueByName = function(self, frame, ControlName)
		if frame == nil then return nil end
		local TargetSlider = GET_CHILD(frame, ControlName, "ui::CSlideBar");
		if TargetSlider ~= nil then
			return self:GetSliderValue(TargetSlider);
		else
			return nil;
		end
	end,
	GetSliderValue = function(self, TargetSlider)
		if TargetSlider == nil then return nil end
		tolua.cast(TargetSlider, "ui::CSlideBar");
		return TargetSlider:GetLevel();
	end,

	-- ***** ラジオボタン関連 *****
	-- 選択されているラジオボタンの名前を取得する
	GetSelectedRadioValue = function(self, SeedRadio)
		if SeedRadio == nil then return nil end
		local radioBtn = tolua.cast(SeedRadio, "ui::CRadioButton");
		radioBtn = radioBtn:GetSelectedButton();
		return string.match(radioBtn:GetName(),".-_(.+)");
	end,

	-- ***** テキストボックス関連 *****
	-- テキストボックスを追加
	AddTextBox = function(self, BaseFrame, NewObjName, pText, NewLeft, NewTop, NewWidth, NewHeight)
		local objTextBox = tolua.cast(BaseFrame:CreateOrGetControl("edit", NewObjName, NewLeft, NewTop, NewWidth, NewHeight), "ui::CEditControl");
		objTextBox:SetGravity(ui.LEFT, ui.TOP);
		objTextBox:EnableHitTest(1);
		objTextBox:SetSkinName("test_weight_skin");
		objTextBox:SetClickSound("button_click_big");
		objTextBox:SetOverSound("button_over");
		objTextBox:SetFontName("white_18_ol");
		objTextBox:SetOffsetXForDraw(0);
		objTextBox:SetOffsetYForDraw(-1);
		objTextBox:SetTextAlign("center", "center");
		objTextBox:SetText(pText);
		return objTextBox;
	end,

	GetNumValue = function(self, objTarget)
		if objTarget == nil then return nil end
		return GetNumberFromCommaText(objTarget:GetText());
	end


};
Me.UI = ToukibiUI;

-- 設定データを設定画面に反映
function Me.InitSettingValue(BaseFrame)
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");

	local CurrentRadio = GET_CHILD(BodyGBox, "lang_en", "ui::CRadioButton");
	if Me.Settings.Lang == "jp" then
		CurrentRadio = GET_CHILD(BodyGBox, "lang_jp", "ui::CRadioButton");
	end
	CurrentRadio:Select()

	ToukibiUI:SetCheckedByName(BodyGBox, "showCollection",				 Me.Settings.showCollectionCustomTooltips);
	ToukibiUI:SetCheckedByName(BodyGBox, "showCompletedCollection",		 Me.Settings.showCompletedCollections);
	ToukibiUI:SetCheckedByName(BodyGBox, "showRecipe",					 Me.Settings.showRecipeCustomTooltips);
	ToukibiUI:SetCheckedByName(BodyGBox, "showRecipeHaveNeedCount",		 Me.Settings.showRecipeHaveNeedCount);
	ToukibiUI:SetCheckedByName(BodyGBox, "showItemDropRatio",			 Me.Settings.showItemDropRatio);
	ToukibiUI:SetCheckedByName(BodyGBox, "UseAutoImportDropData",		 Me.Settings.UseAutoImportDropData);
	ToukibiUI:SetCheckedByName(BodyGBox, "showMagnumOpus",				 Me.Settings.showMagnumOpus);
	ToukibiUI:SetCheckedByName(BodyGBox, "AllwaysDisplayOpusMap_From",	 Me.Settings.AllwaysDisplayOpusMap_From);
	ToukibiUI:SetCheckedByName(BodyGBox, "AllwaysDisplayOpusMap_Into",	 Me.Settings.AllwaysDisplayOpusMap_Into);
	ToukibiUI:SetCheckedByName(BodyGBox, "useRecipePuzzleXML",			 Me.Settings.useRecipePuzzleXML);
	ToukibiUI:SetCheckedByName(BodyGBox, "showJournalStats",			 Me.Settings.showJournalStats);
	ToukibiUI:SetCheckedByName(BodyGBox, "showRepairRecommendation",	 Me.Settings.showRepairRecommendation);
	txtInput = GET_CHILD(BodyGBox, "repairPrice", "ui::CEditControl");
	txtInput:SetText(Me.Settings.squireRepairPerKit);
	ToukibiUI:SetCheckedByName(BodyGBox, "UseOriginalBgSkin",			 Me.Settings.UseOriginalBgSkin);
	
end

-- 設定画面を設定データに反映
function Me.ExecSetting()
	local BaseFrame = ui.GetFrame("tooltiphelper_toukibi");
	if BaseFrame == nil then
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "SettingFrame.CannotGetSettingFrameHandle"), "Warning", true, false);
		return;
	end
	local BodyGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");
	if BodyGBox == nil then return end

	Me.Settings.Lang = ToukibiUI:GetSelectedRadioValue(BodyGBox:GetChild("lang_jp"));

	Me.Settings.showCollectionCustomTooltips =	 ToukibiUI:GetCheckedByName(BodyGBox, "showCollection");
	Me.Settings.showCompletedCollections =		 ToukibiUI:GetCheckedByName(BodyGBox, "showCompletedCollection");
	Me.Settings.showRecipeCustomTooltips =		 ToukibiUI:GetCheckedByName(BodyGBox, "showRecipe");
	Me.Settings.showRecipeHaveNeedCount =		 ToukibiUI:GetCheckedByName(BodyGBox, "showRecipeHaveNeedCount");
	Me.Settings.showItemDropRatio =				 ToukibiUI:GetCheckedByName(BodyGBox, "showItemDropRatio");
	Me.Settings.UseAutoImportDropData =			 ToukibiUI:GetCheckedByName(BodyGBox, "UseAutoImportDropData");
	Me.Settings.showMagnumOpus =				 ToukibiUI:GetCheckedByName(BodyGBox, "showMagnumOpus");
	Me.Settings.AllwaysDisplayOpusMap_From =	 ToukibiUI:GetCheckedByName(BodyGBox, "AllwaysDisplayOpusMap_From");
	Me.Settings.AllwaysDisplayOpusMap_Into =	 ToukibiUI:GetCheckedByName(BodyGBox, "AllwaysDisplayOpusMap_Into");
	Me.Settings.useRecipePuzzleXML =			 ToukibiUI:GetCheckedByName(BodyGBox, "useRecipePuzzleXML");
	Me.Settings.showJournalStats =				 ToukibiUI:GetCheckedByName(BodyGBox, "showJournalStats");
	Me.Settings.showRepairRecommendation =		 ToukibiUI:GetCheckedByName(BodyGBox, "showRepairRecommendation");
	txtInput = GET_CHILD(BodyGBox, "repairPrice", "ui::CEditControl");
	Me.Settings.squireRepairPerKit = 			 ToukibiUI:GetNumValue(txtInput)
	Me.Settings.UseOriginalBgSkin =				 ToukibiUI:GetCheckedByName(BodyGBox, "UseOriginalBgSkin");

	SaveSetting();
	Me.CloseSettingFrame();
end

-- 設定画面のテキストを再設定する
function Me.InitSettingText(BaseFrame, LangMode)
	LangMode = LangMode or Me.Settings.Lang or "jp";

	ToukibiUI:SetText(GET_CHILD(BaseFrame, "title", "ui::CRichText"), 
					  Toukibi:GetResText(ResText, LangMode, "SettingFrame.SettingFrameTitle"), {"@st43"});

	local TargetGBox = GET_CHILD_GROUPBOX(BaseFrame, "pnlMain");
	if TargetGBox ~= nil then
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "lang_title", "ui::CRichText"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.LangTitle"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "lang_jp", "ui::CRadioButton"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.Japanese"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "lang_en", "ui::CRadioButton"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.English"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "display_title", "ui::CRichText"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.DisplayTitle"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showCollection", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.showCollection"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showCompletedCollection", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.showCompletedCollection"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showRecipe", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.showRecipe"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showRecipeHaveNeedCount", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.showRecipeHaveNeedCount"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showItemDropRatio", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.showItemDropRatio"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "UseAutoImportDropData", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.UseAutoImportDropData"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showMagnumOpus", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.showMagnumOpus"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "AllwaysDisplayOpusMap_From", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.AllwaysDisplayOpusMap_From"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "AllwaysDisplayOpusMap_Into", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.AllwaysDisplayOpusMap_Into"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "useRecipePuzzleXML", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.useRecipePuzzleXML"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showJournalStats", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.showJournalStats"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "showRepairRecommendation", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.showRepairRecommendation"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "repairPrice_title", "ui::CRichText"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.repairPrice_title"), {"@st66b"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "UseOriginalBgSkin", "ui::CCheckBox"), 
						  Toukibi:GetResText(ResText, LangMode, "SettingFrame.UseOriginalBgSkin"), {"@st66b"});

		ToukibiUI:SetText(GET_CHILD(TargetGBox, "btn_excute", "ui::CButton"), 
							Toukibi:GetResText(ResText, LangMode, "SettingFrame.Save"), {"@st42"});
		ToukibiUI:SetText(GET_CHILD(TargetGBox, "btn_cencel", "ui::CButton"), 
							Toukibi:GetResText(ResText, LangMode, "SettingFrame.CloseMe"), {"@st42"});
	end
end

-- 設定画面を開く
function Me.SettingFrame_BeforeDisplay()
	local BaseFrame = ui.GetFrame("tooltiphelper_toukibi");
	if BaseFrame == nil then
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "SettingFrame.CannotGetSettingFrameHandle"), "Warning", true, false);
		return;
	end
	Me.InitSettingValue(BaseFrame);
	Me.InitSettingText(BaseFrame);
	Me.SettingFrameIsAvailable = true;
	BaseFrame:ShowWindow(1);
end

function Me.OpenSettingFrame()
	Me.SettingFrame_BeforeDisplay();
end

-- 設定画面を閉じる
function Me.CloseSettingFrame()
	local BaseFrame = ui.GetFrame("tooltiphelper_toukibi");
	if BaseFrame == nil then
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "SettingFrame.CannotGetSettingFrameHandle"), "Warning", true, false);
		return;
	end
	Me.SettingFrameIsAvailable = false;
	BaseFrame:ShowWindow(0);
end

-- 設定画面オープン
function TOUKIBI_TTHELPER_OPEN_SETTING()
	Me.SettingFrame_BeforeDisplay();
end

-- 設定保存
function TOUKIBI_TTHELPER_EXEC_SETTING()
	Me.ExecSetting();
end

-- 設定画面クローズ
function TOUKIBI_TTHELPER_CLOSE_SETTING()
	Me.CloseSettingFrame();
end

-- 言語切替
function TOUKIBI_TTHELPER_CHANGE_LANGMODE(frame, ctrl, str, num)
	local SelectedLang = ToukibiUI:GetSelectedRadioValue(ctrl);
	Me.InitSettingText(frame:GetTopParentFrame(), SelectedLang);
end

-- ===========================
--    フックイベント受け取り
-- ===========================

function Me.ITEM_TOOLTIP_ETC_HOOKED(tooltipFrame, invItem, strArg, useSubFrame)
	Me.HoockedOrigProc["ITEM_TOOLTIP_ETC"](tooltipFrame, invItem, strArg, useSubFrame); 
	local mainFrameName = 'etc'

	if useSubFrame == "usesubframe" or useSubFrame == "usesubframe_recipe" then
		mainFrameName = "etc_sub"
	end

	-- if marktioneer ~= nil then
	-- 	CUSTOM_TOOLTIP_PROPS(tooltipFrame, mainFrameName, invItem, strArg, useSubFrame);
	-- 	return marktioneer.addMarketPrice(tooltipFrame, mainFrameName, invItem, strArg, useSubFrame);
	-- else
		return Me.UpdateToolTipData(tooltipFrame, mainFrameName, invItem, strArg, useSubFrame);  
	-- end
end

function Me.ITEM_TOOLTIP_EQUIP_HOOKED(tooltipFrame, invItem, strArg, useSubFrame)
	Me.HoockedOrigProc["ITEM_TOOLTIP_EQUIP"](tooltipFrame, invItem, strArg, useSubFrame); 
	local mainFrameName = 'equip_main'

	if useSubFrame == "usesubframe" or useSubFrame == "usesubframe_recipe" then
		mainFrameName = "equip_sub"
	end

	-- if marktioneer ~= nil then
	-- 	CUSTOM_TOOLTIP_PROPS(tooltipFrame, mainFrameName, invItem, strArg, useSubFrame);
	-- 	return marktioneer.addMarketPrice(tooltipFrame, mainFrameName, invItem, strArg, useSubFrame);
	-- else
		return Me.UpdateToolTipData(tooltipFrame, mainFrameName, invItem, strArg, useSubFrame);  
	-- end
end

function Me.ITEM_TOOLTIP_GEM_HOOKED(tooltipFrame, invItem, strArg)
	Me.HoockedOrigProc["ITEM_TOOLTIP_GEM"](tooltipFrame, invItem, strArg);

	local mainFrameName = 'gem'

	return Me.UpdateToolTipData(tooltipFrame, mainFrameName, invItem, strArg);
end

function Me.ITEM_TOOLTIP_BOSSCARD_HOOKED(tooltipFrame, invItem, strArg)
	Me.HoockedOrigProc["ITEM_TOOLTIP_BOSSCARD"](tooltipFrame, invItem, strArg);

	local mainFrameName = 'bosscard'

	return Me.UpdateToolTipData(tooltipFrame, mainFrameName, invItem, strArg);
end

-- ===== アドオンの内容ここまで =====

-- ===== ここから先またお決まり文句 =====

-- スラッシュコマンド受取
function TOUKIBI_TTHELPER_PROCESS_COMMAND(command)
	Toukibi:AddLog(string.format(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ExecuteCommands"), SlashCommandList[1] .. " " .. table.concat(command, " ")), "Info", true, true);
	local cmd = ""; 
	if #command > 0 then 
		cmd = table.remove(command, 1); 
	else 
		Me.OpenSettingFrame();
		return;
	end 
	if cmd == "reset" then 
		-- すべてをリセット
		MargeDefaultSetting(true, true);
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.ResetSettings"), "Notice", true, false);
		return;
	elseif cmd == "import" then 
		-- ドロップデータをインポート
		Toukibi:AddLog(Toukibi:GetResText(ResText, Me.Settings.Lang, "System.StartImportDropData"), "Caution", true, false);

		ReserveScript("TOUKIBI_TTHELPER_START_IMPORT()", 0.5);
		return;
	elseif cmd == "jp" or cmd == "en" or string.len(cmd) == 2 then
		-- 言語モードと勘違いした？
		if cmd == "ja" then cmd = "jp" end
		Me.ComLib:ChangeLanguage(cmd);
		Me.CustomizeMiniMap()
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

Me.HoockedOrigProc = Me.HoockedOrigProc or {};
function TOOLTIPHELPER_TOUKIBI_ON_INIT(addon, frame)
	-- 設定を読み込む
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
		Me.LoadMagnumOpusRecipeFromXML();
		Me.CreateApplicationsList_Collection();
		Me.CreateApplicationsList_Recipe();
		-- IToSかJTosか判別(ドロップ率のクラスにヒットさせることで判別する)
		if GetClassCount("MonsterDropItemList_Onion") < 0 then
			-- JToSの場合
			if Me.Settings.UseAutoImportDropData then
				Me.ImportDropData(false);
			end
		end
		Me.CreateDropRatioList();
	end
	if Me.Settings.DoNothing then return end
	Me.SettingFrameIsAvailable = false;

	-- イベントを登録する
	Toukibi:SetHook("ITEM_TOOLTIP_ETC", Me.ITEM_TOOLTIP_ETC_HOOKED);
	Toukibi:SetHook("ITEM_TOOLTIP_EQUIP", Me.ITEM_TOOLTIP_EQUIP_HOOKED);
	Toukibi:SetHook("ITEM_TOOLTIP_GEM", Me.ITEM_TOOLTIP_GEM_HOOKED);
	Toukibi:SetHook("ITEM_TOOLTIP_BOSSCARD", Me.ITEM_TOOLTIP_BOSSCARD_HOOKED);

	-- スラッシュコマンドを登録する
	local acutil = require("acutil");
	for i = 1, #SlashCommandList do
		acutil.slashCommand(SlashCommandList[i], TOUKIBI_TTHELPER_PROCESS_COMMAND);
	end
end

-- ドロップ情報書き込み
-- ToolTipR.ExportDropData()
function Me.ExportDropData()
	local ExportFilePathName = string.format("../addons/%s/%s", addonNameLower, "dropdata.json");
	local ExportFilePathName_tsv = string.format("../addons/%s/%s", addonNameLower, "dropdata.dat");

	local hFile = io.open(ExportFilePathName_tsv, "w");
	local tblTarget = {};
	local clsList, cnt = GetClassList("Monster");
	for i = 0 , cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		local DoneList = {};
		if cls.Faction == "Monster" and cls.GroupName == "Monster" then
			local dropID = cls.DropItemList;
			if dropID ~= nil and dropID ~= "None" then
				local dropID = 'MonsterDropItemList_' .. dropID;
				local dropClassCount = GetClassCount(dropID);
				if dropClassCount ~= nil and dropClassCount > 0 then
					local MobClassID = cls.ClassID;
					for j = 0, dropClassCount - 1 do
						local dropIES = GetClassByIndex(dropID, j);
						if dropIES ~= nil and dropIES.GroupName == 'Item' then
							local itemClassName = dropIES.ItemClassName;
							local DropRatio = dropIES.DropRatio;
							table.insert(tblTarget,	 {iCNm = itemClassName
													, mCID = MobClassID
													, Ratio = DropRatio
													 });
							
							hFile:write(string.format("%s\t%s\t%s\n", MobClassID, DropRatio, itemClassName));
						end
					end
				end
			end
		end
	end
	hFile:close();
	-- Toukibi:SaveTable(ExportFilePathName, Me.ApplicationsList.DropRatio);
	 Toukibi:SaveTable(ExportFilePathName, tblTarget);
	log('[Export Drop Ratio Data] Finish!!')
end
