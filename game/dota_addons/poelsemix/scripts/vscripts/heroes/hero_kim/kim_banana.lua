kim_banana = kim_banana or class({})

function kim_banana:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_point = self:GetCursorPosition()
    local distance = (caster:GetAbsOrigin() - target_point):Length2D()
    local direction = (target_point - caster:GetAbsOrigin()):Normalized()
    caster:EmitSound("kim_bananer")

    local banan_projectile = {
        Target = GetGroundPosition(target_point,nil),
        vSpawnOrigin = caster:GetAbsOrigin(),
        Source = caster,
        Ability = self,
        fDistance = distance,
        EffectName = "particles/heroes/kim/banana_kim_proj.vpcf",
        fStartRadius		= 50,
		fEndRadius			= 50,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        bDodgeable = false,
        bIgnoreSource = true,
        bProvidesVision = false,
        --iMoveSpeed = self:GetSpecialValueFor("proj_speed"),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        vVelocity 	= direction * self:GetSpecialValueFor("projectile_speed") * Vector(1, 1, 0)
    }
    ProjectileManager:CreateLinearProjectile(banan_projectile)
end

function kim_banana:GetCooldown(level)

	local cd = self.BaseClass.GetCooldown(self,level)
    if self:GetCaster():FindAbilityByName("special_bonus_kim_3"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_kim_3"):GetSpecialValueFor("value") end
    return cd
end




function kim_banana:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()


    if target == nil then
        local unit = CreateUnitByName("npc_banan", location, true, caster, caster, caster:GetTeamNumber())
        unit:AddNewModifier(caster, self, "modifier_banana_handler", {} )
        return true
    elseif target:IsRealHero() then
        local gold = self:GetSpecialValueFor("gold_stolen")
		if caster:FindAbilityByName("special_bonus_kim_6"):GetLevel() > 0 then gold = gold + caster:FindAbilityByName("special_bonus_kim_6"):GetSpecialValueFor("value") end
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
        	caster:ModifyGold(gold, true, 0)
    		target:ModifyGold(-gold, true, 0)
		end

        if not caster:HasScepter() then
            target:Heal(self:GetSpecialValueFor("target_heal"),self)
        else
            target:AddNewModifier(caster, self, "modifier_banana_toxic", {duration = self:GetSpecialValueFor("aghs_tick_duration")})
        end
        return true
    else
        return false
    end

end

modifier_banana_handler = modifier_banana_handler or class({})
LinkLuaModifier("modifier_banana_handler", "heroes/hero_kim/kim_banana", LUA_MODIFIER_MOTION_NONE)
function modifier_banana_handler:IsHidden() return true end
function modifier_banana_handler:IsPurgable() return false end

function modifier_banana_handler:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		self:GetParent():AddNewModifier(self:GetParent(), ability, "modifier_kill", { duration = ability:GetSpecialValueFor("peel_duration") } )
        self.radius = ability:GetSpecialValueFor("peel_radius")

        self:StartIntervalThink(0.1)
	end
end

function modifier_banana_handler:OnIntervalThink()
	if IsServer() then
			local parent = self:GetParent()
			local ability = self:GetAbility()

    local unit = self:GetParent()
		local unit_pos = unit:GetAbsOrigin()
		local ability = self:GetAbility()
		local caster = ability:GetCaster()
		local enemies = FindUnitsInRadius(unit:GetTeamNumber(), 
			unit_pos, 
			nil, 
			self.radius, 
			DOTA_UNIT_TARGET_TEAM_BOTH, 
			DOTA_UNIT_TARGET_HERO, 
			DOTA_UNIT_TARGET_FLAG_NONE, 
			FIND_ANY_ORDER, 
			false)

		if #enemies == 0 then
			enemies = nil
		end

        if enemies ~= nil then
			self:StartIntervalThink(-1)
			for _, enemy in pairs(enemies) do
				enemy:AddNewModifier(parent, ability, "modifier_banana_slip", {})
			end

			EmitSoundOn("kim_banana_slip", unit)
			unit:AddNoDraw()
			unit:ForceKill(false)
		end
    end
end

modifier_banana_slip = modifier_banana_slip or class ({})
LinkLuaModifier("modifier_banana_slip", "heroes/hero_kim/kim_banana", LUA_MODIFIER_MOTION_NONE)

function modifier_banana_slip:IsPurgable() return	false end
function modifier_banana_slip:IsHidden() return	false end
function modifier_banana_slip:IgnoreTenacity() return true end
function modifier_banana_slip:IsDebuff() return true end
function modifier_banana_slip:IsMotionController() return true end
function modifier_banana_slip:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_banana_slip:CheckState()
	if IsServer() then
		local state = {	[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true, }
		return state
	end
end

function modifier_banana_slip:OnCreated()
	if not IsServer() then return end
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local distance = ability:GetSpecialValueFor("slip_distance")

		self.direction = parent:GetForwardVector()
		self.velocity = ability:GetSpecialValueFor("slip_velocity")
		self.distance_traveled = 0
		self.distance = distance

		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)
end

function modifier_banana_slip:OnIntervalThink()
	if IsServer() then
		if not self:CheckMotionControllers() then
			self:Destroy()
			return nil
		end

		self:HorizontalMotion(self:GetParent(), self.frametime)
	end
end

function modifier_banana_slip:HorizontalMotion(me, dt)
	if IsServer() then
		local parent = self:GetParent()

		if self.distance_traveled < self.distance then
			parent:SetAbsOrigin(parent:GetAbsOrigin() + self.direction * self.velocity * dt)
			self.distance_traveled = self.distance_traveled + self.velocity * dt
        else
			self:Destroy()
		end
	end
end


modifier_banana_toxic = modifier_banana_toxic or class({})
LinkLuaModifier("modifier_banana_toxic", "heroes/hero_kim/kim_banana", LUA_MODIFIER_MOTION_NONE)

function modifier_banana_toxic:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		self.tick = ability:GetSpecialValueFor("aghs_tick_rate")
		self:StartIntervalThink(self.tick-0.1)
	end
end

function modifier_banana_toxic:OnIntervalThink()
	if IsServer() then
		local target = self:GetParent()
		local caster = self:GetCaster()
        local ability = self:GetAbility()

		ApplyDamage({victim = target,
		attacker = caster,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage = ability:GetSpecialValueFor("aghs_poison_per_tick"),
		ability = self:GetAbility()
		})
        self:StartIntervalThink(self.tick)
	end
end