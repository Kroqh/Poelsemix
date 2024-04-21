LinkLuaModifier("modifier_gunpowder", "heroes/hero_baseboys/baseboys_gunpowder", LUA_MODIFIER_MOTION_NONE)
baseboys_gunpowder = baseboys_gunpowder or class({})

function baseboys_gunpowder:GetAbilityTextureName()
	return "gunpowder"
end

function baseboys_gunpowder:OnSpellStart()
	if IsServer() then
        local caster = self:GetCaster()
		caster:EmitSound("Hero_Sven.GodsStrength")
		self:ApplyDrink(caster)

        --TODO: Make concert members also drink
	end
end

function baseboys_gunpowder:ApplyDrink(drinker)
    
    local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
   
	drinker:EmitSound("gratisgunpowder")
    local roll = 4
    
    if drinker:HasModifier("modifier_gunpowder") then 
        drinker:RemoveModifierByName("modifier_gunpowder")
    end --ensure proper refresh if other drink is rolled

    if caster:FindAbilityByName("special_bonus_baseboys_8"):GetLevel() == 0 then --roll if no talent
	    roll = math.random(3)
    end

    
    if roll == 1 then 
        caster:AddNewModifier(caster, self, "modifier_gunpowder", {duration = duration, type = 1}) 
        local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_baseboys/gunpower_red.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	    ParticleManager:SetParticleControl(pfx, 0, drinker:GetAbsOrigin())
    elseif roll == 2 then 
        caster:AddNewModifier(caster, self, "modifier_gunpowder", {duration = duration, type = 2}) 
        local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_baseboys/gunpower_green.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	    ParticleManager:SetParticleControl(pfx, 0, drinker:GetAbsOrigin())
    elseif roll == 3 then 
        caster:AddNewModifier(caster, self, "modifier_gunpowder", {duration = duration, type = 3}) 
        local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_baseboys/gunpower_blue.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	    ParticleManager:SetParticleControl(pfx, 0, drinker:GetAbsOrigin())
    elseif roll == 4 then 
        caster:AddNewModifier(caster, self, "modifier_gunpowder", {duration = duration, type = 4}) 
        local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_baseboys/gunpower_rainbow.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	    ParticleManager:SetParticleControl(pfx, 0, drinker:GetAbsOrigin())

    end
end

modifier_gunpowder = modifier_gunpowder or class({})

function modifier_gunpowder:OnCreated(keys)
    if IsServer() then
        
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local scale = ability:GetSpecialValueFor("model_scale")
        local main_stat = ability:GetSpecialValueFor("bonus_main_stat")
        self.bonus_strength = 0
        self.bonus_agility = 0
        self.bonus_intellect = 0
        self.bonus_armor = 0
        self.bonus_as = 0
        self.bonus_mr = 0
        self.type = keys.type
        if keys.type == 1 or keys.type == 4 then
            self.bonus_strength = main_stat
            if caster:HasScepter() then
                
                self.bonus_armor = ability:GetSpecialValueFor("aghs_red_armor")
            end
        end
        if keys.type == 2 or keys.type == 4 then
            --self.bonus_agility = main_stat
            if caster:HasScepter() then
                self.bonus_as = ability:GetSpecialValueFor("aghs_green_as")
            end
        end
        if keys.type == 3 or keys.type == 4 then
            self.bonus_intellect = main_stat
            if caster:HasScepter() then
                self.bonus_mr = ability:GetSpecialValueFor("aghs_blue_mr")
            end
        end
        
        self:SetHasCustomTransmitterData(true)
        
        if self.orig_size == nil then self.orig_size = caster:GetModelScale() end
        caster:SetModelScale(scale)
	end
end

--this is a server-only function that is called whenever modifier:SetHasCustomTransmitterData(true) is called,
-- and also whenever modifier:SendBuffRefreshToClients() is called
function modifier_gunpowder:AddCustomTransmitterData()
    return {
        str = self.bonus_strength,
        agi = self.bonus_agility,
        int = self.bonus_intellect,
        arm = self.bonus_armor,
        as = self.bonus_as,
        mr = self.bonus_mr,
        drink = self.type,
    }
end

--this is a client-only function that is called with the table returned by modifier:AddCustomTransmitterData()
function modifier_gunpowder:HandleCustomTransmitterData( data )
    self.bonus_strength = data.str
    self.bonus_agility = data.agi
    self.bonus_intellect = data.int
    self.bonus_armor = data.arm
    self.bonus_as = data.as
    self.bonus_mr = data.mr
    self.type = data.drink
end

function modifier_gunpowder:IsPurgable() return true end
function modifier_gunpowder:IsBuff() return true end

function modifier_gunpowder:DeclareFunctions()
	local decFuncs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS, 
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
	return decFuncs
end

function modifier_gunpowder:GetTexture()

    local image = "gunpowder"
    if self.type == 1 then 
        image = "gunpowder_red"
    elseif self.type == 2 then 
        image = "gunpowder_green"
    elseif self.type == 3 then 
        image ="gunpowder_blue"
    elseif self.type == 4 then 
        image = "gunpowder_rainbow"
    end
	return image
end

function modifier_gunpowder:GetModifierBonusStats_Strength()
	return self.bonus_strength
end
function modifier_gunpowder:GetModifierBonusStats_Agility()
	return self.bonus_agility
end
function modifier_gunpowder:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end
function modifier_gunpowder:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end
function modifier_gunpowder:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end
function modifier_gunpowder:GetModifierMagicalResistanceBonus()
	return self.bonus_mr
end

function modifier_gunpowder:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function modifier_gunpowder:StatusEffectPriority()
	return 10
end

function modifier_gunpowder:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		caster:SetModelScale(self.orig_size)
	end
end
