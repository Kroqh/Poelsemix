--[[ events.lua ]]
require("timers")
---------------------------------------------------------------------------
-- Event: Game state change handler
---------------------------------------------------------------------------
function COverthrowGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	--print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then

	end

	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		local numberOfPlayers = PlayerResource:GetPlayerCount()
		if numberOfPlayers > 7 then
			--self.TEAM_KILLS_TO_WIN = 25
			nCOUNTDOWNTIMER = 1200
		elseif numberOfPlayers > 4 and numberOfPlayers <= 7 then
			--self.TEAM_KILLS_TO_WIN = 20
			nCOUNTDOWNTIMER = 1200
		else
			--self.TEAM_KILLS_TO_WIN = 15
			nCOUNTDOWNTIMER = 1200
		end
		if GetMapName() == "forest_solo" then
			self.TEAM_KILLS_TO_WIN = 35
		elseif GetMapName() == "desert_duo" then
			self.TEAM_KILLS_TO_WIN = 35
		elseif GetMapName() == "desert_quintet" then
			self.TEAM_KILLS_TO_WIN = 35
		elseif GetMapName() == "temple_quartet" then
			self.TEAM_KILLS_TO_WIN = 35
		else
			self.TEAM_KILLS_TO_WIN = 35
		end
		--print( "Kills to win = " .. tostring(self.TEAM_KILLS_TO_WIN) )

		CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );

		self._fPreGameStartTime = GameRules:GetGameTime()
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "OnGameRulesStateChange: Game In Progress" )
		self.countdownEnabled = true
		CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
		DoEntFire( "center_experience_ring_particles", "Start", "0", 0, self, self  )
	end
end

--------------------------------------------------------------------------------
-- Event: OnNPCSpawned
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit:IsRealHero() then
		-- Destroys the last hit effects
		local deathEffects = spawnedUnit:Attribute_GetIntValue( "effectsID", -1 )
		if deathEffects ~= -1 then
			ParticleManager:DestroyParticle( deathEffects, true )
			spawnedUnit:DeleteAttribute( "effectsID" )
		end
		if self.allSpawned == false then
			if GetMapName() == "mines_trio" then
				--print("mines_trio is the map")
				--print("self.allSpawned is " .. tostring(self.allSpawned) )
				local unitTeam = spawnedUnit:GetTeam()
				local particleSpawn = ParticleManager:CreateParticleForTeam( "particles/addons_gameplay/player_deferred_light.vpcf", PATTACH_ABSORIGIN, spawnedUnit, unitTeam )
				ParticleManager:SetParticleControlEnt( particleSpawn, PATTACH_ABSORIGIN, spawnedUnit, PATTACH_ABSORIGIN, "attach_origin", spawnedUnit:GetAbsOrigin(), true )
			end
		end
	end

	
end

--------------------------------------------------------------------------------
-- Event: BountyRunePickupFilter
--------------------------------------------------------------------------------
function COverthrowGameMode:BountyRunePickupFilter( filterTable )
      filterTable["xp_bounty"] = 5*filterTable["xp_bounty"]
      filterTable["gold_bounty"] = 5*filterTable["gold_bounty"]
      return true
end

---------------------------------------------------------------------------
-- Event: OnTeamKillCredit, see if anyone won
---------------------------------------------------------------------------
function COverthrowGameMode:OnTeamKillCredit( event )	
--	print( "OnKillCredit" )
--	DeepPrint( event )

	local nKillerID = event.killer_userid
	local nTeamID = event.teamnumber
	local nTeamKills = event.herokills
	local nKillsRemaining = self.TEAM_KILLS_TO_WIN - nTeamKills
	
	local broadcast_kill_event =
	{
		killer_id = event.killer_userid,
		team_id = event.teamnumber,
		team_kills = nTeamKills,
		kills_remaining = nKillsRemaining,
		victory = 0,
		close_to_victory = 0,
		very_close_to_victory = 0,
	}

	if nKillsRemaining <= 0 then
		GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[nTeamID] )
		GameRules:SetGameWinner( nTeamID )
		broadcast_kill_event.victory = 1
	elseif nKillsRemaining == 1 then
		EmitGlobalSound( "ui.npe_objective_complete" )
		broadcast_kill_event.very_close_to_victory = 1
	elseif nKillsRemaining <= self.CLOSE_TO_VICTORY_THRESHOLD then
		EmitGlobalSound( "ui.npe_objective_given" )
		broadcast_kill_event.close_to_victory = 1
	end

	CustomGameEventManager:Send_ServerToAllClients( "kill_event", broadcast_kill_event )
end

---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function COverthrowGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	local hero = EntIndexToHScript( event.entindex_attacker )
	local heroTeam = hero:GetTeam()
	local extraTime = 0
	if killedUnit:IsRealHero() then
		self.allSpawned = true
		--print("Hero has been killed")
		--Add extra time if killed by Necro Ult
		
		if hero:IsRealHero() == true then
			if event.entindex_inflictor ~= nil then
				local inflictor_index = event.entindex_inflictor
				if inflictor_index ~= nil then
					local ability = EntIndexToHScript( event.entindex_inflictor )
					if ability ~= nil then
						if ability:GetAbilityName() ~= nil then
							if ability:GetAbilityName() == "necrolyte_reapers_scythe" then
								print("Killed by Necro Ult")
								extraTime = 20
							end
						end
					end
					
				end
				
			end
		end
		if hero:IsRealHero() and heroTeam ~= killedTeam then
			--print("Granting killer xp")
			if killedUnit:GetTeam() == self.leadingTeam and self.isGameTied == false then
				local memberID = hero:GetPlayerID()
				PlayerResource:ModifyGold( memberID, 500, true, 0 )
				hero:AddExperience( 100, 0, false, false )
				local name = hero:GetClassname()
				local victim = killedUnit:GetClassname()
				local kill_alert =
					{
						hero_id = hero:GetClassname()
					}
				CustomGameEventManager:Send_ServerToAllClients( "kill_alert", kill_alert )
			else
				hero:AddExperience( 50, 0, false, false )
			end
		end
		--Granting XP to all heroes who assisted
		local allHeroes = HeroList:GetAllHeroes()
		for _,attacker in pairs( allHeroes ) do
			--print(killedUnit:GetNumAttackers())
			for i = 0, killedUnit:GetNumAttackers() - 1 do
				if attacker == killedUnit:GetAttacker( i ) then
					--print("Granting assist xp")
					attacker:AddExperience( 25, 0, false, false )
				end
			end
		end
		if killedUnit:GetRespawnTime() > 10 then
			--print("Hero has long respawn time")
			if killedUnit:IsReincarnating() == true then
				--print("Set time for Wraith King respawn disabled")
				return nil
			else
				COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
			end
		else
			COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
		end

	end
end

function COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
	--print("Setting time for respawn")
	if killedTeam == self.leadingTeam and self.isGameTied == false then
		killedUnit:SetTimeUntilRespawn( 20 + extraTime )
	else
		killedUnit:SetTimeUntilRespawn( 10 + extraTime )
	end
end


--------------------------------------------------------------------------------
-- Event: OnItemPickUp
--------------------------------------------------------------------------------
function COverthrowGameMode:OnItemPickUp( event )

	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner
	
	if event.HeroEntityIndex then
		owner = EntIndexToHScript(event.HeroEntityIndex)
	elseif event.UnitEntityIndex then
		owner = EntIndexToHScript(event.UnitEntityIndex)
		local vRandomSpawnPos = {
			Vector(108, 0, 0),
			Vector(108, 108, 0),
			Vector(108, 0, 0),
			Vector(0, 108, 0),
			Vector(-108, 0, 0),
			Vector(-108, 108, 0),
			Vector(-108, -108, 0),
			Vector(0, -108, 0),
		}
		-- Prevent courier abuse when picking up overthrow items
		if event.itemname == "item_bag_of_gold" then
			local newItem = CreateItem( "item_bag_of_gold", nil, nil )
			local drop = CreateItemOnPositionForLaunch( owner:GetAbsOrigin() + vRandomSpawnPos[math.random(8)], newItem )
		elseif event.itemname == "item_treasure_chest" then
			local newItem = CreateItem( "item_treasure_chest", nil, nil )
			local drop = CreateItemOnPositionForLaunch( owner:GetAbsOrigin() + vRandomSpawnPos[math.random(8)], newItem )
		end

		return
	end

	r = 300
	--r = RandomInt(200, 400)
	if event.itemname == "item_bag_of_gold" then
		--print("Bag of gold picked up")
		PlayerResource:ModifyGold( owner:GetPlayerID(), r, true, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, r, nil )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	elseif event.itemname == "item_treasure_chest" then
		--print("Special Item Picked Up")
		DoEntFire( "item_spawn_particle_" .. self.itemSpawnIndex, "Stop", "0", 0, self, self )
		COverthrowGameMode:SpecialItemAdd( event )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	end
end


--------------------------------------------------------------------------------
-- Event: OnNpcGoalReached
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNpcGoalReached( event )
	local npc = EntIndexToHScript( event.npc_entindex )
	if npc:GetUnitName() == "npc_dota_treasure_courier" then
		COverthrowGameMode:TreasureDrop( npc )
	end
end

--------------------------------------------------------------------------------
-- Event: On NPC Spawn
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNPCSpawned( event )
	local hero = EntIndexToHScript( event.entindex )
	local npcName = hero:GetUnitName()


	if npcName == "npc_dota_hero_sniper" then
		
		local sniper_cloak = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/sharpshooter_cloak/sharpshooter_cloak.vmdl"})
		sniper_cloak:FollowEntity(hero, true)
		
		local sniper_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/hare_hunt_rifle/hare_hunt_rifle.vmdl"})
		sniper_weapon:FollowEntity(hero, true)
		
		local sniper_mask = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/sharpshooter_stache/sharpshooter_stache.vmdl"})
		sniper_mask :FollowEntity(hero, true)

	end

	if npcName == "npc_dota_hero_dragon_knight" then
		
		local DkBracer = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/aurora_warrior_set_arms/aurora_warrior_set_arms.vmdl"})
		DkBracer:FollowEntity(hero, true)
		
		local DkShield = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/aurora_warrior_set_off_hand/aurora_warrior_set_off_hand.vmdl"})
		DkShield:FollowEntity(hero, true)
		
		local DkHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/aurora_warrior_set_head/aurora_warrior_set_head.vmdl"})
		DkHead:FollowEntity(hero, true)
		
		local DkLegs = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/aurora_warrior_set_back/aurora_warrior_set_back.vmdl"})
		DkLegs:FollowEntity(hero, true)
		
		local DkShoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/aurora_warrior_set_shoulder/aurora_warrior_set_shoulder.vmdl"})
		DkShoulder:FollowEntity(hero, true)

		local DkSword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/aurora_warrior_set_weapon/aurora_warrior_set_weapon.vmdl"})
		DkSword:FollowEntity(hero, true)

	end
	
	-- only hero stuff afterswards, also called on illusions before they are turned into actual illusions (thanks valve), create a timer like at the bottom if it should not happen on illusions
	if not hero:IsRealHero() then return end

	

	if hero:GetUnitName() == "unit_hog_rider" then
		local ability = hero:FindAbilityByName("hog_bash")
		ability:SetLevel(1)
	end
	if hero:GetUnitName() == "npc_dota_hero_pugna" then
		local ability = hero:FindAbilityByName("bloodseeker_thirst")
		ability:SetLevel(1)
	end
	if hero:GetUnitName() == "npc_dota_hero_bounty_hunter" then
		local ability = hero:FindAbilityByName("pr0_incognito")
		ability:SetLevel(1)
	end
	if hero:GetUnitName() == "npc_dota_hero_phantom_assassin" then
		local ability = hero:FindAbilityByName("click")
		ability:SetLevel(1)
	end
	if hero:GetUnitName() == "npc_dota_hero_riki" then
		local ability = hero:FindAbilityByName("flyby_attack")
		ability:SetLevel(1)
	end
	if hero:GetUnitName() == "npc_dota_hero_meepo" then
		local ability = hero:FindAbilityByName("choke_datadriven")
		ability:SetLevel(1)
	end

	if hero:GetUnitName() == "npc_dota_hero_crystal_maiden" then
		local ability = hero:FindAbilityByName("water")
		local ability2 = hero:FindAbilityByName("dangerous_sea")
		ability:SetLevel(1)
		ability2:SetLevel(1)
	end

	if hero:GetUnitName() == "npc_dota_hero_venomancer" then
		local ability = hero:FindAbilityByName("guerrilla_warfare")
		ability:SetLevel(1)
	end

	Timers:CreateTimer({
		endTime = 0.1,
		callback = function()
			SpawnCourier(hero)
		end
		})


end

function SpawnCourier(hero)
	if hero:IsRealHero() and hero.FirstSpawn == nil then
		hero.FirstSpawn = true
		-- hero:AddItemByName("item_courier")
		COverthrowGameMode:OnHeroInGame(hero)
		local courier = CreateUnitByName("npc_dota_courier", hero:GetAbsOrigin(), true, nil, nil, hero:GetTeam())
		courier:SetControllableByPlayer(hero:GetPlayerID(), false)
		local ability = courier:AddAbility("courier_superspeed")
		ability:SetLevel(1)
	end
end



