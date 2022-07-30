GM.Name = "Nextbot Chase"
GM.Author = "Mikey! with help from Mee, Marshall_vak, and MyUsername"
GM.Email = "N/A"
GM.Website = "N/A"

-- Global Variables
local round = 1
alive_people = alive_people or player.GetAll()
dead_early = dead_early or {}
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
	"npc_jungler",
	"npc_thewok",
	"npc_gru",
}
local current_nextbots = current_nextbots or {}
local contains = table.HasValue
function spawnAsSpectator(ply,target)
	if target:IsValid() then
	local ang = ply:EyeAngles()
		ply:SetPos(target:GetPos())
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(target)
		ply:SetMoveType(MOVETYPE_OBSERVER)
		ply:SetEyeAngles(ang)
		ply:StripWeapons()
	end
end


function spawnAsRoaming(ply)
	local pos = ply:GetShootPos()
	local ang = ply:EyeAngles()
	ply:SetPos(pos)
	ply:SetEyeAngles(ang)
	ply:Spectate(OBS_MODE_ROAMING)
	ply:SetMoveType(MOVETYPE_OBSERVER)
	ply:StripWeapons()
end

function reward(ply)
	chatPrintFancy(ply:GetName() .. " won this round!")
end

function RestartGame()
	dead_early = {}
	timer.Simple(4.0, function()
		alive_people = player.GetAll()
	end)
	if SERVER then
		timer.Simple(0, function()
			for _, ply in ipairs(player.GetAll()) do
				spawnAsRoaming(ply)
			end
		end)

		timer.Simple(4.0, function()
			timer.Create("SpawnProtect", 2.0, 1, function() end)
			print("RESTART TIMER CREATED")

			timer.Create("chase_Restart", 60 * 5, 1, function()
				for _, ply in ipairs(alive_people) do
					reward(ply)
				end
				RestartGame()
			end)
			local areas = navmesh.GetAllNavAreas()
			for _, ply in ipairs(player.GetAll()) do
				ply:UnSpectate()
				ply:Spawn()
				ply:SetPos(ply:GetPos() + ply:GetAimVector() * math.random(64) * Vector(1,1,0))
				ply:SetTeam(1)
				ply:SetNoCollideWithTeammates(true)
				ply:GodEnable()
				timer.Simple(3.0, function()
					if ply:IsValid() then
						ply:GodDisable()
					end
				end)
			end

			for _, npc in ipairs(ents.FindByClass("npc_*")) do
				npc:Remove()
			end
			for i = 1,4 do -- spawn 4 nextbots
				local pos = areas[math.random(#areas)]:GetRandomPoint()

				for k = 0,100 do
					for _, ply in ipairs(player.GetAll()) do
						if ply:GetPos():Distance(pos) < 200 then
							pos = areas[math.random(#areas)]:GetRandomPoint()
						end
					end
				end
				local nextbot_class = nextbots[math.random(#nextbots)]
				print("while 1")
				while contains(current_nextbots, nextbot_class) do
					nextbot_class = nextbots[math.random(#nextbots)]
				end
				local nextbot = ents.Create(nextbot_class)

				nextbot:SetPos(pos)
				nextbot:Spawn()
				current_nextbots[#current_nextbots + 1] = nextbot:GetClass()
				print("Nextbot Spawned!")
			end
			current_nextbots = {}
		end)
	end

	round = round + 1
end

if SERVER then
	timer.Create("chase_send_player_count", 0.5, 0, function()
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
	if ply:GetObserverMode() != OBS_MODE_NONE and contains(alive_people,ply) then
		table.RemoveByValue(alive_people, ply)
	end
	for k,spec in ipairs(player.GetAll()) do
		if spec:GetObserverMode() != OBS_MODE_NONE and ply == spec:GetObserverTarget() then
			local randomPly = table.Random(alive_people)
			print("while 2")
			while not randomPly:IsValid() and #alive_people > 0 do
				spec:Spawn()
				spawnAsSpectator(spec,randomPly)
			end
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
			local randomPly = table.Random(alive_people)
			print("while 3")
			while not randomPly:IsValid() or not contains(alive_people,randomPly) and #alive_people > 0 do
				randomPly = table.Random(alive_people)
			end
			spawnAsSpectator(ply,randomPly)
		end
	end)
end

if SERVER then
	function GM:SetupMove(ply,mv,cmd)
		if not contains(alive_people,ply) and ply:KeyPressed( IN_ATTACK ) and #alive_people > 1 and ply:GetObserverMode() != OBS_MODE_NONE then
			local randomPly = table.Random(alive_people)
			print("while 4")
			while #alive_people > 1 and ply:GetObserverTarget() == randomPly do
				randomPly = table.Random(alive_people)
			end
			spawnAsSpectator(ply,randomPly)
		end
	end
end
local dead_early = {}
function GM:PostPlayerDeath(victim, inflictor, attacker)
	if contains(alive_people,victim) and not timer.Exists("SpawnProtect") then
		table.RemoveByValue(alive_people, victim)

		if #alive_people >= 1 then
			timer.Simple(2.0, function()
				if #alive_people >= 1 then
					victim:Spawn()
					local randomPly = table.Random(alive_people)
					spawnAsSpectator(victim,randomPly)
					for k,ply in ipairs(player.GetAll()) do
						if ply:GetObserverMode() != OBS_MODE_NONE and victim == ply:GetObserverTarget() and ply != victim and #alive_people >= 1 then
							local randomPly = table.Random(alive_people)
							ply:Spawn()
							spawnAsSpectator(ply,randomPly)
						end
					end
				end
			end)
		end
	end -- random comment
	if timer.Exists("SpawnProtect") then
		victim:ChatPrint("You have been killed early, click to respawn!")
		dead_early[#dead_early + 1] = victim
		timer.Simple(8.0,function()
			if timer.Exists("SpawnProtect") then
				for k,ply in ipairs(dead_early) do
					if not ply:Alive() then
						table.RemoveByValue(alive_people, ply)
					end
				end
			end
			dead_early = {}
		end)
	end
	if #alive_people <= 0 and has_people then
		RestartGame()
	end
end

function GM:Tick()
	if SERVER and not timer.Exists("chase_sync") and timer.Exists("chase_Restart") then
		timer.Create("chase_sync",1,0,function()
			net.Start("chase_time")
			net.WriteInt(timer.TimeLeft("chase_Restart") or 0, 16)
			net.Broadcast()
		end)
	end
end
