LinkLuaModifier("modifier_pro_blockchain_invest", "heroes/hero_pr0ph3cy/prophecy_blockchain", LUA_MODIFIER_MOTION_NONE)
pr0_blockchain = pr0_blockchain or class({})

function pr0_blockchain:GetChannelTime()
    return self:GetSpecialValueFor("channel_duration")
end


function pr0_blockchain:OnSpellStart()
    if IsServer() then
		local caster = self:GetCaster()
        caster:EmitSound("pr0_hackerjob")
		self.pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_dark_willow/dark_willow_bramble_precast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
		self.elapsedTime = 0.1
	end
end

function pr0_blockchain:OnChannelThink(think)
    if  not IsServer() then return end
    local caster	= self:GetCaster()
    self.elapsedTime = self.elapsedTime + think
    if self.elapsedTime >= self:GetSpecialValueFor("tick_rate") then
		
		local mod=caster:FindModifierByName("modifier_pro_blockchain_invest")
		if mod == nil then
			mod = caster:AddNewModifier(caster, self, "modifier_pro_blockchain_invest", {})
		end
		local gold_rate = self:GetSpecialValueFor("gold_percent") / 100
		local gold = caster:GetGold() * gold_rate
		caster:ModifyGold(-gold, false, 0)
		mod:SetStackCount(mod:GetStackCount() + gold)
        self.elapsedTime = 0
    end
end

function pr0_blockchain:OnChannelFinish(interrupted)
    if  not IsServer() then return end
    ParticleManager:DestroyParticle( self.pfx, true )
    self:GetCaster():StopSound("pr0_hackerjob")
	self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)
end


modifier_pro_blockchain_invest = modifier_pro_blockchain_invest or class({})


function modifier_pro_blockchain_invest:IsHidden()		return false end
function modifier_pro_blockchain_invest:IsPurgable()		return false end
function modifier_pro_blockchain_invest:IsDebuff()		return false end

function modifier_pro_blockchain_invest:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED
					}
	return funcs
end
function modifier_pro_blockchain_invest:OnHeroKilled(event) 
	if not IsServer() then return end
	if event.attacker ~= self:GetParent() and event.target ~= self:GetParent() then return end
	local payout_rate = 0
	if event.attacker == self:GetParent() then
		payout_rate = self:GetAbility():GetSpecialValueFor("payout_self")
		if self:GetCaster():FindAbilityByName("special_bonus_prophecy_5"):GetLevel() > 0 then payout_rate = payout_rate + self:GetCaster():FindAbilityByName("special_bonus_prophecy_5"):GetSpecialValueFor("value") end
	else
		payout_rate = self:GetAbility():GetSpecialValueFor("payout_enemy")
	end
	event.attacker:ModifyGold(payout_rate * self:GetStackCount(), true, 0)
	event.attacker:EmitSound("pr0_ching")
	ParticleManager:CreateParticle("particles/treasure_courier_death_coins.vpcf", PATTACH_ABSORIGIN, event.attacker)
	self:Destroy()
end



