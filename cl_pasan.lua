
local pasan = {
	InProgress = false,
	targetSrc = -1,
	type = "",
	personPasaning = {
		animDict = "move_m@hiking",
		anim = "idle",
		flag = 49,
	},
	personBeingPasaned = {
		animDict = "amb@prop_human_seat_computer@male@react_shock",
		anim = "forward",
		attachX = 0.00,
		attachY = -0.31,
		attachZ = 0.09,
		flag = 33,
	}
}

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _,playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
	if closestDistance ~= -1 and closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end

RegisterCommand("pasan",function(source, args)
	if not pasan.InProgress then
		local closestPlayer = GetClosestPlayer(3)
		if closestPlayer then
			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				pasan.InProgress = true
				pasan.targetSrc = targetSrc
				TriggerServerEvent("Pasan:sync",targetSrc)
				ensureAnimDict(pasan.personPasaning.animDict)
				pasan.type = "pasaning"
			else
				drawNativeNotification("~r~No one nearby to pasan!")
			end
		else
			drawNativeNotification("~r~No one nearby to pasan!")
		end
	else
		pasan.InProgress = false
		ClearPedSecondaryTask(PlayerPedId())
		DetachEntity(PlayerPedId(), true, false)
		TriggerServerEvent("Pasan:stop",pasan.targetSrc)
		pasan.targetSrc = 0
	end
end,false)

RegisterNetEvent("Pasan:syncTarget")
AddEventHandler("Pasan:syncTarget", function(targetSrc)
	local playerPed = PlayerPedId()
	local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
	pasan.InProgress = true
	ensureAnimDict(pasan.personBeingPasaned.animDict)
	AttachEntityToEntity(PlayerPedId(), targetPed, 0, pasan.personBeingPasaned.attachX, pasan.personBeingPasaned.attachY, pasan.personBeingPasaned.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
	pasan.type = "beingPasaned"
end)

RegisterNetEvent("Pasan:cl_stop")
AddEventHandler("Pasan:cl_stop", function()
	pasan.InProgress = false
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
end)

Citizen.CreateThread(function()
	while true do
		if pasan.InProgress then
			if pasan.type == "beingPasaned" then
				if not IsEntityPlayingAnim(PlayerPedId(), pasan.personBeingPasaned.animDict, pasan.personBeingPasaned.anim, 3) then
					TaskPlayAnim(PlayerPedId(), pasan.personBeingPasaned.animDict, pasan.personBeingPasaned.anim, 8.0, -8.0, 100000, pasan.personBeingPasaned.flag, 0, false, false, false)
				end
			elseif pasan.type == "pasaning" then
				if not IsEntityPlayingAnim(PlayerPedId(), pasan.personPasaning.animDict, pasan.personPasaning.anim, 3) then
					TaskPlayAnim(PlayerPedId(), pasan.personPasaning.animDict, pasan.personPasaning.anim, 8.0, -8.0, 100000, pasan.personPasaning.flag, 0, false, false, false)
				end
			end
		end
		Wait(0)
	end
end)