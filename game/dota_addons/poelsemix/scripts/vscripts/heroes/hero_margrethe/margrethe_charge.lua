margrethe_charge = margrethe_charge or class({})
LinkLuaModifier( "modifier_margrethe_charge", "heroes/hero_margrethe/margrethe_charge", LUA_MODIFIER_MOTION_NONE )

function margrethe_charge:GetCastRange()
    local range = self:GetSpecialValueFor("range")
	if self:GetCaster():FindAbilityByName("special_bonus_margrethe_1"):GetLevel() > 0 then range = range + self:GetCaster():FindAbilityByName("special_bonus_margrethe_1"):GetSpecialValueFor("value") end 
    return range
end


function margrethe_charge:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()
    local ability = self
	local duration = ability:GetSpecialValueFor("charge_max_dur")
    
    for i, unit in pairs(self:GetKnights()) do
        EmitSoundOn("margrethe_charge", unit)
		if unit:HasModifier("modifier_margrethe_charge") then unit:RemoveModifierByName("modifier_margrethe_charge") end
		unit:AddNewModifier(caster, ability, "modifier_margrethe_charge", {duration = duration, target = target:GetEntityIndex()})
    end
end

function margrethe_charge:CastFilterResultTarget(target)
	if IsServer() then
		if #self:GetKnights() >= 1 then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end

function margrethe_charge:GetKnights()
	local knights = {}
	local caster = self:GetCaster()
	local count = 0
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED , FIND_ANY_ORDER, false)
	for i, unit in pairs(units) do
        if unit:GetUnitName() == "npc_queens_knight" then 
			count = count + 1
			knights[count] = unit
		end
    end
	return knights
end

function margrethe_charge:GetCustomCastErrorTarget(hTarget)
	return "NO KNIGHTS ALIVE"
end


modifier_margrethe_charge = modifier_margrethe_charge  or class({})


function modifier_margrethe_charge:IsPurgable() return false end
function modifier_margrethe_charge:IsHidden() return false end

function modifier_margrethe_charge:OnCreated(kv)
	self.ms = self:GetAbility():GetSpecialValueFor("charge_bonus_speed")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.range = self:GetAbility():GetSpecialValueFor("charge_damage_range")
	
	if not IsServer() then return end
	self:GetParent():Stop()
	self:GetParent():StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)
	self.target = EntIndexToHScript( kv.target)
	self:StartIntervalThink(0.1)
	self:GetParent():SetForceAttackTarget(self.target)
end

function modifier_margrethe_charge:OnIntervalThink()
	if not IsServer() then return end
    local parent = self:GetParent()
	if not self.target:IsAlive() then self:Destroy() end

	local dist = FindDistance(self.target:GetAbsOrigin(), parent:GetAbsOrigin())

	if dist <= self.range then
		ApplyDamage({victim = self.target,
		attacker = parent,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		damage = self.damage,
		ability = self:GetAbility()})
		EmitSoundOn("margrethe_charge_thrust", parent)
		local particle_blood = "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg_blood.vpcf"
		local particle_blood_fx = ParticleManager:CreateParticle(particle_blood, PATTACH_ABSORIGIN_FOLLOW, self.target)
		ParticleManager:SetParticleControl(particle_blood_fx, 0, self.target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_blood_fx)

		if self:GetCaster():FindAbilityByName("special_bonus_margrethe_4"):GetLevel() > 0 then 
			self.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_disarmed", {duration = self:GetCaster():FindAbilityByName("special_bonus_margrethe_4"):GetSpecialValueFor("value")})
		end

		self:Destroy()
	end

end

function modifier_margrethe_charge:DeclareFunctions()
	local decFuncs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
}
    return decFuncs
end

function modifier_margrethe_charge:OnRemoved()
	if not IsServer() then return end
	self:GetParent():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_1)
end

function modifier_margrethe_charge:GetModifierMoveSpeedBonus_Constant()
    return self.ms
end


function modifier_margrethe_charge:GetEffectName()
    return "particles/units/heroes/hero_margrethe/margrethe_charge.vpcf"
end