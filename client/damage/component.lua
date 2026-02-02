DAMAGE = {
	_required = { "Alerts" },
	IsLimping = function(self)
		return IsInjuryCausingLimp()
	end,
	GetDamageLabel = function(self, severity)
		return Config.WoundStates[severity]
	end,
	GetBleedLabel = function(self, severity)
		return Config.BleedingStates[severity]
	end,
	Alerts = {
		Reset = function(self)
			exports["prp-hud-v2"]:NotificationPersistentRemove(bleedNotifId)
			exports["prp-hud-v2"]:NotificationPersistentRemove(limbNotifId)
			exports["prp-hud-v2"]:NotificationPersistentRemove(bleedMoveNotifId)
		end,
		All = function(self)
			exports["prp-damage"]:AlertsBleed()
			exports["prp-damage"]:AlertsLimbs()
		end,
		Bleed = function(self)
			playerPed = PlayerPedId()
			if not IsEntityDead(playerPed) and LocalDamage ~= nil and LocalDamage.Bleed > 0 then
				exports["prp-hud-v2"]:NotificationPersistentCustom(
					bleedNotifId,
					string.format(Config.Strings.BleedAlert, Config.BleedingStates[LocalDamage.Bleed]),
					Config.NotifStyle
				)
			else
				exports["prp-hud-v2"]:NotificationPersistentRemove(bleedNotifId)
			end
		end,
		Limbs = function(self)
			playerPed = PlayerPedId()
			if not IsEntityDead(playerPed) then
				local size = cTable(_damagedLimbs)
				if size > 0 then
					local limbDamageMsg = ""
					if size <= Config.AlertShowInfo then
						local c = 0
						for k, v in pairs(_damagedLimbs) do
							c = c + 1
							limbDamageMsg = string.format(
								Config.Strings.LimbAlert,
								v.label,
								Config.WoundStates[v.severity]
							)
							if c < size then
								limbDamageMsg = limbDamageMsg .. Config.Strings.LimbAlertSeperator
							end
						end
					else
						limbDamageMsg = Config.Strings.LimbAlertMultiple
					end

					exports["prp-hud-v2"]:NotificationPersistentCustom(limbNotifId, limbDamageMsg)
				else
					exports["prp-hud-v2"]:NotificationPersistentRemove(limbNotifId)
				end
			else
				exports["prp-hud-v2"]:NotificationPersistentRemove(limbNotifId)
			end
		end,
		Debug = function(self, ped, bone, weapon, damageDone)
			exports["prp-hud-v2"]:NotificationStandard("Bone: " .. Config.Bones[bone])
			if Config.MinorInjurWeapons[weapon] ~= nil then
				exports["prp-hud-v2"]:NotificationStandard("Minor Weapon : " .. weapon, 10000)
			else
				exports["prp-hud-v2"]:NotificationStandard("Major Weapon : " .. weapon, 10000)
			end
			exports["prp-hud-v2"]:NotificationStandard("Crit Area: " .. tostring(Config.CriticalAreas[Config.Bones[bone]] ~= nil), 10000)
			exports["prp-hud-v2"]:NotificationStandard(
				"Stagger Area: "
					.. tostring(
						Config.StaggerAreas[Config.Bones[bone]] ~= nil
							and (Config.StaggerAreas[Config.Bones[bone]].armored or GetPedArmour(ped) <= 0)
					),
				10000
			)
			exports["prp-hud-v2"]:NotificationStandard("Dmg Done: " .. damageDone, 10000)
		end,
	},
	Apply = {
		StandardDamage = function(self, value, armorFirst)
			ApplyDamageToPed(playerPed, value, armorFirst)
		end,
		Bleed = function(self, level)
			exports["prp-base"]:CallbacksServer("Damage:ApplyBleed", level, function(new)
				exports["prp-damage"]:AlertsAll()
			end)
		end,
	},
}

--[[
IsLimping()
GetDamageLabel(severity)
GetBleedLabel(severity)
AlertsReset()
AlertsAll()
AlertsBleed()
AlertsLimbs()
AlertsDebug(ped, bone, weapon, damageDone)
ApplyStandardDamage(value, armorFirst)
ApplyBleed(level)
]]
local function exportHandler(exportName, func)
	AddEventHandler(('__cfx_export_%s_%s'):format(GetCurrentResourceName(), exportName), function(setCB)
        setCB(function(...)
			return func(DAMAGE, ...)
		end)
    end)
end

local function createExportForObject(object, name)
	name = name or ""
	for k, v in pairs(object) do
		if type(v) == "function" then
			exportHandler(name..k, v)
		elseif type(v) == "table" then
			createExportForObject(v, name..k)
		end
	end
end

for k, v in pairs(DAMAGE) do
	if type(v) == "function" then
		exportHandler(k, v)
	elseif type(v) == "table" then
		createExportForObject(v, k)
	end
end
