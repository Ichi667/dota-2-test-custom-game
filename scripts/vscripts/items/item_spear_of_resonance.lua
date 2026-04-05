LinkLuaModifier("modifier_item_spear_of_resonance", "items/item_spear_of_resonance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_spear_of_resonance_echo", "items/item_spear_of_resonance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_spear_of_resonance_slow", "items/item_spear_of_resonance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_spear_of_resonance_chase", "items/item_spear_of_resonance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_spear_of_resonance_movespeed_cap", "items/item_spear_of_resonance", LUA_MODIFIER_MOTION_NONE)

item_spear_of_resonance = class({})
modifier_item_spear_of_resonance = class({})
modifier_item_spear_of_resonance_echo = class({})
modifier_item_spear_of_resonance_slow = class({})
modifier_item_spear_of_resonance_chase = class({})
modifier_item_spear_of_resonance_movespeed_cap = class({})

function item_spear_of_resonance:GetIntrinsicModifierName()
    return "modifier_item_spear_of_resonance"
end

--------------------------------------------------
-- MAIN MODIFIER
--------------------------------------------------

function modifier_item_spear_of_resonance:IsHidden()
    return true
end

function modifier_item_spear_of_resonance:IsPurgable()
    return false
end

function modifier_item_spear_of_resonance:RemoveOnDeath()
    return false
end

function modifier_item_spear_of_resonance:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_item_spear_of_resonance:OnCreated()
    self:UpdateValues()

    if not IsServer() then
        return
    end

    self.attack_records = {}
    self.chase_cooldown_end = 0
end

function modifier_item_spear_of_resonance:OnRefresh()
    self:UpdateValues()
end

function modifier_item_spear_of_resonance:UpdateValues()
    local ability = self:GetAbility()

    self.bonus_damage = 0
    self.bonus_strength = 0
    self.bonus_mana_regen = 0
    self.bonus_agility = 0
    self.bonus_attack_speed = 0
    self.bonus_move_speed_pct = 0

    self.echo_attack_speed_duration = 0.3
    self.echo_slow_duration = 0.8
    self.echo_slow_pct = 100
    self.echo_cooldown = 5

    self.chase_radius = 900
    self.chase_duration = 1.0
    self.chase_cooldown = 3.0
    self.chase_move_speed = 1000

    if not ability then
        return
    end

    self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
    self.bonus_strength = ability:GetSpecialValueFor("bonus_strength")
    self.bonus_mana_regen = ability:GetSpecialValueFor("bonus_mana_regen")
    self.bonus_agility = ability:GetSpecialValueFor("bonus_agility")
    self.bonus_attack_speed = ability:GetSpecialValueFor("bonus_attack_speed")
    self.bonus_move_speed_pct = ability:GetSpecialValueFor("bonus_move_speed_pct")

    self.echo_attack_speed_duration = ability:GetSpecialValueFor("echo_attack_speed_duration")
    self.echo_slow_duration = ability:GetSpecialValueFor("echo_slow_duration")
    self.echo_slow_pct = ability:GetSpecialValueFor("echo_slow_pct")
    self.echo_cooldown = ability:GetSpecialValueFor("echo_cooldown")

    self.chase_radius = ability:GetSpecialValueFor("chase_radius")
    self.chase_duration = ability:GetSpecialValueFor("chase_duration")
    self.chase_cooldown = ability:GetSpecialValueFor("chase_cooldown")
    self.chase_move_speed = ability:GetSpecialValueFor("chase_move_speed")
end

function modifier_item_spear_of_resonance:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY
    }
end

function modifier_item_spear_of_resonance:GetModifierPreAttack_BonusDamage()
    if not self:IsPrimaryItem() then
        return 0
    end

    return self.bonus_damage
end

function modifier_item_spear_of_resonance:GetModifierBonusStats_Strength()
    if not self:IsPrimaryItem() then
        return 0
    end

    return self.bonus_strength
end

function modifier_item_spear_of_resonance:GetModifierBonusStats_Agility()
    if not self:IsPrimaryItem() then
        return 0
    end

    return self.bonus_agility
end

function modifier_item_spear_of_resonance:GetModifierConstantManaRegen()
    if not self:IsPrimaryItem() then
        return 0
    end

    return self.bonus_mana_regen
end

function modifier_item_spear_of_resonance:GetModifierAttackSpeedBonus_Constant()
    if not self:IsPrimaryItem() then
        return 0
    end

    return self.bonus_attack_speed
end

function modifier_item_spear_of_resonance:GetModifierMoveSpeedBonus_Percentage()
    if not self:IsPrimaryItem() then
        return 0
    end

    return self.bonus_move_speed_pct
end

function modifier_item_spear_of_resonance:IsPrimaryItem()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then
        return false
    end

    local modifiers = parent:FindAllModifiersByName("modifier_item_spear_of_resonance")
    return modifiers[1] == self
end

--------------------------------------------------
-- CHASE PASSIVE
--------------------------------------------------

function modifier_item_spear_of_resonance:OnOrder(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()

    if not self:IsPrimaryItem() then
        return
    end

    if params.unit ~= parent then
        return
    end

    if parent:IsRangedAttacker() then
        return
    end

    local order_type = params.order_type

    local is_attack_order =
        order_type == DOTA_UNIT_ORDER_ATTACK_TARGET
        or order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET

    if not is_attack_order then
        if parent:HasModifier("modifier_item_spear_of_resonance_chase") then
            parent:RemoveModifierByName("modifier_item_spear_of_resonance_chase")
        end
        return
    end

    local target = params.target
    if not target or target:IsNull() then
        return
    end

    if target:GetTeamNumber() == parent:GetTeamNumber() then
        return
    end

    if not target:IsAlive() then
        return
    end

    if GameRules:GetGameTime() < self.chase_cooldown_end then
        return
    end

    local distance = (parent:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
    if distance > self.chase_radius then
        return
    end

    parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_spear_of_resonance_movespeed_cap", { duration = self.chase_duration })
    parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_spear_of_resonance_chase", {
        duration = self.chase_duration,
        target_entindex = target:entindex()
    })

    self.chase_cooldown_end = GameRules:GetGameTime() + self.chase_cooldown
end

--------------------------------------------------
-- ECHO PASSIVE
--------------------------------------------------

function modifier_item_spear_of_resonance:OnAttack(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    if not self:IsPrimaryItem() then
        return
    end

    if not ability or ability:IsNull() then
        return
    end

    if params.attacker ~= parent then
        return
    end

    if parent:IsRangedAttacker() then
        return
    end

    if not ability:IsCooldownReady() then
        return
    end

    parent:AddNewModifier(parent, ability, "modifier_item_spear_of_resonance_echo", {
        duration = self.echo_attack_speed_duration
    })

    self.attack_records[params.record] = true

    ability:StartCooldown(self.echo_cooldown)
end

function modifier_item_spear_of_resonance:OnAttackLanded(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()

    if not self:IsPrimaryItem() then
        return
    end

    if params.attacker ~= parent then
        return
    end

    if parent:IsRangedAttacker() then
        return
    end

    local target = params.target
    if not target or target:IsNull() then
        return
    end

    if self.attack_records[params.record] then
        target:AddNewModifier(parent, self:GetAbility(), "modifier_item_spear_of_resonance_slow", {
            duration = self.echo_slow_duration
        })
    end

    if parent:HasModifier("modifier_item_spear_of_resonance_chase") then
        local chase_modifier = parent:FindModifierByName("modifier_item_spear_of_resonance_chase")
        if chase_modifier and chase_modifier.target_entindex == target:entindex() then
            parent:RemoveModifierByName("modifier_item_spear_of_resonance_chase")
        end
    end
end

function modifier_item_spear_of_resonance:OnAttackRecordDestroy(params)
    if not IsServer() then
        return
    end

    self.attack_records[params.record] = nil
end

--------------------------------------------------
-- ECHO ATTACK SPEED
--------------------------------------------------

function modifier_item_spear_of_resonance_echo:IsHidden()
    return false
end

function modifier_item_spear_of_resonance_echo:IsPurgable()
    return false
end

function modifier_item_spear_of_resonance_echo:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_item_spear_of_resonance_echo:GetModifierAttackSpeedBonus_Constant()
    return 1000
end

--------------------------------------------------
-- SLOW
--------------------------------------------------

function modifier_item_spear_of_resonance_slow:IsHidden()
    return false
end

function modifier_item_spear_of_resonance_slow:IsPurgable()
    return true
end

function modifier_item_spear_of_resonance_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_item_spear_of_resonance_slow:GetModifierMoveSpeedBonus_Percentage()
    return -100
end

--------------------------------------------------
-- CHASE MOVE BUFF
--------------------------------------------------

function modifier_item_spear_of_resonance_chase:IsHidden()
    return false
end

function modifier_item_spear_of_resonance_chase:IsPurgable()
    return false
end

function modifier_item_spear_of_resonance_chase:OnCreated(params)
    if not IsServer() then
        return
    end

    self.target_entindex = params.target_entindex or -1
    self:StartIntervalThink(FrameTime())
end

function modifier_item_spear_of_resonance_chase:OnIntervalThink()
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    local target = nil

    if self.target_entindex and self.target_entindex ~= -1 then
        target = EntIndexToHScript(self.target_entindex)
    end

    if not parent or parent:IsNull() then
        self:Destroy()
        return
    end

    if not target or target:IsNull() then
        self:Destroy()
        return
    end

    if not target:IsAlive() then
        self:Destroy()
        return
    end

    if parent:GetAggroTarget() ~= target then
        self:Destroy()
        return
    end
end

function modifier_item_spear_of_resonance_chase:OnDestroy()
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    if parent and not parent:IsNull() then
        parent:RemoveModifierByName("modifier_item_spear_of_resonance_movespeed_cap")
    end
end

function modifier_item_spear_of_resonance_chase:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
    }
end

function modifier_item_spear_of_resonance_chase:GetModifierMoveSpeed_Absolute()
    local ability = self:GetAbility()
    if not ability then
        return 0
    end

    return ability:GetSpecialValueFor("chase_move_speed")
end

--------------------------------------------------
-- REMOVE MOVE SPEED CAP
--------------------------------------------------

function modifier_item_spear_of_resonance_movespeed_cap:IsHidden()
    return true
end

function modifier_item_spear_of_resonance_movespeed_cap:IsPurgable()
    return false
end

function modifier_item_spear_of_resonance_movespeed_cap:CheckState()
    return {
        [MODIFIER_STATE_UNSLOWABLE] = true
    }
end