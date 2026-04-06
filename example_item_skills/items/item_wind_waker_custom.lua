LinkLuaModifier("modifier_item_wind_waker_custom", "abilities/items/item_wind_waker_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_wind_waker_custom_active", "abilities/items/item_wind_waker_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_wind_waker_custom_speed", "abilities/items/item_wind_waker_custom", LUA_MODIFIER_MOTION_NONE)

item_wind_waker_custom = class({})

function item_wind_waker_custom:Precache(context)
if self:GetCaster() and self:GetCaster():IsIllusion() then return end
PrecacheResource( "particle","particles/econ/events/seasonal_reward_line_fall_2025/phase_boots_fallrewardline_2025.vpcf", context )
end

function item_wind_waker_custom:GetIntrinsicModifierName()
return "modifier_item_wind_waker_custom"
end

function item_wind_waker_custom:Spawn()
self.bonus_movement_speed = self:GetSpecialValueFor("bonus_movement_speed")
self.bonus_mana_regen = self:GetSpecialValueFor("bonus_mana_regen")
self.bonus_intellect = self:GetSpecialValueFor("bonus_intellect")
self.cyclone_duration = self:GetSpecialValueFor("cyclone_duration")
self.tooltip_drop_damage = self:GetSpecialValueFor("tooltip_drop_damage")
self.tornado_speed = self:GetSpecialValueFor("tornado_speed")
self.speed_duration = self:GetSpecialValueFor("speed_duration")
self.speed_move = self:GetSpecialValueFor("speed_move")
end

function item_wind_waker_custom:OnSpellStart()
local caster = self:GetCaster()
local target = self:GetCursorTarget()

if target:TriggerSpellAbsorb(self) then return end
target:EmitSound("DOTA_Item.Cyclone.Activate")

if target == caster then
  caster:Purge(false, true, false, false, false)
  caster:AddNewModifier(caster, self, "modifier_item_wind_waker_custom_active", {duration = self.cyclone_duration})
end
target:AddNewModifier(caster, self, "modifier_wind_waker", {duration = self.cyclone_duration})
end

modifier_item_wind_waker_custom_active = class(mod_hidden)
function modifier_item_wind_waker_custom_active:IsPurgable() return true end
function modifier_item_wind_waker_custom_active:OnDestroy()
if not IsServer() then return end
self.parent = self:GetParent()
self.ability = self:GetAbility()

if not IsValid(self.ability) then return end
self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_wind_waker_custom_speed", {duration = self.ability.speed_duration})
end

modifier_item_wind_waker_custom_speed = class(mod_visible)
function modifier_item_wind_waker_custom_speed:IsPurgable() return true end
function modifier_item_wind_waker_custom_speed:OnCreated(table)
self.parent = self:GetParent()
self.ability = self:GetAbility()

self.move = self.ability.speed_move
if not IsServer() then return end
self.parent:GenericParticle("particles/econ/events/seasonal_reward_line_fall_2025/phase_boots_fallrewardline_2025.vpcf", self)
end

function modifier_item_wind_waker_custom_speed:CheckState()
return
{
  [MODIFIER_STATE_UNSLOWABLE] = true
}
end

function modifier_item_wind_waker_custom_speed:DeclareFunctions()
return
{
  MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
}
end

function modifier_item_wind_waker_custom_speed:GetModifierMoveSpeedBonus_Percentage()
return self.move
end



modifier_item_wind_waker_custom = class(mod_hidden)
function modifier_item_wind_waker_custom:DeclareFunctions()
return
{
  MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
  MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
  MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
}
end

function modifier_item_wind_waker_custom:OnCreated()
self.parent = self:GetParent()
self.ability = self:GetAbility()

if not self.parent.cdr_items then
  self.parent.cdr_items = {}
end
self.parent.cdr_items[self] = self.ability:GetSpecialValueFor("cdr_bonus")
end

function modifier_item_wind_waker_custom:GetModifierConstantManaRegen()
return self.ability.bonus_mana_regen
end

function modifier_item_wind_waker_custom:GetModifierBonusStats_Intellect()
return self.ability.bonus_intellect
end

function modifier_item_wind_waker_custom:GetModifierMoveSpeedBonus_Constant()
return self.ability.bonus_movement_speed
end


