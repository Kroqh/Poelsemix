LinkLuaModifier("modifier_raio_heavenly_decree_mark", "heroes/hero_raio/raio_heavenly_decree", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_raio_heavenly_decree_scepter", "heroes/hero_raio/raio_heavenly_decree", LUA_MODIFIER_MOTION_NONE)

raio_heavenly_decree = raio_heavenly_decree or class({})

function raio_heavenly_decree:OnAbilityPhaseStart()
	
	self:GetCaster():EmitSound("raio_heavenly_cast")
	
	return true
end


function raio_heavenly_decree:GetCooldown(level)

	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_cd")
	else
		return self.BaseClass.GetCooldown(self,level)
	end
end

function raio_heavenly_decree:GetManaCost( level )
	if self:GetCaster():HasScepter() then
		return 0
	end

	return self.BaseClass.GetManaCost(self, level)
end

function raio_heavenly_decree:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end

	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE --Have to hard code, cant use getbehaviour as it will cause stack overflow
end

function raio_heavenly_decree:GetIntrinsicModifierName()
	return "modifier_raio_heavenly_decree_scepter"
end

function raio_heavenly_decree:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function raio_heavenly_decree:GetCastRange()
	return self:GetSpecialValueFor("range")
end

function raio_heavenly_decree:OnSpellStart()
	if IsServer() then
		local caster 		= self:GetCaster()
		local target_point 	= self:GetCursorPosition()
		self:GetCaster():EmitSound("Hero_Zuus.LightningBolt.Cast")
		local delay = self:GetSpecialValueFor("delay")
		local marks = self:GetSpecialValueFor("voltage_marks")  
		CreateModifierThinker(caster, self, "modifier_raio_heavenly_decree_mark", {duration = delay, target_point_x = target_point.x, target_point_y = target_point.y, target_point_z = target_point.z, first_strike = true, marks = marks}, target_point, caster:GetTeamNumber(), false)
	end
end

function raio_heavenly_decree:CastLightningBolt(caster, ability, target_point, first_strike, marks)
	if IsServer() then
		local radius			= ability:GetSpecialValueFor("radius")
		EmitSoundOnLocationWithCaster(target_point, "raio_heavenly_decree", caster)
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(), 
			target_point, 
			nil, 
			radius, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			ability:GetAbilityTargetFlags(), 
			FIND_ANY_ORDER, 
			false
		)
	local particle = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_immortal_lightning.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, target_point + Vector(0, 0, 5000))
	ParticleManager:SetParticleControl(particle, 1, target_point)
    ParticleManager:SetParticleControl(particle, 3, target_point)

	AddFOWViewer(caster:GetTeam(), target_point, ability:GetSpecialValueFor("vision_radius"), ability:GetSpecialValueFor("vision_duration"), false)
		
		for _, target in pairs(enemies) do
			local damage_table 			= {}
			damage_table.attacker 		= caster
			damage_table.ability 		= ability
			damage_table.damage_type 	= ability:GetAbilityDamageType() 
			damage_table.damage			= ability:GetSpecialValueFor("damage")
			damage_table.victim 		= target

			caster:FindModifierByName("modifier_raio_unstable_passive"):ApplyMark(target, marks)

			ApplyDamage(damage_table)
		end
	end

	if first_strike and caster:FindAbilityByName("special_bonus_raio_8"):GetLevel() > 0 then
		 local delay_second = caster:FindAbilityByName("special_bonus_raio_8"):GetSpecialValueFor("value") 
		 CreateModifierThinker(caster, ability, "modifier_raio_heavenly_decree_mark", {duration = delay_second, target_point_x = target_point.x, target_point_y = target_point.y, target_point_z = target_point.z, first_strike = false}, target_point, caster:GetTeamNumber(), false)
		end

end

modifier_raio_heavenly_decree_mark = modifier_raio_heavenly_decree_mark or class({})
function modifier_raio_heavenly_decree_mark:IsHidden() return true end
function modifier_raio_heavenly_decree_mark:IsPurgable() return false end

function modifier_raio_heavenly_decree_mark:OnCreated(keys)
	if IsServer() then
		self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)
		self.first_strike = (keys.first_strike == 1)
		self.marks = keys.marks
		AddFOWViewer(self:GetCaster():GetTeam(), self.target_point, self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("delay"), false)
	end
end
function modifier_raio_heavenly_decree_mark:OnRemoved()
	if not IsServer() then return end
	self:GetAbility():CastLightningBolt(self:GetCaster(), self:GetAbility(), self.target_point, self.first_strike, self.marks)
end

function modifier_raio_heavenly_decree_mark:GetEffectName()
	return "particles/heroes/raio/mark.vpcf"
end

function modifier_raio_heavenly_decree_mark:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end

modifier_raio_heavenly_decree_scepter = modifier_raio_heavenly_decree_scepter or class({})

function modifier_raio_heavenly_decree_scepter:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_raio_heavenly_decree_scepter:IsHidden() return true end
function modifier_raio_heavenly_decree_scepter:IsPurgable() return false end
function modifier_raio_heavenly_decree_scepter:IsPassive() return false end

function modifier_raio_heavenly_decree_scepter:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster() 
		local ability = self:GetAbility()

		if caster:HasScepter() and ability:IsCooldownReady() then
			local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(), 
			caster:GetAbsOrigin(), 
			nil, 
			FIND_UNITS_EVERYWHERE, 
			ability:GetAbilityTargetTeam(), 
			DOTA_UNIT_TARGET_HERO, 
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 
			FIND_ANY_ORDER, 
			false
			)
			if #enemies > 0 then
				local delay = self:GetAbility():GetSpecialValueFor("delay")
				local marks = self:GetAbility():GetSpecialValueFor("voltage_marks")  
				local target_point = enemies[1]:GetAbsOrigin()
				CreateModifierThinker(caster, self:GetAbility(), "modifier_raio_heavenly_decree_mark", {duration = delay, target_point_x = target_point.x, target_point_y = target_point.y, target_point_z = target_point.z, first_strike = true, marks = marks}, target_point, caster:GetTeamNumber(), false)
				ability:StartCooldown(ability:GetCooldown() * caster:GetCooldownReduction())
			end
		end
	end
end