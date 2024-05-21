LinkLuaModifier("modifier_marvelous_reptil_unit_information", "heroes/hero_marvelous/marvelous_koldblodet_reptil", LUA_MODIFIER_MOTION_NONE)
marvelous_koldblodet_reptil = marvelous_koldblodet_reptil or class({})

function marvelous_koldblodet_reptil:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local particle = "particles/heroes/hero_marvelous/marvelous_reptil.vpcf"
		local speed = self:GetSpecialValueFor("proj_speed")

		local bullet = 
			{
				Target = target,
				Source = caster,
				Ability = self,
				EffectName = particle,
				iMoveSpeed = speed,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				ExtraData = {}
			}
		ProjectileManager:CreateTrackingProjectile(bullet)
		EmitSoundOn("koldblodet", caster)
	end
end

function marvelous_koldblodet_reptil:OnProjectileHit(target, location)
	if not target then
		return nil 
	end

	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("lifetime")
	local ability = self


	local agi = caster:GetAgility()
    local dmg_scaling = ability:GetSpecialValueFor("agi_to_damage")
    local hp_scaling = ability:GetSpecialValueFor("agi_to_hp")

	if self:GetCaster():FindAbilityByName("special_bonus_marvelous_3"):GetLevel() > 0 then dmg_scaling = dmg_scaling + self:GetCaster():FindAbilityByName("special_bonus_marvelous_3"):GetSpecialValueFor("value") end 


	local dmg = math.floor(agi * dmg_scaling)
    local hp = math.floor(agi * hp_scaling)--minks have 1 hp by defeault as to not insta die
	count = 0
	total_units = 1
	if self:GetCaster():FindAbilityByName("special_bonus_marvelous_8"):GetLevel() > 0 then total_units = total_units + self:GetCaster():FindAbilityByName("special_bonus_marvelous_8"):GetSpecialValueFor("value") end 

	while(count < total_units) do

		unit = CreateUnitByName("npc_koldblodet_reptil",location, true, caster, nil, caster:GetTeam())
		unit:AddNewModifier(caster, ability, "modifier_kill", { duration = ability:GetSpecialValueFor("lifetime") } )
		unit:AddNewModifier(caster, ability, "modifier_marvelous_reptil_unit_information", {dmg = dmg} )
		unit:SetTeam(caster:GetTeamNumber())
		unit:SetOwner(caster)
		unit:SetBaseMaxHealth(hp)
		unit:SetMaxHealth(hp)
		unit:SetHealth(hp) --has to have this ugly trio for it to work lol
		unit:AddNewModifier(target, self, "modifier_generic_taunt", {})
		count = count + 1
	end


	local damage = self:GetSpecialValueFor("proj_damage")

	ApplyDamage({victim = target,
	attacker = caster,
	damage_type = self:GetAbilityDamageType(),
	damage = damage,
	ability = self})
	
	
end

modifier_marvelous_reptil_unit_information = modifier_marvelous_reptil_unit_information  or class({})


function modifier_marvelous_reptil_unit_information:IsPurgable() return false end
function modifier_marvelous_reptil_unit_information:IsHidden() return true end

function modifier_marvelous_reptil_unit_information:OnCreated(kv)
	if not IsServer() then return end
    self.dmg = kv.dmg
end

function modifier_marvelous_reptil_unit_information:DeclareFunctions()
	local decFuncs = {
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
}
    return decFuncs
end


function modifier_marvelous_reptil_unit_information:GetModifierBaseAttack_BonusDamage()
    if not IsServer() then return end
    return self.dmg
end