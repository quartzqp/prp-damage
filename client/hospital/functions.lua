local cam = nil

local inBedDict = "anim@gangops@morgue@table@"
local inBedAnim = "ko_front"
local getOutDict = 'switch@franklin@bed'
local getOutAnim = 'sleep_getup_rubeyes'

function SetBedCam(bed)
	_curBed = bed

	if not IsScreenFadedOut() then
		DoScreenFadeOut(1000)
		while not IsScreenFadedOut() do
			Citizen.Wait(1)
		end
	end

	if IsPedDeadOrDying(playerPed, false) then
		local playerPos = GetEntityCoords(playerPed)
		NetworkResurrectLocalPlayer(playerPos.x, playerPos.y, playerPos.z, 0.0, true, false)
    end

    SetEntityCoords(playerPed, _curBed.x, _curBed.y, _curBed.z, false, false, false, false)
	SetEntityHeading(playerPed, _curBed.h)

    RequestAnimDict(inBedDict)
    while not HasAnimDictLoaded(inBedDict) do
        Citizen.Wait(0)
    end

	local rotationOffset = 180.0
	if _curBed.model and Config.BedOffsets and Config.BedOffsets[_curBed.model] then
		rotationOffset = Config.BedOffsets[_curBed.model].rotationOffset or 180.0
	end

    SetEntityHeading(playerPed, _curBed.h + rotationOffset)

    TaskPlayAnim(playerPed, inBedDict , inBedAnim, 8.0, 1.0, -1, 1, 0, 0, 0, 0 )
    Citizen.CreateThread(function()
        Citizen.Wait(500)
        while isHospitalized and not _leavingBed do
            if not IsEntityPlayingAnim(playerPed, inBedDict, inBedAnim, 3) then
                TaskPlayAnimAdvanced(playerPed, inBedDict, inBedAnim, _curBed.x, _curBed.y, _curBed.z, 0.0, 0.0, _curBed.h + rotationOffset, 8.0, 1.0, -1, 0, 0, 0, 0)
            end
            SetEntityInvincible(playerPed, true)
            Citizen.Wait(0)
        end
        SetEntityInvincible(playerPed, false) -- Please
        ClearPedTasksImmediately(playerPed)
    end)

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(cam, true)
    AttachCamToPedBone(cam, playerPed, 0, 0, 0, 1.0 , true)
    SetCamFov(cam, 90.0)
	local camRotationOffset = 180.0
	if _curBed.model and Config.BedOffsets and Config.BedOffsets[_curBed.model] then
		camRotationOffset = Config.BedOffsets[_curBed.model].rotationOffset or 180.0
	end
    SetCamRot(cam, -90.0, 0.0, GetEntityHeading(playerPed) + camRotationOffset, true)

    LocalPlayer.state:set("isHospitalized", true, true)
    DoScreenFadeIn(1000)
    while not IsScreenFadedIn() do
        Citizen.Wait(1)
    end
    _leavingBed = false
end

function LeaveBed()
    if not isDead then
        RequestAnimDict(getOutDict)
        while not HasAnimDictLoaded(getOutDict) do
            Citizen.Wait(0)
        end

        SetEntityInvincible(playerPed, false)
        SetEntityHeading(playerPed, _curBed.h - 90)
        TaskPlayAnim(playerPed, getOutDict , getOutAnim, 100.0, 1.0, -1, 8, -1, false, false, false)
        ClearPedTasksImmediately(playerPed)
    end

    exports["prp-base"]:CallbacksServer('Hospital:LeaveBed')
	if _curBed ~= nil and not _curBed.freeBed then
		exports["prp-damage"]:HospitalLeaveBed()
	end

    FreezeEntityPosition(playerPed, false)
    RenderScriptCams(false, true, 200, true, true)
    DestroyCam(cam, false)
    _curBed = nil
    _leavingBed = false
    LocalPlayer.state:set("isHospitalized", false, true)
end