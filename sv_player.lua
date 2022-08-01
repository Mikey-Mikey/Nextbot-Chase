-- weapons to give the player when they spawn
local playerWeapons = {
    "parkourmod"
}

-- micro optimizations
local simpleTimer = timer.Simple
local getAllPlayers = player.GetAll
local IsValid = IsValid
local pairs = pairs

-- run when the player spawns
hook.Add( "PlayerSpawn", "player", function( ply ) 
    -- check if the player is a spectator
    if ply.spectating then return end

    -- set the player's model
    ply:SetModel( "models/player/odessa.mdl" )

    -- remove the player's velocity (kept across spawns for some reason)
    ply:SetVelocity(-ply:GetVelocity())

    -- actually give the player the weapons in the table
    for _,wep in pairs(playerWeapons) do
        ply:Give(wep)
    end
end )

-- run when the server is a
hook.Add("PreRoundStart", "players", function(round)
    -- clear the global alive players table on round start
    GAMEMODE.players = {}

    -- for every player on the server do the following 
    for i,ply in pairs(getAllPlayers()) do
        timer.Simple(i * 0.05, function()
            ply:UnSpectate()
            ply:Spawn()
            ply:SetTeam(1)
            ply:SetNoCollideWithTeammates(true)
            ply:SetPos(ply:GetPos() + ply:GetAimVector() * math.random(0,100)) --for some reason, this is needed to prevent the players from spawning in the same spot
            ply:GodEnable()

            -- add the player to the global alive players table
            GAMEMODE.players[#GAMEMODE.players + 1] = ply
        end)
    end
end)

-- when the round starts after 3 seconds disable spawn protection 
hook.Add("RoundStart", "players", function(round)
    for _,ply in pairs(getAllPlayers()) do
        simpleTimer(3, function()
			if IsValid(ply) then 
                ply:GodDisable() 
                ply:SetNoCollideWithTeammates(false)
            end
		end)
    end
end)



hook.Add( "PlayerSpawnSWEP", "players", function(ply, desiredState)
    return false
end )

hook.Add( "PlayerCanNoclip", "players", function(ply)
    return false
end )

hook.Add( "PlayerSpawnVehicle", "players", function(ply)
	return false
end )

hook.Add( "PlayerSpawnProp", "players", function(ply)
	return false
end )

hook.Add( "PlayerSpawnSENT", "players", function(ply)
	return false
end )

hook.Add( "GetFallDamage", "RealisticDamage", function( ply, speed )
	return 0
end )