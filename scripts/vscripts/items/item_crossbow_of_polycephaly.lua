LinkLuaModifier("modifier_item_crossbow_of_polycephaly", "items/item_crossbow_of_polycephaly", LUA_MODIFIER_MOTION_NONE)

item_crossbow_of_polycephaly = class({})
modifier_item_crossbow_of_polycephaly = class({})

function item_crossbow_of_polycephaly:GetIntrinsicModifierName()
    return "modifier_item_crossbow_of_polycephaly"
end

modifier_item_crossbow_of_polycephaly.__index = modifier_item_crossbow_of_polycephaly

function modifier_item_crossbow_of_polycephaly:IsHidden()
    return true
end

function modifier_item_crossbow_of_polycephaly:IsPurgable()
    return false
end

function modifier_item_crossbow_of_polycephaly:RemoveOnDeath()
    return false
end

function modifier_item_crossbow_of_polycephaly:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_crossbow_of_polycephaly:OnCreated()
    self.records = {}
    self.pending_secondary = nil
    self:UpdateValues()
end

function modifier_item_crossbow_of_polycephaly:OnRefresh()
    self:UpdateValues()
end

function modifier_item_crossbow_of_polycephaly:UpdateValues()
    local ability = self:GetAbility()

    self.bonus_strength = 0
    self.bonus_agility = 0
    self.bonus_intellect = 0
    self.bonus_damage = 0
    self.bonus_range = 0

    self.distance_step = 100
    self.distance_damage_pct = 5

    self.count = 0
    self.secondary_target_range_bonus = 0
    self.secondary_target_angle = 120
    self.proc_chance = 0
    self.base_proc_dmg = 0
    self.proc_dmg_pct = 0
    self.proc_dmg_pct_primary = 0

    if not ability then
        return
    end

    self.bonus_strength = ability:GetSpecialValueFor("strength")
    self.bonus_agility = ability:GetSpecialValueFor("agility")
    self.bonus_intellect = ability:GetSpecialValueFor("intellect")
    self.bonus_damage = ability:GetSpecialValueFor("damage")
    self.bonus_range = ability:GetSpecialValueFor("range_bonus")

    self.distance_step = ability:GetSpecialValueFor("distance_step")
    self.distance_damage_pct = ability:GetSpecialValueFor("distance_damage_pct")

    self.count = ability:GetSpecialValueFor("count")
    self.secondary_target_range_bonus = ability:GetSpecialValueFor("secondary_target_range_bonus")
    self.secondary_target_angle = ability:GetSpecialValueFor("secondary_target_angle")
    self.proc_chance = ability:GetSpecialValueFor("proc_chance")
    self.base_proc_dmg = ability:GetSpecialValueFor("base_proc_dmg")
    self.proc_dmg_pct = ability:GetSpecialValueFor("proc_dmg_pct")
    self.proc_dmg_pct_primary = ability:GetSpecialValueFor("proc_dmg_pct_primary")
end

function modifier_item_crossbow_of_polycephaly:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_EVENT_ON_ATTACK_RECORD,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY
    }
end

function modifier_item_crossbow_of_polycephaly:GetModifierBonusStats_Strength()
    return self.bonus_strength
end

function modifier_item_crossbow_of_polycephaly:GetModifierBonusStats_Agility()
    return self.bonus_agility
end

function modifier_item_crossbow_of_polycephaly:GetModifierBonusStats_Intellect()
    return self.bonus_intellect
end

function modifier_item_crossbow_of_polycephaly:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_item_crossbow_of_polycephaly:GetModifierAttackRangeBonus()
    local parent = self:GetParent()

    if not parent or not parent:IsRangedAttacker() then
        return 0
    end

    return self.bonus_range
end

function modifier_item_crossbow_of_polycephaly:OnAttackRecord(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()

    if parent:FindAllModifiersByName("modifier_item_crossbow_of_polycephaly")[1] ~= self then
        return
    end

    if params.attacker ~= parent then
        return
    end

    if not parent:IsRangedAttacker() then
        return
    end

    local target = params.target
    if not target or target:IsNull() then
        return
    end

    local record_data = {
        target_entindex = target:entindex(),
        attack_damage_snapshot = parent:GetAverageTrueAttackDamage(target),
        is_secondary = false,
        poly_multiplier_pct = 0,
        poly_flat_damage = 0,
        allow_poly_proc = true
    }

    if self.pending_secondary then
        if self.pending_secondary.target_entindex == target:entindex() then
            record_data.is_secondary = true
            record_data.poly_multiplier_pct = self.pending_secondary.poly_multiplier_pct
            record_data.poly_flat_damage = self.pending_secondary.poly_flat_damage
            record_data.allow_poly_proc = false
            record_data.attack_damage_snapshot = self.pending_secondary.attack_damage_snapshot
            self.pending_secondary = nil
        end
    end

    self.records[params.record] = record_data
end

function modifier_item_crossbow_of_polycephaly:OnAttack(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    if params.attacker ~= parent then
        return
    end

    if not parent:IsRangedAttacker() then
        return
    end

    if not ability or ability:IsNull() then
        return
    end

    local target = params.target
    if not target or target:IsNull() or target:IsOther() then
        return
    end

    local data = self.records[params.record]
    if not data then
        return
    end

    if data.is_secondary then
        return
    end

    if not data.allow_poly_proc then
        return
    end

    if not RollPercentage(self.proc_chance) then
        return
    end

    data.poly_multiplier_pct = self.proc_dmg_pct_primary
    data.poly_flat_damage = self.base_proc_dmg

    self:LaunchSecondaryAttacks(parent, target, data.attack_damage_snapshot)
end

function modifier_item_crossbow_of_polycephaly:GetModifierProcAttack_BonusDamage_Physical(params)
    if not IsServer() then
        return 0
    end

    local parent = self:GetParent()

    if parent:FindAllModifiersByName("modifier_item_crossbow_of_polycephaly")[1] ~= self then
        return 0
    end

    if params.attacker ~= parent then
        return 0
    end

    local data = self.records[params.record]
    if not data then
        return 0
    end

    local target = params.target
    if not target or target:IsNull() then
        return 0
    end

    local base_attack_damage = data.attack_damage_snapshot or 0
    if base_attack_damage <= 0 then
        return 0
    end

    local desired_total_damage = base_attack_damage

    if data.poly_flat_damage > 0 or data.poly_multiplier_pct > 0 then
        desired_total_damage =
            self.base_proc_dmg
            + base_attack_damage * data.poly_multiplier_pct / 100
    end

    if not data.is_secondary then
        desired_total_damage = base_attack_damage + desired_total_damage - base_attack_damage
        desired_total_damage = base_attack_damage + self.base_proc_dmg + base_attack_damage * data.poly_multiplier_pct / 100
    end

    local distance_multiplier = self:GetDistanceMultiplier(parent, target)
    desired_total_damage = desired_total_damage * distance_multiplier

    local bonus_damage = desired_total_damage - base_attack_damage

    return bonus_damage
end

function modifier_item_crossbow_of_polycephaly:OnAttackRecordDestroy(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()

    if parent:FindAllModifiersByName("modifier_item_crossbow_of_polycephaly")[1] ~= self then
        return
    end

    self.records[params.record] = nil
end

function modifier_item_crossbow_of_polycephaly:GetDistanceMultiplier(attacker, target)
    if self.distance_step <= 0 then
        return 1
    end

    local distance = (attacker:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
    local steps = math.floor(distance / self.distance_step)

    if steps <= 0 then
        return 1
    end

    local bonus_pct = steps * self.distance_damage_pct
    return 1 + bonus_pct / 100
end

function modifier_item_crossbow_of_polycephaly:LaunchSecondaryAttacks(attacker, primary_target, attack_damage_snapshot)
    local origin = attacker:GetAbsOrigin()
    local forward = attacker:GetForwardVector()
    local attack_range = attacker:Script_GetAttackRange()
    local search_radius = attack_range + self.secondary_target_range_bonus

    local enemies = FindUnitsInRadius(
        attacker:GetTeamNumber(),
        origin,
        nil,
        search_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_CLOSEST,
        false
    )

    local hit_count = 0

    for _, enemy in ipairs(enemies) do
        if enemy ~= primary_target and enemy ~= attacker and not enemy:IsNull() and enemy:IsAlive() then
            if self:IsTargetInsideCone(attacker, enemy, forward, self.secondary_target_angle) then
                self.pending_secondary = {
                    target_entindex = enemy:entindex(),
                    poly_multiplier_pct = self.proc_dmg_pct,
                    poly_flat_damage = self.base_proc_dmg,
                    attack_damage_snapshot = attack_damage_snapshot
                }

                attacker:PerformAttack(
                    enemy,
                    false,
                    false,
                    true,
                    false,
                    true,
                    false,
                    false
                )

                hit_count = hit_count + 1

                if hit_count >= self.count then
                    break
                end
            end
        end
    end
end

function modifier_item_crossbow_of_polycephaly:IsTargetInsideCone(attacker, target, forward, angle)
    local direction = target:GetAbsOrigin() - attacker:GetAbsOrigin()
    direction.z = 0

    if direction:Length2D() <= 0 then
        return true
    end

    direction = direction:Normalized()

    local flat_forward = Vector(forward.x, forward.y, 0)

    if flat_forward:Length2D() <= 0 then
        return true
    end

    flat_forward = flat_forward:Normalized()

    local dot = flat_forward.x * direction.x + flat_forward.y * direction.y
    local limit = math.cos(math.rad(angle / 2))

    return dot >= limit
end