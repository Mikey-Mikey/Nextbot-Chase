AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile("utils/chat.lua")

-- Includes
include("utils/chat.lua")
include( "shared.lua" )
include( "sv_restrictions.lua" )

util.AddNetworkString("spectate_next")
util.AddNetworkString("chase_time")

navmesh.Load()