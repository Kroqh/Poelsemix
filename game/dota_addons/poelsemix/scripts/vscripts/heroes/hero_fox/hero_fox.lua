--Q



--W
-------------------------------------------
--      SPELL SHIELD
-------------------------------------------
-- Visible Modifiers:
LinkLuaModifier("modifier_imba_spell_shield_buff_reflect", "heroes/hero_fox/hero_fox", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spellshield_scepter_ready", "heroes/hero_fox/hero_fox", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spellshield_scepter_recharge", "heroes/hero_fox/hero_fox", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spell_shield_buff_passive", "heroes/hero_fox/hero_fox", LUA_MODIFIER_MOTION_NONE)

fox_shine = fox_shine or class({})

function fox_shine:GetAbilityTextureName()
	return "antimage_spell_shield"
end

function fox_shine:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

-- Declare active skill + visuals
function fox_shine:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local active_modifier = "modifier_imba_spell_shield_buff_reflect"
		self.duration = ability:GetSpecialValueFor("active_duration")

		-- Start skill cooldown.
		caster:AddNewModifier(caster, ability, active_modifier, {duration = self.duration})

		-- Run visual + sound
		local shield_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(shield_pfx)
		caster:EmitSound("Hero_Antimage.SpellShield.Block")
	end
end

-- Magic resistence modifier
function fox_shine:GetIntrinsicModifierName()
	return "modifier_imba_spell_shield_buff_passive"
end

function fox_shine:GetCooldown( nLevel )
	return self.BaseClass.GetCooldown( self, nLevel )
end

function fox_shine:IsHiddenWhenStolen()
	return false
end

local function SpellReflect(parent, params)
	-- If some spells shouldn't be reflected, enter it into this spell-list
	local exception_spell =
		{
			["rubick_spell_steal"] = true,
			["imba_alchemist_greevils_greed"] = true,
			["imba_alchemist_unstable_concoction"] = true,
			["imba_disruptor_glimpse"] = true,
		}

	local reflected_spell_name = params.ability:GetAbilityName()
	local target = params.ability:GetCaster()

	-- Does not reflect allies' projectiles for any reason
	if target:GetTeamNumber() == parent:GetTeamNumber() then
		return nil
	end

	-- FOR NOW, UNTIL LOTUS ORB IS DONE
	-- Do not reflect spells if the target has Lotus Orb on, otherwise the game will die hard.
	if target:HasModifier("modifier_item_lotus_orb_active") then
		return nil
	end

	if ( not exception_spell[reflected_spell_name] ) and (not target:HasModifier("modifier_imba_spell_shield_buff_reflect")) then

		-- If this is a reflected ability, do nothing
		if params.ability.spell_shield_reflect then
			return nil
		end

		local reflect_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(reflect_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(reflect_pfx)

		local old_spell = false
		for _,hSpell in pairs(parent.tOldSpells) do
			if hSpell ~= nil and hSpell:GetAbilityName() == reflected_spell_name then
				old_spell = true
				break
			end
		end
		if old_spell then
			ability = parent:FindAbilityByName(reflected_spell_name)
		else
			ability = parent:AddAbility(reflected_spell_name)
			ability:SetStolen(true)
			ability:SetHidden(true)

			-- Tag ability as a reflection ability
			ability.spell_shield_reflect = true

			-- Modifier counter, and add it into the old-spell list
			ability:SetRefCountsModifiers(true)
			table.insert(parent.tOldSpells, ability)
		end

		ability:SetLevel(params.ability:GetLevel())
		-- Set target & fire spell
		parent:SetCursorCastTarget(target)
		ability:OnSpellStart()
		target:EmitSound("Hero_Antimage.SpellShield.Reflect")
	end
	return false
end

local function SpellAbsorb(parent)
	local reflect_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(reflect_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetOrigin(), true)
	ParticleManager:ReleaseParticleIndex(reflect_pfx)
	return 1
end

modifier_imba_spell_shield_buff_passive = modifier_imba_spell_shield_buff_passive or class({})

function modifier_imba_spell_shield_buff_passive:IsHidden()
	return true
end

function modifier_imba_spell_shield_buff_passive:IsDebuff()
	return false
end

function modifier_imba_spell_shield_buff_passive:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_PROPERTY_REFLECT_SPELL
	}
	return decFuncs
end

function modifier_imba_spell_shield_buff_passive:OnCreated()
	--	if self:GetCaster():IsIllusion() then
	--		print("Removing buff from an illusion..") -- CRASH WITH NEW MANTA LUA
	--		self:Destroy()
	--		return
	--	end
	self.magic_resistance = self:GetAbility():GetSpecialValueFor("magic_resistance")

	if IsServer() then
		self.duration = self:GetAbility():GetSpecialValueFor("active_duration")
		self.spellshield_max_distance = self:GetAbility():GetSpecialValueFor("spellshield_max_distance")
		self.internal_cooldown = self:GetAbility():GetSpecialValueFor("internal_cooldown")
		self.modifier_ready = "modifier_imba_spellshield_scepter_ready"
		self.modifier_recharge = "modifier_imba_spellshield_scepter_recharge"

		-- Add the scepter modifier
		if not self:GetParent():HasModifier(self.modifier_ready) then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), self.modifier_ready, {})
		end

		self:GetParent().tOldSpells = {}

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_spell_shield_buff_passive:OnRefresh()
	self:OnCreated()
end

function modifier_imba_spell_shield_buff_passive:GetModifierMagicalResistanceBonus(params)
	return self.magic_resistance
end

function modifier_imba_spell_shield_buff_passive:GetReflectSpell( params )
	if IsServer() then
		local parent = self:GetParent()
		if not self:GetParent():PassivesDisabled() then

			-- If the targets are too far apart, do nothing
			local distance = (parent:GetAbsOrigin() - params.ability:GetCaster():GetAbsOrigin()):Length2D()
			if distance > self.spellshield_max_distance then
				return nil
			end

			-- Apply the spell reflect
			return SpellReflect(parent, params)
		end
	end
end

function modifier_imba_spell_shield_buff_passive:GetAbsorbSpell( params )
	if IsServer() then
		local parent = self:GetParent()
		if not self:GetParent():PassivesDisabled() then
			-- Start the internal recharge modifier
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), self.modifier_recharge, {duration = self.internal_cooldown})

			-- Apply Spell Absorption
			return SpellAbsorb(parent)
		end
	end
end

function modifier_imba_spell_shield_buff_passive:OnDestroy()
	-- If for some reason this modifier is destroyed (Rubick losing it, for instance), remove the scepter modifier
	if IsServer() then
		if self:GetParent():HasModifier(self.modifier_ready) then
			self:GetParent():RemoveModifierByName(self.modifier_ready)
		end
	end
end

-- Reflect modifier
-- Biggest thanks to Yunten !
modifier_imba_spell_shield_buff_reflect = modifier_imba_spell_shield_buff_reflect or class({})

function modifier_imba_spell_shield_buff_reflect:IsHidden()
	return false
end

function modifier_imba_spell_shield_buff_reflect:IsDebuff()
	return false
end

function modifier_imba_spell_shield_buff_reflect:IsPurgable()
	return false
end

function modifier_imba_spell_shield_buff_reflect:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_PROPERTY_REFLECT_SPELL
	}
	return decFuncs
end

-- Initialize old-spell-checker
function modifier_imba_spell_shield_buff_reflect:OnCreated( params )
	if IsServer() then

	end
end

function modifier_imba_spell_shield_buff_reflect:GetReflectSpell( params )
	if IsServer() then
		if not self:GetParent():PassivesDisabled() then
			return SpellReflect(self:GetParent(), params)
		end
	end
end

function modifier_imba_spell_shield_buff_reflect:GetAbsorbSpell( params )
	if IsServer() then
		if not self:GetParent():PassivesDisabled() then
			return SpellAbsorb(self:GetParent())
		end
	end
end

-- Deleting old abilities
-- This is bound to the passive modifier, so this is constantly on!
function modifier_imba_spell_shield_buff_passive:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		for i=#caster.tOldSpells,1,-1 do
			local hSpell = caster.tOldSpells[i]
			if hSpell:NumModifiersUsingAbility() == 0 and not hSpell:IsChanneling() then
				hSpell:RemoveSelf()
				table.remove(caster.tOldSpells,i)
			end
		end
	end
end



-- Scepter block Ready modifier
modifier_imba_spellshield_scepter_ready = modifier_imba_spellshield_scepter_ready or class({})

function modifier_imba_spellshield_scepter_ready:IsHidden()

	if not self:GetParent():HasScepter() then
		return true
	end

	-- If the caster is recharging its scepter reflect, hide
	if self:GetParent():HasModifier("modifier_imba_spellshield_scepter_recharge") then
		return true
	end

	-- Otherwise, show normally
	return false
end

function modifier_imba_spellshield_scepter_ready:IsPurgable() return false end
function modifier_imba_spellshield_scepter_ready:IsDebuff() return false end
function modifier_imba_spellshield_scepter_ready:RemoveOnDeath() return false end


-- Scepter block recharge modifier
modifier_imba_spellshield_scepter_recharge = modifier_imba_spellshield_scepter_recharge or class({})

function modifier_imba_spellshield_scepter_recharge:IsHidden()
	return false
end

function modifier_imba_spellshield_scepter_recharge:IsPurgable() return false end
function modifier_imba_spellshield_scepter_recharge:IsDebuff() return false end
function modifier_imba_spellshield_scepter_recharge:RemoveOnDeath() return false end





--R
-------------------------------------------
--      JUGGLE
-------------------------------------------
-- Visible Modifiers:
LinkLuaModifier("modifier_fox_juggle", "heroes/hero_fox/hero_fox", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_foxenemy_juggled", "heroes/hero_fox/hero_fox", LUA_MODIFIER_MOTION_NONE)


fox_ult = fox_ult or class({})

function fox_ult:GetAbilityTextureName()
	return "Soren4"
end

--function fox_ult:GetBehavior()
--	return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
--end

function fox_ult:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local casterloc = caster:GetAbsOrigin()
		local target = self:GetCursorTarget()
		local ability = self
		self.height = ability:GetSpecialValueFor("bounce_height")
		self.lengthmultiplier = ability:GetSpecialValueFor("bounce_lengthmultiplier")

		-- Calculates the knockback position (for Tsunami)
		local torrent_border = ( target:GetAbsOrigin() - casterloc ):Normalized() * 100
		local distance_from_center = ( target:GetAbsOrigin() - casterloc ):Length2D() * self.lengthmultiplier

		-- Some randomness to tsunami-torrent for smoother animation
		randomness_x = math.random() * math.random(-30,30)
		randomness_y = math.random() * math.random(-30,30)

		-- Knocks the target up
		local knockback =
		{
			should_stun = 1,
			knockback_duration = 3,
			duration = 3,
			knockback_distance = distance_from_center,
			knockback_height = self.height,
			center_x = (casterloc + torrent_border).x + randomness_x,
			center_y = (casterloc + torrent_border).y + randomness_y,
			center_z = (casterloc + torrent_border).z
		}

		-- Apply knockback on enemies hit
		target:RemoveModifierByName("modifier_knockback")
		target:AddNewModifier(caster, self, "modifier_knockback", knockback)
		target:AddNewModifier(caster, self, "modifier_imba_torrent_phase", {duration = 3})
		caster:AddNewModifier(caster, self, "modifier_fox_juggle", {duration = 4})

		Timers:CreateTimer(1, function()

			target:AddNewModifier(caster, self, "modifier_foxenemy_juggled", {duration = 2})

		end)
	end
end

modifier_fox_juggle = modifier_fox_juggle or class({})

function modifier_fox_juggle:IsHidden()
	return false
end

function modifier_fox_juggle:IsDebuff()
	return false
end

function modifier_fox_juggle:IsPurgable()
	return false
end

function modifier_fox_juggle:OnCreated(keys)
	self:StartIntervalThink(0.1)
end

function modifier_fox_juggle:OnIntervalThink()
	if IsServer() then

	local caster = self:GetCaster()
	local casterloc = caster:GetAbsOrigin()
	local ability = self:GetAbility()
	self.height = ability:GetSpecialValueFor("bounce_height")
	self.lengthmultiplier = ability:GetSpecialValueFor("bounce_lengthmultiplier")

	local enemiestobounce = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	print(#enemiestobounce)

	for _,unit in pairs(enemiestobounce) do
		if unit:HasModifier("modifier_foxenemy_juggled") == true then
			--DER SMADRES OPPAD IGEN

			-- Calculates the knockback position (for Tsunami)
			local torrent_border = ( unit:GetAbsOrigin() - casterloc ):Normalized() * 100
			local distance_from_center = ( unit:GetAbsOrigin() - casterloc ):Length2D() * self.lengthmultiplier
	
			-- Some randomness to tsunami-torrent for smoother animation
			randomness_x = math.random() * math.random(-10,10)
			randomness_y = math.random() * math.random(-10,10)
	
			-- Knocks the target up
			local knockback =
			{
				should_stun = 1,
				knockback_duration = 3,
				duration = 3,
				knockback_distance = distance_from_center,
				knockback_height = self.height,
				center_x = (casterloc + torrent_border).x + randomness_x,
				center_y = (casterloc + torrent_border).y + randomness_y,
				center_z = (casterloc + torrent_border).z
			}
	
			-- Apply knockback on enemies hit
			unit:RemoveModifierByName("modifier_knockback")
			unit:AddNewModifier(caster, self, "modifier_knockback", knockback)
			unit:AddNewModifier(caster, self, "modifier_imba_torrent_phase", {duration = 3})
			caster:AddNewModifier(caster, self, "modifier_fox_juggle", {duration = 3})
	
			Timers:CreateTimer(1, function()

				unit:AddNewModifier(caster, self, "modifier_foxenemy_juggled", {duration = 2})

			end)

		end
	end
end
end





----
modifier_foxenemy_juggled = modifier_foxenemy_juggled or class({})

function modifier_foxenemy_juggled:IsHidden()
	return false
end

function modifier_foxenemy_juggled:IsDebuff()
	return true
end

function modifier_foxenemy_juggled:IsPurgable()
	return false
end

function modifier_foxenemy_juggled:OnCreated(keys)
	
end
