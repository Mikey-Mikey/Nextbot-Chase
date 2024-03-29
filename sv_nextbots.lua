-- how many next bots shound be spawned by default
local baseNextBotCount = 3

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- need to find a way to use list.Get("NPC")
-- StarFrost 7/30/2022, 11:53:17 AM Easily? I don't know. Your best bet is probably list.Get("NPC") since you'll be able to get every npc/nextbot. Only way I know of recognizing whatever class name is a nextbot is actually spawning down the entity and testing :IsNextBot() but that sounds very costly
-- Marshall_vak 7/30/2022, 11:54:21 AM that does sound costly
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- table of bots activly in the game and running around the server killing people
local activeBots = {}

-- areas in the nav mesh (set pre round)
local areas

-- micro optimizations
local random = math.random
local pairs = pairs
local ipairs = ipairs
local IsValid = IsValid
local getAllPlayers = player.GetAll
-- spawn bots at a random location
-- a
local function spawnBots(amount)
	local nextbots = {}
	local npcs = list.Get("NPC")
	for k,v in pairs(npcs) do
		if string.find(k, "tf2_ghost") or string.find(k, "MUNCI") then
			continue
		end
		local e = ents.Create(k)
		if e:IsNextBot() then
			nextbots[#nextbots + 1] = k
		end
		if IsValid(e) then
			e:Remove()
		end
	end
	for i = 1,amount do
		local pos_found = false
		local pos = areas[random(#areas)]:GetRandomPoint()

		local samples = 0
		while not pos_found and samples < 100 do
			for _, ply in ipairs(getAllPlayers()) do
				pos = areas[random(#areas)]:GetRandomPoint()

				if ply:GetPos():Distance(pos) > 200 then
					pos_found = true
				end
			end
			samples = samples + 1
		end
		local nextbot_class = nextbots[random(#nextbots)]
		if random(0,100) <= 0 then
			nextbot_class = "npc_ANGRY_MUNCI"
		end
		local nextbot = ents.Create(nextbot_class)

		nextbot:SetPos(pos)
		nextbot:Spawn()

		activeBots[#activeBots + 1] = nextbot
	end
end

-- before the round starts generate the areas of the nav mesh
hook.Add("PreRoundStart", "nextbots", function(round)
    areas = navmesh.GetAllNavAreas()
end)

-- round the amount of connected players up then divide by 10 (if there are 5 players on round up to 10 then devide by 10 to get 1) 
-- after all of that add the base next bot count then spawn that many bots
hook.Add("RoundStart", "nextbots", function(round)
	local min,max = game.GetWorld():GetModelBounds()
	spawnBots((math.Round(max:Length()) / 3000) + baseNextBotCount)
end)

hook.Add("RoundEnd", "nextbots", function(round)
    for _, ent in ipairs(activeBots) do
		if IsValid(ent) then ent:Remove() end
	end
end)