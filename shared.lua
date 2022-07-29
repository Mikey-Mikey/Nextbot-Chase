GM.Name = "Nextbot Chase"
GM.Author = "Mikey"
GM.Email = "N/A"
GM.Website = "N/A"

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
	"npc_smiler"
}

local function contains(list, value)
	for k, v in pairs(list) do
		if v == value then
			return true
		end
	end

	return false
end

function spawnAsSpectator(ply,target)
	ply:SetPos(target:GetPos())
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(target)
	ply:SetMoveType(MOVETYPE_OBSERVER)
	ply:StripWeapons()
end

function spawnAsRoaming()
	for k,v in ipairs(player.GetAll()) do
		local pos = v:GetShootPos()
		local ang = v:EyeAngles()

		v:Spawn()
		v:SetPos(pos)
		v:SetEyeAngles(ang)
		v:Spectate(OBS_MODE_ROAMING)
		v:SetMoveType(MOVETYPE_OBSERVER)
		v:StripWeapons()
	end
end

function reward(ply)
	ply:ChatPrint(ply:GetName() .. " won this round!")
end

function RestartGame()
	alive_people = player.GetAll()
	if SERVER then
		timer.Simple(0, function()
			spawnAsRoaming()
		end)

		timer.Simple(4.0, function()
			print("RESTART TIMER CREATED")

			timer.Create("chase_Restart", 60 * 7, 1, function()
				for k,v in ipairs(alive_people) do
					reward(v)
				end
				RestartGame()
			end)

			for k, v in ipairs(player.GetAll()) do
				v:SetTeam(1)
				v:UnSpectate()
				v:SetNoCollideWithTeammates(true)
				v:Spawn()
				v:GodEnable()
				local areas = navmesh.GetAllNavAreas()
				local pos = areas[math.random(#areas)]:GetRandomPoint()
				v:SetPos(pos) --for some reason, this is needed to prevent the players from spawning in the same spot
				timer.Simple(2.0, function()
					if v:IsValid() then
						v:GodDisable()
					end
				end)
			end

			for k,v in ipairs(ents.FindByClass("npc_*")) do
				v:Remove()
			end

			for i = 1,4 do -- spawn 4 nextbots
				local pos_found = false
				local areas = navmesh.GetAllNavAreas()
				local pos = areas[math.random(#areas)]:GetRandomPoint()

				while not pos_found do
					pos_found = true
					for k,v in ipairs(player.GetAll()) do
						if v:GetPos():Distance(pos) < 100 then
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

RestartGame()

function GM:InitPostEntity()
	if SERVER then
		navmesh.Load()
	end

	RestartGame()
end

local chase_time = 0

net.Receive("chase_time", function()
	chase_time = net.ReadInt(16)
end)

function GM:PostDrawHUD()
	surface.SetDrawColor(200,200,200,200)
	draw.RoundedBox(5, ScrW() / 2 - 150 / 2, -5, 150, 50, Color(0,0,0,200))

	draw.DrawText(math.floor(chase_time / 60) .. ":" .. string.format("%02d",math.floor(chase_time % 60)), "CloseCaption_Bold", ScrW() / 2, 3, Color(225,225,225,255), TEXT_ALIGN_CENTER)
	draw.SimpleText("Players Left: " .. #alive_people, "SmallText", ScrW() / 2 - 35, 26)
end

function GM:PlayerNoClip(ply, desiredState)
	return false
end

function GM:PlayerDisconnected(ply)
	if player.GetCount() == 0 then
		has_people = false
	end

	if contains(alive_people, ply) then
		table.RemoveByValue(alive_people, ply)
	end

	print(#alive_people)
	
	if #alive_people <= 0 and player.GetCount() > 0 then
		RestartGame()
	end
end

function GM:PlayerSpawn(ply)
	has_people = true

	ply:SetVelocity(-ply:GetVelocity())
	ply:Give("parkourmod")
	ply:SetModel( "models/player/odessa.mdl" )

	timer.Simple(0,function()
		if not contains(alive_people, ply) and #alive_people > 0 then
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

		while ply:GetObserverTarget() == randomPly do
			randomPly = table.Random(alive_people)
		end

		spawnAsSpectator(ply,randomPly)
	end
end)

function GM:PostPlayerDeath(victim, inflictor, attacker)
	if contains(alive_people, victim) and #alive_people >= 1 then
		table.RemoveByValue(alive_people, victim)

		if #alive_people >= 1 then
			timer.Simple(2.0, function()
				if #alive_people >= 1 then
					victim:Spawn()
					spawnAsSpectator(victim,table.Random(alive_people))
				end
			end)

			for k,v in ipairs(player.GetAll()) do
				if v:GetObserverTarget() == victim then
					v:Spawn()
					spawnAsSpectator(v,table.Random(alive_people))
				end
			end
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

	if SERVER then
		for k,v in ipairs(player.GetAll()) do
			for _, wep in ipairs( v:GetWeapons() ) do
				if wep:GetClass() ~= "parkourmod" then
					v:StripWeapon( wep:GetClass() )
				end
			end
		end
	end
	
	if #alive_people <= 0 and has_people then
		RestartGame()
	end
end