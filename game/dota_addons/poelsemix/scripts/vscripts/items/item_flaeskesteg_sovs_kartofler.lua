item_flaeskesteg_sovs_kartofler = item_flaeskesteg_sovs_kartofler or class({})

LinkLuaModifier("modifier_item_flaeskesteg_sovs_kartofler", "items/item_flaeskesteg_sovs_kartofler", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_flaeskesteg_sovs_kartofler_handler_unique", "items/item_flaeskesteg_sovs_kartofler", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_flaeskesteg_healing", "items/item_flaeskesteg_healing", LUA_MODIFIER_MOTION_NONE)

function item_flaeskesteg_sovs_kartofler:GetIntrinsicModifierName()
	return "modifier_item_flaeskesteg_sovs_kartofler"
end

modifier_item_flaeskesteg_sovs_kartofler = modifier_item_flaeskesteg_sovs_kartofler or class({})
function modifier_item_flaeskesteg_sovs_kartofler:IsHidden()		return true end
function modifier_item_flaeskesteg_sovs_kartofler:IsPurgable()		return false end
function modifier_item_flaeskesteg_sovs_kartofler:RemoveOnDeath()	return false end
function modifier_item_flaeskesteg_sovs_kartofler:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_flaeskesteg_sovs_kartofler:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS

	}
end
function modifier_item_flaeskesteg_sovs_kartofler:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("armor")
    end
end

function modifier_item_flaeskesteg_sovs_kartofler:GetModifierMagicalResistanceBonus()
if self:GetAbility() then
	return self:GetAbility():GetSpecialValueFor("magic_resist")
end
end
function modifier_item_flaeskesteg_sovs_kartofler:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("hp")
    end
end
function modifier_item_flaeskesteg_sovs_kartofler:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("str")
    end
end

function modifier_item_flaeskesteg_sovs_kartofler:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_flaeskesteg_sovs_kartofler_handler_unique") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_flaeskesteg_sovs_kartofler_handler_unique", {})
		end
	end
end

function modifier_item_flaeskesteg_sovs_kartofler:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_flaeskesteg_sovs_kartofler") then
			parent:RemoveModifierByName("modifier_item_flaeskesteg_sovs_kartofler_handler_unique")
		end
		if parent:HasModifier("modifier_item_flaeskesteg_healing") then parent:RemoveModifierByName("modifier_item_flaeskesteg_healing") end
	end
end


modifier_item_flaeskesteg_sovs_kartofler_handler_unique = modifier_item_flaeskesteg_sovs_kartofler_handler_unique or class({})
function modifier_item_flaeskesteg_sovs_kartofler_handler_unique:IsHidden()		return true end
function modifier_item_flaeskesteg_sovs_kartofler_handler_unique:IsPurgable()		return false end
function modifier_item_flaeskesteg_sovs_kartofler_handler_unique:RemoveOnDeath()	return false end

function modifier_item_flaeskesteg_sovs_kartofler_handler_unique:OnCreated()
	if not IsServer() then return end

	self:StartIntervalThink(FrameTime())
end

function modifier_item_flaeskesteg_sovs_kartofler_handler_unique:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
	return decFuncs
end


function modifier_item_flaeskesteg_sovs_kartofler_handler_unique:OnTakeDamage(keys)
	if IsServer() then
		local parent = self:GetParent()
		if keys.unit == parent then
			local cd = self:GetAbility():GetSpecialValueFor("cooldown")
			self:StartIntervalThink(cd)
			self:GetAbility():StartCooldown(cd)
			if parent:HasModifier("modifier_item_flaeskesteg_healing") then parent:RemoveModifierByName("modifier_item_flaeskesteg_healing") end
		end
	end
end

function modifier_item_flaeskesteg_sovs_kartofler_handler_unique:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_flaeskesteg_healing") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_flaeskesteg_healing", {icon = 1, healing = self:GetAbility():GetSpecialValueFor("health_regen_percent_per_second")})
		else
			local mod = parent:FindModifierByName("modifier_item_flaeskesteg_healing")
			if mod.healing < self:GetAbility():GetSpecialValueFor("health_regen_percent_per_second") then
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_flaeskesteg_healing", {icon = 1, healing = self:GetAbility():GetSpecialValueFor("health_regen_percent_per_second")})
			end
		end
		
		self:StartIntervalThink(-1)
	end
end