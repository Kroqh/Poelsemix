
LinkLuaModifier("modifier_kaj_succ_thinker", "heroes/hero_kaj/kaj_succ", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kaj_succ_stun", "heroes/hero_kaj/kaj_succ", LUA_MODIFIER_MOTION_HORIZONTAL)
kaj_succ = kaj_succ or class({})

function kaj_succ:GetCastRange()
    local value = self:GetSpecialValueFor("radius") 
    if self:GetCaster():FindAbilityByName("special_bonus_kaj_4"):GetLevel() > 0 then value = value + self:GetCaster():FindAbilityByName("special_bonus_kaj_4"):GetSpecialValueFor("value") end
    return value
end


function kaj_succ:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	caster:EmitSound("KajSucc")
    local radius =   self:GetSpecialValueFor("radius") 
    local duration = self:GetSpecialValueFor("duration") 
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", PATTACH_POINT, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, 1, 1))
	ParticleManager:ReleaseParticleIndex(particle)
    local thinker = CreateModifierThinker(caster, self, "modifier_kaj_succ_thinker", {duration = duration}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
end

modifier_kaj_succ_thinker = modifier_kaj_succ_thinker or class({})


function modifier_kaj_succ_thinker:OnCreated()
	if IsServer() then
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
        if self:GetCaster():FindAbilityByName("special_bonus_kaj_4"):GetLevel() > 0 then self.radius = self.radius + self:GetCaster():FindAbilityByName("special_bonus_kaj_4"):GetSpecialValueFor("value") end
        self.damage = self:GetAbility():GetSpecialValueFor("damage")
        if self:GetCaster():FindAbilityByName("special_bonus_kaj_6"):GetLevel() > 0 then self.damage = self.damage + self:GetCaster():FindAbilityByName("special_bonus_kaj_6"):GetSpecialValueFor("value") end
        self.duration = self:GetDuration()
        self.location = self:GetCaster():GetAbsOrigin()
        self.vacuum_start_time = GameRules:GetGameTime()
        self.first_iteration = true
		self:StartIntervalThink(0.03)
        
	end
end

function modifier_kaj_succ_thinker:OnRemoved()
	if IsServer() then
        self.first_iteration = false
	end
end

function modifier_kaj_succ_thinker:OnIntervalThink()
	if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
    

        local vacuum_modifier = "modifier_kaj_succ_stun"
        local remaining_duration = self.duration - (GameRules:GetGameTime() - self.vacuum_start_time)
    
        -- Targeting variables
        local target_teams = ability:GetAbilityTargetTeam() 
        local target_types = ability:GetAbilityTargetType() 
        local target_flags = ability:GetAbilityTargetFlags() 
    
        local units = FindUnitsInRadius(caster:GetTeamNumber(), self.location, nil, self.radius, target_teams, target_types, target_flags, FIND_CLOSEST, false)
    
        -- Calculate the position of each found unit
        for _,unit in ipairs(units) do
            local unit_location = unit:GetAbsOrigin()
            local vector_distance = self.location - unit_location
            local distance = (vector_distance):Length2D()
            local direction = (vector_distance):Normalized()
    
            -- Check if its a new vacuum cast
            -- Set the new pull speed if it is
            if self.first_iteration then

                ApplyDamage({victim = unit,
		        attacker = caster,
		        damage_type = self:GetAbility():GetAbilityDamageType(),
		        damage = self.damage,
		        ability = self:GetAbility()
		    })
                unit.pull_speed = distance * 1/self.duration * 1/30
            end
            
            -- Apply the stun and no collision modifier then set the new location
            unit:AddNewModifier(caster, self, "modifier_kaj_succ_stun", {duration = remaining_duration})
            unit:SetAbsOrigin(unit_location + direction * unit.pull_speed)
        end
        self.first_iteration = false
	end
end



modifier_kaj_succ_stun = modifier_kaj_succ_stun or class({})

function modifier_kaj_succ_stun:IsPurgable() return	false end
function modifier_kaj_succ_stun:IsHidden() return	true end
function modifier_kaj_succ_stun:IgnoreTenacity() return true end
function modifier_kaj_succ_stun:IsMotionController() return true end
function modifier_kaj_succ_stun:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end


function modifier_kaj_succ_stun:CheckState()
	if IsServer() then
		local state = {	[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true, }
		return state
	end
end

function modifier_kaj_succ_stun:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
	return decFuncs
end

function modifier_kaj_succ_stun:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
