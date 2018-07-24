--hurtigbrille

LinkLuaModifier("modifier_hurtigbrille", "heroes/hero_brian/hero_brian", LUA_MODIFIER_MOTION_NONE)
hurtigbrille = class({})

function hurtigbrille:OnSpellStart()
    if IsServer() then
		local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        
        caster:AddNewModifier(caster, self, "modifier_hurtigbrille", {duration = duration})
        caster:EmitSound("woosh_brian") 
    end
end

modifier_hurtigbrille = class({})

function modifier_hurtigbrille:IsBuff() return true end

function modifier_hurtigbrille:DeclareFunctions()

    local decFuncs =
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS

    }
    return decFuncs
end

function modifier_hurtigbrille:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end
function modifier_hurtigbrille:GetModifierBonusStats_Agility()
    return self.agi
end
function modifier_hurtigbrille:OnCreated()

        local move_up_self = self:GetAbility():GetSpecialValueFor("move_up_self")
        self.movespeed = move_up_self
        local agibuff = self:GetAbility():GetSpecialValueFor("aspeed")
        self.agi = agibuff
        
        self.partfire = "particles/econ/items/invoker/glorious_inspiration/invoker_forge_spirit_ambient_esl_fire.vpcf"
		self.pfx = ParticleManager:CreateParticle(self.partfire, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
end
function modifier_hurtigbrille:OnDestroy()
ParticleManager:DestroyParticle(self.pfx, false)
end
