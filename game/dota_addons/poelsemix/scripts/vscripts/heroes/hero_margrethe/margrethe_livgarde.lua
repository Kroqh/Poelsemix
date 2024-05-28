margrethe_livgarde = margrethe_livgarde or class({})
LinkLuaModifier( "modifier_margrethe_livgarde_unit_information", "heroes/hero_margrethe/margrethe_livgarde", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_margrethe_livgarde_stack_handler", "heroes/hero_margrethe/margrethe_livgarde", LUA_MODIFIER_MOTION_NONE )


function margrethe_livgarde:GetIntrinsicModifierName()
	return "modifier_margrethe_livgarde_stack_handler"
end


function margrethe_livgarde:OnSpellStart()
    if not IsServer() then return end
    local target_point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local ability = self
    local damage = caster:GetAttackDamage()
    local base_dmg = ability:GetSpecialValueFor("base_dmg")
    local dmg_scaling = ability:GetSpecialValueFor("dmg_to_dmg_scaling")
    local hp_scaling = ability:GetSpecialValueFor("hp_to_hp_scaling")
    local ms = ability:GetSpecialValueFor("ms")
    

    local dmg = base_dmg + math.floor(damage * dmg_scaling)
    local hp = math.floor(caster:GetMaxHealth() * hp_scaling)
    unit = CreateUnitByName("npc_queens_knight",target_point, true, caster, nil, caster:GetTeam())

    unit:AddNewModifier(caster, ability, "modifier_kill", { duration = ability:GetSpecialValueFor("lifetime") } )
    unit:AddNewModifier(caster, ability, "modifier_margrethe_livgarde_unit_information", {dmg = dmg, ms = ms} )
	unit:SetTeam(caster:GetTeamNumber())
	unit:SetOwner(caster)
    unit:SetBaseMaxHealth(hp)
    unit:SetMaxHealth(hp)
    unit:SetHealth(hp) --has to have this ugly trio for it to work lol
    unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)

    EmitSoundOn("margrethe_giv_agt", unit)


    local modifier_stacks = caster:FindModifierByName("modifier_margrethe_livgarde_stack_handler"):GetStackCount()
	caster:FindModifierByName("modifier_margrethe_livgarde_stack_handler"):SetStackCount(modifier_stacks - 1)
end

function margrethe_livgarde:CastFilterResultLocation()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier_stack_count = caster:FindModifierByName("modifier_margrethe_livgarde_stack_handler"):GetStackCount()

		if modifier_stack_count >= 1 then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end

function margrethe_livgarde:GetCustomCastErrorLocation()
	return "NO KNIGHTS AVAILABLE"
end


modifier_margrethe_livgarde_unit_information = modifier_margrethe_livgarde_unit_information  or class({})


function modifier_margrethe_livgarde_unit_information:IsPurgable() return false end
function modifier_margrethe_livgarde_unit_information:IsHidden() return true end

function modifier_margrethe_livgarde_unit_information:OnCreated(kv)
	if not IsServer() then return end
    self.dmg = kv.dmg
    self.ms = kv.ms
    self:SetHasCustomTransmitterData(true)
end

function modifier_margrethe_livgarde_unit_information:DeclareFunctions()
	local decFuncs = {
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
}
    return decFuncs
end


function modifier_margrethe_livgarde_unit_information:AddCustomTransmitterData()
    return {
        ms = self.ms,
        dmg = self.dmg

    }
end

function modifier_margrethe_livgarde_unit_information:HandleCustomTransmitterData( data )
    self.dmg = data.dmg
    self.ms = data.ms

end


function modifier_margrethe_livgarde_unit_information:GetModifierBaseAttack_BonusDamage()
    return self.dmg
end
function modifier_margrethe_livgarde_unit_information:GetModifierMoveSpeedBonus_Constant()
    return self.ms
end


modifier_margrethe_livgarde_stack_handler = modifier_margrethe_livgarde_stack_handler or class({})

function modifier_margrethe_livgarde_stack_handler:IsDebuff() 	return false end
function modifier_margrethe_livgarde_stack_handler:IsHidden() 	return false end
function modifier_margrethe_livgarde_stack_handler:IsPassive() 	return true end
function modifier_margrethe_livgarde_stack_handler:IsPurgable() return false end

function modifier_margrethe_livgarde_stack_handler:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local lol = 0

		if lol == 0 then
			local caster = self:GetCaster()
			self:SetStackCount(1)
			lol = 1
		end
		self.count = 0
		self:StartIntervalThink(0.1)
	end
end

function modifier_margrethe_livgarde_stack_handler:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()

		local max_stacks = ability:GetSpecialValueFor("max_charges")
		if self:GetCaster():FindAbilityByName("special_bonus_margrethe_5"):GetLevel() > 0 then max_stacks = max_stacks + self:GetCaster():FindAbilityByName("special_bonus_margrethe_5"):GetSpecialValueFor("value") end 
		local charge_time = ability:GetSpecialValueFor("charge_time")
		if self:GetCaster():FindAbilityByName("special_bonus_margrethe_6"):GetLevel() > 0 then charge_time = charge_time + self:GetCaster():FindAbilityByName("special_bonus_margrethe_6"):GetSpecialValueFor("value") end 

		if self:GetStackCount() == max_stacks then
			self.count = 0
		end

		if self.count >= charge_time then
			self.count = 0
			if self:GetStackCount() < max_stacks then
				self:SetStackCount(self:GetStackCount() + 1)
			end
		end

		self.count = self.count + 0.1
	end
end
