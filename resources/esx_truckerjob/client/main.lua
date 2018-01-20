--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Script serveur No Brain Modified by AlphaKush for ESX 
-- www.nobrain.org
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
------------------- Configuration du script
--------------------------------------------------------------------------------
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}


local livraisonmax = 10
--------------------------------------------------------------------------------
-- NE RIEN MODIFIER
--------------------------------------------------------------------------------
local namezone = "Delivery"
local namezonenum = 0
local namezoneregion = 0
local MissionRegion = 0
local viemaxvehicule = 1000
local argentretire = 0
local livraisonTotalPaye = 0
local livraisonnombre = 0
local MissionRetourCamion = false
local MissionNum = 0
local MissionLivraison = false
local isInService = false
local PlayerData              = {}
local GUI                     = {}
GUI.Time                      = 0

local hasAlreadyEnteredMarker = false;
local lastZone                = nil;
local Blips                   = {}

local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}

ESX = nil
--------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer

    if PlayerData.job.name == 'trucker' then
		Config.Zones.VehicleSpawner.Type = 1
		Config.Zones.CloakRoom.Type = 1
		Config.Zones.RetourCamion.Type = 1

	else
		Config.Zones.VehicleSpawner.Type = -1
		Config.Zones.CloakRoom.Type = -1
		Config.Zones.RetourCamion.Type = -1
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	
	PlayerData.job = job

	if PlayerData.job.name == 'trucker' then
		Config.Zones.VehicleSpawner.Type = 1
		Config.Zones.CloakRoom.Type = 1
		Config.Zones.RetourCamion.Type = 1
	else
		Config.Zones.VehicleSpawner.Type = -1
		Config.Zones.CloakRoom.Type = -1
		Config.Zones.RetourCamion.Type = -1
	end
end)

function OpenCloakRoom()
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'cloakroom',
		{
			title    = 'Vestiaire',
			elements = {
				{label = 'Tenue de travail', value = 'job_wear'},
				{label = 'Tenue civil', value = 'citizen_wear'},
			}
		},
		function(data, menu)
			menu.close()

			if data.current.value == 'citizen_wear' then
				isInService = false
				RemoveBlip(Blips['delivery'])
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
	    			TriggerEvent('skinchanger:loadSkin', skin)
				end)
			end
			if data.current.value == 'job_wear' then
				isInService = true
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
	    			if skin.sex == 0 then
	    				TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
					else
	    				TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
					end
				end)
			end
			CurrentAction     = 'cloakroom_menu'
			CurrentActionMsg  = _U('cloakroom')
			CurrentActionData = {}
		end,
		function(data, menu)
			menu.close()
		end
	)
end

AddEventHandler('esx_truckerjob:hasEnteredMarker', function(zone)

	if zone == 'CloakRoom' and PlayerData.job.name ~= nil and PlayerData.job.name == 'trucker' then
		CurrentAction = 'cloakroom_menu'
		CurrentActionMsg = _U('cloakroom')
		CurrentActionData = {}
	end

	if zone == 'VehicleSpawner' and PlayerData.job.name ~= nil and PlayerData.job.name == 'trucker' then
		CurrentAction = 'vehicle_spawner_menu'
		CurrentActionMsg = _U('veh_spawn')
		CurrentActionData = {}
	end

	if zone == namezone and PlayerData.job.name ~= nil and PlayerData.job.name == 'trucker' then
			if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) and IsVehicleModel(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetHashKey("mule2", _r)) then
				if Blips['delivery'] ~= nil then
					RemoveBlip(Blips['delivery'])
					Blips['delivery'] = nil
				end
				CurrentAction = 'delivery_ok'
				CurrentActionMsg = _U('delivery_obj')
				CurrentActionData = {}
			else
				SendNotification("~r~Ce n'est pas le véhicule qu'on ta fournit !~w~")
			end
	end

	if zone == 'RetourCamion' and PlayerData.job.name ~= nil and PlayerData.job.name == 'trucker' then
		CurrentAction = 'vehicle_delete_menu'
		CurrentActionMsg = _U('veh_delete')
		CurrentActionData = {}
	end

end)

function OpenVehicleSpawnerMenu()
		local elements = {
		{label = 'Sortir Véhicule', value = 'vehicle_list'},
	}
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'trucker_actions',
		{
			title    = 'Voitures de service',
			elements = elements
		},
		function(data, menu)
			if data.current.value == 'vehicle_list' then
						local elements = {
							{label = 'Camion', value = 'mule2'}
						}

						ESX.UI.Menu.CloseAll()
						ESX.UI.Menu.Open(
							'default', GetCurrentResourceName(), 'spawn_vehicle',
							{
								title    = 'Véhicule de service',
								elements = elements
							},
							function(data, menu)
								for i=1, #elements, 1 do
									if Config.MaxInService == -1 and isInService then
										ESX.Game.SpawnVehicle(data.current.value, Config.Zones.VehicleSpawnPoint.Pos, 269.12, function(vehicle) -- direction du spawn
											local playerPed = GetPlayerPed(-1)
											SetEntityAsMissionEntity(vehicle,  true,  true)
											TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
										end)
										MissionLivraisonSelect()
										break
									else
										SendNotification("~r~Tu dois d'abord prendre ton service !~w~")
									end
								end
								menu.close()
							end,
							function(data, menu)
								menu.close()
								OpenVehicleSpawnerMenu()
							end
						)
			end
		end,
		function(data, menu)
			menu.close()
			CurrentAction     = 'vehicle_spawner_menu'
			CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour accéder au menu.'
			CurrentActionData = {}
		end
	)
end

AddEventHandler('esx_truckerjob:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
		
		if MissionLivraison and isInService then
			DrawMarker(destination.Type, destination.Pos.x, destination.Pos.y, destination.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, destination.Size.x, destination.Size.y, destination.Size.z, destination.Color.r, destination.Color.g, destination.Color.b, 100, false, true, 2, false, false, false, false)
		end
	end
end)

--Display Markers
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		if PlayerData.job ~= nil then

			local coords = GetEntityCoords(GetPlayerPed(-1))
			for k,v in pairs(Config.Zones) do
				if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, 120, 120, 240, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

-- Create blips
Citizen.CreateThread(function()

		local blip = AddBlipForCoord(Config.Zones.CloakRoom.Pos.x, Config.Zones.CloakRoom.Pos.y, Config.Zones.CloakRoom.Pos.z)

		SetBlipSprite (blip, 318)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 1.4)
		SetBlipColour (blip, 66)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('realtors'))
		EndTextCommandSetBlipName(blip)
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Wait(0)
			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end

			for k,v in pairs(Config.Livraison) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end

			if (isInMarker and not hasAlreadyEnteredMarker) or (isInMarker and lastZone ~= currentZone) then
				hasAlreadyEnteredMarker = true
				lastZone                = currentZone
				TriggerEvent('esx_truckerjob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
				TriggerEvent('esx_truckerjob:hasExitedMarker', lastZone)
			end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if CurrentAction ~= nil then
			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - GUI.Time) > 300 then
				if CurrentAction == 'cloakroom_menu' and PlayerData.job.name == 'trucker' then
					OpenCloakRoom()
				end

				if CurrentAction == 'vehicle_spawner_menu' and PlayerData.job.name == 'trucker' then
					OpenVehicleSpawnerMenu()
				end

				if CurrentAction == 'delivery_ok' and PlayerData.job.name == 'trucker' then
					nouvelledestination()
				end

				if CurrentAction == 'vehicle_delete_menu' and PlayerData.job.name == 'trucker' then
					if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) and IsVehicleModel(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetHashKey("mule2", _r)) then
						ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
						donnerlapaye()
					else
						SendNotification("~r~Ce n'est pas le véhicule qu'on ta fournit !~w~")
					end
					
				end
				CurrentAction = nil
				GUI.Time      = GetGameTimer()
			end
		end
	end
end)

function nouvelledestination()
	livraisonnombre = livraisonnombre+1
	livraisonTotalPaye = livraisonTotalPaye+destination.Paye

	if livraisonnombre >= livraisonmax then
		MissionLivraisonStopRetourDepot()
	else

		livraisonsuite = math.random(0, 100)
		
		if livraisonsuite <= 10 then
			MissionLivraisonStopRetourDepot()
		elseif livraisonsuite <= 99 then
			MissionLivraisonSelect()
		elseif livraisonsuite <= 100 then
			if MissionRegion == 1 then
				MissionRegion = 2
			elseif MissionRegion == 2 then
				MissionRegion = 1
			end
			MissionLivraisonSelect()	
		end
	end
end

--fonction pour supprimer voiture
function deleteCar( entity )
    ESX.Game.DeleteVehicle(entity)
end

--fonction pour arondir
function round(num, numDecimalPlaces)
  local mult = 5^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function donnerlapaye()
	ped = GetPlayerPed(-1)
	vehicle = GetVehiclePedIsIn(ped, false)
	vievehicule = GetVehicleEngineHealth(vehicle)
	calculargentretire = round(viemaxvehicule-vievehicule)
	
	if calculargentretire <= 0 then
		argentretire = 0
	else
		argentretire = calculargentretire
	end
	
	-- despawn camion
	SetEntityAsMissionEntity( vehicle, true, true )
	deleteCar(vehicle)
	
	-- donne paye
	local amount = livraisonTotalPaye-argentretire
	
	if vievehicule >= 1 then
		if livraisonTotalPaye == 0 then
			TriggerEvent('esx:showNotification', 'Pas de livraison, pas de chèque !')
			TriggerEvent('esx:showNotification', 'Réparations camion : -'..argentretire)
			TriggerServerEvent("esx_truckerjob:pay", amount)
			livraisonTotalPaye = 0
		else
			if argentretire <= 0 then
				TriggerEvent('esx:showNotification', 'Livraisons : ~g~+ '..livraisonTotalPaye ..' $~w~')
					TriggerServerEvent("esx_truckerjob:pay", amount)
				livraisonTotalPaye = 0
			else
				TriggerEvent('esx:showNotification', 'Livraisons : +'..livraisonTotalPaye)
				TriggerEvent('esx:showNotification', 'Réparations camion : -'..argentretire)
					TriggerServerEvent("esx_truckerjob:pay", amount)
				livraisonTotalPaye = 0
			end
		end
	else
		if livraisonTotalPaye ~= 0 and amount <= 0 then
			TriggerEvent('esx:showNotification', 'Pas de chèque, vue l\'état du camion !')
			livraisonTotalPaye = 0
		else
			if argentretire <= 0 then
				TriggerEvent('esx:showNotification', 'Livraisons : +'..livraisonTotalPaye)
					TriggerServerEvent("esx_truckerjob:pay", amount)
				livraisonTotalPaye = 0
			else
				TriggerEvent('esx:showNotification', 'Livraisons : +'..livraisonTotalPaye)
				TriggerEvent('esx:showNotification', 'Réparations camion : -'..argentretire)
				TriggerServerEvent("esx_truckerjob:pay", amount)
				livraisonTotalPaye = 0
			end
		end
	end
end

function SendNotification(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(false, false)
end

-------------------------------------------------
-- Fonctions
-------------------------------------------------
-- Fonction selection nouvelle mission livraison
function MissionLivraisonSelect()
	if MissionRegion == 0 then
		MissionRegion = math.random(1,2)
	end
	
	if MissionRegion == 1 then -- Los santos
		MissionNum = math.random(1, 10)
	
		if MissionNum == 1 then destination = Config.Livraison.Delivery1LS namezone = "Delivery1LS" namezonenum = 1 namezoneregion = 1
		elseif MissionNum == 2 then destination = Config.Livraison.Delivery2LS namezone = "Delivery2LS" namezonenum = 2 namezoneregion = 1
		elseif MissionNum == 3 then destination = Config.Livraison.Delivery3LS namezone = "Delivery3LS" namezonenum = 3 namezoneregion = 1
		elseif MissionNum == 4 then destination = Config.Livraison.Delivery4LS namezone = "Delivery4LS" namezonenum = 4 namezoneregion = 1
		elseif MissionNum == 5 then destination = Config.Livraison.Delivery5LS namezone = "Delivery5LS" namezonenum = 5 namezoneregion = 1
		elseif MissionNum == 6 then destination = Config.Livraison.Delivery6LS namezone = "Delivery6LS" namezonenum = 6 namezoneregion = 1
		elseif MissionNum == 7 then destination = Config.Livraison.Delivery7LS namezone = "Delivery7LS" namezonenum = 7 namezoneregion = 1
		elseif MissionNum == 8 then destination = Config.Livraison.Delivery8LS namezone = "Delivery8LS" namezonenum = 8 namezoneregion = 1
		elseif MissionNum == 9 then destination = Config.Livraison.Delivery9LS namezone = "Delivery9LS" namezonenum = 9 namezoneregion = 1
		elseif MissionNum == 10 then destination = Config.Livraison.Delivery10LS namezone = "Delivery10LS" namezonenum = 10 namezoneregion = 1
		end
		
	elseif MissionRegion == 2 then -- Blaine County
		MissionNum = math.random(1, 10)
	
		if MissionNum == 1 then destination = Config.Livraison.Delivery1BC namezone = "Delivery1BC" namezonenum = 1 namezoneregion = 2
		elseif MissionNum == 2 then destination = Config.Livraison.Delivery2BC namezone = "Delivery2BC" namezonenum = 2 namezoneregion = 2
		elseif MissionNum == 3 then destination = Config.Livraison.Delivery3BC namezone = "Delivery3BC" namezonenum = 3 namezoneregion = 2
		elseif MissionNum == 4 then destination = Config.Livraison.Delivery4BC namezone = "Delivery4BC" namezonenum = 4 namezoneregion = 2
		elseif MissionNum == 5 then destination = Config.Livraison.Delivery5BC namezone = "Delivery5BC" namezonenum = 5 namezoneregion = 2
		elseif MissionNum == 6 then destination = Config.Livraison.Delivery6BC namezone = "Delivery6BC" namezonenum = 6 namezoneregion = 2
		elseif MissionNum == 7 then destination = Config.Livraison.Delivery7BC namezone = "Delivery7BC" namezonenum = 7 namezoneregion = 2
		elseif MissionNum == 8 then destination = Config.Livraison.Delivery8BC namezone = "Delivery8BC" namezonenum = 8 namezoneregion = 2
		elseif MissionNum == 9 then destination = Config.Livraison.Delivery9BC namezone = "Delivery9BC" namezonenum = 9 namezoneregion = 2
		elseif MissionNum == 10 then destination = Config.Livraison.Delivery10BC namezone = "Delivery10BC" namezonenum = 10 namezoneregion = 2
		end
		
	end
	MissionLivraisonLetsGo()
end

-- Fonction active mission livraison
function MissionLivraisonLetsGo()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	if isInService then
		Blips['delivery'] = AddBlipForCoord(destination.Pos.x,  destination.Pos.y,  destination.Pos.z)
		SetBlipRoute(Blips['delivery'], true)
	end

	if MissionRegion == 1 then -- Los santos
		TriggerEvent('esx:showNotification', 'Rendez-vous au point de livraison à Los Santos')
	elseif MissionRegion == 2 then -- Blaine County
		TriggerEvent('esx:showNotification', 'Rendez-vous au point de livraison à Blaine County')
	elseif MissionRegion == 0 then -- au cas ou
		TriggerEvent('esx:showNotification', 'Rendez-vous au point de livraison')
	end

	MissionLivraison = true
end

--Fonction retour au depot
function MissionLivraisonStopRetourDepot()
	destination = Config.Zones.RetourCamion
	
	Blips['delivery'] = AddBlipForCoord(destination.Pos.x,  destination.Pos.y,  destination.Pos.z)
	SetBlipRoute(Blips['delivery'], true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Walker Logistics : dépot")
	EndTextCommandSetBlipName(Blips['delivery'])

	TriggerEvent('esx:showNotification', 'Retournez au dépot pour finir votre tourné.')
	
	MissionRegion = 0
	MissionLivraison = false
	MissionNum = 0
	MissionRetourCamion = true
end