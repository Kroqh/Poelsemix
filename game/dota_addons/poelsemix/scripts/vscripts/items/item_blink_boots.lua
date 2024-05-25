item_blink_boots = item_blink_boots or class({})
LinkLuaModifier( "modifier_blink_boots", "items/item_blink_boots", LUA_MODIFIER_MOTION_NONE ) -- Check if the target was damaged and set cooldown

function item_blink_boots:GetIntrinsicModifierName()
	return "modifier_blink_boots"
end

function item_blink_boots:GetCastRange(location, target)
	if IsClient() then
		return self:GetSpecialValueFor("max_blink_range") - self:GetCaster():GetCastRangeBonus()
	end
end

function item_blink_boots:OnSpellStart()
	local caster = self:GetCaster()
	local origin_point = caster:GetAbsOrigin()
	local target_point = self:GetCursorPosition()

	local distance = (target_point - origin_point):Length2D()
	local max_blink_range = self:GetSpecialValueFor("max_blink_range")

	-- Set distance if targeted destiny is beyond range
	if distance > max_blink_range then
		-- Calculate total overshoot distance
		if distance > max_blink_range then
			target_point = origin_point + (target_point - origin_point):Normalized() * max_blink_range
		end
	end
	caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	local blink_pfx
	local blink_pfx_name = "particles/items_fx/blink_dagger_start.vpcf"
	blink_pfx = ParticleManager:CreateParticle(blink_pfx_name, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(blink_pfx, 0, self:GetAbsOrigin())

	ParticleManager:ReleaseParticleIndex(blink_pfx)
	FindClearSpaceForUnit(caster, target_point, true)
	ProjectileManager:ProjectileDodge(caster)

	local blink_end_pfx
	local blink_end_pfx_name = "particles/items_fx/blink_dagger_end.vpcf"

	blink_end_pfx = ParticleManager:CreateParticle(blink_end_pfx_name, PATTACH_ABSORIGIN, caster)

	ParticleManager:ReleaseParticleIndex(blink_end_pfx)

	EmitSoundOn("DOTA_Item.BlinkDagger.NailedIt", caster)
end

modifier_blink_boots = modifier_blink_boots or class({})
function modifier_blink_boots:IsHidden() return true end
function modifier_blink_boots:IsDebuff() return false end
function modifier_blink_boots:IsPurgable() return false end
function modifier_blink_boots:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_blink_boots:DeclareFunctions()
		return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
			MODIFIER_EVENT_ON_TAKEDAMAGE
		}

end

function modifier_blink_boots:GetModifierMoveSpeedBonus_Special_Boots()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("movement_speed")
	end
end

function modifier_blink_boots:OnTakeDamage( keys )
	if self:GetAbility() then
		if self:GetParent() == keys.unit and keys.attacker:GetTeam() ~= self:GetParent():GetTeam() and keys.attacker:IsHero() then
			if self:GetAbility():GetCooldownTimeRemaining() < self:GetAbility():GetSpecialValueFor("cooldown") then
				self:GetAbility():StartCooldown(self:GetAbility():GetSpecialValueFor("cooldown"))
			end
		end
	end
end