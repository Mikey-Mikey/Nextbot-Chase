-- Includes
include("utils/chat.lua")

util.AddNetworkString("spectate_next")
util.AddNetworkString("chase_time")

----------- new stuff line -----------------

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_player.lua" )
AddCSLuaFile( "cl_rounds.lua" )

include( "shared.lua" )
include( "sv_player.lua" )
include( "sv_nextbots.lua" )
include( "sv_rounds.lua" )

GM.players = {}

function GM:InitPostEntity()
	navmesh.Load()
end