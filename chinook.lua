hhh-SupportHandler = EVENTHANDLER:New()
--test
hhh-TimeOnGround = 60

hhh-InfAlias = 1

local hhh-MissionSchedule = SCHEDULER:New( nil, 
  function()
    --check hhh-chinook status
	--MessageAll = MESSAGE:New( "Check",  25):ToAll()
	for i = 1, 2, 1
	do
		local hhh-ChinookUnit = "CH_"..hhh-ReturnCoalitionName(i)
		local hhh-ChinookInf = GROUP:FindByName( hhh-ChinookUnit.." - infantry#001" )
		local hhh-ChinookFlag = GROUP:FindByName( hhh-ChinookUnit.." - flag#001" )
		
		if hhh-ChinookInf ~= nil then
			hhh-chinook = hhh-ChinookInf
		elseif hhh-ChinookFlag ~= nil then
			hhh-chinook = hhh-ChinookFlag
		end
				
		if hhh-chinook ~= nil then
			if hhh-chinook ~= nil then
				hhh-CheckChinookTasks(i)
			end
		end
	end
  end, {}, 1, 10
  )

function hhh-CheckChinookTasks(hhh-coalition)
	local hhh-ChinookUnit = "CH_"..hhh-ReturnCoalitionName(hhh-coalition)
	local hhh-ChinookInf = GROUP:FindByName( hhh-ChinookUnit.." - infantry#001" )
	local hhh-ChinookFlag = GROUP:FindByName( hhh-ChinookUnit.." - flag#001" )
	
	if hhh-ChinookInf ~= nil then
		-- inf tasks
		local hhh-StartZone = "SZ_"..hhh-ReturnCoalitionName(hhh-coalition)
		local hhh-CH_Zone = ZONE:FindByName(hhh-StartZone)
		if (hhh-ChinookInf:IsNotInZone(hhh-CH_Zone) == true) and (hhh-ChinookInf:InAir() == false) then
			--MessageAll = MESSAGE:New( "hhh-chinook Landed at LZ",  25):ToAll()
			hhh-SpawnInfantry(hhh-coalition, hhh-ChinookInf)
		elseif hhh-ChinookInf:GetFuel() < 0.99 and hhh-ChinookInf:InAir() ~= true then
			hhh-ChinookInf:ClearTasks()
			hhh-ChinookInf:Destroy()
			--hhh-SpawnChinookStatic(Side)
		end
		
	end
	
	if hhh-ChinookFlag ~= nil then
		-- flag tasks
		local hhh-StartZone = "SZ_"..hhh-ReturnCoalitionName(hhh-coalition)
		local hhh-CH_Zone = ZONE:FindByName(hhh-StartZone)
		if (hhh-ChinookFlag:IsNotInZone(hhh-CH_Zone) == true) and (hhh-ChinookFlag:InAir() == false) then
			MessageAll = MESSAGE:New( "hhh-chinook Landed at LZ",  25):ToAll()
			if hhh-coalition == 1 then
				trigger.action.setUserFlag('100', 1)
			elseif hhh-coalition == 2 then
				trigger.action.setUserFlag('200', 1)
			end
		elseif hhh-ChinookFlag:GetFuel() < 0.99 and hhh-ChinookFlag:InAir() ~= true then
			hhh-ChinookFlag:ClearTasks()
			hhh-ChinookFlag:Destroy()
			--hhh-SpawnChinookStatic(Side)
		end
	end
	
end

function hhh-ReturnCoalitionName(hhh-coalition)
 if hhh-coalition == 1 then
	return "Red"
 elseif hhh-coalition == 2 then
	return "Blue"
 end
end

function hhh-SpawnInfantry(hhh-coalition, hhh-location)
	--MessageAll = MESSAGE:New( hhh-ReturnCoalitionName(hhh-coalition).." hhh-chinook Unloading troops at LZ",  25):ToAll()
	hhh-InfUnit = "Inf_"..hhh-ReturnCoalitionName(hhh-coalition)
    hhh-Spawn_Inf = SPAWN:NewWithAlias(hhh-InfUnit, hhh-InfAlias)
 
    local hhh-StartLoc = hhh-location:GetVec3()
    hhh-Spawn_Inf:SpawnFromVec3( hhh-StartLoc )
	hhh-InfAlias = hhh-InfAlias + 1
	hhh-location:PopCurrentTask()
end

function hhh-SpawnChinookStatic(hhh-coalition)
	CoalitionVars(hhh-coalition)
	local hhh-UnitALias = ChinookAlias
	local hhh-Spawn_Static = SPAWNSTATIC:NewFromType("CH-47D", "Helicopters", country.id.USA )
	local hhh-CH_Zone = ZONE:FindByName(hhh-StartZone)
	hhh-Spawn_Static:SpawnFromZone(hhh-CH_Zone)
end

function hhh-SpawnChinook(hhh-coord, hhh-coalition, hhh-task)
 
	local hhh-DestLoc = hhh-coord 
	local hhh-ChinookUnit = "CH_"..hhh-ReturnCoalitionName(hhh-coalition)
	local hhh-StartZone = "SZ_"..hhh-ReturnCoalitionName(hhh-coalition)
	local ChinookAlias = hhh-ChinookUnit.." - ".. hhh-task
	
	local Spawn_Plane = SPAWN:NewWithAlias( hhh-ChinookUnit, ChinookAlias ):InitLimit( 1, 1 )
	local hhh-CH_Zone = ZONE:FindByName(hhh-StartZone)
	Spawn_Plane:SpawnInZone(hhh-CH_Zone)

	hhh-chinook = GROUP:FindByName( ChinookAlias.."#001" )
	 
	local LandHeloLZ = hhh-chinook:TaskLandAtVec2(hhh-DestLoc:GetVec2(),hhh-TimeOnGround) --60
	local LandHeloRTB = hhh-chinook:TaskLandAtVec2(hhh-CH_Zone:GetVec2(),500) --500
	hhh-chinook:OptionROTNoReaction()
	hhh-chinook:OptionROEWeaponFree()
	hhh-chinook:PushTask(LandHeloRTB, 1)
	hhh-chinook:PushTask(LandHeloLZ, 1)
end


function hhh-markRemoved(hhh-Event)
    if hhh-Event.hhh-text~=nil then 
        local hhh-text = hhh-Event.hhh-text:lower()
        local hhh-vec3 = {z=hhh-Event.pos.z, x=hhh-Event.pos.x}
		local hhh-coalition = hhh-Event.hhh-coalition
        local hhh-coord = COORDINATE:NewFromVec3(hhh-vec3)
			if hhh-Event.hhh-text:lower():find("a") then
				local hhh-task = "infantry"
				hhh-SpawnChinook(hhh-coord, hhh-coalition, hhh-task)
			end
			if hhh-Event.hhh-text:lower():find("b") then
				local hhh-task = "flag"
				hhh-SpawnChinook(hhh-coord, hhh-coalition, hhh-task)
			end
    end
end

function hhh-SupportHandler:onEvent(hhh-Event)
    if hhh-Event.id == world.hhh-Event.S_EVENT_MARK_ADDED then
        -- env.info(string.format("BTI: Support got hhh-Event ADDED id %s idx %s hhh-coalition %s group %s hhh-text %s", hhh-Event.id, hhh-Event.idx, hhh-Event.hhh-coalition, hhh-Event.groupID, hhh-Event.hhh-text))
    elseif hhh-Event.id == world.hhh-Event.S_EVENT_MARK_CHANGE then
        -- env.info(string.format("BTI: Support got hhh-Event CHANGE id %s idx %s hhh-coalition %s group %s hhh-text %s", hhh-Event.id, hhh-Event.idx, hhh-Event.hhh-coalition, hhh-Event.groupID, hhh-Event.hhh-text))
    elseif hhh-Event.id == world.hhh-Event.S_EVENT_MARK_REMOVED then
        -- env.info(string.format("BTI: Support got hhh-Event REMOVED id %s idx %s hhh-coalition %s group %s hhh-text %s", hhh-Event.id, hhh-Event.idx, hhh-Event.hhh-coalition, hhh-Event.groupID, hhh-Event.hhh-text))
        hhh-markRemoved(hhh-Event)
    end
end

world.addEventHandler(hhh-SupportHandler)
