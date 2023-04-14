LinkLuaModifier("modifier_kazuya_god_fist_knockup","heroes/hero_kazuya/kazuya_god_fist.lua",LUA_MODIFIER_MOTION_NONE)

kazuya_god_fist = kazuya_god_fist or class({})


function kazuya_god_fist:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
        local target = self:GetCursorTarget()

	    ApplyDamage({victim = target,
	    attacker = caster,
	    damage_type = DAMAGE_TYPE_PHYSICAL,
	    damage = self:GetSpecialValueFor("damage"),
	    ability = self})

        EmitSoundOn("kazuya_god_fist", caster)
        target:AddNewModifier(caster,self,"modifier_kazuya_god_fist_knockup",{duration = self:GetSpecialValueFor("knockup_duration")})


        local particle = "particles/econ/items/disruptor/disruptor_ti8_immortal_weapon/disruptor_ti8_immortal_thunder_strike_aoe_electric.vpcf"
		local pfx = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), false)
		ParticleManager:ReleaseParticleIndex(pfx)
    end
end


modifier_kazuya_god_fist_knockup = modifier_kazuya_god_fist_knockup or class({})

function modifier_kazuya_god_fist_knockup:IsDebuff() return true end
function modifier_kazuya_god_fist_knockup:IsHidden() return false end
function modifier_kazuya_god_fist_knockup:IsPurgable() return true end
function modifier_kazuya_god_fist_knockup:IsStunDebuff() return true end
function modifier_kazuya_god_fist_knockup:IsMotionController()  return true end
function modifier_kazuya_god_fist_knockup:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_kazuya_god_fist_knockup:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	
	self:StartIntervalThink(FrameTime())
	if IsServer() then
		self:GetParent():StartGesture(ACT_DOTA_FLAIL)
		self.abs = self:GetParent():GetAbsOrigin()
		self.cyc_pos = self:GetParent():GetAbsOrigin()
	end
end

function modifier_kazuya_god_fist_knockup:OnIntervalThink()
	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_kazuya_god_fist_knockup:HorizontalMotion(unit, time)
	if not IsServer() then return end
	-- Change the Face Angle
	-- Change the height at the first and last 0.3 sec
	if self:GetElapsedTime() <= 0.3 then
		self.cyc_pos.z = self.cyc_pos.z + 50
		self:GetParent():SetAbsOrigin(self.cyc_pos)
	elseif self:GetDuration() - self:GetElapsedTime() < 0.3 then
		self.step = self.step or (self.cyc_pos.z - self.abs.z) / ((self:GetDuration() - self:GetElapsedTime()) / FrameTime())
		self.cyc_pos.z = self.cyc_pos.z - self.step
		self:GetParent():SetAbsOrigin(self.cyc_pos)
    end
end

function modifier_kazuya_god_fist_knockup:OnDestroy()
	if not IsServer() then return end
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	self:GetParent():SetAbsOrigin(self.abs)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function modifier_kazuya_god_fist_knockup:CheckState()
	local state =
		{
			[MODIFIER_STATE_STUNNED] = true,
		}
	return state
end
