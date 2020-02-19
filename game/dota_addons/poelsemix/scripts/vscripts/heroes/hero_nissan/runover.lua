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
  caster:EmitSound("nissan_runover")

  caster:AddNewModifier(caster, self, "modifier_runover", {duration = duration})
end

modifier_runover = class({})

function modifier_runover:IsHidden() return true end
function modifier_runover:IsDebuff() return false end

function modifier_runover:OnCreated()
  self.movespeed = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
  local caster = self:GetCaster()

  if not IsServer() then return end
  self.particle = "particles/units/heroes/hero_techies/techies_suicide_base.vpcf"
  local pfx = ParticleManager:CreateParticle(self.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
  ParticleManager:SetParticleControl(pfx, 2, Vector(1.5,1.5,1.5))
  
  caster:EmitSound("Hero_Techies.Suicide")

  self:StartIntervalThink(0.1)
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
                                    DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                    DOTA_UNIT_TARGET_FLAG_NONE, 
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
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage = damage,
				ability = ability
	    })
      enemy:AddNewModifier(caster, ability, "modifier_runover_stun", {duration = stun_duration})
      
      caster:EmitSound("Hero_Techies.Suicide")
    end
  end
end

modifier_runover_stun = class({})

function modifier_runover_stun:IsPurgeable() return false end
function modifier_runover_stun:IsHidden() return true end

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
  local found = false;
  local units = FindUnitsInRadius(parent:GetTeamNumber(), 
                                  parent:GetAbsOrigin(), 
                                  nil, 
                                  radius, 
                                  DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                  DOTA_UNIT_TARGET_FLAG_NONE, 
                                  FIND_ANY_ORDER, false)
  
  for _, enemy in pairs(units) do
    if enemy:GetUnitName() == "npc_dota_hero_ogre_magi" then found = true end;
  end

  if found then
    parent:SetAngles(-90, angles.y, angles.z)
  else
    parent:SetAngles(0, angles.y, angles.z)
  end
end