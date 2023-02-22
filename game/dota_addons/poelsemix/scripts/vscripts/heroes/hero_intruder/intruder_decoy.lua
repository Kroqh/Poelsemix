intruder_decoy = intruder_decoy or class({})
LinkLuaModifier("modifier_intruder_stealth", "heroes/hero_intruder/modifier_intruder_stealth", LUA_MODIFIER_MOTION_NONE)

function intruder_decoy:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, ability, "modifier_intruder_stealth", {duration = self:GetSpecialValueFor("invis_dur")})

	local illusions = CreateIllusions(caster, caster, {
		outgoing_damage = self:GetSpecialValueFor("clone_outgoing"),
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