playerId = PlayerId()
plaSrvId = GetPlayerServerId(playerId)

playerPed = PlayerPedId()
lib.onCache("ped", function(value) playerPed = value end)

IsInArena = false
AddStateBagChangeHandler("isInArena", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    IsInArena = value
end)

loggedIn = false
AddStateBagChangeHandler("loggedIn", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    loggedIn = value
end)

isDead = false
AddStateBagChangeHandler("isDead", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    isDead = value
end)

Character = LocalPlayer.state.Character
AddStateBagChangeHandler("Character", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    Character = value
end)

onPainKillers = 0
AddStateBagChangeHandler("onPainKillers", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    onPainKillers = value
end)

wasOnPainKillers = false
AddStateBagChangeHandler("wasOnPainKillers", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    wasOnPainKillers = value
end)

onDrugs = 0
AddStateBagChangeHandler("onDrugs", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    onDrugs = value
end)

wasOnDrugs = false
AddStateBagChangeHandler("wasOnDrugs", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    wasOnDrugs = value
end)

inCreator = nil
AddStateBagChangeHandler("inCreator", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    inCreator = value
end)

isHospitalized = nil
AddStateBagChangeHandler("isHospitalized", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    isHospitalized = value
end)

tourniquet = nil
AddStateBagChangeHandler("tourniquet", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    tourniquet = value
end)

isEscorting = nil
AddStateBagChangeHandler("isEscorting", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    isEscorting = value
end)

isEscorted = nil
AddStateBagChangeHandler("isEscorted", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    isEscorted = value
end)

myEscorter = nil
AddStateBagChangeHandler("myEscorter", ("player:%s"):format(plaSrvId), function(bagName, key, value, reserved, replicated)
    myEscorter = value
end)