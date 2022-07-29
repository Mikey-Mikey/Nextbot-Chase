local isSpectating = false

-- listen to the server when it tells us if we are a spectator or not
net.Receive("spectate", function()
    isSpectating = net.ReadBool()
end)




-- currently unused