modifier_bonus_to_stealth_passive = class({})
LinkLuaModifier( "modifier_bonus_to_stealth_invis", "heroes/hero_shadow/bonus_to_stealth/modifier_bonus_to_stealth_invis", LUA_MODIFIER_MOTION_NONE )

function modifier_bonus_to_stealth_passive:IsPurgeable() return false end
function modifier_bonus_to_stealth_passive:IsHidden() return true end

function modifier_bonus_to_stealth_passive:OnCreated()
	print("passive created")
	if IsServer() then
		self.wait = self:GetAbility():GetSpecialValueFor("fade_delay")
		self.count = 0
		self:StartIntervalThink(0.1)
	end
end

function modifier_bonus_to_stealth_passive:OnRefresh()
	if IsServer() then
		self.wait = self:GetAbility():GetSpecialValueFor("fade_delay")
	end
end

function modifier_bonus_to_stealth_passive:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
	return decFuncs
end
function modifier_bonus_to_stealth_passive:GetModifierIncomingDamage_Percentage(params)
	if IsServer() then
		local parent = self:GetParent()
		if params.target == parent then 
			self.count = 0
			if parent:HasModifier("modifier_bonus_to_stealth_invis") then
				parent:RemoveModifierByName("modifier_bonus_to_stealth_invis")
			end
		end
	end
end



function modifier_bonus_to_stealth_passive:OnAttackStart(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.attacker == parent then
			self.count = 0
            if parent:HasModifier("modifier_bonus_to_stealth_invis") then
                parent:RemoveModifierByName("modifier_bonus_to_stealth_invis")
            end
		end
	end
end

function modifier_bonus_to_stealth_passive:OnAbilityExecuted(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.unit == parent then
			self.count = 0
		end
	end
end

function modifier_bonus_to_stealth_passive:OnIntervalThink()
	if IsServer() then
		if self.count >= self.wait then
			local caster = self:GetParent()
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_bonus_to_stealth_invis", {})
            self.count = 0
        end

		self.count = self.count + 0.1
	end
end