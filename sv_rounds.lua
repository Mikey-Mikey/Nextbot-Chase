-- round controller config
local preRoundTime = 1
local roundTime = 300
local afterRoundTime = 1

-- round controller internal variables
local round = 0
local roundState = 3

-- micro optimizations
local Color = Color
local runHook = hook.Run
local MsgC = MsgC
local createTimer = timer.Create
local removeValueFromTable = table.RemoveByValue

-- prep the network message
util.AddNetworkString("round_state")

-- prep the server for the next round
function GM:preRoundStart()
    -- increace the round counter
    roundState = 0
    round = round + 1

    -- let the client know that the round is about to start
    net.Start("round_state")
    net.WriteString("preRoundStart")
    net.WriteInt(round, 32)
    net.WriteInt(preRoundTime, 32)
    net.Broadcast()

    -- clean up the map with the vars from gmod issue #3637
    game.CleanUpMap( false, { "env_fire", "entityflame", "_firesmoke" } )
    
    -- let the server know that the round is preparing to start
    runHook("PreRoundStart", round, preRoundTime)

    -- wait for the round to start
    createTimer("preRoundStart", preRoundTime, 1, function()
        self:startRound()
    end)
end

-- start the round
function GM:startRound()
    -- set the internal round state to 1
    roundState = 1
    MsgC(Color(255, 255, 255), "[", Color(30, 255, 0), "Nextbot Chase", Color(255, 255, 255), "] Starting Round " .. round .. "\n")

    -- let the client know that the round is starting
    net.Start("round_state")
    net.WriteString("RoundStart")
    net.WriteInt(round, 32)
    net.WriteInt(roundTime, 32)
    net.Broadcast()

    -- let the server know that the round is starting
    runHook("RoundStart", round, roundTime)

    -- wait for the round to end
    createTimer("endRoundTime", roundTime, 1, function()
        self:endRound()
    end)
end

-- end the round
function GM:endRound()
    -- set the internal round state to 2
    roundState = 2
    MsgC(Color(255, 255, 255), "[", Color(30, 255, 0), "Nextbot Chase", Color(255, 255, 255), "] Ending Round " .. round .. "\n")

    -- let the client know that the round is ending
    net.Start("round_state")
    net.WriteString("RoundEnd")
    net.WriteInt(round, 32)
    net.WriteInt(afterRoundTime, 32)
    net.Broadcast()

    -- let the server know that the round is ending
    runHook("RoundEnd", round, afterRoundTime)

    -- wait for the next round to prepare
    createTimer("preRoundStart", afterRoundTime, 1, function()
        self:preRoundStart()
    end)
end

-- allow other files on the server to check the round state
function GM:getRoundState()
    return roundState
end

-- check if the round should end
local function endRoundCheck(ply)
    -- if a player is not alive / leaves / spawns after the round has started then remove them from the global player table 
    removeValueFromTable(GAMEMODE.players, ply)

    -- if the round is active tell the server to end the round
    if #GAMEMODE.players == 0 and roundState == 1 then GAMEMODE:endRound() end
end

-- tell the round controller to check if the round should end
hook.Add("PlayerDisconnected", "endRoundCheck", endRoundCheck)
hook.Add("PostPlayerDeath", "endRoundCheck", endRoundCheck)
hook.Add("PlayerInitialSpawn", "endRoundCheck", endRoundCheck)

hook.Add("PlayerSpawn", "startrcsys", function( ply )
    if roundState ~= 3 then return end

    GAMEMODE:preRoundStart()
end)
