--multiclick

LinkLuaModifier("modifier_multiclick", "heroes/hero_cid/cid_multiclick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_multiclick_passive", "heroes/hero_cid/cid_multiclick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_multiclick_thinker", "heroes/hero_cid/cid_multiclick", LUA_MODIFIER_MOTION_NONE)

multiclick = multiclick or class({})

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
        if caster:FindAbilityByName("special_bonus_cid_2"):GetLevel() > 0 then stacks = stacks + caster:FindAbilityByName("special_bonus_cid_2"):GetSpecialValueFor("value") end

		caster:AddNewModifier(caster, self, "modifier_multiclick", {duration = duration})
		caster:FindModifierByName("modifier_multiclick"):SetStackCount(stacks)
		caster:EmitSound("Hero_StormSpirit.ElectricVortexCast")
	end
end

function multiclick:GetManaCost( level )
	if self:GetCaster():HasModifier("modifier_upgrade_skills") then
		return 0
	end

	return self.BaseClass.GetManaCost(self, level)
end

--multiclick modifier
modifier_multiclick = modifier_multiclick or class({})

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
	
	local caster = self:GetCaster()
    if caster:FindAbilityByName("special_bonus_cid_8"):GetLevel() > 0 then self.attackTime = self.attackTime + caster:FindAbilityByName("special_bonus_cid_8"):GetSpecialValueFor("value") end

	self.pfx = "particles/econ/items/wisp/wisp_guardian_ti7.vpcf"
	self.wisp_fx = ParticleManager:CreateParticle(self.pfx, PATTACH_ABSORIGIN_FOLLOW, caster) 
	ParticleManager:SetParticleControlEnt(self.wisp_fx, 0, caster, PATTACH_OVERHEAD_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
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

function modifier_multiclick:OnDestroy()
	ParticleManager:DestroyParticle(self.wisp_fx, false)
	ParticleManager:ReleaseParticleIndex(self.wisp_fx)
end

--multiclick passive modifier
modifier_multiclick_passive = modifier_multiclick_passive or class({})

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
    local caster = self:GetCaster()
    if caster:FindAbilityByName("special_bonus_cid_8"):GetLevel() > 0 then self.upgraded_bat = self.upgraded_bat + caster:FindAbilityByName("special_bonus_cid_8"):GetSpecialValueFor("value") end
end

function modifier_multiclick_passive:OnRefresh()
	self:OnCreated()
end

modifier_multiclick_thinker = modifier_multiclick_thinker or class({})

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
            caster:RemoveModifierByName("modifier_multiclick") 
		else
			caster:RemoveModifierByName("modifier_multiclick_passive")
		end
	end
end