musashi_water = musashi_water or class({})
LinkLuaModifier( "modifier_musashi_water", "heroes/hero_musashi/musashi_water", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function musashi_water:GetIntrinsicModifierName()
	return "modifier_musashi_water"
end


modifier_musashi_water = modifier_musashi_water or class({})

function modifier_musashi_water:IsPassive() return true end

function modifier_musashi_water:IsHidden() return true end

function modifier_musashi_water:IsPurgable() return false end


function modifier_musashi_water:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end


function modifier_musashi_water:OnAttackLanded( params )
	if IsServer() then
		if params.target~=self:GetCaster() then return end
		if self:GetCaster():PassivesDisabled() then return end
		if params.attacker:GetTeamNumber()==params.target:GetTeamNumber() then return end
		if params.attacker:IsOther() or params.attacker:IsBuilding() then return end
        local range = self:GetAbility():GetSpecialValueFor("range")
        if self:GetParent():HasTalent("special_bonus_musashi_3") then
            range = range  + self:GetParent():FindAbilityByName("special_bonus_musashi_3"):GetSpecialValueFor("value")
        end
        if (params.target:GetAbsOrigin()-params.attacker:GetAbsOrigin()):Length2D() > range then return end

        local chance = self:GetAbility():GetSpecialValueFor("proc_chance")
		if RandomInt(1,100) > chance then return end

        self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_4)

        self:GetParent():EmitSound("musashi_water") 

		

		-- damage
		
        local damage = self:GetParent():GetAttackDamage()
        
        local damageTable = {
			victim = params.attacker,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}
        ApplyDamage(damageTable)

		if self:GetParent():HasScepter() then
		    local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			self:GetAbility():GetAbilityTargetTeam(),	-- int, team filter
			self:GetAbility():GetAbilityTargetType(),	-- int, type filter
			self:GetAbility():GetAbilityTargetFlags(),	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		    )
            
            for _,enemy in pairs(enemies) do
                if params.attacker ~= enemy then
                    damageTable.victim = enemy
		            ApplyDamage(damageTable)
                end
		    end
            local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_riptide.vpcf", PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:SetParticleControl(pfx, 1, Vector(range, range, range))
			ParticleManager:SetParticleControl(pfx, 3, Vector(range, range, range))
			ParticleManager:ReleaseParticleIndex(pfx)
        end
        local tidebringer_hit_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 0, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 2, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)

		-- cooldown
		self:GetAbility():UseResources(false, false, false, true )

	end
end