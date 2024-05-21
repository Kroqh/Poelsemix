herobrine_grief = herobrine_grief or class({})
LinkLuaModifier( "modifier_herobrine_grief_passive", "heroes/hero_herobrine/herobrine_grief", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_herobrine_grief_bomb", "heroes/hero_herobrine/herobrine_grief", LUA_MODIFIER_MOTION_NONE )

function herobrine_grief:GetIntrinsicModifierName()
	return "modifier_herobrine_grief_passive"
end


function herobrine_grief:PlantTNT(enemy, planted_directly)

    local scaling = self:GetSpecialValueFor("explosion_int_damage_scaling")
    if self:GetCaster():FindAbilityByName("special_bonus_herobrine_4"):GetLevel() > 0 then scaling = scaling + self:GetCaster():FindAbilityByName("special_bonus_herobrine_4"):GetSpecialValueFor("value") end
    local dmg = self:GetSpecialValueFor("explosion_damage") + (scaling * self:GetCaster():GetIntellect())
    if (enemy:HasModifier("modifier_herobrine_grief_bomb")) then
        enemy:FindModifierByName("modifier_herobrine_grief_bomb"):TriggerExplosion()
    else
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_herobrine_grief_bomb", {dmg = dmg, planted_directly = planted_directly} )
    end
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
    self:GetAbility():PlantTNT(params.target, true)
end


modifier_herobrine_grief_bomb = modifier_herobrine_grief_bomb  or class({})

function modifier_herobrine_grief_bomb:IsDebuff() return true end
function modifier_herobrine_grief_bomb:IsHidden() return false end
function modifier_herobrine_grief_bomb:IsPurgable() return true end



function modifier_herobrine_grief_bomb:OnCreated(keys)
    if not IsServer() then return end
    self.chain = false 
    if keys.planted_directly == 1 and self:GetCaster():FindAbilityByName("special_bonus_herobrine_5"):GetLevel() > 0 then
        self.chain = true
    end
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
        if self.chain == true and enemy ~= parent then
            self:GetAbility():PlantTNT(enemy, false)
        end
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