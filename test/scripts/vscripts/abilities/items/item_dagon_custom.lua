LinkLuaModifier("modifier_item_dagon_custom", "abilities/items/item_dagon_custom", LUA_MODIFIER_MOTION_NONE)

item_dagon_custom = class({})

function item_dagon_custom:Precache(context)
if self:GetCaster() and self:GetCaster():IsIllusion() then return end
PrecacheResource( "particle","particles/items_fx/dagon.vpcf", context )
end

function item_dagon_custom:GetIntrinsicModifierName() return "modifier_item_dagon_custom" end

function item_dagon_custom:GetAOERadius()
return self:GetSpecialValueFor("aoe_radius")
end

function item_dagon_custom:OnSpellStart()
local mod = self:GetCaster():FindModifierByName("modifier_item_dagon_custom")
if mod then
    mod:DealDamage(self:GetCursorTarget())
end

end

item_dagon_2_custom = class(item_dagon_custom)
item_dagon_3_custom = class(item_dagon_custom)
item_dagon_4_custom = class(item_dagon_custom)
item_dagon_5_custom = class(item_dagon_custom)


modifier_item_dagon_custom = class({})
function modifier_item_dagon_custom:IsHidden() return true end
function modifier_item_dagon_custom:IsPurgable() return false end
function modifier_item_dagon_custom:DeclareFunctions()
return 
{
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    MODIFIER_PROPERTY_HEALTH_BONUS,
    MODIFIER_PROPERTY_MANA_BONUS,
    MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
}
end

function modifier_item_dagon_custom:GetModifierSpellAmplify_Percentage()
return self.bonus_damage
end

function modifier_item_dagon_custom:GetModifierHealthBonus()
return self.bonus_health
end

function modifier_item_dagon_custom:GetModifierManaBonus()
return self.bonus_mana
end

function modifier_item_dagon_custom:GetModifierCastRangeBonusStacking()
return self.bonus_range
end

function modifier_item_dagon_custom:OnCreated()
self.ability = self:GetAbility()
self.parent = self:GetParent()

self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")
self.bonus_health = self.ability:GetSpecialValueFor("bonus_health")
self.bonus_mana = self.ability:GetSpecialValueFor("bonus_mana")
self.bonus_range = self.ability:GetSpecialValueFor("bonus_range")
self.active_heal = self.ability:GetSpecialValueFor("active_heal")/100

self.radius = self.ability:GetSpecialValueFor("aoe_radius")
self.damage = self.ability:GetSpecialValueFor("damage")
self.mana_damage = self.ability:GetSpecialValueFor("mana_damage")/100
end

function modifier_item_dagon_custom:DealDamage(target)
if not IsServer() then return end

local caster = self.parent
local point = target:GetAbsOrigin()

target:EmitSound("DOTA_Item.Dagon"..self.ability:GetLevel()..".Target")

if target:TriggerSpellAbsorb(self.ability) then return end

caster:EmitSound("DOTA_Item.Dagon.Activate")

local damage = self.damage + caster:GetMaxMana()*self.mana_damage
local damage_table = { attacker = caster, ability = self.ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL }

local visual_caster = caster
local mod = caster:FindModifierByName("modifier_life_stealer_infest_custom")
if mod and mod.target then
    visual_caster = mod.target
end

local get_dagon_nyx_wearable = visual_caster:GetItemWearableHandle("misc")
if visual_caster and get_dagon_nyx_wearable and get_dagon_nyx_wearable:GetModelName() == "models/items/nerubian_assassin/nyx_dagon.vmdl" then
    visual_caster = get_dagon_nyx_wearable
end

for _, enemy in pairs(caster:FindTargets(self.radius, point)) do
    local dagon_pfx = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf", PATTACH_RENDERORIGIN_FOLLOW, visual_caster)
    ParticleManager:SetParticleControlEnt(dagon_pfx, 0, visual_caster, PATTACH_POINT_FOLLOW, "attach_attack1", visual_caster:GetAbsOrigin(), false)
    ParticleManager:SetParticleControlEnt(dagon_pfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), false)
    ParticleManager:SetParticleControl(dagon_pfx, 2, Vector(damage, 0, 0))
    ParticleManager:SetParticleControl(dagon_pfx, 3, Vector(0.3, 0, 0))
    ParticleManager:ReleaseParticleIndex(dagon_pfx)

    damage_table.victim = enemy
    local damage = DoDamage(damage_table)

    if enemy == target then 
        local result = caster:CanLifesteal(enemy)
        if result then
            caster:GenericHeal(damage*self.active_heal*result, self.ability)
        end
    end
    if enemy:IsIllusion() and not enemy:HasModifier("modifier_chaos_knight_phantasm_illusion") then
        enemy:Kill(self.ability, caster)
    end
end

end