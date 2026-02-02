_currentCountZone = nil

local setupEvent = nil
setupEvent = AddEventHandler("Core:Shared:Ready", function()
	Wait(300)

	exports["prp-base"]:CallbacksRegisterClient("Damage:ApplyPainkiller", function(data, cb)
		LocalPlayer.state.onPainKillers = data
		LocalPlayer.state.wasOnPainKillers = true
	end)

	exports["prp-base"]:CallbacksRegisterClient("Damage:ApplyAdrenaline", function(data, cb)
		LocalPlayer.state.onDrugs = data
		LocalPlayer.state.wasOnDrugs = true
	end)
    RemoveEventHandler(setupEvent)
end)

RegisterNetEvent("Characters:Client:Logout", function()
	exports["prp-hud-v2"]:Dead(false)
end)