net.Receive("round_state", function()
    hook.Run(net.ReadString(), net.ReadInt())
end)