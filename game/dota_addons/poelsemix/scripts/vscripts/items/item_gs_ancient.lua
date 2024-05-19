item_gs_ancient = item_gs_ancient or class({})

LinkLuaModifier("modifier_item_gs_ancient", "items/item_gs_ancient", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_gs_ancient_mark", "items/item_gs_ancient", LUA_MODIFIER_MOTION_NONE)

function item_gs_ancient:GetIntrinsicModifierName()
	return "modifier_item_gs_ancient"
end

function item_gs_ancient:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self
        local target = self:GetCursorTarget()
        local sound_cast = "godsword_slash"    
        local particle_slash = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_counter_slash.vpcf"
        local modifier_mark = "modifier_item_gs_ancient_mark"

        -- Ability specials
        local mark_duration = ability:GetSpecialValueFor("mark_duration")

        EmitSoundOn(sound_cast, target)


        local particle_slash_fx = ParticleManager:CreateParticle(particle_slash, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(particle_slash_fx, 0, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_slash_fx)

        local damageTable = {
            victim = target,
            attacker = self:GetCaster(),
            damage = self:GetSpecialValueFor("active_damage"),
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self
        }

        ApplyDamage(damageTable)

        if target:IsAlive() then
            target:AddNewModifier(caster, ability, modifier_mark, {duration = mark_duration})
        end
    end

end

modifier_item_gs_ancient = modifier_item_gs_ancient or class({})
function modifier_item_gs_ancient:IsHidden()			return true end
function modifier_item_gs_ancient:IsPurgable()		return false end
function modifier_item_gs_ancient:RemoveOnDeath()	return false end
function modifier_item_gs_ancient:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_gs_ancient:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_item_gs_ancient:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("int")
	end
end
function modifier_item_gs_ancient:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("damage")
    end
end




modifier_item_gs_ancient_mark = modifier_item_gs_ancient_mark or class({})


function modifier_item_gs_ancient_mark:IsHidden() return false end
function modifier_item_gs_ancient_mark:IsPurgeException() return true end
function modifier_item_gs_ancient_mark:IsDebuff() return true end

function modifier_item_gs_ancient_mark:GetStatusEffectName()
	return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end
function modifier_item_gs_ancient_mark:GetStatusEffectPriority()
	return 9
end
function modifier_item_gs_ancient_mark:OnCreated()
    if IsServer() then
        self.formerpos = self:GetParent():GetAbsOrigin()
        self.dist_moved = 0
        self.dist_to_move = self:GetAbility():GetSpecialValueFor("dist_to_move")
        self:StartIntervalThink(0.1)
    end
end

function modifier_item_gs_ancient_mark:GetTexture()
    return "gs_ancient"
end
function modifier_item_gs_ancient_mark:OnIntervalThink()
    if IsServer() then
        local dis = (self.formerpos-self:GetParent():GetAbsOrigin()):Length2D()
        self.dist_moved = self.dist_moved + dis
        self.formerpos = self:GetParent():GetAbsOrigin()
        if (self.dist_moved > self.dist_to_move) then
            local particle_cleanse = "particles/econ/items/templar_assassin/ta_2022_immortal/ta_2022_immortal_trap_gold_ring_inner_start.vpcf"
            local particle_cleanse_fx = ParticleManager:CreateParticle(particle_cleanse, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(particle_cleanse_fx, 0, self:GetParent():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle_cleanse_fx)
            self:GetParent():RemoveModifierByNameAndCaster("modifier_item_gs_ancient_mark", self.caster)
        end
    end
end

function modifier_item_gs_ancient_mark:OnRemoved()
    if IsServer() then
        if self.dist_moved > self.dist_to_move then
            return 
        end
        local damageTable = {victim = self:GetParent(),
            damage = self:GetAbility():GetSpecialValueFor("bonus_magic_damage"),
            damage_type = DAMAGE_TYPE_MAGICAL,
            attacker = self:GetCaster(),
            ability = self:GetAbility()
        }
        ApplyDamage(damageTable)
        self:GetCaster():Heal(self:GetAbility():GetSpecialValueFor("bonus_self_heal"), self:GetAbility())
        EmitSoundOn("blood_splatter_gs", self:GetParent())

        local particle_slash = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_counter_slash.vpcf"
        local particle_slash_fx = ParticleManager:CreateParticle(particle_slash, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(particle_slash_fx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_slash_fx)
        local particle_blood = "particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_r_backstab_hit_blood.vpcf"
        local particle_blood_fx = ParticleManager:CreateParticle(particle_blood, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(particle_blood_fx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_blood_fx)
    end
end

