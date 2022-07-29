-- round controller config
local preRoundTime = 1
local roundTime = 420
local afterRoundTime = 1

-- round controller internal variables
local round = 0
local roundState = 2

-- micro optimizations
local Color = Color

-- prep the network message
util.AddNetworkString("round_state")

-- prep the server for the next round
local function GM:preRoundStart()
    -- increace the round counter
    roundState = 0
    round = round + 1

    -- let the client know that the round is about to start
    net.Start("round_state")
    net.WriteString("preRoundStart")
    net.WriteInt(round)
    net.Broadcast()

    -- clean up the map with the vars from gmod issue #3637
    game.CleanUpMap( false, { "env_fire", "entityflame", "_firesmoke" } )
    
    -- let the server know that the round is preparing to start
    hook.Run("PreRoundStart", round)

    -- wait for the round to start
    timer.Create("preRoundStart", preRoundTime, 1, function()
        self:startRound()
    end)
end

-- start the round
local function GM:startRound()
    -- set the internal round state to 1
    roundState = 1
    MsgC(Color(255, 255, 255), "[", Color(30, 255, 0), "Nextbot Chase", Color(255, 255, 255), "] Starting Round  " .. round .. "\n")

    -- let the client know that the round is starting
    net.Start("round_state")
    net.WriteString("startRound")
    net.WriteInt(round)
    net.Broadcast()

    -- let the server know that the round is starting
    hook.Run("RoundStart", round)

    -- wait for the round to end
    timer.Create("endRoundTime", roundTime, 1, function()
        self:endRound()
    end)
end

-- end the round
local function GM:endRound()
    -- set the internal round state to 2
    roundState = 2
    MsgC(Color(255, 255, 255), "[", Color(30, 255, 0), "Nextbot Chase", Color(255, 255, 255), "] Ending Round " .. round .. "\n")

    -- let the client know that the round is ending
    net.Start("round_state")
    net.WriteString("endRound")
    net.WriteInt(round)
    net.Broadcast()

    -- let the server know that the round is ending
    hook.Run("RoundEnd", round)

    -- wait for the next round to prepare
    timer.Create("preRoundStart", afterRoundTime, 1, function()
        self:preRoundStart()
    end)
end

-- check if the round should end
local function GM:endRoundCheck(ply)
    -- if a player is not alive / leaves / spawns after the round has started then remove them from the global player table 
    table.RemoveByValue(self.players, ply)

    -- if the round is active tell the server to end the round
    if not #self.players and roundState == 1 then endRound() end
end

-- tell the round controller to check if the round should end
hook.Add("PlayerDisconnected", "endRoundCheck", endRoundCheck)
hook.Add("PostPlayerDeath", "endRoundCheck", endRoundCheck)
hook.Add("PlayerInitialSpawn", "endRoundCheck", endRoundCheck)