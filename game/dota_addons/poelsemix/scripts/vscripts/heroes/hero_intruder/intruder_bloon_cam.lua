intruder_bloon_cam = intruder_bloon_cam or class({})

function intruder_bloon_cam:OnSpellStart()
	if IsServer() then
        
		local caster = self:GetCaster()
		local pos = caster:GetCursorPosition()
        EmitSoundOn("intruder_bloon", caster)
        local unit = CreateUnitByName("unit_recon_ballon", pos, true, caster, caster, caster:GetTeamNumber())
        local dur = self:GetSpecialValueFor("duration")
        if caster:HasTalent("special_bonus_intruder_6") then  dur = dur + caster:FindAbilityByName("special_bonus_intruder_6"):GetSpecialValueFor("value") end
        unit:AddNewModifier(caster, self, "modifier_kill", { duration = dur } )
    end
end