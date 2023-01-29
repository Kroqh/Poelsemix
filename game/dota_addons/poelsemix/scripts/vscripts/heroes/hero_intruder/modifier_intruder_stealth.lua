modifier_intruder_stealth = modifier_intruder_stealth or class({})

function modifier_intruder_stealth:IsPurgeable() return false end
function modifier_intruder_stealth:IsDebuff() return false end
function modifier_intruder_stealth:IsHidden() return true end

function modifier_intruder_stealth:DeclareFunctions()
	local decFuncs = {
	MODIFIER_PROPERTY_INVISIBILITY_LEVEL, 
	MODIFIER_EVENT_ON_ATTACK,
	MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
	return decFuncs
end

function modifier_intruder_stealth:GetModifierInvisibilityLevel()
	if IsClient() then
		return 1
	end
end
function modifier_intruder_stealth:OnAttack(keys)
	if IsServer() then
		if keys.attacker ~= self:GetParent() then return end
		self:Destroy()
	end
end

function modifier_intruder_stealth:OnAbilityExecuted(keys)
	if IsServer() then
		if keys.ability:GetCaster() ~= self:GetParent() then return end
		self:Destroy()
	end
end

function modifier_intruder_stealth:CheckState()
	if IsServer() then
		local state = {[MODIFIER_STATE_INVISIBLE] = true}
		return state
	end
end