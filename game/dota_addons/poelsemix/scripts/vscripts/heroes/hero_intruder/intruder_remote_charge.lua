LinkLuaModifier("modifier_remote_charge_invis", "heroes/hero_intruder/intruder_remote_charge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_remote_charge_handler", "heroes/hero_intruder/intruder_remote_charge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_remote_charge_explosion", "heroes/hero_intruder/intruder_remote_charge", LUA_MODIFIER_MOTION_NONE)


intruder_remote_charge = intruder_remote_charge or class({})



function intruder_remote_charge:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local pos = caster:GetCursorPosition()
		
		local unit = CreateUnitByName("npc_remote_charge", pos, true, caster, caster, caster:GetTeamNumber())
		unit:FaceTowards(pos - Vector(0,1))
		unit:AddNewModifier(caster, self, "modifier_remote_charge_handler", {})

		EmitSoundOn("intruder_bomb_plant", caster)
	end
end

modifier_remote_charge_handler = modifier_remote_charge_handler or class({})




function modifier_remote_charge_handler:IsHidden() return true end

function modifier_remote_charge_handler:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		self:GetParent():AddNewModifier(self:GetCaster(), ability, "modifier_kill", { duration = ability:GetSpecialValueFor("lifetime") } )
		self:StartIntervalThink(ability:GetSpecialValueFor("delay"))
	end
end

function modifier_remote_charge_handler:OnIntervalThink()
	if IsServer() then
			local parent = self:GetParent()
			local ability = self:GetAbility()
			parent:AddNewModifier(self:GetCaster(), ability, "modifier_remote_charge_invis", {})
			parent:AddNewModifier(self:GetCaster(), ability, "modifier_remote_charge_explosion", {})
			parent:RemoveModifierByName("modifier_remote_charge_handler")
	end
end

modifier_remote_charge_invis = modifier_remote_charge_invis or  class({})

function modifier_remote_charge_invis:IsHidden() return true end

function modifier_remote_charge_invis:IsPurgeable() return false end
function modifier_remote_charge_invis:IsDebuff() return false end

function modifier_remote_charge_invis:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
	return decFuncs
end

function modifier_remote_charge_invis:GetModifierInvisibilityLevel()
	if IsClient() then
		return 1
	end
end

function modifier_remote_charge_invis:CheckState()
	if IsServer() then
		local state = {[MODIFIER_STATE_INVISIBLE] = true}
		return state
	end
end

modifier_remote_charge_explosion = modifier_remote_charge_explosion or class({})

function modifier_remote_charge_explosion:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		self.radius = ability:GetSpecialValueFor("explosion_radius")
		self.damage = ability:GetSpecialValueFor("explosion_damage")
		if self:GetCaster():HasTalent("special_bonus_intruder_5") then  self.damage = self.damage + self:GetCaster():FindAbilityByName("special_bonus_intruder_5"):GetSpecialValueFor("value") end
		self:StartIntervalThink(0.1)
	end
end

function modifier_remote_charge_explosion:IsHidden() return false end

function modifier_remote_charge_explosion:OnIntervalThink()
	if IsServer() then

		local unit = self:GetParent()
		local unit_pos = unit:GetAbsOrigin()
		local ability = self:GetAbility()
		local caster = ability:GetCaster()
		local enemies = FindUnitsInRadius(unit:GetTeamNumber(), 
			unit_pos, 
			nil, 
			self.radius, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			DOTA_UNIT_TARGET_FLAG_NONE, 
			FIND_ANY_ORDER, 
			false)

		if #enemies == 0 then
			enemies = nil
		end

		--EXPLOSION HAPPENS HERE
		if enemies ~= nil then --hardcoded explosion delay for some reason
			self:StartIntervalThink(-1)
			for _, enemy in pairs(enemies) do
				local damageTable = {
					victim = enemy,
					damage = self.damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					attacker = caster,
					ability = ability
				}
				ApplyDamage(damageTable)
			end

			local particle = "particles/heroes/intruder/trap_explosion.vpcf"
			local pfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, unit)
			ParticleManager:SetParticleControl(pfx, 0, unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(pfx, 1, Vector(0.65,0.65,0.65))

			EmitSoundOn("intruder_bomb_explode", unit)
			unit:AddNoDraw()
			unit:ForceKill(false)
		end
	end
end