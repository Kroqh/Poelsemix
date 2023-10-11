LinkLuaModifier("modifier_damian_penjamin", "heroes/hero_damian/damian_penjamin", LUA_MODIFIER_MOTION_NONE)

damian_penjamin = damian_penjamin or class({})

function damian_penjamin:OnToggle()
	if not IsServer() then return end

	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_damian_penjamin", {} )
	else
		self:GetCaster():RemoveModifierByNameAndCaster("modifier_damian_penjamin", self:GetCaster())
	end
end

modifier_damian_penjamin = modifier_damian_penjamin or class({})


function modifier_damian_penjamin:IsHidden() 				return true end
function modifier_damian_penjamin:IsPurgable() 				return false end


function modifier_damian_penjamin:OnCreated()
	if not IsServer() then return end
    local ability = self:GetAbility()
    local tick_rate = ability:GetSpecialValueFor("tick_rate")
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_damian_3") then tick_rate = tick_rate + caster:FindAbilityByName("special_bonus_damian_3"):GetSpecialValueFor("value") end
    self.mana_cost = ability:GetSpecialValueFor("mana_per_sec") * tick_rate
    self:StartIntervalThink(tick_rate)
end


function modifier_damian_penjamin:OnIntervalThink()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local mana_after == caster:GetMana() - self.mana_cost
	if mana_after == 0 then
		caster:SetMana(0)
        ability:ToggleAbility()
	elseif mana_after < 0 then
        ability:ToggleAbility()
        return
    else
		caster:SetMana(mana_after)
	end

    caster:Heal(ability:GetSpecialValueFor("hp_restore_per_tick"),ability)

    caster:EmitSound("damian_exhale")
    self.partfire = "particles/units/heroes/hero_winter_wyvern/wyvern_taunt_ring_smoke.vpcf"
    self.pfx = ParticleManager:CreateParticle(self.partfire, PATTACH_CENTER_FOLLOW, self:GetCaster())


    mod= caster:FindModifierByName("modifier_damian_faded")
    mod:SetStackCount(mod:GetStackCount()+ability:GetSpecialValueFor("faded_stack_per_tick"))

    if caster:HasTalent("special_bonus_damian_3") then
        local tick_rate = ability:GetSpecialValueFor("tick_rate") + caster:FindAbilityByName("special_bonus_damian_3"):GetSpecialValueFor("value")
        self:StartIntervalThink(tick_rate)
        self.mana_cost = ability:GetSpecialValueFor("mana_per_sec")  * tick_rate 
    end

end