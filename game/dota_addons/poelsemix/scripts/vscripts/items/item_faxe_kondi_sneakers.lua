item_faxe_kondi_sneakers = item_faxe_kondi_sneakers or class({})

LinkLuaModifier("modifier_item_faxe_kondi_sneakers", "items/item_faxe_kondi_sneakers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_faxe_kondi_sneakers_ms_burst", "items/item_faxe_kondi_sneakers", LUA_MODIFIER_MOTION_NONE)


function item_faxe_kondi_sneakers:GetIntrinsicModifierName()
	return "modifier_item_faxe_kondi_sneakers"
end

modifier_item_faxe_kondi_sneakers = modifier_item_faxe_kondi_sneakers or class({})

function modifier_item_faxe_kondi_sneakers:IsHidden()		return true end
function modifier_item_faxe_kondi_sneakers:IsPurgable()		return false end
function modifier_item_faxe_kondi_sneakers:RemoveOnDeath()	return false end
function modifier_item_faxe_kondi_sneakers:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end



function modifier_item_faxe_kondi_sneakers:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, 
		MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

function modifier_item_faxe_kondi_sneakers:OnAbilityExecuted(event)
    if event.unit ~= self:GetParent() then return end
	if event.ability:IsToggle() then return end
	if self:GetParent():HasModifier("modifier_item_faxe_kondi_sneakers_ms_burst") then
		self:GetParent():FindModifierByName("modifier_item_faxe_kondi_sneakers_ms_burst"):AddStack()
	else
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_faxe_kondi_sneakers_ms_burst", {})
	end
end
function modifier_item_faxe_kondi_sneakers:GetModifierPercentageCooldown()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("cdr")
    end
end

function modifier_item_faxe_kondi_sneakers:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("movement_speed")
    end
end
	
modifier_item_faxe_kondi_sneakers_ms_burst = modifier_item_faxe_kondi_sneakers_ms_burst or class({})

function modifier_item_faxe_kondi_sneakers_ms_burst:IsHidden()		return false end
function modifier_item_faxe_kondi_sneakers_ms_burst:IsPurgable()		return true end

function modifier_item_faxe_kondi_sneakers_ms_burst:OnCreated()
	if not IsServer() then return end
	self:AddStack()
end

function modifier_item_faxe_kondi_sneakers_ms_burst:AddStack()
	local stackcount = self:GetStackCount()
	local max_stackcount = self:GetAbility():GetSpecialValueFor("max_stacks")
	if stackcount < max_stackcount then self:SetStackCount(stackcount+1) end
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("stack_falloff"))
end

function modifier_item_faxe_kondi_sneakers_ms_burst:OnIntervalThink()
	self:Destroy()
end

function modifier_item_faxe_kondi_sneakers_ms_burst:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_item_faxe_kondi_sneakers_ms_burst:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("ms_perc_per_stack") * self:GetStackCount()
end

function modifier_item_faxe_kondi_sneakers_ms_burst:GetTexture()
	return "faxe_kondi_sneakers"
end