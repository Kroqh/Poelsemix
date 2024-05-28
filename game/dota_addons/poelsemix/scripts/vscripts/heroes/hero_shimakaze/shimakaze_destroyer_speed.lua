LinkLuaModifier("shimakaze_modifier_destroyer_speed_passive", "heroes/hero_shimakaze/shimakaze_destroyer_speed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shimakaze_modifier_destroyer_speed_active", "heroes/hero_shimakaze/shimakaze_destroyer_speed", LUA_MODIFIER_MOTION_NONE)

shimakaze_destroyer_speed = shimakaze_destroyer_speed or class({})



function shimakaze_destroyer_speed:GetIntrinsicModifierName() 
	return "shimakaze_modifier_destroyer_speed_passive"
end

function shimakaze_destroyer_speed:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier_stack_count = caster:FindModifierByName("shimakaze_modifier_destroyer_speed_passive"):GetStackCount()
		local duration = self:GetSpecialValueFor("duration")

		caster:FindModifierByName("shimakaze_modifier_destroyer_speed_passive"):SetStackCount(0)
		
		caster:AddNewModifier(caster, self, "shimakaze_modifier_destroyer_speed_active", {duration = duration})
		
		self:EmitSound("shimakaze_ossoi")
	end
end

function shimakaze_destroyer_speed:CastFilterResult()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier_stack_count = caster:FindModifierByName("shimakaze_modifier_destroyer_speed_passive"):GetStackCount()
		local stack_count = self:GetSpecialValueFor("max_stacks")
		if self:GetCaster():FindAbilityByName("special_bonus_shimakaze_2"):GetLevel() > 0 then stack_count = stack_count + self:GetCaster():FindAbilityByName("special_bonus_shimakaze_2"):GetSpecialValueFor("value") end
	
		if modifier_stack_count >= stack_count then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end

function shimakaze_destroyer_speed:GetCustomCastError()
	return "Not enough stacks"
end

shimakaze_modifier_destroyer_speed_active = shimakaze_modifier_destroyer_speed_active or class({})

function shimakaze_modifier_destroyer_speed_active:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed")
end

function shimakaze_modifier_destroyer_speed_active:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return decFuncs
end


function shimakaze_modifier_destroyer_speed_active:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

shimakaze_modifier_destroyer_speed_passive = shimakaze_modifier_destroyer_speed_passive or class({})

function shimakaze_modifier_destroyer_speed_passive:IsPureable() return false end
function shimakaze_modifier_destroyer_speed_passive:IsPassive() return true end

function shimakaze_modifier_destroyer_speed_passive:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()

		self.startPos = self:GetCaster():GetAbsOrigin()
		self.stacks = 0
		self.max_stacks = ability:GetSpecialValueFor("max_stacks")
		self:StartIntervalThink(0.1)
	end
end

function shimakaze_modifier_destroyer_speed_passive:OnIntervalThink()
	if IsServer() then
		local caster_pos = self:GetCaster():GetAbsOrigin()
		local stacks = self:GetStackCount()
		
		if caster_pos ~= self.startPos and stacks < self.max_stacks then
			if self:GetCaster():FindAbilityByName("special_bonus_shimakaze_2"):GetLevel() > 0 then self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks") + self:GetCaster():FindAbilityByName("special_bonus_shimakaze_2"):GetSpecialValueFor("value") end
			local distance = FindDistance(caster_pos, self.startPos)
			local stacks_to_add = math.floor(distance/10)
			--print(stacks_to_add)

			if self:GetStackCount() + stacks_to_add > self.max_stacks then
				self:SetStackCount(self.max_stacks)
			else
				self:SetStackCount(stacks + math.floor(distance / 10))
			end
		end
		
		self.startPos = caster_pos
	end
end
