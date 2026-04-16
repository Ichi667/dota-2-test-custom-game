antimage_energy_of_ages = class({})

LinkLuaModifier("modifier_antimage_energy_of_ages", "abilities/antimage/antimage_energy_of_ages.lua", LUA_MODIFIER_MOTION_NONE)

function antimage_energy_of_ages:GetIntrinsicModifierName()
    return "modifier_antimage_energy_of_ages"
end

modifier_antimage_energy_of_ages = class({})

function modifier_antimage_energy_of_ages:IsHidden() return true end
function modifier_antimage_energy_of_ages:IsPurgable() return false end

function modifier_antimage_energy_of_ages:OnCreated()
    self.spell_counter = 0
end

function modifier_antimage_energy_of_ages:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
end

function modifier_antimage_energy_of_ages:OnAbilityExecuted(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    if params.unit ~= parent then
        return
    end

    local ability = params.ability
    if not ability or ability:IsItem() or ability:IsToggle() and not ability:GetToggleState() then
        return
    end

    self.spell_counter = self.spell_counter + 1
    local threshold = self:GetAbility():GetSpecialValueFor("spells_needed")

    if self.spell_counter < threshold then
        return
    end

    self.spell_counter = 0

    local restore_pct = self:GetAbility():GetSpecialValueFor("restore_pct")
    local talent = parent:FindAbilityByName("special_bonus_unique_antimage_custom_4")
    if talent and talent:GetLevel() > 0 then
        restore_pct = restore_pct + talent:GetSpecialValueFor("value")
    end

    local heal_amount = parent:GetMaxHealth() * restore_pct * 0.01
    local mana_amount = parent:GetMaxMana() * restore_pct * 0.01

    parent:Heal(heal_amount, self:GetAbility())
    parent:GiveMana(mana_amount)

    local particle = ParticleManager:CreateParticle("particles/items_fx/arcane_boots.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:ReleaseParticleIndex(particle)
    parent:EmitSound("DOTA_Item.ArcaneBoots.Activate")
end
