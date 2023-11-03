
urgot_reverser = urgot_reverser or class({})

LinkLuaModifier( "modifier_urgot_reverser", "heroes/hero_urgot/urgot_reverser", LUA_MODIFIER_MOTION_NONE )


function urgot_reverser:GetCastRange()
    local value = self:GetSpecialValueFor("cast_range") 
	if self:GetCaster():FindAbilityByName("special_bonus_urgot_5"):GetLevel() > 0 then value = value + self:GetCaster():FindAbilityByName("special_bonus_urgot_5"):GetSpecialValueFor("value") end 
    return value
end

function urgot_reverser:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		if caster:HasScepter() then
			
			self.allEnemies = FindUnitsInRadius(caster:GetTeamNumber(),
			Vector(0, 0, 0),
			nil,
			FIND_UNITS_EVERYWHERE,
			self:GetAbilityTargetTeam(),
			self:GetAbilityTargetType(),
			self:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false)
			
			for _,unit in pairs(self.allEnemies) do
				EmitSoundOn("urgotRStart", unit)
			end

		end

		EmitSoundOn("urgotRStart", caster)
		EmitSoundOn("urgotRStart", target)

		--dmg reduction til urgot del
		local dmgReducDur = self:GetSpecialValueFor("dmg_red_duration")

		caster:AddNewModifier(caster, self, "modifier_urgot_reverser", {duration = dmgReducDur} )	
	end
end

function urgot_reverser:OnChannelThink(flInterval)
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		
		if caster:HasScepter() then
			for _,unit in pairs(self.allEnemies) do
				if not unit:HasModifier("modifier_stunned") then
					unit:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.1})
				end
			end
		else
			if not target:HasModifier("modifier_stunned") then
				target:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.1})
			end
		end
	end
end

function urgot_reverser:OnChannelFinish(bInterrupted)
	if IsServer() then
	if bInterrupted then self:GetCaster():RemoveModifierByName("modifier_urgot_reverser") return end

		local caster = self:GetCaster()
		local target = self:GetCursorTarget()


		-- Ministun the target if it's an enemy
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			target:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.1})
		end

		if caster:HasScepter() then
			for _,unit in pairs(self.allEnemies) do
				unit:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.2})
			end
		end		

		-- Play sounds
		caster:EmitSound("urgotREnd")
		target:EmitSound("urgotREnd")

		-- Disjoint projectiles
		ProjectileManager:ProjectileDodge(caster)
		if target:GetTeamNumber() == caster:GetTeamNumber() then
			ProjectileManager:ProjectileDodge(target)
		end

		-- Play caster particle
		local caster_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControlEnt(caster_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(caster_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

		-- Play target particle
		local target_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControlEnt(target_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(target_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

		local target_loc = target:GetAbsOrigin()
		local caster_loc = caster:GetAbsOrigin()
		

			-- Swap positions
			


			if caster:HasScepter() then
				self.allEnemies = FindUnitsInRadius(caster:GetTeamNumber(),
				Vector(0, 0, 0),
				nil,
				FIND_UNITS_EVERYWHERE,
				DOTA_UNIT_TARGET_TEAM_BOTH,
				self:GetAbilityTargetType(),
				self:GetAbilityTargetFlags(),
				FIND_ANY_ORDER,
				false)

				local allEnemiesPos = {}
				local shitCounter = 0
				for _,unit in pairs(self.allEnemies) do
					allEnemiesPos[shitCounter] = unit:GetOrigin()
					shitCounter = shitCounter + 1
				end

				local counter = math.random(0,table.getn(self.allEnemies)-1)
				for _,unit in pairs(self.allEnemies) do
					local targetPos = allEnemiesPos[counter%table.getn(self.allEnemies)]
					
						Timers:CreateTimer(FrameTime(), function()
							FindClearSpaceForUnit(unit, targetPos, true)
							EmitSoundOn("urgotREnd", unit)
						end)

					counter = counter+1
				end
			else
				Timers:CreateTimer(FrameTime(), function()
					FindClearSpaceForUnit(caster, target_loc, true)
					FindClearSpaceForUnit(target, caster_loc, true)
				end)
			end
			
	end
end

modifier_urgot_reverser = modifier_urgot_reverser or class({})

-- Modifier properties
function modifier_urgot_reverser:IsDebuff()			return false end
function modifier_urgot_reverser:IsHidden() 			return false end
function modifier_urgot_reverser:IsPurgable() 			return true end
function modifier_urgot_reverser:IsStunDebuff() 		return false end
function modifier_urgot_reverser:RemoveOnDeath() 		return true  end

function modifier_urgot_reverser:OnCreated()
	local ability = self:GetAbility()
	self.dmg_reduction = ability:GetSpecialValueFor("dmg_reduction")
end

function modifier_urgot_reverser:DeclareFunctions()
	local func = {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
	return func
end

function modifier_urgot_reverser:GetModifierIncomingDamage_Percentage( kv )
	return -self.dmg_reduction
end