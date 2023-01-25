drift = class({})

function drift:GetCastPoint()
	local caster = self:GetCaster()

	return self:GetSpecialValueFor("cast_point")
end

function drift:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target_pos = self:GetCursorPosition()
		local caster_pos = caster:GetAbsOrigin()

		local dash_length = self:GetSpecialValueFor("dash_length")
		local dash_width = self:GetSpecialValueFor("dash_width")
		local dash_duration = self:GetSpecialValueFor("dash_duration")

		local direction = (target_pos - caster_pos):Normalized()

		caster:SetForwardVector(direction)

		local start_time = GameRules:GetGameTime()

		local forward_direction = caster:GetForwardVector()
		local right_direction = caster:GetRightVector()
		local caster_angles = caster:GetAngles()

		local ellipse_center = caster_pos + forward_direction * (dash_length / 2)

		local dummy_modifier = "modifier_drift_dummy"
		caster:AddNewModifier(caster, self, dummy_modifier, {duration = dash_duration})

		caster:SetContextThink(DoUniqueString("drift_update"), function ( )

			local elapsed_time = GameRules:GetGameTime() - start_time
			local progress = elapsed_time / dash_duration

			self.progress = progress

			if not caster:HasModifier(dummy_modifier) then
				return nil 
			end

			local theta = -2 * math.pi * progress
			local x = math.sin(theta) * dash_width * 0.5
			local y = math.cos(theta) * dash_length * 0.5

			local pos = ellipse_center + right_direction  * x + forward_direction * y
			local yaw = caster_angles.y + 90 + progress * -360

			pos = GetGroundPosition(pos, caster)

			caster:SetAbsOrigin(pos)
			caster:SetAngles(caster_angles.x, yaw, caster_angles.y)

			GridNav:DestroyTreesAroundPoint(pos, 80, false)

			return 0.03


			end, 0)
	end
end