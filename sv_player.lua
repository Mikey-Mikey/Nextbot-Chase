local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:spawnAsSpectator(target)
    self:StripWeapons()

    if not IsValid(target) then 
        self:Spectate(OBS_MODE_ROAMING)
    else
        self:Spectate(OBS_MODE_CHASE)
        self:SpectateEntity(target)
        self:SetPos(target:GetPos())
    end
end

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