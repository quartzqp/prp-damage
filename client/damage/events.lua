AddEventHandler("Characters:Client:Spawn", function()
	playerHealth = GetEntityHealth(playerPed)
	playerArmor = GetPedArmour(playerPed)
end)