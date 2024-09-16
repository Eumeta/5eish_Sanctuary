 --Caster DC function
 function GetDC(ID)
    local data = Ext.Entity.Get(ID).Stats
    local proficiency = data.ProficiencyBonus
    local spellmod = data.AbilityModifiers[(data.SpellCastingAbility == "Wisdom" and 6) or 
                (data.SpellCastingAbility == "Charisma" and 7) or
                (data.SpellCastingAbility == "Intelligence" and 5)]
    local DC = 8 + proficiency + spellmod
    return DC
 end

 Ext.Osiris.RegisterListener("StatusApplied", 4, "before", function(target, status, source,_)
    if status == "SANCTUARY_AURA" then
        local statuses = Ext.Entity.Get(source).ServerCharacter.StatusManager.Statuses
        local caster = nil
        for _, v in pairs(statuses) do
            if v.StatusId == "SANCTUARY" then
                caster = v.CauseGUID
            end
        end
        local DC = GetDC(caster)
        local adv = HasPassive(target,"MagicResistance") and true or false
        local roll = adv and Osi.IntegerMax(math.random(1,20),math.random(1,20)) or math.random(1,20)
        local saving_throw = (roll + Ext.Entity.Get(source).Stats.AbilityModifiers[6])
        if saving_throw < DC then
            Osi.ApplyStatus(target,"SANCTUARY_FAILED",6,1,source)
        else
            Osi.ApplyStatus(target,"SANCTUARY_SAVED",6,1,source)
        end 
    end
end)