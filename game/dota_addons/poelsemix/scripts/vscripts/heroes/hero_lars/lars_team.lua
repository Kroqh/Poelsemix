LinkLuaModifier("modifier_lars_team_swap", "heroes/hero_lars/lars_team", LUA_MODIFIER_MOTION_NONE)
lars_team = lars_team or class({})

function lars_team:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		caster:EmitSound("LarsAlly")
        
        local bullet = 
			{
				Target = target,
				Source = caster,
				Ability = self,
				EffectName = "particles/units/heroes/hero_lars/lars_team_beer.vpcf",
				iMoveSpeed = 800,
				bDodgeable = false,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				ExtraData = {}
			}
		ProjectileManager:CreateTrackingProjectile(bullet)
	end
end

function lars_team:OnProjectileHit(target)
	if not target then
		return nil 
	end
    target:EmitSound("lars_beer_open")
	local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(caster, self, "modifier_lars_team_swap", {duration = duration})
    
end


modifier_lars_team_swap = modifier_lars_team_swap or class({})

function modifier_lars_team_swap:IsDebuff() return true end
function modifier_lars_team_swap:IsPurgable() return false end

function modifier_lars_team_swap:OnCreated()
	if not IsServer() then return end
    local caster = self:GetCaster()
	local target = self:GetParent()

	AddFOWViewer(target:GetTeam(), target:GetAbsOrigin(), target:GetCurrentVisionRange(), self:GetDuration(), false)

	local larsTeamNumb = caster:GetTeamNumber()
	self.targetTeamNumb = target:GetTeamNumber()

	target:SetTeam(larsTeamNumb)
	target:SetFriction(0)
end

function modifier_lars_team_swap:OnRemoved()
	if not IsServer() then return end
    self:GetParent():SetTeam(self.targetTeamNumb)
end
function modifier_lars_team_swap:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_lars_team_swap:GetEffectName()
    return "particles/units/heroes/hero_marci/marci_sidekick_buff.vpcf"
end
