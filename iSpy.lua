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
found = T{}
found_index = 1

SpiedMobs = {
	odyssey = S{'Chest','Coffer','Strongbox'},
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
		local player = windower.ffxi.get_player()
		if player.target_index == nil then
			local mobs = windower.ffxi.get_mob_array()
			local best_match
			for i, mob in pairs(mobs) do
				if SpiedMobs[setting]:contains(mob.name) and (math.sqrt(mob.distance) < 50) then
					--windower.add_to_chat(7,mob.name)
					if best_match == nil or (found:contains(best_match.id) and not found:contains(mob.id)) or mob.distance < best_match.distance then
						best_match = mob
						--windower.add_to_chat(7,'new best: '..best_match.name..'')
					end
				end
			end

			if best_match ~= nil then
				
				local self_vector = windower.ffxi.get_mob_by_id(player.id)
				local angle = (math.atan2((best_match.y - self_vector.y), (best_match.x - self_vector.x))*180/math.pi)*-1
				windower.ffxi.turn((angle):radian())
				
				if not found:contains(best_match.id) then
					--windower.add_to_chat(7,'targetting: '..best_match.name..'')
					packets.inject(packets.new('incoming', 0x058, {
						['Player'] = player.id,
						['Target'] = best_match.id,
						['Player Index'] = player.index,
					}))
	
					if report then
						windower.chat.input('/p Found ['..best_match.name..'] at <pos>!')
					else
						windower.add_to_chat(7,'Found ['..best_match.name..']!')
					end
					
					found[found_index] = best_match.id
					if found_index > 3 then
						found_index = 1
					else
						found_index = found_index + 1
					end
				end
			end
		end
	end
end

Spy:loop(1.5)