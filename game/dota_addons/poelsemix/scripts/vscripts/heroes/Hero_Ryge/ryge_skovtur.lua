LinkLuaModifier("modifier_ryge_skovtur_buff", "heroes/hero_ryge/ryge_skovtur", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ryge_skovtur_debuff", "heroes/hero_ryge/ryge_skovtur", LUA_MODIFIER_MOTION_NONE)
skovtur = skovtur or class({});



function skovtur:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local dur = self:GetSpecialValueFor("duration")
	caster:EmitSound("SorenSkov")
	if target:GetTeam() == caster:GetTeam() then
		target:AddNewModifier(caster, self, "modifier_ryge_skovtur_buff", {duration = dur})
	else
		target:AddNewModifier(caster, self, "modifier_ryge_skovtur_debuff", {duration = dur})
	end
end


modifier_ryge_skovtur_buff = modifier_ryge_skovtur_buff or class({});


function modifier_ryge_skovtur_buff:IsDebuff() return false end

function modifier_ryge_skovtur_buff:IsPurgable() return false end
function modifier_ryge_skovtur_buff:IsHidden() return false end

function modifier_ryge_skovtur_buff:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_OUT_OF_GAME] = true}
	return state
end
function modifier_ryge_skovtur_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MODEL_CHANGE
	}
end

function modifier_ryge_skovtur_buff:GetModifierModelChange()
	return "models/props_tree/tree_oak_00.vmdl"
end
function modifier_ryge_skovtur_buff:GetModifierHealthRegenPercentage()
	local heal = self:GetAbility():GetSpecialValueFor("hp_regen_sec_perc")
	if self:GetCaster():FindAbilityByName("special_bonus_ryge_3"):GetLevel() > 0 then heal = heal + self:GetCaster():FindAbilityByName("special_bonus_ryge_3"):GetSpecialValueFor("value") end
	return heal
end


modifier_ryge_skovtur_debuff = modifier_ryge_skovtur_debuff or class({});


function modifier_ryge_skovtur_debuff:IsDebuff() return true end

function modifier_ryge_skovtur_debuff:IsPurgable() return true end
function modifier_ryge_skovtur_debuff:IsHidden() return false end

function modifier_ryge_skovtur_debuff:OnCreated()
	self.burns = self:GetCaster():FindAbilityByName("special_bonus_ryge_4"):GetLevel() > 0
	if self.burns then self:StartIntervalThink(0.9) end
end

function modifier_ryge_skovtur_debuff:OnIntervalThink()
	if IsServer() then
		local target = self:GetParent()
		local caster = self:GetCaster()
        --calc damage
        local damage = caster:FindAbilityByName("special_bonus_ryge_4"):GetSpecialValueFor("value")
		ApplyDamage({victim = target,
		attacker = caster,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage = damage,
		ability = self:GetAbility()
		})
		self:StartIntervalThink(1)
	end
end


function modifier_ryge_skovtur_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}
end

function modifier_ryge_skovtur_debuff:GetModifierModelChange()
	return "models/props_tree/tree_oak_00.vmdl"
end

function modifier_ryge_skovtur_debuff:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_OUT_OF_GAME] = true}
	return state
end


function modifier_ryge_skovtur_debuff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ryge_skovtur_debuff:GetEffectName()
	local returns = nil
	if self.burns then returns = "particles/econ/courier/courier_onibi/courier_onibi_yellow_ambient_fire_lvl18.vpcf" end
    return returns
end

