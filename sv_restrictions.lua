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