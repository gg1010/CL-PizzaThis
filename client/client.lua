local QBCore = exports['qb-core']:GetCoreObject()

local PlayerJob = {}

local drinked = 0

local dough = 0

local ClipBoardSpawned = false


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	QBCore.Functions.GetPlayerData(function(PlayerData)
		PlayerJob = PlayerData.job
	end)
	if not ClipBoardSpawned then
		SpawnClipBoard()
	end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == 'Gustav-PizzaThis' then
		PlayerJob = QBCore.Functions.GetPlayerData().job
		QBCore.Functions.GetPlayerData(function(PlayerData)
			PlayerJob = PlayerData.job
			if PlayerData.job.onduty then
				if PlayerData.job.name == Config.Arbejde then
					TriggerServerEvent("QBCore:ToggleDuty")
				end
			end
		end)
    else
		print('Stop med at ændre navnet hvis det her bliver fjernet SÅ ER DET UUUUDDDD!!!')
		StopResource()
	end
end)




CreateThread(function()
    while true do
        local plyPed = PlayerPedId()
        local plyCoords = GetEntityCoords(plyPed)
        local letSleep = true        

        if PlayerJob.name == Config.Arbejde then
            if (GetDistanceBetweenCoords(plyCoords.x, plyCoords.y, plyCoords.z, Config.Sted["Garage"]["Marker"].x, Config.Sted["Garage"]["Marker"].y, Config.Sted["Garage"]["Marker"].z, true) < Config.MarkerLengde) then
                letSleep = false
                DrawMarker(36, Config.Sted["Garage"]["Marker"].x, Config.Sted["Garage"]["Marker"].y, Config.Sted["Garage"]["Marker"].z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.5, 0.5, 162, 33, 36, 255, true, false, false, true, false, false, false)
                 if (GetDistanceBetweenCoords(plyCoords.x, plyCoords.y, plyCoords.z, Config.Sted["Garage"]["Marker"].x, Config.Sted["Garage"]["Marker"].y, Config.Sted["Garage"]["Marker"].z, true) < 1.5) then
                    DrawText3D(Config.Sted["Garage"]["Marker"].x, Config.Sted["Garage"]["Marker"].y, Config.Sted["Garage"]["Marker"].z, "~g~E~w~ - Pizzeria Garage") 
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent("Gustav-Pizzeria:Garage:Menu")
                    end
                end  
            end
        end

        if letSleep then
            Wait(2000)
        end

        Wait(1)
    end
end)


RegisterNetEvent('Gustav-Pizzeria:StoreVehicle', function()
    local ped = PlayerPedId()
    local car = GetVehiclePedIsIn(PlayerPedId(), true)
    if IsPedInAnyVehicle(ped, false) then
        TaskLeaveVehicle(ped, car, 1)
        Citizen.Wait(2000)
        QBCore.Functions.Notify(Config.Locals["Notifications"]["VehicleStored"], 'success')
        DeleteVehicle(car)
        DeleteEntity(car)
    else
        QBCore.Functions.Notify(Config.Locals["Notifications"]["NotInAnyVehicle"], "error")
    end
end)

RegisterNetEvent("Gustav-Pizzeria:SpawnVehicle", function(vehicle)
    local coords = vector4(809.81219, -732.6318, 27.597684, 133.52844)
    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        SetVehicleNumberPlateText(veh, "PIZZA"..tostring(math.random(1000, 9999)))
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end)

RegisterNetEvent('Gustav-Pizzeria:OpenShop', function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
		if result then
			TriggerServerEvent("inventory:server:OpenInventory", "shop", "Main Shop", Config.ButiksTing)
		else
			QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
		end
	end)
end)

RegisterNetEvent('Gustav-Pizzeria:OpenAddonsShop', function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
		if result then
			TriggerServerEvent("inventory:server:OpenInventory", "shop", "Pizza Extras", Config.PizzaEkstraTing)
		else
			QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
		end
	end)
end)

RegisterNetEvent('Gustav-Pizzeria:WashHands', function(data)
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
		if result then
			SetEntityHeading(PlayerPedId(), data.heading)
			QBCore.Functions.Progressbar("wash_hands", Config.Locals["Progressbars"]["WashHands"]["Text"], Config.Locals["Progressbars"]["WashHands"]["Time"], false, true, {
				disableMovement = true,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = true,
			}, {
                animDict = 'mp_arresting',
                anim = 'a_uncuff',
				flags = 49,
			}, {}, {}, function()
				TriggerServerEvent('hud:server:RelieveStress', Config.HaandvaskStress)
			end, function()
				QBCore.Functions.Notify("Canceled...", "error")
			end)
		else
			QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
		end
	end)
end)

RegisterNetEvent('Gustav-Pizzeria:OpenBossStash', function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
		if result then
			TriggerServerEvent("inventory:server:OpenInventory", "stash", "Pizza This Boss Storage") 
			TriggerEvent("inventory:client:SetCurrentStash", "Pizza This Boss Storage")
		else
			QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
		end
	end)
end)

RegisterNetEvent('Gustav-Pizzeria:OpenFoodFridge', function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
		if result then
			TriggerServerEvent("inventory:server:OpenInventory", "shop", "Food Fridge", Config.MadKoeleskabsTing)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
	end)
end)

RegisterNetEvent("Gustav-Pizzeria:OpenPersonalStash", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
		if result then
			TriggerServerEvent("inventory:server:OpenInventory", "stash", "pizzathisstash_"..QBCore.Functions.GetPlayerData().citizenid)
			TriggerEvent("inventory:client:SetCurrentStash", "pizzathisstash_"..QBCore.Functions.GetPlayerData().citizenid)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
	end)
end)

RegisterNetEvent("Gustav-Pizzeria:MakeDrink", function(data)
    QBCore.Functions.TriggerCallback('Gustav-Pizzeria:HasItem', function(result)
        if result then
            QBCore.Functions.Progressbar("make_"..data.drink, "Pouring " ..data.drinkname, 5000, false, true, {
				disableMovement = true,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = true,
			}, {
				animDict = 'anim@amb@clubhouse@bar@drink@one',
				anim = 'one_bartender',
				flags = 49,
			}, {}, {}, function()
                QBCore.Functions.Notify(data.drinkname .. " Successfully Made", "success")
                TriggerServerEvent("Gustav-Pizzeria:RemoveItem", data.glass, 1)
                TriggerServerEvent("Gustav-Pizzeria:AddItem", data.drink, 1)
				TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.drink], "add")
			end, function()
				QBCore.Functions.Notify("Canceled...", "error")
			end)
        else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["NoIngredients"], "error")
        end
    end, data.glass)
end)

RegisterNetEvent("Gustav-Pizzeria:Drink", function(item, ischampagne, itemname, anim, animdict, model, bones, coords, thirst)
	if ischampagne then
		QBCore.Functions.Progressbar("drinking_"..item, "Drinking " ..itemname, 3700, false, true, {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		}, {
			animDict = "anim@amb@casino@mini@drinking@champagne_drinking@heels@base",
			anim = "outro",
			flags = 49,
		}, {}, {}, function()
			QBCore.Functions.Notify("You Have Drank " ..itemname, "success")
			TriggerServerEvent("Gustav-Pizzeria:AddThirst", QBCore.Functions.GetPlayerData().metadata["thirst"] + Config.Toerst["Champagne"])
			TriggerServerEvent("Gustav-Pizzeria:RemoveItem", item, 1)
			AlcoholEffect()
		end, function()
			QBCore.Functions.Notify("Canceled...", "error")
		end)
	else
		QBCore.Functions.Progressbar("drinking_"..item, "Drinking " ..itemname, Config.Locals["Progressbars"]["Drink"]["Time"], false, true, {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		}, {
			animDict = anim,
			anim = animdict,
			flags = 49,
		}, {
			model = model,
			bone = bones,
			coords = { x=coords.x, y=coords.y, z=coords.z },
		}, {}, function()
			QBCore.Functions.Notify("You Have Drank " ..itemname, "success")
			TriggerServerEvent("Gustav-Pizzeria:AddThirst", QBCore.Functions.GetPlayerData().metadata["thirst"] + thirst)
			TriggerServerEvent("Gustav-Pizzeria:RemoveItem", item, 1)
			drinked = drinked + 1
			if drinked >= 3 then
				QBCore.Functions.Notify(Config.Locals["Notifications"]["DrinkedEnough"])
				drinked = 0
				AlcoholEffect()
			end
		end, function()
			QBCore.Functions.Notify("Canceled...", "error")
		end)
	end
end)

RegisterNetEvent("Gustav-Pizzeria:Grab", function(data)
    QBCore.Functions.Progressbar("grab_"..data.gdrink, "Grabing " ..data.gdrinkname, data.time, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
		animDict = data.animationdict,
		anim = data.animation,
        flags = 49,
    }, {}, {}, function()
        QBCore.Functions.Notify("You grabbed " ..data.gdrinkname, "success")
        TriggerServerEvent("Gustav-Pizzeria:AddItem", data.gdrink, 1)
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.gdrink], "add")
		if data.dough then
			dough = dough - 1
		end
    end, function()
        QBCore.Functions.Notify("Canceled...", "error")
    end)
end)

RegisterNetEvent("Gustav-Pizzeria:Make", function(data)
	if not data.qbcoreevent then
		QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckFor'..data.eventname..'Items', function(HasItems)
			if HasItems then
				QBCore.Functions.Progressbar("make", "Making "..data.itemname, data.time, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = true,
				}, {
					animDict = data.animdict,
					anim = data.anim,
					flags = 49,
				}, {}, {}, function()
					if data.item4 then
						TriggerServerEvent("Gustav-Pizzeria:RemoveItem", data.item4, 1)
						TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.item4], "remove")
					end
					if data.item5 then
						TriggerServerEvent("Gustav-Pizzeria:RemoveItem", data.item5, 1)
						TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.item5], "remove")
					end
					if data.item6 then
						TriggerServerEvent("Gustav-Pizzeria:RemoveItem", data.item6, 1)
						TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.item6], "remove")
					end
					TriggerServerEvent("Gustav-Pizzeria:RemoveItem", data.item2, 1)
					TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.item2], "remove")
					TriggerServerEvent("Gustav-Pizzeria:RemoveItem", data.item3, 1)
					TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.item3], "remove")
					TriggerServerEvent("Gustav-Pizzeria:AddItem", data.recieveitem, data.number)
					TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.recieveitem], "add")
				end, function()
					QBCore.Functions.Notify("Canceled...", "error")
				end)
			else
				QBCore.Functions.Notify('You Are Trying To Make '.. data.itemname ..' With Nothing ?', 'error')
			end
		end)
	else
		QBCore.Functions.TriggerCallback('Gustav-Pizzeria:HasItem', function(HasItems)
			if HasItems then
				QBCore.Functions.Progressbar("make", "Making "..data.itemname, data.time, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = true,
				}, {
					animDict = data.animdict,
					anim = data.anim,
					flags = 49,
				}, {}, {}, function()
					if data.item4 then
						TriggerServerEvent("Gustav-Pizzeria:RemoveItem", data.item4, 1)
						TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.item4], "remove")
					elseif data.item5 then
						TriggerServerEvent("Gustav-Pizzeria:RemoveItem", data.item5, 1)
						TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.item5], "remove")
					elseif data.item6 then
						TriggerServerEvent("Gustav-Pizzeria:RemoveItem", data.item6, 1)
						TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.item6], "remove")
					end
					TriggerServerEvent("Gustav-Pizzeria:RemoveItem", data.item2, 1)
					TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.item2], "remove")
					TriggerServerEvent("Gustav-Pizzeria:AddItem", data.recieveitem, data.number)
					TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[data.recieveitem], "add")
				end, function()
					QBCore.Functions.Notify("Canceled...", "error")
				end)
			else
				QBCore.Functions.Notify('You Are Trying To Make '.. data.itemname ..' With Nothing ?', 'error')
			end
		end, data.qbcoreitem)
	end
end)

RegisterNetEvent('Gustav-Pizzeria:OpenMenu', function()
  	SendNUIMessage({action = 'OpenMenu'})
	Citizen.CreateThread(function()
        while true do
			ShowHelpNotification("Press ~INPUT_FRONTEND_RRIGHT~ To Exit")
			if IsControlJustReleased(0, 177) then
				SendNUIMessage({action = 'CloseMenu'})
				PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
				break
			end
			Citizen.Wait(1)
		end
	end)
end)

RegisterNetEvent("Gustav-Pizzeria:AddDough", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:HasItem', function(result)
		if result then
			if dough >= 12 then
				QBCore.Functions.Notify(Config.Locals["Notifications"]["StorageFull"], "error")
			else
				dough = dough + 1
				TriggerServerEvent("Gustav-Pizzeria:RemoveItem", "pdough", 1)
				TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items["pdough"], "remove")
				QBCore.Functions.Notify(Config.Locals["Notifications"]["DoughAdded"], "success")
			end
		else
			QBCore.Functions.Notify(Config.Locals["Notifications"]["DontHaveDough"], "error")
		end
	end, 'pdough')
end)

RegisterNetEvent("Gustav-Pizzeria:Eat", function(fruit, item, itemname, time, hunger, anim, animdict, model, bones, coords)
	if not fruit then
		QBCore.Functions.Progressbar("eat_"..item, "Eating " ..itemname, time, false, true, {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		}, {
			animDict = anim,
			anim = animdict,
			flags = 49,
		}, {
			model = model,
			bone = bones,
			coords = { x=coords.x, y=coords.y, z=coords.z },
		}, {}, function()
			QBCore.Functions.Notify("You eated " ..itemname, "success")
			TriggerServerEvent("Gustav-Pizzeria:RemoveItem", item, 1)
			TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[item], "remove")
			TriggerServerEvent("Gustav-Pizzeria:AddHunger", QBCore.Functions.GetPlayerData().metadata["hunger"] + hunger)
		end, function()
			QBCore.Functions.Notify("Canceled...", "error")
		end)
	else
		QBCore.Functions.Progressbar("eat_"..item, "Eating " ..itemname, time, false, true, {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		}, {
			animDict = anim,
			anim = animdict,
			flags = 49,
		}, {}, {}, function()
			QBCore.Functions.Notify("You eated " ..itemname, "success")
			TriggerServerEvent("Gustav-Pizzeria:RemoveItem", item, 1)
			TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[item], "remove")
			TriggerServerEvent("Gustav-Pizzeria:AddHunger", hunger)
		end, function()
			QBCore.Functions.Notify("Canceled...", "error")
		end)
	end
end)

Citizen.CreateThread(function()
	exports[Config.Target]:AddBoxZone("Duty", vector3(Config.Sted["Duty"]["Coords"].x, Config.Sted["Duty"]["Coords"].y, Config.Sted["Duty"]["Coords"].z), 0.3, 0.6, {
		name = "Duty",
		heading = Config.Sted["Duty"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["Duty"]["minZ"],
		maxZ = Config.Sted["Duty"]["maxZ"],
		}, {
			options = { 
			{
				type = "client",
                event = "Gustav-Pizzeria:DutyMenu",
				icon = Config.Locals['Targets']['Duty']['Icon'],
				label = Config.Locals['Targets']['Duty']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	for k, v in pairs(Config.Sted["WashHands"]) do
        exports[Config.Target]:AddBoxZone("WashHands"..k, vector3(v.coords.x, v.coords.y, v.coords.z), v.poly1, v.poly2, {
            name = "WashHands"..k,
            heading = v.heading,
            debugPoly = Config.PolyZone,
            minZ = v.minZ,
            maxZ = v.maxZ,
            }, {
                options = { 
                {
                    type = "client",
					event = "Gustav-Pizzeria:WashHands",
					icon = Config.Locals['Targets']['WashHands']['Icon'],
					label = Config.Locals['Targets']['WashHands']['Label'],
					heading = v.heading,
					job = Config.Arbejde,
                }
            },
            distance = 1.2,
        })
    end
    
    exports[Config.Target]:AddBoxZone("Shop", vector3(Config.Sted["Shop"]["Coords"].x, Config.Sted["Shop"]["Coords"].y, Config.Sted["Shop"]["Coords"].z), 0.5, 1.0, {
		name = "Shop",
		heading = Config.Sted["Shop"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["Shop"]["minZ"],
		maxZ = Config.Sted["Shop"]["maxZ"],
		}, {
			options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:OpenShop",
				icon = Config.Locals['Targets']['Shop']['Icon'],
				label = Config.Locals['Targets']['Shop']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

    exports[Config.Target]:AddBoxZone("Stash", vector3(Config.Sted["Stash"]["Coords"].x, Config.Sted["Stash"]["Coords"].y, Config.Sted["Stash"]["Coords"].z), 0.5, 1.5, {
		name = "Stash",
		heading = Config.Sted["Stash"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["Stash"]["minZ"],
		maxZ = Config.Sted["Stash"]["maxZ"],
		}, {
			options = { 
			{
				icon = Config.Locals['Targets']['Stash']['Icon'],
				label = Config.Locals['Targets']['Stash']['Label'],
				job = Config.Arbejde,
				action = function()
					QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
						if result then
							TriggerServerEvent("inventory:server:OpenInventory", "stash", "Pizza This Stash", {maxweight = 100000, slots = 100})
							TriggerEvent("inventory:client:SetCurrentStash", "Pizza This Stash") 
						else
							QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
						end
					end)
				end,
			},
		},
		distance = 1.2,
	})
    
    exports[Config.Target]:AddBoxZone("Glasses", vector3(Config.Sted["Glasses"]["Coords"].x, Config.Sted["Glasses"]["Coords"].y, Config.Sted["Glasses"]["Coords"].z), 0.5, 1.0, {
		name = "Glasses",
		heading = Config.Sted["Glasses"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["Glasses"]["minZ"],
		maxZ = Config.Sted["Glasses"]["maxZ"],
		}, {
			options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:GlassesMenu",
				icon = Config.Locals['Targets']['Glasses']['Icon'],
				label = Config.Locals['Targets']['Glasses']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

    exports[Config.Target]:AddBoxZone("DrinksMachine", vector3(Config.Sted["DrinksMachine"]["Coords"].x, Config.Sted["DrinksMachine"]["Coords"].y, Config.Sted["DrinksMachine"]["Coords"].z), 0.5, 1.0, {
		name = "DrinksMachine",
		heading = Config.Sted["DrinksMachine"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["DrinksMachine"]["minZ"],
		maxZ = Config.Sted["DrinksMachine"]["maxZ"],
		}, {
			options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:DrinksMachineMenu",
				icon = Config.Locals['Targets']['DrinksMachine']['Icon'],
				label = Config.Locals['Targets']['DrinksMachine']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

    exports[Config.Target]:AddBoxZone("GrabDrinks", vector3(Config.Sted["GrabDrinks"]["Coords"].x, Config.Sted["GrabDrinks"]["Coords"].y, Config.Sted["GrabDrinks"]["Coords"].z), 0.5, 2.0, {
		name = "GrabDrinks",
		heading = Config.Sted["GrabDrinks"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["GrabDrinks"]["minZ"],
		maxZ = Config.Sted["GrabDrinks"]["maxZ"],
		}, {
			options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:GrabDrinksMenu",
				icon = Config.Locals['Targets']['GrabDrinks']['Icon'],
				label = Config.Locals['Targets']['GrabDrinks']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("BossStash", vector3(Config.Sted["BossStash"]["Coords"].x, Config.Sted["BossStash"]["Coords"].y, Config.Sted["BossStash"]["Coords"].z), 0.5, 0.7, {
		name = "BossStash",
		heading = Config.Sted["BossStash"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["BossStash"]["minZ"],
		maxZ = Config.Sted["BossStash"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:OpenBossStash",
				icon = Config.Locals['Targets']['BossStash']['Icon'],
				label = Config.Locals['Targets']['BossStash']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("GrabBossDrinks", vector3(Config.Sted["GrabBossDrinks"]["Coords"].x, Config.Sted["GrabBossDrinks"]["Coords"].y, Config.Sted["BossStash"]["Coords"].z), 0.9, 0.7, {
		name = "GrabBossDrinks",
		heading = Config.Sted["GrabBossDrinks"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["GrabBossDrinks"]["minZ"],
		maxZ = Config.Sted["GrabBossDrinks"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:GrabBossDrinksMenu",
				icon = Config.Locals['Targets']['GrabBossDrinks']['Icon'],
				label = Config.Locals['Targets']['GrabBossDrinks']['Label'],
				job = Config.Arbejde,
				canInteract = function()
				 	if PlayerJob.isboss then
				 		return true
				 	else
				 		return false
				 	end
				end,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("Fruits", vector3(Config.Sted["Fruits"]["Coords"].x, Config.Sted["Fruits"]["Coords"].y, Config.Sted["Fruits"]["Coords"].z), 0.4, 0.4, {
		name = "Fruits",
		heading = Config.Sted["Fruits"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["Fruits"]["minZ"],
		maxZ = Config.Sted["Fruits"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:FruitsMenu",
				icon = Config.Locals['Targets']['Fruits']['Icon'],
				label = Config.Locals['Targets']['Fruits']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("GrabWater", vector3(Config.Sted["GrabWater"]["Coords"].x, Config.Sted["GrabWater"]["Coords"].y, Config.Sted["GrabWater"]["Coords"].z), 0.4, 0.4, {
		name = "GrabWater",
		heading = Config.Sted["GrabWater"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["GrabWater"]["minZ"],
		maxZ = Config.Sted["GrabWater"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:Grab",
				icon = Config.Locals['Targets']['GrabWater']['Icon'],
				label = Config.Locals['Targets']['GrabWater']['Label'],
				gdrinkname = "Water Cup",
				gdrink = "pwatercup",
				animationdict = "pickup_object",
				animation = "putdown_low",
				time = 3000,
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("GrabCoffee", vector3(Config.Sted["GrabCoffee"]["Coords"].x, Config.Sted["GrabCoffee"]["Coords"].y, Config.Sted["GrabCoffee"]["Coords"].z), 0.5, 0.2, {
		name = "GrabCoffee",
		heading = Config.Sted["GrabCoffee"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["GrabCoffee"]["minZ"],
		maxZ = Config.Sted["GrabCoffee"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:Grab",
				icon = Config.Locals['Targets']['GrabCoffee']['Icon'],
				label = Config.Locals['Targets']['GrabCoffee']['Label'],
				gdrinkname = "Coffee",
				gdrink = "coffee",
				animationdict = "anim@amb@clubhouse@bar@drink@base",
				animation = "idle_a",
				time = 5000,
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	-- exports[Config.Target]:AddBoxZone("Fridge", vector3(Config.Sted["Fridge"]["Coords"].x, Config.Sted["Fridge"]["Coords"].y, Config.Sted["Fridge"]["Coords"].z), 0.7, 0.7, {
	-- 	name = "Fridge",
	-- 	heading = Config.Sted["Fridge"]["Heading"],
	-- 	debugPoly = Config.PolyZone,
	-- 	minZ = Config.Sted["Fridge"]["minZ"],
	-- 	maxZ = Config.Sted["Fridge"]["maxZ"],
	-- }, {
	-- 	options = { 
	-- 		{
	-- 			icon = Config.Locals['Targets']['Fridge']['Icon'],
	-- 			label = Config.Locals['Targets']['Fridge']['Label'],
	-- 			job = Config.Arbejde,
	-- 			action = function()
	-- 				TriggerServerEvent("inventory:server:OpenInventory", "shop", "Fridge", Config.Koeleskabsting)
	-- 			end,
	-- 		},
	-- 	},
	-- 	distance = 1.2,
	-- })

	for k, v in pairs(Config.Sted["Lockers"]) do
        exports[Config.Target]:AddBoxZone("Locker"..k, vector3(v.coords.x, v.coords.y, v.coords.z), v.poly1, v.poly2, {
            name = "Locker"..k,
            heading = v.heading,
            debugPoly = Config.PolyZone,
            minZ = v.minZ,
            maxZ = v.maxZ,
            }, {
                options = { 
                {
                    type = "client",
					event = "qb-clothing:client:openMenu",
					icon = Config.Locals['Targets']['Lockers']['Icon'],
					label = Config.Locals['Targets']['Lockers']['Label'],
					job = Config.Arbejde,
                }
            },
            distance = 1.2,
        })
    end

	exports[Config.Target]:AddBoxZone("PizzaThis-Bossmenu", vector3(Config.Sted["Bossmenu"]["Coords"].x, Config.Sted["Bossmenu"]["Coords"].y, Config.Sted["Bossmenu"]["Coords"].z), 1.2, 2.6, {
		name = "PizzaThis-Bossmenu",
		heading = Config.Sted["Bossmenu"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["Bossmenu"]["minZ"],
		maxZ = Config.Sted["Bossmenu"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "qb-bossmenu:client:OpenMenu",
				icon = Config.Locals['Targets']['Bossmenu']['Icon'],
				label = Config.Locals['Targets']['Bossmenu']['Label'],
				job = Config.Arbejde,
				canInteract = function() 
					return PlayerJob.isboss
				end,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("Dough", vector3(Config.Sted["Dough"]["Coords"].x, Config.Sted["Dough"]["Coords"].y, Config.Sted["Dough"]["Coords"].z), 0.6, 0.6, {
		name = "Dough",
		heading = Config.Sted["Dough"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["Dough"]["minZ"],
		maxZ = Config.Sted["Dough"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:DoughMenu",
				icon = Config.Locals['Targets']['Dough']['Icon'],
				label = Config.Locals['Targets']['Dough']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	for k, v in pairs(Config.Sted["WineRacks"]) do
        exports[Config.Target]:AddBoxZone("WineRacks"..k, vector3(v.coords.x, v.coords.y, v.coords.z), v.poly1, v.poly2, {
            name = "WineRack"..k,
            heading = v.heading,
            debugPoly = Config.PolyZone,
            minZ = v.minZ,
            maxZ = v.maxZ,
            }, {
                options = { 
                {
                    type = "client",
					event = "Gustav-Pizzeria:WineRackMenu",
					icon = Config.Locals['Targets']['WineRacks']['Icon'],
					label = Config.Locals['Targets']['WineRacks']['Label'],
					job = Config.Arbejde,
                }
            },
            distance = 1.2,
        })
	end

	exports[Config.Target]:AddBoxZone("PersonalStash", vector3(Config.Sted["PersonalStash"]["Coords"].x, Config.Sted["PersonalStash"]["Coords"].y, Config.Sted["PersonalStash"]["Coords"].z), 0.6, 1.2, {
		name = "PersonalStash",
		heading = Config.Sted["PersonalStash"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["PersonalStash"]["minZ"],
		maxZ = Config.Sted["PersonalStash"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:OpenPersonalStash",
				icon = Config.Locals['Targets']['PersonalStash']['Icon'],
				label = Config.Locals['Targets']['PersonalStash']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("DoughMachine", vector3(Config.Sted["DoughMachine"]["Coords"].x, Config.Sted["DoughMachine"]["Coords"].y, Config.Sted["DoughMachine"]["Coords"].z), 1.0, 0.6, {
		name = "DoughMachine",
		heading = Config.Sted["DoughMachine"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["DoughMachine"]["minZ"],
		maxZ = Config.Sted["DoughMachine"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:OpenDoughMachineMenu",
				icon = Config.Locals['Targets']['DoughMachine']['Icon'],
				label = Config.Locals['Targets']['DoughMachine']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("DoughPrepare", vector3(Config.Sted["DoughPrepare"]["Coords"].x, Config.Sted["DoughPrepare"]["Coords"].y, Config.Sted["DoughPrepare"]["Coords"].z), 0.6, 1.9, {
		name = "DoughPrepare",
		heading = Config.Sted["DoughPrepare"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["DoughPrepare"]["minZ"],
		maxZ = Config.Sted["DoughPrepare"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:OpenPrepareDoughMenu",
				icon = Config.Locals['Targets']['DoughPrepare']['Icon'],
				label = Config.Locals['Targets']['DoughPrepare']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("CoffeeCups", vector3(Config.Sted["CoffeeCups"]["Coords"].x, Config.Sted["CoffeeCups"]["Coords"].y, Config.Sted["CoffeeCups"]["Coords"].z), 0.5, 1.0, {
		name = "CoffeeCups",
		heading = Config.Sted["CoffeeCups"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["CoffeeCups"]["minZ"],
		maxZ = Config.Sted["CoffeeCups"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:CoffeeCupsMenu",
				icon = Config.Locals['Targets']['CoffeeCups']['Icon'],
				label = Config.Locals['Targets']['CoffeeCups']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.5,
	})

	exports[Config.Target]:AddBoxZone("FoodFridge", vector3(Config.Sted["FoodFridge"]["Coords"].x, Config.Sted["FoodFridge"]["Coords"].y, Config.Sted["FoodFridge"]["Coords"].z), 0.8, 1.3, {
		name = "FoodFridge",
		heading = Config.Sted["FoodFridge"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["FoodFridge"]["minZ"],
		maxZ = Config.Sted["FoodFridge"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:OpenFoodFridge",
				icon = Config.Locals['Targets']['FoodFridge']['Icon'],
				label = Config.Locals['Targets']['FoodFridge']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("CoffeeMachine", vector3(Config.Sted["CoffeeMachine"]["Coords"].x, Config.Sted["CoffeeMachine"]["Coords"].y, Config.Sted["CoffeeMachine"]["Coords"].z), 0.5, 0.7, {
		name = "CoffeeMachine",
		heading = Config.Sted["CoffeeMachine"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["CoffeeMachine"]["minZ"],
		maxZ = Config.Sted["CoffeeMachine"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:MainCoffeeMenu",
				icon = Config.Locals['Targets']['CoffeeMachine']['Icon'],
				label = Config.Locals['Targets']['CoffeeMachine']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.5,
	})

	exports[Config.Target]:AddBoxZone("DrinksMaker", vector3(Config.Sted["DrinksMaker"]["Coords"].x, Config.Sted["DrinksMaker"]["Coords"].y, Config.Sted["DrinksMaker"]["Coords"].z), 0.5, 0.7, {
		name = "DrinksMaker",
		heading = Config.Sted["DrinksMaker"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["DrinksMaker"]["minZ"],
		maxZ = Config.Sted["DrinksMaker"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:DrinksMakerMenu",
				icon = Config.Locals['Targets']['DrinksMaker']['Icon'],
				label = Config.Locals['Targets']['DrinksMaker']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.5,
	})

	for k, v in pairs(Config.Sted["Trays"]) do
        exports[Config.Target]:AddBoxZone("Tray"..k, vector3(v.coords.x, v.coords.y, v.coords.z), v.poly1, v.poly2, {
            name = "Tray"..k,
            heading = v.heading,
            debugPoly = Config.PolyZone,
            minZ = v.minZ,
            maxZ = v.maxZ,
            }, {
                options = { 
                {
					icon = Config.Locals['Targets']['Tray']['Icon'],
					label = Config.Locals['Targets']['Tray']['Label'],
					action = function()
						TriggerServerEvent("inventory:server:OpenInventory", "stash", "PizzaThis "..k.." Tray", {maxweight = 30000, slots = 10})
						TriggerEvent("inventory:client:SetCurrentStash", "PizzaThis "..k.." Tray") 
					end,
                }
            },
            distance = 1.2,
        })
    end

	exports[Config.Target]:AddBoxZone("MakePizza", vector3(Config.Sted["MakePizza"]["Coords"].x, Config.Sted["MakePizza"]["Coords"].y, Config.Sted["MakePizza"]["Coords"].z), 0.4, 0.4, {
		name = "MakePizza",
		heading = Config.Sted["MakePizza"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["MakePizza"]["minZ"],
		maxZ = Config.Sted["MakePizza"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:MakePizzaMenu",
				icon = Config.Locals['Targets']['MakePizza']['Icon'],
				label = Config.Locals['Targets']['MakePizza']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("MakePasta", vector3(Config.Sted["MakePasta"]["Coords"].x, Config.Sted["MakePasta"]["Coords"].y, Config.Sted["MakePasta"]["Coords"].z), 0.6, 0.7, {
		name = "MakePasta",
		heading = Config.Sted["MakePasta"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["MakePasta"]["minZ"],
		maxZ = Config.Sted["MakePasta"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:PastasMenu",
				icon = Config.Locals['Targets']['MakePasta']['Icon'],
				label = Config.Locals['Targets']['MakePasta']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("PizzaOven", vector3(Config.Sted["PizzaOven"]["Coords"].x, Config.Sted["PizzaOven"]["Coords"].y, Config.Sted["PizzaOven"]["Coords"].z), 0.6, 1.7, {
		name = "PizzaOven",
		heading = Config.Sted["PizzaOven"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["PizzaOven"]["minZ"],
		maxZ = Config.Sted["PizzaOven"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:CookPizzaMenu",
				icon = Config.Locals['Targets']['PizzaOven']['Icon'],
				label = Config.Locals['Targets']['PizzaOven']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("Dessert", vector3(Config.Sted["Dessert"]["Coords"].x, Config.Sted["Dessert"]["Coords"].y, Config.Sted["Dessert"]["Coords"].z), 0.6, 1.7, {
		name = "Dessert",
		heading = Config.Sted["Dessert"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["Dessert"]["minZ"],
		maxZ = Config.Sted["Dessert"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:MakeDessertMenu",
				icon = Config.Locals['Targets']['Dessert']['Icon'],
				label = Config.Locals['Targets']['Dessert']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("PizzaAddons", vector3(Config.Sted["PizzaAddons"]["Coords"].x, Config.Sted["PizzaAddons"]["Coords"].y, Config.Sted["PizzaAddons"]["Coords"].z), 0.6, 0.9, {
		name = "PizzaAddons",
		heading = Config.Sted["PizzaAddons"]["Heading"],
		debugPoly = Config.PolyZone,
		minZ = Config.Sted["PizzaAddons"]["minZ"],
		maxZ = Config.Sted["PizzaAddons"]["maxZ"],
	}, {
		options = { 
			{
				type = "client",
				event = "Gustav-Pizzeria:OpenAddonsShop",
				icon = Config.Locals['Targets']['PizzaAddons']['Icon'],
				label = Config.Locals['Targets']['PizzaAddons']['Label'],
				job = Config.Arbejde,
			},
		},
		distance = 1.2,
	})
end)


RegisterNetEvent('Gustav-Pizzeria:Garage:Menu', function()
	local GarageMenu = {
		{
			header = Config.Locals["Menus"]["Garage"]["MainMenu"]["MainHeader"],
			txt = Config.Locals["Menus"]["Garage"]["MainMenu"]["Text"],
			params = {
				event = "Gustav-Pizzeria:Catalog",
			}
		}
	}
	GarageMenu[#GarageMenu+1] = {
		header = Config.Locals["Menus"]["Garage"]["MainMenu"]["StoreVehicleHeader"],
		params = {
			event = "Gustav-Pizzeria:StoreVehicle"
		}
	}
	GarageMenu[#GarageMenu+1] = {
		header = Config.Locals["Menus"]["Garage"]["MainMenu"]["CloseMenuHeader"],
		params = {
			event = "qb-menu:client:closeMenu"
		}
	}
	exports['qb-menu']:openMenu(GarageMenu)
end)

RegisterNetEvent("Gustav-Pizzeria:Catalog", function()
    local VehicleMenu = {
        {
            header = Config.Locals["Menus"]["Garage"]["CatalogMenu"]["MainHeader"],
            isMenuHeader = true,
        }
    }
    for k, v in pairs(Config.Koertoerjer) do
        VehicleMenu[#VehicleMenu+1] = {
            header = v.vehiclename,
            txt = "Rent: " .. v.vehiclename .. " For: " .. v.price .. "$",
            params = {
                isServer = true,
                event = "Gustav-Pizzeria:TakeMoney",
                args = {
                    price = v.price,
                    vehiclename = v.vehiclename,
                    vehicle = v.vehicle
                }
            }
        }
    end
    VehicleMenu[#VehicleMenu+1] = {
        header = Config.Locals["Menus"]["Garage"]["CatalogMenu"]["GoBackHeader"],
        params = {
            event = "Gustav-Pizzeria:Garage:Menu"
        }
    }
    exports['qb-menu']:openMenu(VehicleMenu)
end)

RegisterNetEvent("Gustav-Pizzeria:DutyMenu", function()
    local DutyMenu = {
        {
            header = Config.Locals["Menus"]["Duty"]["MainHeader"],
            isMenuHeader = true,
        }
    }
	DutyMenu[#DutyMenu+1] = {
        header = Config.Locals["Menus"]["Duty"]["SecondHeader"],
		txt = Config.Locals["Menus"]["Duty"]["Text"],
        params = {
			isServer = true,
            event = "QBCore:ToggleDuty"
        }
    }
    DutyMenu[#DutyMenu+1] = {
        header = Config.Locals["Menus"]["Duty"]["CloseMenuHeader"],
        params = {
            event = "qb-menu:client:closemenu"
        }
    }
    exports['qb-menu']:openMenu(DutyMenu)
end)

RegisterNetEvent("Gustav-Pizzeria:GlassesMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local GlassesMenu = {
				{
					header = Config.Locals["Menus"]["Glasses"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			for k, v in pairs(Config.Ting["Glasses"]) do
				GlassesMenu[#GlassesMenu+1] = {
					header = v.image.." ┇ " ..v.glassname,
					txt = "Buy " .. v.glassname .. " For: " .. v.price .. "$",
					params = {
						isServer = true,
						event = "Gustav-Pizzeria:BuyGlass",
						args = {
							price = v.price,
							glassname = v.glassname,
							glass = v.glass
						}
					}
				}
			end
			GlassesMenu[#GlassesMenu+1] = {
				header = Config.Locals["Menus"]["Glasses"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(GlassesMenu)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
    end)
end)

RegisterNetEvent("Gustav-Pizzeria:DrinksMachineMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local DrinksMenu = {
				{
					header = Config.Locals["Menus"]["DrinksMachine"]["MainHeader"],
					isMenuHeader = true,
				}
			}
            for k, v in pairs(Config.Ting["Drinks"]) do
                DrinksMenu[#DrinksMenu+1] = {
                    header = v.image.." ┇ " ..v.drinkname,
                    txt = "Pour " .. v.drinkname .. "</br> Needed Glass: " .. v.glassname,
                    params = {
                        event = "Gustav-Pizzeria:MakeDrink",
                        args = {
                            glassname = v.glassname,
                            glass = v.glass,
                            drinkname = v.drinkname,
                            drink = v.drink,
                        }
                    }
                }
            end
			DrinksMenu[#DrinksMenu+1] = {
				header = Config.Locals["Menus"]["DrinksMachine"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(DrinksMenu)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
    end)
end)

RegisterNetEvent("Gustav-Pizzeria:GrabDrinksMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local GrabDrinks = {
				{
					header = Config.Locals["Menus"]["GrabDrinks"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			for k, v in pairs(Config.Ting["GrabDrinks"]) do
				GrabDrinks[#GrabDrinks+1] = {
					header = v.image.." ┇ " ..v.drinkname,
					txt = "Grab " .. v.drinkname,
					params = {
						event = "Gustav-Pizzeria:Grab",
						args = {
							gdrinkname = v.drinkname,
							gdrink = v.drink,
							animationdict = "pickup_object",
							animation = "putdown_low",
							time = 3000,
						}
					}
				}
			end
			GrabDrinks[#GrabDrinks+1] = {
				header = Config.Locals["Menus"]["GrabDrinks"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(GrabDrinks)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
    end)
end)

RegisterNetEvent("Gustav-Pizzeria:GrabBossDrinksMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local BossGrabDrinksMenu = {
				{
					header = Config.Locals["Menus"]["GrabBossDrinks"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			for k, v in pairs(Config.Ting["GrabBossDrinks"]) do
				BossGrabDrinksMenu[#BossGrabDrinksMenu+1] = {
					header = v.image.." ┇ " ..v.drinkname,
					txt = "Grab " .. v.drinkname,
					params = {
						event = "Gustav-Pizzeria:Grab",
						args = {
							gdrinkname = v.drinkname,
							gdrink = v.drink,
							animationdict = "pickup_object",
							animation = "putdown_low",
							time = 3000,
						}
					}
				}
			end
			BossGrabDrinksMenu[#BossGrabDrinksMenu+1] = {
				header = Config.Locals["Menus"]["GrabBossDrinks"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(BossGrabDrinksMenu)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
    end)
end)

RegisterNetEvent("Gustav-Pizzeria:WineRackMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local WineRack = {
				{
					header = Config.Locals["Menus"]["WineRack"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			for k, v in pairs(Config.Ting["WineRack"]) do
				WineRack[#WineRack+1] = {
					header = v.image.." ┇ " ..v.winename,
					txt = "Grab " .. v.winename,
					params = {
						event = "Gustav-Pizzeria:Grab",
						args = {
							gdrinkname = v.winename,
							gdrink = v.wine,
							animationdict = "pickup_object",
							animation = "putdown_low",
							time = 3000,
						}
					}
				}
			end
			WineRack[#WineRack+1] = {
				header = Config.Locals["Menus"]["WineRack"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(WineRack)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
    end)
end)

RegisterNetEvent("Gustav-Pizzeria:FruitsMenu", function()
    local FruitsMenu = {
        {
            header = Config.Locals["Menus"]["Fruits"]["MainHeader"],
            isMenuHeader = true,
        }
    }
	for k, v in pairs(Config.Ting["Fruits"]) do
		FruitsMenu[#FruitsMenu+1] = {
			header = v.image.." ┇ " ..v.fruitname,
			txt = "Grab " .. v.fruitname,
			params = {
				event = "Gustav-Pizzeria:Grab",
				args = {
					gdrinkname = v.fruitname,
					gdrink = v.fruit,
					animationdict = "anim@amb@clubhouse@bar@drink@one",
					animation = "one_player",
					time = 4500,
				}
			}
		}
	end
    FruitsMenu[#FruitsMenu+1] = {
        header = Config.Locals["Menus"]["Fruits"]["CloseMenuHeader"],
        params = {
            event = "qb-menu:client:closemenu"
        }
    }
    exports['qb-menu']:openMenu(FruitsMenu)
end)

RegisterNetEvent("Gustav-Pizzeria:DoughMenu", function()
    local DoughMenu = {
        {
            header = Config.Locals["Menus"]["Dough"]["MainHeader"],
            isMenuHeader = true,
        }
    }
	if dough >= 1 then
		DoughMenu[#DoughMenu+1] = {
			header = Config.Locals["Menus"]["Dough"]["SecondHeader"],
			txt = "Current Available Dough: "..dough,
			params = {
				event = "Gustav-Pizzeria:Grab",
				args = {
					gdrinkname = "Dough",
					gdrink = "pdough",
					animationdict = "anim@amb@clubhouse@bar@drink@one",
					animation = "one_player",
					time = 4700,
					dough = true,
				}
			}
		}
		DoughMenu[#DoughMenu+1] = {
			header = Config.Locals["Menus"]["Dough"]["ThirdHeader"],
			txt = Config.Locals["Menus"]["Dough"]["ThirdText"],
			params = {
				event = "Gustav-Pizzeria:AddDough"
			}
		}
	else
		DoughMenu[#DoughMenu+1] = {
			header = Config.Locals["Menus"]["Dough"]["FourthHeader"],
			txt = Config.Locals["Menus"]["Dough"]["FourthText"],
			params = {
				event = "Gustav-Pizzeria:AddDough",
			}
		}
	end
    DoughMenu[#DoughMenu+1] = {
        header = Config.Locals["Menus"]["Dough"]["CloseMenuHeader"],
        params = {
            event = "qb-menu:client:closemenu"
        }
    }
    exports['qb-menu']:openMenu(DoughMenu)
end)

RegisterNetEvent("Gustav-Pizzeria:OpenDoughMachineMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local DoughMachineMenu = {
				{
					header = Config.Locals["Menus"]["DoughMachine"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			DoughMachineMenu[#DoughMachineMenu+1] = {
				header =  "<img src=https://cdn.discordapp.com/attachments/967914093396774942/978962983516508170/pbigdough.png width=30px> ".." ┇ Pizza Dough",
				txt = "Ingredients: <br> - Pizza Flour <br> - Water <br> - Salt <br> - Oil",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "PizzaDough",
						time = 5000,
						itemname = "Pizza Dough",
						item2 = "pwater",
						item3 = "poil",
						item4 = "psalt",
						item5 = "ppizzaflour",	
						number = 2,
						recieveitem = "pbigdough",
						animdict = "mini@repair",
						anim = "fixing_a_player",
					}
				}
			}
			DoughMachineMenu[#DoughMachineMenu+1] = {
				header = Config.Locals["Menus"]["DoughMachine"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(DoughMachineMenu)
		else
			QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
		end
	end)
end)

RegisterNetEvent("Gustav-Pizzeria:OpenPrepareDoughMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local PrepareDoughMenu = {
				{
					header = Config.Locals["Menus"]["PrepareDough"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			PrepareDoughMenu[#PrepareDoughMenu+1] = {
				header =  "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979013867856338955/pdough.png width=30px> ".." ┇  Ready Pizza Dough",
				txt = "Ingredients: <br> - Pizza Dough",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						qbcoreevent = true,
						qbcoreitem = "pbigdough",
						time = 5000,
						itemname = "Pizza Dough",
						item2 = "pbigdough",
						recieveitem = "pdough",
						number = 4,
						animdict = "anim@amb@business@coc@coc_unpack_cut@",
						anim = "fullcut_cycle_v6_cokecutter",
					}
				}
			}
			PrepareDoughMenu[#PrepareDoughMenu+1] = {
				header = Config.Locals["Menus"]["PrepareDough"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(PrepareDoughMenu)
		else
			QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
		end
	end)
end)

RegisterNetEvent("Gustav-Pizzeria:CoffeeCupsMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local CoffeeCupsMenu = {
				{
					header = Config.Locals["Menus"]["CoffeeCups"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			for k, v in pairs(Config.Ting["CoffeeCups"]) do
				CoffeeCupsMenu[#CoffeeCupsMenu+1] = {
					header = v.image.." ┇ " ..v.glassname,
					txt = "Buy " .. v.glassname .. " For: " .. v.price .. "$",
					params = {
						isServer = true,
						event = "Gustav-Pizzeria:BuyGlass",
						args = {
							price = v.price,
							glassname = v.glassname,
							glass = v.glass
						}
					}
				}
			end
			CoffeeCupsMenu[#CoffeeCupsMenu+1] = {
				header = Config.Locals["Menus"]["CoffeeCups"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(CoffeeCupsMenu)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
    end)
end)

RegisterNetEvent("Gustav-Pizzeria:DrinksMakerMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local DrinksMakerMenu = {
				{
					header = Config.Locals["Menus"]["DrinksMaker"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			for k, v in pairs(Config.Ting["DrinksMaker"]) do
				DrinksMakerMenu[#DrinksMakerMenu+1] = {
					header = v.image.." ┇ " ..v.drinkname,
					txt = "Grab " .. v.drinkname,
					params = {
						event = "Gustav-Pizzeria:Grab",
						args = {
							gdrinkname = v.drinkname,
							gdrink = v.drink,
							animationdict = "anim@amb@nightclub@mini@drinking@drinking_shots@ped_a@normal",
							animation = "idle",
							time = 2700,
						}
					}
				}
			end
			DrinksMakerMenu[#DrinksMakerMenu+1] = {
				header = Config.Locals["Menus"]["DrinksMaker"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(DrinksMakerMenu)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
    end)
end)

RegisterNetEvent("Gustav-Pizzeria:MakePizzaMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local MakePizzaMenu = {
				{
					header = Config.Locals["Menus"]["MakePizza"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			MakePizzaMenu[#MakePizzaMenu+1] = {
				header =  "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979143892106629170/ppizzabase.png width=30px> ".." ┇ Pizza Base",
				txt = "Ingredients: <br> - Pizza Dough <br> - Pizza Flour <br> - Tomato Souce",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "PizzaBase",
						time = 7000,
						itemname = "Pizza Base",
						item2 = "pdough",
						item3 = "ppizzaflour",
						item4 = "ptomatosouce",
						number = 1,
						recieveitem = "ppizzabase",
						animdict = "mini@repair",
						anim = "fixing_a_ped",
					}
				}
			}
			MakePizzaMenu[#MakePizzaMenu+1] = {
				header = Config.Locals["Menus"]["MakePizza"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(MakePizzaMenu)
		else
			QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
		end
	end)
end)

RegisterNetEvent("Gustav-Pizzeria:MainCoffeeMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local MainCoffeeMenu = {
				{
					header = "Coffee's",
					isMenuHeader = true,
				}
			}
			MainCoffeeMenu[#MainCoffeeMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/926465631770005514/963446697059553351/unknown.png width=30px> ".." ┇ Espresso Macchiato",
				txt = "Ingredients: <br> - Espresso Coffee Glass <br> - Milk <br> - Coffee Beans",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "EspressoMacchiato",
						number = 2,
						time = 5000,
						item2 = "pmilk",
						item3 = "pcoffeebeans",
						item4 = "pespressocoffeecup",	
						itemname = "Espresso Macchiato",
						recieveitem = "pespressomacchiato",
						animdict = "anim@amb@nightclub@mini@drinking@bar@player_bartender@two",
						anim = "two_player",
					}            
				}
			}
			MainCoffeeMenu[#MainCoffeeMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/930069494066475008/945394895328268419/caremel_frappucino.png width=30px> ".." ┇ Caramel Frappucino",
				txt = "Ingredients: <br> - High Coffee Glass <br> - Milk <br> - Coffee Beans <br> - Whipped Cream <br> - Caramel Syrup",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "CaramelFrappucino",
						number = 2,
						time = 5000,
						item2 = "pmilk",
						item3 = "pcoffeebeans",
						item4 = "pcream",
						item5 = "pcaramelsyrup",
						item6 = "phighcoffeeglasscup",	
						itemname = "Caramel Frappucino",
						recieveitem = "pcaramelfrappucino",
						animdict = "anim@amb@nightclub@mini@drinking@bar@player_bartender@two",
						anim = "two_player",
					}        
				}
			}
			MainCoffeeMenu[#MainCoffeeMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/930069494066475008/945394893474398238/cold_brew_latte.png width=30px> ".." ┇ Cold Brew Latte",
				txt = "Ingredients: <br> - High Coffee Glass <br> - Milk <br> - Coffee Beans",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "ColdBrewLatte",
						number = 2,
						time = 5000,
						item2 = "pmilk",
						item3 = "pcoffeebeans",
						item4 = "phighcoffeeglasscup",	
						itemname = "Cold Brew Latte",
						recieveitem = "pcoldbrewlatte",
						animdict = "anim@amb@nightclub@mini@drinking@bar@player_bartender@two",
						anim = "two_player",
					}           
				}
			}
			MainCoffeeMenu[#MainCoffeeMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/930069494066475008/945394940282798201/strawberry_vanilla_oat_latte.png width=30px> ".." ┇ Strawberry Vanilla Oat Latte",
				txt = "Ingredients: <br> - Coffee Glass <br> - Milk <br> - Coffee Beans",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "StrawberryVanillaOatLatte",
						number = 2,
						time = 5000,
						item2 = "pmilk",
						item3 = "pcoffeebeans",
						item4 = "pcoffeeglass",	
						itemname = "Strawberry Vanilla Oat Latte",
						recieveitem = "pstrawberryvanillaoatlatte",
						animdict = "anim@amb@nightclub@mini@drinking@bar@player_bartender@two",
						anim = "two_player",
					}           
				}
			}
			MainCoffeeMenu[#MainCoffeeMenu+1] = {
				header = "⬅ Close",
				params = {
					event = "qb-menu:client:closemenu",
				}
			}
			exports['qb-menu']:openMenu(MainCoffeeMenu)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
    end)
end)

RegisterNetEvent("Gustav-Pizzeria:MakeDessertMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local MakeDessertMenu = {
				{
					header = Config.Locals["Menus"]["Dessert"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			MakeDessertMenu[#MakeDessertMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979152201584881704/pmargharita.png width=30px> ".." ┇ Cook Margharita Pizza",
				txt = "Ingredients: <br> - Pizza Base <br> - Basil <br> - Mozzarella <br> - Olive Oil <br> - Salt",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "MargharitaPizza",
						number = 1,
						time = 8000,
						item2 = "pbasil",
						item3 = "pmozzarella",
						item4 = "poil",	
						item5 = "psalt",
						item6 = "ppizzabase",
						itemname = "Margharita Pizza",
						recieveitem = "pmargharita",
						animdict = "anim@amb@business@meth@meth_monitoring_no_work@",
						anim = "base_lazycook",
					}            
				}
			}
			MakeDessertMenu[#MakeDessertMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979340823177093140/pnapollitano.png width=30px> ".." ┇ Cook Napollitano Pizza",
				txt = "Ingredients: <br> - Pizza Base <br> - Basil <br> - Mozzarella <br> - Salt",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "NapollitanoPizza",
						number = 1,
						time = 8000,
						item2 = "pbasil",
						item3 = "pmozzarella",
						item4 = "psalt",
						item5 = "ppizzabase",
						itemname = "Napollitano Pizza",
						recieveitem = "pnapollitano",
						animdict = "anim@amb@business@meth@meth_monitoring_no_work@",
						anim = "base_lazycook",
					}            
				}
			}
			MakeDessertMenu[#MakeDessertMenu+1] = {
				header = Config.Locals["Menus"]["Dessert"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu",
				}
			}
			exports['qb-menu']:openMenu(MakeDessertMenu)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
    end)
end)

RegisterNetEvent("Gustav-Pizzeria:CookPizzaMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local CookPizzaMenu = {
				{
					header = Config.Locals["Menus"]["Pizzas"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			CookPizzaMenu[#CookPizzaMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979152201584881704/pmargharita.png width=30px> ".." ┇ Cook Margharita Pizza",
				txt = "Ingredients: <br> - Pizza Base <br> - Basil <br> - Mozzarella <br> - Olive Oil <br> - Salt",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "MargharitaPizza",
						number = 1,
						time = 8000,
						item2 = "pbasil",
						item3 = "pmozzarella",
						item4 = "poil",	
						item5 = "psalt",
						item6 = "ppizzabase",
						itemname = "Margharita Pizza",
						recieveitem = "pmargharita",
						animdict = "anim@amb@business@meth@meth_monitoring_no_work@",
						anim = "base_lazycook",
					}            
				}
			}
			CookPizzaMenu[#CookPizzaMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979340823177093140/pnapollitano.png width=30px> ".." ┇ Cook Napollitano Pizza",
				txt = "Ingredients: <br> - Pizza Base <br> - Basil <br> - Mozzarella <br> - Salt",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "NapollitanoPizza",
						number = 1,
						time = 8000,
						item2 = "pbasil",
						item3 = "pmozzarella",
						item4 = "psalt",
						item5 = "ppizzabase",
						itemname = "Napollitano Pizza",
						recieveitem = "pnapollitano",
						animdict = "anim@amb@business@meth@meth_monitoring_no_work@",
						anim = "base_lazycook",
					}            
				}
			}
			CookPizzaMenu[#CookPizzaMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979344270425198612/pmushroomspizza.png width=30px> ".." ┇ Cook Fungi Pizza",
				txt = "Ingredients: <br> - Pizza Base <br> - Butter <br> - Mozzarella <br> - Olive Oil <br> - Mushrooms",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "MushroomsPizza",
						number = 1,
						time = 8000,
						item2 = "pbutter",
						item3 = "pmozzarella",
						item4 = "poil",
						item5 = "ppizzabase",
						item6 = "pmushrooms",
						itemname = "Mushrooms Pizza",
						recieveitem = "pmushroomspizza",
						animdict = "anim@amb@business@meth@meth_monitoring_no_work@",
						anim = "base_lazycook",
					}            
				}
			}
			CookPizzaMenu[#CookPizzaMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979349165568041020/pseafood.png width=30px> ".." ┇ Cook Seafood Pizza",
				txt = "Ingredients: <br> - Pizza Base <br> - Seafood Mix <br> - Mozzarella <br> - Basil <br> - Salt",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "SeafoodPizza",
						number = 1,
						time = 8000,
						item2 = "pseafoodmix",
						item3 = "pmozzarella",
						item4 = "pbasil",
						item5 = "ppizzabase",
						item6 = "psalt",
						itemname = "Seafood Pizza",
						recieveitem = "pseafood",
						animdict = "anim@amb@business@meth@meth_monitoring_no_work@",
						anim = "base_lazycook",
					}            
				}
			}
			CookPizzaMenu[#CookPizzaMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979373569358319616/pvegpizza.png width=30px> ".." ┇ Cook Vegetarian Pizza",
				txt = "Ingredients: <br> - Pizza Base <br> - Tomatoes <br> - Vegetarian Cheese <br> - Basil <br> - Salt",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "VegetarianPizza",
						number = 1,
						time = 8000,
						item2 = "ptomatoes",
						item3 = "pvegicheese",
						item4 = "pbasil",
						item5 = "ppizzabase",
						item6 = "psalt",
						itemname = "Vegetarian Pizza",
						recieveitem = "pvegpizza",
						animdict = "anim@amb@business@meth@meth_monitoring_no_work@",
						anim = "base_lazycook",
					}            
				}
			}
			CookPizzaMenu[#CookPizzaMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979373569358319616/pvegpizza.png width=30px> ".." ┇ Cook Bjørnholdt Ananas Pizza",
				txt = "Ingredients: <br> - Pizza Base <br> - Tomatoes <br> - Vegetarian Cheese <br> - Basil <br> - Salt <br> - Ananas",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "Bjoenholdt",
						number = 1,
						time = 8000,
						item2 = "ptomatoes",
						item3 = "pvegicheese",
						item4 = "pbasil",
						item5 = "ppizzabase",
						item6 = "psalt",
						item6 = "ananas",
						itemname = "Bjørnholdt Pizza",
						recieveitem = "bjoenholdt",
						animdict = "anim@amb@business@meth@meth_monitoring_no_work@",
						anim = "base_lazycook",
					}            
				}
			}
			CookPizzaMenu[#CookPizzaMenu+1] = {
				header = Config.Locals["Menus"]["Pizzas"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu",
				}
			}
			exports['qb-menu']:openMenu(CookPizzaMenu)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
    end)
end)

RegisterNetEvent("Gustav-Pizzeria:PastasMenu", function()
	QBCore.Functions.TriggerCallback('Gustav-Pizzeria:CheckDuty', function(result)
        if result then
			local PastasMenu = {
				{
					header = Config.Locals["Menus"]["Pastas"]["MainHeader"],
					isMenuHeader = true,
				}
			}
			PastasMenu[#PastasMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979434168859631686/pmacncheese.png width=30px> ".." ┇ Cook Mac N Cheese",
				txt = "Ingredients: <br> - Elbow Macaroni <br> - Butter <br> - Milk <br> - Cheddar Cheese <br> - Parmesan Cheese",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "MacNCheese",
						number = 1,
						time = 8000,
						item2 = "pelbowmacaroni",
						item3 = "pbutter",
						item4 = "pmilk",	
						item5 = "pcheddarcheese",
						item6 = "pparmesancheese",
						itemname = "Mac N Cheese",
						recieveitem = "pmacncheese",
						animdict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@",
						anim = "chemical_pour_long_cooker",
					}            
				}
			}
			PastasMenu[#PastasMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979436658132918372/pbbqporkmac.png width=30px> ".." ┇ Cook BBQ Pork Mac",
				txt = "Ingredients: <br> - Pork Meat <br> - Elbow Macaroni <br> - Milk <br> - Cheddar Cheese <br> - BBQ Souce",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "BBQPorkMac",
						number = 1,
						time = 8000,
						item2 = "pporkmeat",
						item3 = "pelbowmacaroni",
						item4 = "pmilk",	
						item5 = "pcheddarcheese",
						item6 = "pbbqsouce",
						itemname = "BBQ Pork Mac",
						recieveitem = "pbbqporkmac",
						animdict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@",
						anim = "chemical_pour_long_cooker",
					}            
				}
			}
			PastasMenu[#PastasMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/967914093396774942/979439685174710392/pfresca.png width=30px> ".." ┇ Cook Pasta Fresca",
				txt = "Ingredients: <br> - Regular Pasta <br> - Olive Oil <br> - Tomatoes <br> - Seafood Mix",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "PastaFresca",
						number = 1,
						time = 8000,
						item2 = "pregularpasta",
						item3 = "poil",
						item4 = "ptomatoes",
						item5 = "pseafoodmix",
						itemname = "Pasta Fresca",
						recieveitem = "pfresca",
						animdict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@",
						anim = "chemical_pour_long_cooker",
					}            
				}
			}
			PastasMenu[#PastasMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/1108467372551061665/1116054682905874503/pcarbonara.png width=30px> ".." ┇ Cook Pasta Carbonara",
				txt = "Ingredients: <br> - Regular Pasta <br> - Olive Oil <br> - Tomatoes <br> - Parmesan Cheese <br> - Bacon",
				params = {
					event = "Gustav-Pizzeria:Make", 
					args = {
						eventname = "PastaCarbonara",
						number = 1,
						time = 8000,
						item2 = "pregularpasta",
						item3 = "poil",
						item4 = "ptomatoes",
						item5 = "pparmesancheese",
						item6 = "bacon",
						itemname = "Pasta Carbonara",
						recieveitem = "carbonara",
						animdict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@",
						anim = "chemical_pour_long_cooker",
					}            
				}
			}
			PastasMenu[#PastasMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/1108467372551061665/1116053994398285854/marinara.png width=30px> ".." ┇ Cook Pasta Marinara",
				txt = "Ingredients: <br> - Regular Pasta <br> - Olive Oil <br> - Tomato Souce",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "PastaMarinara",
						number = 1,
						time = 8000,
						item2 = "pregularpasta",
						item3 = "poil",
						item4 = "ptomatosouce",
						itemname = "Pasta Marinara",
						recieveitem = "marinara",
						animdict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@",
						anim = "chemical_pour_long_cooker",
					}            
				}
			}
			PastasMenu[#PastasMenu+1] = {
				header = "<img src=https://cdn.discordapp.com/attachments/1108467372551061665/1116054740938260670/pomodoro.png width=30px> ".." ┇ Cook Pasta Al Pomodoro",
				txt = "Ingredients: <br> - Regular Pasta <br> - Olive Oil <br> - Tomatoes <br> - Tomato sauce <br> - Basil",
				params = {
					event = "Gustav-Pizzeria:Make",
					args = {
						eventname = "PastaPomodoro",
						number = 1,
						time = 8000,
						item2 = "pregularpasta",
						item3 = "poil",
						item4 = "ptomatoes",
						item5 = "ptomatosouce",
						item6 = "pbasil",
						itemname = "Pasta Al Pomodoro",
						recieveitem = "pomodoro",
						animdict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@",
						anim = "chemical_pour_long_cooker",
					}            
				}
			}
			PastasMenu[#PastasMenu+1] = {
				header = Config.Locals["Menus"]["Pastas"]["CloseMenuHeader"],
				params = {
					event = "qb-menu:client:closemenu",
				}
			}
			exports['qb-menu']:openMenu(PastasMenu)
		else
            QBCore.Functions.Notify(Config.Locals["Notifications"]["MustBeOnDuty"], "error")
        end
    end)
end)


function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function AlcoholEffect()
	local Player = PlayerPedId()
	StartScreenEffect("MinigameEndTrevor", 1.0, 0)
    Citizen.Wait(5000)
    StopScreenEffect("MinigameEndTrevor")
end

function LoadModel(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		Wait(10)
	end
end

function SpawnClipBoard()
	for k, v in pairs(Config.DutyObjects) do
		LoadModel(v.model)
		local Model = CreateObject(GetHashKey(v.model), v.coords.x, v.coords.y, v.coords.z, true)
		SetEntityHeading(Model, v.heading)
		FreezeEntityPosition(Model, true)
		ClipBoardSpawned = true
	end
end

function ShowHelpNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, 50)
end


Citizen.CreateThread(function()
	for k, v in pairs(Config.Sted['General']['Blips']) do
		if Config.BrugBlips then
			Blip = AddBlipForCoord(v.Coords.x, v.Coords.y, v.Coords.z)
			SetBlipSprite(Blip, v.BlipId)
			SetBlipDisplay(Blip, 4)
			SetBlipScale(Blip, 0.6)	
			SetBlipColour(Blip, v.BlipColour)
			SetBlipAsShortRange(Blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.Title)
			EndTextCommandSetBlipName(Blip)
		end
	end	
end)