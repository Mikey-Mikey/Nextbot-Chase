local preRoundTime = 1
local roundTime = 420
local afterRoundTime = 1

local round = 0
local roundState = 2

local Color = Color

util.AddNetworkString("round_state")

local function preRoundStart()
    roundState = 0
    round = round + 1

    net.Start("round_state")
    net.WriteString("preRoundStart")
    net.WriteInt(round)
    net.Broadcast()
    
    hook.Run("PreRoundStart", round)

    timer.Create("preRoundStart", preRoundTime, 1, function()
        startRound()
    end)
end

local function startRound()
    roundState = 1
    MsgC(Color(255, 255, 255), "[", Color(30, 255, 0), "Nextbot Chase", Color(255, 255, 255), "] Starting Round  " .. round .. "\n")

    net.Start("round_state")
    net.WriteString("startRound")
    net.WriteInt(round)
    net.Broadcast()

    hook.Run("RoundStart", round)

    timer.Create("endRoundTime", roundTime, 1, function()
        endRound()
    end)
end

local function endRound()
    roundState = 2
    MsgC(Color(255, 255, 255), "[", Color(30, 255, 0), "Nextbot Chase", Color(255, 255, 255), "] Ending Round " .. round .. "\n")

    net.Start("round_state")
    net.WriteString("endRound")
    net.WriteInt(round)
    net.Broadcast()

    hook.Run("RoundEnd", round)

    timer.Create("preRoundStart", afterRoundTime, 1, function()
        preRoundStart()
    end)
end

local function endRoundCheck()
    if not #GAMEMODE.players and roundState == 1 then endRound() end
end