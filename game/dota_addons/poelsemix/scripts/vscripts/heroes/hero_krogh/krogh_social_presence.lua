LinkLuaModifier("modifier_krogh_social_presence","heroes/hero_krogh/krogh_social_presence.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_krogh_social_presence_debuff","heroes/hero_krogh/krogh_social_presence.lua",LUA_MODIFIER_MOTION_NONE)

social_presence = social_presence or class({})

function social_presence:OnSpellStart()
	if not IsServer() then return end

    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
    caster:AddNewModifier(caster, self, "modifier_krogh_social_presence", {})
end
function social_presence:OnProjectileHit(target)
	if not target then
		return nil 
	end

	local caster = self:GetCaster()

	local damage = self:GetSpecialValueFor("bonus_damage")
    local duration = self:GetSpecialValueFor("armor_reduction_duration")
    if caster:FindAbilityByName("special_bonus_krogh_6"):GetLevel() > 0 then duration = duration + caster:FindAbilityByName("special_bonus_krogh_6"):GetSpecialValueFor("value") end

	ApplyDamage({victim = target,
	attacker = caster,
	damage_type = self:GetAbilityDamageType(),
	damage = damage,
	ability = self})
	
	target:AddNewModifier(caster, self, "modifier_krogh_social_presence_debuff", {duration = duration})
end


modifier_krogh_social_presence = modifier_krogh_social_presence or class({})

function modifier_krogh_social_presence:OnCreated()
    local caster = self:GetCaster()
    self.range = self:GetAbility():GetSpecialValueFor("bonus_range")
    if caster:FindAbilityByName("special_bonus_krogh_7"):GetLevel() > 0 then self.range = self.range + caster:FindAbilityByName("special_bonus_krogh_7"):GetSpecialValueFor("value") end
    
    
end

function modifier_krogh_social_presence:OnRemoved()
    if not IsServer() then return end
    self:GetParent():FadeGesture(ACT_DOTA_CAST_ABILITY_2)
end

function modifier_krogh_social_presence:IsDebuff()return false end
function modifier_krogh_social_presence:IsPurgable() return false end
function modifier_krogh_social_presence:IsHidden() return false end

function modifier_krogh_social_presence:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_UNIT_MOVED, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}
end

function modifier_krogh_social_presence:GetModifierAttackRangeBonus()
    return self.range
end

function modifier_krogh_social_presence:OnUnitMoved(keys)
    if IsServer() then
		local parent = self:GetParent()

		if keys.unit == parent then
			self:Destroy()
		end
	end
end
function modifier_krogh_social_presence:OnAbilityExecuted(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.unit == parent then
			self:Destroy()
		end
	end
end

function modifier_krogh_social_presence:OnAttackStart(keys)
	if IsServer() then
		local parent = self:GetParent()
        
		if keys.attacker == parent then
            EmitSoundOn("krogh_upsie", parent)
            parent:StartGesture(ACT_DOTA_CAST_ABILITY_2_END)
            local proj = 
			{
				Target = keys.target,
				Source = parent,
				Ability = self:GetAbility(),
				EffectName = "particles/units/heroes/hero_krogh/krogh_social_presence.vpcf",
				iMoveSpeed =  800,
				bDodgeable = false,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				ExtraData = {}
			}
		ProjectileManager:CreateTrackingProjectile(proj)
			self:Destroy()
		end
	end
end


function modifier_krogh_social_presence:GetModifierInvisibilityLevel()
	if IsClient() then
		return 1
	end
end

function modifier_krogh_social_presence:CheckState()
	if IsServer() then
		local state = {[MODIFIER_STATE_INVISIBLE] = true}
		return state
	end
end



modifier_krogh_social_presence_debuff = modifier_krogh_social_presence_debuff or class({})
function modifier_krogh_social_presence_debuff:IsHidden() return false end
function modifier_krogh_social_presence_debuff:IsDebuff() return true end
function modifier_krogh_social_presence_debuff:IsPurgable() return true end

function modifier_krogh_social_presence_debuff:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_krogh_social_presence_debuff:OnCreated(keys)
    self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction")
    self.silence = (self:GetCaster():FindAbilityByName("special_bonus_krogh_8"):GetLevel() > 0)
end

function modifier_krogh_social_presence_debuff:GetModifierPhysicalArmorBonus()
	return self.armor_reduction
end
function modifier_krogh_social_presence_debuff:CheckState()
	local state = {[MODIFIER_STATE_SILENCED] = self.silence}
	return state
end