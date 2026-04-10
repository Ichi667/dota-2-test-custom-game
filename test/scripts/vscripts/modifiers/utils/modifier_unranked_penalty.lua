

modifier_unranked_penalty_1 = class(mod_visible)
function modifier_unranked_penalty_1:IsDebuff() return true end
function modifier_unranked_penalty_1:RemoveOnDeath() return false end
function modifier_unranked_penalty_1:GetTexture() return "buffs/generic/unranked_penalty" end
function modifier_unranked_penalty_1:OnCreated(table)
self.damage = UNRANKED_DAMAGE_PENALTY
self.rating = UNRANKED_RATING_PENALTY
end

function modifier_unranked_penalty_1:DeclareFunctions()
return
{
    MODIFIER_PROPERTY_TOOLTIP,
    MODIFIER_PROPERTY_TOOLTIP2
}
end

function modifier_unranked_penalty_1:OnTooltip()
return self.rating
end

function modifier_unranked_penalty_1:OnTooltip2()
return self.damage
end


modifier_unranked_penalty_2 = class(mod_visible)
function modifier_unranked_penalty_2:IsDebuff() return true end
function modifier_unranked_penalty_2:RemoveOnDeath() return false end
function modifier_unranked_penalty_2:GetTexture() return "buffs/generic/unranked_penalty" end
function modifier_unranked_penalty_2:OnCreated(table)
self.damage = UNRANKED_DAMAGE_PENALTY
end

function modifier_unranked_penalty_2:DeclareFunctions()
return
{
    MODIFIER_PROPERTY_TOOLTIP,
    MODIFIER_PROPERTY_TOOLTIP2
}
end

function modifier_unranked_penalty_2:OnTooltip()
return self.rating
end

function modifier_unranked_penalty_2:OnTooltip2()
return self.damage
end

