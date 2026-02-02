_curBed = nil
_done = false
isCheckingIn = false
_currentCheckInZone = nil

local setupEvent = nil
setupEvent = AddEventHandler("Core:Shared:Ready", function()
	Wait(200)
	Init()

	-- exports["prp-pedinteraction"]:Add("HiddenHospital", `s_m_m_doctor_01`, vector3(-83.954, 6226.642, 30.090), 348.538,
	-- 	25.0, {
	-- 		{
	-- 			icon = "heart-pulse",
	-- 			text = "Revive Escort (5 $PLEB)",
	-- 			event = "Hospital:Client:HiddenRevive",
	-- 			data = isEscorting or {},
	-- 			isEnabled = function()
	-- 				if isEscorting ~= nil and not isDead then
	-- 					local ps = Player(isEscorting).state
	-- 					return ps.isDead
	-- 				else
	-- 					return false
	-- 				end
	-- 			end,
	-- 		},
	-- 	}, 'suitcase-medical', 'CODE_HUMAN_MEDIC_KNEEL')

	
	for index, clinic in ipairs(Config.Clinics) do
		exports["prp-pedinteraction"]:Add("Clinic_" .. index, clinic.model, clinic.location.xyz, clinic.location.w, 25.0,
			{
				{
					icon = "HeartPulse",
					text = locale("CHECK_IN"),
					event = "Hospital:Client:CheckIn",
				},
				-- {
				-- 	icon = "syringe",
				-- 	text = locale("OPEN_SHOP"),

				-- 	callback = function()
				-- 		local response = lib.callback.await("prp-crime:server:openClinicShop", 250, index)

				-- 		if not response then
				-- 			return
				-- 		end

				-- 		exports["prp-new-inventory"]:OpenShop({
				-- 			id = "SHOP_CLINIC_" .. index,
				-- 			name = locale("CLINIC_SHOP")
				-- 		})
				-- 	end
				-- },
				-- {
				-- 	icon = "syringe",
				-- 	text = locale("OPEN_PHARMACY"),

				-- 	callback = function()
				-- 		exports["prp-new-inventory"]:OpenShop({
				-- 			shopItemSet = 38
				-- 		})
				-- 	end
				-- },
			}, 'suitcase-medical', 'WORLD_HUMAN_SMOKING')
	end

	for zoneIdentifier, checkInZone in pairs(Config.CheckInZones) do
		exports["prp-polyzone"]:CreateBox(zoneIdentifier, checkInZone.coords, checkInZone.length, checkInZone.width, {
			name = zoneIdentifier,
			heading = checkInZone.rotation,
			minZ = checkInZone.minZ,
			maxZ = checkInZone.maxZ
		}, {})
	end

	-- exports["prp-pedinteraction"]:Add("hospital-icu", `s_m_m_doctor_01`, vec3(-304.957123, -579.214539, 36.338291), 304.791281, 25.0, {
	-- 	{
	-- 		icon = "bell-concierge",
	-- 		text = locale("REQUEST_BELL_LABEL"),
	-- 		event = "Hospital:Client:RequestEMS",
	-- 		isEnabled = function()
	-- 			return (Character:GetData("ICU") ~= nil and not Character:GetData("ICU").Released) and
	-- 				(not _done or _done < GetCloudTimeAsInt())
	-- 		end,
	-- 	},
	-- }, "notes-medical", "WORLD_HUMAN_CLIPBOARD")

	RemoveEventHandler(setupEvent)
end)

AddEventHandler("onResourceStop", function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end

	exports["prp-pedinteraction"]:Remove("hospital-icu")
end)

AddEventHandler("Hospital:Client:RequestEMS", function()
	if not _done or _done < GetCloudTimeAsInt() then
		TriggerServerEvent("EmergencyAlerts:Server:DoPredefined", "icurequest")
		_done = GetCloudTimeAsInt() + (60 * 10)
	end
end)

local _bedId = nil
HOSPITAL = {
	CheckIn = function(self)
		exports["prp-base"]:CallbacksServer('Hospital:Treat', {
			zone = _currentCheckInZone
		}, function(bed)
			if bed ~= nil then
				_countdown = Config.HealTimer
				LocalPlayer.state:set("isHospitalized", true, true)
				exports["prp-damage"]:HospitalSendToBed(Config.Beds[bed], false, bed)
			else
				exports["prp-hud-v2"]:NotificationError(locale("NO_HOSPITAL_BEDS"))
			end
		end)
	end,
	SendToBed = function(self, bed, isRp, bedId, skipHeal)
		LocalPlayer.state:set("hospitalizedRP", isRp, true)
		local fuck = false

		if bedId then
			local p = promise.new()
			exports["prp-base"]:CallbacksServer('Hospital:OccupyBed', bedId, function(s)
				p:resolve(s)
			end)

			fuck = Citizen.Await(p)
		else
			fuck = true
		end

		_bedId = bedId

		LocalPlayer.state:set("hospitalBed", _bedId, true)

		if bed ~= nil and fuck then
			if not isRp then
				_countdown = Config.HealTimer

				if exports["prp-businesses-v2"]:TotalEmployeesInZone(_currentCheckInZone) > 0 then
					_countdown = GetConvarInt("sv_nancyHealTimerOn", 60)
				end
			else
				_countdown = 0
			end
			SetBedCam(bed)
			if isRp then
				StartRPThread()
			else
				StartHealThread(skipHeal, _currentCheckInZone)
			end

		else
			exports["prp-hud-v2"]:NotificationError(locale("INVALID_BED"))
		end
	end,
	FindBed = function(self, object, playerId)
		local coords = GetEntityCoords(object)
		local model = GetEntityModel(object)
		if playerId then
			return TriggerServerEvent("prp-damage:placeInBed", playerId, coords)
		end
		exports["prp-base"]:CallbacksServer('Hospital:FindBed', coords, function(bed)
			if bed ~= nil then
				local bedData = Config.Beds[bed]
				local bedDataCopy = {
					x = bedData.x,
					y = bedData.y,
					z = bedData.z,
					h = bedData.h,
					model = bedData.model or model
				}
				exports["prp-damage"]:HospitalSendToBed(bedDataCopy, true, bed)
			else
				exports["prp-damage"]:HospitalSendToBed({
					x = coords.x,
					y = coords.y,
					z = coords.z,
					h = GetEntityHeading(object),
					model = model,
					freeBed = true,
				}, true)
			end
		end)
	end,
	LeaveBed = function(self)
		LocalPlayer.state:set("hospitalizedRP", nil, true)
		exports["prp-base"]:CallbacksServer('Hospital:LeaveBed', _bedId, function()
			_bedId = nil
		end)

		LocalPlayer.state:set("hospitalBed", false, true)
	end,
	GetBed = function(self)
		return _bedId
	end,
}

--[[
HospitalCheckIn()
HospitalSendToBed(bed, isRp)
HospitalFindBed(object, playerId)
HospitalLeaveBed()
]]
local function exportHandler(exportName, func)
	AddEventHandler(('__cfx_export_%s_%s'):format(GetCurrentResourceName(), exportName), function(setCB)
		setCB(function(...)
			return func(HOSPITAL, ...)
		end)
	end)
end

local function createExportForObject(object, name)
	name = name or ""
	for k, v in pairs(object) do
		if type(v) == "function" then
			exportHandler(name .. k, v)
		elseif type(v) == "table" then
			createExportForObject(v, name .. k)
		end
	end
end

for k, v in pairs(HOSPITAL) do
	if type(v) == "function" then
		exportHandler("Hospital" .. k, v)
	elseif type(v) == "table" then
		createExportForObject(v, "Hospital" .. k)
	end
end

local _inCheckInZone = false

AddEventHandler('Polyzone:Enter', function(id, point, insideZone, data)
	if not Config.CheckInZones[id] then return end
	local zoneData = Config.CheckInZones[id]

	local countZone = zoneData.countZone
	_inCheckInZone = true
	_currentCheckInZone = id
	_currentCountZone = countZone

	if isEscorted then return end

	local actionString = locale("CHECK_IN_ACTION_BAR", "")

	if countZone then
		local employeesInZone = exports["prp-businesses-v2"]:TotalEmployeesInZone(countZone)

		actionString = locale("CHECK_IN_ACTION_BAR", "{key}" .. locale('CHECK_IN_CURRENCY', GetConvarInt("sv_nancyPriceOff", 25)) .. "{/key}")
		if employeesInZone > 0 then
			actionString = locale("CHECK_IN_ACTION_BAR", "{key}" .. locale('CHECK_IN_CURRENCY', GetConvarInt("sv_nancyPriceOn", 50)) .. "{/key}")
		end
	end

	exports["prp-hud-v2"]:ActionShow(actionString)
end)

AddEventHandler('Polyzone:Exit', function(id, point, insideZone, data)
	if not Config.CheckInZones[id] then return end
	_inCheckInZone = false
	exports["prp-hud-v2"]:ActionHide()
end)

AddEventHandler('Keybinds:Client:KeyUp:primary_action', function()
	if _inCheckInZone then
		if not LocalPlayer.state.doingAction and not isEscorted and not isCheckingIn then
			TriggerEvent('Hospital:Client:CheckIn')
		end
	end
end)

RegisterNetEvent("prp-damage:client:addHospitalZone", function(zoneId, zoneData)
	local newZone = {
		name = zoneId,
		coords = zoneData.coords,
		size = zoneData.size or vec3(30.0, 30.0, 5.0),
		rotation = zoneData.rotation or 0.0,
	}
	newZone.zone = lib.zones.box(newZone)
	Config.HospitalZones[#Config.HospitalZones + 1] = newZone
	Config.DynamicHospitalZones[zoneId] = #Config.HospitalZones
end)

RegisterNetEvent("prp-damage:client:removeHospitalZone", function(zoneId)
	local index = Config.DynamicHospitalZones[zoneId]
	if index then
		table.remove(Config.HospitalZones, index)
		Config.DynamicHospitalZones[zoneId] = nil
		for k, v in pairs(Config.DynamicHospitalZones) do
			if v > index then
				Config.DynamicHospitalZones[k] = v - 1
			end
		end
	end
end)

RegisterNetEvent("prp-damage:client:addCheckInZone", function(zoneId, zoneData)
	Config.CheckInZones[zoneId] = {
		coords = zoneData.coords,
		length = zoneData.length or 4.0,
		width = zoneData.width or 4.6,
		minZ = zoneData.minZ or (zoneData.coords.z - 2.0),
		maxZ = zoneData.maxZ or (zoneData.coords.z + 4.0),
		rotation = zoneData.rotation or 0.0
	}
	exports["prp-polyzone"]:CreateBox(zoneId, zoneData.coords, Config.CheckInZones[zoneId].length, Config.CheckInZones[zoneId].width, {
		name = zoneId,
		heading = Config.CheckInZones[zoneId].rotation,
		minZ = Config.CheckInZones[zoneId].minZ,
		maxZ = Config.CheckInZones[zoneId].maxZ
	}, {})
	Config.DynamicCheckInZones[zoneId] = true
end)

RegisterNetEvent("prp-damage:client:removeCheckInZone", function(zoneId)
	if Config.DynamicCheckInZones[zoneId] then
		exports["prp-polyzone"]:RemoveZone(zoneId)
		Config.CheckInZones[zoneId] = nil
		Config.DynamicCheckInZones[zoneId] = nil
	end
end)

RegisterNetEvent("prp-damage:client:addClinic", function(clinicId, clinicData)
	exports["prp-pedinteraction"]:Add("Clinic_" .. clinicId, clinicData.model or `alvar_doc`, clinicData.location.xyz, clinicData.location.w, 25.0, nil, 'suitcase-medical', 'WORLD_HUMAN_SMOKING')
	Config.DynamicClinics[clinicId] = true
end)

RegisterNetEvent("prp-damage:client:removeClinic", function(clinicId)
	if Config.DynamicClinics[clinicId] then
		exports["prp-pedinteraction"]:Remove("Clinic_" .. clinicId)
		Config.DynamicClinics[clinicId] = nil
	end
end)

RegisterNetEvent("prp-damage:client:addBeds", function(zoneId, beds)
	if not Config.DynamicBeds then
		Config.DynamicBeds = {}
	end
	for _, bed in ipairs(beds) do
		Config.Beds[#Config.Beds + 1] = bed
		if not Config.DynamicBeds[zoneId] then
			Config.DynamicBeds[zoneId] = {}
		end
		Config.DynamicBeds[zoneId][#Config.DynamicBeds[zoneId] + 1] = #Config.Beds
	end
end)

RegisterNetEvent("prp-damage:client:removeBeds", function(zoneId)
	if Config.DynamicBeds and Config.DynamicBeds[zoneId] then
		local bedsToRemove = {}
		for _, bedIndex in ipairs(Config.DynamicBeds[zoneId]) do
			table.insert(bedsToRemove, bedIndex)
		end
		table.sort(bedsToRemove, function(a, b) return a > b end)
		for _, bedIndex in ipairs(bedsToRemove) do
			table.remove(Config.Beds, bedIndex)
		end
		Config.DynamicBeds[zoneId] = nil
		if Config.DynamicBeds then
			for k, v in pairs(Config.DynamicBeds) do
				if k ~= zoneId then
					for i, bedIndex in ipairs(v) do
						local adjustment = 0
						for _, removedIndex in ipairs(bedsToRemove) do
							if bedIndex > removedIndex then
								adjustment = adjustment + 1
							end
						end
						v[i] = bedIndex - adjustment
					end
				end
			end
		end
	end
end)