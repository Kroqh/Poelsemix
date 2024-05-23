mewtwo_hyper_beam = mewtwo_hyper_beam or class({})

function mewtwo_hyper_beam:GetCastRange()
    local range = self:GetSpecialValueFor("range")
    if self:GetCaster():FindAbilityByName("special_bonus_mewtwo_7"):GetLevel() > 0 then range = range + self:GetCaster():FindAbilityByName("special_bonus_mewtwo_7"):GetSpecialValueFor("value") end
    return range
end

function mewtwo_hyper_beam:GetChannelTime()
    return self:GetSpecialValueFor("channel_duration")
end



function mewtwo_hyper_beam:OnSpellStart()
    if  not IsServer() then return end
    local caster	= self:GetCaster()
    caster:EmitSound("mewtwo_hyper_beam");
    self.range					=  self:GetSpecialValueFor("range")
    if self:GetCaster():FindAbilityByName("special_bonus_mewtwo_7"):GetLevel() > 0 then self.range = self.range + self:GetCaster():FindAbilityByName("special_bonus_mewtwo_7"):GetSpecialValueFor("value") end

    self.radius = self:GetSpecialValueFor("radius")
    local particleName = "particles/heroes/mewtwo/hyper_beam.vpcf"
	self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, caster )
	self.attach_point = caster:ScriptLookupAttachment( "attach_attack2" )
    self.interval = self:GetSpecialValueFor("tick_rate")

    self.dmgdealt = 0
	self.elapsedTime = self.interval
    local damage = self:GetSpecialValueFor("damage")
    if self:GetCaster():FindAbilityByName("special_bonus_mewtwo_8"):GetLevel() > 0 then damage = damage + self:GetCaster():FindAbilityByName("special_bonus_mewtwo_8"):GetSpecialValueFor("value") end
    self.tickdmg = (damage * (self.interval / self:GetSpecialValueFor("channel_duration")))

    self.dir = (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized()
    
    -- Update thinker positions
    self.endcapPos = caster:GetAbsOrigin() + self.dir * self.range
    self.endcapPos = GetGroundPosition( self.endcapPos, nil )
    self.endcapPos.z = self.endcapPos.z + 92

    -- Update particle FX
    ParticleManager:SetParticleControl( self.pfx, 1, self.endcapPos )

end

function mewtwo_hyper_beam:OnChannelThink(think)
    if  not IsServer() then return end
    local caster	= self:GetCaster()
    ParticleManager:SetParticleControl(self.pfx, 0, caster:GetAttachmentOrigin(self.attach_point))
    self.elapsedTime = self.elapsedTime + think
    if self.elapsedTime >= self.interval then

        local count = math.floor(self.range / 15)
        local counter = 0
        
        while counter < count do
            AddFOWViewer(caster:GetTeamNumber(),caster:GetAbsOrigin() + self.dir * (count*10), self.radius * 8 ,0.5,false)
            counter = counter + 1
        end
        
            

            
                -- Dmg
                local units = FindUnitsInLine(caster:GetTeamNumber(),
                    caster:GetAbsOrigin() + self.dir * 32 ,
                    self.endcapPos,
                    nil,
                    self.radius,
                    self:GetAbilityTargetTeam(),
                    self:GetAbilityTargetType(),
                    self:GetAbilityTargetFlags())
                

                for _,unit in pairs(units) do
                    local damage_table 			= {};
		            damage_table.attacker 		= caster;
		            damage_table.ability 		= self;
		            damage_table.damage_type 	= self:GetAbilityDamageType();
		            damage_table.damage	 		= self.tickdmg;
		            damage_table.victim  		= unit;
		            ApplyDamage(damage_table)
                end

                self.dmgdealt = self.dmgdealt + self.tickdmg
                self.elapsedTime = 0
    end


end

function mewtwo_hyper_beam:OnChannelFinish(interrupted)
    if  not IsServer() then return end
    ParticleManager:DestroyParticle( self.pfx, true )
    self:GetCaster():StopSound("mewtwo_hyper_beam")
end
