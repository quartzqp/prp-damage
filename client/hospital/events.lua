local hospitalCheckin = {
	{
		icon = "clipboard-check",
		text = locale("GO_ON_DUTY"),
		event = "EMS:Client:OnDuty",
		jobPerms = {
			{
				job = 'ems',
				reqOffDuty = true,
			}
		},
	},
	{
		icon = "clipboard",
		text = locale("GO_OFF_DUTY"),
		event = "EMS:Client:OffDuty",
		jobPerms = {
			{
				job = 'ems',
				reqDuty = true,
			}
		},
	},
	{
		icon = "clipboard",
		text = locale("CHECK_ICU_PATIENTS"),
		event = "prp-hospital:client:checkIcuPatients",
		jobPerms = {
			{
				job = 'ems',
			}
		},
	},
	{
		icon = "clipboard",
		text = locale("ADMIT_TO_ICU"),
		event = "prp-hospital:client:sendToIcu",
		jobPerms = {
			{
				job = 'ems',
			}
		},
	},
	{
		icon = "hands-holding",
		text = locale("RETRIEVE_ITEMS"),
		event = "Hospital:Client:RetreiveItems",
		isEnabled = function()
			return Character:GetData("ICU") == nil or not Character:GetData("ICU").Items
		end,
	},
	{
		icon = "paw",
		text = locale("CHECK_IN_PET_LABEL"),
		event = "Hospital:Client:CheckInPet"
	},
}

function Init()
	-- exports["prp-pedinteraction"]:Add("hospital-check-in", `u_f_m_miranda_02`, vec3(-325.875275, -587.221069, 31.775402), 228.710281, 25.0, hospitalCheckin, "notes-medical", "WORLD_HUMAN_CLIPBOARD")
	-- To be enabled later
	--exports["prp-pedinteraction"]:Add("hospital-check-in", `u_f_m_miranda_02`, vector3(1673.467, 3667.818, 34.35), 211.623, 25.0, hospitalCheckin, "notes-medical", "WORLD_HUMAN_CLIPBOARD")


	for k, v in ipairs(Config.BedModels) do
		exports["ox_target"]:AddObject(v, "stretcher", {
			{
				icon = "stretcher",
				text = locale("LAY_IN_BED"),
				event = "Hospital:Client:FindBed",
				minDist = 2.0,
				isEnabled = function()
					return isEscorting == nil and myEscorter == nil and not isHospitalized
				end,
			},
			{
				icon = "stretcher",
				text = locale("LAY_PLAYER_IN_BED"),
				event = "Hospital:Client:FindBedForPlayer",
				minDist = 2.0,
				isEnabled = function()
					return isEscorting ~= nil and not Player(isEscorting).state.isHospitalized
				end,
			},
			{
				icon = "scalpel",
				text = locale("TRAIN_SURGERY"),
				event = "Hospital:TrainSurgery",
				minDist = 2.0,
				jobs = {
					{
						job = 'ems',
						reqDuty = true,
					},
				},
			},
		}, 3.0)
	end
end

AddEventHandler("onResourceStop", function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end

	exports["prp-pedinteraction"]:Remove("hospital-check-in")
end)

AddEventHandler("Hospital:TrainSurgery", function(data)
	local coords = GetEntityCoords(data.entity)
	for bedId, bedCoords in ipairs(Config.Beds) do
		if (#(vector3(bedCoords.x, bedCoords.y, bedCoords.z) - coords) <= 2.0) then
			TriggerEvent("prp-injuries:trainSurgery", bedCoords)
		end
	end
end)

AddEventHandler("Hospital:Client:RetreiveItems", function()
	exports["prp-base"]:CallbacksServer("Hospital:RetreiveItems")
end)

AddEventHandler("Hospital:Client:CheckInPet", function()
	local result = lib.callback.await("prp-pets:server:getPetsForCheckIn", 100)
    if not result then
        exports["prp-hud-v2"]:NotificationError(locale("ERROR_PETS_CHECKIN"))
        return
    end

    local canCheckinPets = result.canCheckin or {}
    local petsInHospital = result.inHospital or {}

    if #canCheckinPets == 0 and #petsInHospital == 0 then
        exports["prp-hud-v2"]:NotificationError(locale("NO_PETS_TO_CHECK_IN"))
        return
    end

    local petCheckinMenu = {
        main = {
            label = locale("PET_MENU_LABEL"),
            items = {}
        }
    }

    if #canCheckinPets > 0 then
        petCheckinMenu.main.items[#petCheckinMenu.main.items+1] = {
            label = locale("CAN_CHECK_IN_PETS"),
            description = locale("CAN_CHECK_IN_PETS_DESC"),
            submenu = "canCheckin"
        }

        local checkInItems = {}
        for i = 1, #canCheckinPets do
            local pet = canCheckinPets[i]

            checkInItems[#checkInItems + 1] = {
                label = locale("CHECK_IN_PET_TITLE", pet.name, pet.cost),
                description = locale("CHECK_IN_PET_DESC", pet.duration),
                type = "server",
                event = "prp-pets:server:checkInPet",
                data = {
                    id = pet.id,
                    itemSlot = pet.itemSlot
                }
            }
        end

        petCheckinMenu["canCheckin"] = {
            label = locale("CAN_CHECK_IN_PETS"),
            items = checkInItems
        }
    end

    if #petsInHospital > 0 then
        petCheckinMenu.main.items[#petCheckinMenu.main.items+1] = {
            label = locale("PETS_IN_HOSPITAL"),
            description = locale("PETS_IN_HOSPITAL_DESC"),
            submenu = "inHospital"
        }

        local inHospitalItems = {}
        for i = 1, #petsInHospital do
            local pet = petsInHospital[i]

            inHospitalItems[#inHospitalItems + 1] = {
                label = pet.name,
                description = pet.timeLeftLabel,
                disabled = not pet.canPickup,
                type = "server",
                event = pet.canPickup and "prp-pets:server:checkOutPet",
                data = pet.id
            }
        end

        petCheckinMenu["inHospital"] = {
            label = locale("PETS_IN_HOSPITAL"),
            items = inHospitalItems
        }
    end

    exports["prp-hud-v2"]:ListMenuShow(petCheckinMenu)
end)

AddEventHandler("Hospital:Client:HiddenRevive", function(entity, data)
	exports["prp-hud-v2"]:Progress({
		name = "ammo_action",
		duration = (math.random(5) + 15) * 1000,
		label = locale("REVIVING_PROGRESS_LABEL"),
		useWhileDead = false,
		canCancel = true,
		ignoreModifier = true,
		controlDisables = {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			task = "CODE_HUMAN_MEDIC_KNEEL",
		},
	}, function(status)
		if not status then
			exports["prp-base"]:CallbacksServer("Hospital:HiddenRevive", {}, function(s)
				if s then
					exports["prp-escort"]:StopEscort()
				end
			end)
		end
	end)
end)

AddEventHandler("Characters:Client:Spawn", function()
	LocalPlayer.state:set("isHospitalized", false, true)
	
	lib.callback("prp-damage:server:getSafezoneHospitalZones", false, function(zones)
		if zones then
			for zoneId, data in pairs(zones) do
				TriggerEvent("prp-damage:client:addHospitalZone", zoneId, data.hospitalZone)
				TriggerEvent("prp-damage:client:addCheckInZone", data.checkInZone.zoneId, data.checkInZone)
				TriggerEvent("prp-damage:client:addClinic", zoneId, data.clinic)
				if data.beds then
					TriggerEvent("prp-damage:client:addBeds", zoneId, data.beds)
				end
			end
		end
	end)
end)

RegisterNetEvent("Characters:Client:Logout", function()
	LocalPlayer.state:set("isHospitalized", false, true)
end)

AddEventHandler("Hospital:Client:CheckIn", function()
	if isCheckingIn then return end

	if LocalPlayer.state.isDragging then return end
	if LocalPlayer.state.isInTrolley or LocalPlayer.state.isPushingTrolley then return end

	isCheckingIn = true

	exports["prp-hud-v2"]:ProgressWithStartEvent({
		name = "hospital_action",
		duration = 3500,
		label = locale("CHECKING_IN_PROGRESS_LABEL"),
		useWhileDead = true,
		canCancel = true,
		ignoreModifier = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			anim = "clipboard_still",
		},
		disarm = true,
	}, function()
		isCheckingIn = false

		-- LocalPlayer.state:set("isHospitalized", true, true)
	end, function(status)
		if not status then
			exports["prp-damage"]:HospitalCheckIn()
		else
			LocalPlayer.state:set("isHospitalized", false, true)
		end

		isCheckingIn = false
	end)
end)

RegisterNetEvent("Hospital:Client:GetOut", function()
	exports["prp-base"]:CallbacksServer('Hospital:LeaveBed', {}, function()
		_doing = false
		LeaveBed()
	end)
end)

AddEventHandler("Hospital:Client:FindBed", function(event, data)
	if not event then
		return
	end
	exports["prp-damage"]:HospitalFindBed(event.entity)
end)

AddEventHandler("Hospital:Client:FindBedForPlayer", function(event, data)
	if not event then
		return
	end
	exports["prp-escort"]:StopEscort()
	exports["prp-damage"]:HospitalFindBed(event.entity, isEscorting)
end)

RegisterNetEvent("prp-damage:goToBed", function(escorter, coords)
	if escorter ~= myEscorter then return end
	exports["prp-base"]:CallbacksServer('Hospital:FindBed', coords, function(bed)
		if bed ~= nil then
			exports["prp-damage"]:HospitalSendToBed(Config.Beds[bed], true, bed)
		else
			exports["prp-damage"]:HospitalSendToBed({
				x = coords.x,
				y = coords.y,
				z = coords.z,
				h = GetEntityHeading(object),
				freeBed = true,
			}, true)
		end
	end)
end)

RegisterNetEvent("prp-hospital:client:sendToIcu", function()
	local input = lib.inputDialog(locale("SEND_PLAYER_TO_ICU"), {
        {type = 'input', label = locale("STATE_ID"), icon = 'syringe', description = locale("ENTER_A_SID"), required = true},
    })

    if not input then return end

    local stateId = input[1]

	TriggerServerEvent("prp-hospital:server:admitToICU", stateId)
end)

RegisterNetEvent("prp-hospital:client:checkIcuPatients", function()
	local patients = lib.callback.await("prp-hospital:server:getIcuPatients", 100)

	if not patients or #patients == 0 then
		exports["prp-hud-v2"]:NotificationError(locale("NO_PATIENTS_IN_ICU"))
		return
	end

	local patientsMenu = {
        main = {
            label = locale("ICU_PATIENTS"),
            items = {},
        }
    }

	local function patientSubmenu(patientData)
		patientsMenu[tostring(patientData.stateId)] = {
            label = patientData.name,
            items = {
				{
					label = locale("RELEASE"),
					description = locale("RELEASE_PATIENT_FROM_ICU"),
					event = "prp-hospital:server:releaseFromIcu",
					type = "server",
					data = { stateId = patientData.stateId },
				},
			},
        }
	end

	for k, v in ipairs(patients) do
		patientSubmenu(v)
		table.insert(patientsMenu.main.items, {
			label = v.name,
			description = string.format("%s: %s", locale("STATE_ID"), v.stateId),
			submenu = tostring(v.stateId),
		})
	end

	exports["prp-hud-v2"]:ListMenuShow(patientsMenu)
end)

RegisterNetEvent("Hospital:Client:ICU:Enter", function()
	if not IsScreenFadedOut() then
		DoScreenFadeOut(1000)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end
	end

	local room = Config.ICUBeds[math.random(#Config.ICUBeds)]

	SetEntityCoords(playerPed, room[1], room[2], room[3], false, false, false, false)
	Citizen.Wait(100)
	SetEntityHeading(playerPed, room[4])
	_disabled = false

	Citizen.Wait(1000)

	DoScreenFadeIn(1000)
	while not IsScreenFadedIn() do
		Citizen.Wait(10)
	end
end)