--BIG CLICKS
LinkLuaModifier("modifier_big_clicks", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)

big_clicks = class({})

function big_clicks:GetAbilityTextureName()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_upgrade_skills") then
		return "big_clicks_upgraded_icon"
	end

	return "big_clicks_icon"
end

function big_clicks:OnSpellStart() 
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		local stacks = self:GetSpecialValueFor("stacks")
		local upgraded_stacks = self:GetSpecialValueFor("upgraded_stacks") 

		caster:AddNewModifier(caster, self, "modifier_big_clicks", {duration = duration})

		if caster:HasModifier("modifier_upgrade_skills") then
			caster:FindModifierByName("modifier_big_clicks"):SetStackCount(upgraded_stacks)
		else
			caster:FindModifierByName("modifier_big_clicks"):SetStackCount(stacks)
		end
	end
end

--big clicks modifier
modifier_big_clicks = class({})

function modifier_big_clicks:IsBuff() return true end
function modifier_big_clicks:IsPurgeable() return true end
function modifier_big_clicks:IsHidden() return false end

function modifier_big_clicks:DeclareFunctions()
		local decFuncs =
			{
					MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
					MODIFIER_EVENT_ON_ATTACK_LANDED
			}
		return decFuncs
end

function modifier_big_clicks:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage
end

function modifier_big_clicks:OnCreated()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_upgrade_skills") then
		self.damage = self:GetAbility():GetSpecialValueFor("upgraded_damage")
	else
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
	end
end

function modifier_big_clicks:OnAttackLanded()
	if IsServer() then
		local stacks = self:GetStackCount()

		if stacks > 1 then
			self:SetStackCount(stacks - 1)
		else
			self:Destroy()
		end
	end
end

function modifier_big_clicks:OnRefresh()
	self:OnCreated()
end

--multiclick

LinkLuaModifier("modifier_multiclick", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_multiclick_passive", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_multiclick_thinker", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)

multiclick = class({})

function multiclick:GetAbilityTextureName()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_upgrade_skills") then
		return "multiclick_upgraded_icon"
	end

	return "multiclick_icon"
end

function multiclick:GetBehavior()
	if self:GetCaster():HasModifier("modifier_upgrade_skills") then
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end

	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function multiclick:GetIntrinsicModifierName()
	return "modifier_multiclick_thinker"
end

function multiclick:OnSpellStart() 
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		local stacks = self:GetSpecialValueFor("stacks")

		caster:AddNewModifier(caster, self, "modifier_multiclick", {duration = duration})
		caster:FindModifierByName("modifier_multiclick"):SetStackCount(stacks)
	end
end

function multiclick:GetManaCost( level )
	if self:GetCaster():HasModifier("modifier_upgrade_skills") then
		return 0
	end

	return self.BaseClass.GetManaCost(self, level)
end

--multiclick modifier
modifier_multiclick = class({})

function modifier_multiclick:IsBuff() return true end
function modifier_multiclick:IsPurgeable() return true end
function modifier_multiclick:IsHidden() return false end

function modifier_multiclick:DeclareFunctions()
		local decFuncs =
			{
					MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
					MODIFIER_EVENT_ON_ATTACK_LANDED

			}
		return decFuncs
end

function modifier_multiclick:GetModifierBaseAttackTimeConstant()
	return self.attackTime
end 

function modifier_multiclick:OnCreated()
	self.attackTime = self:GetAbility():GetSpecialValueFor("bat")
end

function modifier_multiclick:OnAttackLanded()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_upgrade_skills") then return end
		local stacks = self:GetStackCount()

		if stacks > 1 then
			self:SetStackCount(stacks - 1)
		else
			self:Destroy()
		end
	end
end
--multiclick passive modifier
modifier_multiclick_passive = class({})

function modifier_multiclick_passive:IsHidden() 
	if self:GetCaster():HasModifier("modifier_upgrade_skills") then
		return false
	end

	return true
end

function modifier_multiclick_passive:IsPurgeable() return false end

function modifier_multiclick_passive:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
	return decFuncs
end


function modifier_multiclick_passive:GetModifierBaseAttackTimeConstant()
	return self.upgraded_bat
end

function modifier_multiclick_passive:OnCreated()
	self.upgraded_bat = self:GetAbility():GetSpecialValueFor("bat_upgraded")
end

function modifier_multiclick_passive:OnRefresh()
	self:OnCreated()
end

modifier_multiclick_thinker = class({})

function modifier_multiclick_thinker:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function modifier_multiclick_thinker:IsHidden() return true end
function modifier_multiclick_thinker:IsPurgeable() return false end

function modifier_multiclick_thinker:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster() 
		local ability = self:GetAbility()

		if caster:HasModifier("modifier_upgrade_skills") then
			caster:AddNewModifier(caster, ability, "modifier_multiclick_passive", {}) 
		else
			caster:RemoveModifierByName("modifier_multiclick_passive")
		end
	end
end

--huge click
LinkLuaModifier("modifier_huge_click_attack", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)

huge_click = class({})

function huge_click:GetAbilityTextureName()
	local caster = self:GetCaster() 
	
	if caster:HasModifier("modifier_upgrade_skills") then
		return "huge_click_upgraded_icon"
	end
	
	return "huge_click_icon"
end

function huge_click:GetIntrinsicModifierName()
	return "modifier_huge_click_attack"
end 

--huge click modifier
modifier_huge_click_attack = class({})

function modifier_huge_click_attack:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}

	return decFuncs
end

function modifier_huge_click_attack:IsPurgeable() return false end
function modifier_huge_click_attack:IsHidden() return true end

function modifier_huge_click_attack:OnCreated()
		self.damage_modifier = self:GetAbility():GetSpecialValueFor("damage_modifier")
		self.damage_modifier_upgraded = self:GetAbility():GetSpecialValueFor("damage_modifier_upgraded") 
		self.chance = self:GetAbility():GetSpecialValueFor("chance")
end

function modifier_huge_click_attack:GetModifierPreAttack_CriticalStrike()
	if IsServer() then
		local caster = self:GetCaster() 
		local rand = RandomInt(1, 100)
		if rand <= self.chance then
			if caster:HasModifier("modifier_upgrade_skills") then
				damage = self.damage_modifier_upgraded
			else
				damage = self.damage_modifier
			end

			return damage
		end

		return nil
	end
end

--POWERSURGE
LinkLuaModifier("modifier_powersurge", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)
powersurge = class({})

function powersurge:GetAbilityTextureName()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_upgrade_skills") then
		return "powersurge_upgraded_icon"
	end

	return "powersurge_icon"
end

function powersurge:OnSpellStart() 
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")

		caster:AddNewModifier(caster, self, "modifier_powersurge", {duration = duration}) 
	end
end

modifier_powersurge = class({})

function modifier_powersurge:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
	
	return decFuncs
end

function modifier_powersurge:GetModifierBaseAttack_BonusDamage()
	return self.baseDamage
end

function modifier_powersurge:OnCreated()
	if IsServer then
		local caster = self:GetCaster()
		local baseDamageAverage = (caster:GetBaseDamageMax() + caster:GetBaseDamageMin()) / 2
		local damage_multiplier = self:GetAbility():GetSpecialValueFor("damage_multiplier") 
		local damage_multiplier_upgraded = self:GetAbility():GetSpecialValueFor("damage_multiplier_upgraded")
		
		if caster:HasModifier("modifier_upgrade_skills") then
			self.baseDamage = baseDamageAverage * damage_multiplier_upgraded
		else
			self.baseDamage = baseDamageAverage * damage_multiplier
		end
	end
end

function modifier_powersurge:OnRefresh()
	self.baseDamage = 0
	self:OnCreated()
end


--UPGRADE SKILLS
LinkLuaModifier("modifier_upgrade_skills", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)
upgrade_skills = class({})

function upgrade_skills:GetAbilityTextureName()
	return "upgrade_skills"
end

modifier_upgrade_skills = class({})

function upgrade_skills:OnSpellStart() 
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")

		caster:AddNewModifier(caster, self, "modifier_upgrade_skills", {duration = duration})
		caster:RemoveModifierByName("modifier_multiclick")
	end
end
