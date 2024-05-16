stewart_en_med_guldringen = stewart_en_med_guldringen or class({})

LinkLuaModifier( "modifier_stewart_guldring", "heroes/hero_stewart/stewart_en_med_guldringen", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stewart_guldring_active", "heroes/hero_stewart/stewart_en_med_guldringen", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- Passive Modifier
function stewart_en_med_guldringen:GetIntrinsicModifierName()
	return "modifier_stewart_guldring"
end

function stewart_en_med_guldringen:GetCooldown(level)
    local cd = self.BaseClass.GetCooldown(self,level)
    if self:GetCaster():FindAbilityByName("special_bonus_stewart_3"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_stewart_3"):GetSpecialValueFor("value") end
    return cd
end


function stewart_en_med_guldringen:Apply(parent)
	parent:AddNewModifier(parent, self, "modifier_stewart_guldring_active", {})
end
modifier_stewart_guldring = modifier_stewart_guldring or class({})

function modifier_stewart_guldring:IsPassive() return true end

function modifier_stewart_guldring:IsHidden() return true end

function modifier_stewart_guldring:IsPurgable() return false end

function modifier_stewart_guldring:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end



function modifier_stewart_guldring:OnIntervalThink()
    if not IsServer() then return end
    if self:GetAbility():IsCooldownReady() and not self:GetParent():HasModifier("modifier_stewart_guldring_active") then self:GetAbility():Apply(self:GetParent()) end
end




modifier_stewart_guldring_active = modifier_stewart_guldring_active or class({})


function modifier_stewart_guldring_active:IsHidden() return false end
function modifier_stewart_guldring_active:IsPurgable() return false end

function modifier_stewart_guldring_active:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_START
	}

	return funcs
end




function modifier_stewart_guldring_active:OnAttackStart( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
		if self:GetParent():PassivesDisabled() then return end
		if params.target:IsOther() or params.attacker:IsBuilding() then return end
        self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_1)
        self:GetParent():EmitSound("stewart_heavy_hit") 
    end

end

function modifier_stewart_guldring_active:GetEffectName()
    return "particles/units/heroes/hero_primal_beast/primal_beast_uproar_hands_power_up_energy.vpcf"
end

function modifier_stewart_guldring_active:OnAttackLanded( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
        
		if self:GetParent():PassivesDisabled() then return end
		if params.target:IsOther() or params.attacker:IsBuilding() then return end
		
		-- damage
        local str_scale = self:GetAbility():GetSpecialValueFor("str_to_damage")
        if self:GetCaster():FindAbilityByName("special_bonus_stewart_5"):GetLevel() > 0 then str_scale = str_scale + self:GetCaster():FindAbilityByName("special_bonus_stewart_5"):GetSpecialValueFor("value") end 
		
        local damage = self:GetParent():GetAttackDamage()
        local damage = self:GetParent():GetStrength() * str_scale
        
        local damageTable = {
			victim = params.target,
			attacker = self:GetParent(),
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}
        ApplyDamage(damageTable)

        local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
        if self:GetCaster():FindAbilityByName("special_bonus_stewart_2"):GetLevel() > 0 then stun_duration = stun_duration + self:GetCaster():FindAbilityByName("special_bonus_stewart_2"):GetSpecialValueFor("value") end 

        params.target:AddNewModifier(self:GetParent(), self, "modifier_stunned", {duration = stun_duration})
		-- cooldown
		if not self:GetParent():HasModifier("modifier_stewart_jul_invis") then self:GetAbility():UseResources(false, false, false, true ) end
        self:Destroy()

	end
end
