_addon.name     = 'iSpy'
_addon.author   = 'Selindrile'
_addon.version  = '1.0'
_addon.commands = {'spy','ispy'}

require('luau')
require('coroutine')
packets = require('packets')
res = require('resources')

spy = true
setting = 'odyssey'
report = false
lastreported = nil

SpiedMobs = {
	odyssey = S{'Chest'},
	nyzul = S{'Runic Lamp'},
	questions = S{'???'},
	}

windower.register_event('addon command',function (...)
    cmd = {...}

	if cmd[1] ~= nil then
		cmd[1] = cmd[1]:lower()
	end
	
	if cmd[1] == nil then
		if spy == true then
			spy = false
			windower.add_to_chat(7,'Spying is [OFF].')
		else
			spy = true
			windower.add_to_chat(7,'Spying is [ON].')
		end
	elseif cmd[1] == 'report' then
		if report == true then
			report = false
			windower.add_to_chat(7,'Reporting is [OFF].')
		else
			report = true
			windower.add_to_chat(7,'Reporting is [ON].')
		end
	elseif SpiedMobs[cmd[1]] then
		windower.add_to_chat(7,'Spied mobs set to '..cmd[1]..'.')
		setting = cmd[1]
	else
		windower.add_to_chat(7,'Error: that setting does not exist.')
    end

end)

function Spy()
	if spy then
		local mobs = windower.ffxi.get_mob_array()
		for i, mob in pairs(mobs) do
			if SpiedMobs[setting]:contains(mob.name) and (math.sqrt(mob.distance) < 50) then
				local player = windower.ffxi.get_player()
				if player.target_index == nil then
					packets.inject(packets.new('incoming', 0x058, {
						['Player'] = player.id,
						['Target'] = mob.id,
						['Player Index'] = player.index,
					}))
					if report and mob.id ~= lastreported then
						windower.chat.input('/p Found ['..mob.name..'] at <pos>!')
						lastreported = mob.id
					end
				end
			end
		end
	end
end

Spy:loop(2)