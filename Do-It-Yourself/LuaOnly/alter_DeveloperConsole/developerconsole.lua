
function DEVELOPERCONSOLE_ON_INIT(addon, frame)
	local acutil = require("acutil");
	acutil.slashCommand("/dev", DEVELOPERCONSOLE_TOGGLE_FRAME);
	acutil.slashCommand("/console", DEVELOPERCONSOLE_TOGGLE_FRAME);
	acutil.slashCommand("/devconsole", DEVELOPERCONSOLE_TOGGLE_FRAME);
	acutil.slashCommand("/developerconsole", DEVELOPERCONSOLE_TOGGLE_FRAME);

	acutil.setupHook(DEVELOPERCONSOLE_PRINT_TEXT, "print");

	CLEAR_CONSOLE();
end

function DEVELOPERCONSOLE_TOGGLE_FRAME()
	ui.ToggleFrame("developerconsole");
end

function DEVELOPERCONSOLE_OPEN()
	local frame = ui.GetFrame("developerconsole");
	local textViewLog = frame:GetChild("textview_log");
	textViewLog:ShowWindow(1);

	local devconsole = ui.GetFrame("developerconsole");
	devconsole:ShowTitleBar(0);
	--devconsole:ShowTitleBarFrame(1);
	devconsole:ShowWindow(0);
	devconsole:SetSkinName("chat_window");
	devconsole:ShowWindow(1);
	--devconsole:Resize(800, 500);

	local input = devconsole:GetChild("input");
	if input ~= nil then
		input:Move(0, 0);
		input:SetOffset(10, 450);
		--input:ShowWindow(1);
		--input:Resize(675, 40);
		--input:SetGravity(ui.LEFT, ui.CENTER);
	end

	local executeButton = devconsole:GetChild("execute");
	if executeButton ~= nil then
		--executeButton:Resize(100, 40);
		executeButton:SetOffset(690, 450);
		executeButton:SetText("Execute");
	end

	local debugUIButton = devconsole:GetChild("debugUI");
	if debugUIButton ~= nil then
		--debugUIButton:Resize(100, 40);
		debugUIButton:SetOffset(690, 405);
		debugUIButton:SetText("Debug UI");
	end

	local clearButton = devconsole:GetChild("clearConsole");
	if clearButton ~= nil then
		clearButton:Resize(100, 40);
		clearButton:SetOffset(690, 360);
		clearButton:SetText("Clear");
	end

	local textlog = devconsole:GetChild("textview_log");
	if textlog ~= nil then
		--textlog:Resize(675, 435);
		textlog:SetOffset(10, 10);
	end

	devconsole:Invalidate();

	--ui.SysMsg("input: " .. input:GetX() .. " " .. input:GetY() .. " " .. input:GetWidth() .. " " .. input:GetHeight());
	--ui.SysMsg("execute: " .. executeButton:GetX() .. " " .. executeButton:GetY() .. " " .. executeButton:GetWidth() .. " " .. executeButton:GetHeight());
	--ui.SysMsg("debugUI: " .. debugUIButton:GetX() .. " " .. debugUIButton:GetY() .. " " .. debugUIButton:GetWidth() .. " " .. debugUIButton:GetHeight());
	--ui.SysMsg("textlog: " .. textlog:GetX() .. " " .. textlog:GetY() .. " " .. textlog:GetWidth() .. " " .. textlog:GetHeight());
end

function DEVELOPERCONSOLE_CLOSE()
end

function TOGGLE_UI_DEBUG()
	debug.ToggleUIDebug();
end

function CLEAR_CONSOLE()
	local frame = ui.GetFrame("developerconsole");

	if frame ~= nil then
		local textlog = frame:GetChild("textview_log");

		if textlog ~= nil then
			tolua.cast(textlog, "ui::CTextView");
			textlog:Clear();
			textlog:AddText("Developer Console", "white_16_ol");
			textlog:AddText("Enter command and press execute!", "white_16_ol");
		end
	end
end

function DEVELOPERCONSOLE_PRINT_TEXT(text)
	if text == nil or text == "" then
		return;
	end

	local frame = ui.GetFrame("developerconsole");
	local textlog = frame:GetChild("textview_log");

	if textlog ~= nil then
		tolua.cast(textlog, "ui::CTextView");
		textlog:AddText(text, "white_16_ol");
	end
end

local function order_pairs(tab)
	local sorted = {};
	for key in pairs(tab) do
		table.insert(sorted,key);
	end
	table.sort(sorted);
	local i = 0;
	return function()
		i = i + 1
		if i > #sorted then
			return nil,nil
		else
			local key=sorted[i]
			return key,tab[key]
		end
	end
end
function DEVELOPERCONSOLE_PRINT_VALUE(frame, objName, objValue, ParentName, indentStr, ViewValue)
	frame = frame or ui.GetFrame("developerconsole");
	local textlog = frame:GetChild("textview_log");
	indentStr = indentStr or "";
	ParentName = ParentName or "";
	if ViewValue == nil then ViewValue = false end
	local commandText = "";
	local typeStr = type(objValue);
	if typeStr == "userdata" or typeStr == "table" then
		if typeStr == "userdata" then objValue = getmetatable(objValue) end

		for pName, pValue in order_pairs(objValue) do
			local strLeft = "{#666666}" .. indentStr .. "└{/}{#444466}" .. tostring(pName) .. "{/}";
			local pType = type(pValue);
			if pName == "tolua_ubox" then
				textlog:AddText("{#666666}" .. indentStr .. "└{/}{#666644}[" .. tostring(pName) .. "]{/}", "white_16_ol");
			elseif pType == "function" then
				local funcStr = string.format("{#888888}(%s){/}", tostring(pValue));
				local valueStr = "";
				if ViewValue and string.sub(pName, 1, 2) ~= "__" and objName ~= ".set" then
					valueStr = "{#444444}={/} ";
					local funcSrcStr = ""
					if objName == ".get" then
						funcSrcStr = string.format("return tostring(%s.%s)", ParentName, pName);
					else
						funcSrcStr = string.format("return tostring(%s:%s())", ParentName, pName);
					end
					-- textlog:AddText(tostring(funcSrcStr), "white_16_ol");
					-- local funcResult = assert(load(funcSrcStr))();
					local status, objResult = pcall(load(funcSrcStr))
					if not status then
						--textlog:AddText(tostring(objResult), "white_16_ol");
					else
						valueStr = valueStr .. "{#336666}" .. objResult .. "{/} ";
					end
				end
				if string.sub(pName, 1, 2) ~= "__" and objName ~= ".set" then
					textlog:AddText(string.format("%s {#888888}%s{/}%s", strLeft, valueStr, funcStr), "white_16_ol");
				end
			elseif pType == "userdata" or pType	 == "table" then
				local NextParentName = ParentName;
				if objName ~= ".get" then
					
				else
					NextParentName = NextParentName .. objName
				end
				textlog:AddText(strLeft .. " {#444444}={/} {#005500}" .. pType .. "{/}", "white_16_ol");
				DEVELOPERCONSOLE_PRINT_VALUE(frame, tostring(pName), pValue, NextParentName, indentStr .. "│  ", ViewValue);
			else
				textlog:AddText(strLeft .. " {#444444}={/} " .. tostring(pValue), "white_16_ol")
			end
		end
	else
		local f = assert(print(tostring(objValue)));
		local status, error = pcall(f);
		if not status then
			textlog:AddText(tostring(error), "white_16_ol");
		end
	end
end

function DEVELOPERCONSOLE_ENTER_KEY(frame, control, argStr, argNum)
	local textlog = frame:GetChild("textview_log");

	if textlog ~= nil then
		tolua.cast(textlog, "ui::CTextView");

		local editbox = frame:GetChild("input");

		if editbox ~= nil then
			tolua.cast(editbox, "ui::CEditControl");
			local commandText = editbox:GetText();
			if commandText ~= nil and commandText ~= "" then
				textlog:AddText(" ", "white_16_ol");
				local s = "[Execute] " .. commandText;
				textlog:AddText("{#333333}" .. s .. "{/}", "white_16_ol");
				if string.sub(commandText, 1, 2) == "??" then
					local ViewValue = false
					local objName = string.sub(commandText,3)
					if string.sub(commandText, 1, 3) == "???" then
						ViewValue = true;
						objName = string.sub(commandText,4)
					end
					local objValue = assert(load(string.format("return %s", objName)))();
					textlog:AddText("{#444444}type of {#005500}"  .. objName .. "{/} is {#005500}" .. type(objValue) .. "{/}{/}", "white_16_ol");
					DEVELOPERCONSOLE_PRINT_VALUE(frame, objName, objValue, objName, nil, ViewValue);
				elseif string.sub(commandText, 1, 1) == "?" then
					local objName = string.sub(commandText,2)
					local objValue = assert(load(string.format("return %s", objName)))();
					local strLeft = "{#444466}" .. tostring(objName) .. "{/} {#444444}={/} ";
					textlog:AddText(strLeft .. tostring(objValue), "white_16_ol")
				else
					local f = assert(load(commandText));
					local status, error = pcall(f);

					if not status then
						textlog:AddText(tostring(error), "white_16_ol");
					end
				end
			end
		end
	end
end