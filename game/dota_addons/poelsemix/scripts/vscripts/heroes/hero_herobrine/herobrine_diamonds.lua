LinkLuaModifier( "modifier_herobrine_diamonds_active", "heroes/hero_herobrine/herobrine_diamonds", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_herobrine_diamonds_diamond", "heroes/hero_herobrine/herobrine_diamonds", LUA_MODIFIER_MOTION_NONE )
herobrine_diamonds = herobrine_diamonds or class({})


function herobrine_diamonds:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
	caster:EmitSound("DIAMONDS")
	caster:AddNewModifier(caster, self, "modifier_herobrine_diamonds_active", {duration = self:GetSpecialValueFor("duration")})
end

function herobrine_diamonds:GetCastRange()
	local range = self:GetSpecialValueFor("radius")
	return range
end

modifier_herobrine_diamonds_active = modifier_herobrine_diamonds_active or class({})

function modifier_herobrine_diamonds_active:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.05)
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_herobrine_diamonds_active:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self.radius, ability:GetAbilityTargetTeam(), 
    ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)


	for _, enemy in pairs(units) do
        self:CheckGaze(enemy)
    end
end

function modifier_herobrine_diamonds_active:CheckGaze(enemy)
	local caster = self:GetCaster()
	local vision_cone = self:GetAbility():GetSpecialValueFor("vision_cone")

	local caster_location = caster:GetAbsOrigin()
	local target_location = enemy:GetAbsOrigin()	

	-- Angle calculation
	local direction = (caster_location - target_location):Normalized()
	local forward_vector = enemy:GetForwardVector()
	local angle = math.abs(RotationDelta((VectorToAngles(direction)), VectorToAngles(forward_vector)).y)

	if angle <= vision_cone/2 then
			enemy:AddNewModifier(caster, self:GetAbility(), "modifier_herobrine_diamonds_diamond", {Duration = 0.1})
	end
end

function modifier_herobrine_diamonds_active:GetEffectName()
	return "particles/econ/events/ti5/teleport_start_c_ti5.vpcf"
end
function modifier_herobrine_diamonds_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_herobrine_diamonds_diamond = modifier_herobrine_diamonds_diamond or class({})
function modifier_herobrine_diamonds_diamond:IsDebuff() return true end

function modifier_herobrine_diamonds_diamond:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_dire.vpcf"
end
function modifier_herobrine_diamonds_diamond:StatusEffectPriority()
	return 50
end
function modifier_herobrine_diamonds_diamond:DeclareFunctions()
	local decFuncs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
}
    return decFuncs
end

function modifier_herobrine_diamonds_diamond:OnAttackLanded( params )
	if not IsServer() then return end
	if params.target ~= self:GetParent() then return end 
	ParticleManager:CreateParticle("particles/econ/courier/courier_flopjaw_gold/flopjaw_death_coins_gold.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    self:GetCaster():ModifyGold(self:GetAbility():GetSpecialValueFor("bonus_gold"), false, 0)
	params.target:EmitSound("diamondcling")
end


function modifier_herobrine_diamonds_diamond:CheckState()
	local state =
		{
			[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_FROZEN] = true
		}
	return state
end

function modifier_herobrine_diamonds_diamond:GetModifierIncomingDamage_Percentage( params )
    if params.target == self:GetParent() then  
       return -self:GetAbility():GetSpecialValueFor("damage_resist")
    end
    return
end