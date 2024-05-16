stewart_poelsevogn = stewart_poelsevogn or class({})
LinkLuaModifier( "modifier_stewart_poelsevogn", "heroes/hero_stewart/stewart_poelsevogn", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------


function stewart_poelsevogn:GetCastRange()
    local value = self:GetSpecialValueFor("range")
    return value
end

function stewart_poelsevogn:OnSpellStart()
	if not IsServer() then return end
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()


	caster:EmitSound("stewart_poelsevogn")

	unit = CreateUnitByName("npc_poelsevogn",target_point, true, caster, nil, caster:GetTeam())
	unit:AddNewModifier(caster, ability, "modifier_stewart_poelsevogn", { duration = ability:GetSpecialValueFor("duration_before_explosion") } )
	unit:AddNewModifier(target, self, "modifier_generic_taunt", {})
end


modifier_stewart_poelsevogn = modifier_stewart_poelsevogn or class({})

function modifier_stewart_poelsevogn:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
	self.taunt_range = self:GetAbility():GetSpecialValueFor("taunt_range")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.radius = self:GetAbility():GetSpecialValueFor("explosion_radius")
	if self:GetCaster():FindAbilityByName("special_bonus_stewart_8"):GetLevel() > 0 then self.radius = self.radius + self:GetCaster():FindAbilityByName("special_bonus_stewart_8"):GetSpecialValueFor("value") end
end

function modifier_stewart_poelsevogn:OnIntervalThink()
	if not IsServer() then return end
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.taunt_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	self:GetParent():MoveToNPC(enemies[1])
end

function modifier_stewart_poelsevogn:OnRemoved()
	if not IsServer() then return end
	self.target = nil
	self:GetParent():EmitSound("Hero_Techies.Suicide")
	local parent = self:GetParent()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), parent:GetAbsOrigin(), nil, self.radius, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	local particle = "particles/units/heroes/hero_techies/techies_remote_cart_explode.vpcf"


	local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControl(pfx, 0, parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, Vector(0,0,self.radius))


    for i, enemy in pairs(enemies) do
		local damageTable = {
			victim = enemy,
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility()
		}
		ApplyDamage(damageTable)
		
	end
	
	parent:ForceKill(false)

	Timers:CreateTimer({
        endTime = 0.75,
        callback = function()
           parent:AddNoDraw()
        end
    })
	
end