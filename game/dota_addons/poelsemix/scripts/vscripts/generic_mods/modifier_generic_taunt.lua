modifier_generic_taunt = modifier_generic_taunt or class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_taunt:IsHidden()
    if not IsServer() then end
	return  self.is_hidden
end

function modifier_generic_taunt:IsDebuff()
	return true
end

function modifier_generic_taunt:IsStunDebuff()
	return false
end

function modifier_generic_taunt:IsPurgable()
    if not IsServer() then end
	return self.is_purgeable
end

--------------------------------------------------------------------------------
-- Initializations, takes optional target, status effect, status_priority, is_hidden, is_purgeable (is_hidden not working it seems)
function modifier_generic_taunt:OnCreated(kv)
    self.is_hidden = kv.is_hidden
    if not self.is_hidden then
        self.is_hidden = false
    end
    if IsServer() then
        self.taunt_target = kv.taunt_target
        self.status_priority = kv.status_priority
        self.status_effect = kv.status_effect
        
        self.is_purgeable = kv.is_purgeable

        if not self.is_purgeable then
            self.is_purgeable = false
        end
       
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