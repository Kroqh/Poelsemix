LinkLuaModifier("modifier_hindbersnitte", "heroes/hero_ryge/ryge_hindbersnitte", LUA_MODIFIER_MOTION_NONE)


hindbersnitte = hindbersnitte or class({})

function hindbersnitte:GetIntrinsicModifierName()
	return "modifier_hindbersnitte"
end

modifier_hindbersnitte = modifier_hindbersnitte or class({})

function modifier_hindbersnitte:IsPassive() return true end
function modifier_hindbersnitte:IsHidden() return false end
function modifier_hindbersnitte:IsPurgable() return false end

function modifier_hindbersnitte:OnCreated()
	if not IsServer() then return end
    self:SetStackCount(0)

end

function modifier_hindbersnitte:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_EVENT_ON_ATTACK_START
	}

	return funcs
end


function modifier_hindbersnitte:OnAttackStart(keys)
    if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local chance = ability:GetSpecialValueFor("chance")
	local roll = RandomInt(1,100)
	if roll <= chance then
		parent:EmitSound("SorenPassiveTrigger")
		self:SetStackCount(self:GetStackCount()+1)
		parent:Heal(ability:GetSpecialValueFor("heal_amount"),ability)
		local particle_self = "particles/units/heroes/hero_omniknight/omniknight_shard_hammer_of_purity_heal_pluses.vpcf"
    	local pfx_fire = ParticleManager:CreateParticle(particle_self, PATTACH_POINT_FOLLOW, parent)
    	ParticleManager:SetParticleControlEnt(pfx_fire, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), false)
	end
    
end
function modifier_hindbersnitte:GetModifierBonusStats_Agility()
	return self:GetStackCount()
end