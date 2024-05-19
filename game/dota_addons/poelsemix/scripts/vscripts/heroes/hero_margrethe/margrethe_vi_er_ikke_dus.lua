margrethe_vi_er_ikke_dus = margrethe_vi_er_ikke_dus or class({})

LinkLuaModifier( "modifier_margrethe_vi_er_ikke_dus_buff", "heroes/hero_margrethe/margrethe_vi_er_ikke_dus", LUA_MODIFIER_MOTION_NONE )

function margrethe_vi_er_ikke_dus:GetCastRange()
    local range = self:GetSpecialValueFor("range")
    return range
end


function margrethe_vi_er_ikke_dus:GetChannelTime()
    return self:GetSpecialValueFor("channel_duration")
end

function margrethe_vi_er_ikke_dus:OnSpellStart()
    if  not IsServer() then return end
    local caster= self:GetCaster()
    caster:EmitSound("margrethe_vi_er_ikke_dus");
    
    self.range	=  self:GetSpecialValueFor("range")
    self.dmg = self:GetSpecialValueFor("damage")
    self.buff_duration =self:GetSpecialValueFor("buff_duration")
    local number_of_slashes = self:GetSpecialValueFor("base_slashes") + (math.floor(caster:GetIntellect() * self:GetSpecialValueFor("slash_scaling")))
    self.interval = self:GetChannelTime() / number_of_slashes
	self.elapsedTime = 0
    caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_6,number_of_slashes)

    -- Current position & direction
    self.casterOrigin	= caster:GetAbsOrigin()
    self.direction = (self:GetCursorPosition() - self.casterOrigin):Normalized()
end

function margrethe_vi_er_ikke_dus:OnChannelThink(think)
    if  not IsServer() then return end
    local caster	= self:GetCaster()
    self.elapsedTime = self.elapsedTime + think
    
    if self.elapsedTime >= self.interval then

        local direction = self:GetDirection(self.direction)
        local slash = 
				{
					EffectName 			= "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf",
					Ability 			= self,
					vSpawnOrigin 		= caster:GetAbsOrigin(),
					vVelocity 			= direction * self:GetSpecialValueFor("slash_speed"),
					fDistance 			= self.range,
					fStartRadius 		= self:GetSpecialValueFor("slash_width_start"),
					fEndRadius 			= self:GetSpecialValueFor("slash_width_end"),
					Source 				= caster,
					bHasFrontalCone 	= true,
					bReplaceExisting 	= false,
					iUnitTargetTeam 	= self:GetAbilityTargetTeam(),
					iUnitTargetFlags 	= self:GetAbilityTargetFlags(),
					iUnitTargetType 	= self:GetAbilityTargetType(),
					ExtraData = {
						damage 				= self.dmg
					}
				}

				ProjectileManager:CreateLinearProjectile(slash)
        caster:EmitSound("margrethe_slash")
        self.elapsedTime = 0
    end
end

function margrethe_vi_er_ikke_dus:OnProjectileHit_ExtraData(target, location, ExtraData)
    if not IsServer() then return end
    
    if target then
        local caster = self:GetCaster()

        ApplyDamage({victim = target,
		attacker = caster,
		damage_type = self:GetAbilityDamageType(),
		damage = ExtraData.damage,
		ability = self})

        local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self.range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for i, hero in pairs(heroes) do
            if not hero:HasModifier("modifier_margrethe_vi_er_ikke_dus_buff") then
                local mod = hero:AddNewModifier(caster, self, "modifier_margrethe_vi_er_ikke_dus_buff", {duration = self.buff_duration})
                mod:SetStackCount(1)
            else
                local mod = hero:FindModifierByName("modifier_margrethe_vi_er_ikke_dus_buff")
                mod:SetStackCount(mod:GetStackCount() + 1)
                mod:SetDuration(self.buff_duration, true)
            end
        end
        return true
    end	
end

function margrethe_vi_er_ikke_dus:rotate(x, y, angle)
    local cos_angle = math.cos(angle)
    local sin_angle = math.sin(angle)
    return x * cos_angle - y * sin_angle, x * sin_angle + y * cos_angle
end

function margrethe_vi_er_ikke_dus:GetDirection(dir)
    local spread = self:GetSpecialValueFor("angle_spread_each_side_radian")
    local random = RandomFloat(-spread,spread)
    local spread_dir_x, spread_dir_y = self:rotate(dir.x, dir.y, random)
    return Vector(spread_dir_x, spread_dir_y, 0)
end

function margrethe_vi_er_ikke_dus:OnChannelFinish(interrupted)
    if  not IsServer() then return end
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_6)
end


modifier_margrethe_vi_er_ikke_dus_buff = modifier_margrethe_vi_er_ikke_dus_buff or class({})

function modifier_margrethe_vi_er_ikke_dus_buff:IsDebuff() return false end
function modifier_margrethe_vi_er_ikke_dus_buff:IsPurgable() return false end

function modifier_margrethe_vi_er_ikke_dus_buff:OnCreated()
    self.as_per_stack = self:GetAbility():GetSpecialValueFor("as_stack")
    self.dmg_per_stack = self:GetAbility():GetSpecialValueFor("dmg_stack")
end

function modifier_margrethe_vi_er_ikke_dus_buff:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end

function modifier_margrethe_vi_er_ikke_dus_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount() * self.as_per_stack
end
function modifier_margrethe_vi_er_ikke_dus_buff:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount() * self.dmg_per_stack
end