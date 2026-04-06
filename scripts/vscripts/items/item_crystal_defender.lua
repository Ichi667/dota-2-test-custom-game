LinkLuaModifier("modifier_item_crystal_defender", "items/item_crystal_defender", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_crystal_defender_active", "items/item_crystal_defender", LUA_MODIFIER_MOTION_NONE)

item_crystal_defender = class({})
local WINTER_WYVERN_COLD_EMBRACE_PARTICLE = "particles/items/crystal_defender.vpcf"

function item_crystal_defender:GetIntrinsicModifierName()
    return "modifier_item_crystal_defender"
end

function item_crystal_defender:Precache(context)
    PrecacheResource("particle", WINTER_WYVERN_COLD_EMBRACE_PARTICLE, context)
end

function item_crystal_defender:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    caster:AddNewModifier(caster, self, "modifier_item_crystal_defender_active", {
        duration = self:GetSpecialValueFor("active_duration"),
    })
end

modifier_item_crystal_defender = class({})

local DAMAGE_DEFENSE_PRIORITY = {
    "modifier_item_crystal_defender",
    "modifier_item_iron_shield",
    "modifier_item_phaseblade",
}

function modifier_item_crystal_defender:IsHidden() return true end
function modifier_item_crystal_defender:IsPurgable() return false end
function modifier_item_crystal_defender:RemoveOnDeath() return false end
function modifier_item_crystal_defender:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_crystal_defender:IsPrimaryDefenseModifier()
    local parent = self:GetParent()
    if not parent then return false end

    for _, modifier_name in ipairs(DAMAGE_DEFENSE_PRIORITY) do
        local modifiers = parent:FindAllModifiersByName(modifier_name)
        if #modifiers > 0 then
            return modifiers[1] == self
        end
    end

    return false
end

function modifier_item_crystal_defender:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
    }
end

function modifier_item_crystal_defender:GetModifierPhysicalArmorBonus()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_armor") or 0
end

function modifier_item_crystal_defender:GetModifierConstantHealthRegen()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_health_regen") or 0
end

function modifier_item_crystal_defender:GetModifierHealthBonus()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_health") or 0
end

function modifier_item_crystal_defender:GetModifierPreAttack_BonusDamage()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_damage") or 0
end

function modifier_item_crystal_defender:GetModifierBonusStats_Strength()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_strength") or 0
end

function modifier_item_crystal_defender:GetModifierIncomingDamageConstant(params)
    if not IsServer() then return 0 end
    if not self:IsPrimaryDefenseModifier() then return 0 end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or not ability then return 0 end
    if params.target ~= parent then return 0 end
    if bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end

    local damage = params.damage or 0
    if damage <= 0 then return 0 end

    local flat_reduction = ability:GetSpecialValueFor("flat_damage_reduction")
    local pct_reduction = ability:GetSpecialValueFor("damage_reduction_pct") * 0.01

    local after_flat = math.max(0, damage - flat_reduction)
    local final_damage = after_flat * (1 - pct_reduction)
    local prevented = damage - final_damage

    return -prevented
end

modifier_item_crystal_defender_active = class({})

function modifier_item_crystal_defender_active:IsHidden() return false end
function modifier_item_crystal_defender_active:IsPurgable() return false end
function modifier_item_crystal_defender_active:GetTexture() return "lotus_orb" end

function modifier_item_crystal_defender_active:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
end

function modifier_item_crystal_defender_active:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    parent:EmitSound("crystal_defender")
    self.effect_cast = ParticleManager:CreateParticle(WINTER_WYVERN_COLD_EMBRACE_PARTICLE, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(self.effect_cast, false, false, -1, false, false)
    self:StartIntervalThink(1.0)
end

function modifier_item_crystal_defender_active:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("crystal_defender")
end

function modifier_item_crystal_defender_active:OnIntervalThink()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or not ability then return end

    local heal_pct = ability:GetSpecialValueFor("active_heal_pct_per_second")
    local heal = parent:GetMaxHealth() * heal_pct * 0.01
    parent:Heal(heal, ability)
end
