--[[

	========== ADDON SYSTEM SETTINGS ==========
	!!DO NOT TAMPER WITH defaultDB[1] AS THIS WILL RESET YOUR ADDON SETTINGS!!

]]

local defaultDB = {};
-- Do nothing to this value! Ever! I mean it!
defaultDB[1] = 0.7;
-- Sets the default UI profile
defaultDB[2] = "normal";
-- Sets, whether raid profile repositioning/rescaling is enabled by default (doesn't affect automatic raid profile switching)
defaultDB[3] = true;
-- Sets, whether nameplates should be small or big on fitting resolutions
defaultDB[4] = true;

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
	SetCVar("useCompactPartyFrames", 1, "scriptCVar");
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
local PARTY_PROFILE = "Party"
local RAID_25_PROFILE = "Raid25";
local RAID_40_PROFILE = "Raid40";
local ARENA_PROFILE = "Arena";
local BG_PROFILE = "Battleground";

-- Utility function to manage the raid profiles and create them in an addon friendly way
function manageCUFProfiles()
	for i=1, GetNumRaidProfiles() do
		local name = GetRaidProfileName(i);
		if (name ~= ARENA_PROFILE) and (name ~= BG_PROFILE) and (name ~= PARTY_PROFILE) and (name ~= RAID_25_PROFILE) and (name ~= RAID_40_PROFILE) then
			DeleteRaidProfile(name);
			-- Replaces the deleted profile with a wanted one
			if (not RaidProfileExists(PARTY_PROFILE)) then
				name = PARTY_PROFILE;
			elseif (not RaidProfileExists(RAID_25_PROFILE)) then
				name = RAID_25_PROFILE;
			elseif (not RaidProfileExists(RAID_40_PROFILE)) then
				name = RAID_40_PROFILE;
			elseif (not RaidProfileExists(ARENA_PROFILE)) then
				name = ARENA_PROFILE;
			elseif (not RaidProfileExists(BG_PROFILE)) then
				name = BG_PROFILE;
			end
			CompactUnitFrameProfiles_CreateProfile(name);
			-- Calls the function again to rescan the profiles
			-- (Lua doesn't allow the count variable to be changed from inside the loop)
			manageCUFProfiles();
		end
	end
end

-- Utility function to create all the missing profiles
-- Extra function to prevent recursive overload
function createMissingCUFProfiles() 
	if (not RaidProfileExists(PARTY_PROFILE)) then
		CompactUnitFrameProfiles_CreateProfile(PARTY_PROFILE);
	end
	if (not RaidProfileExists(RAID_25_PROFILE)) then
		CompactUnitFrameProfiles_CreateProfile(RAID_25_PROFILE);
	end
	if (not RaidProfileExists(RAID_40_PROFILE)) then
		CompactUnitFrameProfiles_CreateProfile(RAID_40_PROFILE);
	end
	if (not RaidProfileExists(ARENA_PROFILE)) then
		CompactUnitFrameProfiles_CreateProfile(ARENA_PROFILE);
	end
	if (not RaidProfileExists(BG_PROFILE)) then
		CompactUnitFrameProfiles_CreateProfile(BG_PROFILE);
	end
end

-- Configures a single CUFProfile according to the parsed paraameters
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
	if (XereUICharDB[2] == "normal") then
		if (lowRes) then
								-- profile, 	 together, sorting, horizontal, powerbar, pets, tanks, dispell, health, 	height, width, border
			configureCUFProfile(PARTY_PROFILE, 		false, 	"role", 	false, 	true, 	false, 	false, 	true, 	"none", 	50, 	144, 	true);
			configureCUFProfile(RAID_25_PROFILE, 	false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	100, 	false);
			configureCUFProfile(RAID_40_PROFILE, 	false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
			configureCUFProfile(ARENA_PROFILE, 		false, 	"role", 	false, 	true, 	true, 	false, 	false, 	"perc", 	72, 	144, 	true);
			configureCUFProfile(BG_PROFILE, 		false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
		else
								-- profile, 	 together, sorting, horizontal, powerbar, pets, tanks, dispell, health, 	height, width, border
			configureCUFProfile(PARTY_PROFILE, 		false, 	"role", 	false, 	true, 	false, 	false, 	true, 	"none", 	72, 	144, 	true);
			configureCUFProfile(RAID_25_PROFILE, 	false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	50, 	100, 	false);
			configureCUFProfile(RAID_40_PROFILE, 	false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
			configureCUFProfile(ARENA_PROFILE, 		false, 	"role", 	false, 	true, 	true, 	false, 	false, 	"perc", 	72, 	144, 	true);
			configureCUFProfile(BG_PROFILE, 		false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
		end
		
	elseif (XereUICharDB[2] == "pvp") then
		if (lowRes) then
								-- profile, 	 together, sorting, horizontal, powerbar, pets, tanks, dispell, health, 	height, width, border
			configureCUFProfile(PARTY_PROFILE, 		false, 	"role", 	false, 	true, 	false, 	false, 	true, 	"none", 	72, 	144, 	true);
			configureCUFProfile(RAID_25_PROFILE, 	false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	50, 	100, 	false);
			configureCUFProfile(RAID_40_PROFILE, 	false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
			configureCUFProfile(ARENA_PROFILE, 		false, 	"role", 	false, 	true, 	true, 	false, 	false, 	"perc", 	72, 	144, 	true);
			configureCUFProfile(BG_PROFILE, 		false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
		else
								-- profile, 	 together, sorting, horizontal, powerbar, pets, tanks, dispell, health, 	height, width, border
			configureCUFProfile(PARTY_PROFILE, 		false, 	"role", 	false, 	true, 	false, 	false, 	true, 	"none", 	72, 	144, 	true);
			configureCUFProfile(RAID_25_PROFILE, 	false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	50, 	100, 	false);
			configureCUFProfile(RAID_40_PROFILE, 	false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
			configureCUFProfile(ARENA_PROFILE, 		false, 	"role", 	false, 	true, 	true, 	false, 	false, 	"perc", 	72, 	144, 	true);
			configureCUFProfile(BG_PROFILE, 		false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
		end
		
	elseif (XereUICharDB[2] == "healer") then
		if (lowRes) then
								-- profile, 	 together, sorting, horizontal, powerbar, pets, tanks, dispell, health, 	height, width, border
			configureCUFProfile(PARTY_PROFILE, 		true, 	"group", 	true, 	false, 	false, 	false, 	false, 	"perc", 	72, 	72, 	true);
			configureCUFProfile(RAID_25_PROFILE, 	false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
			configureCUFProfile(RAID_40_PROFILE, 	false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
			configureCUFProfile(ARENA_PROFILE, 		true, 	"group", 	true, 	false, 	true, 	false, 	false, 	"perc", 	72, 	72, 	true);
			configureCUFProfile(BG_PROFILE, 		false, 	"group", 	false, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
		else
								-- profile, 	 together, sorting, horizontal, powerbar, pets, tanks, dispell, health, 	height, width, border
			configureCUFProfile(PARTY_PROFILE, 		true, 	"group", 	true, 	false, 	false, 	false, 	false, 	"perc", 	72, 	72, 	true);
			configureCUFProfile(RAID_25_PROFILE, 	true, 	"group", 	true, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
			configureCUFProfile(RAID_40_PROFILE, 	true, 	"group", 	true, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
			configureCUFProfile(ARENA_PROFILE, 		true, 	"group", 	true, 	false, 	true, 	false, 	false, 	"perc", 	72, 	72, 	true);
			configureCUFProfile(BG_PROFILE, 		true, 	"group", 	true, 	false, 	false, 	true, 	false, 	"none", 	36, 	72, 	false);
		end
		
	else
		print("Chosen profile not recognized.");
	end
end

-- Positions the compact unit frames according to resolution and profile
function positionCUFPRofiles()
	if (XereUICharDB[2] == "normal") then
		if (lowRes) then
			SetRaidProfileSavedPosition(PARTY_PROFILE, 		false, "TOP", 130, "BOTTOM", 150, "ATTACHED", 0);
			SetRaidProfileSavedPosition(RAID_25_PROFILE, 	false, "TOP", 130, "BOTTOM", 250, "ATTACHED", 0);
			SetRaidProfileSavedPosition(RAID_40_PROFILE, 	false, "TOP", 130, "BOTTOM", 250, "ATTACHED", 0);
			SetRaidProfileSavedPosition(ARENA_PROFILE, 		false, "TOP", 130, "BOTTOM", 150, "ATTACHED", 0);
			SetRaidProfileSavedPosition(BG_PROFILE, 		false, "TOP", 130, "BOTTOM", 250, "ATTACHED", 0);
		else
			SetRaidProfileSavedPosition(PARTY_PROFILE, 		false, "TOP", 180, "BOTTOM", 400, "LEFT", 350);
			SetRaidProfileSavedPosition(RAID_25_PROFILE, 	false, "TOP", 200, "BOTTOM", 300, "LEFT", 200);
			SetRaidProfileSavedPosition(RAID_40_PROFILE, 	false, "TOP", 200, "BOTTOM", 300, "LEFT", 150);
			SetRaidProfileSavedPosition(ARENA_PROFILE, 		false, "TOP", 200, "BOTTOM", 400, "LEFT", 250);
			SetRaidProfileSavedPosition(BG_PROFILE, 		false, "TOP", 200, "BOTTOM", 300, "LEFT", 150);
		end
		
	elseif (XereUICharDB[2] == "pvp") then
		if (lowRes) then
			SetRaidProfileSavedPosition(PARTY_PROFILE, 		false, "TOP", 130, "BOTTOM", 150, "ATTACHED", 0);
			SetRaidProfileSavedPosition(RAID_25_PROFILE, 	false, "TOP", 130, "BOTTOM", 250, "ATTACHED", 0);
			SetRaidProfileSavedPosition(RAID_40_PROFILE, 	false, "TOP", 130, "BOTTOM", 250, "ATTACHED", 0);
			SetRaidProfileSavedPosition(ARENA_PROFILE, 		false, "TOP", 130, "BOTTOM", 150, "ATTACHED", 0);
			SetRaidProfileSavedPosition(BG_PROFILE, 		false, "TOP", 130, "BOTTOM", 250, "ATTACHED", 0);
		else
			SetRaidProfileSavedPosition(PARTY_PROFILE, 		false, "TOP", 200, "BOTTOM", 400, "ATTACHED", 0);
			SetRaidProfileSavedPosition(RAID_25_PROFILE, 	false, "TOP", 200, "BOTTOM", 300, "ATTACHED", 0);
			SetRaidProfileSavedPosition(RAID_40_PROFILE, 	false, "TOP", 200, "BOTTOM", 300, "ATTACHED", 0);
			SetRaidProfileSavedPosition(ARENA_PROFILE, 		false, "TOP", 200, "BOTTOM", 400, "ATTACHED", 0);
			SetRaidProfileSavedPosition(BG_PROFILE, 		false, "TOP", 200, "BOTTOM", 300, "ATTACHED", 0);
		end
		
	elseif (XereUICharDB[2] == "healer") then
		if (lowRes) then
			SetRaidProfileSavedPosition(PARTY_PROFILE, 		false, "BOTTOM", 275, "BOTTOM", 100, "LEFT", 500);
			SetRaidProfileSavedPosition(RAID_25_PROFILE, 	false, "TOP", 130, "BOTTOM", 250, "ATTACHED", 0);
			SetRaidProfileSavedPosition(RAID_40_PROFILE, 	false, "TOP", 130, "BOTTOM", 250, "ATTACHED", 0);
			SetRaidProfileSavedPosition(ARENA_PROFILE, 		false, "BOTTOM", 275, "BOTTOM", 100, "LEFT", 500);
			SetRaidProfileSavedPosition(BG_PROFILE, 		false, "TOP", 130, "BOTTOM", 250, "ATTACHED", 0);
		else
			SetRaidProfileSavedPosition(PARTY_PROFILE, 		false, "BOTTOM", 425, "BOTTOM", 100, "LEFT", 775);
			SetRaidProfileSavedPosition(RAID_25_PROFILE, 	false, "BOTTOM", 425, "BOTTOM", 100, "LEFT", 775);
			SetRaidProfileSavedPosition(RAID_40_PROFILE, 	false, "TOP",  200, "BOTTOM", 100, "LEFT", 150);
			SetRaidProfileSavedPosition(ARENA_PROFILE, 		false, "BOTTOM", 425, "BOTTOM", 100, "LEFT", 775);
			SetRaidProfileSavedPosition(BG_PROFILE, 		false, "TOP",  200, "BOTTOM", 100, "LEFT", 150);
		end
		
	else
		print("Chosen profile not recognized.");
	end
end

-- Credit to Grimmj from the WoW-EU-Forums
-- Handles the CompactRaidFrame switching
function switchProfile()
	if InCombatLockdown() == false then --This should fix in-combat issues.
		isArena, _ = IsActiveBattlefieldArena(); 
		if isArena == true then --**IN ARENA**.
			if GetActiveRaidProfile() ~= ARENA_PROFILE then --if arena profile is not active
				CompactUnitFrameProfiles_ActivateRaidProfile(ARENA_PROFILE); --...set arena profile.
			end
			
		elseif InActiveBattlefield() then --**IN BG**.
			if GetActiveRaidProfile() ~= BG_PROFILE then --if battleground profile is not active
				CompactUnitFrameProfiles_ActivateRaidProfile(BG_PROFILE); --...set battleground profile.
			end
			
		elseif GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE) > 0 then --**IN INSTANCE GROUP**
			if GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE) > 25 then
				if GetActiveRaidProfile() ~= RAID_40_PROFILE then -- if Raid40 profile is not active
					CompactUnitFrameProfiles_ActivateRaidProfile(RAID_40_PROFILE); --...set raid40 profile.
				end
			elseif GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE) > 5 then
				if GetActiveRaidProfile() ~= RAID_25_PROFILE then --if Raid25 profile is not active
					CompactUnitFrameProfiles_ActivateRaidProfile(RAID_25_PROFILE); --...set raid25 profile.
				end
			else
				if GetActiveRaidProfile() ~= PARTY_PROFILE then --if Party profile is not active
					CompactUnitFrameProfiles_ActivateRaidProfile(PARTY_PROFILE); --...set Party profile.
				end
			end
			
		elseif GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > 0 then --**IN MANUAL GROUP**
			if GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > 25 then
				if GetActiveRaidProfile() ~= RAID_40_PROFILE then -- if Raid40 profile is not active
					CompactUnitFrameProfiles_ActivateRaidProfile(RAID_40_PROFILE); --...set raid40 profile.
				end
			elseif GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > 5 then
				if GetActiveRaidProfile() ~= RAID_25_PROFILE then --if Raid25 profile is not active
					CompactUnitFrameProfiles_ActivateRaidProfile(RAID_25_PROFILE); --...set raid25 profile.
				end
			else
				if GetActiveRaidProfile() ~= PARTY_PROFILE then --if Party profile is not active
					CompactUnitFrameProfiles_ActivateRaidProfile(PARTY_PROFILE); --...set Party profile.
				end
			end
		end
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


--[[

	========== FRAME AND EVENTHANDLING ==========

]]

local frame = CreateFrame("FRAME", "XereUIFrame");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("GROUP_ROSTER_UPDATE"); --fires when player joins or leaves group
frame:RegisterEvent("PLAYER_REGEN_ENABLED"); --fires when leaving combat
frame:RegisterEvent("COMPACT_UNIT_FRAME_PROFILES_LOADED"); --fires when the CUF is loaded. Happens apparently after entering world and is needed to prevent errors
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
		
	-- switches the raidprofile whenever a group change occurs and is out of combat
	elseif (event == "GROUP_ROSTER_UPDATE") or (event == "PLAYER_REGEN_ENABLED") then
		switchProfile();
		
	-- Manages the Raid-Frames whenever the Player enters the world to ensure functionality
	elseif (event == "COMPACT_UNIT_FRAME_PROFILES_LOADED") then
		manageCUFProfiles();
		createMissingCUFProfiles();
		if (XereUICharDB[3]) then
			positionCUFPRofiles();
			configureCUFProfiles();
		end
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
		
	-- toggles the raid profile positioning	
	elseif (command == "rprofile") then
		XereUICharDB[3] = not XereUICharDB[3];
		ReloadUI();

	-- toggles the nameplate size
	elseif (command == "nameplate") then
		XereUICharDB[4] = not XereUICharDB[4];
		ReloadUI();
		
	-- prints a list of the savedvariables and their values
	elseif (command == "status") then
	
		print("Version: " .. XereUICharDB[1]);
		print("Profile: " .. XereUICharDB[2]);
		
		-- Apparently, lua cannot concatenate booleans to strings ...		
		if (XereUICharDB[3]) then
			print("Raid-Profile positioning: true");
		else
			print("Raid-Profile positioning: false");
		end

		if (XereUICharDB[4]) then
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
		print("    > |cff34d1c9rprofile|r : toggles the raid profile positioning.");
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