AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include( "shared.lua" )
include( "sv_restrictions.lua" )

util.AddNetworkString("spectate_next")
util.AddNetworkString("chase_time")