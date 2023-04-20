local DataStoreService = game:GetService("DataStoreService")

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
