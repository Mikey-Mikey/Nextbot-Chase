-- micro optimizations
local removeValueFromTable = table.RemoveByValue
local getAllPlayers = player.GetAll
local random = math.random
local pairs = pairs
local IsValid = IsValid
local inTable = table.HasValue
-- prep the network message
util.AddNetworkString("Spectate")

--allow us to create a player function
local PlayerMeta = FindMetaTable("Player")

-- when called turn the player into a spectator
function PlayerMeta:spawnAsSpectator(target)
    self.spectating = true

    if not self:Alive() then self:Spawn() end

    if IsValid(target) then 
        self:Spectate(OBS_MODE_CHASE)
        self:SpectateEntity(target)
        self:SetPos(target:GetPos())
    else
        self:Spectate(OBS_MODE_ROAMING)
    end
end
local function bool2int(bool)
    return bool and 1 or 0;
end

-- when a player spawns as a spectator make sure their client knows they are a spectator
function GM:PlayerSpawn(ply) 
    if not ply.spectating then return end

    net.Start("Spectate")
    net.WriteBool(true)
    net.Send(ply)
end

function GM:PlayerInitialSpawn(ply)
    if #GAMEMODE.players > 1 then
        ply.spectating = true
        local randomPly = GAMEMODE.players[random(1, #GAMEMODE.players)]
        timer.Simple(0,function()
            ply:spawnAsSpectator(randomPly)
        end)

    else
        ply.spectating = false
    end
end

-- when a player dies, make them a spectator
local dead_early = {}
function GM:PostPlayerDeath(victim)
    if not timer.Exists("Spawn Protection") then
        removeValueFromTable(self.players, victim)
        victim.spectating = true
        for _,ply in pairs(getAllPlayers()) do
            if ply:GetObserverTarget() == victim then
                timer.Simple(1.0,function()
                    ply:spawnAsSpectator(self.players[random(1, #self.players)])
                end)
            end
        end
        if #self.players > 0 then
            victim:spawnAsSpectator(self.players[random(1, #self.players)])
        else
            victim:spawnAsSpectator()
        end
    else
        if #dead_early < 1 then
            timer.Simple(6.0,function()
                for _,ply in ipairs(dead_early) do
                    if not ply:Alive() then
                        removeValueFromTable(self.players, ply)
                        randomPly = GAMEMODE.players[random(1, #GAMEMODE.players)]
                        ply:spawnAsSpectator(randomPly)
                    end
                end
                dead_early = {}
            end)
        end
        dead_early[#dead_early + 1] = victim
        victim:PrintMessage(HUD_PRINTCENTER,"You died early, click to respawn!")
    end
end 

-- before the round starts reset spectate value
hook.Add("PreRoundStart", "spectate", function(round)
    timer.Create("Spawn Protection", 1.0, 1, function() end)
    for _,ply in pairs(getAllPlayers()) do
        ply.spectating = false
    end
end )

-- when the round ends set everyone to spectators 
hook.Add("RoundEnd", "spectate", function(round)
    for _,ply in pairs(getAllPlayers()) do
        if not IsValid(ply) then return end

        ply:KillSilent()
        ply:spawnAsSpectator()
    end
end )

-- let the user change spectate modes and players
hook.Add("KeyPress", "Spectate", function(ply, key)
    if not ply.spectating then return end
    if key == IN_ATTACK or key == IN_ATTACK2 then
        local dir = bool2int(key == IN_ATTACK) - bool2int(key == IN_ATTACK2)
        if #getAllPlayers() > 1 then
            local spect = ply:GetObserverTarget()
            local targetPly
            for k,target in ipairs(GAMEMODE.players) do -- spectate the next player in the list
                if target == spect then
                    targetPly = GAMEMODE.players[((k + dir) % #GAMEMODE.players) + 1]
                end
            end
            if targetPly:IsValid() then
                ply:spawnAsSpectator(targetPly)
            else
                error("Invalid target spectate player")
            end
        end
    end
end )

-- hook to config auto unstuck
hook.Add("AU.CanHandlePlayer", "player_stuck",function(ply)
    return ply:GetObserverMode() == OBS_MODE_NONE
end)

hook.Add( "CanPlayerSuicide", "players", function( ply )
    return ply:GetObserverMode() == OBS_MODE_NONE
end )

hook.Add("PlayerUse", "players", function(ply,ent)
    return ply:GetObserverMode() == OBS_MODE_NONE
end)