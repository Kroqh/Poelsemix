LinkLuaModifier("modifier_mewtwo_shadow_ball_debuff", "heroes/hero_mewtwo/mewtwo_shadow_ball", LUA_MODIFIER_MOTION_NONE)
mewtwo_shadow_ball = mewtwo_shadow_ball or class({});


function mewtwo_shadow_ball:GetCooldown(level)
    local cd = self.BaseClass.GetCooldown(self,level)
    if self:GetCaster():FindAbilityByName("special_bonus_mewtwo_2"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_mewtwo_2"):GetSpecialValueFor("value") end
    return cd
end

function mewtwo_shadow_ball:GetAOERadius()
    return self:GetSpecialValueFor("aoe_radius")
end


function mewtwo_shadow_ball:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():EmitSound("mewtwo_shadow_ball_cast");
    end
end
function mewtwo_shadow_ball:OnSpellStart() 
	if IsServer() then
		local caster 						= self:GetCaster();
		local target 						= self:GetCursorPosition();
		local aoe_radius 					= self:GetSpecialValueFor("aoe_radius");

		local attack_slow 					= self:GetSpecialValueFor("attack_slow");
		local cdr_units 					= self:GetSpecialValueFor("cdr_units");
		local splinter_threshold			= self:GetSpecialValueFor("threshold");
		local splinter_dmg_efficiency		= self:GetSpecialValueFor("splinter_dmg_efficiency");
		local splinter_aoe_efficiency		= self:GetSpecialValueFor("splinter_aoe_efficiency");
		local damage 						= self:GetSpecialValueFor("damage");
		local speed							= self:GetSpecialValueFor("projectile_speed")
        local debuff_duration 				= self:GetSpecialValueFor("duration");

		mewtwo_shadow_ball:CreateLinearProjectile(
		{
			target 						= target,
			caster 						= caster,
			ability 					= self,
			iMoveSpeed 					= speed,
			iSourceAttachment 			= DOTA_PROJECTILE_ATTACHMENT_ATTACK_1 ,
			EffectName 					= "particles/units/heroes/hero_mewtwo/shadow_ball_projectile.vpcf",
			aoe_radius				=  aoe_radius,
			debuff_duration 	 				= debuff_duration,
			damage 						= damage,
		});	
	end
end

-- cursed imba code
function mewtwo_shadow_ball:CreateLinearProjectile(keys)
    local target = keys.target;
    local caster = keys.caster;
    local speed = keys.iMoveSpeed;
 
    -- Set creation time in the parameters
    keys.creation_time = GameRules:GetGameTime();
 
    -- Fetch initial projectile location
    local projectile = caster:GetAttachmentOrigin(keys.iSourceAttachment);
 
    -- Make the particle
    local particle = ParticleManager:CreateParticle(keys.EffectName, PATTACH_POINT, caster);


    -- Source CP
    ParticleManager:SetParticleControl(particle, 0, caster:GetAttachmentOrigin(keys.iSourceAttachment));
    -- TargetCP
    ParticleManager:SetParticleControl(particle, 1, target);
    -- Speed CP
    ParticleManager:SetParticleControl(particle, 2, Vector(speed, 0, 0));
    
    Timers:CreateTimer(function()

 
        -- Move the projectile towards the target
        projectile = projectile + (target - projectile):Normalized() * speed * FrameTime();
 
        -- Check the distance to the target
        if (target - projectile):Length2D() < speed * FrameTime() then
            -- Target has reached destination!
            mewtwo_shadow_ball:OnProjectileHit(keys);
            -- Destroy particle
            ParticleManager:DestroyParticle(particle, false);
            -- Release particle index
            ParticleManager:ReleaseParticleIndex(particle);
 
            -- Stop the timer
            return nil
        else

            -- Reschedule for next frame
            return 0
        end
    end)

end

function mewtwo_shadow_ball:OnProjectileHit(keys)
    if  not IsServer() then return end
	
    EmitSoundOnLocationWithCaster(keys.target, "mewtwo_shadow_ball_hit", keys.caster);
	local nearby_enemy_units = FindUnitsInRadius(
		keys.caster:GetTeam(),
		keys.target, 
		nil, 
		keys.aoe_radius, 
		keys.ability:GetAbilityTargetTeam(),
		keys.ability:GetAbilityTargetType(), 
		keys.ability:GetAbilityTargetFlags(), 
		FIND_ANY_ORDER, 
		false
	);

	for _,enemy in pairs(nearby_enemy_units) do 

			local damage_table 			= {};
		    damage_table.attacker 		= keys.caster;
		    damage_table.ability 		= keys.ability;
		    damage_table.damage_type 	= keys.ability:GetAbilityDamageType();
		    damage_table.damage	 		= keys.damage;
		    damage_table.victim  		= enemy;
		    ApplyDamage(damage_table)

            enemy:AddNewModifier(keys.caster, keys.ability, "modifier_mewtwo_shadow_ball_debuff", {duration = keys.debuff_duration});
	end

    return true
end



modifier_mewtwo_shadow_ball_debuff = modifier_mewtwo_shadow_ball_debuff or class({})
function modifier_mewtwo_shadow_ball_debuff:IsHidden() return false end
function modifier_mewtwo_shadow_ball_debuff:IsDebuff() return true end
function modifier_mewtwo_shadow_ball_debuff:IsPurgable() return true end

function modifier_mewtwo_shadow_ball_debuff:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_mewtwo_shadow_ball_debuff:OnCreated(keys)

    self.magic_reduction = self:GetAbility():GetSpecialValueFor("magic_resist_reduction")
	if self:GetCaster():FindAbilityByName("special_bonus_mewtwo_3"):GetLevel() > 0 then self.magic_reduction = self.magic_reduction + self:GetCaster():FindAbilityByName("special_bonus_mewtwo_3"):GetSpecialValueFor("value") end
	if IsServer() then 
		self.hit_particle 	= ParticleManager:CreateParticle("particles/units/heroes/hero_mewtwo/shadow_ball_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent());
		ParticleManager:SetParticleControl(self.hit_particle, 0, self:GetParent():GetAbsOrigin());
	end
end

function modifier_mewtwo_shadow_ball_debuff:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.hit_particle, false);
		ParticleManager:ReleaseParticleIndex(self.hit_particle);
		
	end
end

function modifier_mewtwo_shadow_ball_debuff:GetModifierMagicalResistanceBonus()
	return self.magic_reduction
end
