LinkLuaModifier("modifier_vader_choke", "heroes/hero_vader/vader_choke", LUA_MODIFIER_MOTION_NONE)
vader_choke = vader_choke or class({})

function vader_choke:GetChannelTime()
    return self:GetSpecialValueFor("channel_duration")
end

function vader_choke:GetCastRange()
	return self:GetSpecialValueFor("range")
end

function vader_choke:GetCooldown(level)
    local cd = self.BaseClass.GetCooldown(self,level)
    if self:GetCaster():FindAbilityByName("special_bonus_vader_7"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_vader_7"):GetSpecialValueFor("value") end
    return cd
end


function vader_choke:OnSpellStart()
    if IsServer() then
		local caster = self:GetCaster()
        caster:EmitSound("vader_force_choke")
		caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_6)
		self.target = self:GetCursorTarget()

		self.target:AddNewModifier(caster, self, "modifier_vader_choke", {duration = self:GetSpecialValueFor("channel_duration")})
	end
end

function vader_choke:OnChannelFinish(interrupted)
    if  not IsServer() then return end
    self:GetCaster():StopSound("vader_force_choke")
	self:GetCaster():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_6)
	self.target:RemoveModifierByName("modifier_vader_choke")
end


modifier_vader_choke = modifier_vader_choke or class({})


function modifier_vader_choke:IsHidden()		return false end
function modifier_vader_choke:IsPurgable()		return false end
function modifier_vader_choke:IsDebuff()		return true end


function modifier_vader_choke:OnCreated()
	if not IsServer() then return end
	self.tick_rate =  self:GetAbility():GetSpecialValueFor("tick_rate")
	self.damage_sec = self:GetAbility():GetSpecialValueFor("damage_sec")
	self:StartIntervalThink(self.tick_rate)
end

function modifier_vader_choke:OnIntervalThink()
    if not IsServer() then return end
	ApplyDamage({victim = self:GetParent(),
	attacker = self:GetCaster(),
	damage_type = self:GetAbility():GetAbilityDamageType(),
	damage = self.tick_rate *  self.damage_sec,
	ability = self:GetAbility()})
end

function modifier_vader_choke:GetEffectName()
    return "particles/econ/items/vader/force_choke.vpcf"
end

function modifier_vader_choke:DeclareFunctions()
	local decFuncs = {
        MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return decFuncs
end

function modifier_vader_choke:GetModifierIncomingDamage_Percentage(event)
	if IsServer() then
		if event.target == self:GetParent() then
			if self:GetCaster():FindAbilityByName("special_bonus_vader_5"):GetLevel() > 0 then 
			return self:GetCaster():FindAbilityByName("special_bonus_vader_5"):GetSpecialValueFor("value")
			end
		end
	end
end


function modifier_vader_choke:OnDeath(keys)
    if not IsServer() then return end
	if keys.unit ~= self:GetParent() then return end
	if self:GetCaster():HasModifier("modifier_vader_wrath") then
			self:GetCaster():FindModifierByName("modifier_vader_wrath"):AddStacks(self:GetAbility():GetSpecialValueFor("wrath_on_target_death"))
	end
end

function modifier_vader_choke:CheckState()
	local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true
    }
	return state
end


