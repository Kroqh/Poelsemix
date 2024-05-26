LinkLuaModifier("modifier_raio_afterimage_dash", "heroes/hero_raio/raio_afterimage", LUA_MODIFIER_MOTION_NONE)
raio_afterimage = raio_afterimage or class({})



function raio_afterimage:GetCastRange()
	if IsClient() then --global range for server, but range visible for player
		local range = self:GetSpecialValueFor("range")
		return range
	end
end

function raio_afterimage:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_raio_afterimage_dash", {})
    
end

function raio_afterimage:DoImage()
	local caster = self:GetCaster()

	local outgoing = self:GetSpecialValueFor("afterimage_dmg_percent")
	local incoming = self:GetSpecialValueFor("afterimage_taken_percent")
	local duration = self:GetSpecialValueFor("afterimage_duration")
	if self:GetCaster():FindAbilityByName("special_bonus_raio_1"):GetLevel() > 0 then duration = duration + self:GetCaster():FindAbilityByName("special_bonus_raio_1"):GetSpecialValueFor("value") end

    local images = CreateIllusions(self:GetCaster(), self:GetCaster(), {
		outgoing_damage 			= outgoing,
		incoming_damage				= incoming,
		duration					= duration
	}, 1, self:GetCaster():GetHullRadius(), true, true)

	local unstable = caster:FindAbilityByName("raio_unstable")

	for i = 1, #images do
		images[i]:AddNewModifier(caster, unstable, "modifier_raio_unstable_passive", {outgoings = outgoing})
	end
    
end



function raio_afterimage:OnAbilityPhaseStart() 
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)
	local caster = self:GetCaster()
	local point = caster:GetCursorPosition()
	local direction = (point - caster:GetAbsOrigin()):Normalized()
	caster:SetForwardVector(direction)

	return true
end

modifier_raio_afterimage_dash = modifier_raio_afterimage_dash or  class ({})

function modifier_raio_afterimage_dash:IsPurgable() return	false end
function modifier_raio_afterimage_dash:IsHidden() return	true end
function modifier_raio_afterimage_dash:IgnoreTenacity() return true end
function modifier_raio_afterimage_dash:IsMotionController() return true end
function modifier_raio_afterimage_dash:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_raio_afterimage_dash:CheckState() --otherwise dash is cancelable, dont want that - needs no unit collision to not get caught at the end of dash
	if IsServer() then
		local state = {	[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]  = true}
		return state
	end
end

function modifier_raio_afterimage_dash:OnCreated()
	if not IsServer() then return end
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		caster:EmitSound("raio_afterimage")
		caster:EmitSound("Hero_StormSpirit.BallLightning.Loop")
		ability:DoImage()
		local max_distance = ability:GetSpecialValueFor("range") + caster:GetCastRangeBonus()
		
		local distance = (caster:GetAbsOrigin() - caster:GetCursorPosition() ):Length2D()
		if distance > max_distance then distance = max_distance end
		self.direction = ( caster:GetCursorPosition() - caster:GetAbsOrigin() ):Normalized()
		self.velocity = ability:GetSpecialValueFor("velocity")
		self.distance_traveled = 0
		self.distance = distance

		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)
		
end

function modifier_raio_afterimage_dash:OnIntervalThink()
	if IsServer() then
		if not self:CheckMotionControllers() then
			self:Destroy()
			return nil
		end
		self:HorizontalMotion(self:GetParent(), self.frametime)
	end
end

function modifier_raio_afterimage_dash:HorizontalMotion(me, dt)
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
function modifier_raio_afterimage_dash:GetEffectName()
	return "particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf"
end
function modifier_raio_afterimage_dash:GetEffectAttachType()
	return PATTACH_ROOTBONE_FOLLOW
end


function modifier_raio_afterimage_dash:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		caster:StopSound("Hero_StormSpirit.BallLightning.Loop")

		if self:GetCaster():FindAbilityByName("special_bonus_raio_7"):GetLevel() > 0 then
			self:GetAbility():DoImage()
		end

		Timers:CreateTimer(0.1, function()

			-- Stop the casting animation and remove caster modifier
			caster:FadeGesture(ACT_DOTA_CAST_ABILITY_3)
		end)
	end
end
