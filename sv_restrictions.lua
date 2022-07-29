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

hook.Add( "PlayerCanHearPlayersVoice", "Maximum Range", function( listener, talker )
	if talker:GetObserverMode() != OBS_MODE_NONE and listener:GetObserverMode() != OBS_MODE_NONE then
		return true
	end
	if talker:GetObserverMode() == OBS_MODE_NONE and listener:GetObserverMode() == OBS_MODE_NONE then
		return true
	end
	if talker:GetObserverMode() != OBS_MODE_NONE and listener:GetObserverMode() == OBS_MODE_NONE then
		return false
	end
	if talker:GetObserverMode() == OBS_MODE_NONE and listener:GetObserverMode() != OBS_MODE_NONE then
		return false
	end
end )