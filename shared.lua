GM.Name = "Nextbot Chase"
GM.Author = "Mikey! with help from Mee, Marshall_vak, and MyUsername"
GM.Email = "N/A"
GM.Website = "N/A"

-- Global Variables
local round = 1
local alive_people = alive_people or player.GetAll()
local has_people = has_people or false
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
	"npc_jungler"
}
local contains = table.HasValue
function spawnAsSpectator(ply,target)
	print("Spawning " .. ply:Nick() .. " as spectator")
	ply:SetPos(target:GetPos())
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(target)
	ply:SetMoveType(MOVETYPE_OBSERVER)
end


function spawnAsRoaming(ply)
	local pos = ply:GetShootPos()
	local ang = ply:EyeAngles()

	ply:Spawn()
	ply:SetPos(pos)
	ply:SetEyeAngles(ang)
	ply:Spectate(OBS_MODE_ROAMING)
	ply:SetMoveType(MOVETYPE_OBSERVER)
end

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

			timer.Create("chase_Restart", 60 * 5, 1, function()
				for _, ply in ipairs(player.GetAll()) do
					if contains(alive_people, ply) then
						reward(ply)
					end
				end
				RestartGame()
			end)
			local areas = navmesh.GetAllNavAreas()
			for _, ply in ipairs(player.GetAll()) do
				ply:SetTeam(1)
				ply:SetNoCollideWithTeammates(true)
				ply:UnSpectate()
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

if SERVER then
	timer.Create("chase_send_player_count", 1, 0, function()
		net.Start("chase_player_count")
			net.WriteInt(#alive_people, 8)
		net.Broadcast()
	end)
end
if #alive_people <= 0 then
	RestartGame()
end

function GM:InitPostEntity()
	RestartGame()
end

function GM:PlayerNoClip(ply, desiredState)
	return false
end

function GM:PlayerDisconnected(ply)
	if player.GetCount() == 0 then
		has_people = false
	end

	if contains(alive_people,ply) then
		table.RemoveByValue(alive_people, ply)
	end
	for k,spec in ipairs(player.GetAll()) do
		if spec:GetObserverMode() != OBS_MODE_NONE and ply == spec:GetObserverTarget() then
			spec:Spawn()
			spawnAsSpectator(spec,table.Random(alive_people))
		end
	end
	print(#alive_people)

	if #alive_people <= 0 and player.GetCount() > 0 then
		RestartGame()
	end
end


function GM:PlayerSpawn(ply)
	has_people = true
	if ply:GetObserverMode() == OBS_MODE_NONE then
		ply:Give("parkourmod")
	end
	ply:SetVelocity(-ply:GetVelocity())
	ply:SetModel( "models/player/odessa.mdl" )
	timer.Simple(0,function()
		if not contains(alive_people,ply) and #alive_people > 0 then
			spawnAsSpectator(ply,table.Random(alive_people))
		end
	end)
end

if CLIENT then
	function GM:SetupMove(ply,mv,cmd)
		if input.WasMousePressed(MOUSE_LEFT) and #alive_people > 1 then
			net.Start("spectate_next")
			net.SendToServer()
		end
	end
end

net.Receive("spectate_next", function(len,ply)
	if not contains(alive_people,ply) and #alive_people > 1 then
		local randomPly = table.Random(alive_people)
		while #alive_people > 1 do
			randomPly = table.Random(alive_people)
			if ply:GetObserverTarget() != randomPly then break end
		end
		ply:Spawn()
		spawnAsSpectator(ply,randomPly)
	end
end)

function GM:PostPlayerDeath(victim, inflictor, attacker)
	if contains(alive_people,victim) then
		table.RemoveByValue(alive_people, victim)

		if #alive_people >= 1 then
			timer.Simple(2.0, function()
				if #alive_people >= 1 then
					victim:Spawn()
					spawnAsSpectator(victim,table.Random(alive_people))
					for k,ply in ipairs(player.GetAll()) do
						if ply:GetObserverMode() != OBS_MODE_NONE and victim == ply:GetObserverTarget() and ply != victim then
							ply:Spawn()
							spawnAsSpectator(ply,table.Random(alive_people))
						end
					end
				end
			end)
		end
		print(#alive_people)
	end
end

function GM:Tick()
	if SERVER and not timer.Exists("chase_sync") and timer.Exists("chase_Restart") then
		timer.Create("chase_sync",1,0,function()
			net.Start("chase_time")
			net.WriteInt(timer.TimeLeft("chase_Restart"), 16)
			net.Broadcast()
		end)
	end

	if #alive_people <= 0 and has_people then
		RestartGame()
	end
end
