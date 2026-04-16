antimage_physical_shield = class({})

LinkLuaModifier("modifier_antimage_physical_shield_active", "abilities/antimage/antimage_physical_shield.lua", LUA_MODIFIER_MOTION_NONE)

function antimage_physical_shield:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf", context)
end

function antimage_physical_shield:OnUpgrade()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local linked = caster:FindAbilityByName("antimage_mage_shield")
    if linked and linked:GetLevel() ~= self:GetLevel() then
        linked:SetLevel(self:GetLevel())
    end
end

function antimage_physical_shield:CastFilterResult()
    if IsServer() then
        local caster = self:GetCaster()
        if caster:IsStunned() and not caster:HasScepter() then
            return UF_FAIL_CUSTOM
        end
    end

    return UF_SUCCESS
end

function antimage_physical_shield:GetCustomCastError()
    return "#dota_hud_error_cant_cast_when_stunned"
end

function antimage_physical_shield:OnToggle()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local lock_duration = self:GetSpecialValueFor("min_toggle_lock")

    if self:GetToggleState() then
        local max_mana = caster:GetMaxMana()
        local activation_flat = self:GetSpecialValueFor("activation_mana_flat")
        local activation_pct = self:GetSpecialValueFor("activation_mana_pct")
        local activation_cost = activation_flat + max_mana * activation_pct * 0.01

        if caster:GetMana() < activation_cost then
            self:ToggleAbility()
            return
        end

        caster:Script_ReduceMana(activation_cost, self)
        self.lock_until = GameRules:GetGameTime() + lock_duration

        local other = caster:FindAbilityByName("antimage_mage_shield")
        if other then
            if other:GetToggleState() then
                other._ignore_lock = true
                other:ToggleAbility()
            end
            other:SetActivated(false)
        end

        caster:AddNewModifier(caster, self, "modifier_antimage_physical_shield_active", {})
    else
        if self._ignore_lock then
            self._ignore_lock = nil
        elseif self.lock_until and GameRules:GetGameTime() < self.lock_until then
            self._ignore_lock = true
            self:ToggleAbility()
            return
        end

        caster:RemoveModifierByName("modifier_antimage_physical_shield_active")

        local other = caster:FindAbilityByName("antimage_mage_shield")
        if other and not other:GetToggleState() then
            other:SetActivated(true)
        end

        self:UseResources(false, false, false, true)
    end
end

modifier_antimage_physical_shield_active = class({})

function modifier_antimage_physical_shield_active:IsPurgable() return false end

function modifier_antimage_physical_shield_active:OnCreated()
    if not IsServer() then return end

    self:OnIntervalThink()
    self:StartIntervalThink(1.0)

    local parent = self:GetParent()
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_antimage_physical_shield_active:OnIntervalThink()
    local ability = self:GetAbility()
    if not ability then return end

    local parent = self:GetParent()
    local max_mana = parent:GetMaxMana()

    local deactivation_threshold = ability:GetSpecialValueFor("activation_mana_flat") + max_mana * ability:GetSpecialValueFor("activation_mana_pct") * 0.01
    if parent:GetMana() < deactivation_threshold then
        ability._ignore_lock = true
        if ability:GetToggleState() then
            ability:ToggleAbility()
        end
        self:Destroy()
        return
    end

    local drain = ability:GetSpecialValueFor("drain_mana_flat_per_sec") + max_mana * ability:GetSpecialValueFor("drain_mana_pct_per_sec") * 0.01
    parent:Script_ReduceMana(drain, ability)
end

function modifier_antimage_physical_shield_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE
    }
end

function modifier_antimage_physical_shield_active:GetModifierIncomingPhysicalDamage_Percentage()
    return -self:GetAbility():GetSpecialValueFor("damage_reduction_pct")
end
