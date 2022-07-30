-- micro optimizations
local runHook = hook.Run

-- let the client know that the round has started / ended / etc with info from the server
net.Receive("round_state", function()
    runHook(net.ReadString(), net.ReadInt())
end)