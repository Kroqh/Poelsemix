LinkLuaModifier("modifier_baseboys_concert_cast", "heroes/hero_baseboys/baseboys_concert", LUA_MODIFIER_MOTION_NONE)

baseboys_concert = baseboys_concert or class({})


function baseboys_concert:GetCooldown(level)

	local cd = self.BaseClass.GetCooldown(self,level)
    if self:GetCaster():FindAbilityByName("special_bonus_baseboys_6"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_baseboys_6"):GetSpecialValueFor("value") end
    return cd
end

function baseboys_concert:OnSpellStart()
	if not IsServer() then return end

	local band_count = self:GetSpecialValueFor("band_count")
	local image_out_dmg = self:GetSpecialValueFor("outgoing_damage")
    local image_in_dmg = self:GetSpecialValueFor("incoming_damage")
    local band_duration = self:GetSpecialValueFor("illusion_duration")
    local cast_duration = self:GetSpecialValueFor("cast_duration")

    if self:GetCaster():FindAbilityByName("special_bonus_baseboys_7"):GetLevel() > 0 then band_count = band_count + self:GetCaster():FindAbilityByName("special_bonus_baseboys_7"):GetSpecialValueFor("value") end


	local vRandomSpawnPos = { --huh
		Vector(108, 0, 0),
		Vector(108, 108, 0),
		Vector(108, 0, 0),
		Vector(0, 108, 0),
		Vector(-108, 0, 0),
		Vector(-108, 108, 0),
		Vector(-108, -108, 0),
		Vector(0, -108, 0),
	}

	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_baseboys/concert.vpcf", PATTACH_ABSORIGIN, self:GetCaster())

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_baseboys_concert_cast", {duration = cast_duration})

	if self.illusions then
		for _, illusion in pairs(self.illusions) do
			if IsValidEntity(illusion) and illusion:IsAlive() then
				illusion:ForceKill(false)
			end
		end
	end

	self:GetCaster():SetContextThink(DoUniqueString("baseboys_concert"), function()
		self.illusions = CreateIllusions(self:GetCaster(), self:GetCaster(), {
			outgoing_damage 			= image_out_dmg,
			incoming_damage				= image_in_dmg,
			duration					= band_duration
		}, band_count, self:GetCaster():GetHullRadius(), true, true)

		for i = 1, #self.illusions do
			local illusion = self.illusions[i]
			local pos = self:GetCaster():GetAbsOrigin() + vRandomSpawnPos[i]
			FindClearSpaceForUnit(illusion, pos, true)
			local part2 = ParticleManager:CreateParticle("particles/units/heroes/hero_baseboys/baseboys_concert_foam.vpcf", PATTACH_ABSORIGIN, illusion)
			ParticleManager:ReleaseParticleIndex(part2)
		end

		ParticleManager:DestroyParticle(pfx, false)
		ParticleManager:ReleaseParticleIndex(pfx)

		self:GetCaster():Stop()
        

		return nil
	end, cast_duration)

	if self:GetCaster():HasItemInInventory("item_norwegian_eul") then
        self:GetCaster():EmitSound("baseboys_1000_norsk")
    else
        self:GetCaster():EmitSound("baseboys_1000_dansk")
    end
end

function baseboys_concert:GetIllusions()
    if self.illusions then
		return self.illusions
	else
        return false
    end
end

modifier_baseboys_concert_cast = mmodifier_baseboys_concert_cast or class({})

function modifier_baseboys_concert_cast:IsHidden() return true end

function modifier_baseboys_concert_cast:CheckState() return {
	[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_STUNNED] = true,
	-- [MODIFIER_STATE_OUT_OF_GAME] = true,
} end
