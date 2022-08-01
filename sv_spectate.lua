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

-- when a player spawns as a spectator make sure their client knows they are a spectator
function GM:PlayerSpawn(ply) 
    if not ply.spectating then return end

    net.Start("Spectate")
    net.WriteBool(true)
    net.Send(ply)
end

function GM:PlayerInitialSpawn(ply)
    ply.spectating = false

    ply:spawnAsSpectator()
end

-- when a player dies, make them a spectator
function GM:PostPlayerDeath(victim)
    removeValueFromTable(self.players, victim)
    for _,ply in pairs(getAllPlayers()) do
        if ply:GetObserverTarget() == victim then
            timer.Simple(1.0,function()
                ply:spawnAsSpectator(self.players[random(1, #self.players)])
            end)
        end
    end
    if #self.players then
        victim:spawnAsSpectator(self.players[random(1, #self.players)])
    else
        victim:spawnAsSpectator()
    end
end 

-- before the round starts reset spectate value
hook.Add("PreRoundStart", "spectate", function(round)
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

    local randomPly

    if key == IN_ATTACK or key == IN_ATTACK2 then
        randomPly = GAMEMODE.players[random(1, #GAMEMODE.players)]

        while ply:GetObserverTarget() == randomPly and #GAMEMODE.players > 1 and inTable(GAMEMODE.players, ply:GetObserverTarget()) and #player.GetAll() > 0 do
            randomPly = GAMEMODE.players[random(1, #GAMEMODE.players)]
        end
    end

    if key == IN_ATTACK then
        ply:spawnAsSpectator(randomPly)
    elseif key == IN_ATTACK2 then
        if ply:GetObserverMode() == OBS_MODE_CHASE then
            ply:spawnAsSpectator()
        else
            ply:spawnAsSpectator(randomPly)
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

    if ply:GetObserverMode() ~= OBS_MODE_NONE and ply.cooldown ~= true then
        ply.cooldown = true
        if ply.cooldown == false and ent:IsValid() then
            timer.Create(tostring(ply) .. "cooldown", 5.0, 1, function()
                ply.cooldown = false
            end)
        end
        return ent:GetClass() ~= "prop_door_rotating"
    end
    return ply:GetObserverMode() == OBS_MODE_NONE
end)