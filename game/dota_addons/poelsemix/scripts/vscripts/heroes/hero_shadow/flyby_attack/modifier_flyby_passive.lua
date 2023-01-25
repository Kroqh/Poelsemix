modifier_flyby_passive = class({})
LinkLuaModifier( "modifier_flyby_attack", "heroes/hero_shadow/flyby_attack/modifier_flyby_attack", LUA_MODIFIER_MOTION_NONE )

function modifier_flyby_passive :IsPurgeable() return false end
function modifier_flyby_passive :IsPassive() return true end
function modifier_flyby_passive :IsHidden() return true end

function modifier_flyby_passive :OnCreated()
	if IsServer() then
		self.wait = self:GetAbility():GetSpecialValueFor("teleport_cooldown")
		self.count = 0
		self:StartIntervalThink(0.1)
	end
end

function modifier_flyby_passive :OnRefresh()
	if IsServer() then
		self.wait = self:GetAbility():GetSpecialValueFor("teleport_cooldown")
	end
end

function modifier_flyby_passive :DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_EVENT_ON_ATTACK_START}
	return decFuncs
end

function modifier_flyby_passive:OnAttackStart(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.attacker == parent then
			
            if parent:HasModifier("modifier_flyby_attack") then
				count = 0
			end
		end
	end
end

function modifier_flyby_passive:OnAbilityExecuted(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.unit == parent then
			self.count = 0 --Ddunno what this does

			
		end
	end
end

function modifier_flyby_passive :OnIntervalThink()
	if IsServer() then
		if self.count >= self.wait then
			local caster = self:GetParent()
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_flyby_attack", {})
            self.count = 0
        end

		self.count = self.count + 0.1
	end
end