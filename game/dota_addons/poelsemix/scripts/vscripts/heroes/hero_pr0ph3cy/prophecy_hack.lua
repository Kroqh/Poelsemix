LinkLuaModifier("modifier_pro_hack_stat_steal", "heroes/hero_pr0ph3cy/prophecy_hack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pro_hack_stat_gain", "heroes/hero_pr0ph3cy/prophecy_hack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pro_hack_damage", "heroes/hero_pr0ph3cy/prophecy_hack", LUA_MODIFIER_MOTION_NONE)
pr0_hack = pr0_hack or class({})

function pr0_hack:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local particle = "particles/units/heroes/hero_phantom_lancer/phantomlancer_spiritlance_projectile.vpcf"
		local speed = 1000
        

        local projectile = 
			{
				Target = target,
				Source = caster,
				Ability = self,
				EffectName = particle,
				iMoveSpeed = speed,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
			}
		ProjectileManager:CreateTrackingProjectile(projectile)

        if self:GetCaster():HasTalent("special_bonus_prophecy_4") then

            local range = self:GetEffectiveCastRange(caster:GetAbsOrigin(),caster)
            local enemy_heroes = FindUnitsInRadius(caster:GetTeamNumber(),
											   caster:GetAbsOrigin(),
											   nil,
											   range,
											   DOTA_UNIT_TARGET_TEAM_ENEMY,
											   DOTA_UNIT_TARGET_HERO,
											   DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
											   FIND_CLOSEST,
											   false)
            
            for _,enemy_hero in pairs(enemy_heroes) do
			if enemy_hero ~= target then
				projectile.Target = enemy_hero
                ProjectileManager:CreateTrackingProjectile(projectile)
                break
			end
		end                  
            

        end
        EmitSoundOn("pr0_hack", caster)
    end
end


function pr0_hack:OnProjectileHit(target)
	if not target then
		return nil 
	end

	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("hacktimer")

    if self:GetCaster():HasTalent("special_bonus_prophecy_1") then duration = duration + self:GetCaster():FindAbilityByName("special_bonus_prophecy_1"):GetSpecialValueFor("value") end
	
	target:AddNewModifier(caster, self, "modifier_pro_hack_damage", {duration = duration})


    if caster:HasScepter() then
        target:AddNewModifier(caster, self, "modifier_pro_hack_stat_steal", {duration = duration})
        if caster:HasModifier("modifier_pro_hack_stat_gain") then
            caster:FindModifierByName("modifier_pro_hack_stat_gain"):SetStackCount(1 + caster:FindModifierByName("modifier_pro_hack_stat_gain"):GetStackCount())
        else
            mod = caster:AddNewModifier(caster, self, "modifier_pro_hack_stat_gain", {})
            mod:SetStackCount(1)
        end
    end
end


modifier_pro_hack_damage = modifier_pro_hack_damage or class({})

function modifier_pro_hack_damage:IsHidden()		return false end
function modifier_pro_hack_damage:IsDebuff()		return true end


function modifier_pro_hack_damage:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()

		self.damage = ability:GetSpecialValueFor("damage_tick")
		self.tick = ability:GetSpecialValueFor("hackticks")
		self:StartIntervalThink(self.tick-0.1)
	end
end

function modifier_pro_hack_damage:OnIntervalThink()
	if IsServer() then
		local target = self:GetParent()
		local caster = self:GetCaster()

		ApplyDamage({victim = target,
		attacker = caster,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		damage = self.damage,
		ability = self:GetAbility()
		})
		self:StartIntervalThink(self.tick)
	end
end

function modifier_pro_hack_damage:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true}
end

function modifier_pro_hack_damage:GetStatusEffectName()
	return "particles/status_fx/status_effect_electrical.vpcf"
end
function modifier_pro_hack_damage:StatusEffectPriority()
	return 10
end

modifier_pro_hack_stat_gain = modifier_pro_hack_stat_gain or class({})

function modifier_pro_hack_stat_gain:IsHidden()		return false end
function modifier_pro_hack_stat_gain:IsPurgable()		return false end
function modifier_pro_hack_stat_gain:IsDebuff()		return false end


function modifier_pro_hack_stat_gain:OnCreated()
	if IsServer() then
		self:GetParent():CalculateStatBonus(false)
	end
end

function modifier_pro_hack_stat_gain:DeclareFunctions()
	local funcs = {
                    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                    MODIFIER_PROPERTY_STATS_AGILITY_BONUS
					}
	return funcs
end
function modifier_pro_hack_stat_gain:GetModifierBonusStats_Intellect()	if self:GetAbility() then return  self:GetAbility():GetSpecialValueFor("stat_steal") * self:GetStackCount() end end
function modifier_pro_hack_stat_gain:GetModifierBonusStats_Agility()	if self:GetAbility() then return  self:GetAbility():GetSpecialValueFor("stat_steal") * self:GetStackCount() end end
function modifier_pro_hack_stat_gain:GetModifierBonusStats_Strength()	if self:GetAbility() then return  self:GetAbility():GetSpecialValueFor("stat_steal") * self:GetStackCount() end end


modifier_pro_hack_stat_steal = modifier_pro_hack_stat_steal or class({})


function modifier_pro_hack_stat_steal:IsHidden()		return false end
function modifier_pro_hack_stat_steal:IsPurgable()		return false end
function modifier_pro_hack_stat_steal:IsDebuff()		return true end


function modifier_pro_hack_stat_steal:DeclareFunctions()
	local funcs = {
                    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                    MODIFIER_PROPERTY_STATS_AGILITY_BONUS
					}
	return funcs
end
function modifier_pro_hack_stat_steal:GetModifierBonusStats_Intellect()	if self:GetAbility() then return  -self:GetAbility():GetSpecialValueFor("stat_steal") end end
function modifier_pro_hack_stat_steal:GetModifierBonusStats_Agility()	if self:GetAbility() then return  -self:GetAbility():GetSpecialValueFor("stat_steal") end end
function modifier_pro_hack_stat_steal:GetModifierBonusStats_Strength()	if self:GetAbility() then return  -self:GetAbility():GetSpecialValueFor("stat_steal") end end

function modifier_pro_hack_stat_steal:OnDestroy()
    if IsServer() then
        local pro_modifier = self:GetAbility():GetCaster():FindModifierByName("modifier_pro_hack_stat_gain")
        pro_modifier:DecrementStackCount()
        if pro_modifier:GetStackCount() == 0 then pro_modifier:Destroy() end
    end
end

function modifier_pro_hack_stat_steal:OnRefresh()
    if IsServer() then
        self:OnDestroy()
    end
end



