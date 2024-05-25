LinkLuaModifier("shimakaze_modifier_wave_cast", "heroes/hero_shimakaze/shimakaze_wave", LUA_MODIFIER_MOTION_NONE)
shimakaze_wave = shimakaze_wave or class({})


function shimakaze_wave:GetCastRange()
	if IsClient() then --global range for server, but range visible for player
		local range = self:GetSpecialValueFor("range")
		if self:GetCaster():FindAbilityByName("special_bonus_shimakaze_1"):GetLevel() > 0 then range = range + self:GetCaster():FindAbilityByName("special_bonus_shimakaze_1"):GetSpecialValueFor("value") end
		return range
	end
end
function shimakaze_wave:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "shimakaze_modifier_wave_cast", {})
	caster:EmitSound("shimakaze_wave")
end

function shimakaze_wave:OnAbilityPhaseStart() 
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)
	return true
end

shimakaze_modifier_wave_cast = shimakaze_modifier_wave_cast or class ({})


function shimakaze_modifier_wave_cast:IsPurgable() return	false end
function shimakaze_modifier_wave_cast:IsHidden() return	true end
function shimakaze_modifier_wave_cast:IgnoreTenacity() return true end
function shimakaze_modifier_wave_cast:IsMotionController() return true end
function shimakaze_modifier_wave_cast:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function shimakaze_modifier_wave_cast:CheckState() --otherwise dash is cancelable, dont want that, needs no unit collision to not get caught at the end of dash
	if IsServer() then
		local state = {	[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true, }
		return state
	end
end

function shimakaze_modifier_wave_cast:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local max_distance = ability:GetSpecialValueFor("range") + caster:GetCastRangeBonus()
		if caster:HasTalent("special_bonus_shimakaze_1") then
			local bonus_range = caster:FindAbilityByName("special_bonus_shimakaze_1"):GetSpecialValueFor("value")
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
end

function shimakaze_modifier_wave_cast:OnIntervalThink()
	if IsServer() then
		if not self:CheckMotionControllers() then
			self:Destroy()
			return nil
		end

		self:HorizontalMotion(self:GetParent(), self.frametime)
	end
end

function shimakaze_modifier_wave_cast:HorizontalMotion(me, dt)
	if IsServer() then
		local caster = self:GetCaster()

		if self.distance_traveled < self.distance then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + self.direction * self.velocity * dt)
			self.distance_traveled = self.distance_traveled + self.velocity * dt
		else
			self:Destroy()
		end
	end
end

function shimakaze_modifier_wave_cast:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()

		Timers:CreateTimer(0.1, function()

			-- Stop the casting animation and remove caster modifier
			caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
		end)
	end
end