LinkLuaModifier("modifier_hog_bash", "abilities/hog_bash", LUA_MODIFIER_MOTION_NONE)
hog_bash = hog_bash or class({})
modifier_hog_bash = modifier_hog_bash or class({})



function hog_bash:GetIntrinsicModifierName()
	return "modifier_hog_bash"
end

function modifier_hog_bash:IsPurgable() return true end
function modifier_hog_bash:IsHidden() return true end
function modifier_hog_bash:IsPassive() return true end

function modifier_hog_bash:OnCreated()
	if IsServer() then
		self:StartIntervalThink(10) --for instaspawning the first

	end
end


function modifier_hog_bash:OnIntervalThink()
    self:GetParent():SetForceAttackTarget(nil)
    self:StartIntervalThink(999)
end

function modifier_hog_bash:DeclareFunctions()
	local decFuncs = 
	{MODIFIER_EVENT_ON_ATTACK_LANDED}
	return decFuncs
end


function modifier_hog_bash:OnAttackLanded( params )
    if IsServer() then
        if (params.attacker ~= self:GetParent()) then return end 
        if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("chance"), self) then
	        params.target:AddNewModifier(params.attacker, self, "modifier_stunned", { duration = self:GetAbility():GetSpecialValueFor("duration") } )
        end
    
	end
end