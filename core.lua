--[[

	========== ADDON SYSTEM SETTINGS ==========
	!!DO NOT TAMPER WITH defaultDB[1] AS THIS WILL RESET YOUR ADDON SETTINGS!!

]]

local version = 1.0;

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
end


--[[

	========== UNITFRAMES ==========

]]

-- Determines the position of the frames depending on your resolution and profile
function setPositions ()
	TARGET_FRAME_BUFFS_ON_TOP = true;
	FOCUS_FRAME_BUFFS_ON_TOP = true;
	PLAYER_FRAME_CASTBARS_SHOWN = lowRes;
	
	local scale, playerX, playerY;

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
	========== COMPACT RAIDFRAMES ==========
]]

-- Sets the Displaynames for the different Raid-Profiles
-- Change the strings to your liking, but doesn't change their functionality
local PARTY_PROFILE = "Party";

-- Creates a raid profile used for the addon if not already present
function createProfileIfMissing()
	if not RaidProfileExists(PARTY_PROFILE) then
		if GetNumRaidProfiles() < 5 then
			CompactUnitFrameProfiles_CreateProfile(PARTY_PROFILE);
		else
			print("|cff9482C9XereUI|r | Error: Could not create necessary raiframe profile. All raidframe profiles are in use. Please free up a slot and type /reload.");
		end
	end
end

-- Configures a single CUFProfile according to the parsed parameters
function configureCUFProfile(profile, together, sorting, horizontal, powerbar, pets, tanks, dispell, health, height, width, border)
	local oldProfile = GetActiveRaidProfile();
	CompactUnitFrameProfiles_ActivateRaidProfile(profile);
	SetRaidProfileOption(profile, "keepGroupsTogether", together);
	SetRaidProfileOption(profile, "sortBy", sorting); -- { "role", "group", "alphabetical" }
	SetRaidProfileOption(profile, "horizontalGroups", horizontal);
	SetRaidProfileOption(profile, "displayHealPrediction", true);
	SetRaidProfileOption(profile, "displayPowerBar", powerbar);
	SetRaidProfileOption(profile, "displayAggroHighlight", true);
	SetRaidProfileOption(profile, "useClassColors", true);
	SetRaidProfileOption(profile, "displayPets", pets);
	SetRaidProfileOption(profile, "displayMainTankAndAssist", tanks);
	SetRaidProfileOption(profile, "displayNonBossDebuffs", true);
	SetRaidProfileOption(profile, "displayOnlyDispellableDebuffs", dispell);
	SetRaidProfileOption(profile, "healthText", health); -- { "none", "health", "losthealth", "perc" }
	SetRaidProfileOption(profile, "frameHeight", height);
	SetRaidProfileOption(profile, "frameWidth", width);
	SetRaidProfileOption(profile, "displayBorder", border);
	CompactUnitFrameProfiles_ActivateRaidProfile(oldProfile);
end

-- Configures the settings of the CUFProfiles depending on the UIProfile
function configureCUFProfiles()
	if (lowRes) then
							-- profile, 	 together, sorting, horizontal, powerbar, pets, tanks, dispell, health, 	height, width, border
		configureCUFProfile(PARTY_PROFILE, 		true, 	"role", 	false, 	true, 	false, 	false, 	true, 	"none", 	50, 	144, 	false);
	else
							-- profile, 	 together, sorting, horizontal, powerbar, pets, tanks, dispell, health, 	height, width, border
		configureCUFProfile(PARTY_PROFILE, 		true, 	"role", 	false, 	true, 	false, 	false, 	true, 	"none", 	72, 	144, 	false);
	end
end

-- Positions the compact unit frames according to resolution and profile
function positionCUFPRofiles()
	if (lowRes) then
		SetRaidProfileSavedPosition(PARTY_PROFILE, 		false, "TOP", 130, "BOTTOM", 150, "ATTACHED", 0);
	else
		SetRaidProfileSavedPosition(PARTY_PROFILE, 		false, "TOP", 180, "BOTTOM", 400, "LEFT", 250);
	end
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

-- Moves the tooltip to be anchored at the cursos

-- hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent) self:SetOwner(parent, "ANCHOR_CURSOR") end)


--[[

	========== FRAME AND EVENTHANDLING ==========

]]

local frame = CreateFrame("FRAME", "XereUIFrame");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("COMPACT_UNIT_FRAME_PROFILES_LOADED"); --fires when the CUF is loaded. Happens apparently after entering world and is needed to prevent errors
frame:RegisterEvent("CVAR_UPDATE"); -- needed so that CVars can be set in a script

local function eventHandler(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then	
		-- Applies the profile to the interface whenever the player enters the world
		setPositions();
		setCVars();

	elseif (event == "COMPACT_UNIT_FRAME_PROFILES_LOADED") then
		createProfileIfMissing();
		positionCUFPRofiles();
		configureCUFProfiles();
	end
end

frame:SetScript("OnEvent", eventHandler);


--[[

	========== SLASHCOMMAND HANDLING ==========

]]

local function MyAddonCommands(command, editbox)
	-- Changes the profile to the specified one
	if (command == "status") or (command == "help") then
		print("|cff9482C9XereUI|r version |cff34d1c9" .. version .. "|r.");
	else
		print("Command not recognized. Try |cff34d1c9'/xui help'|r for help.");
	end
end

SLASH_XEREUI1, SLASH_XEREUI2 = '/xui', '/xereui';

SlashCmdList["XEREUI"] = MyAddonCommands;
