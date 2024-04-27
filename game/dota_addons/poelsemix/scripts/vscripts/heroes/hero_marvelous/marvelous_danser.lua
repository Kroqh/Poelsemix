marvelous_danser = marvelous_danser or class({})
LinkLuaModifier( "modifier_marvelous_danser", "heroes/hero_marvelous/marvelous_danser", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function marvelous_danser:GetIntrinsicModifierName()
	return "modifier_marvelous_danser"
end


modifier_marvelous_danser = modifier_marvelous_danser or class({})

function modifier_marvelous_danser:IsPassive() return true end

function modifier_marvelous_danser:IsHidden() return false end

function modifier_marvelous_danser:IsPurgable() return false end


function modifier_marvelous_danser:OnCreated()
	if IsServer() then
		self:SetStackCount(0)
	end
end


function modifier_marvelous_danser:DeclareFunctions()
	local funcs	=	{
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end


function modifier_marvelous_danser:OnAttackLanded( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
		if self:GetParent():PassivesDisabled() then return end

		local stack_count = self:GetAbility():GetSpecialValueFor("max_stacks")
		if self:GetCaster():FindAbilityByName("special_bonus_marvelous_2"):GetLevel() > 0 then stack_count = stack_count + self:GetCaster():FindAbilityByName("special_bonus_marvelous_2"):GetSpecialValueFor("value") end 


		if (self:GetStackCount() < stack_count) then
			self:IncrementStackCount()
		end
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("time_for_fall_off"))
		

	end
end

function modifier_marvelous_danser:OnIntervalThink()
	if IsServer() then
		self:SetStackCount(0)
	end
end


function modifier_marvelous_danser:GetModifierIncomingDamage_Percentage()
	if not IsServer() then return end
	local parent = self:GetParent()
	local chance = self:GetAbility():GetSpecialValueFor("dodge_chance_pct")
	local chance_per_stack = self:GetAbility():GetSpecialValueFor("dodge_chance_per_stack")
	
	chance = chance + (chance_per_stack * self:GetStackCount())

	if parent:HasModifier("modifier_marvelous_antikommerciel_masseappel") then

		local scaler = parent:FindModifierByName("modifier_marvelous_antikommerciel_masseappel"):GetAbility():GetSpecialValueFor("danser_multiplier")
		if self:GetCaster():FindAbilityByName("special_bonus_marvelous_7"):GetLevel() > 0 then scaler = scaler + self:GetCaster():FindAbilityByName("special_bonus_marvelous_7"):GetSpecialValueFor("value") end 
		chance = chance * scaler
	end

	if RollPercentage(chance) then
		local backtrack_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN, parent)
		ParticleManager:SetParticleControl(backtrack_fx, 0, parent:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(backtrack_fx)
		return -100
	end
	
end
