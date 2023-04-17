LinkLuaModifier("modifier_spinning_demon_cast", "heroes/hero_kazuya/kazuya_spinning_demon", LUA_MODIFIER_MOTION_NONE)
kazuya_spinning_demon = kazuya_spinning_demon or class({})

function kazuya_spinning_demon:OnSpellStart()
	local caster = self:GetCaster()
	local fury_cost  = self:GetSpecialValueFor("fury_cost")
	if caster:HasTalent("special_bonus_kazuya_4") then fury_cost = fury_cost + caster:FindAbilityByName("special_bonus_kazuya_4"):GetSpecialValueFor("value") end
	caster:FindModifierByName("modifier_kazuya_rage_fury_handler"):ChangeFury(-fury_cost, false)
    caster:AddNewModifier(caster, self, "modifier_spinning_demon_cast", {})
    
end

function kazuya_spinning_demon:OnAbilityPhaseStart() 
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
	return true
end

function kazuya_spinning_demon:GetCustomCastErrorLocation()
	local caster = self:GetCaster()
	local fury_cost  = self:GetSpecialValueFor("fury_cost")
	if caster:HasTalent("special_bonus_kazuya_4") then fury_cost = fury_cost + caster:FindAbilityByName("special_bonus_kazuya_4"):GetSpecialValueFor("value") end
	return string.format("Fury needed: %s", fury_cost)
end

function kazuya_spinning_demon:CastFilterResultLocation()
	if IsServer() then
		local caster = self:GetCaster()
		local fury_cost  = self:GetSpecialValueFor("fury_cost")
		if caster:HasTalent("special_bonus_kazuya_4") then fury_cost = fury_cost + caster:FindAbilityByName("special_bonus_kazuya_4"):GetSpecialValueFor("value") end
		if caster:FindModifierByName("modifier_kazuya_rage_fury_handler"):GetEnoughFury(fury_cost) then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end


modifier_spinning_demon_cast = class ({})

function modifier_spinning_demon_cast:IsPurgable() return	false end
function modifier_spinning_demon_cast:IsHidden() return	true end
function modifier_spinning_demon_cast:IgnoreTenacity() return true end
function modifier_spinning_demon_cast:IsMotionController() return true end
function modifier_spinning_demon_cast:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_spinning_demon_cast:CheckState()
	if IsServer() then
		local state = {	[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true, }
		return state
	end
end




function modifier_spinning_demon_cast:OnCreated()
	if not IsServer() then return end
		self.hasdamaged = false
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		caster:EmitSound("kazuya_spinning_demon")

		local max_distance = ability:GetSpecialValueFor("range")

		local distance = (caster:GetAbsOrigin() - caster:GetCursorPosition() ):Length2D()
		if distance > max_distance then distance = max_distance end

		self.direction = ( caster:GetCursorPosition() - caster:GetAbsOrigin() ):Normalized()
		self.velocity = ability:GetSpecialValueFor("velocity")
		self.distance_traveled = 0
		self.distance = distance

		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)
end

function modifier_spinning_demon_cast:OnIntervalThink()
	if IsServer() then
		if not self:CheckMotionControllers() then
			self:Destroy()
			return nil
		end

		self:HorizontalMotion(self:GetParent(), self.frametime)
	end
end


function modifier_spinning_demon_cast:GetEffectName()
	return "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_blade_fury_disk.vpcf"
end
function modifier_spinning_demon_cast:HorizontalMotion(me, dt)
	if IsServer() then
		local caster = self:GetCaster()

		if self.distance_traveled < self.distance then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + self.direction * self.velocity * dt)
			self.distance_traveled = self.distance_traveled + self.velocity * dt
		else
			self:Destroy()
		end

        if not self.hasdamaged and self.distance_traveled > (self.distance * 0.45) then
    		local ability = self:GetAbility()
			local target_teams = DOTA_UNIT_TARGET_TEAM_ENEMY 
			local target_types = DOTA_UNIT_TARGET_ALL 
			local target_flags = DOTA_UNIT_TARGET_FLAG_NONE 
			local radius = ability:GetSpecialValueFor("radius")

			local str_scale = ability:GetSpecialValueFor("strength_scaling")
			if caster:HasTalent("special_bonus_kazuya_6") then str_scale = str_scale + caster:FindAbilityByName("special_bonus_kazuya_6"):GetSpecialValueFor("value") end
			local damage = ability:GetSpecialValueFor("damage") + (caster:GetStrength() * str_scale)


			local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, target_teams, target_types, target_flags, FIND_CLOSEST, false)
			for _, enemy in  pairs(units) do
				ApplyDamage({victim = enemy, attacker = caster, damage_type = ability:GetAbilityDamageType(), damage = damage, ability = ability})
    		end
			self.hasdamaged = true
		end
	end
end

function modifier_spinning_demon_cast:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()

		Timers:CreateTimer(0.1, function()

			-- Stop the casting animation and remove caster modifier
			caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
		end)
	end
end