local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:spawnAsSpectator(target)
    self:StripWeapons()

    if not IsValid(target) then 
        self:Spectate(OBS_MODE_ROAMING)
    else
        self:Spectate(OBS_MODE_CHASE)
        self:SpectateEntity(target)
        self:SetPos(target:GetPos())
    end
end