-- internal spectating value
local isSpectating = false

-- micro optimizations
local runHook = hook.Run

-- listen to the server when it tells us if we are a spectator or not
net.Receive("spectate", function()
    isSpectating = net.ReadBool()
    runHook("spectate", isSpectating)
end)