item_flaeskesteg = item_flaeskesteg or class({})

LinkLuaModifier("modifier_item_flaeskesteg", "items/item_flaeskesteg", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_flaeskesteg_handler_unique", "items/item_flaeskesteg", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_flaeskesteg_healing", "items/item_flaeskesteg_healing", LUA_MODIFIER_MOTION_NONE)

function item_flaeskesteg:GetIntrinsicModifierName()
	return "modifier_item_flaeskesteg"
end

modifier_item_flaeskesteg = modifier_item_flaeskesteg or class({})
function modifier_item_flaeskesteg:IsHidden()		return true end
function modifier_item_flaeskesteg:IsPurgable()		return false end
function modifier_item_flaeskesteg:RemoveOnDeath()	return false end
function modifier_item_flaeskesteg:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_flaeskesteg:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS
	}
end

function modifier_item_flaeskesteg:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("hp")
    end
end
function modifier_item_flaeskesteg:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("str")
    end
end

function modifier_item_flaeskesteg:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_flaeskesteg_handler_unique") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_flaeskesteg_handler_unique", {})
		end
	end
end

function modifier_item_flaeskesteg:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_flaeskesteg") then
			parent:RemoveModifierByName("modifier_item_flaeskesteg_handler_unique")
		end
		if parent:HasModifier("modifier_item_flaeskesteg_healing") and (not parent:HasItemInInventory("item_flaeskesteg") or parent:HasItemInInventory("item_flaeskesteg_sovs_kartofler"))then parent:RemoveModifierByName("modifier_item_flaeskesteg_healing") end
	end
end


modifier_item_flaeskesteg_handler_unique = modifier_item_flaeskesteg_handler_unique or class({})
function modifier_item_flaeskesteg_handler_unique:IsHidden()		return true end
function modifier_item_flaeskesteg_handler_unique:IsPurgable()		return false end
function modifier_item_flaeskesteg_handler_unique:RemoveOnDeath()	return false end

function modifier_item_flaeskesteg_handler_unique:OnCreated()
	if not IsServer() then return end

	self:StartIntervalThink(FrameTime())
end

function modifier_item_flaeskesteg_handler_unique:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
	return decFuncs
end


function modifier_item_flaeskesteg_handler_unique:OnTakeDamage(keys)
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

function modifier_item_flaeskesteg_handler_unique:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_flaeskesteg_healing") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_flaeskesteg_healing", {icon = 0, healing = self:GetAbility():GetSpecialValueFor("health_regen_percent_per_second")})
		else
			local mod = parent:FindModifierByName("modifier_item_flaeskesteg_healing")
			if mod.healing < self:GetAbility():GetSpecialValueFor("health_regen_percent_per_second") then
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_flaeskesteg_healing", {icon = 0, healing = self:GetAbility():GetSpecialValueFor("health_regen_percent_per_second")})
			end
		end
		self:StartIntervalThink(-1)
	end
end