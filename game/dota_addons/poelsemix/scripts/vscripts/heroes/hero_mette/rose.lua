LinkLuaModifier("modifier_mette_rose", "heroes/hero_mette/rose", LUA_MODIFIER_MOTION_NONE)

red_rose= red_rose or class({})

function red_rose:GetIntrinsicModifierName()
	return "modifier_mette_rose"
end

modifier_mette_rose = modifier_mette_rose or class({})

function modifier_mette_rose:IsPurgeable() return false end
function modifier_mette_rose:IsHidden() return true end
function modifier_mette_rose:IsPassive() return true end

function modifier_mette_rose:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}

	return decFuncs
end

function modifier_mette_rose:OnTakeDamage(keys)
	if not IsServer() then return end
	if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		if not keys.unit:IsOther() then
		
			local damageTable = {
				victim			= keys.attacker,
				damage			= keys.original_damage * (self:GetAbility():GetSpecialValueFor("reflect_percent")/100),
				damage_type		= DAMAGE_TYPE_PURE,
				damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				attacker		= self:GetParent(),
				ability			= self:GetAbility()
			}
			
            
			local reflectDamage = ApplyDamage(damageTable)
			
			
		end
	end
end