-- Loading MySQL Class
require "resources/mysql-async/lib/MySQL"

-- MySQL:open("IP", "databasname", "user", "password")
MySQL:open("127.0.0.1", "hnomkeng_fivem", "hnomkeng", "Deathnote1#")

TriggerEvent('es:addGroupCommand', 'ban', "admin", function(source, args, user)
		if(GetPlayerName(tonumber(args[2])) ~= nil)then
			-- User permission check
			local player = tonumber(args[2])
			TriggerEvent("es:getPlayerFromId", player, function(target)
					if(tonumber(target.permission_level) > tonumber(user.permission_level))then
						TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "You're not allowed to target this person!")
						return
					end
				local time = args[3]

				local message = ""

				if string.find(time, "m") then
					time = string.gsub(time, "m", "")
					time = os.time() + (tonumber(time) * 60)
					message = time .. " minute(s)"
				elseif string.find(time, "h") then
					time = string.gsub(time, "h", "")
					message = time .. " hour(s)"
					time = os.time() + (tonumber(time) * 60 * 60)
				else
					time = os.time() + tonumber(time)
					message = time .. " second(s)"
				end

				if not tonumber(time) > 0 then
					time = os.time() + 999999999999
					message = 'very long'
				end

				local reason = args
				table.remove(reason, 1)
				table.remove(reason, 1)
				table.remove(reason, 1)

				reason = "Banned: " .. table.concat(reason, " ")

				if(reason == "Banned: ")then
					reason = reason .. "You have been banned for: ^1" .. message .. "^0."
					DropPlayer(player, "You have been banned for: " .. message)
				else
					DropPlayer(player, "Banned: " .. reason)
				end

				TriggerClientEvent('chatMessage', -1, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been banned(^2" .. reason .. "^0)")

				local tstamp = os.date("*t", time)
				local tstamp2 = os.date("*t", os.time())

				MySQL:executeQuery("INSERT INTO bans (`banned`, `reason`, `expires`, `banner`, `timestamp`) VALUES ('@username', '@reason', '@expires', '@banner', '@now')",
				{['@username'] = target.identifier, ['@reason'] = reason, ['@expires'] = os.date(tstamp.year .. "-" .. tstamp.month .. "-" .. tstamp.day .. " " .. tstamp.hour .. ":" .. tstamp.min .. ":" .. tstamp.sec), ['@banner'] = user.identifier, ['@now'] = os.date(tstamp2.year .. "-" .. tstamp2.month .. "-" .. tstamp2.day .. " " .. tstamp2.hour .. ":" .. tstamp2.min .. ":" .. tstamp2.sec)})
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

function stringsplit(self, delimiter)
  local a = self:Split(delimiter)
  local t = {}

  for i = 0, #a - 1 do
     table.insert(t, a[i])
  end

  return t
end