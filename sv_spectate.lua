-- micro optimizations
local removeValueFromTable = table.RemoveByValue
local getAllPlayers = player.GetAll
local random = math.random
local pairs = pairs
local IsValid = IsValid

-- prep the network message
util.AddNetworkString("Spectate")

--allow us to create a player function
local PlayerMeta = FindMetaTable("Player")

-- when called turn the player into a spectator
function PlayerMeta:spawnAsSpectator(target)
    self.spectating = true

    if not self:Alive() then self:Spawn() end

    if not IsValid(target) then 
        self:Spectate(OBS_MODE_ROAMING)
    else
        self:Spectate(OBS_MODE_CHASE)
        self:SpectateEntity(target)
        self:SetPos(target:GetPos())
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

    if self:getRoundState() ~= 1 then
        ply:spawnAsSpectator()
    end
end

-- when a player dies, make them a spectator
function GM:PostPlayerDeath(ply)
    removeValueFromTable(self.players, ply)
    
    if #self.players then
        ply:spawnAsSpectator(self.players[random(1, #self.players)])
    else
        ply:spawnAsSpectator()
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

    if key == IN_ATTACK then
        ply:spawnAsSpectator(GAMEMODE.players[random(1, #GAMEMODE.players)])
    elseif key == IN_ATTACK2 then
        if ply:GetObserverMode() == OBS_MODE_CHASE then
            ply:spawnAsSpectator()
        else
            ply:spawnAsSpectator(GAMEMODE.players[random(1, #GAMEMODE.players)])
        end
    end
end )