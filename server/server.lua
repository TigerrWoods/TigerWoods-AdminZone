RegisterNetEvent('adminzone:bringPlayer', function(target)
    if not target or not GetPlayerPed(target) then return end
    TriggerClientEvent('adminzone:teleportToZone', target)
end)

Citizen.CreateThread(function()
	if (GetCurrentResourceName() ~= "TigerWoods-AdminZone") then 
		StopResource(GetCurrentResourceName());
		print("[" .. GetCurrentResourceName() .. "] " .. "IMPORTANT: This resource must be named TigerWoods-AdminZone for it to work properly...");
	end
	print("[TigerWoods-AdminZone] THANK YOU FOR USING THIS SCRIPT LOVE FROM TIGERWOODS");
	print("[TigerWoods-AdminZone] THANK YOU FOR USING THIS SCRIPT LOVE FROM TIGERWOODS");
end)

