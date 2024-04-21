LinkLuaModifier("modifier_bomb_b", "heroes/hero_baseboys/baseboys_bomb_b", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bomb_b_stun", "heroes/hero_baseboys/baseboys_bomb_b", LUA_MODIFIER_MOTION_NONE)
baseboys_bomb_b = baseboys_bomb_b or class({})

function baseboys_bomb_b:GetAbilityTextureName()
	return "bombe_b"
end

function baseboys_bomb_b:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")

		caster:AddNewModifier(caster, self, "modifier_bomb_b", {duration = duration})
		self:EmitSound("bombe_paa_b")
	end
end

modifier_bomb_b = class({})

function modifier_bomb_b:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local interval = ability:GetSpecialValueFor("tick_interval")

		self.radius = ability:GetSpecialValueFor("radius")
		self.damage = ability:GetSpecialValueFor("damage")
		self.stun_duration = ability:GetSpecialValueFor("stun_duration")
		self.mini_stun_duration = ability:GetSpecialValueFor("mini_stun_duration")

		self.particle = "particles/units/heroes/hero_techies/techies_suicide_base.vpcf"

		self.bombCounter = 0
		self.bombsHit = 0

		self:StartIntervalThink(interval)
	end
end

function modifier_bomb_b:OnIntervalThink()
	if IsServer() then
		self.bombCounter = self.bombCounter + 1
		local caster = self:GetParent()
		local caster_pos = caster:GetAbsOrigin()
		local ability = self:GetAbility()

		local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster_pos, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
		ability:EmitSound("Hero_Techies.Suicide")

		local pfx = ParticleManager:CreateParticle(self.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(pfx, 0, caster_pos)
		ParticleManager:SetParticleControl(pfx, 2, Vector(1.5,1.5,1.5))

		if #heroes == 0 then
			return nil
		end

		for _, enemy in pairs(heroes) do
			ApplyDamage({victim = enemy, attacker = caster, damage_type = DAMAGE_TYPE_MAGICAL, damage = self.damage, ability = ability})
			enemy:AddNewModifier(caster, ability, "modifier_bomb_b_stun", {duration = self.mini_stun_duration})
		end

		self.bombsHit = self.bombsHit + 1
	end
end

function modifier_bomb_b:OnRemoved()
	if IsServer() then
		if self.bombsHit < self.bombCounter then
			print("bomb missed once. caster stunned.")
			local caster = self:GetParent()
			local ability = self:GetAbility()
			caster:AddNewModifier(caster, ability, "modifier_bomb_b_stun", {duration = self.stun_duration})
			ability:EmitSound("FUCKDIG")
		end
	end
end

modifier_bomb_b_stun = class({})

function modifier_bomb_b_stun:IsPurgeable() return false end
function modifier_bomb_b_stun:IsHidden() return false end

function modifier_bomb_b_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"

end

function modifier_bomb_b_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_bomb_b_stun:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end

