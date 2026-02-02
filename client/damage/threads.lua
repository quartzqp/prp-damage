Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local CanSendDistress = false
local HasSentDistress = false
local LastJump = nil
local JumpCooldown = 2000.0
local MovementRate = 1.0

local _respawning = false
local _waiting = false
local _countdown = 300
local _sendToHosp = false

LocalPlayer.state.isDead = false

function DisableControls()
	Citizen.CreateThread(function()
		while loggedIn and isDead do
			DisableControlAction(0, 30, true) -- disable left/right
			DisableControlAction(0, 31, true) -- disable forward/back
			DisableControlAction(0, 36, true) -- INPUT_DUCK
			DisableControlAction(0, 21, true) -- disable sprint
			DisableControlAction(0, 44, true) -- disable cover
			DisableControlAction(0, 63, true) -- veh turn left
			DisableControlAction(0, 64, true) -- veh turn right
			DisableControlAction(0, 71, true) -- veh forward
			DisableControlAction(0, 72, true) -- veh backwards
			DisableControlAction(0, 75, true) -- disable exit vehicle
			DisablePlayerFiring(playerId, true) -- Disable weapon firing
			DisableControlAction(0, 24, true) -- disable attack
			DisableControlAction(0, 25, true) -- disable aim
			DisableControlAction(1, 37, true) -- disable weapon select
			DisableControlAction(0, 47, true) -- disable weapon
			DisableControlAction(0, 58, true) -- disable weapon
			DisableControlAction(0, 140, true) -- disable melee
			DisableControlAction(0, 141, true) -- disable melee
			DisableControlAction(0, 142, true) -- disable melee
			DisableControlAction(0, 143, true) -- disable melee
			DisableControlAction(0, 263, true) -- disable melee
			DisableControlAction(0, 264, true) -- disable melee
			DisableControlAction(0, 257, true) -- disable melee
			Citizen.Wait(0)
		end
	end)
end

AddEventHandler("prp-injuries:respawn", function()
	if (isDead and not LocalPlayer.state.isHospitalized) then
		if LocalPlayer.state.isInTrolleyEntity or LocalPlayer.state.isPushingTrolleyEntity then
			if LocalPlayer.state.isInTrolleyEntity then
				TriggerServerEvent('prp-injuries:server:removeFromTrolley')
			elseif LocalPlayer.state.isPushingTrolleyEntity then
				TriggerServerEvent('prp-injuries:server:stopPushingTrolley')
			end
			Wait(1000)
		end
		
		if not LocalPlayer.state.myEscorter then
			if not LocalPlayer.state.myEscorter then
                if GetConvarInt("allowOnlyCharacterCreation", 0) == 1 then
                    local success = lib.callback.await("prp-damage:server:respawnInCharMingleZone", false)
                    if success then
                        local coords = vector4(456.369, -724.378, 27.359, 173.464)
                        SetEntityCoords(cache.ped, coords.x, coords.y, coords.z)
                        SetEntityHeading(cache.ped, coords.w)

                        TriggerEvent('prp-injuries:hospitalBedHeal', false, _currentCheckInZone)
                        return
                    end
                end

				exports["prp-base"]:CallbacksServer("Hospital:Respawn", {}, function(bedId)
					if bedId ~= nil then
						if bedId ~= 'teleport' then
							_sendToHosp = bedId
							_countdown = Config.HealTimer
							LocalPlayer.state:set("isHospitalized", true, true)
							exports["prp-damage"]:HospitalSendToBed(Config.Beds[_sendToHosp], false, _sendToHosp)
							_waiting = false
						end
					else
						exports["prp-hud-v2"]:NotificationError(locale("NO_HOSPITAL_BEDS"))
					end
				end)
			else
				exports["prp-hud-v2"]:NotificationError(locale("CANNOT_RESPAWN_DURING_ESCORT"))
			end
		else
			exports["prp-hud-v2"]:NotificationError(locale("CANNOT_RESPAWN_DURING_ESCORT"))
		end
	end
end)

function respawnCd()
	_spawndelay = 30
	_countdown = Config.RespawnTimer
	_waiting = true
	Citizen.CreateThread(function()
		local key = exports["prp-keybinds"]:GetKey("secondary_action")
		while
			loggedIn
			and (isDead and not LocalPlayer.state.isHospitalized)
			and _waiting
		do
			if not IsInArena then
				if _spawndelay > 0 then
					DrawUIText(4, true, 0.5, 0.9, 0.35, 255, 255, 255, 255, locale("NOTIFY_POLICE_UI_TEXT", _spawndelay))
				elseif _respawning then
					DrawUIText(4, true, 0.5, 0.9, 0.35, 255, 255, 255, 255, locale("RESPAWNING_TEXT"))
				else
					CanSendDistress = true
					if _countdown > 0 then
						DrawUIText(4, true,	0.5, 0.9, 0.35, 255, 255, 255, 255, locale("RESPAWN_AVAILABLE_AT_UI_TEXT", _countdown))
						DrawUIText(4, true,	0.5, 0.93, 0.35, 255, 255, 255, 255, locale("PRESS_KEY_TO_CALL_EMS"))

					else
						DrawUIText(4, true, 0.5, 0.9, 0.35,	255, 255, 255, 255, locale("PRESS_KEY_TO_RESPAWN", key))
						DrawUIText(4, true,	0.5, 0.93, 0.35, 255, 255, 255,	255, locale("PRESS_KEY_TO_CALL_EMS"))
					end
				end
				Citizen.Wait(1)
			else
				Citizen.Wait(500)
			end
		end
	end)

    Citizen.CreateThread(function()
        function CitizenDistress()
            if CanSendDistress and isDead and not HasSentDistress then
				TriggerServerEvent("EmergencyAlerts:Server:DoPredefined", "injuredPerson")
                exports["prp-hud-v2"]:NotificationSuccess(locale("NOTIFIED_MEDICAL_SERVICES"))

                CanSendDistress = false
                HasSentDistress = true
                Citizen.SetTimeout(60000, function()
                    if isDead then
                    	CanSendDistress = true
                    end
                    HasSentDistress = false
                end)
            end
        end

        while loggedIn and isDead do
            CanSendDistress = true
            if IsControlPressed(0, Keys['H']) or IsDisabledControlPressed(0, Keys['H']) then
                CitizenDistress()
            end
            Citizen.Wait(1000)
            _countdown = _countdown - 1
            _spawndelay = _spawndelay -1
        end
    end)
end

Citizen.CreateThread(function()
	while true do
		SetPlayerHealthRechargeMultiplier(playerId, 0.0)
		Citizen.Wait(500)
	end
end)

RegisterNetEvent('Damage:addHealth', function(amount)
    playerPed  = PlayerPedId()
    local prevHealth = GetEntityHealth(playerPed)
    local newHealth = math.max(prevHealth + amount, 0)

    if newHealth ~= prevHealth then
        SetEntityHealth(playerPed, newHealth)
    end
end)

CreateThread(function()
	SetWeaponDamageModifier(`WEAPON_RUN_OVER_BY_CAR`, 0.0)
	SetWeaponDamageModifier(`WEAPON_RAMMED_BY_CAR`, 0.0)
	SetWeaponDamageModifier(`VEHICLE_WEAPON_ROTORS`, 0.0)
end)