local Reconstructed = {}

Reconstructed.ExecuteRemotes = false
Reconstructed.ExecuteMovement = false
Reconstructed.ActionLog = {}

Reconstructed.DefaultGAGConfig = {
	["Harvest"] = {
		["Auto Harvest"] = true,
		["Sell At"] = 85,
		["Sell Every"] = 40,
		["Only Harvest"] = {},
		["Don't Harvest"] = {},
		["Wait For Mutation"] = {},
	},
	["Planting"] = {
		["Auto Plant"] = true,
		["Plant Plan"] = {},
		["Only Plant"] = {},
		["Minimum Seed"] = "Bamboo",
		["Layout"] = "compact",
		["Don't Plant"] = { "Gold", "Rainbow", "Mega" },
		["Don't Buy"] = {},
		["Keep Seeds"] = {},
		["Plant Limit"] = 0,
		["Never Shovel"] = {},
		["Shovel Up To"] = "",
		["Buy Seeds"] = {},
	},
	["Money"] = {
		["Keep Cash"] = 15000,
		["Auto Expand Plot"] = true,
		["Max Expansions"] = 3,
		["Expand If Over"] = 1500000,
		["Auto Replace Plants"] = true,
	},
	["Never Sell"] = {
		["By Mutation"] = {},
		["By Fruit"] = {},
		["Exact"] = {},
	},
	["Pets"] = {
		["Buy"] = { "Unicorn", "GoldenDragonfly", ["Deer"] = 6 },
		["Equip"] = { ["Deer"] = 6 },
		["Auto Buy Slots"] = true,
		["Max Pet Slots"] = 6,
	},
	["Gear"] = {
		["Auto Buy"] = true,
		["Keep Cash"] = 15000,
		["Sprinkler Coverage"] = "concentrate",
		["Place Sprinklers"] = { ["best"] = 4 },
		["Best Sprinkler Up To"] = "Rare Sprinkler",
		["Keep Gear"] = { ["Supersize Mushroom"] = 1 },
		["Buy Gear"] = { "Super Sprinkler", "Legendary Sprinkler" },
	},
	["Event Seeds"] = {
		["Auto Claim"] = true,
	},
	["Mail"] = {
		["Auto Claim"] = true,
		["Send To"] = "",
		["Send Every"] = 0,
		["Send"] = {
			"Moon Bloom",
			"Dragon's Breath",
			"Gold",
			"Rainbow",
			"Deer",
			"GoldenDragonfly",
			"Unicorn",
			"Robin",
			"Raccoon",
			"Turtle",
			"Super Sprinkler",
			"Legendary Sprinkler",
			"Super Watering Can",
		},
	},
	["Misc"] = {
		["Auto Return To Garden"] = true,
		["Show Stats"] = true,
		["Hide Game UI"] = false,
		["Show Console"] = false,
		["Smart Travel"] = true,
		["Auto Daily Deal"] = true,
		["Walk Speed"] = 35,
		["Slide Speed"] = 35,
		["Fast Travel"] = true,
		["Teleport"] = true,
	},
	["Friends"] = {
		["Auto Accept"] = false,
		["Auto Send"] = false,
	},
	["Performance"] = {
		["FPS Cap"] = 0,
		["Low Graphics"] = true,
		["Remove Other Gardens"] = true,
		["Hide Crop Visuals"] = true,
		["Hide Fruit Visuals"] = true,
		["Hide Players"] = true,
	},
	["Debug"] = {
		["Log To File"] = true,
		["Console"] = true,
	},
}

Reconstructed.Config = {
	["Auto Buy Auction"] = false,
	["Select Seed"] = {},
	["Select Gear"] = {},
	["Select Seed Pack"] = {},
	["Select Egg"] = {},
	["Auction Price"] = 0,
	["Auction Price Mode"] = "Below",

	["Auto Sell All"] = false,
	["Allow Sell at Multiplier"] = false,
	["Allow Sell If Backpack Is Max"] = false,
	["Allows Double Or Nothing"] = false,
	["Use Daily Deal"] = false,
	["Delay To Sell Inventory"] = 0.05,

	["Auto Sell Fruit"] = false,
	["Select Sell Fruit"] = {},
	["Select Sell Rarity"] = {},
	["Select Sell Mutation"] = {},
	["Select Threshold Mode"] = "Above",
	["Weight Threshold"] = 0,

	["ESP Fruit Value"] = false,
	["ESP Spawned Pets"] = false,
	["ESP Fruit"] = false,
	["Select ESP Fruit"] = {},
	["Select ESP Rarity"] = {},
	["Select ESP Mutation"] = {},

	["Auto Collect Fruit"] = false,
	["Auto Collect All Fruit"] = false,
	["Stop Collect If Backpack Is Full Max"] = false,
	["Select Fruit"] = {},
	["Select Rarity"] = {},
	["Select Mutation"] = {},
	["Select Filter"] = nil,
	["Disable Teleport"] = false,
	["Delay To Collect"] = 0,

	["Auto Sell Pets"] = false,
	["Select Pets"] = {},
	["Select Rarity Pets"] = {},
	["Select Size Pets"] = {},
}

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local copied = {}

	for key, child in pairs(value) do
		copied[key] = deepCopy(child)
	end

	return copied
end

local function deepMerge(base, override)
	local merged = deepCopy(base)

	if type(override) ~= "table" then
		return merged
	end

	for key, value in pairs(override) do
		if type(value) == "table" and type(merged[key]) == "table" then
			merged[key] = deepMerge(merged[key], value)
		else
			merged[key] = deepCopy(value)
		end
	end

	return merged
end

local function cfg(config, key, default)
	if config[key] ~= nil then
		return config[key]
	end

	if config[key .. " "] ~= nil then
		return config[key .. " "]
	end

	if config[key .. "  "] ~= nil then
		return config[key .. "  "]
	end

	return default
end

local function section(config, name)
	local value = config and config[name]

	if type(value) == "table" then
		return value
	end

	return {}
end

local function safeCall(fn, ...)
	if type(fn) ~= "function" then
		return false
	end

	return pcall(fn, ...)
end

local function safeProp(instance, prop, default)
	if not instance or prop == nil then
		return default
	end

	local success, value = safeCall(function()
		return instance[prop]
	end)

	if success and value ~= nil then
		return value
	end

	return default
end

local function safeSet(instance, prop, value)
	if not instance or prop == nil then
		return false
	end

	local success = safeCall(function()
		instance[prop] = value
	end)

	return success
end

local function toList(value)
	if type(value) == "table" then
		return value
	end

	if value == nil then
		return {}
	end

	return { value }
end

local function QueryChildren(instance)
	if type(safeProp(instance, "GetChildren")) ~= "function" then
		return {}
	end

	local success, children = safeCall(function()
		return instance:GetChildren()
	end)

	if success then
		return toList(children)
	end

	return {}
end

local function QueryDescendants(instance)
	if type(safeProp(instance, "GetDescendants")) ~= "function" then
		return {}
	end

	local success, descendants = safeCall(function()
		return instance:GetDescendants()
	end)

	if success then
		return toList(descendants)
	end

	return {}
end

local function safeRequire(requireModule, module)
	local loader = requireModule

	if not loader and type(require) == "function" then
		loader = require
	end

	if not module or type(loader) ~= "function" then
		return nil
	end

	local success, result = safeCall(loader, module)

	if success then
		return result
	end

	return nil
end

local function safeWait(duration)
	local delay = tonumber(duration) or 0
	local waitFn = task and safeProp(task, "wait")

	if type(waitFn) == "function" then
		local success, result = safeCall(waitFn, delay)

		if success then
			return result
		end
	end

	if type(wait) == "function" then
		local success, result = safeCall(wait, delay)

		if success then
			return result
		end
	end

	return nil
end

local function makeColor(r, g, b)
	if Color3 and Color3.new then
		local success, color = safeCall(function()
			return Color3.new(r, g, b)
		end)

		if success then
			return color
		end
	end

	return { R = r, G = g, B = b }
end

local function makeColorRGB(r, g, b)
	if Color3 and Color3.fromRGB then
		local success, color = safeCall(function()
			return Color3.fromRGB(r, g, b)
		end)

		if success then
			return color
		end
	end

	return makeColor((tonumber(r) or 255) / 255, (tonumber(g) or 255) / 255, (tonumber(b) or 255) / 255)
end

local function colorToRGB(color)
	return math.floor((tonumber(safeProp(color, "R", 1)) or 1) * 255),
		math.floor((tonumber(safeProp(color, "G", 1)) or 1) * 255),
		math.floor((tonumber(safeProp(color, "B", 1)) or 1) * 255)
end

local function getAttr(instance, name)
	if type(safeProp(instance, "GetAttribute")) ~= "function" then
		return nil
	end

	local success, value = safeCall(function()
		return instance:GetAttribute(name)
	end)

	if success then
		return value
	end

	return nil
end

local function numberAttr(instance, name, default)
	local value = tonumber(getAttr(instance, name))

	if value ~= nil then
		return value
	end

	return default
end

local function findChild(instance, name, recursive)
	if type(safeProp(instance, "FindFirstChild")) ~= "function" then
		return nil
	end

	local success, child = safeCall(function()
		return instance:FindFirstChild(name, recursive)
	end)

	if success then
		return child
	end

	return nil
end

local function isTruthySelectionValue(key, value)
	if key == nil or key == "" or key == "None" then
		return false
	end

	if value == false then
		return false
	end

	return true
end

local function selectionContains(selection, value)
	if selection == nil or selection == "" or selection == "None" then
		return true
	end

	if type(selection) == "string" then
		return selection == value
	end

	if type(selection) ~= "table" then
		return true
	end

	local hasSelection = false

	for key, selected in pairs(selection) do
		if type(selected) == "string" and selected ~= "" and selected ~= "None" then
			hasSelection = true

			if selected == value then
				return true
			end
		elseif isTruthySelectionValue(key, selected) then
			hasSelection = true

			if key == value then
				return true
			end
		end
	end

	return not hasSelection
end

local function buildSelectedMap(...)
	local selected = {}

	for index = 1, select("#", ...) do
		local group = select(index, ...)

		if type(group) == "table" then
			for key, value in pairs(group) do
				if isTruthySelectionValue(key, value) then
					selected[key] = true
				end
			end
		elseif type(group) == "string" and group ~= "" and group ~= "None" then
			selected[group] = true
		end
	end

	return selected, next(selected) ~= nil
end

local function passesThreshold(mode, limit, value)
	limit = tonumber(limit)
	value = tonumber(value)

	if not limit or limit == 0 or not value then
		return true
	end

	if mode == "Above" then
		return value > limit
	end

	if mode == "Below" then
		return value < limit
	end

	return true
end

local function randomNonce()
	return math.random(1, 100)
end

local function iterList(value)
	if type(value) == "function" then
		return value
	end

	return ipairs(value or {})
end

local function getService(name)
	if not game or not game.GetService then
		return nil
	end

	local success, service = pcall(function()
		return game:GetService(name)
	end)

	if success then
		return service
	end

	return nil
end

local function getWorkspace(context)
	if context and context.Workspace then
		return context.Workspace
	end

	if workspace then
		return workspace
	end

	return getService("Workspace")
end

local function getReplicatedStorage(context)
	if context and context.ReplicatedStorage then
		return context.ReplicatedStorage
	end

	return getService("ReplicatedStorage")
end

local function getPlayers(context)
	if context and context.Players then
		return context.Players
	end

	return getService("Players")
end

local function getLocalPlayer(context)
	if context and context.LocalPlayer then
		return context.LocalPlayer
	end

	if context and context.Player then
		return context.Player
	end

	local players = getPlayers(context)
	return players and players.LocalPlayer
end

local function shouldExecuteRemotes(context)
	if context and context.ExecuteRemotes ~= nil then
		return context.ExecuteRemotes == true
	end

	return Reconstructed.ExecuteRemotes == true
end

local function shouldExecuteMovement(context)
	if context and context.ExecuteMovement ~= nil then
		return context.ExecuteMovement == true
	end

	return Reconstructed.ExecuteMovement == true
end

local function recordAction(typeName, name, args)
	table.insert(Reconstructed.ActionLog, {
		Type = typeName,
		Name = name,
		Args = args or {},
	})
end

local function isA(instance, className)
	if type(safeProp(instance, "IsA")) ~= "function" then
		return false
	end

	local success, result = safeCall(function()
		return instance:IsA(className)
	end)

	return success and result == true
end

local function selectionMatches(selection, value)
	if value == nil or selection == nil or selection == "" or selection == "None" then
		return false
	end

	value = tostring(value)

	if type(selection) == "string" then
		return selection ~= "" and selection ~= "None" and value:find(selection, 1, true) ~= nil
	end

	if type(selection) ~= "table" then
		return false
	end

	for key, selected in pairs(selection) do
		local candidate = nil

		if type(selected) == "string" then
			candidate = selected
		elseif isTruthySelectionValue(key, selected) then
			candidate = key
		end

		if candidate and candidate ~= "" and candidate ~= "None" and value:find(tostring(candidate), 1, true) then
			return true
		end
	end

	return false
end

local function countSelection(selection)
	local count = 0

	if type(selection) ~= "table" then
		return count
	end

	for key, value in pairs(selection) do
		if isTruthySelectionValue(key, value) then
			count = count + 1
		end
	end

	return count
end

function Reconstructed.EmitRemote(api, remoteName, ...)
	table.insert(Reconstructed.ActionLog, {
		Type = "Remote",
		Name = remoteName,
		Args = { ... },
	})

	local networker = safeProp(api, "Networker")
	local fire = safeProp(networker, "Fire")

	if Reconstructed.ExecuteRemotes and type(fire) == "function" then
		local success, result = safeCall(fire, remoteName, ...)

		if success then
			return result
		end
	end

	return false
end

function Reconstructed.EmitTeleport(api, cframe, reason, condition)
	table.insert(Reconstructed.ActionLog, {
		Type = "Teleport",
		Name = reason,
		Args = { cframe },
	})

	local teleportManager = safeProp(api, "TeleportManager")
	local getTo = safeProp(teleportManager, "GetTo")

	if Reconstructed.ExecuteMovement and type(getTo) == "function" then
		local success, result = safeCall(getTo, cframe, reason, nil, nil, nil, condition)

		if success then
			return result
		end
	end

	return false
end

Reconstructed.Converter = {}

function Reconstructed.Converter.CorrectNumber(text)
	if type(text) ~= "string" then
		return tonumber(text)
	end

	local cleaned = text:gsub(",", ""):gsub("%$", ""):gsub("%s+", "")
	local number = tonumber(cleaned:match("[%d%.]+")) or 0
	local suffix = cleaned:match("[KkMmBbTt]$")

	if suffix == "K" or suffix == "k" then
		return number * 1e3
	end

	if suffix == "M" or suffix == "m" then
		return number * 1e6
	end

	if suffix == "B" or suffix == "b" then
		return number * 1e9
	end

	if suffix == "T" or suffix == "t" then
		return number * 1e12
	end

	return number
end

function Reconstructed.Converter.Abbreviate(value)
	value = tonumber(value) or 0

	if value >= 1e12 then
		return string.format("%.2fT", value / 1e12)
	end

	if value >= 1e9 then
		return string.format("%.2fB", value / 1e9)
	end

	if value >= 1e6 then
		return string.format("%.2fM", value / 1e6)
	end

	if value >= 1e3 then
		return string.format("%.2fK", value / 1e3)
	end

	return tostring(math.floor(value))
end

function Reconstructed.Converter.FormatGrams(weight)
	weight = tonumber(weight) or 0

	if weight >= 1000 then
		return string.format("%.2fkg", weight / 1000)
	end

	return string.format("%.2fg", weight)
end

function Reconstructed.FruitFilter(filterConfig, item, filterMode)
	local selectedFruit = filterConfig and filterConfig[1]
	local selectedRarity = filterConfig and filterConfig[2]
	local selectedMutation = filterConfig and filterConfig[3]
	local threshold = filterConfig and filterConfig[4]

	local itemName = getAttr(item, "CorePartName")
		or getAttr(item, "SeedName")
		or getAttr(item, "ItemName")
		or getAttr(item, "Name")
		or safeProp(item, "Name")

	local rarity = getAttr(item, "Rarity")
	local mutation = getAttr(item, "Mutation")
	local weight = getAttr(item, "Weight")

	if not selectionContains(selectedFruit, itemName) then
		return false
	end

	if not selectionContains(selectedRarity, rarity) then
		return false
	end

	if not selectionContains(selectedMutation, mutation) then
		return false
	end

	if type(threshold) == "table" then
		if not passesThreshold(threshold[1], threshold[2], threshold[3] or weight) then
			return false
		end
	end

	return true
end

function Reconstructed.PetFilter(filterConfig, pet)
	local selectedPets = filterConfig and filterConfig[1]
	local selectedRarity = filterConfig and filterConfig[2]
	local selectedSize = filterConfig and filterConfig[3]

	local petName = getAttr(pet, "PetName") or safeProp(pet, "Name")
	local rarity = getAttr(pet, "Rarity")
	local size = getAttr(pet, "PetSize")

	if not selectionContains(selectedPets, petName) then
		return false
	end

	if not selectionContains(selectedRarity, rarity) then
		return false
	end

	if not selectionContains(selectedSize, size) then
		return false
	end

	return true
end

Reconstructed.Fruit_Misc = {}

function Reconstructed.Fruit_Misc.AddValue(button, data)
	table.insert(Reconstructed.ActionLog, {
		Type = "FruitValueUI",
		Name = safeProp(button, "Name"),
		Args = { data },
	})
end

function Reconstructed.Fruit_Misc.GetTotalFruitValue()
	return 0
end

Reconstructed.ESP = {}

function Reconstructed.ESP.CreateESP(target, options)
	table.insert(Reconstructed.ActionLog, {
		Type = "ESP",
		Name = safeProp(target, "Name"),
		Args = { options },
	})

	if not Instance or not target then
		return nil
	end

	local folder = findChild(target, "ESP") or Instance.new("Folder")
	safeSet(folder, "Name", "ESP")
	safeSet(folder, "Parent", target)

	local billboard = findChild(folder, "BillboardGui") or Instance.new("BillboardGui")
	safeSet(billboard, "Name", "BillboardGui")
	safeSet(billboard, "AlwaysOnTop", true)
	safeSet(billboard, "Size", UDim2.fromOffset(220, 80))
	safeSet(billboard, "Parent", folder)

	local label = findChild(billboard, "TextLabel") or Instance.new("TextLabel")
	safeSet(label, "Name", "TextLabel")
	safeSet(label, "BackgroundTransparency", 1)
	safeSet(label, "Size", UDim2.fromScale(1, 1))
	safeSet(label, "RichText", true)
	safeSet(label, "TextScaled", true)
	safeSet(label, "Text", safeProp(options, "Text", ""))
	safeSet(label, "TextColor3", safeProp(options, "Color", makeColor(1, 1, 1)))
	safeSet(label, "Parent", billboard)

	return folder
end

Reconstructed.Collection = {}

function Reconstructed.Collection.GetPlantList(plantsFolder, result, _, includeAll)
	result = result or {}

	if not plantsFolder then
		return result
	end

	for _, descendant in ipairs(QueryDescendants(plantsFolder)) do
		if getAttr(descendant, "PlantId") then
			table.insert(result, descendant)
		elseif includeAll and getAttr(descendant, "FruitId") then
			table.insert(result, descendant)
		end
	end

	return result
end

Reconstructed.TeleportManager = {}

function Reconstructed.TeleportManager.GetTo(cframe, reason, context, _, _, condition)
	table.insert(Reconstructed.ActionLog, {
		Type = "Teleport",
		Name = reason,
		Args = { cframe },
	})

	if type(condition) == "function" then
		local conditionSuccess, conditionResult = safeCall(condition)

		if conditionSuccess and conditionResult then
			return true
		end
	end

	if shouldExecuteMovement(context) and Reconstructed.TeleportToPositionGAG then
		local success, result = safeCall(Reconstructed.TeleportToPositionGAG, cframe, context, reason)

		if success then
			return result
		end
	end

	return false
end

function Reconstructed.TeleportManager.Reset(reason)
	table.insert(Reconstructed.ActionLog, {
		Type = "TeleportReset",
		Name = reason,
		Args = {},
	})
end

function Reconstructed.IsMaxInventory(playerStats)
	local count = numberAttr(playerStats, "FruitCount", 0)
	local max = numberAttr(playerStats, "MaxFruitCapacity", math.huge)

	return count >= max
end

function Reconstructed.IsOnGarden()
	return false
end

function Reconstructed.GetOwnerPlot()
	return nil
end

function Reconstructed.GetAllTool(player)
	local tools = {}

	if player and player.Backpack then
		for _, item in ipairs(QueryChildren(player.Backpack)) do
			if isA(item, "Tool") then
				table.insert(tools, item)
			end
		end
	end

	if player and player.Character then
		for _, item in ipairs(QueryChildren(player.Character)) do
			if isA(item, "Tool") then
				table.insert(tools, item)
			end
		end
	end

	return tools
end

function Reconstructed.GetUserGAGConfig()
	if type(_G) == "table" and type(_G.GAGConfig) == "table" then
		return _G.GAGConfig
	end

	return {}
end

function Reconstructed.GetEffectiveGAGConfig(userConfig)
	return deepMerge(Reconstructed.DefaultGAGConfig, userConfig or Reconstructed.GetUserGAGConfig())
end

function Reconstructed.BuildLegacyConfig(gagConfig)
	gagConfig = gagConfig or Reconstructed.GetEffectiveGAGConfig()

	local harvest = section(gagConfig, "Harvest")
	local planting = section(gagConfig, "Planting")
	local neverSell = section(gagConfig, "Never Sell")
	local pets = section(gagConfig, "Pets")
	local misc = section(gagConfig, "Misc")

	local autoHarvest = cfg(harvest, "Auto Harvest", true)
	local legacy = deepCopy(Reconstructed.Config)

	legacy["Auto Sell All"] = autoHarvest
	legacy["Allow Sell If Backpack Is Max"] = true
	legacy["Delay To Sell Inventory"] = cfg(harvest, "Sell Every", 40)
	legacy["Auto Collect Fruit"] = autoHarvest
	legacy["Auto Collect All Fruit"] = autoHarvest
	legacy["Stop Collect If Backpack Is Full Max"] = true
	legacy["Select Fruit"] = cfg(harvest, "Only Harvest", {})
	legacy["Select Sell Fruit"] = cfg(neverSell, "By Fruit", {})
	legacy["Select Sell Mutation"] = cfg(neverSell, "By Mutation", {})
	legacy["Disable Teleport"] = not cfg(misc, "Teleport", true)
	legacy["Auto Sell Pets"] = false
	legacy["Select Pets"] = cfg(pets, "Buy", {})
	legacy["Auto Buy Auction"] = false
	legacy["Select Seed"] = cfg(planting, "Buy Seeds", {})

	return legacy
end

function Reconstructed.ValidateGAGConfig(gagConfig)
	local warnings = {}
	gagConfig = gagConfig or Reconstructed.GetEffectiveGAGConfig()

	local function expect(sectionName, key, expectedType)
		local value = section(gagConfig, sectionName)[key]

		if value ~= nil and type(value) ~= expectedType then
			table.insert(warnings, sectionName .. "." .. key .. " expected " .. expectedType .. ", got " .. type(value))
		end
	end

	expect("Harvest", "Auto Harvest", "boolean")
	expect("Harvest", "Sell At", "number")
	expect("Harvest", "Sell Every", "number")
	expect("Planting", "Auto Plant", "boolean")
	expect("Planting", "Minimum Seed", "string")
	expect("Planting", "Layout", "string")
	expect("Money", "Keep Cash", "number")
	expect("Pets", "Auto Buy Slots", "boolean")
	expect("Gear", "Auto Buy", "boolean")
	expect("Mail", "Send To", "string")
	expect("Misc", "Fast Travel", "boolean")
	expect("Performance", "Low Graphics", "boolean")

	return warnings
end

function Reconstructed.CreateDefaultApi()
	return {
		Networker = {
			Fire = function(remoteName, ...)
				return Reconstructed.EmitRemote(nil, remoteName, ...)
			end,
		},

		Converter = Reconstructed.Converter,
		FruitFilter = Reconstructed.FruitFilter,
		PetFilter = Reconstructed.PetFilter,
		Fruit_Misc = Reconstructed.Fruit_Misc,
		ESP = Reconstructed.ESP,
		Collection = Reconstructed.Collection,
		TeleportManager = Reconstructed.TeleportManager,
		GetOwnerPlot = Reconstructed.GetOwnerPlot,
	}
end

function Reconstructed.AutoBuyAuction(config, auctionGui, playerData, api)
	api = api or Reconstructed.CreateDefaultApi()

	local auction = findChild(auctionGui, "Auction")
	if not auction then
		return
	end

	local frame = findChild(auction, "Frame")
	local list = frame and findChild(frame, "ScrollingFrame")
	if not frame or not list then
		return
	end

	local selectedItems, hasFilter = buildSelectedMap(
		cfg(config, "Select Seed", {}),
		cfg(config, "Select Gear", {}),
		cfg(config, "Select Seed Pack", {}),
		cfg(config, "Select Egg", {})
	)

	local priceLimit = cfg(config, "Auction Price", 0) or 0
	local priceMode = cfg(config, "Auction Price Mode", "Below")

	for _, lotFrame in ipairs(QueryChildren(list)) do
		if not cfg(config, "Auto Buy Auction", false) then
			break
		end

		if not isA(lotFrame, "Frame") then
			continue
		end

		local outOfStock = findChild(lotFrame, "OUT_OF_STOCK", true)
		local expired = findChild(lotFrame, "EXPIRED", true)

		if safeProp(outOfStock, "Visible", false) or safeProp(expired, "Visible", false) then
			continue
		end

		if hasFilter then
			local itemName = findChild(lotFrame, "ItemName", true)
			local itemText = safeProp(itemName, "Text", "")

			if not itemName or not selectedItems[itemText] then
				continue
			end
		end

		local lotInnerFrame = safeProp(lotFrame, "Frame")
		local mainFrame = lotInnerFrame and findChild(lotInnerFrame, "Main_Frame")
		local buyButton = mainFrame and findChild(mainFrame, "BuyButton")
		local textFrame = buyButton and findChild(buyButton, "Text")
		local priceLabel = textFrame and findChild(textFrame, "TextLabel")

		if not priceLabel then
			continue
		end

		local price = api.Converter.CorrectNumber(safeProp(priceLabel, "ContentText", safeProp(priceLabel, "Text", "")))

		if not price or price == 0 then
			continue
		end

		if playerData and playerData.GetCurrentCash and playerData:GetCurrentCash() < price then
			continue
		end

		if priceLimit ~= 0 then
			if priceMode == "Above" and price <= priceLimit then
				continue
			end

			if priceMode == "Below" and price >= priceLimit then
				continue
			end
		end

		Reconstructed.EmitRemote(api, "AuctioneerPurchaseLot", tostring(safeProp(lotFrame, "Name", "")):gsub("Lot_", ""), price)
		break
	end

	safeWait(0.3)
end

function Reconstructed.AutoSellAll(config, api, inventory, playerStats, canSellByMultiplier)
	api = api or Reconstructed.CreateDefaultApi()

	if not cfg(config, "Auto Sell All", false) then
		return
	end

	if numberAttr(playerStats, "FruitCount", 0) == 0 then
		return
	end

	if cfg(config, "Allow Sell at Multiplier", false) and canSellByMultiplier and not canSellByMultiplier() then
		return
	end

	local shouldSell = not cfg(config, "Allow Sell If Backpack Is Max", false)
		or (inventory and inventory.IsMaxInventory and inventory.IsMaxInventory())

	if not shouldSell then
		return
	end

	if cfg(config, "Allows Double Or Nothing", false) then
		Reconstructed.EmitRemote(api, "DoubleOrNothing", randomNonce())
		safeWait(0.1)
		Reconstructed.EmitRemote(api, "CashOutDoubleOrNothing", randomNonce())
		safeWait(0.1)
	end

	if cfg(config, "Use Daily Deal", false) then
		Reconstructed.EmitRemote(api, "UseDailyDealAll", randomNonce())
	end

	Reconstructed.EmitRemote(api, "SellAll", randomNonce())
	safeWait(tonumber(cfg(config, "Delay To Sell Inventory", 0.05)) or 0.05)
end

function Reconstructed.AutoSellFruit(config, canSellByMultiplier, playerStats, api, toolManager, player)
	api = api or Reconstructed.CreateDefaultApi()

	if numberAttr(playerStats, "FruitCount", 0) == 0 then
		return
	end

	if cfg(config, "Allow Sell at Multiplier", false) and canSellByMultiplier and not canSellByMultiplier() then
		return
	end

	local tools = toolManager and toolManager.GetAllTool and toolManager.GetAllTool() or Reconstructed.GetAllTool(player)

	for _, tool in iterList(tools) do
		if not cfg(config, "Auto Sell Fruit", false) then
			break
		end

		if cfg(config, "Allow Sell at Multiplier", false) and canSellByMultiplier and not canSellByMultiplier() then
			break
		end

		if not getAttr(tool, "HarvestedFruit") then
			continue
		end

		if getAttr(tool, "IsFavorite") then
			continue
		end

		local filter = {
			cfg(config, "Select Sell Fruit", {}),
			cfg(config, "Select Sell Rarity", {}),
			cfg(config, "Select Sell Mutation", {}),
			{
				cfg(config, "Select Threshold Mode", "Above"),
				cfg(config, "Weight Threshold", 0),
				getAttr(tool, "Weight"),
			},
		}

		if not api.FruitFilter(filter, tool) then
			continue
		end

		local fruitId = getAttr(tool, "Id")
		if not fruitId then
			continue
		end

		if cfg(config, "Use Daily Deal", false) then
			Reconstructed.EmitRemote(api, "UseDailyDealSingle", randomNonce(), fruitId)
		end

		Reconstructed.EmitRemote(api, "SellFruit", randomNonce(), fruitId)
		safeWait(0.1)
	end

	safeWait(0.5)
end

function Reconstructed.ESPFruitValue(gui, api, config)
	api = api or Reconstructed.CreateDefaultApi()

	local backpackGui = findChild(gui, "BackpackGui")
	local backpack = backpackGui and findChild(backpackGui, "Backpack")
	if not backpack then
		return
	end

	for _, button in ipairs(QueryDescendants(backpack)) do
		if not cfg(config, "ESP Fruit Value", false) then
			break
		end

		if isA(button, "TextButton") then
			local count = findChild(button, "ToolCount")
			local name = findChild(button, "ToolName")

			if count and name then
				api.Fruit_Misc.AddValue(button, {
					Weight = safeProp(count, "Text", ""),
					Name = safeProp(name, "Text", ""),
				})
			end
		end
	end

	safeWait(2)
end

function Reconstructed.ShowFruitInventoryValue(gui, playerStats, api)
	api = api or Reconstructed.CreateDefaultApi()

	local backpackGui = findChild(gui, "BackpackGui")
	local backpack = backpackGui and findChild(backpackGui, "Backpack")
	local inventory = backpack and findChild(backpack, "Inventory")
	local fruitInventory = inventory and findChild(inventory, "FruitInventory")

	if not fruitInventory then
		return
	end

	local countText = tostring(getAttr(playerStats, "FruitCount")) .. "/" .. tostring(getAttr(playerStats, "MaxFruitCapacity")) .. " Fruits"
	local totalValue = api.Fruit_Misc.GetTotalFruitValue()

	safeSet(fruitInventory, "Visible", true)
	safeSet(fruitInventory, "RichText", true)
	safeSet(fruitInventory, "Text", countText .. ' | <font color="rgb(0,255,0)">$' .. tostring(api.Converter.Abbreviate(totalValue)) .. "</font>")

	safeWait(1.5)
end

function Reconstructed.ESPSpawnedPets(config, api, sharedModules)
	api = api or Reconstructed.CreateDefaultApi()

	local map = workspace and workspace:FindFirstChild("Map")
	local spawns = map and map:FindFirstChild("WildPetSpawns")
	local refs = map and map:FindFirstChild("WildPetRef")

	if not spawns or not refs then
		return
	end

	local rarityData = sharedModules and sharedModules:FindFirstChild("RarityData")
	local gradients = rarityData and rarityData:FindFirstChild("Gradients")

	for _, spawnModel in ipairs(QueryChildren(spawns)) do
		if not cfg(config, "ESP Spawned Pets", false) then
			break
		end

		if not isA(spawnModel, "Model") then
			continue
		end

		local guid = tostring(safeProp(spawnModel, "Name", "")):match("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x")
		local petRef = guid and refs:FindFirstChild("WildPet_" .. guid)

		if not petRef then
			continue
		end

		if not api.PetFilter({
			cfg(config, "Select Pets", {}),
			cfg(config, "Select Rarity Pets", {}),
			cfg(config, "Select Size Pets", {}),
		}, petRef) then
			continue
		end

		local petName = getAttr(petRef, "PetName")
		local rarity = getAttr(petRef, "Rarity")
		local size = getAttr(petRef, "PetSize")
		local price = getAttr(petRef, "Price")

		if not petName or not rarity then
			continue
		end

		local gradient = gradients and findChild(gradients, rarity)
		local gradientColor = safeProp(gradient, "Color")
		local keypoints = toList(safeProp(gradientColor, "Keypoints"))
		local keypoint = keypoints[math.floor(#keypoints / 2) + 1]
		local color = safeProp(keypoint, "Value", makeColor(1, 1, 1))
		local red, green, blue = colorToRGB(color)

		local text = '<font color="rgb(255,255,255)">' .. petName .. '</font> [ <font color="rgb(' .. red .. "," .. green .. "," .. blue .. ')">' .. rarity .. "</font> ]"

		if price then
			text = text .. ' <font color="rgb(255,200,0)">[ $' .. tostring(api.Converter.Abbreviate(price)) .. " ]</font>"
		end

		if size and size ~= "" then
			text = text .. '\n<font color="rgb(255,255,0)">' .. tostring(size) .. "</font>"
		end

		local esp = findChild(spawnModel, "ESP")

		if not esp then
			api.ESP.CreateESP(spawnModel, {
				Color = makeColorRGB(red, green, blue),
				Text = text,
			})
		else
			local billboard = findChild(esp, "BillboardGui", true)
			local label = billboard and findChild(billboard, "TextLabel")

			if label and safeProp(label, "Text", "") ~= text then
				safeSet(label, "Text", text)
			end
		end
	end

	safeWait(2)
end

function Reconstructed.AutoCollectFruit(config, api, localPlayer, playerState, requireModule, inventory)
	api = api or Reconstructed.CreateDefaultApi()

	local plot = api.GetOwnerPlot()
	local plantsFolder = plot and plot:FindFirstChild("Plants")

	if not plantsFolder then
		return
	end

	local spawnPoint = plot and plot:FindFirstChild("SpawnPoint")
	local plants = api.Collection.GetPlantList(plantsFolder, {})

	if not plants then
		return
	end

	local playerScripts = localPlayer and localPlayer:FindFirstChild("PlayerScripts")
	local controllers = playerScripts and playerScripts:FindFirstChild("Controllers")
	local fruitVisualizerModule = controllers and findChild(controllers, "FruitVisualizerController")
	local fruitVisualizer = safeRequire(requireModule, fruitVisualizerModule)

	for _, plant in ipairs(plants) do
		if not cfg(config, "Auto Collect Fruit", false) then
			break
		end

		if cfg(config, "Stop Collect If Backpack Is Full Max", false) and inventory and inventory.IsMaxInventory and inventory.IsMaxInventory() then
			break
		end

		local plantId = getAttr(plant, "PlantId")
		local fruitId = getAttr(plant, "FruitId") or ""

		if not plantId then
			continue
		end

		local weight = getAttr(plant, "Weight") or 0

		if fruitVisualizer then
			if fruitId ~= "" and fruitVisualizer.CalculateFruitWeight then
				weight = fruitVisualizer:CalculateFruitWeight(plant)
			elseif fruitVisualizer.CalculatePlantWeight then
				weight = fruitVisualizer:CalculatePlantWeight(plant)
			end
		end

		local filter = {
			cfg(config, "Select Fruit", {}),
			cfg(config, "Select Rarity", {}),
			cfg(config, "Select Mutation", {}),
			{
				cfg(config, "Select Threshold Mode", "Above"),
				cfg(config, "Weight Threshold", 0),
				weight,
			},
		}

		if not api.FruitFilter(filter, plant, cfg(config, "Select Filter", nil)) then
			continue
		end

		if spawnPoint and not cfg(config, "Disable Teleport", false) and playerState and safeProp(playerState, "IsOnGarden") and not playerState:IsOnGarden() then
			Reconstructed.EmitTeleport(api, safeProp(spawnPoint, "CFrame"), "Auto Collect Fruit", function()
				return playerState:IsOnGarden()
			end)
			return
		end

		if cfg(config, "Delay To Collect", 0) ~= 0 then
			safeWait(cfg(config, "Delay To Collect", 0) or 0)
		end

		Reconstructed.EmitRemote(api, "CollectFruit", plantId, fruitId)
		safeWait(0.01)
	end

	if api.TeleportManager and api.TeleportManager.Reset then
		api.TeleportManager.Reset("Auto Collect Fruit")
	end

	safeWait(0.5)
end

function Reconstructed.AutoCollectAllFruit(config, api, playerState, inventory)
	api = api or Reconstructed.CreateDefaultApi()

	local plot = api.GetOwnerPlot()
	local plantsFolder = plot and plot:FindFirstChild("Plants")

	if not plantsFolder then
		return
	end

	local spawnPoint = plot and plot:FindFirstChild("SpawnPoint")
	local plants = api.Collection.GetPlantList(plantsFolder, {})

	if not plants then
		return
	end

	for _, plant in ipairs(plants) do
		if not cfg(config, "Auto Collect All Fruit", false) then
			break
		end

		if cfg(config, "Stop Collect If Backpack Is Full Max", false) and inventory and inventory.IsMaxInventory and inventory.IsMaxInventory() then
			break
		end

		local plantId = getAttr(plant, "PlantId")
		local fruitId = getAttr(plant, "FruitId") or ""

		if not plantId then
			continue
		end

		if spawnPoint and not cfg(config, "Disable Teleport", false) and playerState and safeProp(playerState, "IsOnGarden") and not playerState:IsOnGarden() then
			Reconstructed.EmitTeleport(api, safeProp(spawnPoint, "CFrame"), "Auto Collect All Fruit", function()
				return playerState:IsOnGarden()
			end)
			return
		end

		if cfg(config, "Delay To Collect", 0) ~= 0 then
			safeWait(cfg(config, "Delay To Collect", 0) or 0)
		end

		Reconstructed.EmitRemote(api, "CollectFruit", plantId, fruitId)
		safeWait(0.01)
	end

	if api.TeleportManager and api.TeleportManager.Reset then
		api.TeleportManager.Reset("Auto Collect All Fruit")
	end

	safeWait(0.5)
end

function Reconstructed.ESPFruit(config, localPlayer, api, sharedModules, requireModule)
	api = api or Reconstructed.CreateDefaultApi()

	local plot = api.GetOwnerPlot()
	local plantsFolder = plot and plot:FindFirstChild("Plants")

	if not plantsFolder then
		return
	end

	local plants = api.Collection.GetPlantList(plantsFolder, {}, nil, true)

	if not plants then
		return
	end

	local playerScripts = localPlayer and localPlayer:FindFirstChild("PlayerScripts")
	local controllers = playerScripts and playerScripts:FindFirstChild("Controllers")
	local fruitVisualizerModule = controllers and findChild(controllers, "FruitVisualizerController")
	local fruitValueCalcModule = sharedModules and findChild(sharedModules, "FruitValueCalc")
	local fruitVisualizer = safeRequire(requireModule, fruitVisualizerModule)
	local calculateValue = safeRequire(requireModule, fruitValueCalcModule)

	for _, plant in ipairs(plants) do
		if not cfg(config, "ESP Fruit", false) then
			break
		end

		local plantId = getAttr(plant, "PlantId")
		if not plantId then
			continue
		end

		local fruitId = getAttr(plant, "FruitId") or ""
		local weight = getAttr(plant, "Weight") or 0

		if fruitVisualizer then
			if fruitId ~= "" and fruitVisualizer.CalculateFruitWeight then
				weight = fruitVisualizer:CalculateFruitWeight(plant)
			elseif fruitVisualizer.CalculatePlantWeight then
				weight = fruitVisualizer:CalculatePlantWeight(plant)
			end
		end

		if not api.FruitFilter({
			cfg(config, "Select ESP Fruit", {}),
			cfg(config, "Select ESP Rarity", {}),
			cfg(config, "Select ESP Mutation", {}),
		}, plant) then
			continue
		end

		local name = getAttr(plant, "CorePartName") or getAttr(plant, "SeedName") or safeProp(plant, "Name", "")
		local mutation = getAttr(plant, "Mutation")
		local weightText = api.Converter.FormatGrams(weight)
		local value = 0

		if calculateValue then
			local success, result = pcall(
				calculateValue,
				name,
				getAttr(plant, "SizeMulti") or 1,
				mutation,
				localPlayer,
				nil
			)

			if success and type(result) == "number" then
				value = result
			end
		end

		local colorPart = findChild(plant, "1")
		local color = safeProp(colorPart, "Color", makeColor(1, 1, 1))
		local red, green, blue = colorToRGB(color)
		local mutationText = ""

		if mutation and mutation ~= "" then
			mutationText = string.format('\n<font color="rgb(%d,%d,%d)">%s</font>', red, green, blue, mutation)
		end

		local valueText = string.format(
			'<font color="rgb(255,255,255)">[ </font><font color="rgb(0,255,0)">$%s</font><font color="rgb(255,255,255)"> ]</font>',
			api.Converter.Abbreviate(value)
		)

		local labelText = string.format(
			'<font color="rgb(255,255,255)">%s [ </font><font color="rgb(200,200,200)">%s</font><font color="rgb(255,255,255)"> ]</font> %s%s',
			name,
			weightText,
			valueText,
			mutationText
		)

		local esp = findChild(plant, "ESP")

		if not esp then
			api.ESP.CreateESP(plant, {
				Color = color,
				Text = labelText,
			})
		else
			local billboard = findChild(esp, "BillboardGui", true)
			local textLabel = billboard and findChild(billboard, "TextLabel")

			if textLabel and safeProp(textLabel, "Text", "") ~= labelText then
				safeSet(textLabel, "Text", labelText)
			end
		end
	end

	safeWait(2)
end

function Reconstructed.AutoSellPets(config, api, toolManager, player)
	api = api or Reconstructed.CreateDefaultApi()

	local tools = toolManager and toolManager.GetAllTool and toolManager.GetAllTool() or Reconstructed.GetAllTool(player)

	for _, tool in iterList(tools) do
		if not cfg(config, "Auto Sell Pets", false) then
			break
		end

		if not getAttr(tool, "PetId") then
			continue
		end

		if getAttr(tool, "IsFavorite") then
			continue
		end

		if not api.PetFilter({
			cfg(config, "Select Pets", {}),
			cfg(config, "Select Rarity Pets", {}),
			cfg(config, "Select Size Pets", {}),
		}, tool) then
			continue
		end

		local petId = getAttr(tool, "PetId")

		if not petId then
			continue
		end

		Reconstructed.EmitRemote(api, "SellPet", randomNonce(), petId)
		safeWait(0.1)
	end

	safeWait(0.5)
end

Reconstructed.GAG2SeedNames = {
	Carrot = true,
	Strawberry = true,
	Blueberry = true,
	Tulip = true,
	Tomato = true,
	Apple = true,
	Bamboo = true,
	Corn = true,
	Cactus = true,
	Pineapple = true,
	Mushroom = true,
	["Green Bean"] = true,
}

Reconstructed.GAG2SeedRank = {
	Carrot = 1,
	Strawberry = 2,
	Blueberry = 3,
	Tulip = 4,
	Tomato = 5,
	Apple = 6,
	Bamboo = 7,
	Corn = 8,
	Cactus = 9,
	Pineapple = 10,
	Mushroom = 11,
	["Green Bean"] = 12,
}

local function getValueObjectValue(instance)
	if not instance then
		return nil
	end

	local success, value = safeCall(function()
		return safeProp(instance, "Value")
	end)

	if success then
		return value
	end

	return nil
end

local function hasSelection(selection)
	if type(selection) == "string" then
		return selection ~= "" and selection ~= "None"
	end

	return countSelection(selection) > 0
end

local function getPlantDisplayName(plant)
	return getAttr(plant, "CorePartName")
		or getAttr(plant, "SeedName")
		or getAttr(plant, "ItemName")
		or getAttr(plant, "DisplayName")
		or safeProp(plant, "Name")
end

local function getPlantMutation(plant)
	local mutation = getAttr(plant, "Mutation")

	if mutation ~= nil and mutation ~= "" then
		return mutation
	end

	local mutationChild = findChild(plant, "Mutation", true) or findChild(plant, "Mutated", true)
	local value = getValueObjectValue(mutationChild)

	if value ~= nil then
		return value
	end

	return safeProp(mutationChild, "Name")
end

local function getCharacterParts(player)
	local character = safeProp(player, "Character")
	local humanoid = nil
	local rootPart = nil

	if character then
		if type(safeProp(character, "FindFirstChildOfClass")) == "function" then
			local success, foundHumanoid = safeCall(function()
				return character:FindFirstChildOfClass("Humanoid")
			end)

			if success then
				humanoid = foundHumanoid
			end
		end

		humanoid = humanoid or findChild(character, "Humanoid")
		rootPart = findChild(character, "HumanoidRootPart") or safeProp(character, "PrimaryPart")
	end

	return character, humanoid, rootPart
end

local function setVisualHidden(instance)
	if not instance then
		return false
	end

	local changed = false

	if isA(instance, "BasePart") then
		safeSet(instance, "LocalTransparencyModifier", 1)
		safeSet(instance, "Transparency", 1)
		changed = true
	elseif isA(instance, "Decal") or isA(instance, "Texture") then
		safeSet(instance, "Transparency", 1)
		changed = true
	elseif isA(instance, "ParticleEmitter") or isA(instance, "Trail") or isA(instance, "Beam") then
		safeSet(instance, "Enabled", false)
		changed = true
	end

	return changed
end

local function hideVisualTree(root)
	local changed = 0

	if setVisualHidden(root) then
		changed = changed + 1
	end

	for _, descendant in ipairs(QueryDescendants(root)) do
		if setVisualHidden(descendant) then
			changed = changed + 1
		end
	end

	return changed
end

local function recordPlanner(featureName, payload)
	recordAction("Stub", featureName, { payload })
end

function Reconstructed.GetGarden(context)
	context = context or {}

	local currentWorkspace = getWorkspace(context)
	local player = getLocalPlayer(context)
	local gardens = currentWorkspace and (findChild(currentWorkspace, "Gardens") or findChild(currentWorkspace, "Farms"))

	if not gardens then
		return nil
	end

	local ownerName = context.Owner or safeProp(player, "Name")
	local ownerUserId = context.OwnerUserId or safeProp(player, "UserId")

	for _, garden in ipairs(QueryChildren(gardens)) do
		local ownerObject = findChild(garden, "Owner")
		local ownerValue = getValueObjectValue(ownerObject)
		local gardenOwner = getAttr(garden, "Owner")
		local gardenOwnerUserId = getAttr(garden, "OwnerUserId")

		if ownerName and (ownerValue == ownerName or gardenOwner == ownerName) then
			return garden
		end

		if ownerUserId and gardenOwnerUserId and tostring(gardenOwnerUserId) == tostring(ownerUserId) then
			return garden
		end
	end

	return nil
end

function Reconstructed.GetOwnerPlot(context)
	local garden = Reconstructed.GetGarden(context)

	if not garden then
		return nil
	end

	return findChild(garden, "Plot") or garden
end

function Reconstructed.GetPlotPlants(plot)
	return plot and (findChild(plot, "Plants") or findChild(plot, "Crops"))
end

function Reconstructed.GetPlotVisual(plot)
	return plot and findChild(plot, "Visual")
end

function Reconstructed.GetBackpack(player)
	return player and findChild(player, "Backpack")
end

function Reconstructed.GetInventoryCounts(player)
	local counts = {}
	local total = 0
	local sources = {
		Reconstructed.GetBackpack(player),
		player and player.Character,
	}

	for _, source in ipairs(sources) do
		for _, item in ipairs(QueryChildren(source)) do
			if isA(item, "Tool") then
				local itemName = safeProp(item, "Name", "")
				counts[itemName] = (counts[itemName] or 0) + 1
				total = total + 1
			end
		end
	end

	return counts, total
end

function Reconstructed.GetSheckles(player)
	local leaderstats = player and findChild(player, "leaderstats")
	local sheckles = leaderstats and (findChild(leaderstats, "Sheckles") or findChild(leaderstats, "Money"))
	local value = getValueObjectValue(sheckles)

	return tonumber(value) or 0
end

function Reconstructed.FindPromptByAction(root, actionText, promptName)
	local function matches(prompt)
		if not isA(prompt, "ProximityPrompt") then
			return false
		end

		if promptName and safeProp(prompt, "Name") ~= promptName then
			return false
		end

		if actionText then
			local success, text = safeCall(function()
				return safeProp(prompt, "ActionText")
			end)

			if not success or text ~= actionText then
				return false
			end
		end

		return true
	end

	if matches(root) then
		return root
	end

	for _, descendant in ipairs(QueryDescendants(root)) do
		if matches(descendant) then
			return descendant
		end
	end

	return nil
end

function Reconstructed.FindHarvestPrompt(plant)
	return Reconstructed.FindPromptByAction(plant, "Harvest") or Reconstructed.FindPromptByAction(plant, nil, "HarvestPrompt")
end

function Reconstructed.ShouldHarvestGAG(plant, gagConfig)
	gagConfig = gagConfig or Reconstructed.GetEffectiveGAGConfig()

	local harvest = section(gagConfig, "Harvest")
	if not cfg(harvest, "Auto Harvest", true) then
		return false
	end

	if not Reconstructed.FindHarvestPrompt(plant) then
		return false
	end

	local plantName = getPlantDisplayName(plant)
	local mutation = getPlantMutation(plant)

	if hasSelection(cfg(harvest, "Only Harvest", {})) and not selectionMatches(cfg(harvest, "Only Harvest", {}), plantName) then
		return false
	end

	if selectionMatches(cfg(harvest, "Don't Harvest", {}), plantName) then
		return false
	end

	if selectionMatches(cfg(harvest, "Wait For Mutation", {}), plantName) and (not mutation or mutation == false or mutation == "") then
		return false
	end

	local neverSell = section(gagConfig, "Never Sell")
	if selectionMatches(cfg(neverSell, "By Fruit", {}), plantName) then
		return false
	end

	if selectionMatches(cfg(neverSell, "By Mutation", {}), mutation) or selectionMatches(cfg(neverSell, "By Mutation", {}), plantName) then
		return false
	end

	local exact = cfg(neverSell, "Exact", {})
	if type(exact) == "table" then
		for _, entry in pairs(exact) do
			if type(entry) == "string" and plantName == entry then
				return false
			elseif type(entry) == "table" then
				local fruit = entry.fruit or entry.Fruit or entry[1]
				local mut = entry.mut or entry.Mutation or entry[2]

				if fruit and plantName and plantName:find(tostring(fruit), 1, true) and (not mut or tostring(mutation) == tostring(mut) or plantName:find(tostring(mut), 1, true)) then
					return false
				end
			end
		end
	end

	return true
end

function Reconstructed.HarvestPlantByPrompt(plant, context, gagConfig)
	local prompt = Reconstructed.FindHarvestPrompt(plant)
	recordAction("HarvestPrompt", safeProp(plant, "Name"), { safeProp(prompt, "Name") })

	if not prompt then
		return false
	end

	if shouldExecuteRemotes(context) and type(fireproximityprompt) == "function" then
		local success = pcall(function()
			fireproximityprompt(prompt)
		end)

		return success
	end

	return false
end

function Reconstructed.HarvestAllByPrompt(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local plot = context.Plot or Reconstructed.GetOwnerPlot(context)
	local plantsFolder = Reconstructed.GetPlotPlants(plot)
	local harvested = 0

	if not plantsFolder then
		return harvested
	end

	for _, plant in ipairs(QueryChildren(plantsFolder)) do
		if Reconstructed.ShouldHarvestGAG(plant, gagConfig) and Reconstructed.HarvestPlantByPrompt(plant, context, gagConfig) then
			harvested = harvested + 1
			safeWait(0.15)
		end
	end

	return harvested
end

function Reconstructed.CollectDroppedFruitGAG(context)
	context = context or {}

	local currentWorkspace = getWorkspace(context)
	local dropped = currentWorkspace and findChild(currentWorkspace, "DroppedItems")
	local pickedUp = 0

	if not dropped then
		return pickedUp
	end

	for _, item in ipairs(QueryChildren(dropped)) do
		if getAttr(item, "ItemCategory") == "HarvestedFruits" then
			local prompt = Reconstructed.FindPromptByAction(item, "Pick Up", "PickupPrompt")
				or Reconstructed.FindPromptByAction(item, nil, "PickupPrompt")
			recordAction("PickupPrompt", safeProp(item, "Name"), { safeProp(prompt, "Name") })

			if prompt and shouldExecuteRemotes(context) and type(fireproximityprompt) == "function" then
				local success = pcall(function()
					fireproximityprompt(prompt)
				end)

				if success then
					pickedUp = pickedUp + 1
					safeWait(0.15)
				end
			end
		end
	end

	return pickedUp
end

function Reconstructed.GetNetworkingGAG2(context)
	context = context or {}

	local replicatedStorage = getReplicatedStorage(context)
	local sharedModules = replicatedStorage and findChild(replicatedStorage, "SharedModules")
	local networkingModule = sharedModules and findChild(sharedModules, "Networking")
	return safeRequire(context.Require, networkingModule)
end

Reconstructed.NetworkingDumpGAG2 = Reconstructed.NetworkingDumpGAG2 or {}
Reconstructed.NetworkingIndexGAG2 = Reconstructed.NetworkingIndexGAG2 or {}
Reconstructed.PacketAttemptsGAG2 = Reconstructed.PacketAttemptsGAG2 or {}

local function valueTypeGAG2(value)
	if type(typeof) == "function" then
		local success, result = safeCall(typeof, value)

		if success then
			return result
		end
	end

	return type(value)
end

local function getPacketCallableFlagsGAG2(node)
	local nodeType = type(node)

	return {
		HasFire = type(safeProp(node, "Fire")) == "function",
		HasInvoke = type(safeProp(node, "Invoke")) == "function",
		HasFireServer = type(safeProp(node, "FireServer")) == "function",
		HasInvokeServer = type(safeProp(node, "InvokeServer")) == "function",
		HasCall = nodeType == "function" or type(safeProp(node, "Call")) == "function",
	}
end

local function hasPacketCallableGAG2(entry)
	return entry.HasFire or entry.HasInvoke or entry.HasFireServer or entry.HasInvokeServer or entry.HasCall
end

local function pathChildGAG2(path, key)
	local keyText = tostring(key)

	if type(key) == "number" then
		return path .. "[" .. keyText .. "]"
	end

	if path == "" then
		return keyText
	end

	return path .. "." .. keyText
end

local function listValuesGAG2(value)
	local list = {}

	if type(value) == "table" then
		for _, child in pairs(value) do
			if child ~= nil and child ~= false then
				table.insert(list, child)
			end
		end
	elseif value ~= nil and value ~= false then
		table.insert(list, value)
	end

	return list
end

local function addIndexEntryGAG2(index, entry)
	index.Entries = index.Entries or {}
	index.ByName = index.ByName or {}
	index.ByPath = index.ByPath or {}
	index.ByNamespace = index.ByNamespace or {}

	table.insert(index.Entries, entry)
	index.ByPath[entry.Path] = entry

	local normalizedName = Reconstructed.NormalizePacketNameGAG2(entry.Name)
	local normalizedNamespace = Reconstructed.NormalizePacketNameGAG2(entry.Namespace)

	if normalizedName ~= "" then
		index.ByName[normalizedName] = index.ByName[normalizedName] or {}
		table.insert(index.ByName[normalizedName], entry)
	end

	if normalizedNamespace ~= "" then
		index.ByNamespace[normalizedNamespace] = index.ByNamespace[normalizedNamespace] or {}
		table.insert(index.ByNamespace[normalizedNamespace], entry)
	end
end

local function preferredKindMatchesGAG2(entry, preferredKind)
	local kind = Reconstructed.NormalizePacketNameGAG2(preferredKind)

	if kind == "" then
		return true
	end

	if kind:find("fire", 1, true) then
		return entry.HasFire or entry.HasFireServer
	end

	if kind:find("invoke", 1, true) then
		return entry.HasInvoke or entry.HasInvokeServer
	end

	if kind:find("call", 1, true) then
		return entry.HasCall
	end

	return true
end

local function choosePacketMethodGAG2(node, entry, preferredKind)
	local preferred = Reconstructed.NormalizePacketNameGAG2(preferredKind)
	local order = {}

	if preferred:find("fireserver", 1, true) then
		order = { "FireServer", "Fire", "Call", "InvokeServer", "Invoke" }
	elseif preferred:find("fire", 1, true) then
		order = { "Fire", "FireServer", "Call", "Invoke", "InvokeServer" }
	elseif preferred:find("invokeserver", 1, true) then
		order = { "InvokeServer", "Invoke", "Call", "FireServer", "Fire" }
	elseif preferred:find("invoke", 1, true) then
		order = { "Invoke", "InvokeServer", "Call", "Fire", "FireServer" }
	elseif preferred:find("call", 1, true) then
		order = { "Call", "Fire", "Invoke", "FireServer", "InvokeServer" }
	else
		order = { "Fire", "Invoke", "FireServer", "InvokeServer", "Call" }
	end

	if type(node) == "function" and (preferred == "" or preferred:find("call", 1, true)) then
		return "Function"
	end

	for _, method in ipairs(order) do
		if method == "Fire" and entry and entry.HasFire then
			return method
		elseif method == "Invoke" and entry and entry.HasInvoke then
			return method
		elseif method == "FireServer" and entry and entry.HasFireServer then
			return method
		elseif method == "InvokeServer" and entry and entry.HasInvokeServer then
			return method
		elseif method == "Call" and entry and entry.HasCall then
			if type(node) == "function" then
				return "Function"
			end

			return method
		end
	end

	local flags = getPacketCallableFlagsGAG2(node)
	if flags.HasFire then
		return "Fire"
	elseif flags.HasInvoke then
		return "Invoke"
	elseif flags.HasFireServer then
		return "FireServer"
	elseif flags.HasInvokeServer then
		return "InvokeServer"
	elseif type(node) == "function" then
		return "Function"
	elseif flags.HasCall then
		return "Call"
	end

	return nil
end

local function entryNamespaceMatchesGAG2(entry, namespaceNames)
	local namespaces = listValuesGAG2(namespaceNames)

	if #namespaces == 0 then
		return true
	end

	local haystack = Reconstructed.NormalizePacketNameGAG2(tostring(entry.Namespace or "") .. "." .. tostring(entry.Path or ""))

	for _, namespace in ipairs(namespaces) do
		local needle = Reconstructed.NormalizePacketNameGAG2(namespace)

		if needle ~= "" and haystack:find(needle, 1, true) then
			return true
		end
	end

	return false
end

local function selectionEntriesGAG2(selection, defaultCount)
	local entries = {}
	defaultCount = tonumber(defaultCount) or 1

	if type(selection) == "string" then
		if selection ~= "" and selection ~= "None" then
			table.insert(entries, { Name = selection, Count = defaultCount })
		end

		return entries
	end

	if type(selection) ~= "table" then
		return entries
	end

	for key, value in pairs(selection) do
		if type(value) == "string" and value ~= "" and value ~= "None" then
			table.insert(entries, { Name = value, Count = defaultCount })
		elseif isTruthySelectionValue(key, value) then
			local count = tonumber(value) or defaultCount
			table.insert(entries, { Name = tostring(key), Count = math.max(1, count) })
		end
	end

	return entries
end

local function inventoryCountForNameGAG2(counts, name)
	name = tostring(name or "")

	return counts[name]
		or counts[name .. " Seed"]
		or counts[name .. " Seeds"]
		or counts[name .. " Gear"]
		or 0
end

function Reconstructed.NormalizePacketNameGAG2(value)
	if value == nil then
		return ""
	end

	local normalized = tostring(value):lower():gsub("[^%w]+", "")
	return normalized
end

function Reconstructed.ScanNetworkingTableGAG2(root, namespace, path, depth, dump, index, seen, options)
	options = options or {}
	dump = dump or {}
	index = index or { Entries = {}, ByName = {}, ByPath = {}, ByNamespace = {} }
	seen = seen or {}
	depth = tonumber(depth) or 0
	path = path or "Networking"
	namespace = namespace or ""

	local maxDepth = tonumber(options.MaxDepth) or 8
	local maxEntries = tonumber(options.MaxEntries)

	if not maxEntries then
		maxEntries = 1500
	elseif maxEntries <= 0 then
		maxEntries = math.huge
	end

	local includeFunctions = options.IncludeFunctions == true
	local rootType = type(root)
	local flags = getPacketCallableFlagsGAG2(root)
	local entry = {
		Path = path,
		Name = tostring(path):match("([^%.%[%]]+)%]?$") or tostring(path),
		Namespace = namespace,
		Type = valueTypeGAG2(root),
		HasFire = flags.HasFire,
		HasInvoke = flags.HasInvoke,
		HasFireServer = flags.HasFireServer,
		HasInvokeServer = flags.HasInvokeServer,
		HasCall = flags.HasCall,
		Ref = root,
	}

	if options.RecordAll ~= false or hasPacketCallableGAG2(entry) then
		table.insert(dump, entry)
		addIndexEntryGAG2(index, entry)
	end

	if (rootType ~= "table" and (rootType ~= "function" or not includeFunctions)) or depth >= maxDepth or #dump >= maxEntries then
		return dump, index
	end

	if seen[root] then
		return dump, index
	end

	seen[root] = true

	if rootType == "table" or includeFunctions then
		safeCall(function()
			for key, child in pairs(root) do
				if #dump >= maxEntries then
					break
				end

				local childPath = pathChildGAG2(path, key)
				Reconstructed.ScanNetworkingTableGAG2(child, path, childPath, depth + 1, dump, index, seen, options)
			end
		end)
	end

	if options.IncludeMetatables and (rootType == "table" or rootType == "function") and #dump < maxEntries then
		local success, metatable = safeCall(getmetatable, root)

		if success and metatable then
			Reconstructed.ScanNetworkingTableGAG2(metatable, path, path .. ".<metatable>", depth + 1, dump, index, seen, options)
		end
	end

	return dump, index
end

function Reconstructed.BuildNetworkingIndexGAG2(context, networking, options)
	context = context or {}
	networking = networking or context.Networking or Reconstructed.GetNetworkingGAG2(context)

	local dump = {}
	local index = {
		Entries = {},
		ByName = {},
		ByPath = {},
		ByNamespace = {},
		BuiltAt = os and os.time and os.time() or 0,
	}

	if networking then
		Reconstructed.ScanNetworkingTableGAG2(networking, "", "Networking", 0, dump, index, {}, options or {})
	end

	Reconstructed.NetworkingDumpGAG2 = dump
	Reconstructed.NetworkingIndexGAG2 = index
	return index, dump
end

function Reconstructed.ScanNetworkingGAG2(context, options)
	context = context or {}
	local networking = context.Networking or Reconstructed.GetNetworkingGAG2(context)
	local index, dump = Reconstructed.BuildNetworkingIndexGAG2(context, networking, options)
	recordAction("NetworkingScanGAG2", "Networking", { #dump })
	return index, dump
end

function Reconstructed.ScanNetworkingFullGAG2(context)
	return Reconstructed.ScanNetworkingGAG2(context, {
		MaxDepth = 15,
		MaxEntries = 0,
		IncludeFunctions = true,
		IncludeMetatables = false,
	})
end

local function networkingDumpEntriesGAG2(dump)
	if type(dump) ~= "table" then
		return {}
	end

	if type(dump.Flat) == "table" then
		return dump.Flat
	end

	if #dump > 0 then
		return dump
	end

	if type(dump.Entries) == "table" then
		return dump.Entries
	end

	return dump
end

local function safeNetworkingDumpFileNamePartGAG2(value)
	local name = tostring(value or ""):gsub("[\\/:*?\"<>|]", "_"):gsub("%s+", "_")

	if name == "" or name == "." or name == ".." then
		return "dump"
	end

	return name
end

local function safeNetworkingDumpPathGAG2(path)
	path = tostring(path or ""):gsub("\\", "/")

	local parts = {}

	for part in path:gmatch("[^/]+") do
		table.insert(parts, safeNetworkingDumpFileNamePartGAG2(part))
	end

	return table.concat(parts, "/")
end

local function ensureNetworkingDumpFolderGAG2(path)
	local folder = tostring(path or ""):match("^(.*)/[^/]+$")

	if not folder or folder == "" or type(makefolder) ~= "function" then
		return
	end

	local exists = false

	if type(isfolder) == "function" then
		local success, result = safeCall(isfolder, folder)
		exists = success and result
	end

	if not exists then
		safeCall(makefolder, folder)
	end
end

function Reconstructed.FilterNetworkingDumpGAG2(dump, namespaceName)
	local filtered = { Flat = {}, Entries = {} }
	local namespaceText = tostring(namespaceName or "")
	local normalizedNamespace = Reconstructed.NormalizePacketNameGAG2(namespaceText)
	local normalizedPrefix = Reconstructed.NormalizePacketNameGAG2("Networking." .. namespaceText)
	local pathPrefix = "Networking." .. namespaceText

	for _, entry in ipairs(networkingDumpEntriesGAG2(dump or Reconstructed.NetworkingDumpGAG2)) do
		local path = tostring(entry.Path or "")
		local namespace = tostring(entry.Namespace or "")
		local normalizedPath = Reconstructed.NormalizePacketNameGAG2(path)
		local normalizedEntryNamespace = Reconstructed.NormalizePacketNameGAG2(namespace)
		local matches = namespaceText == ""
			or path:sub(1, #pathPrefix) == pathPrefix
			or normalizedPath:sub(1, #normalizedPrefix) == normalizedPrefix
			or normalizedEntryNamespace == normalizedNamespace
			or normalizedEntryNamespace == normalizedPrefix
			or (normalizedNamespace ~= "" and normalizedEntryNamespace:find(normalizedNamespace, 1, true) ~= nil)

		if matches then
			local copied = {}

			for key, value in pairs(entry) do
				copied[key] = value
			end

			table.insert(filtered, copied)
			table.insert(filtered.Flat, copied)
			table.insert(filtered.Entries, copied)
		end
	end

	return filtered
end

function Reconstructed.GetNetworkingDumpTextGAG2(context, dumpOverride)
	context = context or {}

	if dumpOverride == nil and (not Reconstructed.NetworkingDumpGAG2 or #networkingDumpEntriesGAG2(Reconstructed.NetworkingDumpGAG2) == 0) then
		Reconstructed.ScanNetworkingGAG2(context)
	end

	local lines = {}

	for _, entry in ipairs(networkingDumpEntriesGAG2(dumpOverride or Reconstructed.NetworkingDumpGAG2)) do
		local flags = {}

		if entry.HasFire then
			table.insert(flags, "Fire")
		end

		if entry.HasInvoke then
			table.insert(flags, "Invoke")
		end

		if entry.HasFireServer then
			table.insert(flags, "FireServer")
		end

		if entry.HasInvokeServer then
			table.insert(flags, "InvokeServer")
		end

		if entry.HasCall then
			table.insert(flags, "Call")
		end

		table.insert(lines, table.concat({ entry.Path, entry.Type or "nil", entry.Namespace or "", table.concat(flags, ",") }, " | "))
	end

	return table.concat(lines, "\n")
end

function Reconstructed.PrintDumpGAG2(context, dumpOverride)
	local text = Reconstructed.GetNetworkingDumpTextGAG2(context, dumpOverride)

	if type(print) == "function" then
		print(text)
	else
		recordAction("NetworkingDumpGAG2", "Print", { text })
	end

	return text
end

function Reconstructed.CopyDumpGAG2(context, dumpOverride)
	local text = Reconstructed.GetNetworkingDumpTextGAG2(context, dumpOverride)

	if type(setclipboard) == "function" then
		local success = safeCall(setclipboard, text)

		if success then
			return true, text
		end
	end

	recordPlanner("Copy Networking Dump", { Text = text, ClipboardUnavailable = true })
	return false, text
end

function Reconstructed.SaveDumpGAG2(context, dumpOverride, fileName)
	context = context or {}

	if type(dumpOverride) == "string" and fileName == nil then
		fileName = dumpOverride
		dumpOverride = nil
	end

	local text = Reconstructed.GetNetworkingDumpTextGAG2(context, dumpOverride)
	local path = safeNetworkingDumpPathGAG2(fileName or context.NetworkingDumpPath or "GAG2NetworkingDump.txt")

	ensureNetworkingDumpFolderGAG2(path)

	if type(writefile) == "function" then
		local success = safeCall(writefile, path, text)

		if success then
			return true, path
		end
	end

	recordPlanner("Save Networking Dump", { Path = path, Text = text, WriteFileUnavailable = true })
	return false, path
end

function Reconstructed.PrintNamespaceDumpGAG2(context, namespaceName)
	local _, dump = Reconstructed.ScanNetworkingFullGAG2(context)
	local filtered = Reconstructed.FilterNetworkingDumpGAG2(dump, namespaceName)
	local text = Reconstructed.GetNetworkingDumpTextGAG2(context, filtered)

	if type(print) == "function" then
		print(text)
	else
		recordAction("NetworkingNamespaceDumpGAG2", tostring(namespaceName or ""), { text })
	end

	return text, filtered
end

function Reconstructed.SaveNamespaceDumpGAG2(context, namespaceName, fileNamespaceName)
	local _, dump = Reconstructed.ScanNetworkingFullGAG2(context)
	local filtered = Reconstructed.FilterNetworkingDumpGAG2(dump, namespaceName)
	local fileName = "GAG2/networking_" .. safeNetworkingDumpFileNamePartGAG2(fileNamespaceName or namespaceName) .. ".txt"
	return Reconstructed.SaveDumpGAG2(context, filtered, fileName)
end

function Reconstructed.GetNodeByPacketPathGAG2(networking, path)
	if not networking or type(path) ~= "string" or path == "" then
		return nil
	end

	local current = networking
	local normalizedPath = path:gsub("^Networking%.", ""):gsub("^Networking$", "")

	if normalizedPath == "" then
		return current
	end

	for part in normalizedPath:gmatch("[^%.]+") do
		local key = part:match("^([^%[]+)") or part
		local index = part:match("%[(%d+)%]")

		if key ~= "" then
			current = safeProp(current, key)
		end

		if index then
			current = safeProp(current, tonumber(index))
		end

		if current == nil then
			return nil
		end
	end

	return current
end

function Reconstructed.ResolveNetworkingPacketGAG2(context, namespaceNames, packetAliases, preferredKind)
	context = context or {}

	if not Reconstructed.NetworkingIndexGAG2 or not Reconstructed.NetworkingIndexGAG2.Entries or #Reconstructed.NetworkingIndexGAG2.Entries == 0 then
		Reconstructed.ScanNetworkingGAG2(context)
	end

	local index = Reconstructed.NetworkingIndexGAG2 or {}
	local aliases = listValuesGAG2(packetAliases)
	local fallback = nil

	for _, alias in ipairs(aliases) do
		local normalized = Reconstructed.NormalizePacketNameGAG2(alias)
		local entries = normalized ~= "" and index.ByName and index.ByName[normalized] or nil

		for _, entry in ipairs(entries or {}) do
			if entryNamespaceMatchesGAG2(entry, namespaceNames) and hasPacketCallableGAG2(entry) then
				fallback = fallback or entry

				if preferredKindMatchesGAG2(entry, preferredKind) then
					local node = entry.Ref or Reconstructed.GetNodeByPacketPathGAG2(context.Networking or Reconstructed.GetNetworkingGAG2(context), entry.Path)
					return {
						Entry = entry,
						Node = node,
						Path = entry.Path,
						Name = entry.Name,
						Namespace = entry.Namespace,
						Method = choosePacketMethodGAG2(node, entry, preferredKind),
					}
				end
			end
		end
	end

	if fallback then
		local node = fallback.Ref or Reconstructed.GetNodeByPacketPathGAG2(context.Networking or Reconstructed.GetNetworkingGAG2(context), fallback.Path)
		return {
			Entry = fallback,
			Node = node,
			Path = fallback.Path,
			Name = fallback.Name,
			Namespace = fallback.Namespace,
			Method = choosePacketMethodGAG2(node, fallback, preferredKind),
		}
	end

	local normalizedAliases = {}

	for _, alias in ipairs(aliases) do
		table.insert(normalizedAliases, Reconstructed.NormalizePacketNameGAG2(alias))
	end

	for _, entry in ipairs(index.Entries or {}) do
		local normalizedPath = Reconstructed.NormalizePacketNameGAG2(entry.Path)

		for _, alias in ipairs(normalizedAliases) do
			if alias ~= "" and normalizedPath:find(alias, 1, true) and entryNamespaceMatchesGAG2(entry, namespaceNames) and hasPacketCallableGAG2(entry) and preferredKindMatchesGAG2(entry, preferredKind) then
				local node = entry.Ref or Reconstructed.GetNodeByPacketPathGAG2(context.Networking or Reconstructed.GetNetworkingGAG2(context), entry.Path)
				return {
					Entry = entry,
					Node = node,
					Path = entry.Path,
					Name = entry.Name,
					Namespace = entry.Namespace,
					Method = choosePacketMethodGAG2(node, entry, preferredKind),
				}
			end
		end
	end

	return nil
end

function Reconstructed.SafeCallPacketGAG2(context, packetRef, args, options)
	context = context or {}
	options = options or {}
	args = args or {}

	local entry = packetRef and packetRef.Entry or packetRef
	local node = packetRef and (packetRef.Node or packetRef.Ref) or nil
	local path = packetRef and (packetRef.Path or safeProp(entry, "Path")) or nil

	if not node and entry and entry.Ref then
		node = entry.Ref
	end

	if not node and path then
		node = Reconstructed.GetNodeByPacketPathGAG2(context.Networking or Reconstructed.GetNetworkingGAG2(context), path)
	end

	local method = options.Method or packetRef and packetRef.Method or choosePacketMethodGAG2(node, entry, options.PreferredKind)
	local attempt = {
		Feature = options.Feature,
		Path = path or safeProp(entry, "Path") or tostring(packetRef),
		Name = packetRef and (packetRef.Name or safeProp(entry, "Name")) or safeProp(entry, "Name"),
		Namespace = packetRef and (packetRef.Namespace or safeProp(entry, "Namespace")) or safeProp(entry, "Namespace"),
		Method = method,
		Args = args,
		Executed = false,
		Success = false,
	}

	table.insert(Reconstructed.PacketAttemptsGAG2, attempt)
	recordAction("PacketAttemptGAG2", attempt.Name or attempt.Path or "Packet", { attempt })

	if not shouldExecuteRemotes(context) then
		recordPlanner(options.Feature or "Packet Attempt", attempt)
		return false
	end

	if not node or not method then
		attempt.Error = "Packet method not found"
		return false
	end

	local unpackArgs = table.unpack or unpack
	local success, result

	if method == "Function" and type(node) == "function" then
		success, result = safeCall(function()
			return node(unpackArgs(args))
		end)
	else
		local callable = safeProp(node, method)

		if type(callable) ~= "function" then
			attempt.Error = "Callable missing"
			return false
		end

		success, result = safeCall(function()
			return callable(node, unpackArgs(args))
		end)
	end

	attempt.Executed = true
	attempt.Success = success
	attempt.Result = result
	return success, result
end

function Reconstructed.TryPacketCandidatesGAG2(context, candidates, argVariants, options)
	context = context or {}
	options = options or {}
	argVariants = argVariants or { {} }

	local attempted = false

	for _, candidate in ipairs(toList(candidates)) do
		local packetRef = nil

		if type(candidate) == "string" then
			packetRef = Reconstructed.ResolveNetworkingPacketGAG2(context, options.Namespaces or options.Namespace, { candidate }, options.PreferredKind)
		elseif type(candidate) == "table" and (candidate.Node or candidate.Entry or candidate.Path) then
			packetRef = candidate
		elseif type(candidate) == "table" then
			packetRef = Reconstructed.ResolveNetworkingPacketGAG2(
				context,
				candidate.Namespaces or candidate.Namespace or options.Namespaces or options.Namespace,
				candidate.Aliases or candidate.PacketAliases or candidate.Name,
				candidate.PreferredKind or options.PreferredKind
			)
		end

		if packetRef then
			for _, args in ipairs(argVariants) do
				attempted = true
				local success, result = Reconstructed.SafeCallPacketGAG2(context, packetRef, args, {
					Feature = options.Feature,
					PreferredKind = packetRef.PreferredKind or options.PreferredKind,
					Method = packetRef.Method or options.Method,
				})

				if success then
					return true, result, packetRef, true
				end
			end
		end
	end

	if not attempted then
		recordPlanner(options.Feature or "Packet Candidates", {
			Candidates = candidates,
			ArgVariants = argVariants,
			PacketNotFound = true,
		})
	end

	return false, nil, nil, attempted
end

function Reconstructed.BuySeedGAG2(context, seedName, options)
	context = context or {}
	options = options or {}

	if not seedName or seedName == "" then
		return false
	end

	local aliases = { "BuySeed", "PurchaseSeed", "SeedShopPurchase", "PurchaseSeedStock", "BuySeedStock", "BuyItem", "PurchaseItem" }
	local success, _, _, attempted = Reconstructed.TryPacketCandidatesGAG2(context, {
		{
			Namespaces = { "SeedShop", "Seeds", "Shop" },
			Aliases = aliases,
			PreferredKind = "Fire",
		},
	}, {
		{ seedName },
		{ seedName, options.Amount or 1 },
		{ seedName .. " Seed" },
		{ seedName .. " Seed", options.Amount or 1 },
	}, { Feature = "Seed Shop", PreferredKind = "Fire" })

	if not attempted then
		Reconstructed.SeedShopPlannerStub(context.GAGConfig or Reconstructed.GetEffectiveGAGConfig(), context)
	end

	return success
end

function Reconstructed.AutoBuySeedsGAG2(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local planting = section(gagConfig, "Planting")
	local buySeeds = cfg(planting, "Buy Seeds", {})

	if not hasSelection(buySeeds) then
		if cfg(planting, "Auto Plant", true) then
			Reconstructed.SeedShopPlannerStub(gagConfig, context)
		end

		return 0
	end

	local player = getLocalPlayer(context)
	local counts = Reconstructed.GetInventoryCounts(player)
	local bought = 0

	for _, entry in ipairs(selectionEntriesGAG2(buySeeds, 1)) do
		if not selectionMatches(cfg(planting, "Don't Buy", {}), entry.Name) then
			local current = inventoryCountForNameGAG2(counts, entry.Name)
			local needed = math.max(1, math.floor(tonumber(entry.Count) or 1))

			for _ = current + 1, needed do
				if Reconstructed.BuySeedGAG2(context, entry.Name, { Amount = 1 }) then
					bought = bought + 1
					safeWait(0.15)
				else
					break
				end
			end
		end
	end

	return bought
end

function Reconstructed.BuyGearGAG2(context, gearName, options)
	context = context or {}
	options = options or {}

	if not gearName or gearName == "" then
		return false
	end

	local success, _, _, attempted = Reconstructed.TryPacketCandidatesGAG2(context, {
		{
			Namespaces = { "GearShop", "Gear", "Shop" },
			Aliases = { "BuyGear", "PurchaseGear", "GearShopPurchase", "PurchaseGearStock", "BuyGearStock", "BuyItem", "PurchaseItem" },
			PreferredKind = "Fire",
		},
	}, {
		{ gearName },
		{ gearName, options.Amount or 1 },
	}, { Feature = "Gear Shop", PreferredKind = "Fire" })

	if not attempted then
		Reconstructed.GearShopPlannerStub(context.GAGConfig or Reconstructed.GetEffectiveGAGConfig(), context)
	end

	return success
end

function Reconstructed.AutoBuyGearGAG2(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local gear = section(gagConfig, "Gear")
	if not cfg(gear, "Auto Buy", true) and not hasSelection(cfg(gear, "Buy Gear", {})) and not hasSelection(cfg(gear, "Keep Gear", {})) then
		return 0
	end

	local selected = selectionEntriesGAG2(cfg(gear, "Buy Gear", {}), 1)
	local keep = selectionEntriesGAG2(cfg(gear, "Keep Gear", {}), 1)

	for _, entry in ipairs(keep) do
		table.insert(selected, entry)
	end

	if #selected == 0 then
		Reconstructed.GearShopPlannerStub(gagConfig, context)
		return 0
	end

	local player = getLocalPlayer(context)
	local counts = Reconstructed.GetInventoryCounts(player)
	local bought = 0

	for _, entry in ipairs(selected) do
		local current = inventoryCountForNameGAG2(counts, entry.Name)
		local needed = math.max(1, math.floor(tonumber(entry.Count) or 1))

		for _ = current + 1, needed do
			if Reconstructed.BuyGearGAG2(context, entry.Name, { Amount = 1 }) then
				bought = bought + 1
				safeWait(0.15)
			else
				break
			end
		end
	end

	return bought
end

function Reconstructed.BuyPetGAG2(context, petName, options)
	context = context or {}
	options = options or {}

	if not petName or petName == "" then
		return false
	end

	local success, _, _, attempted = Reconstructed.TryPacketCandidatesGAG2(context, {
		{
			Namespaces = { "Pets", "PetShop", "Pet", "Shop", "Egg" },
			Aliases = { "BuyPet", "PurchasePet", "BuyEgg", "PurchaseEgg", "HatchPet", "PetShopPurchase", "PurchasePetEgg", "BuyPetEgg" },
			PreferredKind = "Fire",
		},
	}, {
		{ petName },
		{ petName, options.Amount or 1 },
	}, { Feature = "Pet Shop", PreferredKind = "Fire" })

	if not attempted then
		Reconstructed.PetShopPlannerStub(context.GAGConfig or Reconstructed.GetEffectiveGAGConfig(), context)
	end

	return success
end

function Reconstructed.EquipPetGAG2(context, petOrId, options)
	context = context or {}
	options = options or {}

	local petId = getAttr(petOrId, "PetId") or getAttr(petOrId, "Id") or getAttr(petOrId, "UUID") or petOrId
	local petName = getAttr(petOrId, "PetName") or safeProp(petOrId, "Name") or tostring(petId or "")

	if not petId or petId == "" then
		return false
	end

	local success, _, _, attempted = Reconstructed.TryPacketCandidatesGAG2(context, {
		{
			Namespaces = { "Pets", "Pet", "Inventory" },
			Aliases = { "EquipPet", "PetEquip", "EquipPetById", "EquipCompanion", "SetPetEquipped" },
			PreferredKind = "Fire",
		},
	}, {
		{ petId },
		{ petName },
		{ petId, true },
		{ petName, petId },
	}, { Feature = "Pet Equip", PreferredKind = "Fire" })

	if not attempted then
		Reconstructed.PetShopPlannerStub(context.GAGConfig or Reconstructed.GetEffectiveGAGConfig(), context)
	end

	return success
end

function Reconstructed.BuyPetSlotGAG2(context, options)
	context = context or {}
	options = options or {}

	local success, _, _, attempted = Reconstructed.TryPacketCandidatesGAG2(context, {
		{
			Namespaces = { "Pets", "Pet", "Slots", "Shop" },
			Aliases = { "BuyPetSlot", "PurchasePetSlot", "UpgradePetSlot", "UnlockPetSlot", "BuyPetInventorySlot", "PurchasePetInventorySlot" },
			PreferredKind = "Fire",
		},
	}, {
		{},
		{ options.MaxSlots },
	}, { Feature = "Pet Slots", PreferredKind = "Fire" })

	if not attempted then
		Reconstructed.PetShopPlannerStub(context.GAGConfig or Reconstructed.GetEffectiveGAGConfig(), context)
	end

	return success
end

function Reconstructed.AutoPetsGAG2(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local pets = section(gagConfig, "Pets")
	local acted = 0

	for _, entry in ipairs(selectionEntriesGAG2(cfg(pets, "Buy", {}), 1)) do
		for _ = 1, math.max(1, math.floor(tonumber(entry.Count) or 1)) do
			if Reconstructed.BuyPetGAG2(context, entry.Name, { Amount = 1 }) then
				acted = acted + 1
				safeWait(0.2)
			else
				break
			end
		end
	end

	local equipEntries = selectionEntriesGAG2(cfg(pets, "Equip", {}), 1)
	if #equipEntries > 0 then
		local equippedCounts = {}
		local tools = Reconstructed.GetAllTool(getLocalPlayer(context))

		for _, tool in ipairs(tools) do
			local petName = getAttr(tool, "PetName") or safeProp(tool, "Name", "")

			for _, entry in ipairs(equipEntries) do
				if selectionMatches(entry.Name, petName) and (equippedCounts[entry.Name] or 0) < entry.Count then
					if Reconstructed.EquipPetGAG2(context, tool) then
						equippedCounts[entry.Name] = (equippedCounts[entry.Name] or 0) + 1
						acted = acted + 1
						safeWait(0.15)
					end
				end
			end
		end
	end

	if cfg(pets, "Auto Buy Slots", true) then
		if Reconstructed.BuyPetSlotGAG2(context, { MaxSlots = cfg(pets, "Max Pet Slots", 6) }) then
			acted = acted + 1
		end
	elseif acted == 0 and (hasSelection(cfg(pets, "Buy", {})) or hasSelection(cfg(pets, "Equip", {}))) then
		Reconstructed.PetShopPlannerStub(gagConfig, context)
	end

	return acted
end

function Reconstructed.ClaimMailGAG2(context, mailId, options)
	context = context or {}
	options = options or {}

	local argVariants = mailId and { { mailId }, {} } or { {} }
	local success, _, _, attempted = Reconstructed.TryPacketCandidatesGAG2(context, {
		{
			Namespaces = { "Mail", "Mailbox", "Gifts" },
			Aliases = { "ClaimMail", "ClaimAllMail", "ClaimMailbox", "AcceptMail", "ClaimGift", "ClaimAllGifts" },
			PreferredKind = "Fire",
		},
	}, argVariants, { Feature = "Mail", PreferredKind = "Fire" })

	if not attempted then
		Reconstructed.MailPlannerStub(context.GAGConfig or Reconstructed.GetEffectiveGAGConfig(), context)
	end

	return success
end

function Reconstructed.SendMailGAG2(context, recipient, itemOrId, options)
	context = context or {}
	options = options or {}

	if not recipient or recipient == "" or not itemOrId then
		return false
	end

	local itemId = getAttr(itemOrId, "Id") or getAttr(itemOrId, "UUID") or getAttr(itemOrId, "PetId") or getAttr(itemOrId, "FruitId") or itemOrId
	local itemName = safeProp(itemOrId, "Name") or tostring(itemId)
	local success, _, _, attempted = Reconstructed.TryPacketCandidatesGAG2(context, {
		{
			Namespaces = { "Mail", "Mailbox", "Gifts" },
			Aliases = { "SendMail", "MailboxSend", "SendGift", "GiftItem", "SendItem", "MailItem" },
			PreferredKind = "Fire",
		},
	}, {
		{ recipient, itemId },
		{ recipient, itemId, itemName },
		{ itemId, recipient },
		{ recipient, itemOrId },
	}, { Feature = "Mail Send", PreferredKind = "Fire" })

	if not attempted then
		Reconstructed.MailPlannerStub(context.GAGConfig or Reconstructed.GetEffectiveGAGConfig(), context)
	end

	return success
end

function Reconstructed.AutoMailGAG2(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local mail = section(gagConfig, "Mail")
	local acted = 0

	if cfg(mail, "Auto Claim", true) and Reconstructed.ClaimMailGAG2(context) then
		acted = acted + 1
	end

	local recipient = cfg(mail, "Send To", "")
	local sendSelection = cfg(mail, "Send", {})

	if recipient ~= "" and hasSelection(sendSelection) then
		for _, tool in ipairs(Reconstructed.GetAllTool(getLocalPlayer(context))) do
			local itemName = safeProp(tool, "Name", "")

			if selectionMatches(sendSelection, itemName) and not getAttr(tool, "IsFavorite") then
				if Reconstructed.SendMailGAG2(context, recipient, tool) then
					acted = acted + 1
					safeWait(0.25)
				end
			end
		end
	elseif acted == 0 and (cfg(mail, "Auto Claim", true) or recipient ~= "" or hasSelection(sendSelection)) then
		Reconstructed.MailPlannerStub(gagConfig, context)
	end

	return acted
end

function Reconstructed.BuyAuctionLotGAG2(context, lot, price, options)
	context = context or {}
	options = options or {}

	local lotId = type(lot) == "table" and (lot.Id or lot.LotId or lot.Name) or lot
	local lotPrice = price or type(lot) == "table" and lot.Price or nil

	if not lotId or lotId == "" then
		return false
	end

	lotId = tostring(lotId):gsub("^Lot_", "")

	local success, _, _, attempted = Reconstructed.TryPacketCandidatesGAG2(context, {
		{
			Namespaces = { "Auction", "Auctioneer" },
			Aliases = { "AuctioneerPurchaseLot", "PurchaseAuctionLot", "BuyAuctionLot", "AuctionBuy", "BidAuctionLot", "PurchaseLot" },
			PreferredKind = "Fire",
		},
	}, {
		{ lotId, lotPrice },
		{ lotId },
		{ lot },
	}, { Feature = "Auction", PreferredKind = "Fire" })

	if not attempted then
		Reconstructed.AuctionPlannerStub(context.GAGConfig or Reconstructed.GetEffectiveGAGConfig(), context)
	end

	return success
end

function Reconstructed.GetAuctionLotsGAG2(context)
	context = context or {}

	if type(context.AuctionLots) == "table" then
		return context.AuctionLots
	end

	local auctionGui = context.AuctionGui
	local auction = auctionGui and findChild(auctionGui, "Auction")
	local frame = auction and findChild(auction, "Frame")
	local list = frame and findChild(frame, "ScrollingFrame")
	local lots = {}

	if not list then
		return lots
	end

	for _, lotFrame in ipairs(QueryChildren(list)) do
		local itemName = findChild(lotFrame, "ItemName", true)
		local priceLabel = findChild(lotFrame, "TextLabel", true)
		local outOfStock = findChild(lotFrame, "OUT_OF_STOCK", true)
		local expired = findChild(lotFrame, "EXPIRED", true)

		if not safeProp(outOfStock, "Visible", false) and not safeProp(expired, "Visible", false) then
			table.insert(lots, {
				Id = tostring(safeProp(lotFrame, "Name", "")):gsub("^Lot_", ""),
				Name = safeProp(itemName, "Text", safeProp(itemName, "ContentText", "")),
				Price = Reconstructed.Converter.CorrectNumber(safeProp(priceLabel, "ContentText", safeProp(priceLabel, "Text", ""))),
				Frame = lotFrame,
			})
		end
	end

	return lots
end

function Reconstructed.AutoBuyAuctionGAG2(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local config = context.Config or Reconstructed.BuildLegacyConfig(gagConfig)
	if not cfg(config, "Auto Buy Auction", false) then
		return 0
	end

	local lots = Reconstructed.GetAuctionLotsGAG2(context)
	if #lots == 0 then
		Reconstructed.AuctionPlannerStub(gagConfig, context)
		return 0
	end

	local selectedItems, hasFilter = buildSelectedMap(
		cfg(config, "Select Seed", {}),
		cfg(config, "Select Gear", {}),
		cfg(config, "Select Seed Pack", {}),
		cfg(config, "Select Egg", {})
	)
	local priceLimit = tonumber(cfg(config, "Auction Price", 0)) or 0
	local priceMode = cfg(config, "Auction Price Mode", "Below")

	for _, lot in ipairs(lots) do
		local lotName = tostring(lot.Name or lot.ItemName or "")
		local price = tonumber(lot.Price) or 0

		if hasFilter and not selectedItems[lotName] then
			continue
		end

		if priceLimit ~= 0 then
			if priceMode == "Above" and price <= priceLimit then
				continue
			end

			if priceMode == "Below" and price >= priceLimit then
				continue
			end
		end

		if Reconstructed.BuyAuctionLotGAG2(context, lot, price) then
			return 1
		end
	end

	return 0
end

function Reconstructed.CollectFruitPacketGAG2(context, plant, fruitId, options)
	context = context or {}
	options = options or {}

	local plantId = getAttr(plant, "PlantId") or getAttr(plant, "Id") or plant
	local targetFruitId = fruitId or getAttr(plant, "FruitId") or ""

	if not plantId or plantId == "" then
		return false
	end

	local success, _, _, attempted = Reconstructed.TryPacketCandidatesGAG2(context, {
		{
			Namespaces = { "Plant", "Plants", "Garden", "Fruit", "Harvest" },
			Aliases = { "CollectFruit", "HarvestFruit", "PickupFruit", "PickFruit", "CollectPlant", "HarvestPlant" },
			PreferredKind = "Fire",
		},
	}, {
		{ plantId, targetFruitId },
		{ plantId },
		{ plant, targetFruitId },
	}, { Feature = "Collect Fruit Packet", PreferredKind = "Fire" })

	if not attempted then
		recordPlanner("Collect Fruit Packet", { PlantId = plantId, FruitId = targetFruitId, RuntimePacketRequired = true })
	end

	return success
end

function Reconstructed.ShovelPlantGAG2(context, plant, options)
	context = context or {}
	options = options or {}

	local plantId = getAttr(plant, "PlantId") or getAttr(plant, "Id") or safeProp(plant, "Name") or plant

	if not plantId or plantId == "" then
		return false
	end

	local success, _, _, attempted = Reconstructed.TryPacketCandidatesGAG2(context, {
		{
			Namespaces = { "Plant", "Plants", "Garden", "Shovel" },
			Aliases = { "ShovelPlant", "RemovePlant", "DeletePlant", "DestroyPlant", "DigUpPlant", "Shovel" },
			PreferredKind = "Fire",
		},
	}, {
		{ plantId },
		{ plant },
	}, { Feature = "Shovel Runtime Packet", PreferredKind = "Fire" })

	if not attempted then
		Reconstructed.ShovelRuntimePacketStub(context.GAGConfig or Reconstructed.GetEffectiveGAGConfig(), context)
	end

	return success
end

function Reconstructed.AutoShovelReplaceGAG2(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local planting = section(gagConfig, "Planting")
	local money = section(gagConfig, "Money")
	local shovelUpTo = cfg(planting, "Shovel Up To", "")
	local autoReplace = cfg(money, "Auto Replace Plants", true)

	if not autoReplace and shovelUpTo == "" and not hasSelection(cfg(planting, "Never Shovel", {})) then
		return 0
	end

	local plot = context.Plot or Reconstructed.GetOwnerPlot(context)
	local plantsFolder = Reconstructed.GetPlotPlants(plot)
	local shoveled = 0

	if not plantsFolder then
		Reconstructed.ShovelRuntimePacketStub(gagConfig, context)
		return shoveled
	end

	local maxRank = shovelUpTo ~= "" and Reconstructed.GAG2SeedRank[shovelUpTo] or nil

	for _, plant in ipairs(QueryChildren(plantsFolder)) do
		local plantName = getPlantDisplayName(plant) or safeProp(plant, "Name", "")
		local shouldShovel = false

		if selectionMatches(cfg(planting, "Never Shovel", {}), plantName) then
			continue
		end

		if maxRank and Reconstructed.GAG2SeedRank[plantName] and Reconstructed.GAG2SeedRank[plantName] <= maxRank then
			shouldShovel = true
		elseif shovelUpTo ~= "" and selectionMatches(shovelUpTo, plantName) then
			shouldShovel = true
		elseif autoReplace and selectionMatches(cfg(planting, "Don't Plant", {}), plantName) then
			shouldShovel = true
		end

		if shouldShovel and Reconstructed.ShovelPlantGAG2(context, plant) then
			shoveled = shoveled + 1
			safeWait(0.25)
		end
	end

	return shoveled
end

function Reconstructed.ExpandPlotGAG2(context, options)
	context = context or {}
	options = options or {}

	local plot = context.Plot or Reconstructed.GetOwnerPlot(context)
	local success, _, _, attempted = Reconstructed.TryPacketCandidatesGAG2(context, {
		{
			Namespaces = { "Plot", "Garden", "Farm", "Expansion", "Land" },
			Aliases = { "ExpandPlot", "BuyPlotExpansion", "PurchasePlotExpansion", "UnlockPlot", "ExpandGarden", "BuyLand" },
			PreferredKind = "Fire",
		},
	}, {
		{},
		{ plot },
		{ options.Level },
	}, { Feature = "Expand Plot", PreferredKind = "Fire" })

	if not attempted then
		Reconstructed.ExpandRuntimePacketStub(context.GAGConfig or Reconstructed.GetEffectiveGAGConfig(), context)
	end

	return success
end

function Reconstructed.AutoExpandPlotGAG2(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local money = section(gagConfig, "Money")
	if not cfg(money, "Auto Expand Plot", true) then
		return false
	end

	local player = getLocalPlayer(context)
	local cash = Reconstructed.GetSheckles(player)
	local keepCash = tonumber(cfg(money, "Keep Cash", 15000)) or 0
	local expandIfOver = tonumber(cfg(money, "Expand If Over", 1500000)) or 0

	if cash > 0 and (cash < keepCash or cash < expandIfOver) then
		return false
	end

	Reconstructed.ExpansionAttemptsGAG2 = Reconstructed.ExpansionAttemptsGAG2 or 0
	local maxExpansions = tonumber(cfg(money, "Max Expansions", 3)) or 0

	if maxExpansions > 0 and Reconstructed.ExpansionAttemptsGAG2 >= maxExpansions then
		return false
	end

	if Reconstructed.ExpandPlotGAG2(context, { Level = Reconstructed.ExpansionAttemptsGAG2 + 1 }) then
		Reconstructed.ExpansionAttemptsGAG2 = Reconstructed.ExpansionAttemptsGAG2 + 1
		return true
	end

	return false
end

function Reconstructed.SellAllGAG2(context)
	recordAction("SellAllGAG2", "Networking.NPCS.SellAll", {})

	if not shouldExecuteRemotes(context) then
		return false
	end

	local networking = Reconstructed.GetNetworkingGAG2(context)
	local npcs = safeProp(networking, "NPCS")
	local sellAll = safeProp(npcs, "SellAll")

	if type(safeProp(sellAll, "Fire")) == "function" then
		local success = safeCall(function()
			sellAll:Fire()
		end)

		if success then
			Reconstructed.LastSellTimeGAG = os and os.time and os.time() or Reconstructed.LastSellTimeGAG
		end

		return success
	end

	return false
end

function Reconstructed.GetHarvestedInventoryCount(player)
	local total = 0
	local sources = {
		Reconstructed.GetBackpack(player),
		player and player.Character,
	}

	for _, source in ipairs(sources) do
		for _, item in ipairs(QueryChildren(source)) do
			local itemName = safeProp(item, "Name", "")
			if isA(item, "Tool") and (getAttr(item, "HarvestedFruit") or itemName:find("%[.-kg%]")) then
				total = total + 1
			end
		end
	end

	return total
end

function Reconstructed.ShouldSellGAG(gagConfig, context)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local player = getLocalPlayer(context)
	local harvest = section(gagConfig, "Harvest")
	local fruitCount = Reconstructed.GetHarvestedInventoryCount(player)

	if fruitCount <= 0 then
		return false
	end

	local sellAt = tonumber(cfg(harvest, "Sell At", 0)) or 0
	if sellAt > 0 and fruitCount >= sellAt then
		return true
	end

	local sellEvery = tonumber(cfg(harvest, "Sell Every", 0)) or 0
	if sellEvery > 0 and os and os.time then
		local lastSell = context.LastSellTime or Reconstructed.LastSellTimeGAG or 0
		return os.time() - lastSell >= sellEvery
	end

	return false
end

function Reconstructed.GetSeedName(toolOrName)
	local name = type(toolOrName) == "string" and toolOrName or safeProp(toolOrName, "Name", "")
	return name:gsub(" Seed$", "")
end

function Reconstructed.IsValidSeedTool(item)
	local itemName = safeProp(item, "Name", "")
	if not isA(item, "Tool") or itemName:find(":") then
		return false
	end

	return Reconstructed.GAG2SeedNames[Reconstructed.GetSeedName(item)] == true
end

function Reconstructed.GetPlantableSeedsGAG(player, gagConfig)
	gagConfig = gagConfig or Reconstructed.GetEffectiveGAGConfig()

	local planting = section(gagConfig, "Planting")
	local seeds = {}
	local counts = Reconstructed.GetInventoryCounts(player)
	local minimumSeed = cfg(planting, "Minimum Seed", "")
	local minimumRank = minimumSeed ~= "" and Reconstructed.GAG2SeedRank[minimumSeed] or nil

	for _, item in ipairs(Reconstructed.GetAllTool(player)) do
		if Reconstructed.IsValidSeedTool(item) then
			local itemName = safeProp(item, "Name", "")
			local seedName = Reconstructed.GetSeedName(item)
			local skip = false
			local seedRank = Reconstructed.GAG2SeedRank[seedName]

			if minimumRank and seedRank and seedRank < minimumRank then
				skip = true
			end

			if selectionMatches(cfg(planting, "Don't Plant", {}), seedName) then
				skip = true
			end

			if not skip and hasSelection(cfg(planting, "Only Plant", {})) and not selectionMatches(cfg(planting, "Only Plant", {}), seedName) then
				skip = true
			end

			local keepSeeds = cfg(planting, "Keep Seeds", {})
			local keepCount = type(keepSeeds) == "table" and tonumber(keepSeeds[seedName] or keepSeeds[itemName]) or nil
			local currentSeedCount = (counts[itemName] or 0) + (itemName ~= seedName and (counts[seedName] or 0) or 0)
			if keepCount and currentSeedCount <= keepCount then
				skip = true
			end

			if not skip then
				table.insert(seeds, {
					name = seedName,
					item = item,
				})
			end
		end
	end

	return seeds
end

function Reconstructed.CountPlantsGAG(plot, plantName)
	local plantsFolder = Reconstructed.GetPlotPlants(plot)
	local count = 0

	if not plantsFolder then
		return count
	end

	for _, plant in ipairs(QueryChildren(plantsFolder)) do
		local name = getPlantDisplayName(plant) or ""
		local rawName = safeProp(plant, "Name", "")
		if not plantName or name:find(plantName, 1, true) or rawName:find(plantName, 1, true) then
			count = count + 1
		end
	end

	return count
end

function Reconstructed.GetPlantAreaPositionsGAG(plot, spacing)
	local positions = {}
	local visual = Reconstructed.GetPlotVisual(plot)
	local plantsFolder = Reconstructed.GetPlotPlants(plot)
	local plantPositions = {}
	spacing = math.max(4, tonumber(spacing) or 6)

	if not visual then
		return positions
	end

	if plantsFolder then
		for _, plant in ipairs(QueryChildren(plantsFolder)) do
			if type(safeProp(plant, "GetBoundingBox")) == "function" then
				local success, cframe, size = safeCall(function()
					return plant:GetBoundingBox()
				end)
				local position = safeProp(cframe, "Position")

				if success and position and size then
					table.insert(plantPositions, {
						position = position,
						radius = math.max(safeProp(size, "X", 0), safeProp(size, "Z", 0)) / 2 + spacing,
					})
				end
			end
		end
	end

	local function isEmpty(position)
		for _, data in ipairs(plantPositions) do
			local dx = position.X - data.position.X
			local dz = position.Z - data.position.Z

			if math.sqrt(dx * dx + dz * dz) < data.radius then
				return false
			end
		end

		return true
	end

	for _, areaName in ipairs({ "PlantAreaColumn1", "PlantAreaColumn2" }) do
		local area = findChild(visual, areaName)
		if isA(area, "BasePart") then
			local size = safeProp(area, "Size")
			local areaCFrame = safeProp(area, "CFrame")
			local halfX = (safeProp(size, "X", 0) / 2) - 4
			local halfZ = (safeProp(size, "Z", 0) / 2) - 4

			if areaCFrame and halfX >= -halfX and halfZ >= -halfZ then
				for x = -halfX, halfX, spacing do
					for z = -halfZ, halfZ, spacing do
						local success, position = safeCall(function()
							return safeProp(areaCFrame * CFrame.new(x, 0, z), "Position")
						end)

						if success and position and isEmpty(position) then
							table.insert(positions, position)
						end
					end
				end
			end
		end
	end

	return positions
end

function Reconstructed.GetPlantControllerGAG(context)
	context = context or {}

	local player = getLocalPlayer(context)
	local playerScripts = player and findChild(player, "PlayerScripts")
	local controllers = playerScripts and findChild(playerScripts, "Controllers")
	local module = controllers and findChild(controllers, "PlantController")
	return safeRequire(context.Require, module)
end

function Reconstructed.EquipSeedGAG(seed, player)
	local _, humanoid = getCharacterParts(player)
	local tool = type(seed) == "table" and seed.item or seed

	if humanoid and tool and type(safeProp(humanoid, "EquipTool")) == "function" then
		local success = safeCall(function()
			humanoid:EquipTool(tool)
		end)

		return success
	end

	return false
end

function Reconstructed.PlantSeedGAG(seed, position, context)
	local seedName = type(seed) == "table" and seed.name or Reconstructed.GetSeedName(seed)
	recordAction("PlantGAG2", seedName, { position })

	if not position or not shouldExecuteRemotes(context) then
		return false
	end

	local player = getLocalPlayer(context)
	Reconstructed.EquipSeedGAG(seed, player)

	local controller = Reconstructed.GetPlantControllerGAG(context)
	if type(safeProp(controller, "TryPlantWithRay")) == "function" then
		local ray = Ray.new(position + Vector3.new(0, 80, 0), Vector3.new(0, -200, 0))
		local success, result = safeCall(function()
			return controller:TryPlantWithRay(ray)
		end)

		return success and result ~= false
	end

	return false
end

function Reconstructed.PlantAllGAG2(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local planting = section(gagConfig, "Planting")
	if not cfg(planting, "Auto Plant", true) then
		return 0
	end

	local player = getLocalPlayer(context)
	local plot = context.Plot or Reconstructed.GetOwnerPlot(context)
	local plantsFolder = Reconstructed.GetPlotPlants(plot)
	local seeds = Reconstructed.GetPlantableSeedsGAG(player, gagConfig)
	local positions = Reconstructed.GetPlantAreaPositionsGAG(plot)
	local plantLimit = tonumber(cfg(planting, "Plant Limit", 0)) or 0
	local planted = 0

	if not plot or #seeds == 0 or #positions == 0 then
		return planted
	end

	for _, seed in ipairs(seeds) do
		local plantPlan = cfg(planting, "Plant Plan", {})
		local targetCount = type(plantPlan) == "table" and tonumber(plantPlan[seed.name]) or nil

		if not targetCount or Reconstructed.CountPlantsGAG(plot, seed.name) < targetCount then
			for _, position in ipairs(positions) do
				if plantLimit > 0 and Reconstructed.CountPlantsGAG(plot) + planted >= plantLimit then
					return planted
				end

				local before = plantsFolder and #QueryChildren(plantsFolder) or 0
				if Reconstructed.PlantSeedGAG(seed, position, context) then
					safeWait(0.6)

					local after = plantsFolder and #QueryChildren(plantsFolder) or before
					if after > before or not shouldExecuteRemotes(context) then
						planted = planted + 1
						break
					end
				end
			end
		end
	end

	return planted
end

function Reconstructed.SetWalkSpeedGAG(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local misc = section(gagConfig, "Misc")
	local speed = tonumber(cfg(misc, "Walk Speed", 35)) or 35
	recordAction("WalkSpeed", "GAG2", { speed })

	if not shouldExecuteMovement(context) then
		return false
	end

	local _, humanoid = getCharacterParts(getLocalPlayer(context))
	if humanoid then
		return safeSet(humanoid, "WalkSpeed", speed)
	end

	return false
end

function Reconstructed.TeleportToPositionGAG(position, context, reason)
	context = context or {}
	recordAction("Teleport", reason or "GAG2", { position })

	if not position or not shouldExecuteMovement(context) then
		return false
	end

	local _, _, rootPart = getCharacterParts(getLocalPlayer(context))
	if not rootPart then
		return false
	end

	local success = safeCall(function()
		if typeof(position) == "CFrame" then
			return safeSet(rootPart, "CFrame", position)
		end

		return safeSet(rootPart, "CFrame", CFrame.new(position))
	end)

	return success
end

function Reconstructed.TeleportToObjectGAG(object, context, reason)
	if not object then
		return false
	end

	if isA(object, "BasePart") then
		return Reconstructed.TeleportToPositionGAG(safeProp(object, "CFrame"), context, reason)
	end

	local targetPart = findChild(object, "HumanoidRootPart") or findChild(object, "Root") or safeProp(object, "PrimaryPart")
	if targetPart then
		return Reconstructed.TeleportToPositionGAG(safeProp(targetPart, "CFrame"), context, reason)
	end

	if type(safeProp(object, "GetBoundingBox")) == "function" then
		local success, cframe = safeCall(function()
			return object:GetBoundingBox()
		end)

		if success then
			return Reconstructed.TeleportToPositionGAG(cframe, context, reason)
		end
	end

	return false
end

function Reconstructed.ReturnToGardenGAG(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local misc = section(gagConfig, "Misc")
	if not cfg(misc, "Auto Return To Garden", true) then
		return false
	end

	local plot = context.Plot or Reconstructed.GetOwnerPlot(context)
	local _, _, rootPart = getCharacterParts(getLocalPlayer(context))

	if not plot or not rootPart then
		return false
	end

	local target = findChild(plot, "SpawnPoint") or findChild(plot, "Center") or safeProp(plot, "PrimaryPart")
	local targetPosition = safeProp(target, "Position")
	local rootPosition = safeProp(rootPart, "Position")
	local distance = rootPosition and targetPosition and safeProp(rootPosition - targetPosition, "Magnitude")
	if distance and distance <= (context.ReturnDistance or 100) then
		return false
	end

	if target then
		return Reconstructed.TeleportToObjectGAG(target, context, "Return To Garden")
	end

	if type(safeProp(plot, "GetBoundingBox")) == "function" then
		local success, cframe = safeCall(function()
			return plot:GetBoundingBox()
		end)

		if success then
			return Reconstructed.TeleportToPositionGAG(cframe, context, "Return To Garden")
		end
	end

	return false
end

function Reconstructed.ApplyFPSCapGAG(gagConfig)
	gagConfig = gagConfig or Reconstructed.GetEffectiveGAGConfig()

	local performance = section(gagConfig, "Performance")
	local cap = tonumber(cfg(performance, "FPS Cap", 0)) or 0
	recordAction("Performance", "FPS Cap", { cap })

	if cap > 0 and type(setfpscap) == "function" then
		return safeCall(function()
			setfpscap(cap)
		end)
	end

	return false
end

function Reconstructed.ApplyLowGraphicsGAG(gagConfig)
	gagConfig = gagConfig or Reconstructed.GetEffectiveGAGConfig()

	local performance = section(gagConfig, "Performance")
	if not cfg(performance, "Low Graphics", true) then
		return false
	end

	recordAction("Performance", "Low Graphics", {})

	local lighting = getService("Lighting")
	local changed = false

	if lighting then
		safeSet(lighting, "GlobalShadows", false)
		safeSet(lighting, "FogEnd", 1000000)
		changed = true
	end

	safeCall(function()
		local appSettings = settings and settings()
		local rendering = safeProp(appSettings, "Rendering")
		if rendering then
			safeSet(rendering, "QualityLevel", Enum.QualityLevel.Level01)
			changed = true
		end
	end)

	return changed
end

function Reconstructed.HideOtherGardensGAG(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local performance = section(gagConfig, "Performance")
	if not cfg(performance, "Remove Other Gardens", true) then
		return 0
	end

	local currentWorkspace = getWorkspace(context)
	local player = getLocalPlayer(context)
	local gardens = currentWorkspace and findChild(currentWorkspace, "Gardens")
	local hidden = 0

	if not gardens then
		return hidden
	end

	for _, garden in ipairs(QueryChildren(gardens)) do
		local gardenOwner = getAttr(garden, "Owner")
		local gardenOwnerUserId = getAttr(garden, "OwnerUserId")
		local owned = player and (gardenOwner == safeProp(player, "Name") or tostring(gardenOwnerUserId) == tostring(safeProp(player, "UserId")))

		if not owned then
			hidden = hidden + hideVisualTree(garden)
		end
	end

	return hidden
end

function Reconstructed.HideOwnedCropVisualsGAG(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local performance = section(gagConfig, "Performance")
	local hideCrops = cfg(performance, "Hide Crop Visuals", true)
	local hideFruits = cfg(performance, "Hide Fruit Visuals", true)
	local plot = context.Plot or Reconstructed.GetOwnerPlot(context)
	local plantsFolder = Reconstructed.GetPlotPlants(plot)
	local hidden = 0

	if not plantsFolder or (not hideCrops and not hideFruits) then
		return hidden
	end

	for _, plant in ipairs(QueryChildren(plantsFolder)) do
		if hideCrops then
			hidden = hidden + hideVisualTree(plant)
		elseif hideFruits then
			for _, descendant in ipairs(QueryDescendants(plant)) do
				local descendantName = safeProp(descendant, "Name", "")
				if getAttr(descendant, "FruitId") or descendantName:find("Fruit") then
					hidden = hidden + hideVisualTree(descendant)
				end
			end
		end
	end

	return hidden
end

function Reconstructed.HidePlayersGAG(context, gagConfig)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	local performance = section(gagConfig, "Performance")
	if not cfg(performance, "Hide Players", true) then
		return 0
	end

	local players = getPlayers(context)
	local localPlayer = getLocalPlayer(context)
	local hidden = 0

	if type(safeProp(players, "GetPlayers")) ~= "function" then
		return hidden
	end

	local success, playerList = safeCall(function()
		return players:GetPlayers()
	end)

	if not success then
		return hidden
	end

	for _, player in ipairs(toList(playerList)) do
		local character = safeProp(player, "Character")
		if player ~= localPlayer and character then
			hidden = hidden + hideVisualTree(character)
		end
	end

	return hidden
end

function Reconstructed.ApplyPerformanceGAG(context, gagConfig)
	gagConfig = gagConfig or context and context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()

	return {
		FPSCap = Reconstructed.ApplyFPSCapGAG(gagConfig),
		LowGraphics = Reconstructed.ApplyLowGraphicsGAG(gagConfig),
		OtherGardens = Reconstructed.HideOtherGardensGAG(context, gagConfig),
		OwnedVisuals = Reconstructed.HideOwnedCropVisualsGAG(context, gagConfig),
		Players = Reconstructed.HidePlayersGAG(context, gagConfig),
	}
end

function Reconstructed.SeedShopPlannerStub(gagConfig, context)
	local planting = section(gagConfig, "Planting")
	if cfg(planting, "Auto Plant", true) or hasSelection(cfg(planting, "Buy Seeds", {})) then
		recordPlanner("Seed Shop", {
			Namespace = "ReplicatedStorage.SharedModules.Networking.SeedShop",
			Config = planting,
			RuntimePacketRequired = true,
		})
	end
end

function Reconstructed.GearShopPlannerStub(gagConfig, context)
	local gear = section(gagConfig, "Gear")
	if cfg(gear, "Auto Buy", true) or hasSelection(cfg(gear, "Buy Gear", {})) or hasSelection(cfg(gear, "Keep Gear", {})) then
		recordPlanner("Gear Shop", {
			Namespace = "ReplicatedStorage.SharedModules.Networking.GearShop",
			Config = gear,
			RuntimePacketRequired = true,
		})
	end
end

function Reconstructed.PetShopPlannerStub(gagConfig, context)
	local pets = section(gagConfig, "Pets")
	if hasSelection(cfg(pets, "Buy", {})) or hasSelection(cfg(pets, "Equip", {})) or cfg(pets, "Auto Buy Slots", true) then
		recordPlanner("Pet Shop", {
			Namespace = "ReplicatedStorage.SharedModules.Networking.Pets",
			Config = pets,
			RuntimePacketRequired = true,
		})
	end
end

function Reconstructed.MailPlannerStub(gagConfig, context)
	local mail = section(gagConfig, "Mail")
	if cfg(mail, "Auto Claim", true) or cfg(mail, "Send To", "") ~= "" or hasSelection(cfg(mail, "Send", {})) then
		recordPlanner("Mail", {
			Namespace = "ReplicatedStorage.SharedModules.Networking.Mail",
			Config = mail,
			RuntimePacketRequired = true,
		})
	end
end

function Reconstructed.AuctionPlannerStub(gagConfig, context)
	local config = context and context.Config or Reconstructed.BuildLegacyConfig(gagConfig)
	if cfg(config, "Auto Buy Auction", false) or hasSelection(cfg(config, "Select Seed", {})) or hasSelection(cfg(config, "Select Gear", {})) then
		recordPlanner("Auction", {
			Namespace = "ReplicatedStorage.SharedModules.Networking.Auctioneer",
			Config = config,
			RuntimePacketRequired = true,
		})
	end
end

function Reconstructed.ExpandRuntimePacketStub(gagConfig, context)
	local money = section(gagConfig, "Money")
	if cfg(money, "Auto Expand Plot", true) then
		recordPlanner("Expand Plot", {
			Namespace = "ReplicatedStorage.SharedModules.Networking",
			Config = money,
			RuntimePacketRequired = true,
		})
	end
end

function Reconstructed.ShovelRuntimePacketStub(gagConfig, context)
	local planting = section(gagConfig, "Planting")
	local money = section(gagConfig, "Money")
	if cfg(money, "Auto Replace Plants", true) or cfg(planting, "Shovel Up To", "") ~= "" or hasSelection(cfg(planting, "Never Shovel", {})) then
		recordPlanner("Shovel Runtime Packet", {
			Namespace = "ReplicatedStorage.SharedModules.Networking.Plant",
			Planting = planting,
			Money = money,
			RuntimePacketRequired = true,
		})
	end
end

function Reconstructed.RecordStub(featureName, config)
	table.insert(Reconstructed.ActionLog, {
		Type = "Stub",
		Name = featureName,
		Args = { config },
	})
end

function Reconstructed.AutoPlantStub(gagConfig, context)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()
	local planting = section(gagConfig, "Planting")

	if not cfg(planting, "Auto Plant", true) then
		return 0
	end

	Reconstructed.RecordStub("Auto Plant", planting)
	return Reconstructed.PlantAllGAG2(context, gagConfig)
end

function Reconstructed.MoneyStub(gagConfig, context)
	local money = section(gagConfig, "Money")
	Reconstructed.RecordStub("Money", money)
end

function Reconstructed.PetsStub(gagConfig, context)
	local pets = section(gagConfig, "Pets")

	if next(pets) then
		Reconstructed.RecordStub("Pets Buy Equip Slots", pets)
	end
end

function Reconstructed.GearStub(gagConfig, context)
	local gear = section(gagConfig, "Gear")

	if cfg(gear, "Auto Buy", true) then
		Reconstructed.RecordStub("Gear Sprinkler", gear)
	end
end

function Reconstructed.EventSeedsStub(gagConfig, context)
	local eventSeeds = section(gagConfig, "Event Seeds")

	if cfg(eventSeeds, "Auto Claim", true) then
		Reconstructed.RecordStub("Event Seeds Auto Claim", eventSeeds)
	end
end

function Reconstructed.MailStub(gagConfig, context)
	local mail = section(gagConfig, "Mail")

	if cfg(mail, "Auto Claim", true) or cfg(mail, "Send To", "") ~= "" then
		Reconstructed.RecordStub("Mail", mail)
	end
end

function Reconstructed.MiscStub(gagConfig, context)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()
	local misc = section(gagConfig, "Misc")
	Reconstructed.RecordStub("Misc", misc)

	return {
		WalkSpeed = Reconstructed.SetWalkSpeedGAG(context, gagConfig),
		ReturnToGarden = Reconstructed.ReturnToGardenGAG(context, gagConfig),
	}
end

function Reconstructed.FriendsStub(gagConfig, context)
	local friends = section(gagConfig, "Friends")

	if cfg(friends, "Auto Accept", false) or cfg(friends, "Auto Send", false) then
		Reconstructed.RecordStub("Friends", friends)
	end
end

function Reconstructed.PerformanceStub(gagConfig, context)
	context = context or {}
	gagConfig = gagConfig or context.GAGConfig or Reconstructed.GetEffectiveGAGConfig()
	local performance = section(gagConfig, "Performance")
	Reconstructed.RecordStub("Performance", performance)
	return Reconstructed.ApplyPerformanceGAG(context, gagConfig)
end

function Reconstructed.DebugStub(gagConfig, context)
	local debugConfig = section(gagConfig, "Debug")
	Reconstructed.RecordStub("Debug", debugConfig)
end

function Reconstructed.CreateSimpleGUI(context)
	context = context or {}

	local player = getLocalPlayer(context)
	local playerGui = player and findChild(player, "PlayerGui")

	if not playerGui or not Instance then
		return nil
	end

	local existing = findChild(playerGui, "GAG2ReconstructedGUI")
	if existing then
		return existing
	end

	_G.GAGConfig = Reconstructed.GetEffectiveGAGConfig(_G.GAGConfig)

	local gui = Instance.new("ScreenGui")
	gui.Name = "GAG2ReconstructedGUI"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "Main"
	frame.Size = UDim2.fromOffset(330, 520)
	frame.Position = UDim2.new(0, 20, 0.5, -260)
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local showButton = Instance.new("TextButton")
	showButton.Name = "ShowButton"
	showButton.Size = UDim2.fromOffset(90, 30)
	showButton.Position = UDim2.fromOffset(20, 20)
	showButton.BackgroundColor3 = Color3.fromRGB(55, 90, 160)
	showButton.BorderSizePixel = 0
	showButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	showButton.Font = Enum.Font.SourceSansBold
	showButton.TextSize = 14
	showButton.Text = "SHOW GUI"
	showButton.Visible = false
	showButton.Parent = gui

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 34)
	title.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	title.BorderSizePixel = 0
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 18
	title.Text = "GAG2 Autofarm Config"
	title.Parent = frame

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.Size = UDim2.new(1, -20, 0, 24)
	status.Position = UDim2.fromOffset(10, 40)
	status.BackgroundTransparency = 1
	status.TextColor3 = Color3.fromRGB(200, 200, 200)
	status.Font = Enum.Font.SourceSans
	status.TextSize = 15
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Text = "Status: stopped"
	status.Parent = frame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Controls"
	scroll.Size = UDim2.new(1, -20, 1, -72)
	scroll.Position = UDim2.fromOffset(10, 68)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.CanvasSize = UDim2.fromOffset(0, 0)
	scroll.Parent = frame

	local resizeHandle = Instance.new("TextButton")
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.Size = UDim2.fromOffset(22, 22)
	resizeHandle.Position = UDim2.new(1, -22, 1, -22)
	resizeHandle.BackgroundColor3 = Color3.fromRGB(70, 70, 82)
	resizeHandle.BorderSizePixel = 0
	resizeHandle.TextColor3 = Color3.fromRGB(255, 255, 255)
	resizeHandle.Font = Enum.Font.SourceSansBold
	resizeHandle.TextSize = 16
	resizeHandle.Text = "↘"
	resizeHandle.ZIndex = 3
	resizeHandle.Parent = frame

	local UserInputService = context.UserInputService or getService("UserInputService")
	local minWidth, minHeight = 280, 300
	local maxWidth, maxHeight = 600, 700
	local dragging = false
	local resizing = false
	local dragStart = nil
	local resizeStart = nil
	local startPosition = nil
	local startSize = nil

	local function clampNumber(value, minimum, maximum)
		value = tonumber(value) or minimum
		if value < minimum then
			return minimum
		end
		if value > maximum then
			return maximum
		end
		return value
	end

	local function getSafeValue(target, key)
		local success, value = safeCall(function()
			return target and target[key]
		end)
		if success then
			return value
		end
		return nil
	end

	local inputTypes = Enum and Enum.UserInputType
	local mouseButtonInput = inputTypes and inputTypes.MouseButton1
	local mouseMovementInput = inputTypes and inputTypes.MouseMovement
	local touchInput = inputTypes and inputTypes.Touch

	local function isPressInput(input)
		local inputType = getSafeValue(input, "UserInputType")
		return inputType == mouseButtonInput or inputType == touchInput
	end

	local function isMoveInput(input)
		local inputType = getSafeValue(input, "UserInputType")
		return inputType == mouseMovementInput or inputType == touchInput
	end

	local function connectInput(signal, callback)
		if not signal or type(callback) ~= "function" then
			return nil
		end
		local success, connection = safeCall(function()
			return signal:Connect(callback)
		end)
		if success then
			return connection
		end
		return nil
	end

	local function updateDrag(input)
		if not dragging or resizing or not dragStart or not startPosition or not isMoveInput(input) then
			return
		end
		local position = getSafeValue(input, "Position")
		if not position then
			return
		end
		local deltaX = position.X - dragStart.X
		local deltaY = position.Y - dragStart.Y
		safeCall(function()
			frame.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + deltaX,
				startPosition.Y.Scale,
				startPosition.Y.Offset + deltaY
			)
		end)
	end

	local function updateResize(input)
		if not resizing or not resizeStart or not startSize or not isMoveInput(input) then
			return
		end
		local position = getSafeValue(input, "Position")
		if not position then
			return
		end
		local width = clampNumber(startSize.X + position.X - resizeStart.X, minWidth, maxWidth)
		local height = clampNumber(startSize.Y + position.Y - resizeStart.Y, minHeight, maxHeight)
		safeCall(function()
			frame.Size = UDim2.fromOffset(width, height)
		end)
	end

	safeSet(title, "Active", true)
	safeSet(resizeHandle, "Active", true)
	safeSet(resizeHandle, "AutoButtonColor", false)

	connectInput(getSafeValue(title, "InputBegan"), function(input)
		if resizing or not isPressInput(input) then
			return
		end
		local position = getSafeValue(input, "Position")
		local currentPosition = getSafeValue(frame, "Position")
		if not position or not currentPosition then
			return
		end
		dragging = true
		dragStart = position
		startPosition = currentPosition
	end)

	connectInput(getSafeValue(resizeHandle, "InputBegan"), function(input)
		if not isPressInput(input) then
			return
		end
		local position = getSafeValue(input, "Position")
		local currentSize = getSafeValue(frame, "AbsoluteSize")
		if not position or not currentSize then
			return
		end
		resizing = true
		dragging = false
		resizeStart = position
		startSize = currentSize
	end)

	if UserInputService then
		connectInput(getSafeValue(UserInputService, "InputChanged"), function(input)
			if resizing then
				updateResize(input)
			elseif dragging then
				updateDrag(input)
			end
		end)
		connectInput(getSafeValue(UserInputService, "InputEnded"), function(input)
			if isPressInput(input) then
				dragging = false
				resizing = false
			end
		end)
	end

	local y = 0

	local function setStatus(text)
		status.Text = text
	end

	local function getConfigSection(sectionName)
		_G.GAGConfig = Reconstructed.GetEffectiveGAGConfig(_G.GAGConfig)
		return section(_G.GAGConfig, sectionName)
	end

	local function bump(amount)
		y = y + amount
		scroll.CanvasSize = UDim2.fromOffset(0, y + 20)
	end

	local function label(text)
		local item = Instance.new("TextLabel")
		item.Size = UDim2.new(1, -6, 0, 24)
		item.Position = UDim2.fromOffset(0, y)
		item.BackgroundTransparency = 1
		item.TextColor3 = Color3.fromRGB(255, 220, 120)
		item.Font = Enum.Font.SourceSansBold
		item.TextSize = 15
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.Text = text
		item.Parent = scroll
		bump(26)
		return item
	end

	local function makeButton(text, callback, color)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, -6, 0, 30)
		button.Position = UDim2.fromOffset(0, y)
		button.BackgroundColor3 = color or Color3.fromRGB(55, 90, 160)
		button.BorderSizePixel = 0
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.Font = Enum.Font.SourceSansBold
		button.TextSize = 15
		button.Text = text
		button.Parent = scroll
		button.MouseButton1Click:Connect(callback)
		bump(34)
		return button
	end

	local function makeToggle(sectionName, key, default)
		local button
		local function refresh()
			local target = getConfigSection(sectionName)
			button.Text = sectionName .. "." .. key .. ": " .. tostring(cfg(target, key, default))
		end
		button = makeButton("", function()
			local target = getConfigSection(sectionName)
			target[key] = not cfg(target, key, default)
			refresh()
			setStatus(key .. " = " .. tostring(target[key]))
		end, Color3.fromRGB(50, 70, 115))
		refresh()
		return button
	end

	local function makeNumber(sectionName, key, default)
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(1, -6, 0, 30)
		box.Position = UDim2.fromOffset(0, y)
		box.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
		box.BorderSizePixel = 0
		box.TextColor3 = Color3.fromRGB(255, 255, 255)
		box.Font = Enum.Font.SourceSans
		box.TextSize = 15
		box.ClearTextOnFocus = false
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.Text = sectionName .. "." .. key .. " = " .. tostring(cfg(getConfigSection(sectionName), key, default))
		box.Parent = scroll
		box.FocusLost:Connect(function()
			local number = tonumber(box.Text:match("%-?%d+%.?%d*"))
			if number ~= nil then
				local target = getConfigSection(sectionName)
				target[key] = number
				box.Text = sectionName .. "." .. key .. " = " .. tostring(number)
				setStatus(key .. " = " .. tostring(number))
			end
		end)
		bump(34)
		return box
	end

	makeButton("START FARM", function()
		_G.GAGRunning = true
		Reconstructed.ExecuteRemotes = true
		Reconstructed.ExecuteMovement = true
		setStatus("Status: running")

		if not _G.GAG2ReconstructedLoop then
			_G.GAG2ReconstructedLoop = true
			local spawnFn = task and task.spawn or spawn
			if type(spawnFn) == "function" then
				spawnFn(function()
					while _G.GAGRunning do
						safeCall(function()
							Reconstructed.RunOnce({
								Require = require,
								ExecuteRemotes = true,
								ExecuteMovement = true,
								GAGConfig = _G.GAGConfig,
							})
						end)
						safeWait(1)
					end
					_G.GAG2ReconstructedLoop = false
				end)
			else
				_G.GAG2ReconstructedLoop = false
			end
		end
	end, Color3.fromRGB(40, 140, 70))

	makeButton("STOP FARM", function()
		_G.GAGRunning = false
		setStatus("Status: stopped")
	end, Color3.fromRGB(150, 55, 55))

	makeButton("HIDE GUI", function()
		frame.Visible = false
		showButton.Visible = true
	end, Color3.fromRGB(80, 80, 90))

	showButton.MouseButton1Click:Connect(function()
		frame.Visible = true
		showButton.Visible = false
	end)

	label("Harvest")
	makeToggle("Harvest", "Auto Harvest", true)
	makeNumber("Harvest", "Sell At", 85)
	makeNumber("Harvest", "Sell Every", 40)

	label("Planting")
	makeToggle("Planting", "Auto Plant", true)
	makeNumber("Planting", "Plant Limit", 0)

	label("Money / Replace")
	makeToggle("Money", "Auto Expand Plot", true)
	makeToggle("Money", "Auto Replace Plants", true)
	makeNumber("Money", "Keep Cash", 15000)
	makeNumber("Money", "Expand If Over", 1500000)

	label("Pets / Gear / Event / Mail")
	makeToggle("Pets", "Auto Buy Slots", true)
	makeToggle("Gear", "Auto Buy", true)
	makeToggle("Event Seeds", "Auto Claim", true)
	makeToggle("Mail", "Auto Claim", true)

	label("Misc")
	makeToggle("Misc", "Auto Return To Garden", true)
	makeToggle("Misc", "Teleport", true)
	makeToggle("Misc", "Fast Travel", true)
	makeToggle("Misc", "Hide Game UI", false)
	makeNumber("Misc", "Walk Speed", 35)
	makeNumber("Misc", "Slide Speed", 35)

	label("Performance")
	makeToggle("Performance", "Low Graphics", true)
	makeToggle("Performance", "Remove Other Gardens", true)
	makeToggle("Performance", "Hide Crop Visuals", true)
	makeToggle("Performance", "Hide Fruit Visuals", true)
	makeToggle("Performance", "Hide Players", true)
	makeNumber("Performance", "FPS Cap", 0)

	label("Friends / Debug")
	makeToggle("Friends", "Auto Accept", false)
	makeToggle("Friends", "Auto Send", false)
	makeToggle("Debug", "Log To File", true)
	makeToggle("Debug", "Console", true)

	label("Networking Debug")
	makeButton("SCAN NETWORKING", function()
		context.Require = context.Require or require
		local _, dump = Reconstructed.ScanNetworkingGAG2(context)
		setStatus("Networking entries: " .. tostring(#(dump or {})))
	end, Color3.fromRGB(70, 95, 135))
	makeButton("SCAN FULL DEPTH 15", function()
		context.Require = context.Require or require
		local _, dump = Reconstructed.ScanNetworkingFullGAG2(context)
		setStatus("Full networking entries: " .. tostring(#(dump or {})))
	end, Color3.fromRGB(70, 95, 135))
	makeButton("SAVE FULL DUMP", function()
		context.Require = context.Require or require
		local _, dump = Reconstructed.ScanNetworkingFullGAG2(context)
		local success, path = Reconstructed.SaveDumpGAG2(context, dump, "GAG2/networking_full_depth15.txt")
		setStatus("Save full dump: " .. tostring(success) .. " " .. tostring(path))
	end, Color3.fromRGB(70, 95, 135))
	makeButton("SAVE GEAR DUMP", function()
		context.Require = context.Require or require
		local success, path = Reconstructed.SaveNamespaceDumpGAG2(context, "GearShop")
		setStatus("Save GearShop dump: " .. tostring(success) .. " " .. tostring(path))
	end, Color3.fromRGB(70, 95, 135))
	makeButton("SAVE MAIL DUMP", function()
		context.Require = context.Require or require
		local success, path = Reconstructed.SaveNamespaceDumpGAG2(context, "Mail")
		setStatus("Save Mail dump: " .. tostring(success) .. " " .. tostring(path))
	end, Color3.fromRGB(70, 95, 135))
	makeButton("SAVE PLANT DUMP", function()
		context.Require = context.Require or require
		local success, path = Reconstructed.SaveNamespaceDumpGAG2(context, "Plant")
		setStatus("Save Plant dump: " .. tostring(success) .. " " .. tostring(path))
	end, Color3.fromRGB(70, 95, 135))
	makeButton("SAVE SEEDPACK DUMP", function()
		context.Require = context.Require or require
		local success, path = Reconstructed.SaveNamespaceDumpGAG2(context, "SeedPack")
		setStatus("Save SeedPack dump: " .. tostring(success) .. " " .. tostring(path))
	end, Color3.fromRGB(70, 95, 135))
	makeButton("SAVE PET DUMP", function()
		context.Require = context.Require or require
		local success, path = Reconstructed.SaveNamespaceDumpGAG2(context, "Pet", "Pet")
		setStatus("Save Pet dump: " .. tostring(success) .. " " .. tostring(path))
	end, Color3.fromRGB(70, 95, 135))
	makeButton("SAVE AUCTION DUMP", function()
		context.Require = context.Require or require
		local success, path = Reconstructed.SaveNamespaceDumpGAG2(context, "Auction", "Auction")
		setStatus("Save Auction dump: " .. tostring(success) .. " " .. tostring(path))
	end, Color3.fromRGB(70, 95, 135))
	makeButton("PRINT DUMP", function()
		context.Require = context.Require or require
		Reconstructed.PrintDumpGAG2(context)
		setStatus("Printed dump: " .. tostring(#(Reconstructed.NetworkingDumpGAG2 or {})))
	end, Color3.fromRGB(70, 95, 135))
	makeButton("COPY DUMP", function()
		context.Require = context.Require or require
		local success = Reconstructed.CopyDumpGAG2(context)
		setStatus("Copy dump: " .. tostring(success))
	end, Color3.fromRGB(70, 95, 135))
	makeButton("SAVE DUMP", function()
		context.Require = context.Require or require
		local success, path = Reconstructed.SaveDumpGAG2(context)
		setStatus("Save dump: " .. tostring(success) .. " " .. tostring(path))
	end, Color3.fromRGB(70, 95, 135))

	return gui
end

function Reconstructed.Start(context)
	context = context or {}
	_G.GAGRunning = true
	Reconstructed.ExecuteRemotes = context.ExecuteRemotes ~= false
	Reconstructed.ExecuteMovement = context.ExecuteMovement ~= false
	Reconstructed.CreateSimpleGUI(context)

	while _G.GAGRunning do
		safeCall(function()
			Reconstructed.RunOnce({
				Require = context.Require or require,
				ExecuteRemotes = true,
				ExecuteMovement = true,
				GAGConfig = _G.GAGConfig,
			})
		end)
		safeWait(context.Interval or 1)
	end
end

function Reconstructed.RunOnce(context)
	context = context or {}

	local gagConfig = Reconstructed.GetEffectiveGAGConfig(context.GAGConfig)
	local config = context.Config or Reconstructed.BuildLegacyConfig(gagConfig)
	local api = context.Api or Reconstructed.CreateDefaultApi()

	context.GAGConfig = gagConfig
	context.Config = config
	context.Plot = context.Plot or Reconstructed.GetOwnerPlot(context)

	Reconstructed.SetWalkSpeedGAG(context, gagConfig)
	Reconstructed.ReturnToGardenGAG(context, gagConfig)
	Reconstructed.ApplyPerformanceGAG(context, gagConfig)
	Reconstructed.HarvestAllByPrompt(context, gagConfig)
	Reconstructed.CollectDroppedFruitGAG(context)

	if Reconstructed.ShouldSellGAG(gagConfig, context) then
		Reconstructed.SellAllGAG2(context)
	end

	Reconstructed.PlantAllGAG2(context, gagConfig)

	if context.RunLegacyLayer then
		if context.AuctionGui and context.PlayerData then
			Reconstructed.AutoBuyAuction(config, context.AuctionGui, context.PlayerData, api)
		end

		if context.PlayerStats then
			Reconstructed.AutoSellAll(config, api, context.Inventory, context.PlayerStats, context.CanSellByMultiplier)
			Reconstructed.AutoSellFruit(config, context.CanSellByMultiplier, context.PlayerStats, api, context.ToolManager, context.Player)
		end

		if context.Gui then
			Reconstructed.ESPFruitValue(context.Gui, api, config)
			Reconstructed.ShowFruitInventoryValue(context.Gui, context.PlayerStats, api)
		end

		if context.SharedModules then
			Reconstructed.ESPSpawnedPets(config, api, context.SharedModules)
		end

		Reconstructed.AutoCollectFruit(config, api, context.LocalPlayer, context.PlayerState, context.Require, context.Inventory)
		Reconstructed.AutoCollectAllFruit(config, api, context.PlayerState, context.Inventory)
		Reconstructed.ESPFruit(config, context.LocalPlayer, api, context.SharedModules, context.Require)
		Reconstructed.AutoSellPets(config, api, context.ToolManager, context.Player)
	end

	Reconstructed.AutoBuySeedsGAG2(context, gagConfig)
	Reconstructed.AutoBuyGearGAG2(context, gagConfig)
	Reconstructed.AutoPetsGAG2(context, gagConfig)
	Reconstructed.AutoMailGAG2(context, gagConfig)
	Reconstructed.AutoBuyAuctionGAG2(context, gagConfig)
	Reconstructed.AutoExpandPlotGAG2(context, gagConfig)
	Reconstructed.AutoShovelReplaceGAG2(context, gagConfig)
	Reconstructed.EventSeedsStub(gagConfig, context)
	Reconstructed.MiscStub(gagConfig, context)
	Reconstructed.FriendsStub(gagConfig, context)
	Reconstructed.DebugStub(gagConfig, context)
end

if type(_G) == "table" then
	_G.GAG2Reconstructed = Reconstructed
end

if type(game) == "userdata" or type(game) == "table" then
	safeCall(function()
		Reconstructed.CreateSimpleGUI({ Require = require })
	end)
end

return Reconstructed
