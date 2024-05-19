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
	self.vision_radius					= self:GetSpecialValueFor("radius") / 2
	self.numVision						= math.ceil( self.range / self.vision_radius )

    local particleName = "particles/heroes/mewtwo/hyper_beam.vpcf"
	self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, caster )
	self.attach_point = caster:ScriptLookupAttachment( "attach_attack2" )
    self.interval = self:GetSpecialValueFor("tick_rate")

    self.dmgdealt = 0
	self.elapsedTime = self.interval
    local damage = self:GetSpecialValueFor("damage")
    if self:GetCaster():FindAbilityByName("special_bonus_mewtwo_8"):GetLevel() > 0 then damage = damage + self:GetCaster():FindAbilityByName("special_bonus_mewtwo_8"):GetSpecialValueFor("value") end
    self.tickdmg = (damage * (self.interval / self:GetSpecialValueFor("channel_duration")))


    -- Current position & direction
    self.casterOrigin	= caster:GetAbsOrigin()
    self.casterForward	= caster:GetForwardVector()
    
    -- Update thinker positions
    self.endcapPos = self.casterOrigin + self.casterForward * self.range
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
        
        

            
                -- Dmg
                local units = FindUnitsInLine(caster:GetTeamNumber(),
                    caster:GetAbsOrigin() + caster:GetForwardVector() * 32 ,
                    self.endcapPos,
                    nil,
                    self:GetSpecialValueFor("radius"),
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

                -- Give vision
                for i=1, self.numVision do
                    AddFOWViewer(caster:GetTeamNumber(), ( self.casterOrigin + self.casterForward * ( self.vision_radius * 2 * (i-1) ) ), self.vision_radius, 0.2, false)
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
