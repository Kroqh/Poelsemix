LinkLuaModifier("modifier_slapper_bum_passive", "heroes/hero_slapper/slapper_bum_hunter", LUA_MODIFIER_MOTION_NONE)
slapper_bum_hunter = slapper_bum_hunter or class({})


function slapper_bum_hunter:GetIntrinsicModifierName()
	return "modifier_slapper_bum_passive"
end

modifier_slapper_bum_passive = modifier_slapper_bum_passive or class({})

function modifier_slapper_bum_passive:IsPurgeable() return false end
function modifier_slapper_bum_passive:IsHidden() return true end

function modifier_slapper_bum_passive:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND, MODIFIER_EVENT_ON_TAKEDAMAGE}
	return decFuncs
end


function modifier_slapper_bum_passive:OnTakeDamage( keys )
	local parent = self:GetParent()
	if keys.attacker == parent and IsServer() and keys.inflictor ~= self:GetAbility() then
		if parent:PassivesDisabled() then return end
	
		local forwardVector			= keys.unit:GetForwardVector()
		local forwardAngle			= math.deg(math.atan2(forwardVector.x, forwardVector.y))
				
		local reverseEnemyVector	= (keys.unit:GetAbsOrigin() - parent:GetAbsOrigin()):Normalized()
		local reverseEnemyAngle		= math.deg(math.atan2(reverseEnemyVector.x, reverseEnemyVector.y))

		local back_angle = self:GetAbility():GetSpecialValueFor("back_angle")

		local difference = math.abs(forwardAngle - reverseEnemyAngle)

		

		if (difference <= (back_angle / 2)) or (difference >= (360 - (back_angle / 2))) then --tak imba
			local damage = keys.damage * (self:GetAbility():GetSpecialValueFor("bonus_damage_from_behind")/100)
			print(damage)
			ApplyDamage({victim = keys.unit,
				attacker = parent,
				damage_type = DAMAGE_TYPE_PURE, --BONUS DAMAGE POST MIGITATIONS
				damage = damage,
				ability = self:GetAbility()
			})
			
		end
	end
end


function modifier_slapper_bum_passive:GetAttackSound()
	local parent = self:GetParent()
	local ramm = parent:HasModifier("modifier_slapper_rammusteinu")
	--local slap_city = parent:HasModifier("modifier_slapper_slap_city")
	local slap_city = false --uncomment other line and remove this

	if ramm then
		if slap_city then return "slapper_slap_city_slap_rammusteinu"
		else return "slapper_slap_city_slap_rammusteinu" end
	else
		if slap_city then return "slapper_slap_normal"
		else return "slapper_slap_city_slap_normal" end
	end
end

