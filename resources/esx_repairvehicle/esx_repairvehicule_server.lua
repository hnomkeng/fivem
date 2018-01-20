ESX 						= nil
local mecanoConnected 		= 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function CountMecano()

	local xPlayers = ESX.GetPlayers()

	mecanoConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'mecano' then
			mecanoConnected = mecanoConnected + 1
		end
	end
	SetTimeout(5000, CountMecano)
end

CountMecano()

RegisterServerEvent('esx_repairvehicule:checkmoney')

AddEventHandler('esx_repairvehicule:checkmoney', function()
	TriggerEvent('es:getPlayerFromId', source, function (user)
		local price = tonumber(Config.Price)
		local moneyuser = user.getMoney()
		if mecanoConnected == 0 then
			if moneyuser >= price then
				user.removeMoney(price)
				TriggerClientEvent('esx_repairvehicule:success', source, price)
			else
				TriggerClientEvent('esx_repairvehicule:notenoughmoney', source)
			end
		else
			TriggerClientEvent('esx:showNotification', source, "~h~~r~Un mécano est en ville, contactez le !")
		end
	end)
end)