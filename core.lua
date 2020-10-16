--[[

	========== ADDON SYSTEM SETTINGS ==========
	!!DO NOT TAMPER WITH defaultDB[1] AS THIS WILL RESET YOUR ADDON SETTINGS!!

]]

local defaultDB = {};
-- Do nothing to this value! Ever! I mean it!
defaultDB[1] = 1.2;
-- Sets the default UI profile
defaultDB[2] = "normal";
-- Sets, whether nameplates should be small or big on fitting resolutions
defaultDB[3] = true;

-- Determines you current resolution to be lowRes or not
-- Seperate "local global variable" so that multiple setups can use it
-- Also only one call to improve performance
local lowRes = ((GetScreenWidth() < 1900) and (GetScreenHeight() < 1000));


--[[

	========== CVARS AND GLOBAL VARIABLES ==========

]]

-- Sets game specific global variables to the desired ones


-- Sets the global CVars to the desired ones
function setCVars()
	SetCVar("nameplateShowFriends", 0, "scriptCVar");
	SetCVar("nameplateShowSelf", 0, "scriptCVar");
	SetCVar("colorChatNamesByClass", 1, "scriptCVar");
	SetCVar("ShowClassColorInNameplate", 1, "scriptCVar");
	SetCVar("NamePlateVerticalScale", 2.7, "scriptCVar");
	SetCVar("NamePlateHorizontalScale", 1.4, "scriptCVar");

	if (((XereUICharDB[2] == "normal") or (XereUICharDB[2] == "healer")) and XereUICharDB[4]) then
		SetCVar("NamePlateVerticalScale", 1, "scriptCVar");
		SetCVar("NamePlateHorizontalScale", 1, "scriptCVar");
	end
end


--[[

	========== UNITFRAMES ==========

]]

-- Determines the position of the frames depending on your resolution and profile
function setPositions ()
	TARGET_FRAME_BUFFS_ON_TOP = true;
	FOCUS_FRAME_BUFFS_ON_TOP = true;
	if ((XereUICharDB[2] == "normal") and (not lowRes)) then
		PLAYER_FRAME_CASTBARS_SHOWN = false;
	else
		PLAYER_FRAME_CASTBARS_SHOWN = true;
	end
	local scale, playerX, playerY;
	if (XereUICharDB[2] == "normal") then
		if (lowRes) then
			scale = 1.1;
			playerX = -200;
			playerY = -50;
			positionFrames(1, (scale - 0.1), playerX, playerY, (playerX * (-1)), playerY, (playerX - 100), (playerY + 100));
		else			
			scale = 1.3;
			playerX = -250;
			playerY = -50;
			positionFrames(scale, (scale - 0.2), playerX, playerY, (playerX * (-1)), playerY, (playerX - 100), (playerY + 150));
		end
		
	elseif (XereUICharDB[2] == "pvp") then
		if (lowRes) then
			scale = 1;
			playerX = -400;
			playerY = 50;
			positionFrames(scale, scale, playerX, playerY, (playerX + 230), playerY, (playerX + 20), (playerY + 100));
		else
			scale = 1.2;
			playerX = -400;
			playerY = 50;
			positionFrames(scale, scale, playerX, playerY, (playerX + 230), playerY, (playerX - 50), (playerY + 100));
		end
		
	elseif (XereUICharDB[2] == "healer") then
		if (lowRes) then
			scale = 1.1;
			playerX = -200;
			playerY = -50;
			positionFrames(scale, (scale - 0.1), playerX, playerY, (playerX * (-1)), playerY, (playerX - 100), (playerY + 100));
		else
			scale = 1.3;
			playerX = -250;
			playerY = -50;
			positionFrames(scale, (scale - 0.2), playerX, playerY, (playerX * (-1)), playerY, (playerX + 20), (playerY + 150));
		end
		
	else
		print("Chosen profile not recognized.");
	end
end

-- Positions the frames according to the parsed parameters
function positionFrames(scale, fScale, pX, pY, tX, tY, fX, fY)
	MinimapCluster:SetScale(scale);
	BuffFrame:SetScale(scale + 0.2);
	for i = 1, 4 do
		local frame = _G["PartyMemberFrame"..i]
		frame:SetScale(scale + 0.4)
	end
	posFrame(PlayerFrame, scale, pX, pY);
	posFrame(TargetFrame, scale, tX, tY);
	posFrame(FocusFrame, fScale, fX, fY);
end

-- Utility function to remove unnecessary code
-- Positions a single frame
function posFrame(frameName, scale, x, y)
	frameName:ClearAllPoints();
	frameName:SetPoint("CENTER", UIParent, x, y);
	frameName:SetScale(scale);
	frameName:SetUserPlaced(true);
end

--[[

	========== MISCELANIOUS ==========

]]

-- Enables Minimap Zoom through scrolling and disables the zoom buttons
MinimapZoomIn:Hide();
MinimapZoomOut:Hide();
Minimap:EnableMouseWheel(true);
Minimap:SetScript("OnMouseWheel", function(self, delta)
    if (delta > 0) then
        Minimap_ZoomIn();
    else
        Minimap_ZoomOut();
    end
end)

-- Hides the tracking button on the minimap and replaces it by right clicking on the minimap
MiniMapTracking:Hide();
Minimap:SetScript("OnMouseUp", function(self, button)
	if (button == "RightButton") then
		ToggleDropDownMenu(1,nil,MiniMapTrackingDropDown,"cursor");
	else
		Minimap_OnClick(self);
	end
end);


--[[

	========== FRAME AND EVENTHANDLING ==========

]]

local frame = CreateFrame("FRAME", "XereUIFrame");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("CVAR_UPDATE"); -- needed so that CVars can be set in a script

local function eventHandler(self, event, ...)
	if (event == "ADDON_LOADED") then
	
		-- Checks whether the addon has run before
		if (XereUICharDB == nil) then
			XereUICharDB = defaultDB;
			print("|cff9482C9XereUI|r |cff34d1c9v." .. XereUICharDB[1] .. "|r Setup done.");
			
		-- Checks whether the saved variables are out of date
		elseif (XereUICharDB[1] ~= defaultDB[1]) then
			local tempData = XereUICharDB;

			XereUICharDB = defaultDB;

			-- Copies the old values to the new database
			for i=2, tablelength(tempData) do
				XereUICharDB[i] = tempData[i];
			end

			print("|cff9482C9XereUI|r | updated to |cff34d1c9v." .. XereUICharDB[1] "|r. Have fun!");
		end
		
	elseif (event == "PLAYER_ENTERING_WORLD") then	
		-- Applies the profile to the interface whenever the player enters the world
		setPositions();
		setCVars();
	end
end

frame:SetScript("OnEvent", eventHandler);


--[[

	========== SLASHCOMMAND HANDLING ==========

]]

local function MyAddonCommands(command, editbox)

	-- Changes the profile to the specified one
	if (command == "normal") or (command == "pvp") or (command == "healer") then
		XereUICharDB[2] = command;
		setCVars();
		ReloadUI();

	-- toggles the nameplate size
	elseif (command == "nameplate") then
		XereUICharDB[3] = not XereUICharDB[3];
		ReloadUI();
		
	-- prints a list of the savedvariables and their values
	elseif (command == "status") then
	
		print("Version: " .. XereUICharDB[1]);
		print("Profile: " .. XereUICharDB[2]);

		if (XereUICharDB[3]) then
			print("Nameplate autosize: true");
		else
			print("Nameplate autosize: false");
		end
	
	-- resets all saved variables to their standard values
	elseif (command == "reset") then
		XereUICharDB = nil;
		ReloadUI();
		
	-- prints the help message
	elseif (command == "help") then
		print("====================================================");
		print("Use |cff9482C9/xui|r or |cff9482C9/xereui|r with one of the following commands:");
		print("    > |cff34d1c9normal|r : for the standard UI.");
		print("    > |cff34d1c9pvp|r : for the pvp focused UI.");
		print("    > |cff34d1c9healer|r : for a healing centric UI.");
		print(" ");
		print("    > |cff34d1c9nameplate|r : toggles small/big nameplates for fitting resolutions.");
		print(" ");
		print("    > |cff34d1c9help|r : prints this help.");
		print("    > |cff34d1c9status|r : displays your current saved values.");
		print("    > |cff34d1c9reset|r : resets all saved variables to their standard values.");
		print("====================================================");
		
	else
		print("Command not recognized. Try '/xui help' for help.");
	end
end

SLASH_XEREUI1, SLASH_XEREUI2 = '/xui', '/xereui';

SlashCmdList["XEREUI"] = MyAddonCommands;


--[[

	========== UTILITY FUNCTIONS ==========

]]

function tablelength(table)
	local count = 0;
	for _ in pairs(table) do 
		count = count + 1;
	end
	return count;
end


--[[

	========== TEST CODE ==========
	and also notes ...

	UI Name color: 9482C9
	Hint color: 34d1c9

]]
