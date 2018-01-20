ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function(target)
  TriggerClientEvent('esx_ambulancejob:revive', target)
end)
RegisterServerEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(target, type)
  TriggerClientEvent('esx_ambulancejob:heal', target, type)
end)

TriggerEvent('esx_phone:registerNumber', 'ambulance', _U('alert_ambulance'), true, true)
TriggerEvent('esx_society:registerSociety', 'ambulance', 'Ambulance', 'society_ambulance', 'society_ambulance', 'society_ambulance', {type = 'public'})

ESX.RegisterServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function(source, cb)

  local xPlayer = ESX.GetPlayerFromId(source)

  if Config.RemoveCashAfterRPDeath then
  
    if xPlayer.getMoney() > 0 then
      xPlayer.removeMoney(xPlayer.getMoney())
    end
	
    if xPlayer.getAccount('black_money').money > 0 then
      xPlayer.setAccountMoney('black_money', 0)
    end
  end

  if Config.RemoveItemsAfterRPDeath then
    for i=1, #xPlayer.inventory, 1 do
      if xPlayer.inventory[i].count > 0 then
        xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
      end
    end
  end

  if Config.RemoveWeaponsAfterRPDeath then
    for i=1, #xPlayer.loadout, 1 do
      xPlayer.removeWeapon(xPlayer.loadout[i].name)
    end
  end
  
  if Config.RespawnFine then
    xPlayer.removeAccountMoney('bank', Config.EarlyRespawnFineAmount)
  end
  
  RemoveLicense(xPlayer)
  
  MySQL.Async.execute(
	'UPDATE users SET isalife = @isalife WHERE identifier = @identifier',
	{
	  ['@isalife']        = 1,
	  ['@identifier']   = xPlayer.identifier,
	}
  )

  cb()

end)

ESX.RegisterServerCallback('esx_ambulancejob:removeItemsAfterRPDeathRemoveMoney', function(source, cb)

  local xPlayer = ESX.GetPlayerFromId(source)


  if Config.RemoveCashAfterRPDeath then
    xPlayer.removeMoney(xPlayer.getMoney())
    xPlayer.setAccountMoney('black_money', 0)
  end


  if Config.EarlyRespawn and Config.EarlyRespawnFine then
    xPlayer.removeAccountMoney('bank', Config.EarlyRespawnFineAmount)
  end

  if Config.RemoveItemsAfterRPDeath then
    for i=1, #xPlayer.inventory, 1 do
      if xPlayer.inventory[i].count > 0 and not xPlayer.inventory[i].rare then
        xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
      end
    end
  end

  if Config.RemoveWeaponsAfterRPDeath then
    for i=1, #xPlayer.loadout, 1 do
      xPlayer.removeWeapon(xPlayer.loadout[i].name)
    end
  end
  
  RemoveLicense(xPlayer)
  
  MySQL.Async.execute(
	'UPDATE users SET isalife = @isalife WHERE identifier = @identifier',
	{
	  ['@isalife']        = 1,
	  ['@identifier']   = xPlayer.identifier,
	}
  )

  cb()

end)

ESX.RegisterServerCallback('esx_ambulancejob:getItemAmount', function(source, cb, item)
  local xPlayer = ESX.GetPlayerFromId(source)
  local qtty = xPlayer.getInventoryItem(item).count
  cb(qtty)
end)

RegisterServerEvent('esx_ambulancejob:removeItem')
AddEventHandler('esx_ambulancejob:removeItem', function(item)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  xPlayer.removeInventoryItem(item, 1)
  if item == 'bandage' then
    TriggerClientEvent('esx:showNotification', _source, _U('used_bandage'))
  elseif item == 'medikit' then
    TriggerClientEvent('esx:showNotification', _source, _U('used_medikit'))
  end
end)

RegisterServerEvent('esx_ambulancejob:giveItem')
AddEventHandler('esx_ambulancejob:giveItem', function(item)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local limit = xPlayer.getInventoryItem(item).limit
  local delta = 1
  local qtty = xPlayer.getInventoryItem(item).count
  if limit ~= -1 then
    delta = limit - qtty
  end
  if qtty < limit then
    xPlayer.addInventoryItem(item, delta)
  else
    TriggerClientEvent('esx:showNotification', _source, _U('max_item'))
  end
end)

RegisterServerEvent('esx_ambulancejob:putInVehicle')
AddEventHandler('esx_ambulancejob:putInVehicle', function(target)
  TriggerClientEvent('esx_ambulancejob:putInVehicle', target)
end)

ESX.RegisterServerCallback('esx_ambulancejob:getBankMoney', function(source, cb)

    local xPlayer = ESX.GetPlayerFromId(source)
    local money = xPlayer.getAccount('bank').money

    cb(money)
end)

TriggerEvent('es:addGroupCommand', 'revive', 'admin', function(source, args, user)

  if args[2] ~= nil then
    TriggerClientEvent('esx_ambulancejob:revive', tonumber(args[2]))
  else
    TriggerClientEvent('esx_ambulancejob:revive', source)
  end

end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('revive_help'), params = {{name = 'id'}}})


ESX.RegisterServerCallback('esx_ambulancejob:getFineList', function(source, cb, category)

  MySQL.Async.fetchAll(
    'SELECT * FROM fine_types_ambulance WHERE category = @category',
    {
      ['@category'] = category
    },
    function(fines)
      cb(fines)
    end
  )

end)

-- RegisterServerEvent('esx_ambulancejob:removeLicense')
-- AddEventHandler('esx_ambulancejob:removeLicense', function(source, cb)
	
	-- local _source = source
	-- local identifier = GetPlayerIdentifiers(_source)

	-- MySQL.Async.fetchAll(
    -- 'DELETE * FROM user_licenses WHERE identifier = @identifier',
    -- {
      -- ['@identifier'] = identifier
    -- },
	-- )
-- end)


RegisterServerEvent('esx_ambulancejob:success')
AddEventHandler('esx_ambulancejob:success', function()

  math.randomseed(os.time())

  local xPlayer        = ESX.GetPlayerFromId(source)
  local total          = math.random(Config.NPCJobEarnings.min, Config.NPCJobEarnings.max);
  local societyAccount = nil

  if xPlayer.job.grade >= 3 then
    total = total * 20
  end

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_taxi', function(account)
    societyAccount = account
  end)

  if societyAccount ~= nil then

    local playerMoney  = math.floor(total / 100 * 30)
    local societyMoney = math.floor(total / 100 * 70)

    xPlayer.addMoney(playerMoney)
    societyAccount.addMoney(societyMoney)

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned') .. playerMoney)
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned') .. societyMoney)

  else

    xPlayer.addMoney(total)
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned') .. total)

  end

end)


function RemoveLicense(xPlayer)

	MySQL.Async.execute(
		'DELETE FROM user_licenses WHERE owner = @owner',
		{
			['@owner'] = xPlayer.identifier
		}
	)
end

RegisterServerEvent('esx_ambulancejob:getStockItem')
AddEventHandler('esx_ambulancejob:getStockItem', function(itemName, count)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ambulance', function(inventory)

    local item = inventory.getItem(itemName)

    if item.count >= count then
      inventory.removeItem(itemName, count)
      xPlayer.addInventoryItem(itemName, count)
	  TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn') .. count .. ' ' .. item.label)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
    end
  end)
end)

RegisterServerEvent('esx_ambulancejob:isalife')
AddEventHandler('esx_ambulancejob:isalife', function(isalifeornot)
	local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute(
	'UPDATE users SET isalife = @isalife WHERE identifier = @identifier',
	{
	  ['@isalife']      = isalifeornot,
	  ['@identifier']   = xPlayer.identifier,
	}
  )
end)

AddEventHandler('es:playerLoaded', function(source) 
	local xPlayer = GetPlayerIdentifiers(source)[1]
	MySQL.Async.fetchAll(
	'select * from users WHERE identifier = @identifier',
	{
	  ['@identifier']   = xPlayer,
	}, 
	function (result)
		if(result[1].isalife ~= 1) then
			print(xPlayer.." es mort")
			TriggerClientEvent('esx_ambulancejob:killped', source)
		else
		end
	end)
end)

-- AddEventHandler('playerSpawned', function(spawn)
    -- local xPlayer = GetPlayerIdentifiers(source)[1]
	-- print(xPlayer.." xplayer")
	-- MySQL.Async.fetchAll(
	-- 'select * from users WHERE identifier = @identifier',
	-- {
	  -- ['@identifier']   = xPlayer,
	-- }, 
	-- function (result)
		-- if(result[1].isalife ~= 1) then
			-- print("tu es mort")
			-- TriggerClientEvent('esx_ambulancejob:killped', source)
		-- else
			-- print("tu es vivant")
		-- end
	-- end)
-- end)



ESX.RegisterServerCallback('esx_ambulancejob:getStockItems', function(source, cb)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ambulance', function(inventory)
    cb(inventory.items)
  end)
end)

RegisterServerEvent('esx_ambulancejob:putStockItems')
AddEventHandler('esx_ambulancejob:putStockItems', function(itemName, count)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ambulance', function(inventory)

    local item = inventory.getItem(itemName)
	local countinventoryitem = xPlayer.getInventoryItem(itemName).count

    if item.count >= 0 and count <= countinventoryitem then
      xPlayer.removeInventoryItem(itemName, count)
      inventory.addItem(itemName, count)
	  TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_added') .. count .. ' ' .. item.label)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
    end
  end)
end)


ESX.RegisterServerCallback('esx_ambulancejob:getPlayerInventory', function(source, cb)

  local xPlayer    = ESX.GetPlayerFromId(source)
  local items      = xPlayer.inventory

  cb({
    items      = items
  })

end)