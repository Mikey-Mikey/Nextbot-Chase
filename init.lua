-- Includes
include("utils/chat.lua")
include( "shared.lua" )

util.AddNetworkString("spectate_next")
util.AddNetworkString("chase_time")

----------- new stuff line -----------------

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )

include( "sv_player.lua" )
include( "sv_nextbots.lua" )
include( "sv_rounds.lua" )

function GM:InitPostEntity()
	navmesh.Load()
end