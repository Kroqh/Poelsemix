item_brunsviger = item_brunsviger or class({})

LinkLuaModifier("modifier_item_brunsviger", "items/item_brunsviger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_brunsviger_burn", "items/item_brunsviger", LUA_MODIFIER_MOTION_NONE)


function item_brunsviger:GetIntrinsicModifierName()
	return "modifier_item_brunsviger"
end

modifier_item_brunsviger = modifier_item_brunsviger or class({})

function modifier_item_brunsviger:IsHidden()		return true end
function modifier_item_brunsviger:IsPurgable()		return false end
function modifier_item_brunsviger:RemoveOnDeath()	return false end
function modifier_item_brunsviger:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end



function modifier_item_brunsviger:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, 
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_item_brunsviger:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("int")
    end
end
function modifier_item_brunsviger:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("mana")
    end
end

function modifier_item_brunsviger:GetModifierSpellAmplify_Percentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("spell_amp")
    end
end
function modifier_item_brunsviger:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("mana_regen")
    end
end
function modifier_item_brunsviger:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("hp")
    end
end





function modifier_item_brunsviger:OnTakeDamage(params)
	if (params.attacker ~= self:GetParent()) then return end 
	if not IsServer() then return end
	if params.inflictor == nil then return end
	if params.attacker:IsIllusion() then return end --for edge cases like unstable on raio afterimages
	if not params.attacker:HasAbility(params.inflictor:GetAbilityName()) then return end --very elegant way of checking if its an actual ability lol, suppose it would not work if a character with weird spell swapping is added?

	local duration = self:GetAbility():GetSpecialValueFor("burn_duration")

	local mod = params.unit:FindModifierByNameAndCaster("modifier_item_brunsviger_burn",self:GetParent())
	if mod == nil then
		params.unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_brunsviger_burn", {duration = duration})
	else
		mod:SetDuration(duration, true)
	end
end
	
modifier_item_brunsviger_burn = modifier_item_brunsviger_burn or class({})

function modifier_item_brunsviger_burn:IsHidden()		return false end
function modifier_item_brunsviger_burn:IsPurgable()		return true end
function modifier_item_brunsviger_burn:IsDebuff()	return true end
function modifier_item_brunsviger_burn:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_brunsviger_burn:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.9)
end

function modifier_item_brunsviger_burn:OnIntervalThink()
	if not IsServer() then return end

	local damage = self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("max_hp_dmg_pct")/100)
	damage = damage + self:GetAbility():GetSpecialValueFor("base_burn_damage")
	
	local damageTable = {
		victim = self:GetParent(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		attacker = self:GetCaster(),
		ability = self:GetAbility()
	}
	ApplyDamage(damageTable)

	self:StartIntervalThink(1)
end

function modifier_item_brunsviger_burn:GetEffectName()
	return "particles/econ/items/brunsviger.vpcf"
end

function modifier_item_brunsviger_burn:GetTexture()
	return "brunsviger"
end