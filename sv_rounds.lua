local players = {}
local spectators = {}
local round = 0

util.AddNetworkString("round_state")


local function preRoundStart()
    round = round + 1

    net.Start("round_state")
    net.WriteString("preRoundStart")
    net.WriteInt(round)
    net.Broadcast()
    
    hook.Run("PreRoundStart", round)

    startRound()
end

local function startRound()
    net.Start("round_state")
    net.WriteString("startRound")
    net.WriteInt(round)
    net.Broadcast()

    hook.Run("RoundStart", round)
end

local function endRound()
    net.Start("round_state")
    net.WriteString("endRound")
    net.WriteInt(round)
    net.Broadcast()

    hook.Run("RoundEnd", round)
end

local function endRoundCheck()
    if not #players then endRound() end
end

hook.Add( "CanPlayerSuicide", "AllowOwnerSuicide", function( ply )
	if ply:IsSuperAdmin() then return true end

    if players[ply] ~= nil then return false end
end )