LinkLuaModifier("modifier_raio_heavenly_decree_mark", "heroes/hero_raio/raio_heavenly_decree", LUA_MODIFIER_MOTION_NONE)

raio_heavenly_decree = raio_heavenly_decree or class({})

function raio_heavenly_decree:OnAbilityPhaseStart()
	
	self:GetCaster():EmitSound("raio_heavenly_cast")
	
	return true
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
		CreateModifierThinker(caster, self, "modifier_raio_heavenly_decree_mark", {duration = delay, target_point_x = target_point.x, target_point_y = target_point.y, target_point_z = target_point.z}, target_point, caster:GetTeamNumber(), false)
	end
end

function raio_heavenly_decree:CastLightningBolt(caster, ability, target_point)
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
			ApplyDamage(damage_table)
		end
	end
end

modifier_raio_heavenly_decree_mark = modifier_raio_heavenly_decree_mark or class({})
function modifier_raio_heavenly_decree_mark:IsHidden() return true end
function modifier_raio_heavenly_decree_mark:IsPurgable() return false end

function modifier_raio_heavenly_decree_mark:OnCreated(keys)
	if IsServer() then
		self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)
		AddFOWViewer(self:GetCaster():GetTeam(), self.target_point, self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("delay"), false)
	end
end
function modifier_raio_heavenly_decree_mark:OnRemoved()
	if not IsServer() then return end
	self:GetAbility():CastLightningBolt(self:GetCaster(), self:GetAbility(), self.target_point)
end

function modifier_raio_heavenly_decree_mark:GetEffectName()
	return "particles/heroes/raio/mark.vpcf"
end

function modifier_raio_heavenly_decree_mark:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end