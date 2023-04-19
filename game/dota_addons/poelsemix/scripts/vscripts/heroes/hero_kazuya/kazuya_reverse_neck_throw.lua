kazuya_reverse_neck_throw = kazuya_reverse_neck_throw or class({})
LinkLuaModifier( "modifier_generic_arc", "generic_mods/modifier_generic_arc", LUA_MODIFIER_MOTION_BOTH )

-- Ability Start
function kazuya_reverse_neck_throw:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local fury_cost  = self:GetSpecialValueFor("fury_cost")
	if caster:HasTalent("special_bonus_kazuya_4") then fury_cost = fury_cost + caster:FindAbilityByName("special_bonus_kazuya_4"):GetSpecialValueFor("value") end
	caster:FindModifierByName("modifier_kazuya_rage_fury_handler"):ChangeFury(-fury_cost, false)
	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	-- load data
	local duration = self:GetSpecialValueFor( "air_duration" )
	local height = self:GetSpecialValueFor( "air_height" )
	local distance = self:GetSpecialValueFor( "throw_distance_behind" )

	local str_scale = self:GetSpecialValueFor("strength_scaling")
	local damage = self:GetSpecialValueFor("damage") + (caster:GetStrength() * str_scale)
    caster:FaceTowards(target:GetOrigin())
	-- set target pos
	local targetpos = caster:GetOrigin() - caster:GetForwardVector() * distance
	local totaldist = (target:GetOrigin() - targetpos):Length2D()
    caster:EmitSound("kazuya_neck_throw")
	-- create arc
	local arc = target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_generic_arc", -- modifier name
		{
			target_x = targetpos.x,
			target_y = targetpos.y,
			duration = duration,
			distance = totaldist,
			height = height,
			fix_end = false,
			fix_duration = false,
			isStun = true,
			isForward = true,
			activity = ACT_DOTA_FLAIL,
		} -- kv
	)
	arc:SetEndCallback( function()
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		}
			ApplyDamage(damageTable)
			-- play effects
            local particle_cast = "particles/units/heroes/hero_marci/marci_dispose_aoe_damage.vpcf"
	        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	        ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	        ParticleManager:ReleaseParticleIndex( effect_cast )

		-- destroy trees
		GridNav:DestroyTreesAroundPoint( target:GetOrigin(), 100, false )
	end)

end

function kazuya_reverse_neck_throw:GetCustomCastErrorTarget()
	local caster = self:GetCaster()
	local fury_cost  = self:GetSpecialValueFor("fury_cost")
	if caster:HasTalent("special_bonus_kazuya_4") then fury_cost = fury_cost + caster:FindAbilityByName("special_bonus_kazuya_4"):GetSpecialValueFor("value") end
	return string.format("Fury needed: %s", fury_cost)
end

function kazuya_reverse_neck_throw:CastFilterResultTarget()
	if IsServer() then
		local caster = self:GetCaster()
		local fury_cost  = self:GetSpecialValueFor("fury_cost")
		if caster:HasTalent("special_bonus_kazuya_4") then fury_cost = fury_cost + caster:FindAbilityByName("special_bonus_kazuya_4"):GetSpecialValueFor("value") end
		if caster:FindModifierByName("modifier_kazuya_rage_fury_handler"):GetEnoughFury(fury_cost) then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end