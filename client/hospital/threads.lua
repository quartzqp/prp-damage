_countdown = 0
_leavingBed = false

AddEventHandler('Keybinds:Client:KeyUp:primary_action', function()
    if _curBed ~= nil and isHospitalized and _countdown <= 0 and not _leavingBed then
		_leavingBed = true
		LeaveBed()
	end
end)

function StartHealThread(skipHeal, currentZone)
	Citizen.CreateThread(function()
		while loggedIn and _countdown >= 0 and isHospitalized do
			Citizen.Wait(1000)
			TriggerEvent("prp-injuries:treatCountdown", _countdown)
			_countdown = _countdown - 1
		end
		LeaveBed()
		TriggerEvent('prp-injuries:hospitalBedHeal', skipHeal, currentZone)
	end)
end

function StartRPThread()
	Citizen.CreateThread(function()
	end)
end