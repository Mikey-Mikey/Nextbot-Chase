local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:spawnAsSpectator(target)
    ply:Spawn()

    if not IsValid(target) then 
        self:Spectate(OBS_MODE_ROAMING)
    else
        self:Spectate(OBS_MODE_CHASE)
        self:SpectateEntity(target)
        self:SetPos(target:GetPos())
    end
end

function GM:PostPlayerDeath( ply )
    table.RemoveByValue(self.Players, ply)
    ply:spawnAsSpectator(self.Players[math.random(1, #self.Players)])
end

hook.Add("preRoundStart", "players", function(round)
    GAMEMODE.players = {}

    for _,ply in pairs(player.GetAll()) do
        ply:SetPos(ply:GetPos() + ply:GetAimVector() * math.random(0,100)) --for some reason, this is needed to prevent the players from spawning in the same spot
        GAMEMODE.players[#GAMEMODE.players + 1] = ply
    end
end)

hook.Add("RoundStart", "players", function(round)
    for _,ply in pairs(player.GetAll()) do
        timer.Simple(3, function()
			if ply:IsValid() then ply:GodDisable() end
		end)
    end
end)

hook.Add("RoundEnd", "players", function(round)
    for _,ply in pairs(player.GetAll()) do
        ply:killsilent()
        ply:spawnAsSpectator()
    end
end)

-- player restrictions
hook.Add( "CanPlayerSuicide", "AllowSuicide", function( ply )
	if ply:IsSuperAdmin() then return true end

    return ply:GetObserverMode() == OBS_MODE_NONE
end )

function GM:PlayerNoClip(ply, desiredState)
	return ply:IsSuperAdmin()
end

hook.Add( "PlayerSpawnSWEP", "SpawnBlockSWEP", function(ply)
	return ply:IsSuperAdmin()
end )

hook.Add( "PlayerSpawnVehicle", "SpawnBlockVehicle", function(ply)
	return ply:IsSuperAdmin()
end )

hook.Add( "PlayerSpawnProp", "SpawnBlockProp", function(ply)
	return ply:IsSuperAdmin()
end )

hook.Add( "PlayerSpawnSENT", "SpawnBlockSENT", function(ply)
	return ply:IsSuperAdmin()
end )