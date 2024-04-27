marvelous_golden_touch = marvelous_golden_touch or class({})
LinkLuaModifier( "modifier_marvelous_golden_touch", "heroes/hero_marvelous/marvelous_golden_touch", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function marvelous_golden_touch:GetIntrinsicModifierName()
	return "modifier_marvelous_golden_touch"
end


modifier_marvelous_golden_touch = modifier_marvelous_golden_touch or class({})

function modifier_marvelous_golden_touch:IsPassive() return true end

function modifier_marvelous_golden_touch:IsHidden() return true end

function modifier_marvelous_golden_touch:IsPurgable() return false end


function modifier_marvelous_golden_touch:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()

    pfx = "particles/econ/courier/courier_devourling_gold/courier_devourling_gold_ambient.vpcf"
    self.pfx_fire1 = ParticleManager:CreateParticle(pfx, PATTACH_POINT_FOLLOW, parent)

end

function modifier_marvelous_golden_touch:OnRemoved()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.pfx_fire1, false)
end


function modifier_marvelous_golden_touch:DeclareFunctions()
	local funcs	=	{
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end


function modifier_marvelous_golden_touch:OnAttackLanded( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
		if self:GetParent():PassivesDisabled() then return end

		local parent = self:GetParent()
		local chance = self:GetAbility():GetSpecialValueFor("trigger_chance")
	
		if RollPercentage(chance) then
			parent:ModifyGold(self:GetAbility():GetSpecialValueFor("gold_on_trigger"), false, 0)

			local damage = parent:GetGold() * (self:GetAbility():GetSpecialValueFor("gold_to_damage_ratio")/100)
			
			ApplyDamage({victim = params.target,
			attacker = parent,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			damage = damage,
			ability = self:GetAbility()
			})
			parent:EmitSound("marvelous_golden")
			ParticleManager:CreateParticle("particles/econ/courier/courier_flopjaw_gold/flopjaw_death_coins_gold.vpcf", PATTACH_ABSORIGIN, params.target)
		end
		

	end
end
