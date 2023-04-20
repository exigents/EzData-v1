--// Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Vars
local Overhead = ReplicatedStorage:WaitForChild("Overhead")

--// Data Funcs
local self = {}

self.DataStore = DataStoreService:GetDataStore("HIDEANDSEEKDATA_3")

self.DataFuncs = {
	getKey = function(player: Player)
		return "~~~"..player.UserId
	end,
	getData = function(player: Player)
		local Data = nil
		pcall(function()
			Data = self.DataStore:GetAsync(self.DataFuncs.getKey(player))
		end)
		return Data
	end,
	saveData = function(player: Player)
		local DataTable = {
			leaderstats = {},
			Attributes = player:GetAttributes()
		}
		
		for i,v in pairs(player:FindFirstChild("leaderstats"):GetChildren()) do
			DataTable.leaderstats[v.Name] = v.Value
		end
		
		self.DataStore:SetAsync(self.DataFuncs.getKey(player), DataTable)
	end,
	loadData = function(player: Player, DataTable)
		local leaderstats = player:FindFirstChild("leaderstats")
		
		for DataName, DataValue in pairs(DataTable.leaderstats) do
			leaderstats:FindFirstChild(DataName).Value = DataValue
		end
		
		for AttName, AttValue in pairs(DataTable.Attributes) do
			player:SetAttribute(AttName, AttValue)
		end
	end,
}

--// Player Funcs
function CharacterAdded(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	repeat task.wait() until Character:FindFirstChild("Head") and Character:FindFirstChild("Humanoid")
	local Head = Character:FindFirstChild("Head")
	local Humanoid = Character:FindFirstChild("Humanoid")
	
	local newOver = Overhead:Clone()
	newOver.label.Text = Player.DisplayName.."\n@"..Player.Name.."\nLv. "..tostring(Player:GetAttribute("Level"))
	newOver.Parent = Head

	Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	Player:GetAttributeChangedSignal("Level"):Connect(function()
		newOver.label.Text = Player.DisplayName.."\n@"..Player.Name.."\nLv. "..tostring(Player:GetAttribute("Level"))
	end)
end

self.PlayerFuncs = {
	PlayerAdded = function(player: Player)
		local leaderstats = Instance.new("Folder")
		local Tags = Instance.new("NumberValue")
		local Wins = Instance.new("NumberValue")
		
		leaderstats.Name = "leaderstats"
		Tags.Name = "Tags"
		Wins.Name = "Wins"
		
		player:SetAttribute("XP", 0)
		player:SetAttribute("Level", 1)
		player:SetAttribute("Alive", false)
		player:SetAttribute("Tagger", false)
		player:SetAttribute("Powers", "")
		player:SetAttribute("Coins", 0)
		
		Tags.Parent = leaderstats
		Wins.Parent = leaderstats
		leaderstats.Parent = player
		
		local PlayerData = self.DataFuncs.getData(player)

		if PlayerData ~= nil then
			self.DataFuncs.loadData(player, PlayerData)
		end
		
		player:GetAttributeChangedSignal("XP"):Connect(function()
			if player:GetAttribute("XP") >= player:GetAttribute("Level") * 100 then
				player:SetAttribute("XP", 0)
				local oldLv = player:GetAttribute("Level")
				player:SetAttribute("Level", oldLv + 1)
			end
		end)
		
		player.CharacterAdded:Connect(CharacterAdded)
	end,
	PlayerRemoving = function(player: Player)
		player:SetAttribute("Alive", false)
		player:SetAttribute("Tagger", false)
		self.DataFuncs.saveData(player)
	end,
}

--// Connections
Players.PlayerAdded:Connect(self.PlayerFuncs.PlayerAdded)
Players.PlayerRemoving:Connect(self.PlayerFuncs.PlayerRemoving)
