modifier_neutral_camp_tag = class({})

function modifier_neutral_camp_tag:IsHidden()
    return true
end

function modifier_neutral_camp_tag:IsPurgable()
    return false
end

function modifier_neutral_camp_tag:RemoveOnDeath()
    return false
end

function modifier_neutral_camp_tag:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end
