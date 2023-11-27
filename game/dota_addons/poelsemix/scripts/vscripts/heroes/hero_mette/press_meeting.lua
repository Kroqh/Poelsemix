press_meeting = press_meeting or class({})
LinkLuaModifier("press_meeting_pull", "heroes/hero_mette/press_meeting", LUA_MODIFIER_MOTION_NONE)

function press_meeting:GetCustomCastError()
	return "NOT IN CENTER"
end

function press_meeting:CastFilterResult()
	if IsServer() then
		local caster = self:GetCaster()
		local distance = (caster:GetAbsOrigin() - Vector(0,0)):Length2D()

		if distance <= self:GetSpecialValueFor("distance_to_center_req") or caster:HasScepter() then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end




function press_meeting:OnSpellStart()
    if not IsServer() then return end
    caster = self:GetCaster()
    for _, enemy in pairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),  nil, FIND_UNITS_EVERYWHERE, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
        if enemy:IsRealHero() then

            enemy:AddNewModifier(caster, self, "press_meeting_pull", {} )
        end
    end

    EmitSoundOn("mette_chirp", caster)
    EmitSoundOn("mette_press", caster)
end





press_meeting_pull = class ({})

function press_meeting_pull:IsPurgable() return	false end
function press_meeting_pull:IsHidden() return	false end
function press_meeting_pull:IgnoreTenacity() return true end
function press_meeting_pull:IsMotionController() return true end
function press_meeting_pull:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end



function press_meeting_pull:CheckState() --otherwise dash is cancelable, dont want that, needs no unit collision to not get caught at the end of dash
	if IsServer() then
		local state = {	[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true }
		return state
	end
end




function press_meeting_pull:OnCreated()
	if not IsServer() then return end
		local caster = self:GetCaster()
		local ability = self:GetAbility()
        local parent = self:GetParent()

        local origin = parent:GetAbsOrigin()
        local vector_between =  origin - Vector(0,0)


        parent:SetAbsOrigin(Vector(origin.x, origin.y, 350))
        self.direction = -(vector_between):Normalized()

        self.max_range_from_center = ability:GetSpecialValueFor("enemy_placement_from_center")

        self.distance = (origin - (self.direction*self.max_range_from_center)):Length2D()
        print(self.distance)
		
		self.velocity = ability:GetSpecialValueFor("pull_speed")
		self.distance_traveled = 0
		

        self.scaler = self:GetAbility():GetSpecialValueFor("mink_scaler")
        if self:GetCaster():FindAbilityByName("special_bonus_mette_8"):GetLevel() > 0 then self.scaler = self.scaler + self:GetCaster():FindAbilityByName("special_bonus_mette_8"):GetSpecialValueFor("value") end

		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)
end

function press_meeting_pull:OnIntervalThink()
	if IsServer() then

        local length =  (self:GetParent():GetAbsOrigin() - Vector(0,0)):Length2D()

		if not self:CheckMotionControllers() or length <= self.max_range_from_center then
			self:Destroy()
			return nil
		end
        
        
		self:HorizontalMotion(self:GetParent(), self.frametime)
	end
end



function press_meeting_pull:HorizontalMotion(me, dt)
	if IsServer() then
		local parent = self:GetParent()
        particle_rose_fx2 = ParticleManager:CreateParticle("particles/heroes/mette/rose_bed.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:SetParticleControl(particle_rose_fx2, 0, parent:GetAbsOrigin())
		if self.distance_traveled < self.distance then
			parent:SetAbsOrigin(parent:GetAbsOrigin() + self.direction * self.velocity * dt)
			self.distance_traveled = self.distance_traveled + self.velocity * dt
		else
			self:Destroy()
		end
	end
end

function press_meeting_pull:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
        local parent = self:GetParent()
        EmitSoundOn("mette_chirp", parent)
        
        caster:FindModifierByName("modifier_mink_passive"):SpawnMink(self.scaler,parent)
	end
end
