function modifier_item_heart_datadriven_regen_on_take_damage(keys)
	if keys.caster:IsRangedAttacker() then
		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
	else  --If the caster is melee.
		keys.ability:StartCooldown(keys.CooldownMelee)
	end
	
	if keys.caster:HasModifier("modifier_item_heart_datadriven_regen_visible") then
		keys.caster:RemoveModifierByNameAndCaster("modifier_item_heart_datadriven_regen_visible", keys.caster)
	end
end

function modifier_item_heart_datadriven_regen_on_interval_think(keys)
	if keys.ability:IsCooldownReady() and keys.caster:IsRealHero() then
		keys.caster:Heal(keys.caster:GetMaxHealth() * (keys.HealthRegenPercentPerSecond / 100) * keys.HealInterval, keys.caster)
		if not keys.caster:HasModifier("modifier_item_heart_datadriven_regen_visible") then
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_heart_datadriven_regen_visible", {duration = -1})
		end
	elseif keys.caster:HasModifier("modifier_item_heart_datadriven_regen_visible") then  --This is mostly a failsafe.
		keys.caster:RemoveModifierByNameAndCaster("modifier_item_heart_datadriven_regen_visible", keys.caster)
	end
end

function modifier_item_heart_datadriven_regen_on_destroy(keys)
	keys.caster:RemoveModifierByNameAndCaster("modifier_item_heart_datadriven_regen_visible", keys.caster)
end