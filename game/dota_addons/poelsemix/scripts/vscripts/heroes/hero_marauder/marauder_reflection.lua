LinkLuaModifier("modifier_marauder_reflection_handler", "heroes/hero_marauder/marauder_reflection", LUA_MODIFIER_MOTION_NONE)
marauder_reflection = marauder_reflection or class({})


function marauder_reflection:OnSpellStart() 
	local caster = self:GetCaster()
	local amount = self:GetSpecialValueFor("clone_amount")
	self:SummonClone(amount)
end

function marauder_reflection:SummonClone(count)
	local caster = self:GetCaster()

	local outgoing = self:GetSpecialValueFor("clone_dmg_percent")
	local incoming = self:GetSpecialValueFor("clone_taken_percent")
	local duration = self:GetSpecialValueFor("clone_duration")
    local images = CreateIllusions(self:GetCaster(), self:GetCaster(), {
		outgoing_damage 			= outgoing,
		incoming_damage				= incoming,
		duration					= duration
	}, count, self:GetCaster():GetHullRadius() + 30, true, true)

	for i = 1, #images do
		images[i]:AddNewModifier(caster, caster:FindAbilityByName("marauder_cyclone"), "modifier_marauder_cyclone", {outgoing = (1 + (outgoing/100))}) --outgoing = outgoing
		images[i]:AddNewModifier(caster, self, "modifier_marauder_reflection_handler", {})
	end
end

modifier_marauder_reflection_handler = modifier_marauder_reflection_handler or class({})

function modifier_marauder_reflection_handler:IsPurgable() return false end
function modifier_marauder_reflection_handler:IsDebuff() return	false end
function modifier_marauder_reflection_handler:IsHidden() return true end

function modifier_marauder_reflection_handler:IsPassive() return true end

function modifier_marauder_reflection_handler:CheckState()
	local state = {
	    [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_UNSELECTABLE] = true
	}
	return state
end

function modifier_marauder_reflection_handler:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_marauder_reflection_handler:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_marauder_blood_rage") and not parent:HasModifier("modifier_marauder_blood_rage") then  caster:FindAbilityByName("marauder_blood_rage"):ApplyRage(parent, caster:FindModifierByName("modifier_marauder_blood_rage"):GetRemainingTime()) end

	local ability = self:GetAbility()
	local radius = self:GetAbility():GetSpecialValueFor("clone_seekout_range")

		local enemies = FindUnitsInRadius(
			parent:GetTeamNumber(), 
			parent:GetAbsOrigin(), 
			nil, 
			radius, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
			FIND_CLOSEST, 
			false
		)

	local nonhero = {}
	local final_targets = {}
	if #enemies > 0 then
		for _, target in pairs(enemies) do
			if target:IsHero() then --shitty prioritise hero function
				table.insert(final_targets, target)
			else
				table.insert(nonhero, target)
			end
			if #final_targets >= 1 then break end
		end
		
		if 1 > #final_targets then
			for _, target in pairs(nonhero) do --if not enough heroes, target other
				table.insert(final_targets, target)
				if #final_targets >= 1 then break end
			end
		end
	end
	if #final_targets > 0 then
		parent:MoveToNPC(final_targets[1])
	end
end