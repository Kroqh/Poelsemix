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
		if self:GetCaster():FindAbilityByName("special_bonus_baseboys_4"):GetLevel() > 0 then duration = duration + self:GetCaster():FindAbilityByName("special_bonus_baseboys_4"):GetSpecialValueFor("value") end

		caster:AddNewModifier(caster, self, "modifier_bomb_b", {duration = duration})
		self:EmitSound("bombe_paa_b")

		local illusions = caster:FindAbilityByName("baseboys_concert"):GetIllusions()
        if illusions then
            for _, illusion in pairs(illusions) do
                if IsValidEntity(illusion) and illusion:IsAlive() then
                    illusion:AddNewModifier(caster, self, "modifier_bomb_b", {duration = duration})
					illusion:EmitSound("bombe_paa_b")
                end
            end
        end


	end
end

modifier_bomb_b = modifier_bomb_b or class({})

function modifier_bomb_b:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local interval = ability:GetSpecialValueFor("tick_interval")

		self.radius = ability:GetSpecialValueFor("radius")
		self.damage = ability:GetSpecialValueFor("damage")
		if self:GetCaster():FindAbilityByName("special_bonus_baseboys_5"):GetLevel() > 0 then self.damage = self.damage + self:GetCaster():FindAbilityByName("special_bonus_baseboys_5"):GetSpecialValueFor("value") end
		self.stun_duration = ability:GetSpecialValueFor("stun_duration")
		self.mini_stun_duration = ability:GetSpecialValueFor("mini_stun_duration")

		self.particle = "particles/units/heroes/hero_baseboys/baseboys_bomb_b.vpcf"

		self.bombCounter = 0
		self.bombsHit = 0

		self:StartIntervalThink(interval)
	end
end

function modifier_bomb_b:OnIntervalThink()
	if IsServer() then
		self.bombCounter = self.bombCounter + 1
		local parent = self:GetParent()
		local parent_pos = parent:GetAbsOrigin()
		local ability = self:GetAbility()

		local heroes = FindUnitsInRadius(parent:GetTeamNumber(), parent_pos, nil, self.radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		
		parent:EmitSound("Hero_Techies.Suicide")

		local pfx = ParticleManager:CreateParticle(self.particle, PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControl(pfx, 0, parent_pos)
		ParticleManager:SetParticleControl(pfx, 2, Vector(0.2,0.2,0.2))

		if #heroes == 0 then
			return nil
		end

		for _, enemy in pairs(heroes) do
			ApplyDamage({victim = enemy, attacker = parent, damage_type = ability:GetAbilityDamageType(), damage = self.damage, ability = ability})
			enemy:AddNewModifier(parent, ability, "modifier_bomb_b_stun", {duration = self.mini_stun_duration})
		end

		self.bombsHit = self.bombsHit + 1
	end
end

function modifier_bomb_b:OnRemoved()
	if IsServer() then
		local parent = self:GetParent()
		local ability = self:GetAbility()
		parent:AddNewModifier(parent, ability, "modifier_bomb_b_stun", {duration = self.stun_duration})
		ability:EmitSound("FUCKDIG")
	end
end

modifier_bomb_b_stun = modifier_bomb_b_stun or class({})

function modifier_bomb_b_stun:IsPurgable() return true end
function modifier_bomb_b_stun:IsDebuff() return true end
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

