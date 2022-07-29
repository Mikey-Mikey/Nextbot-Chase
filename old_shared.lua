GM.Name = "Nextbot Chase"
GM.Author = "Mikey! with help from Mee, Marshall_vak, and MyUsername"
GM.Email = "N/A"
GM.Website = "N/A"

-- Global Variables
local round = 1
local alive_people = alive_people or player.GetAll()
local has_people = has_people or false

function reward(ply)
	chatPrintFancy(ply:GetName() .. " won this round!")
end

function RestartGame()
	alive_people = player.GetAll()
	PrintTable(alive_people)

	

	if SERVER then
		timer.Simple(0, function()
			for _, ply in ipairs(player.GetAll()) do
				spawnAsRoaming(ply)
			end
		end)

		timer.Simple(4.0, function()
			print("RESTART TIMER CREATED")

			timer.Create("chase_Restart", 60 * 7, 1, function()
				for _, ply in ipairs(player.GetAll()) do
					reward(ply)
				end
				RestartGame()
			end)
			local areas = navmesh.GetAllNavAreas()
			for _, ply in ipairs(player.GetAll()) do
				ply:SetTeam(1)
				ply:UnSpectate()
				ply:SetNoCollideWithTeammates(true)
				ply:Spawn()
				ply:GodEnable()
				ply:SetPos(ply:GetPos() + ply:GetAimVector() * math.random(0,100)) --for some reason, this is needed to prevent the players from spawning in the same spot
				timer.Simple(2.0, function()
					if ply:IsValid() then
						ply:GodDisable()
					end
				end)
			end

			for _, npc in ipairs(ents.FindByClass("npc_*")) do
				npc:Remove()
			end

			for i = 1,4 do -- spawn 4 nextbots
				local pos_found = false
				local pos = areas[math.random(#areas)]:GetRandomPoint()

				while not pos_found do
					pos_found = true
					for _, ply in ipairs(player.GetAll()) do
						if ply:GetPos():Distance(pos) < 100 then
							pos = areas[math.random(#areas)]:GetRandomPoint()
							pos_found = false
						end
					end
				end

				local nextbot = ents.Create(nextbots[math.random(#nextbots)])

				nextbot:SetPos(pos)
				nextbot:Spawn()

				print("Nextbot Spawned!")
			end
		end)
	end

	round = round + 1
end

function GM:PlayerSpawn(ply)

	timer.Simple(0,function()
		if alive_people[ply] ~= nil and #alive_people > 0 then
			spawnAsSpectator(ply,table.Random(alive_people))
		end
	end)
end

net.Receive("spectate_next", function(len,ply)
	if alive_people[ply] ~= nil and #alive_people > 1 then
		local randomPly = table.Random(alive_people)

		while ply:GetObserverTarget() == randomPly do
			randomPly = table.Random(alive_people)
		end

		spawnAsSpectator(ply,randomPly)
	end
end)

