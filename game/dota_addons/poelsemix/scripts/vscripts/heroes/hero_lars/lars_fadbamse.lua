
LinkLuaModifier("modifier_lars_fadbamse", "heroes/hero_lars/lars_fadbamse", LUA_MODIFIER_MOTION_NONE)
lars_fadbamse = lars_fadbamse or class({})

function lars_fadbamse:OnSpellStart()
    if  not IsServer() then return end
    local caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    caster:EmitSound("LarsBeer1")
    

end


function lars_fadbamse:OnChannelFinish(interrupted)
    if  not IsServer() then return end
    local caster = self:GetCaster()
    if  interrupted then
        caster:StopSound("LarsBeer1")
        return 
    end
    
    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_lars_fadbamse", {duration = duration})
    caster:EmitSound("LarsBeer2")
end

modifier_lars_fadbamse = modifier_lars_fadbamse or class({})


function modifier_lars_fadbamse:IsHidden() return false end
function modifier_lars_fadbamse:IsPurgable() return false end

function modifier_lars_fadbamse:OnCreated(kv)
    if not IsServer() then return end
    self:GetParent():MoveToTargetToAttack(self:GetAbility().target)
    
    self:StartIntervalThink(0.1) 
	
end
function modifier_lars_fadbamse:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():MoveToTargetToAttack(self:GetAbility().target)
    ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_bubbles.vpcf",PATTACH_CENTER_FOLLOW,self:GetParent())
    if not self:GetAbility().target:IsAlive() then self:GetParent():RemoveModifierByName("modifier_lars_fadbamse") end
end



function modifier_lars_fadbamse:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, 
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, 
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, 
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
	}
end

function modifier_lars_fadbamse:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return state
end
function modifier_lars_fadbamse:OnRemoved()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
	end
end
function modifier_lars_fadbamse:GetModifierIgnoreMovespeedLimit()
    return 1
end
function modifier_lars_fadbamse:GetStatusEffectName() return "particles/status_fx/status_effect_beserkers_call.vpcf" end
function modifier_lars_fadbamse:StatusEffectPriority() return 3 end

function modifier_lars_fadbamse:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_lars_fadbamse:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_dmg") end
function modifier_lars_fadbamse:GetModifierMoveSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_speed") end