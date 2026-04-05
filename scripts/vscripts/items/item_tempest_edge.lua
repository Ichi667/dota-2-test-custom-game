LinkLuaModifier("modifier_item_tempest_edge", "items/item_tempest_edge", LUA_MODIFIER_MOTION_NONE)

item_tempest_edge = class({})

function item_tempest_edge:GetIntrinsicModifierName()
    return "modifier_item_tempest_edge"
end

modifier_item_tempest_edge = class({})

function modifier_item_tempest_edge:IsHidden() return true end
function modifier_item_tempest_edge:IsPurgable() return false end
function modifier_item_tempest_edge:RemoveOnDeath() return false end
function modifier_item_tempest_edge:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_tempest_edge:OnCreated()
    if not IsServer() then return end
    self.attack_records = {}
end

function modifier_item_tempest_edge:OnRefresh()
    if not IsServer() then return end
    self.attack_records = self.attack_records or {}
end

function modifier_item_tempest_edge:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
    }
end

function modifier_item_tempest_edge:GetModifierEvasion_Constant()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_evasion") or 0
end

function modifier_item_tempest_edge:GetModifierBonusStats_Agility()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_agility") or 0
end

function modifier_item_tempest_edge:GetModifierPreAttack_BonusDamage()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_damage") or 0
end

function modifier_item_tempest_edge:GetModifierAttackSpeedBonus_Constant()
    local ability = self:GetAbility()
    return ability and ability:GetSpecialValueFor("bonus_attack_speed") or 0
end

function modifier_item_tempest_edge:OnAttackRecordDestroy(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end

    if params.record ~= nil and self.attack_records then
        self.attack_records[params.record] = nil
    end
end

function modifier_item_tempest_edge:OnAttackLanded(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if params.attacker ~= parent then return end
    if not ability or parent:IsIllusion() or parent:PassivesDisabled() then return end

    local target = params.target
    if not target or target:IsNull() or target:GetTeamNumber() == parent:GetTeamNumber() then return end
    if target:IsBuilding() or target:IsOther() then return end

    if params.record ~= nil then
        self.attack_records = self.attack_records or {}
        if self.attack_records[params.record] then return end
        self.attack_records[params.record] = true
    end

    if not RollPercentage(ability:GetSpecialValueFor("chain_chance")) then return end

    self:TriggerChainLightning(target)
end

function modifier_item_tempest_edge:TriggerChainLightning(initial_target)
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not parent or not ability or not initial_target then return end

    local bounce_count = ability:GetSpecialValueFor("chain_bounces")
    local bounce_radius = ability:GetSpecialValueFor("chain_radius")
    local damage = ability:GetSpecialValueFor("chain_damage")
    local total_hits = bounce_count + 1

    local hit_targets = {}
    local current_target = initial_target

    for _ = 1, total_hits do
        if not current_target or current_target:IsNull() or not current_target:IsAlive() then
            break
        end

        hit_targets[current_target:entindex()] = true

        local particle = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, current_target)
        ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_attack1", parent:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 1, current_target, PATTACH_POINT_FOLLOW, "attach_hitloc", current_target:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(particle)

        ApplyDamage({
            victim = current_target,
            attacker = parent,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = ability,
        })

        local enemies = FindUnitsInRadius(
            parent:GetTeamNumber(),
            current_target:GetAbsOrigin(),
            nil,
            bounce_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NO_INVIS,
            FIND_CLOSEST,
            false
        )

        local next_target = nil
        for _, enemy in ipairs(enemies) do
            if not hit_targets[enemy:entindex()] and enemy ~= current_target and enemy:IsAlive() and not enemy:IsBuilding() and not enemy:IsOther() then
                next_target = enemy
                break
            end
        end

        current_target = next_target
    end

    parent:EmitSound("Item.Maelstrom.Chain_Lightning")
end
