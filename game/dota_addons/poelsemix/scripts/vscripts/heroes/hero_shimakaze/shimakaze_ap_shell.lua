LinkLuaModifier("shimakaze_modifier_ap_shell", "heroes/hero_shimakaze/shimakaze_ap_shell", LUA_MODIFIER_MOTION_NONE)
shimakaze_ap_shell = shimakaze_ap_shell or class({})
function shimakaze_ap_shell:GetCooldown(level)
    local cd = self.BaseClass.GetCooldown(self,level)
    if self:GetCaster():FindAbilityByName("special_bonus_shimakaze_5"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_shimakaze_5"):GetSpecialValueFor("value") end
    return cd
end

function shimakaze_ap_shell:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local particle = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf"
		local speed = self:GetSpecialValueFor("speed")

		local shell = 
			{
				Target = target,
				Source = caster,
				Ability = self,
				EffectName = particle,
				iMoveSpeed = speed,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
				ExtraData = {}
			}
		ProjectileManager:CreateTrackingProjectile(shell)
		self:EmitSound("shimakaze_ap_shell")
		self:EmitSound("Ability.Assassinate")
	end
end

function shimakaze_ap_shell:OnProjectileHit(target)
	if not target then
		return nil
	end

	local duration = self:GetSpecialValueFor("duration") 
    if self:GetCaster():FindAbilityByName("special_bonus_shimakaze_6"):GetLevel() > 0 then duration = duration + self:GetCaster():FindAbilityByName("special_bonus_shimakaze_6"):GetSpecialValueFor("value") end
	target:AddNewModifier(self:GetCaster(), self, "shimakaze_modifier_ap_shell", {duration = duration}) 
end

shimakaze_modifier_ap_shell = shimakaze_modifier_ap_shell or class({})

function shimakaze_modifier_ap_shell:OnCreated()
	local ability = self:GetAbility()

	self.magic_resist = ability:GetSpecialValueFor("magic_resist")
end

function shimakaze_modifier_ap_shell:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
	return decFuncs
end

function shimakaze_modifier_ap_shell:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function shimakaze_modifier_ap_shell:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function shimakaze_modifier_ap_shell:StatusEffectPriority()
	return 10
end
