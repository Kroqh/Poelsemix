LinkLuaModifier("modifier_runover", "heroes/hero_nissan/runover", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_runover_stun", "heroes/hero_nissan/runover", LUA_MODIFIER_MOTION_NONE)

runover = class({})

function runover:GetAbilityTextureName()
	return "nissan_runover_icon"
end

function runover:OnSpellStart()
  if not IsServer() then return end
  local caster = self:GetCaster()
  local duration = self:GetSpecialValueFor("duration")
  if caster:FindAbilityByName("special_bonus_nissan_6"):GetLevel() > 0 then duration = duration + caster:FindAbilityByName("special_bonus_nissan_6"):GetSpecialValueFor("value") end 
  caster:EmitSound("nissan_runover")

  caster:AddNewModifier(caster, self, "modifier_runover", {duration = duration})
end

modifier_runover = class({})

function modifier_runover:IsHidden() return false end
function modifier_runover:IsPurgable() return false end
function modifier_runover:IsDebuff() return false end

function modifier_runover:OnCreated()
  self.movespeed = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
  
  local caster = self:GetCaster()
  if caster:FindAbilityByName("special_bonus_nissan_7"):GetLevel() > 0 then self.movespeed = self.movespeed + caster:FindAbilityByName("special_bonus_nissan_7"):GetSpecialValueFor("value") end 
  if not IsServer() then return end
  self.particle = "particles/units/heroes/hero_techies/techies_suicide_base.vpcf"
  local pfx = ParticleManager:CreateParticle(self.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
  ParticleManager:SetParticleControl(pfx, 2, Vector(1.5,1.5,1.5))
  
  caster:EmitSound("Hero_Techies.Suicide")

  self:StartIntervalThink(0.1)
end

function modifier_runover:OnRefresh()
	self:OnCreated()
end

function modifier_runover:DeclareFunctions()
  return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_runover:GetModifierMoveSpeedBonus_Percentage()
  return self.movespeed
end

function modifier_runover:OnIntervalThink()
  if not IsServer() then return end
  
  local ability = self:GetAbility()
  local caster = ability:GetCaster()

  local radius = ability:GetSpecialValueFor("radius")
  local stun_duration = ability:GetSpecialValueFor("stun_duration")
  local damage = ability:GetSpecialValueFor("damage")

  local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
                                    caster:GetAbsOrigin(), 
                                    nil, 
                                    radius, 
                                    ability:GetAbilityTargetTeam(), 
                                    ability:GetAbilityTargetType(),
                                    ability:GetAbilityTargetFlags(), 
                                    FIND_ANY_ORDER, false)
  
  for _, enemy in pairs(enemies) do 
    if not enemy:HasModifier("modifier_runover_stun") then
      -- Particles
      local pfx = ParticleManager:CreateParticle(self.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
      ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
      ParticleManager:SetParticleControl(pfx, 2, Vector(1.5,1.5,1.5))

      ApplyDamage({
				victim = enemy,
				attacker = caster,
				damage_type = ability:GetAbilityDamageType(),
				damage = damage,
				ability = ability
	    })
      enemy:AddNewModifier(caster, ability, "modifier_runover_stun", {duration = stun_duration})
      
      caster:EmitSound("Hero_Techies.Suicide")
    end
  end
end

modifier_runover_stun = class({})

function modifier_runover_stun:IgnoreTenacity() return true end
function modifier_runover_stun:IsPurgable() return false end
function modifier_runover_stun:IsHidden() return false end

function modifier_runover_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_runover_stun:OnCreated()
  if not IsServer() then return end
  self.angles = self:GetParent():GetAngles()
  self.ability = self:GetAbility()

  self:GetParent():SetAngles(-90, self.angles.y, self.angles.z)
end

function modifier_runover_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_runover_stun:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_runover_stun:OnDestroy()
  if not IsServer() then return end
  local parent = self:GetParent()
  local angles = parent:GetAngles()
  local radius = self.ability:GetSpecialValueFor("radius")
  parent:SetAngles(0, angles.y, angles.z)
end