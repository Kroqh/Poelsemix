LinkLuaModifier("modifier_blinding_dart_blind", "heroes/hero_teemo/teemo_blinding_dart", LUA_MODIFIER_MOTION_NONE)
blinding_dart = blinding_dart or class({})

function blinding_dart:GetAbilityTextureName()
	return "blinding_dart"
end

function blinding_dart:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local particle = "particles/units/heroes/hero_venomancer/venomancer_base_attack.vpcf"
		local speed = 1300
		local int_scaling_talent = caster:FindAbilityByName("special_bonus_teemo_3"):GetSpecialValueFor("value")
		CustomNetTables:SetTableValue("player_table", "blinding_dart", {int_scaling_talent = int_scaling_talent})

		local dart = 
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
				ExtraData = {}
			}
		ProjectileManager:CreateTrackingProjectile(dart)
		EmitSoundOn("teemo_blindingdart", caster)
	end
end

function blinding_dart:OnProjectileHit(target)
	if not target then
		return nil 
	end

	local caster = self:GetCaster()
	local intellect = caster:GetIntellect(true)
	local int_scaling = self:GetSpecialValueFor("int_scaling")
	if caster:HasTalent("special_bonus_teemo_3") then
		local int_talent = CustomNetTables:GetTableValue("player_table", "blinding_dart").int_scaling_talent
		--print(int_talent)
		local int_scaling = int_scaling + int_talent
	end

	local damage = self:GetSpecialValueFor("damage") + intellect*int_scaling
	local duration = self:GetSpecialValueFor("duration")

	ApplyDamage({victim = target,
	attacker = caster,
	damage_type = self:GetAbilityDamageType(),
	damage = damage,
	ability = self})
	
	target:AddNewModifier(caster, self, "modifier_blinding_dart_blind", {duration = duration})
end

modifier_blinding_dart_blind = class({})

function modifier_blinding_dart_blind:IsDebuff() return true end

function modifier_blinding_dart_blind:OnCreated()
	if IsServer() then
		EmitSoundOn("teemo_blindingdart_oh", self:GetParent())
	end
end

function modifier_blinding_dart_blind:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MISS_PERCENTAGE}
	return decFuncs
end

function modifier_blinding_dart_blind:GetModifierMiss_Percentage()
	return self:GetAbility():GetSpecialValueFor("miss_chance")
end