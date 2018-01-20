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

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)
-- Create Blips
Citizen.CreateThread(function ()
	for i = 1, #Config.garage, 1 do
		local blip = AddBlipForCoord(Config.garage[i].x, Config.garage[i].y, Config.garage[i].z)

		SetBlipSprite(blip, 402)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 1.5)
		SetBlipColour (blip, 41)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Réparation véhicule")
		EndTextCommandSetBlipName(blip)
	end
    --return
end)

function esx_repairvehicule_DrawSubtitleTimed(m_text, showtime)
	SetTextEntry_2('STRING')
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end

function esx_repairvehicule_DrawNotification(m_text)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(m_text)
	DrawNotification(true, false)
end

--Display Markers
Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then 
			for k,v in pairs(Config.Zones) do
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0, 0, 0, 0, 0, 0, 5.0, 5.0, 2.0, 0, 157, 0, 155, 0, 0, 2, 0, 0, 0, 0)
				if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v.Pos.x, v.Pos.y, v.Pos.z, true ) < 5 then
					esx_repairvehicule_DrawSubtitleTimed("Appuyez sur [~g~ENTRER~s~] pour réparer votre véhicule!")
					if IsControlJustPressed(1, 18) then
						TriggerServerEvent('esx_repairvehicule:checkmoney')
					end
				end
			end
		end
	end
end)

RegisterNetEvent('esx_repairvehicule:success')
AddEventHandler('esx_repairvehicule:success', function (price)
	local ped = GetPlayerPed(-1)

	if ( DoesEntityExist (ped) and not IsEntityDead (ped) ) then
		if (IsPedSittingInAnyVehicle(ped)) then
			local vehicle = GetVehiclePedIsIn(ped, false)
			if (GetPedInVehicleSeat(vehicle, -1) == ped) then
				SetVehicleEngineHealth(vehicle, 1000)
				SetVehicleEngineOn(vehicle, true, true)
				SetVehicleFixed(vehicle)
				esx_repairvehicule_DrawNotification("Votre véhicule a été ~y~réparé~s~! pour ~g~-$" .. price .. "~s~!")
			end
		end
	end
end)

RegisterNetEvent('esx_repairvehicule:notenoughmoney')
AddEventHandler('esx_repairvehicule:notenoughmoney', function ()
	esx_repairvehicule_DrawNotification("~h~~r~Vous n'avez pas assez d'argent!")
end)