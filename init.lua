AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

util.AddNetworkString("spectate_next")
util.AddNetworkString("chase_time")

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