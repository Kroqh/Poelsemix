LinkLuaModifier("modifier_kaj_andrea_stats", "heroes/hero_kaj/kaj_andrea", LUA_MODIFIER_MOTION_NONE)
kaj_andrea = kaj_andrea or class({})


function kaj_andrea:GetCastRange()
    local value = self:GetSpecialValueFor("summon_range") 
    return value
end

function kaj_andrea:OnProjectileHit_ExtraData(target, loc, data)
    if not target then
		return nil 
	end
    local caster = self:GetCaster()

    ApplyDamage({victim = target,
	attacker = caster,
	damage_type = self:GetAbilityDamageType(),
	damage = data.damage,
	ability = self})

    EmitSoundOn("KajAndrea4", target)
	
end

function kaj_andrea:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
		local target_pos = self:GetCursorPosition()
        local duration = self:GetSpecialValueFor("summon_duration")
        caster:EmitSound("KajAndrea1")
    
        local hp_scaling = self:GetSpecialValueFor("andrea_hp_of_kaj_percent")
    
        local hp = math.floor((hp_scaling/100) * caster:GetMaxHealth()) --andrea has 1 hp by defeault as to not insta die
    
        unit = CreateUnitByName("unit_andrea",target_pos, true, caster, caster, caster:GetTeam())
        unit:SetControllableByPlayer(caster:GetPlayerID(), true)
        unit:AddNewModifier(caster, self, "modifier_kill", { duration = duration } )
        unit:AddNewModifier(caster, self, "modifier_kaj_andrea_stats", {duration = duration} )
        unit:SetTeam(caster:GetTeamNumber())
	    unit:SetOwner(caster)
        unit:SetBaseMaxHealth(hp)
        unit:SetMaxHealth(hp)
        unit:SetHealth(hp) --has to have this ugly trio for it to work lol
    end
end

modifier_kaj_andrea_stats = modifier_kaj_andrea_stats or class({})



function modifier_kaj_andrea_stats:IsPurgable() return false end
function modifier_kaj_andrea_stats:IsHidden() return false end

function modifier_kaj_andrea_stats:OnCreated()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    self.ms = ability:GetSpecialValueFor("andrea_ms")
	if not IsServer() then return end
    self.range = ability:GetSpecialValueFor("andrea_fire_range")
    self.fire_rate = ability:GetSpecialValueFor("andrea_fire_rate")
    if caster:FindAbilityByName("special_bonus_kaj_8"):GetLevel() > 0 then self.fire_rate = self.fire_rate + caster:FindAbilityByName("special_bonus_kaj_8"):GetSpecialValueFor("value") end
    self.damage = ability:GetSpecialValueFor("andrea_damage")
    self.nuke_rate = 999
    self.nuke_counter = 0.1
    if caster:HasScepter() then 
        self.nuke_rate = ability:GetSpecialValueFor("scepter_nuke_rate")
    end
    self.nuke_damage = ability:GetSpecialValueFor("scepter_nuke_damage")
    self.nuke_range = ability:GetSpecialValueFor("scepter_nuke_range")

    self.targets = 1
    if caster:FindAbilityByName("special_bonus_kaj_7"):GetLevel() > 0 then self.targets = self.targets + caster:FindAbilityByName("special_bonus_kaj_7"):GetSpecialValueFor("value") end

    self:StartIntervalThink(self.fire_rate)

end

function modifier_kaj_andrea_stats:OnIntervalThink()
	if IsServer() then
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local parent = self:GetParent()

        
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
			parent:GetAbsOrigin(), 
			nil, 
			self.range, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			ability:GetAbilityTargetFlags(), 
			FIND_CLOSEST, 
			false)

      
        local particle = "particles/units/heroes/hero_kaj/andrea_shot.vpcf"
		for i = 1,self.targets,1 do
            
            if enemies[i] ~= nil then

                local shot = 
                {
                    Target = enemies[i],
                    Source = parent,
                    Ability = ability,
                    EffectName = particle,
                    iMoveSpeed = 1000,
                    bDodgeable = true,
                    bVisibleToEnemies = true,
                    bReplaceExisting = false,
                    bProvidesVision = false,
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                    ExtraData = {damage = self.damage}
                }
            ProjectileManager:CreateTrackingProjectile(shot)
            EmitSoundOn("KajAndrea3", parent)
            end
         end

         --TODO MANGLER NUKING SCEPTER
         self.nuke_counter = self.nuke_counter + self.fire_rate
         if self.nuke_counter >= self.nuke_rate then
            EmitSoundOn("KajAndrea2", parent)
            print("test")


            local enemies2 = FindUnitsInRadius(caster:GetTeamNumber(), 
			parent:GetAbsOrigin(), 
			nil, 
			self.nuke_range, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			ability:GetAbilityTargetFlags(), 
			FIND_CLOSEST, 
			false)

            for _, enemy in pairs(enemies2) do
                ApplyDamage({victim = enemy,
                attacker = caster,
                damage_type = ability:GetAbilityDamageType(),
                damage = self.nuke_damage,
                ability = ability})
			end
	
	        local calldown_second_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_kaj/nuke.vpcf", PATTACH_WORLDORIGIN, parent)
	        ParticleManager:SetParticleControl(calldown_second_particle, 0, parent:GetAttachmentOrigin(parent:ScriptLookupAttachment("attach_hitloc")))
	        ParticleManager:SetParticleControl(calldown_second_particle, 1, parent:GetAbsOrigin())
	        ParticleManager:SetParticleControl(calldown_second_particle, 5, Vector(self.nuke_range, self.nuke_range, self.nuke_range))
	        ParticleManager:ReleaseParticleIndex(calldown_second_particle)
            
            self.nuke_counter = 0
         end

	end
end


function modifier_kaj_andrea_stats:DeclareFunctions()
	local decFuncs = {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
}
    return decFuncs
end


function modifier_kaj_andrea_stats:GetModifierMoveSpeedOverride()
    return self.ms
end