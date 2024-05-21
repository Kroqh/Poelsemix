herobrine_grief = herobrine_grief or class({})
LinkLuaModifier( "modifier_herobrine_grief_passive", "heroes/hero_herobrine/herobrine_grief", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_herobrine_grief_bomb", "heroes/hero_herobrine/herobrine_grief", LUA_MODIFIER_MOTION_NONE )

function herobrine_grief:GetIntrinsicModifierName()
	return "modifier_herobrine_grief_passive"
end

modifier_herobrine_grief_passive = modifier_herobrine_grief_passive  or class({})


function modifier_herobrine_grief_passive:IsPurgable() return false end
function modifier_herobrine_grief_passive:IsHidden() return true end
function modifier_herobrine_grief_passive:IsPassive() return true end


function modifier_herobrine_grief_passive:DeclareFunctions()
	local decFuncs = {
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
}
    return decFuncs
end

function modifier_herobrine_grief_passive:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("as_bonus")
end
function modifier_herobrine_grief_passive:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("attack_damage_removal")
end

function modifier_herobrine_grief_passive:OnAttackLanded( params )
	if not IsServer() then return end
	if (params.attacker ~= self:GetParent()) then return end 
    local dmg = self:GetAbility():GetSpecialValueFor("explosion_damage") + (self:GetAbility():GetSpecialValueFor("explosion_int_damage_scaling") * self:GetParent():GetIntellect())
    if (params.target:HasModifier("modifier_herobrine_grief_bomb")) then
        params.target:FindModifierByName("modifier_herobrine_grief_bomb"):TriggerExplosion()
    else
        params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_herobrine_grief_bomb", {dmg = dmg} )
    end

    
    
	
end


modifier_herobrine_grief_bomb = modifier_herobrine_grief_bomb  or class({})

function modifier_herobrine_grief_bomb:IsDebuff() return true end
function modifier_herobrine_grief_bomb:IsHidden() return false end
function modifier_herobrine_grief_bomb:IsPurgable() return true end



function modifier_herobrine_grief_bomb:OnCreated(keys)
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("explosion_delay"))
    self.dmg = keys.dmg
    self:GetParent():EmitSound("herobrine_tnt_click")
end

function modifier_herobrine_grief_bomb:OnIntervalThink()
	if not IsServer() then return end
    self:TriggerExplosion()
end

function modifier_herobrine_grief_bomb:TriggerExplosion()
	if not IsServer() then return end

    --caster is bomb planter, bomb target is parent
    local caster = self:GetCaster()
	local ability = self:GetAbility()
    local caster_loc = caster:GetAbsOrigin()
    local parent = self:GetParent()
	local explosion_radius = ability:GetSpecialValueFor("explosion_size")

    self:GetParent():StopSound("herobrine_tnt_click")
 

    local bomb_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:ReleaseParticleIndex(bomb_fx)
    local units = FindUnitsInRadius(caster:GetTeamNumber(), parent:GetAbsOrigin(), nil, explosion_radius, ability:GetAbilityTargetTeam(), 
    ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    parent:EmitSound("Hero_Techies.Suicide")
         
    for _, enemy in pairs(units) do
        ApplyDamage({victim = enemy, attacker = caster, damage_type = ability:GetAbilityDamageType(), damage = self.dmg, ability = ability})
    end

    parent:StopSound("herobrine_tnt_click")
    self:Destroy()
end

function modifier_herobrine_grief_bomb:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_herobrine_grief_bomb:GetEffectName()
	return "particles/units/heroes/hero_herobrine/herobrine_explosion_mark.vpcf"
end