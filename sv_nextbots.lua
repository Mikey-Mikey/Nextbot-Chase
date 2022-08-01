-- how many next bots shound be spawned by default
local baseNextBotCount = 2

-- table of bots that are able to be spawned
local nextbots = {
	"npc_wenomachainsama",
	"npc_gigachad",
	"npc_sanic",
	"npc_nerd",
	"npc_luayer",
	"npc_finger",
	"npc_smiley",
	"npc_walter",
	"npc_armstrong",
	"npc_megamind",
	"npc_obunga",
	"npc_cheemsburger",
	"npc_selenedelgado",
	"npc_quandaledingle",
	"npc_smiler",
	"npc_jungler",
	"npc_thewok",
	"npc_gru",
	"npc_morbius",
	"npc_ishowspeed",
	"npc_polishcow",
	"npc_putin",
}

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
local function spawnBots(amount)
		for i = 1,amount do
		local pos_found = false
		local pos


		while not pos_found do
			for _, ply in ipairs(getAllPlayers()) do
				pos = areas[random(#areas)]:GetRandomPoint()

				if ply:GetPos():Distance(pos) > 100 then
					pos_found = true
				end
			end
		end

		local nextbot = ents.Create(nextbots[random(#nextbots)])

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
	spawnBots((math.Round(max:Length() / 3000, -1)) + baseNextBotCount)
end)

hook.Add("RoundEnd", "nextbots", function(round)
    for _, ent in ipairs(activeBots) do
		if IsValid(ent) then ent:Remove() end
	end
end)