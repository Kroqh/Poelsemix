-- Parts learned from Dota IMBA Phoenix

LinkLuaModifier("modifier_longlights_dummy", "heroes/hero_nissan/longlights", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_longlights_blind", "heroes/hero_nissan/longlights", LUA_MODIFIER_MOTION_NONE)

longlights = class({})

function longlights:GetAbilityTextureName()
	return "nissan_longlights_icon"
end

function longlights:OnSpellStart()
  if not IsServer() then return end
  self.caster = self:GetCaster()

  self.caster:EmitSound("nissan_light")

  -- Initialize particles
  local particleName = "particles/heroes/nissan/nissan_lights.vpcf"
  local pfx = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, nil)
  local attach_point = self.caster:ScriptLookupAttachment("attach_origin")

  -- Dummy modifier
  local modifier_dummy_name = "modifier_longlights_dummy"

  -- Ability values
  local duration = self:GetSpecialValueFor("duration")
  local lights_length = self:GetSpecialValueFor("length")

  -- Talent
  if self.caster:HasTalent("special_bonus_nissan_1") then
    lights_length = lights_length + self.caster:FindAbilityByName("special_bonus_nissan_1"):GetSpecialValueFor("value")
  end

  local width = self:GetSpecialValueFor("width")
  local damage_per_tick = self:GetSpecialValueFor("damage_pr_tick")
  local vision_radius = self:GetSpecialValueFor("width") * 3
  local numVision = math.ceil(lights_length / vision_radius)

  local update_time = 0.03

  self.caster:AddNewModifier(self.caster, self, modifier_dummy_name, { duration = duration })

  self.caster:SetContextThink(DoUniqueString("updateLongLights"), function()
    if not self.caster:HasModifier(modifier_dummy_name) then
      ParticleManager:DestroyParticle(pfx, false)
      return nil
    end

    local forward_direction = self.caster:GetForwardVector()
    local caster_pos = self.caster:GetAbsOrigin()

    local particle_end_pos = caster_pos + forward_direction * lights_length

    local units = FindUnitsInLine(self.caster:GetTeamNumber(), 
                                  caster_pos, 
                                  particle_end_pos, 
                                  self.caster, 
                                  width, 
                                  DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
                                  DOTA_UNIT_TARGET_FLAG_NONE)

    for _, enemy in pairs(units) do
      ApplyDamage({victim = enemy, 
                   attacker = self.caster, 
                   damage_type = DAMAGE_TYPE_MAGICAL, 
                   damage = damage_per_tick, 
                   ability = self})
      enemy:AddNewModifier(self.caster, self, "modifier_longlights_blind", {duration = 0.2})
    end

    ParticleManager:SetParticleControl(pfx, 0, self.caster:GetAttachmentOrigin(attach_point))
    
    ParticleManager:SetParticleControl(pfx, 1, particle_end_pos)

    for i=1, numVision do
      AddFOWViewer(self.caster:GetTeamNumber(), 
                  (caster_pos + forward_direction * (vision_radius * 2 * (i-1))), 
                   vision_radius, 
                   update_time, false)
    end

    return update_time
  end, 0.0)
  
  ParticleManager:SetParticleControl(pfx, 0, self.caster:GetAttachmentOrigin(attach_point))
end

modifier_longlights_dummy = modifier_longlights_dummy or class({})

function modifier_longlights_dummy:IsDebuff() return false end
function modifier_longlights_dummy:IsPurgable() return false end
function modifier_longlights_dummy:IsPurgeException() return false end
function modifier_longlights_dummy:IsStunDebuff() return false end
function modifier_longlights_dummy:RemoveOnDeath() return true end

modifier_longlights_blind = modifier_longlights_blind or class({})

function modifier_longlights_blind:IsDebuff() return true end
function modifier_longlights_blind:IsPurgable() return false end
function modifier_longlights_blind:IsPurgeException() return false end
function modifier_longlights_blind:IsStunDebuff() return false end

function modifier_longlights_blind:GetEffectName()
 return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end

function modifier_longlights_blind:OnCreated()
  self.ability = self:GetAbility()

  self.miss_rate = self.ability:GetSpecialValueFor("miss_chance")
end

function modifier_longlights_blind:DeclareFunctions()
 local decFuncs = {
    MODIFIER_PROPERTY_MISS_PERCENTAGE
    }

    return decFuncs
end

function modifier_longlights_blind:GetModifierMiss_Percentage()
  return self.miss_rate
end





