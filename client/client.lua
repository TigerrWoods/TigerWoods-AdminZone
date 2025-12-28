local inAdminZone = false
local weaponBlocked = false
local vehicleBlocked = false
local npc

-- =========================
-- DELETE VEHICLE FUNCTION
-- =========================
local function deleteVehicle(ped)
    if not IsPedInAnyVehicle(ped, false) then return end

    local vehicle = GetVehiclePedIsIn(ped, false)

    TaskLeaveVehicle(ped, vehicle, 16)
    Wait(500)

    NetworkRequestControlOfEntity(vehicle)
    local timeout = 0
    while not NetworkHasControlOfEntity(vehicle) and timeout < 50 do
        Wait(0)
        timeout = timeout + 1
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteEntity(vehicle)
end

-- =========================
-- BLIP + ZONE CIRCLE
-- =========================
CreateThread(function()
    local blip = AddBlipForCoord(Config.AdminZone.coords)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Blip.name)
    EndTextCommandSetBlipName(blip)

    local radiusBlip = AddBlipForRadius(Config.AdminZone.coords, Config.AdminZone.radius)
    SetBlipColour(radiusBlip, Config.Blip.color)
    SetBlipAlpha(radiusBlip, 100)
end)

-- =========================
-- ZONE DETECTION
-- =========================
CreateThread(function()
    while true do
        local ped = cache.ped
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.AdminZone.coords)

        -- ENTER ADMIN ZONE
        if dist <= Config.AdminZone.radius and not inAdminZone then
            inAdminZone = true

            deleteVehicle(ped)

            RemoveAllPedWeapons(ped, true)
            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
            SetEntityInvincible(ped, true)

            lib.notify({
                title = 'Admin Zone',
                description = 'You entered the Admin Zone. Weapons, combat, and vehicles are disabled.',
                type = 'warning'
            })
        end

        -- EXIT ADMIN ZONE
        if dist > Config.AdminZone.radius and inAdminZone then
            inAdminZone = false
            weaponBlocked = false
            vehicleBlocked = false

            SetEntityInvincible(ped, false)

            lib.notify({
                title = 'Admin Zone',
                description = 'You have left the Admin Zone.',
                type = 'success'
            })
        end

        Wait(500)
    end
end)

-- =========================
-- COMBAT & WEAPON BLOCK
-- =========================
CreateThread(function()
    while true do
        if inAdminZone then
            DisablePlayerFiring(cache.playerId, true)
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 37, true) -- Weapon wheel

            if GetSelectedPedWeapon(cache.ped) ~= `WEAPON_UNARMED` then
                RemoveAllPedWeapons(cache.ped, true)
                SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)

                if not weaponBlocked then
                    weaponBlocked = true
                    lib.notify({
                        title = 'Admin Zone',
                        description = 'Weapons are not allowed in the Admin Zone.',
                        type = 'error'
                    })
                end
            else
                weaponBlocked = false
            end

            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- =========================
-- VEHICLE BLOCK (EXTRA SAFETY)
-- =========================
CreateThread(function()
    while true do
        if inAdminZone then
            DisableControlAction(0, 23, true) -- Enter vehicle
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 58, true)

            local ped = cache.ped

            if IsPedInAnyVehicle(ped, false) then
                TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 16)

                if not vehicleBlocked then
                    vehicleBlocked = true
                    lib.notify({
                        title = 'Admin Zone',
                        description = 'Vehicles are not allowed in the Admin Zone.',
                        type = 'error'
                    })
                end
            else
                vehicleBlocked = false
            end

            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- =========================
-- NPC RETURN TO RP
-- =========================
CreateThread(function()
    lib.requestModel(Config.NPC.model)

    npc = CreatePed(
        0,
        Config.NPC.model,
        Config.NPC.coords.x,
        Config.NPC.coords.y,
        Config.NPC.coords.z - 1.0,
        Config.NPC.heading,
        false,
        false
    )

    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStartScenarioInPlace(npc, Config.NPC.scenario, 0, true)

    exports.ox_target:addLocalEntity(npc, {
        {
            label = 'Return to RP', --  Here you can change the name for  [Return to RP]
            icon = 'fa-solid fa-door-open',
            onSelect = function()
                DoScreenFadeOut(500)
                Wait(600)

                SetEntityCoords(cache.ped, Config.ReturnLocation.coords)
                SetEntityHeading(cache.ped, Config.ReturnLocation.heading)

                DoScreenFadeIn(500)
            end
        }
    })
end)
