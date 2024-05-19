
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
		if GetMapName() == "poelsemix" then
			self.TEAM_KILLS_TO_WIN = 35
		elseif GetMapName() == "poelsemix_3v3v3v3" then
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
		if GetMapName() == "poelsemix_3v3v3v3" then
			self:DoMapObjectivesSetUp()
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
		--if hero:IsRealHero() == true then
			--if event.entindex_inflictor ~= nil then
				--local inflictor_index = event.entindex_inflictor
				--if inflictor_index ~= nil then
					--local ability = EntIndexToHScript( event.entindex_inflictor )
					--if ability ~= nil then
						--if ability:GetAbilityName() ~= nil then
							--if ability:GetAbilityName() == "necrolyte_reapers_scythe" then
							--	print("Killed by Necro Ult")
							--	extraTime = 20
							--end
						--end
					--end
				--end				
			--end
		--end
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
	local hero = EntIndexToHScript( event.entindex ) --is all units not just heroes
	local npcName = hero:GetUnitName()
	
	hero:AddNewModifier(hero, nil, "modifier_remove_speed_cap", {})



	if npcName == "npc_dota_hero_sniper" then
		
		local sniper_cloak = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/sharpshooter_cloak/sharpshooter_cloak.vmdl"})
		sniper_cloak:FollowEntity(hero, true)
		
		local sniper_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/hare_hunt_rifle/hare_hunt_rifle.vmdl"})
		sniper_weapon:FollowEntity(hero, true)
		
		local sniper_mask = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/sharpshooter_stache/sharpshooter_stache.vmdl"})
		sniper_mask:FollowEntity(hero, true)

	elseif npcName == "npc_dota_hero_kunkka" then
		
		local yahya_sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/gunsword/kunkka_gunsword.vmdl"})
		yahya_sword:FollowEntity(hero, true)
		
		local yahya_hands = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/green_sleeves_of_the_voyager/green_sleeves_of_the_voyager.vmdl"})
		yahya_hands:FollowEntity(hero, true)
		
		local yahya_legs= SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/legs_admirableadmiral.vmdl"})
		yahya_legs:FollowEntity(hero, true)

		local yahya_hat= SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/kunkka_bandana.vmdl"})
		yahya_hat:FollowEntity(hero, true)


	end
	
	-- only hero stuff afterswards, also called on illusions before they are turned into actual illusions (thanks valve), create a timer like at the bottom if it should not happen on illusions
	if not hero:IsRealHero() then return end


	if hero:GetUnitName() == "unit_hog_rider" then
		local ability = hero:FindAbilityByName("hog_bash")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end
	if hero:GetUnitName() == "npc_dota_hero_pugna" then
		local ability = hero:FindAbilityByName("gametecher_thirst")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end
	if hero:GetUnitName() == "npc_dota_hero_dark_seer" then
		local ability = hero:FindAbilityByName("herobrine_grief")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end
	if hero:GetUnitName() == "npc_dota_hero_bounty_hunter" then
		local ability = hero:FindAbilityByName("pr0_incognito")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end
	if hero:GetUnitName() == "npc_dota_hero_phantom_assassin" then
		local ability = hero:FindAbilityByName("huge_click")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end
	if hero:GetUnitName() == "npc_dota_hero_treant" then
		local ability = hero:FindAbilityByName("damian_faded")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end
	if hero:GetUnitName() == "npc_dota_hero_broodmother" then
		local ability = hero:FindAbilityByName("urgot_augmenter")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end
	if hero:GetUnitName() == "npc_dota_hero_magnataur" then
		local ability = hero:FindAbilityByName("slapper_bum_hunter")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end


	if hero:GetUnitName() == "npc_dota_hero_crystal_maiden" then
		local ability = hero:FindAbilityByName("shimakaze_dangerous_sea")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end

	if hero:GetUnitName() == "npc_dota_hero_venomancer" then
		local ability = hero:FindAbilityByName("guerrilla_warfare")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end
	if hero:GetUnitName() == "npc_dota_hero_tusk" then
		local ability = hero:FindAbilityByName("kazuya_rage")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end
	if hero:GetUnitName() == "npc_dota_hero_hoodwink" then
		local ability = hero:FindAbilityByName("mette_mink")
		if ability:GetLevel() == 0 then ability:SetLevel(1) end
	end

		--Timers:CreateTimer({
		--endTime = 0.1,
		--callback = function()
			SpawnCourier(hero)
		--end
		--})


end

function SpawnCourier(hero)
	if hero:IsRealHero() and hero.FirstSpawn == nil then
		hero.FirstSpawn = true
		-- hero:AddItemByName("item_courier")
		COverthrowGameMode:OnHeroInGame(hero)
		print(hero)
		local courier = CreateUnitByName("npc_dota_courier", hero:GetAbsOrigin(), true, nil, nil, hero:GetTeam())
		courier:SetControllableByPlayer(hero:GetPlayerID(), false)
		local ability = courier:AddAbility("courier_superspeed")
		ability:SetLevel(1)
	end
end



-- Spawning individual camps
function COverthrowGameMode:DoMapObjectivesSetUp(campname)
	for i = 1, 4, 1 do
		self:SpawnMinionCamp(self:GetIslands()[i], 6)
	end
end

function COverthrowGameMode:GetIslands()
	return {"islandmarker1","islandmarker2","islandmarker3","islandmarker4",}
end

function COverthrowGameMode:SpawnMinionCamp(island, count)
    local SpawnLocation = Entities:FindByName(nil, island)
	
	
	if SpawnLocation == nil then
		return
	end

    for i = 1, count do
		local r = "npc_melee_minion"
		if i == 1 then r = "npc_super_minion" end
        local creature = CreateUnitByName(r , SpawnLocation:GetAbsOrigin() + RandomVector( RandomFloat( 0, 250 ) ), true, nil, nil, DOTA_TEAM_NEUTRALS )
        creature:AddNewModifier(nil, nil, "modifier_kill", { duration = 300 } )
		creature:SetFollowRange(300)
		creature:SetInitialGoalPosition(creature:GetAbsOrigin())
    end
end