LinkLuaModifier("modifier_obelix", "heroes/hero_asterix/hero_ax", LUA_MODIFIER_MOTION_NONE)
ax_obelix = class({})

function ax_obelix:OnSpellStart() 
    if IsServer() then
		local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        caster:AddNewModifier(caster, self, "modifier_obelix", {duration = duration})
       
        
    end
end


modifier_obelix = class({})
function modifier_obelix:IsPurgeable() return false end

function modifier_obelix:OnCreated()
    local caster = self:GetCaster()
     caster:SetModelScale(1.6)
       
end
function modifier_obelix:DeclareFunctions()
	local decFuncs = 
		{--MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
	return decFuncs
end
--function modifier_obelix:GetModifierBaseAttack_BonusDamage()
--	return self:GetAbility():GetSpecialValueFor("adamage")
--end
function modifier_obelix:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("move_slow")
end

function modifier_obelix:OnDestroy()
    local caster = self:GetCaster()
        caster:SetModelScale(0.6)
end