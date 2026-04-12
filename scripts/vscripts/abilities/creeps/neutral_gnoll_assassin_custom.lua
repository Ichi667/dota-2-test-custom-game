LinkLuaModifier("modifier_neutral_gnoll_assassin_bleed_custom", "abilities/creeps/neutral_gnoll_assassin_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_neutral_gnoll_assassin_bleed_custom_debuff", "abilities/creeps/neutral_gnoll_assassin_custom", LUA_MODIFIER_MOTION_NONE)

neutral_gnoll_assassin_bleed_custom = class({})

function neutral_gnoll_assassin_bleed_custom:GetIntrinsicModifierName()
	return "modifier_neutral_gnoll_assassin_bleed_custom"
end

modifier_neutral_gnoll_assassin_bleed_custom = class({})

function modifier_neutral_gnoll_assassin_bleed_custom:IsHidden() return true end
function modifier_neutral_gnoll_assassin_bleed_custom:IsPurgable() return false end

function modifier_neutral_gnoll_assassin_bleed_custom:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_neutral_gnoll_assassin_bleed_custom:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if not params.target or params.target:IsNull() then return end
	if params.target:IsBuilding() or params.target:IsOther() then return end

	local duration = self:GetAbility():GetSpecialValueFor("duration")
	params.target:AddNewModifier(
		self:GetParent(),
		self:GetAbility(),
		"modifier_neutral_gnoll_assassin_bleed_custom_debuff",
		{ duration = duration * (1 - params.target:GetStatusResistance()) }
	)
end

modifier_neutral_gnoll_assassin_bleed_custom_debuff = class({})

function modifier_neutral_gnoll_assassin_bleed_custom_debuff:IsDebuff() return true end
function modifier_neutral_gnoll_assassin_bleed_custom_debuff:IsPurgable() return true end

function modifier_neutral_gnoll_assassin_bleed_custom_debuff:OnCreated()
	self.damage_per_second = self:GetAbility():GetSpecialValueFor("damage_per_second")
	if not IsServer() then return end
	self:StartIntervalThink(1.0)
end

function modifier_neutral_gnoll_assassin_bleed_custom_debuff:OnRefresh()
	self.damage_per_second = self:GetAbility():GetSpecialValueFor("damage_per_second")
end

function modifier_neutral_gnoll_assassin_bleed_custom_debuff:OnIntervalThink()
	if not IsServer() then return end
	local ability = self:GetAbility()
	if not ability or ability:IsNull() then return end

	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.damage_per_second,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = ability,
	})
end
