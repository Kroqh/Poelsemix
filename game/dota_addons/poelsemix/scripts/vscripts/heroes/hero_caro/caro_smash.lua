LinkLuaModifier("modifier_caro_smash", "heroes/hero_caro/caro_smash", LUA_MODIFIER_MOTION_NONE)

caro_smash = caro_smash or class({})

function caro_smash:OnToggle()
	if not IsServer() then return end

	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_caro_smash", {} )
	else
		self:GetCaster():RemoveModifierByNameAndCaster("modifier_caro_smash", self:GetCaster())
	end
end


modifier_caro_smash = modifier_caro_smash or class({})


function modifier_caro_smash:IsHidden() 				return true end
function modifier_caro_smash:IsPurgable() 			return false end

function modifier_caro_smash:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS
	}
end


function modifier_caro_smash:GetModifierAttackRangeBonus()
    local caster = self:GetCaster()
    local range = self:GetAbility():GetSpecialValueFor("bonus_range")
    if caster:FindAbilityByName("special_bonus_caro_1"):GetLevel() > 0 then range = range + caster:FindAbilityByName("special_bonus_caro_1"):GetSpecialValueFor("value") end
	return range
end

function modifier_caro_smash:GetModifierBaseAttack_BonusDamage()
    
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end
function modifier_caro_smash:GetModifierProjectileName()
	return "particles/heroes/caroline/smash_ball.vpcf"
end
function modifier_caro_smash:GetModifierProjectileSpeedBonus()
	return self:GetAbility():GetSpecialValueFor("projectile_speed_bonus")
end

function modifier_caro_smash:OnAttackLanded(params)
	if (params.attacker ~= self:GetParent()) then return end 
    if not IsServer() then return end
    caster = self:GetCaster()
    local roll = math.random(100)
    EmitSoundOn("carohit", params.target)
    local bash_chance = self:GetAbility():GetSpecialValueFor("stun_chance")
    if caster:HasTalent("special_bonus_caro_6") then bash_chance = bash_chance + caster:FindAbilityByName("special_bonus_caro_6"):GetSpecialValueFor("value") end
    if bash_chance >= roll then
        params.target:AddNewModifier(caster, self, "modifier_stunned", { duration = self:GetAbility():GetSpecialValueFor("stun_duration") } )
	end
end

function modifier_caro_smash:OnAttackStart(params)
	if (params.attacker ~= self:GetParent()) then return end 
    if not IsServer() then return end
    local caster = self:GetCaster()
	local ability = self:GetAbility()

    local mana_cost =ability:GetSpecialValueFor("mana_cost")
    if caster:HasTalent("special_bonus_caro_5") then mana_cost = mana_cost + caster:FindAbilityByName("special_bonus_caro_5"):GetSpecialValueFor("value") end
	local mana_after = caster:GetMana() - mana_cost

	if mana_after <= 0 then
		caster:SetMana(0)
        ability:ToggleAbility()
    elseif mana_after < 0 then
        ability:ToggleAbility()
        return
    else
		caster:SetMana(mana_after)
	end
	
end