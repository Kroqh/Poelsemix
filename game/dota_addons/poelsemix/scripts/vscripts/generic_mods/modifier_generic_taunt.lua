modifier_generic_taunt = modifier_generic_taunt or class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_taunt:IsHidden()
	return false
end

function modifier_generic_taunt:IsDebuff()
	return true
end

function modifier_generic_taunt:IsStunDebuff()
	return false
end

function modifier_generic_taunt:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations, takes optional target, status effect, status_priority
function modifier_generic_taunt:OnCreated(kv)
    if IsServer() then
        self.taunt_target = kv.taunt_target
        self.status_priority = kv.status_priority
        self.status_effect = kv.status_effect

        if not self.status_priority then
            self.status_priority = 1
        end
        if not self.status_effect then
            self.status_effect= "particles/status_fx/status_effect_beserkers_call.vpcf"
        end
        if not self.taunt_target then
            self:GetParent():SetForceAttackTarget( self:GetCaster() ) -- for creeps
            self:GetParent():MoveToTargetToAttack( self:GetCaster() ) -- for heroes
        else
            self:GetParent():SetForceAttackTarget( taunt_target ) -- for creeps
            self:GetParent():MoveToTargetToAttack( taunt_target ) -- for heroes
        end
	end
end

function modifier_generic_taunt:OnRefresh()
end

function modifier_generic_taunt:OnRemoved()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
	end
end

function modifier_generic_taunt:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_generic_taunt:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations --better hope this is precached lol
function modifier_generic_taunt:GetStatusEffectName()
	return self.status_effect
end
function modifier_generic_taunt:StatusEffectPriority()
	return self.status_priority
end