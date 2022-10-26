local pasaning = {}
local beingPasaned = {}

RegisterServerEvent("Pasan:sync")
AddEventHandler("Pasan:sync", function(targetSrc)
	local source = source
	local sourcePed = GetPlayerPed(source)
    	local sourceCoords = GetEntityCoords(sourcePed)
	local targetPed = GetPlayerPed(targetSrc)
    	local targetCoords = GetEntityCoords(targetPed)
	if #(sourceCoords - targetCoords) <= 3.0 then 
		TriggerClientEvent("Pasan:syncTarget", targetSrc, source)
		pasaning[source] = targetSrc
		beingPasaned[targetSrc] = source
	end
end)

RegisterServerEvent("Pasan:stop")
AddEventHandler("Pasan:stop", function(targetSrc)
	local source = source

	if pasaning[source] then
		TriggerClientEvent("Pasan:cl_stop", targetSrc)
		pasaning[source] = nil
		beingPasaned[targetSrc] = nil
	elseif beingPasaned[source] then
		TriggerClientEvent("Pasan:cl_stop", beingPasaned[source])
		beingPasaned[source] = nil
		pasaning[beingPasaned[source]] = nil
	end
end)

AddEventHandler('playerDropped', function(reason)
	local source = source
	
	if pasaning[source] then
		TriggerClientEvent("Pasan:cl_stop", pasaning[source])
		beingPasaned[pasaning[source]] = nil
		pasaning[source] = nil
	end

	if beingPasaned[source] then
		TriggerClientEvent("Pasan:cl_stop", beingPasaned[source])
		pasaning[beingPasaned[source]] = nil
		beingPasaned[source] = nil
	end
end)

local atrp = [[^4
 █████╗ ████████╗██████╗ ██████╗     ██████╗  █████╗ ███████╗ █████╗ ███╗   ██╗
██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗██╔════╝██╔══██╗████╗  ██║
███████║   ██║   ██████╔╝██████╔╝    ██████╔╝███████║███████╗███████║██╔██╗ ██║
██╔══██║   ██║   ██╔══██╗██╔═══╝     ██╔═══╝ ██╔══██║╚════██║██╔══██║██║╚██╗██║
██║  ██║   ██║   ██║  ██║██║         ██║     ██║  ██║███████║██║  ██║██║ ╚████║
╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝         ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝
]]
AddEventHandler('onResourceStart', function(resourceName)
    Citizen.Wait(5000)
    if GetCurrentResourceName() == resourceName then
        print(atrp)
    end
end)