function bombStart( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	ability.bomb_start = GameRules:GetGameTime()
	
	-- Swap sub_ability
	local sub_ability_name = event.sub_ability_name
	local main_ability_name = ability:GetAbilityName()

	caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
	print("Swapped "..main_ability_name.." with " ..sub_ability_name)


	-- Play the sound, which will be stopped when the sub ability fires
	caster:EmitSound("bombe_paa_B")

end	

function UpdateTimerParticle( event )

	local caster = event.caster
	local ability = event.ability
	local bomb_timer = ability:GetLevelSpecialValueFor( "bomb_timer", ability:GetLevel() - 1 )

	-- Show the particle to all allies
	local allHeroes = HeroList:GetAllHeroes()
	local particleName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf"
	local preSymbol = 0 -- Empty
	local digits = 2 -- "5.0" takes 2 digits
	local number = GameRules:GetGameTime() - ability.bomb_start - bomb_timer - 0.1 --the minus .1 is needed because think interval comes a frame earlier

	-- Get the integer. Add a bit because the think interval isn't a perfect 0.5 timer
	local integer = math.floor(math.abs(number))

	-- Round the decimal number to .0 or .5
	local decimal = math.abs(number) % 1

	if decimal < 0.5 then 
		decimal = 1 -- ".0"
	else 
		decimal = 8 -- ".5"
	end

	print(integer,decimal)

	for k, v in pairs( allHeroes ) do
		if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
			-- Don't display the 0.0 message
			if integer == 0 and decimal == 1 then
				
			else
				local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_OVERHEAD_FOLLOW, caster, PlayerResource:GetPlayer( v:GetPlayerID() ) )
				
				ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
				ParticleManager:SetParticleControl( particle, 1, Vector( preSymbol, integer, decimal) )
				ParticleManager:SetParticleControl( particle, 2, Vector( digits, 0, 0) )
			end
		end
	end

end

function bombStop( event )

	local caster = event.caster
	local sub_ability = event.ability

	-- Stops the charging sound
	caster:StopSound("Hero_Alchemist.UnstableConcoction.Fuse")

	-- Swap the sub_ability back to normal
	local sub_ability_name = sub_ability:GetAbilityName()
	local main_ability_name = event.main_ability_name

	caster:SwapAbilities(main_ability_name, sub_ability_name, true, false)
	print("Swapped "..main_ability_name.." with " ..sub_ability_name)

	-- Get the handle of the main ability to get the time started
	local ability = caster:FindAbilityByName(main_ability_name)

	-- Remove the brewing modifier
	caster:RemoveModifierByName("modifier_plant_bomb_timer")
	caster:EmitSound("Hero_Techies.Suicide")
end	

function bombRunOut( event )
	
	local caster = event.caster
	local ability = event.ability
	local bomb_timer = ability:GetLevelSpecialValueFor( "timerDuration", ability:GetLevel() - 1 )
	
	ability.time_charged = GameRules:GetGameTime() - ability.bomb_start
	
	if ability.time_charged >= bomb_timer then
	
		-- Stops the charging sound
		caster:StopSound("Hero_Alchemist.UnstableConcoction.Fuse")

		-- Swap the sub_ability back to normal
		local sub_ability_name = event.sub_ability_name
		local main_ability_name = ability:GetAbilityName()

		caster:SwapAbilities(main_ability_name, sub_ability_name, true, false)
	print("Swapped "..main_ability_name.." with " ..sub_ability_name)

		-- Main ability handle and variables
		local ability = caster:FindAbilityByName(main_ability_name)
		local big_deeps = ability:GetLevelSpecialValueFor("explosion_damage", ability:GetLevel() - 1)
		local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", ability:GetLevel() - 1)
		local mainAbilityDamageType = ability:GetAbilityDamageType()
		
		-- Damage and stun caster
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_stun", {duration = stun_duration})
		ApplyDamage({victim = caster, attacker = caster, damage = big_deeps, damage_type = mainAbilityDamageType})

		caster:EmitSound("FUCKDIG")
		caster:EmitSound("Hero_Techies.Suicide")
	end
end	

function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end