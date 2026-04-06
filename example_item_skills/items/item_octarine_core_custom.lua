LinkLuaModifier("modifier_item_octarine_core_custom", "abilities/items/item_octarine_core_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_octarine_core_custom_active", "abilities/items/item_octarine_core_custom", LUA_MODIFIER_MOTION_NONE)

item_octarine_core_custom = class({})

function item_octarine_core_custom:GetIntrinsicModifierName()
return "modifier_item_octarine_core_custom"
end

function item_octarine_core_custom:Precache(context)
if self:GetCaster() and self:GetCaster():IsIllusion() then return end

PrecacheResource( "particle","particles/leshrac/storm_refresh.vpcf", context )
end

function item_octarine_core_custom:OnSpellStart()
local caster = self:GetCaster()

if IsValid(self.last_spell) then
	caster:CdAbility(self.last_spell, nil, self.active_cdr)
end

local effect = ParticleManager:CreateParticle("particles/leshrac/storm_refresh.vpcf", PATTACH_CUSTOMORIGIN, caster)
ParticleManager:SetParticleControlEnt( effect, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true )
ParticleManager:ReleaseParticleIndex(effect)
caster:EmitSound("Item.Octarine.Activate")

caster:AddNewModifier(caster, self, "modifier_item_octarine_core_custom_active", {duration = self.duration})
end


modifier_item_octarine_core_custom = class(mod_hidden)
function modifier_item_octarine_core_custom:RemoveOnDeath()	return false end
function modifier_item_octarine_core_custom:OnCreated()
self.parent = self:GetParent()
self.ability = self:GetAbility()

if not self.parent.cdr_items then
  self.parent.cdr_items = {}
end
self.parent.cdr_items[self] = self.ability:GetSpecialValueFor("cdr_bonus")

self.bonus_health = self.ability:GetSpecialValueFor("bonus_health")
self.bonus_mana = self.ability:GetSpecialValueFor("bonus_mana")
self.mana_reduce = self.ability:GetSpecialValueFor("mana_reduce")
self.ability.active_cdr = self.ability:GetSpecialValueFor("active_cdr")/100
self.ability.duration = self.ability:GetSpecialValueFor("duration")
if not IsServer() then return end
if not self.parent:IsRealHero() then return end
self.parent:AddSpellEvent(self, true)
end

function modifier_item_octarine_core_custom:SpellEvent(params)
if not IsServer() then return end
if self.parent ~= params.unit then return end
if not params.ability:IsItem() then return end
if params.ability == self.ability then return end
if NoCdItems[params.ability:GetName()] then return end

self.ability.last_spell = params.ability 
end

function modifier_item_octarine_core_custom:DeclareFunctions()
return
{
	MODIFIER_PROPERTY_HEALTH_BONUS,
	MODIFIER_PROPERTY_MANA_BONUS,
    MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
}
end

function modifier_item_octarine_core_custom:GetModifierPercentageManacostStacking()
return self.mana_reduce
end

function modifier_item_octarine_core_custom:GetModifierHealthBonus()
return self.bonus_health
end

function modifier_item_octarine_core_custom:GetModifierManaBonus()
return self.bonus_mana
end



modifier_item_octarine_core_custom_active = class(mod_visible)
function modifier_item_octarine_core_custom_active:OnCreated()
self.parent = self:GetParent()
self.ability = self:GetAbility()

self.reduce = 100

if not IsServer() then return end
self.parent:GenericParticle("particles/generic_gameplay/rune_arcane_owner.vpcf", self)
end

function modifier_item_octarine_core_custom_active:DeclareFunctions()
return
{
	MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
}
end

function modifier_item_octarine_core_custom_active:GetModifierPercentageManacostStacking(params)
return self.reduce
end


