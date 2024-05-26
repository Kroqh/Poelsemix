LinkLuaModifier("modifier_musashi_wind_dash", "heroes/hero_musashi/musashi_wind", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_musashi_wind_ms", "heroes/hero_musashi/musashi_wind", LUA_MODIFIER_MOTION_NONE)
musashi_wind = musashi_wind or class({})



function musashi_wind:GetCastRange()
	if IsClient() then --global range for server, but range visible for player
		local range = self:GetSpecialValueFor("range")
		if self:GetCaster():FindAbilityByName("special_bonus_musashi_2"):GetLevel() > 0 then range = range + self:GetCaster():FindAbilityByName("special_bonus_musashi_2"):GetSpecialValueFor("value") end
		return range
	end
end

function musashi_wind:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_musashi_wind_dash", {})
    
end

function musashi_wind:OnAbilityPhaseStart() 
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)
	local caster = self:GetCaster()
	local point = caster:GetCursorPosition()
	local direction = (point - caster:GetAbsOrigin()):Normalized()
	caster:SetForwardVector(direction)

	return true
end

modifier_musashi_wind_dash = modifier_musashi_wind_dash or  class ({})

function modifier_musashi_wind_dash:IsPurgable() return	false end
function modifier_musashi_wind_dash:IsHidden() return	true end
function modifier_musashi_wind_dash:IgnoreTenacity() return true end
function modifier_musashi_wind_dash:IsMotionController() return true end
function modifier_musashi_wind_dash:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_musashi_wind_dash:CheckState() --otherwise dash is cancelable, dont want that - needs no unit collision to not get caught at the end of dash
	if IsServer() then
		local state = {	[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]  = true}
		return state
	end
end

function modifier_musashi_wind_dash:OnCreated()
	if not IsServer() then return end
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		caster:EmitSound("musashi_wind")
		local max_distance = ability:GetSpecialValueFor("range") + caster:GetCastRangeBonus()

		if caster:HasTalent("special_bonus_musashi_2") then
			local bonus_range = caster:FindAbilityByName("special_bonus_musashi_2"):GetSpecialValueFor("value")
			max_distance = max_distance + bonus_range
		end
		
		local distance = (caster:GetAbsOrigin() - caster:GetCursorPosition() ):Length2D()
		if distance > max_distance then distance = max_distance end
		self.direction = ( caster:GetCursorPosition() - caster:GetAbsOrigin() ):Normalized()
		self.velocity = ability:GetSpecialValueFor("velocity")
		self.distance_traveled = 0
		self.distance = distance

		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)
		
end

function modifier_musashi_wind_dash:OnIntervalThink()
	if IsServer() then
		if not self:CheckMotionControllers() then
			self:Destroy()
			return nil
		end
		self:HorizontalMotion(self:GetParent(), self.frametime)
	end
end

function modifier_musashi_wind_dash:HorizontalMotion(me, dt)
	if IsServer() then
		local caster = self:GetCaster()

		if self.distance_traveled < self.distance then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + self.direction * self.velocity * dt)
			self.distance_traveled = self.distance_traveled + self.velocity * dt
        else
			duration = self:GetAbility():GetSpecialValueFor("duration_movement_speed")

			if caster:HasTalent("special_bonus_musashi_1") then duration = duration + caster:FindAbilityByName("special_bonus_musashi_1"):GetSpecialValueFor("value") end
			
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_musashi_wind_ms", {duration = duration})
			self:Destroy()	
    	end
		
	end
end
function modifier_musashi_wind_dash:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end



function modifier_musashi_wind_dash:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()

		Timers:CreateTimer(0.1, function()

			-- Stop the casting animation and remove caster modifier
			caster:FadeGesture(ACT_DOTA_CAST_ABILITY_3)
		end)
	end
end

modifier_musashi_wind_ms = modifier_musashi_wind_ms or class({})

function modifier_musashi_wind_ms:IsPurgable() return	true end
function modifier_musashi_wind_ms:IsDebuff() return false end

function modifier_musashi_wind_ms:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return decFuncs
end

function modifier_musashi_wind_ms:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movement_speed_percent")
end

function modifier_musashi_wind_ms:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun_magic_trail.vpcf"
end

function modifier_musashi_wind_ms:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


