-- let the client know that the round has started / ended / etc with info from the server
net.Receive("round_state", function()
    hook.Run(net.ReadString(), net.ReadInt())
end)