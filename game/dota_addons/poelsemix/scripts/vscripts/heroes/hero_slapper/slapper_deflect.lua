LinkLuaModifier("modifier_slapper_deflect_passive", "heroes/hero_slapper/slapper_deflect", LUA_MODIFIER_MOTION_NONE)
slapper_deflect = slapper_deflect or class({})


function slapper_deflect:GetIntrinsicModifierName()
	return "modifier_slapper_deflect_passive"
end


function slapper_deflect:OnProjectileHit(target)
	if not target then
		return nil 
	end
	local caster = self:GetCaster()
	local int_scaling = self:GetSpecialValueFor("int_damage")
	local base_damage = self:GetSpecialValueFor("damage")
	local damage = base_damage + (int_scaling * caster:GetIntellect(true))
	ApplyDamage({victim = target,
	attacker = caster,
	damage_type = self:GetAbilityDamageType(),
	damage = damage,
	ability = self})
end

modifier_slapper_deflect_passive = modifier_slapper_deflect_passive or class({})

function modifier_slapper_deflect_passive:IsPurgeable() return false end
function modifier_slapper_deflect_passive:IsHidden() return false end
function modifier_slapper_deflect_passive:IsPassive() return true end

function modifier_slapper_deflect_passive:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local lol = 0

		if lol == 0 then
			local caster = self:GetCaster()
			self:SetStackCount(1)
			lol = 1
		end

		local interval =ability:GetSpecialValueFor("interval")
		if self:GetCaster():FindAbilityByName("special_bonus_slapper_8"):GetLevel() > 0 then interval = interval + self:GetCaster():FindAbilityByName("special_bonus_slapper_8"):GetSpecialValueFor("value") end 
		self:StartIntervalThink(interval)
	end
end

function modifier_slapper_deflect_passive:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()

		local max_stacks = ability:GetSpecialValueFor("max_charges")
		if self:GetCaster():FindAbilityByName("special_bonus_slapper_2"):GetLevel() > 0 then max_stacks = max_stacks + self:GetCaster():FindAbilityByName("special_bonus_slapper_2"):GetSpecialValueFor("value") end 

		if self:GetStackCount() < max_stacks then
			self:SetStackCount(self:GetStackCount() + 1)
		end
		local interval =ability:GetSpecialValueFor("interval")
		if self:GetCaster():FindAbilityByName("special_bonus_slapper_8"):GetLevel() > 0 then interval = interval + self:GetCaster():FindAbilityByName("special_bonus_slapper_8"):GetSpecialValueFor("value") end 
		self:StartIntervalThink(interval)
	end
end


function modifier_slapper_deflect_passive:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
	return decFuncs
end


function modifier_slapper_deflect_passive:OnAttackLanded( keys )
	local parent = self:GetParent()
	if keys.target == parent and IsServer() then
		local stacks =self:GetStackCount()
		if stacks == 0 then return end
		self:SetStackCount(stacks-1)
		parent:StartGesture(ACT_DOTA_CAST_ABILITY_2)
		parent:EmitSound("slapper_deflect")
		local shot = 
			{
				Target = keys.attacker,
				Source = parent,
				Ability = self:GetAbility(),
				EffectName = "particles/units/heroes/hero_slapperl/slapper_deflect.vpcf",
				iMoveSpeed = self:GetAbility():GetSpecialValueFor("proj_speed"),
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
				ExtraData = {}
			}
		ProjectileManager:CreateTrackingProjectile(shot)
	end
end

