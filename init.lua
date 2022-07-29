-- send files to the client
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_spectate.lua" )
AddCSLuaFile( "cl_rounds.lua" )

-- include server and shared files
include( "shared.lua" )
include( "sv_player.lua" )
include( "sv_nextbots.lua" )
include( "sv_rounds.lua" )

-- create the global inplay player table 
GM.players = {}

-- load the navmesh when the map loads
function GM:InitPostEntity()
	navmesh.Load()
end