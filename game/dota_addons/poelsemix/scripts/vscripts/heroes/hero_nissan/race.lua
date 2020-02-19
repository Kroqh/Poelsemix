LinkLuaModifier("modifier_race", "heroes/hero_nissan/race", LUA_MODIFIER_MOTION_NONE)

race = class({})
-- aldrig kig på det her igen

function race:GetAbilityTextureName()
	return "nissan_race_icon"
end

function race:OnSpellStart()
  if not IsServer() then return end
  self.caster = self:GetCaster()
  self.target = self:GetCursorTarget()
  self.duration = self:GetSpecialValueFor("duration")
  self.damage = self:GetSpecialValueFor("damage")

  if self.caster:HasTalent("special_bonus_nissan_4") then
    self.damage = self.damage + self.caster:FindAbilityByName("special_bonus_nissan_4"):GetSpecialValueFor("value")
  end
  
  -- Track stacks
  self.caster_stacks = self:GetSpecialValueFor("stacks")
  self.target_stacks = self:GetSpecialValueFor("stacks")

  -- Modifiers
  self.caster:AddNewModifier(self.caster, self, "modifier_race", {duration = self.duration})
  self.target:AddNewModifier(self.caster, self, "modifier_race", {duration = self.duration})

  self.player1 = PlayerResource:GetPlayerName(self.caster:GetPlayerID())
  self.player2 = PlayerResource:GetPlayerName(self.target:GetPlayerID())

  -- Custom message
  local message = '<font color="lime">' .. self.player1 .. '</font>' .. ' JUST CHALLENGED ' .. '<font color="red">' .. self.player2 .. '</font>' .. ' TO AN EPIC RACE!!'
  GameRules:SendCustomMessage(message, self.caster:GetTeamNumber(), -1)

  local song = math.random(4)
  local songs = {"nissan_dejavu", 
                 "nissan_gasgasgas", 
                 "nissan_nightoffire", 
                 "nissan_running"}

  self.caster:EmitSound(songs[song])

  -- Maybe has to uncomment.

  -- local units = FindUnitsInRadius(self.caster:GetTeamNumber(), 
  --                                               self.caster:GetAbsOrigin(), 
  --                                               nil, 
  --                                               FIND_UNITS_EVERYWHERE, 
  --                                               DOTA_UNIT_TARGET_TEAM_ENEMY, 
  --                                               DOTA_UNIT_TARGET_HERO, 
  --                                               DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
  --                                               FIND_ANY_ORDER, 
  --                                               false)

  -- for _, enemy in pairs(units) do 
  --   GameRules:SendCustomMessage(message, enemy:GetTeamNumber(), -1)
  -- end

end

modifier_race = class({})

function modifier_race:OnCreated() 
  if not IsServer() then return end
  self.ability = self:GetAbility()
  self.parent_last_pos = self:GetParent():GetAbsOrigin()
  self.are_you_caster = (self:GetParent():GetUnitName() == self.ability.caster:GetUnitName()) and true or false
  self.stacks = (self:GetParent():GetUnitName() == self.ability.caster:GetUnitName()) and self.ability.caster_stacks or self.ability.target_stacks

  self:SetStackCount(self.stacks)

  self:StartIntervalThink(0.1)
end

function modifier_race:OnIntervalThink()
  if not IsServer() then return end
  self.stacks = (self:GetParent():GetUnitName() == self.ability.caster:GetUnitName()) and self.ability.caster_stacks or self.ability.target_stacks

  local distance_diff = FindDistance(self:GetParent():GetAbsOrigin(), self.parent_last_pos)
  
  if distance_diff > 0 then
    self:SetStackCount(self.stacks - math.floor(distance_diff / 10))
    
    -- update stacks
    if self.are_you_caster then
      self.ability.caster_stacks = self:GetStackCount()
    else
      self.ability.target_stacks = self:GetStackCount()
    end
  end

  -- Parent has won
  if self.stacks <= 0 then
    self:Destroy()
  end

  self.parent_last_pos = self:GetParent():GetAbsOrigin()
end

function modifier_race:OnRemoved()
  if not IsServer() then return end
  local pfx = "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf"
  -- Race ends if someone dies.
  if self.ability.caster:GetHealth() <= 0 then
    self.ability.caster:EmitSound("Hero_LegionCommander.Duel.Victory")
		ParticleManager:CreateParticle(pfx, PATTACH_ABSORIGIN_FOLLOW, self.ability.caster)
    return
  else
    if self.ability.target:GetHealth() <= 0 then
      self.ability.target:EmitSound("Hero_LegionCommander.Duel.Victory")
		  ParticleManager:CreateParticle(pfx, PATTACH_ABSORIGIN_FOLLOW, self.ability.target)
      return
    end
  end

  local stack_difference = (self.ability.caster_stacks - self.ability.target_stacks)

  -- only apply one damage instance
  if self.are_you_caster then    
    -- caster lost
    if stack_difference > 0 then
      self.ability.target:EmitSound("Hero_LegionCommander.Duel.Victory")
		  ParticleManager:CreateParticle(pfx, PATTACH_ABSORIGIN_FOLLOW, self.ability.target)
      ApplyDamage({
        victim = self.ability.caster,
        attacker = self.ability.target,
        damage_type = DAMAGE_TYPE_PURE,
        damage = self.ability.damage,
        ability = self.ability
      }) 
    else        
    -- caster win
      self.ability.caster:EmitSound("Hero_LegionCommander.Duel.Victory")
		  ParticleManager:CreateParticle(pfx, PATTACH_ABSORIGIN_FOLLOW, self.ability.caster)
      ApplyDamage({
        victim = self.ability.target,
        attacker = self.ability.caster,
        damage_type = DAMAGE_TYPE_PURE,
        damage = self.ability.damage,
        ability = self.ability
      })
    end
  end
end

