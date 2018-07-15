function item_double_butterfly_on_spell_start(keys)
		
		keys.caster:EmitSound("DOTA_Item.Butterfly")
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_double_butterfly_speed", nil)
end

function item_actual_butterfly_on_spell_start(keys)
			keys.caster:EmitSound("DOTA_Item.Butterfly")
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_actual_butterfly_speed", nil)
end