
LinkLuaModifier("modifier_move_quick_passive", "heroes/hero_teemo/teemo_move_quick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_move_quick_handler", "heroes/hero_teemo/teemo_move_quick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_move_quick_active", "heroes/hero_teemo/teemo_move_quick", LUA_MODIFIER_MOTION_NONE)
move_quick = move_quick or class({})

function move_quick:GetAbilityTextureName()
	return "move_quick"
end

function move_quick:GetIntrinsicModifierName()
	return "modifier_move_quick_handler"
end

function move_quick:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")

		local particle = "particles/econ/events/ti7/phase_boots_ti7.vpcf"
		local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx)

		caster:AddNewModifier(caster, self, "modifier_move_quick_active", {duration = duration})
		EmitSoundOn("teemo_movequick", caster)
	end
end

modifier_move_quick_active = modifier_move_quick_active or class({})

function modifier_move_quick_active:OnCreated()
    if not IsServer() then return end
	local ability = self:GetAbility()
    local caster = self:GetCaster()
    local multiplier = ability:GetSpecialValueFor("multiplier")
    if caster:HasTalent("special_bonus_teemo_8") then multiplier = multiplier + caster:FindAbilityByName("special_bonus_teemo_8"):GetSpecialValueFor("value") end
	self.movespeed = ability:GetSpecialValueFor("movement_speed") * multiplier
end

function modifier_move_quick_active:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}	
	return decFuncs
end

function modifier_move_quick_active:GetModifierMoveSpeedBonus_Percentage()
    if not IsServer() then return end
	return self.movespeed
end

modifier_move_quick_handler = class({})

function modifier_move_quick_handler:IsHidden() return true end

function modifier_move_quick_handler:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.counter = 5
		self:StartIntervalThink(0.1)
		if self.has_been_attacked == nil then
			self.has_been_attacked = false
		end

		if caster:HasModifier("modifier_move_quick_passive") then
			caster:RemoveModifierByName("modifier_move_quick_passive")
		end

		caster:AddNewModifier(caster, ability, "modifier_move_quick_passive", {})
	end
end

function modifier_move_quick_handler:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ATTACKED}
	return decFuncs
end

function modifier_move_quick_handler:OnAttacked(keys)
	if IsServer() then
		if keys.target == self:GetParent() then
			self.counter = 0
		end
	end
end

function modifier_move_quick_handler:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		self.counter = self.counter + 0.1

		if self.counter < 5 then
			if caster:HasModifier("modifier_move_quick_passive") then
				caster:RemoveModifierByName("modifier_move_quick_passive")
			end
		elseif caster:HasModifier("modifier_move_quick_active") then
			if caster:HasModifier("modifier_move_quick_passive") then
				caster:RemoveModifierByName("modifier_move_quick_passive")
			end
		else
			caster:AddNewModifier(caster, ability, "modifier_move_quick_passive", {})
		end
	end
end

modifier_move_quick_passive = class({})

function modifier_move_quick_passive:IsPurgeable() return false end
function modifier_move_quick_passive:IsBuff() return true end

function modifier_move_quick_passive:OnCreated()
	local ability = self:GetAbility()
	self.movespeed = ability:GetSpecialValueFor("movement_speed")
	--print(self.movespeed)
end

function modifier_move_quick_passive:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return decFuncs
end

function modifier_move_quick_passive:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end
