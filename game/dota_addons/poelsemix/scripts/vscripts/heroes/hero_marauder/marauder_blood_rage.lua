LinkLuaModifier("modifier_marauder_blood_rage", "heroes/hero_marauder/marauder_blood_rage", LUA_MODIFIER_MOTION_NONE)
marauder_blood_rage = marauder_blood_rage or class({})


function marauder_blood_rage:OnSpellStart() 
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	caster:EmitSound("marauder_blood_rage")
	self:ApplyRage(caster, duration)
end

function marauder_blood_rage:ApplyRage(unit, duration)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local damage_percent = self:GetSpecialValueFor("self_damage_percent") / 100
	
	if unit:HasModifier("marauder_blood_rage") then unit:RemoveModifierByName("marauder_blood_rage") end --for proper strength refresh, makes str gain static while everything else is dynamic but w/e
	unit:AddNewModifier(caster, self, "modifier_marauder_blood_rage", {duration = duration})
	ApplyDamage({
		victim = unit,
		attacker = caster,
		damage = unit:GetHealth() * damage_percent,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self,
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS
	})
end

function marauder_blood_rage:GetIncreaser()
	return self.percent_increaser / 100
end
function marauder_blood_rage:GetIncreaserFull()
	return self.percent_increaser
end



modifier_marauder_blood_rage = modifier_marauder_blood_rage or class({})

function modifier_marauder_blood_rage:IsPurgable() return	true end
function modifier_marauder_blood_rage:IsDebuff() return	false end

function modifier_marauder_blood_rage:OnCreated()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	ability.percent_increaser = ability:GetSpecialValueFor("percent_increaser")
	
	self.str = 0
	self.str = self:GetParent():GetStrength() * self:GetAbility():GetIncreaser()
end

function modifier_marauder_blood_rage:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_MODEL_SCALE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
	return funcs
end



function modifier_marauder_blood_rage:GetModifierBonusStats_Strength()
	return self.str
end
function modifier_marauder_blood_rage:GetModifierModelScale()
	return self:GetAbility():GetIncreaserFull()
end
function modifier_marauder_blood_rage:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetIncreaserFull()
end


function modifier_marauder_blood_rage:GetEffectName()
	return "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_eztzhok.vpcf"
end

function modifier_marauder_blood_rage:GetStatusEffectName()
	return "particles/econ/items/lifestealer/ls_ti9_immortal/status_effect_ls_ti9_open_wounds.vpcf"
end
function modifier_marauder_blood_rage:StatusEffectPriority()
	return 10
end