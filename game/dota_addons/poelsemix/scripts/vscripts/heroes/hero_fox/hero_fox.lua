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









--E
------------------------------------
-----    ROLLING THUNDER       -----
------------------------------------
fox_wavedash = fox_wavedash or class({})
--LinkLuaModifier("modifier_imba_gyroshell_roll", "hero/hero_pangolier.lua", LUA_MODIFIER_MOTION_NONE) 				------|
--LinkLuaModifier("modifier_imba_gyroshell_ricochet", "hero/hero_pangolier.lua", LUA_MODIFIER_MOTION_NONE)			------|  IMBA MODIFIERS (not used atm)
--LinkLuaModifier("modifier_imba_gyroshell_stun", "hero/hero_pangolier.lua", LUA_MODIFIER_MOTION_NONE)				------|
--LinkLuaModifier("modifier_imba_pangolier_gyroshell_bounce", "hero/hero_pangolier.lua", LUA_MODIFIER_MOTION_NONE)	------|
LinkLuaModifier("modifier_fox_wavedash", "heroes/hero_fox/hero_fox", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fox_wavedash_dash", "heroes/hero_fox/hero_fox", LUA_MODIFIER_MOTION_NONE)

function fox_wavedash:GetAbilityTextureName()
	return "pangolier_gyroshell"
end

function fox_wavedash:IsHiddenWhenStolen() return false end
function fox_wavedash:IsStealable() return true end
function fox_wavedash:IsNetherWardStealable() return false end

function fox_wavedash:GetManaCost(level)
	local manacost = self.BaseClass.GetManaCost(self, level)

	return manacost
end

function fox_wavedash:GetCastPoint()
	local cast_point = self.BaseClass.GetCastPoint(self)

	return cast_point
end

function fox_wavedash:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local roll_modifier = "modifier_pangolier_gyroshell" --Vanilla
	--local roll_modifier = "modifier_imba_gyroshell_roll" --Imba

	-- Ability specials
	local tick_interval = ability:GetSpecialValueFor("tick_interval")
	local ability_duration = ability:GetSpecialValueFor("duration") -- Bruges


	-- Play animation
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)


	--Apply a basic purge
	caster:Purge(false, true, false, false, false)

	--Starts rolling (Vanilla modifier for now)
	--caster:AddNewModifier(caster, ability, roll_modifier, {duration = ability_duration})

	--starts checking for hero impacts
	caster:AddNewModifier(caster, ability, "modifier_fox_wavedash", {duration = ability_duration})
end

	





modifier_fox_wavedash = modifier_fox_wavedash or class({})
function modifier_fox_wavedash:OnCreated()
	-- Ability properties
	self.stun_modifier = "modifier_imba_gyroshell_stun"
	self.collision_modifier = "modifier_imba_gyroshell_ricochet"
	self.shield_crash = "modifier_imba_shield_crash_jump"
	self.end_sound = "Hero_Pangolier.Gyroshell.Stop"
	-- Ability specials
	self.tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
	
	if IsServer() then
		--play initial roll gesture
		self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
	

		--declaring variables
		self.initial_direction = self:GetCaster():GetForwardVector() --will be needed to stop turning after pangolier turn 180°
		self.issued_order = false --is pangolier turning?
		self.boosted_turn = true --is pangolier turning faster? (on start, collision, jump)
		self.boosted_turn_time = 0 --will count how many ticks have been passed with boosted turn rate
		--start modifier interval thinking
		self:StartIntervalThink(self.tick_interval)
	end
end


function modifier_fox_wavedash:IsHidden() return false end
function modifier_fox_wavedash:IsPurgable() return false end
function modifier_fox_wavedash:IsDebuff() return false end
function modifier_fox_wavedash:IgnoreTenacity() return true end
function modifier_fox_wavedash:IsMotionController() return true end
function modifier_fox_wavedash:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_fox_wavedash:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_EVENT_ON_ATTACK_START,
		}
	return decFuns
end

function modifier_fox_wavedash:OnIntervalThink()

	--Interrupt if Pangolier has been stunned, rooted or taunted
	if self:GetCaster():IsStunned() or self:GetCaster():IsRooted() or self:GetCaster():GetForceAttackTarget() then
		 return self:Destroy()
		
	end

	--Actual dash
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_fox_wavedash_dash", {duration = self.tick_interval-0.5}) 
	
	-- Check Motion controllers
	if not self:CheckMotionControllers() then
		self:Destroy()
		return nil
	end

	--Anim
	self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_3)

		-- Disjointing everything
		ProjectileManager:ProjectileDodge(self:GetCaster())
end

function modifier_fox_wavedash:OnAttackStart()
	self:GetCaster():RemoveModifierByName("modifier_fox_wavedash")
end





modifier_fox_wavedash_dash = modifier_fox_wavedash_dash or class({})
function modifier_fox_wavedash_dash:OnCreated()	
	self.forced_direction = self:GetCaster():GetForwardVector()
	self.forced_distance = 50
	self.forced_speed = 300 * 1/30	-- * 1/30 gives a duration of ~0.4 second push time (which is what the gamepedia-site says it should be)
	self.forced_traveled = 0

	self:OnIntervalThink()
	self:StartIntervalThink(0.01)
end

function modifier_fox_wavedash_dash:OnIntervalThink()
	local caster = self:GetCaster()
	print(self.forced_distance)
	if self.forced_traveled < self.forced_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + self.forced_direction * self.forced_speed)
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin() + self.forced_direction * self.forced_speed, true)
		self.forced_traveled = self.forced_traveled + (self.forced_direction * self.forced_speed):Length2D()
		

	else
		caster:InterruptMotionControllers(true)
	end
end