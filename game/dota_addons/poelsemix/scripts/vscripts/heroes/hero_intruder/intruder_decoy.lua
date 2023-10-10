intruder_decoy = intruder_decoy or class({})
LinkLuaModifier("modifier_intruder_stealth", "heroes/hero_intruder/modifier_intruder_stealth", LUA_MODIFIER_MOTION_NONE)

function intruder_decoy:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
	local dur = self:GetSpecialValueFor("invis_dur")
	if caster:HasTalent("special_bonus_intruder_8") then dur = dur + caster:FindAbilityByName("special_bonus_intruder_8"):GetSpecialValueFor("value") end
    caster:AddNewModifier(caster, ability, "modifier_intruder_stealth", {duration = dur})
	local outgoing = self:GetSpecialValueFor("clone_outgoing")
	if caster:HasTalent("special_bonus_intruder_7") then outgoing = outgoing + caster:FindAbilityByName("special_bonus_intruder_7"):GetSpecialValueFor("value") end

	local illusions = CreateIllusions(caster, caster, {
		outgoing_damage = outgoing,
		incoming_damage	= 0,
		bounty_base		= 0,
		bounty_growth	= nil,
		outgoing_damage_structure	= nil,
		outgoing_damage_roshan		= nil,
		duration		= self:GetSpecialValueFor("clone_dur")

	}, 1, 0, false, true)

	for _, illusion in pairs(illusions) do
		illusion:SetControllableByPlayer(-1, true) -- uncontrollable
	end
end