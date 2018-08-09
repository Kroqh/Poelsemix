LinkLuaModifier("modifier_gunpowder", "heroes/hero_baseboys/hero_baseboys", LUA_MODIFIER_MOTION_NONE)
gunpowder_datadriven = class({})

function gunpowder_datadriven:GetAbilityTextureName()
	return "gunpowder"
end

function gunpowder_datadriven:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		local particle = "particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf"
		local agility = self:GetSpecialValueFor("bonus_agility")

		caster:AddNewModifier(caster, self, "modifier_gunpowder", {duration = duration, agility = agility})
		
		local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
		self:EmitSound("gratisgunpowder")
		self:EmitSound("Hero_Sven.GodsStrength")
	end
end

modifier_gunpowder = class({})

function modifier_gunpowder:OnCreated(keys)
	local ability = self:GetAbility()
	local scale = ability:GetSpecialValueFor("model_scale")
	local caster = self:GetCaster()
	self.bonus_agility = keys.agility
	--Passing movespeed through AddNewModifier doesn't show on the HUD
	--so we define it here.
	self.bonus_speed = ability:GetSpecialValueFor("bonus_speed")
	if IsServer() then
		self.orig_size = caster:GetModelScale()
		caster:SetModelScale(scale)
	end
end

function modifier_gunpowder:IsPurgeable() return false end
function modifier_gunpowder:IsBuff() return true end

function modifier_gunpowder:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE}
	return decFuncs
end

function modifier_gunpowder:GetModifierBonusStats_Agility()
	return self.bonus_agility
end

function modifier_gunpowder:GetModifierMoveSpeed_Absolute()
	return self.bonus_speed
end

function modifier_gunpowder:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function modifier_gunpowder:StatusEffectPriority()
	return 10
end

function modifier_gunpowder:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		caster:SetModelScale(self.orig_size)
	end
end
LinkLuaModifier("modifier_bomb_b", "heroes/hero_baseboys/hero_baseboys", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bomb_b_stun", "heroes/hero_baseboys/hero_baseboys", LUA_MODIFIER_MOTION_NONE)
bomb_b = class({})

function bomb_b:GetAbilityTextureName()
	return "bombe_b"
end

function bomb_b:OnSpellStart()
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

LinkLuaModifier("modifier_choke", "heroes/hero_baseboys/hero_baseboys", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_choke_stun", "heroes/hero_baseboys/hero_baseboys", LUA_MODIFIER_MOTION_NONE)
choke_datadriven = class({})

function choke_datadriven:GetAbilityTextureName()
	return "hej_mathilde"
end

function choke_datadriven:GetIntrinsicModifierName()
	return "modifier_choke"
end

modifier_choke = class({})

function modifier_choke:IsHidden() return true end

function modifier_choke:DeclareFunctions()
	local decFuncs = 
	{MODIFIER_EVENT_ON_ATTACKED}
	return decFuncs
end

function modifier_choke:OnAttacked(keys)
	if IsServer() then

		if keys.target == self:GetParent() then

			local ability = self:GetAbility()
			local chance = ability:GetSpecialValueFor("chance") 
			local duration = ability:GetSpecialValueFor("duration")
			local caster = self:GetParent()

			if caster:PassivesDisabled() or caster:IsHexed() then
				return nil
			end

			if RollPseudoRandom(chance, self) then

				keys.attacker:AddNewModifier(caster, ability, "modifier_choke_stun", {duration = duration})
				ability:EmitSound("hej_mathilde")
			end
		end
	end
end

modifier_choke_stun = class({})

function modifier_choke_stun:IsPurgeable() return false end
function modifier_choke_stun:IsHidden() return false end

function modifier_choke_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"

end

function modifier_choke_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_choke_stun:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end