LinkLuaModifier("modifier_gunpowder", "heroes/hero_baseboys/hero_baseboys", LUA_MODIFIER_MOTION_NONE)
gunpowder_datadriven = class({})

function gunpowder_datadriven:GetAbilityTextureName()
	return "gunpowder"
end

function gunpowder_datadriven:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		local particle = "particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf"
		local agility = self:GetSpecialValueFor("bonus_agility")

		caster:AddNewModifier(caster, self, "modifier_gunpowder", {duration = duration, agility = agility})
		
		local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
		self:EmitSound("gratisgunpowder")
		self:EmitSound("Hero_Sven.GodsStrength")
	end
end

modifier_gunpowder = class({})

function modifier_gunpowder:OnCreated(keys)
	local ability = self:GetAbility()
	local scale = ability:GetSpecialValueFor("model_scale")
	local caster = self:GetCaster()
	self.bonus_agility = keys.agility
	--Passing movespeed through AddNewModifier doesn't show on the HUD
	--so we define it here.
	self.bonus_speed = ability:GetSpecialValueFor("bonus_speed")
	if IsServer() then
		self.orig_size = caster:GetModelScale()
		caster:SetModelScale(scale)
	end
end

function modifier_gunpowder:IsPurgeable() return false end
function modifier_gunpowder:IsBuff() return true end

function modifier_gunpowder:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE}
	return decFuncs
end

function modifier_gunpowder:GetModifierBonusStats_Agility()
	return self.bonus_agility
end

function modifier_gunpowder:GetModifierMoveSpeed_Absolute()
	return self.bonus_speed
end

function modifier_gunpowder:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function modifier_gunpowder:StatusEffectPriority()
	return 10
end

function modifier_gunpowder:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		caster:SetModelScale(self.orig_size)
	end
end

LinkLuaModifier("modifier_choke", "heroes/hero_baseboys/hero_baseboys", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_choke_stun", "heroes/hero_baseboys/hero_baseboys", LUA_MODIFIER_MOTION_NONE)
choke_datadriven = class({})

function choke_datadriven:GetAbilityTextureName()
	return "hej_mathilde"
end

function choke_datadriven:GetIntrinsicModifierName()
	return "modifier_choke"
end

modifier_choke = class({})

function modifier_choke:IsHidden() return true end

function modifier_choke:DeclareFunctions()
	local decFuncs = 
	{MODIFIER_EVENT_ON_ATTACKED}
	return decFuncs
end

function modifier_choke:OnAttacked(keys)
	if IsServer() then

		if keys.target == self:GetParent() then

			local ability = self:GetAbility()
			local chance = ability:GetSpecialValueFor("chance") 
			local duration = ability:GetSpecialValueFor("duration")
			local caster = self:GetParent()

			if caster:PassivesDisabled() or caster:IsHexed() then
				return nil
			end

			if RollPseudoRandom(chance, self) then

				keys.attacker:AddNewModifier(caster, ability, "modifier_choke_stun", {duration = duration})
				ability:EmitSound("hej_mathilde")
			end
		end
	end
end

modifier_choke_stun = class({})

function modifier_choke_stun:IsPurgeable() return false end
function modifier_choke_stun:IsHidden() return false end

function modifier_choke_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"

end

function modifier_choke_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_choke_stun:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end