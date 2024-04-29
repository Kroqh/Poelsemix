flyby_attack = flyby_attack or class({})
LinkLuaModifier( "modifier_flyby_passive", "heroes/hero_shadow/flyby_attack", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flyby_attack", "heroes/hero_shadow/flyby_attack", LUA_MODIFIER_MOTION_NONE )

function flyby_attack:GetIntrinsicModifierName()
	return "modifier_flyby_passive"
end

modifier_flyby_passive = modifier_flyby_passive or class({})


function modifier_flyby_passive :IsPurgable() return false end
function modifier_flyby_passive :IsPassive() return true end
function modifier_flyby_passive :IsHidden() return true end

function modifier_flyby_passive:OnCreated()
	if IsServer() then
		self.wait = self:GetAbility():GetSpecialValueFor("teleport_cooldown")
		self.count = 0
		self:StartIntervalThink(0.1)
	end
end

function modifier_flyby_passive :OnRefresh()
	if IsServer() then
		self.wait = self:GetAbility():GetSpecialValueFor("teleport_cooldown")
	end
end


function modifier_flyby_passive :OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		if self.count >= self.wait then
			
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_flyby_attack", {})
            self.count = 0
        end
		if (not parent:HasModifier("modifier_flyby_attack")) then
			self.count = self.count + 0.1
		end
	end
end


modifier_flyby_attack = modifier_flyby_attack or class({})


function modifier_flyby_attack:IsHidden()
	return false
end

function modifier_flyby_attack:IsPurgable()
	return false
end

function modifier_flyby_attack:IsDebuff()
	return false
end

function modifier_flyby_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}

	return funcs
end
function modifier_flyby_attack:GetModifierAttackRangeBonus()
	local range_multi = self:GetAbility():GetSpecialValueFor("range_per_ms")
	if self:GetCaster():FindAbilityByName("special_bonus_shadow_3"):GetLevel() > 0 then range_multi = range_multi + self:GetCaster():FindAbilityByName("special_bonus_shadow_3"):GetSpecialValueFor("value") end 
	return self:GetCaster():GetIdealSpeed() * range_multi
end
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

function modifier_flyby_attack:OnAttackStart( params )
	if not IsServer() then return end
	if (params.attacker ~= self:GetParent()) then return end
	if params.target == nil then
		return
	end
	
	----------------------------------------------------
	-- Finds the distance between attacker and target --
	----------------------------------------------------
	local self_pos = params.attacker:GetAbsOrigin()	--casters position
    local target_pos = params.target:GetAbsOrigin()	--targets position
    local dis_vec = target_pos - self_pos		--vector between caster and target
    local dis = math.sqrt((dis_vec.x*dis_vec.x)+(dis_vec.y*dis_vec.y))		--distance between caster and target

	
	----------------------------------------------------
	--    Determines damage bonus based on distance    --
	----------------------------------------------------
	damage_scaling = self:GetAbility():GetSpecialValueFor( "damage_per_distance" )
	if self:GetCaster():FindAbilityByName("special_bonus_shadow_6"):GetLevel() > 0 then damage_scaling = damage_scaling + self:GetCaster():FindAbilityByName("special_bonus_shadow_6"):GetSpecialValueFor("value") end 

	self.damage = damage_scaling * dis 
	
	FindClearSpaceForUnit(params.attacker, target_pos, true)
	
end

--------------------------------------------------------------------------------

function modifier_flyby_attack:OnAttackLanded( params )
	if IsServer() then
		if (params.attacker ~= self:GetParent()) then return end 
		EmitSoundOn("shadow_teleport_behind", params.attacker)
		local particle_blood = "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg_blood.vpcf"
		local particle_blood_fx = ParticleManager:CreateParticle(particle_blood, PATTACH_ABSORIGIN_FOLLOW, params.target)
		ParticleManager:SetParticleControl(particle_blood_fx, 0, params.target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_blood_fx)
		
		local damageTable = {
				victim = params.target,
				damage = self.damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
				attacker = params.attacker,
				ability = self:GetAbility()
			}

		ApplyDamage(damageTable)
		self:GetParent():RemoveModifierByName("modifier_flyby_attack")
		
	end
	
end
--------------------------------------------------------------------------------
