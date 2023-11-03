LinkLuaModifier("modifier_lars_skat", "heroes/hero_lars/lars_skat", LUA_MODIFIER_MOTION_NONE)

lars_skat = lars_skat or class({})
function lars_skat:OnSpellStart()
    if  not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("channel_time")
    caster:EmitSound("LarsSkat1")
    if caster:HasModifier("modifier_lars_skat") then caster:RemoveModifierByName("modifier_lars_skat") end --refresher orb protection
    caster:AddNewModifier(caster, self, "modifier_lars_skat", {duration = duration})

end

function lars_skat:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function lars_skat:GetChannelTime()
    return self:GetSpecialValueFor("channel_time")
end

function lars_skat:OnChannelFinish(interrupted)
    if  not IsServer() then return end
    if self:GetCaster():FindAbilityByName("special_bonus_lars_4"):GetLevel() == 0 then self:GetCaster():RemoveModifierByName("modifier_lars_skat") end

end

function lars_skat:OnProjectileHit(target)
    ParticleManager:CreateParticle("particles/econ/courier/courier_flopjaw_gold/flopjaw_death_coins_gold.vpcf", PATTACH_ABSORIGIN, target)
    local tax_rate = self:GetSpecialValueFor("tax_rate") 
	if self:GetCaster():FindAbilityByName("special_bonus_lars_3"):GetLevel() > 0 then tax_rate = tax_rate + self:GetCaster():FindAbilityByName("special_bonus_lars_3"):GetSpecialValueFor("value") end 
    local gold = target:GetGold() * (tax_rate / 100)
    target:ModifyGold(-gold, false, 0)
    self:GetCaster():ModifyGold(gold, false, 0)
end

modifier_lars_skat = modifier_lars_skat or class({})


function modifier_lars_skat:IsHidden() return false end
function modifier_lars_skat:IsPurgable() return false end

function modifier_lars_skat:OnCreated()
	if not IsServer() then end
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local tick = ability:GetSpecialValueFor("tick_rate")
		self:StartIntervalThink(tick-0.1)
end


function modifier_lars_skat:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_EVENT_ON_ATTACK_START}
	return decFuncs
end

function modifier_lars_skat:OnAttackStart(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.attacker == parent then
                parent:RemoveModifierByName("modifier_lars_skat")
		end
	end
end

function modifier_lars_skat:OnAbilityExecuted(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.unit == parent then
                parent:RemoveModifierByName("modifier_lars_skat")
		end
	end
end


function modifier_lars_skat:OnIntervalThink()
	if not IsServer() then end
		local ability = self:GetAbility()
		local caster = self:GetCaster()
        local range = ability:GetSpecialValueFor("radius")
        self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_2)

        local cast_pfx = ParticleManager:CreateParticle("particles/econ/items/lina/lina_ti7/lina_spell_light_strike_array_ti7_gold_ring_collapse_f.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(cast_pfx, 1, Vector(range, range, 1.5))
        ParticleManager:SetParticleControl(cast_pfx, 2, Vector(0,0,0))
		ParticleManager:ReleaseParticleIndex(cast_pfx)
        local enemies = FindUnitsInRadius(
			self:GetParent():GetTeam(),	-- int, your team number
			self:GetParent():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			ability:GetAbilityTargetTeam(),	-- int, team filter
			ability:GetAbilityTargetType(),	-- int, type filter
			ability:GetAbilityTargetFlags(),	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		    )

         for _,enemy in pairs(enemies) do
            if enemy:IsRealHero() then
                local hand = 
			{
				Target = enemy,
				Source = caster,
				Ability = ability,
				EffectName = "particles/heroes/lars/lars_midas.vpcf",
				iMoveSpeed = 600,
				bDodgeable = false,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				ExtraData = {}
			}
            ProjectileManager:CreateTrackingProjectile(hand)
            end
                
		end
        if enemies[1] ~= nil then caster:EmitSound("LarsSkat2") end
		self:StartIntervalThink(ability:GetSpecialValueFor("tick_rate"))
    
end