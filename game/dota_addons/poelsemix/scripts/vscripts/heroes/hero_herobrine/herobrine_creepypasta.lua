
herobrine_creepypasta = herobrine_creepypasta or class({})
LinkLuaModifier( "modifier_herobrine_fear", "heroes/hero_herobrine/herobrine_creepypasta", LUA_MODIFIER_MOTION_NONE )

function herobrine_creepypasta:OnSpellStart()
    if not IsServer() then return end
    local target_point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local ability = self
    local int = caster:GetIntellect()
	local casterPos = caster:GetAbsOrigin()

	local blink_pfx_1 = ParticleManager:CreateParticle("particles/econ/heroes/herobrine/herobrine_creepypasta.vpcf", PATTACH_ABSORIGIN, caster)
	
	ParticleManager:ReleaseParticleIndex(blink_pfx_1)


	local blink_pfx_2 = ParticleManager:CreateParticle("particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour_smoke_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(blink_pfx_2)

	EmitSoundOnLocationWithCaster(casterPos, "Hero_QueenOfPain.Blink_out", caster)
    

	FindClearSpaceForUnit(caster, target_point, false)	

	EmitSoundOnLocationWithCaster(target_point, "Hero_QueenOfPain.Blink_in", caster)


	if caster:HasScepter() then
		local radius = self:GetSpecialValueFor("scepter_fear_aoe")
		local duration = self:GetSpecialValueFor("scepter_fear_duration")
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
		Timers:CreateTimer(0.01, function()
			-- Stop the casting animation and remove caster modifier
			local part = ParticleManager:CreateParticle("particles/econ/items/faceless_void/faceless_void_bracers_of_aeons/fv_bracers_of_aeons_dialatedebuf_red_pulse.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
			Timers:CreateTimer(0.1, function()
				-- Stop the casting animation and remove caster modifier
				ParticleManager:DestroyParticle(part, false)
			end)
		end)
		

		for _, enemy in pairs(units) do
			enemy:AddNewModifier(caster, self, "modifier_herobrine_fear", {duration = duration})
		end

	end

end

function herobrine_creepypasta:GetCastRange()
	local range = self:GetSpecialValueFor("blink_range")
	return range
end
function herobrine_creepypasta:GetAOERadius()
	local range = 0
	if self:GetCaster():HasScepter() then range = self:GetSpecialValueFor("scepter_fear_aoe") end
	return range
end

modifier_herobrine_fear = modifier_herobrine_fear  or class({})

function modifier_herobrine_fear:IsDebuff() return true end
function modifier_herobrine_fear:IsHidden() return false end
function modifier_herobrine_fear:IsPurgable() return true end

function modifier_herobrine_fear:OnCreated()
	if not IsServer() then return end
	self:GetParent():MoveToPosition(self:GetParent():GetAbsOrigin() + ((self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin())*3))
end
function modifier_herobrine_fear:OnRefresh()
	if not IsServer() then return end
	self:GetParent():MoveToPosition(self:GetParent():GetAbsOrigin() + ((self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin())*3))
end
function modifier_herobrine_fear:OnRemoved()
	if not IsServer() then return end
	self:GetParent():Stop()
end

function modifier_herobrine_fear:CheckState()
	local state =
		{
			[MODIFIER_STATE_FEARED] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		}
	return state
end
