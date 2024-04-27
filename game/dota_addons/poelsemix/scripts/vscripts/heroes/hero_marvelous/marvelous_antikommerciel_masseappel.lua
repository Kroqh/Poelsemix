marvelous_antikommerciel_masseappel = marvelous_antikommerciel_masseappel or class({})

LinkLuaModifier( "modifier_marvelous_antikommerciel_masseappel", "heroes/hero_marvelous/marvelous_antikommerciel_masseappel", LUA_MODIFIER_MOTION_NONE )


function marvelous_antikommerciel_masseappel:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		EmitSoundOn("masseappel", caster)
		caster:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)

		local partfire = "particles/units/heroes/hero_marvelous/antikommerciel.vpcf"
		self.pfx = ParticleManager:CreateParticle(partfire, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(self.pfx,0, Vector(0,0,200))

	end
end




function marvelous_antikommerciel_masseappel:OnChannelFinish(bInterrupted)
	if IsServer() then
		local caster = self:GetCaster()
		caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
		if bInterrupted then
			caster:StopSound("masseappel")
			ParticleManager:DestroyParticle(self.pfx, true)
			return 
		end
		local duration = self:GetSpecialValueFor("duration")

		EmitSoundOn("Hero_Riki.Smoke_Screen", caster)
		caster:AddNewModifier(caster, self, "modifier_marvelous_antikommerciel_masseappel", {duration = duration})

	end
end

modifier_marvelous_antikommerciel_masseappel = modifier_marvelous_antikommerciel_masseappel or class({})

-- Modifier properties
function modifier_marvelous_antikommerciel_masseappel:IsDebuff()			return false end
function modifier_marvelous_antikommerciel_masseappel:IsHidden() 			return false end
function modifier_marvelous_antikommerciel_masseappel:IsPurgable() 			return true end
function modifier_marvelous_antikommerciel_masseappel:RemoveOnDeath() 		return true  end

function modifier_marvelous_antikommerciel_masseappel:OnCreated()
	if not IsServer() then return end
	local ability = self:GetAbility()

	local dmg_scaling = ability:GetSpecialValueFor("attack_damage_percent")
	if self:GetCaster():FindAbilityByName("special_bonus_marvelous_5"):GetLevel() > 0 then dmg_scaling = dmg_scaling + self:GetCaster():FindAbilityByName("special_bonus_marvelous_5"):GetSpecialValueFor("value") end 

	self.dmg =  self:GetParent():GetAttackDamage() * (dmg_scaling/100) 
	self:SetHasCustomTransmitterData(true)
end

function modifier_marvelous_antikommerciel_masseappel:AddCustomTransmitterData()
    return {
        dmg = self.dmg

    }
end

function modifier_marvelous_antikommerciel_masseappel:HandleCustomTransmitterData( data )
    self.dmg = data.dmg

end


function modifier_marvelous_antikommerciel_masseappel:OnRemoved()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self:GetAbility().pfx, false)
	
end

function modifier_marvelous_antikommerciel_masseappel:DeclareFunctions()
	local func = {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
	return func
end

function modifier_marvelous_antikommerciel_masseappel:GetModifierBaseAttack_BonusDamage()
	return self.dmg
end


function modifier_marvelous_antikommerciel_masseappel:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_marvelous_antikommerciel_masseappel:GetEffectName()
    return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end