LinkLuaModifier("modifier_lina_fiery_soul_lua", "abilities/lina/lina_fiery_soul_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lina_fiery_soul_custom_no_count", "abilities/lina/lina_fiery_soul_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lina_fiery_soul_custom_shard_barrier", "abilities/lina/lina_fiery_soul_custom", LUA_MODIFIER_MOTION_NONE)

lina_fiery_soul_custom = class({})

function lina_fiery_soul_custom:GetIntrinsicModifierName()
    return "modifier_lina_fiery_soul_lua"
end

--------------------------------------------------------------------------------
modifier_lina_fiery_soul_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_lina_fiery_soul_lua:IsHidden()
    return self:GetStackCount() == 0
end

function modifier_lina_fiery_soul_lua:IsDebuff()
    return false
end

function modifier_lina_fiery_soul_lua:IsPurgable()
    return false
end

function modifier_lina_fiery_soul_lua:DestroyOnExpire()
    return false
end

function modifier_lina_fiery_soul_lua:RemoveOnDeath()
    return false
end

function modifier_lina_fiery_soul_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

--------------------------------------------------------------------------------
-- Init
function modifier_lina_fiery_soul_lua:UpdateValues()
    local ability = self:GetAbility()
    if not ability then return end

    self.stack_duration = ability:GetSpecialValueFor("stack_duration")
    self.cooldown_reduction = ability:GetSpecialValueFor("cooldown_reduction_per_stack")
    self.cast_speed = ability:GetSpecialValueFor("cast_speed_per_stack")
    self.spell_bonus_damage = ability:GetSpecialValueFor("spell_damage_bonus_per_stack")
    self.max_stacks = ability:GetSpecialValueFor("max_stacks")

    local talent = self:GetParent():FindAbilityByName("special_bonus_unique_lina_custom_7")
    if talent and talent:GetLevel() > 0 then
        self.max_stacks = self.max_stacks + talent:GetSpecialValueFor("value")
    end
end

function modifier_lina_fiery_soul_lua:OnCreated(kv)
    self:UpdateValues()

    if not IsServer() then return end

    local parent = self:GetParent()

    parent._fiery_soul_stacks = parent._fiery_soul_stacks or 0
    parent._fiery_soul_expire_time = parent._fiery_soul_expire_time or 0

    local now = GameRules:GetGameTime()

    if parent._fiery_soul_stacks > 0 and parent._fiery_soul_expire_time > now then
        self:SetStackCount(math.min(parent._fiery_soul_stacks, self.max_stacks))
    else
        self:SetStackCount(0)
        parent._fiery_soul_stacks = 0
        parent._fiery_soul_expire_time = 0
    end

    self:PlayEffects()
    self:UpdateHudDuration()
    self:StartIntervalThink(0.1)
    self:SaveState()
end

function modifier_lina_fiery_soul_lua:OnRefresh(kv)
    self:UpdateValues()

    if not IsServer() then return end

    if self:GetStackCount() > self.max_stacks then
        self:SetStackCount(self.max_stacks)
    end

    self:SaveState()
    self:UpdateHudDuration()

    if self.effect_cast then
        ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self:GetStackCount(), 0, 0))
    end
end

function modifier_lina_fiery_soul_lua:OnRemoved()
end

function modifier_lina_fiery_soul_lua:OnDestroy()
    if not IsServer() then return end
    self:SaveState()
end

function modifier_lina_fiery_soul_lua:SaveState()
    local parent = self:GetParent()
    if not parent then return end

    parent._fiery_soul_stacks = self:GetStackCount()

    if self:GetStackCount() <= 0 then
        parent._fiery_soul_expire_time = 0
    end
end

function modifier_lina_fiery_soul_lua:UpdateHudDuration()
    if not IsServer() then return end

    local parent = self:GetParent()
    local remaining = math.max(0, (parent._fiery_soul_expire_time or 0) - GameRules:GetGameTime())

    if self:GetStackCount() > 0 and remaining > 0 then
        self:SetDuration(remaining, true)
    else
        self:SetDuration(-1, true)
    end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_lina_fiery_soul_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOOLTIP
    }

    return funcs
end

function modifier_lina_fiery_soul_lua:GetModifierPercentageCooldown()
    return self:GetStackCount() * self.cooldown_reduction
end

function modifier_lina_fiery_soul_lua:GetModifierPercentageCasttime()
    return self:GetStackCount() * self.cast_speed
end

function modifier_lina_fiery_soul_lua:OnTooltip()
    local parent = self:GetParent()
    return math.max(0, math.ceil((parent._fiery_soul_expire_time or 0) - GameRules:GetGameTime()))
end

function modifier_lina_fiery_soul_lua:OnAbilityExecuted(params)
    if not IsServer() then return end

    if params.unit ~= self:GetParent() then return end
    if self:GetParent():PassivesDisabled() then return end
    if not params.ability then return end
    if params.ability:IsItem() or params.ability:IsToggle() then return end

    local parent = self:GetParent()

    if self:GetStackCount() < self.max_stacks then
        self:IncrementStackCount()
    end

    parent._fiery_soul_expire_time = GameRules:GetGameTime() + self.stack_duration

    self:SaveState()
    self:UpdateHudDuration()

    if self.effect_cast then
        ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self:GetStackCount(), 0, 0))
    end
end

function modifier_lina_fiery_soul_lua:OnTakeDamage(params)
    if not IsServer() then return end

    if params.attacker ~= self:GetParent() then return end
    if params.damage <= 0 then return end
    if not params.inflictor then return end
    if params.inflictor:IsItem() then return end
    if params.inflictor == self:GetAbility() then return end
    if self:GetParent():HasModifier("modifier_lina_fiery_soul_custom_no_count") then return end

    local bonus = self:GetStackCount() * self.spell_bonus_damage
    if bonus <= 0 then return end

    self:GetParent():AddNewModifier(
        self:GetParent(),
        self:GetAbility(),
        "modifier_lina_fiery_soul_custom_no_count",
        { duration = FrameTime() }
    )

    ApplyDamage({
        attacker = self:GetParent(),
        victim = params.unit,
        damage = bonus,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
        damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
    })

    if self:GetParent():HasShard() then
        local barrier_mod = self:GetParent():FindModifierByName("modifier_lina_fiery_soul_custom_shard_barrier")
        if not barrier_mod then
            barrier_mod = self:GetParent():AddNewModifier(
                self:GetParent(),
                self:GetAbility(),
                "modifier_lina_fiery_soul_custom_shard_barrier",
                {}
            )
        end

        if barrier_mod then
            barrier_mod:AddBarrier(params.damage * self:GetAbility():GetSpecialValueFor("shard_barrier_pct") * 0.01)
        end
    end
end

--------------------------------------------------------------------------------
-- Interval
function modifier_lina_fiery_soul_lua:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local now = GameRules:GetGameTime()
    local expire_time = parent._fiery_soul_expire_time or 0

    if self:GetStackCount() <= 0 then
        parent._fiery_soul_stacks = 0
        parent._fiery_soul_expire_time = 0
        self:UpdateHudDuration()

        if self.effect_cast then
            ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(0, 0, 0))
        end
        return
    end

    if expire_time <= 0 or now >= expire_time then
        self:SetStackCount(0)
        parent._fiery_soul_stacks = 0
        parent._fiery_soul_expire_time = 0
    end

    if self.effect_cast then
        ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self:GetStackCount(), 0, 0))
    end
end

--------------------------------------------------------------------------------
-- Graphics
function modifier_lina_fiery_soul_lua:PlayEffects()
    local particle_cast = "particles/units/heroes/hero_lina/lina_fiery_soul.vpcf"

    self.effect_cast = ParticleManager:CreateParticle(
        particle_cast,
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )

    ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self:GetStackCount(), 0, 0))

    self:AddParticle(
        self.effect_cast,
        false,
        false,
        -1,
        false,
        false
    )
end

--------------------------------------------------------------------------------
modifier_lina_fiery_soul_custom_no_count = class({})

function modifier_lina_fiery_soul_custom_no_count:IsHidden()
    return true
end

function modifier_lina_fiery_soul_custom_no_count:IsPurgable()
    return false
end

function modifier_lina_fiery_soul_custom_no_count:RemoveOnDeath()
    return false
end

function modifier_lina_fiery_soul_custom_no_count:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

--------------------------------------------------------------------------------
modifier_lina_fiery_soul_custom_shard_barrier = class({})

function modifier_lina_fiery_soul_custom_shard_barrier:IsHidden()
    return false
end

function modifier_lina_fiery_soul_custom_shard_barrier:IsPurgable()
    return false
end

function modifier_lina_fiery_soul_custom_shard_barrier:RemoveOnDeath()
    return false
end

function modifier_lina_fiery_soul_custom_shard_barrier:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_lina_fiery_soul_custom_shard_barrier:GetTexture()
    return "item_aeon_disk"
end

function modifier_lina_fiery_soul_custom_shard_barrier:OnCreated()
    if not IsServer() then return end

    self.barrier = 0
    self:SetHasCustomTransmitterData(true)

    local ability = self:GetAbility()
    if ability and ability._fiery_soul_barrier then
        self.barrier = ability._fiery_soul_barrier
    end

    self:SendBuffRefreshToClients()
end

function modifier_lina_fiery_soul_custom_shard_barrier:OnRefresh()
    if not IsServer() then return end
    self:SaveBarrier()
    self:SendBuffRefreshToClients()
end

function modifier_lina_fiery_soul_custom_shard_barrier:OnDestroy()
    if not IsServer() then return end
    self:SaveBarrier()
end

function modifier_lina_fiery_soul_custom_shard_barrier:SaveBarrier()
    local ability = self:GetAbility()
    if not ability then return end
    ability._fiery_soul_barrier = self.barrier or 0
end

function modifier_lina_fiery_soul_custom_shard_barrier:AddBarrier(value)
    if not IsServer() then return end

    self.barrier = (self.barrier or 0) + value
    self:SaveBarrier()
    self:SendBuffRefreshToClients()
end

function modifier_lina_fiery_soul_custom_shard_barrier:AddCustomTransmitterData()
    return { barrier = self.barrier or 0 }
end

function modifier_lina_fiery_soul_custom_shard_barrier:HandleCustomTransmitterData(data)
    self.barrier = data.barrier or 0
end

function modifier_lina_fiery_soul_custom_shard_barrier:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_lina_fiery_soul_custom_shard_barrier:OnTooltip()
    return self.barrier or 0
end

function modifier_lina_fiery_soul_custom_shard_barrier:GetModifierIncomingDamageConstant(params)
    if not IsServer() then
        if params.report_max then
            return self.barrier or 0
        end
        return 0
    end

    if params.damage <= 0 then return 0 end
    if self.barrier <= 0 then return 0 end

    local block = math.min(self.barrier, params.damage)
    self.barrier = self.barrier - block
    self:SaveBarrier()

    if self.barrier <= 0 then
        self:Destroy()
    else
        self:SendBuffRefreshToClients()
    end

    return -block
end