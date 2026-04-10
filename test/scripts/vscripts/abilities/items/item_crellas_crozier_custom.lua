LinkLuaModifier( "modifier_item_crellas_crozier_custom_stats", "abilities/items/item_crellas_crozier_custom.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_crellas_crozier_custom_active", "abilities/items/item_crellas_crozier_custom.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_crellas_crozier_custom_aura", "abilities/items/item_crellas_crozier_custom.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_crellas_crozier_custom_active_move_change", "abilities/items/item_crellas_crozier_custom.lua", LUA_MODIFIER_MOTION_NONE )

item_crellas_crozier_custom = class({})

function item_crellas_crozier_custom:GetIntrinsicModifierName()
return "modifier_item_crellas_crozier_custom_stats" 
end

function item_crellas_crozier_custom:Precache(context)
if self:GetCaster() and self:GetCaster():IsIllusion() then return end
PrecacheResource( "particle","particles/items8_fx/crellas_crozier_pulses.vpcf", context )
PrecacheResource( "particle","particles/items8_fx/crellas_crozier_pulses_target.vpcf", context )
PrecacheResource( "particle","particles/items8_fx/crellas_crozier_debuff.vpcf", context )
end

function item_crellas_crozier_custom:OnSpellStart()
local caster = self:GetCaster()

caster:EmitSound("item_crozier.cast")
caster:AddNewModifier(caster, self, "modifier_item_crellas_crozier_custom_active", {duration = self.duration})
caster:AddNewModifier(caster, self, "modifier_ghost_state", {duration = self.duration})
end

modifier_item_crellas_crozier_custom_stats = class(mod_hidden)
function modifier_item_crellas_crozier_custom_stats:RemoveOnDeath() return false end
function modifier_item_crellas_crozier_custom_stats:OnCreated(keys)
self.parent = self:GetParent()
self.ability = self:GetAbility()
         
self.ability.bonus_all_stats = self.ability:GetSpecialValueFor("bonus_all_stats")
self.ability.bonus_health = self.ability:GetSpecialValueFor("bonus_health")
self.ability.bonus_mana = self.ability:GetSpecialValueFor("bonus_mana")
self.ability.duration = self.ability:GetSpecialValueFor("duration")
self.ability.extra_spell_damage_percent = self.ability:GetSpecialValueFor("extra_spell_damage_percent")
self.ability.radius = self.ability:GetSpecialValueFor("radius")
self.ability.health_steal = self.ability:GetSpecialValueFor("health_steal")
self.ability.interval = self.ability:GetSpecialValueFor("interval")
self.ability.active_radius = self.ability:GetSpecialValueFor("active_radius")
self.ability.movespeed_steal_pct = self.ability:GetSpecialValueFor("movespeed_steal_pct")
self.ability.active_health_steal = self.ability:GetSpecialValueFor("active_health_steal")
self.ability.stack_duration = self.ability:GetSpecialValueFor("stack_duration")         
self.ability.active_heal = self.ability:GetSpecialValueFor("active_heal")/100       
end

function modifier_item_crellas_crozier_custom_stats:DeclareFunctions()
return 
{ 
	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	MODIFIER_PROPERTY_HEALTH_BONUS,
	MODIFIER_PROPERTY_MANA_BONUS,
}
end

function modifier_item_crellas_crozier_custom_stats:GetModifierBonusStats_Agility()
return self.ability.bonus_all_stats
end

function modifier_item_crellas_crozier_custom_stats:GetModifierBonusStats_Intellect()
return self.ability.bonus_all_stats
end

function modifier_item_crellas_crozier_custom_stats:GetModifierBonusStats_Strength()
return self.ability.bonus_all_stats
end

function modifier_item_crellas_crozier_custom_stats:GetModifierHealthBonus()
return self.ability.bonus_health
end

function modifier_item_crellas_crozier_custom_stats:GetModifierManaBonus()
return self.ability.bonus_mana
end

function modifier_item_crellas_crozier_custom_stats:GetAuraRadius() return self.ability.radius end
function modifier_item_crellas_crozier_custom_stats:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_crellas_crozier_custom_stats:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_crellas_crozier_custom_stats:GetModifierAura() return "modifier_item_crellas_crozier_custom_aura" end
function modifier_item_crellas_crozier_custom_stats:IsAura() return true end


modifier_item_crellas_crozier_custom_aura = class(mod_visible)
function modifier_item_crellas_crozier_custom_aura:DeclareFunctions()
return 
{
	MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
} 
end

function modifier_item_crellas_crozier_custom_aura:OnCreated()
self.ability = self:GetAbility()
self.parent = self:GetParent()
self.caster = self:GetCaster()

self.heal_reduction = self.ability.health_steal
self.active_reduce = self.ability.active_health_steal
self.heal = self.ability.active_heal
if not IsServer() then return end
self.parent:AddHealEvent_inc(self, true)
end

function modifier_item_crellas_crozier_custom_aura:HealEvent_inc(params)
if not IsServer() then return end
if not self.caster:HasModifier("modifier_item_crellas_crozier_custom_active") then return end
if self.parent ~= params.unit then return end

if not self.caster:IsAlive() then return end
self.caster:GenericHeal(params.gain*self.heal, self.ability, true, "")
end

function modifier_item_crellas_crozier_custom_aura:GetModifierHealChange()
return (self.caster:HasModifier("modifier_item_crellas_crozier_custom_active") and self.active_reduce or self.heal_reduction)
end

function modifier_item_crellas_crozier_custom_aura:GetModifierHPRegenAmplify_Percentage()
return (self.caster:HasModifier("modifier_item_crellas_crozier_custom_active") and self.active_reduce or self.heal_reduction)
end





modifier_item_crellas_crozier_custom_active = class(mod_hidden)
function modifier_item_crellas_crozier_custom_active:IsPurgable() return true end
function modifier_item_crellas_crozier_custom_active:OnCreated()
self.parent = self:GetParent()
self.ability = self:GetAbility()
self.active_radius = self.ability.active_radius
self.speed_duration = self.ability.stack_duration
if not IsServer() then return end
self:OnIntervalThink()
self:StartIntervalThink(self.ability.interval - FrameTime())
end

function modifier_item_crellas_crozier_custom_active:OnIntervalThink()
if not IsServer() then return end

local particle = ParticleManager:CreateParticle("particles/items8_fx/crellas_crozier_pulses.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
ParticleManager:SetParticleControl(particle, 0, self.parent:GetAbsOrigin())
ParticleManager:SetParticleControl(particle, 1, Vector(self.active_radius, 0, 0))
ParticleManager:ReleaseParticleIndex(particle)

self.parent:EmitSound("item_crozier.pulse")

local targets = self.parent:FindTargets(self.active_radius) 
for _,target in pairs(targets) do
	local dir = (self.parent:GetAbsOrigin() - target:GetAbsOrigin()):Normalized()

	local particle = ParticleManager:CreateParticle("particles/items8_fx/crellas_crozier_pulses_target.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(particle, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(particle, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	ParticleManager:ReleaseParticleIndex(particle)

	target:AddNewModifier(self.parent, self.ability, "modifier_item_crellas_crozier_custom_active_move_change", {duration = self.speed_duration})
end

if #targets > 0 then
	self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_crellas_crozier_custom_active_move_change", {duration = self.speed_duration})
end

end


modifier_item_crellas_crozier_custom_active_move_change = class(mod_visible)
function modifier_item_crellas_crozier_custom_active_move_change:IsPurgable() return true end
function modifier_item_crellas_crozier_custom_active_move_change:OnCreated()
self.parent = self:GetParent()
self.caster = self:GetCaster()
self.ability = self:GetAbility()

self.max = self.ability.duration + 1
self.is_enemy = self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber()
self.move = self.ability.movespeed_steal_pct
if self.is_enemy then
	self.move = self.move*-1
end

if not IsServer() then return end
self:OnRefresh()
end

function modifier_item_crellas_crozier_custom_active_move_change:OnRefresh(table)
if not IsServer() then return end
if self:GetStackCount() >= self.max then return end
self:IncrementStackCount()

if self.is_enemy then
	self.parent:GenericParticle("particles/items8_fx/crellas_crozier_debuff.vpcf", self)
end

end

function modifier_item_crellas_crozier_custom_active_move_change:DeclareFunctions()
return
{
	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
}
end

function modifier_item_crellas_crozier_custom_active_move_change:GetModifierMoveSpeedBonus_Percentage()
return self.move*self:GetStackCount()
end
