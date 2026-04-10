LinkLuaModifier("modifier_item_soul_reaper", "items/item_soul_reaper", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_soul_reaper_active", "items/item_soul_reaper", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_soul_reaper_movespeed_cap", "items/item_soul_reaper", LUA_MODIFIER_MOTION_NONE)

item_soul_reaper = class({})

function item_soul_reaper:GetIntrinsicModifierName()
    return "modifier_item_soul_reaper"
end

function item_soul_reaper:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("active_duration")

    if not caster then
        return
    end

    caster:Purge(false, true, false, false, false)
    caster:AddNewModifier(caster, self, "modifier_item_soul_reaper_active", { duration = duration })
    caster:EmitSound("DOTA_Item.DiffusalBlade.Target")
end

modifier_item_soul_reaper = class({})

function modifier_item_soul_reaper:IsHidden()
    return true
end

function modifier_item_soul_reaper:IsPurgable()
    return false
end

function modifier_item_soul_reaper:RemoveOnDeath()
    return false
end

function modifier_item_soul_reaper:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_soul_reaper:OnCreated()
    self:UpdateValues()

    if not IsServer() then
        return
    end

    self.proc_records = {}
    self.pseudo_random_id = DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1
end

function modifier_item_soul_reaper:OnRefresh()
    self:UpdateValues()
end

function modifier_item_soul_reaper:OnDestroy()
    if not IsServer() then
        return
    end

    self.proc_records = nil
end

function modifier_item_soul_reaper:UpdateValues()
    local ability = self:GetAbility()

    if not ability then
        self.bonus_damage = 0
        self.bonus_agility = 0
        self.bonus_intellect = 0
        self.proc_chance = 0
        self.proc_damage_pct = 0
        self.mana_burn_pct = 0
        self.mana_burn_flat = 0
        return
    end

    self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
    self.bonus_agility = ability:GetSpecialValueFor("bonus_agility")
    self.bonus_intellect = ability:GetSpecialValueFor("bonus_intellect")
    self.proc_chance = ability:GetSpecialValueFor("proc_chance")
    self.proc_damage_pct = ability:GetSpecialValueFor("proc_damage_pct")
    self.mana_burn_pct = ability:GetSpecialValueFor("mana_burn_pct")
    self.mana_burn_flat = ability:GetSpecialValueFor("mana_burn_flat")
end

function modifier_item_soul_reaper:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_EVENT_ON_ATTACK_RECORD,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_item_soul_reaper:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_item_soul_reaper:GetModifierBonusStats_Agility()
    return self.bonus_agility
end

function modifier_item_soul_reaper:GetModifierBonusStats_Intellect()
    return self.bonus_intellect
end

function modifier_item_soul_reaper:IsPrimaryModifier()
    if not IsServer() then
        return false
    end

    local parent = self:GetParent()
    local modifiers = parent:FindAllModifiersByName("modifier_item_soul_reaper")

    return modifiers[1] == self
end

function modifier_item_soul_reaper:OnAttackRecord(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()

    if params.attacker ~= parent then
        return
    end

    if not self:IsPrimaryModifier() then
        return
    end

    if parent:IsIllusion() then
        return
    end

    if parent:PassivesDisabled() then
        return
    end

    if not params.target then
        return
    end

    if params.target:IsBuilding() or params.target:IsOther() then
        return
    end

    if RollPseudoRandomPercentage(self.proc_chance, self.pseudo_random_id, parent) then
        self.proc_records[params.record] = true
    end
end

function modifier_item_soul_reaper:OnAttackLanded(params)
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local target = params.target

    if not ability then
        return
    end

    if params.attacker ~= parent then
        return
    end

    if not self.proc_records or not self.proc_records[params.record] then
        return
    end

    self.proc_records[params.record] = nil

    if parent:PassivesDisabled() then
        return
    end

    if not target or target:IsNull() then
        return
    end

    if not target:IsAlive() then
        return
    end

    local result = UnitFilter(
        target,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        DOTA_UNIT_TARGET_FLAG_NONE,
        parent:GetTeamNumber()
    )

    if result ~= UF_SUCCESS then
        return
    end

    local attack_damage = params.original_damage or params.damage or parent:GetAverageTrueAttackDamage(target)
    local pure_damage = attack_damage * self.proc_damage_pct * 0.01

    ApplyDamage({
        victim = target,
        attacker = parent,
        damage = pure_damage,
        damage_type = DAMAGE_TYPE_PURE,
        ability = ability
    })

    local mana_burn = math.floor((target:GetMaxMana() * self.mana_burn_pct * 0.01) + self.mana_burn_flat)
    mana_burn = math.min(target:GetMana(), mana_burn)

    if mana_burn > 0 then
        target:Script_ReduceMana(mana_burn, ability)
        self:PlayManaBurnEffects(target)
        parent:EmitSound("DOTA_Item.Daedelus.Crit")
    end
end

function modifier_item_soul_reaper:PlayManaBurnEffects(target)
    local particle_cast = "particles/generic_gameplay/generic_manaburn.vpcf"

    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

modifier_item_soul_reaper_active = class({})

function modifier_item_soul_reaper_active:IsHidden()
    return false
end

function modifier_item_soul_reaper_active:IsPurgable()
    return false
end

function modifier_item_soul_reaper_active:GetTexture()
    return "custom/soul_reaper"
end

function modifier_item_soul_reaper_active:OnCreated()
    self:UpdateValues()

    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    if ability then
        parent:AddNewModifier(parent, ability, "modifier_item_soul_reaper_movespeed_cap", { duration = self:GetDuration() })
    end

    self:StartIntervalThink(FrameTime())
end

function modifier_item_soul_reaper_active:OnRefresh()
    self:UpdateValues()

    if not IsServer() then
        return
    end

    self:StartIntervalThink(FrameTime())
end

function modifier_item_soul_reaper_active:OnDestroy()
    if not IsServer() then
        return
    end

    self:GetParent():RemoveModifierByName("modifier_item_soul_reaper_movespeed_cap")
end

function modifier_item_soul_reaper_active:UpdateValues()
    local ability = self:GetAbility()

    if not ability then
        self.active_move_speed_pct = 0
        self.current_bonus_pct = 0
        self.base_speed = 0
        self.total_duration = 0
        return
    end

    self.active_move_speed_pct = ability:GetSpecialValueFor("active_move_speed_pct")
    self.current_bonus_pct = self.active_move_speed_pct
    self.base_speed = self:GetParent():GetBaseMoveSpeed()
    self.total_duration = ability:GetSpecialValueFor("active_duration")
end

function modifier_item_soul_reaper_active:OnIntervalThink()
    if self.total_duration <= 0 then
        self.current_bonus_pct = 0
        return
    end

    local remaining = self:GetRemainingTime()
    local factor = math.max(remaining / self.total_duration, 0)

    self.current_bonus_pct = self.active_move_speed_pct * factor
end

function modifier_item_soul_reaper_active:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
    }
end

function modifier_item_soul_reaper_active:GetModifierMoveSpeed_Absolute()
    local absolute_speed = self.base_speed * (1 + self.current_bonus_pct * 0.01)
    return math.floor(absolute_speed)
end

modifier_item_soul_reaper_movespeed_cap = class({})

function modifier_item_soul_reaper_movespeed_cap:IsHidden()
    return true
end

function modifier_item_soul_reaper_movespeed_cap:IsPurgable()
    return false
end

function modifier_item_soul_reaper_movespeed_cap:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
    }
end

function modifier_item_soul_reaper_movespeed_cap:GetModifierIgnoreMovespeedLimit()
    return 1
end