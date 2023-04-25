LinkLuaModifier("modifier_mette_rose", "heroes/hero_mette/rose", LUA_MODIFIER_MOTION_NONE)

red_rose= red_rose or class({})

function red_rose:GetIntrinsicModifierName()
	return "modifier_mette_rose"
end

modifier_mette_rose = modifier_mette_rose or class({})

function modifier_mette_rose:IsPurgeable() return false end
function modifier_mette_rose:IsHidden() return false end
function modifier_mette_rose:IsPassive() return true end
function modifier_mette_rose:RemoveOnDeath()	return false end

function modifier_mette_rose:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}

	return decFuncs
end

function modifier_mette_rose:OnCreated()
	if not IsServer() then return end
	self:ResetMinkThreshold()
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("base_interval")) --for instaspawning the first
end


function modifier_mette_rose:OnTakeDamage(keys)
	if not IsServer() then return end
	parent = self:GetParent()
	if keys.unit == parent and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= parent:GetTeamNumber() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		
		reflectDamage = 0
		if (parent:HasTalent("special_bonus_mette_4")) then
            reflectDamage = keys.damage * (self:GetAbility():GetSpecialValueFor("reflect_percent") + parent:FindAbilityByName("special_bonus_mette_4"):GetSpecialValueFor("value"))/100
        else
			reflectDamage = keys.damage * (self:GetAbility():GetSpecialValueFor("reflect_percent")/100)
		end
		if not keys.unit:IsOther() then
		
			local damageTable = {
				victim			= keys.attacker,
				damage			= reflectDamage,
				damage_type		= DAMAGE_TYPE_PURE,
				damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				attacker		= parent,
				ability			= self:GetAbility()
			}
			
            
			ApplyDamage(damageTable)
			self:LowerMinkThreshold(keys.damage)
			
			
		end
	end
end

function modifier_mette_rose:LowerMinkThreshold(damage)
	self.damage_to_mink = self.damage_to_mink - damage
	
	if self.damage_to_mink <= 0 then
	self:GetParent():FindModifierByName("modifier_mink_passive"):SpawnMink(1,self:GetParent())
	self:ResetMinkThreshold()
	else
		self:SetStackCount(self.damage_to_mink)
	end
end

function modifier_mette_rose:ResetMinkThreshold(damage)
	local threshold = self:GetAbility():GetSpecialValueFor("mink_threshold")
	if (self:GetParent():HasTalent("special_bonus_mette_7")) then
		threshold = threshold + self:GetParent():FindAbilityByName("special_bonus_mette_7"):GetSpecialValueFor("value")
	end
	self.damage_to_mink = threshold
	self:SetStackCount(self.damage_to_mink)
end