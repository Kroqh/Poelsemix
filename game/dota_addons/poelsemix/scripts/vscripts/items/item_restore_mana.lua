function restoreMana(keys)
    keys.caster:GiveMana(keys.ability:GetSpecialValueFor("mp_restore"))
end