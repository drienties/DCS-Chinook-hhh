SupportHandler = EVENTHANDLER:New()
--test
TimeOnGround = 60

InfAlias = 1

local MissionSchedule = SCHEDULER:New( nil, 
  function()
    --check chinook status
	--MessageAll = MESSAGE:New( "Check",  25):ToAll()
	for i = 1, 2, 1
	do
		local ChinookUnit = "CH_"..ReturnCoalitionName(i)
		local ChinookInf = GROUP:FindByName( ChinookUnit.." - infantry#001" )
		local ChinookFlag = GROUP:FindByName( ChinookUnit.." - flag#001" )
		
		if ChinookInf ~= nil then
			chinook = ChinookInf
		elseif ChinookFlag ~= nil then
			Chinook = ChinookFlag
		end
				
		if Chinook ~= nil then
			if Chinook ~= nil then
				CheckChinookTasks(i)
			end
		end
	end
  end, {}, 1, 10
  )

function CheckChinookTasks(coalition)
	local ChinookUnit = "CH_"..ReturnCoalitionName(coalition)
	local ChinookInf = GROUP:FindByName( ChinookUnit.." - infantry#001" )
	local ChinookFlag = GROUP:FindByName( ChinookUnit.." - flag#001" )
	
	if ChinookInf ~= nil then
		-- inf tasks
		local StartZone = "SZ_"..ReturnCoalitionName(coalition)
		local CH_Zone = ZONE:FindByName(StartZone)
		if (ChinookInf:IsNotInZone(CH_Zone) == true) and (ChinookInf:InAir() == false) then
			--MessageAll = MESSAGE:New( "Chinook Landed at LZ",  25):ToAll()
			SpawnInfantry(coalition, ChinookInf)
		elseif ChinookInf:GetFuel() < 0.99 and ChinookInf:InAir() ~= true then
			ChinookInf:ClearTasks()
			ChinookInf:Destroy()
			--SpawnChinookStatic(Side)
		end
		
	end
	
	if ChinookFlag ~= nil then
		-- flag tasks
		local StartZone = "SZ_"..ReturnCoalitionName(coalition)
		local CH_Zone = ZONE:FindByName(StartZone)
		if (ChinookFlag:IsNotInZone(CH_Zone) == true) and (ChinookFlag:InAir() == false) then
			MessageAll = MESSAGE:New( "Chinook Landed at LZ",  25):ToAll()
			if coalition == 1 then
				trigger.action.setUserFlag('100', 1)
			elseif coalition == 2 then
				trigger.action.setUserFlag('200', 1)
			end
		elseif ChinookFlag:GetFuel() < 0.99 and ChinookFlag:InAir() ~= true then
			ChinookFlag:ClearTasks()
			ChinookFlag:Destroy()
			--SpawnChinookStatic(Side)
		end
	end
	
end

function ReturnCoalitionName(coalition)
 if coalition == 1 then
	return "Red"
 elseif coalition == 2 then
	return "Blue"
 end
end

function SpawnInfantry(coalition, location)
	--MessageAll = MESSAGE:New( ReturnCoalitionName(coalition).." Chinook Unloading troops at LZ",  25):ToAll()
	InfUnit = "Inf_"..ReturnCoalitionName(coalition)
    Spawn_Inf = SPAWN:NewWithAlias(InfUnit, InfAlias)
 
    local StartLoc = location:GetVec3()
    Spawn_Inf:SpawnFromVec3( StartLoc )
	InfAlias = InfAlias + 1
	location:PopCurrentTask()
end

function SpawnChinookStatic(coalition)
	CoalitionVars(coalition)
	local UnitALias = ChinookAlias
	local Spawn_Static = SPAWNSTATIC:NewFromType("CH-47D", "Helicopters", country.id.USA )
	local CH_Zone = ZONE:FindByName(StartZone)
	Spawn_Static:SpawnFromZone(CH_Zone)
end

function SpawnChinook(coord, coalition, task)
 
	local DestLoc = coord 
	local ChinookUnit = "CH_"..ReturnCoalitionName(coalition)
	local StartZone = "SZ_"..ReturnCoalitionName(coalition)
	local ChinookAlias = ChinookUnit.." - ".. task
	
	local Spawn_Plane = SPAWN:NewWithAlias( ChinookUnit, ChinookAlias ):InitLimit( 1, 1 )
	local CH_Zone = ZONE:FindByName(StartZone)
	Spawn_Plane:SpawnInZone(CH_Zone)

	Chinook = GROUP:FindByName( ChinookAlias.."#001" )
	 
	local LandHeloLZ = Chinook:TaskLandAtVec2(DestLoc:GetVec2(),TimeOnGround) --60
	local LandHeloRTB = Chinook:TaskLandAtVec2(CH_Zone:GetVec2(),500) --500
	Chinook:OptionROTNoReaction()
	Chinook:OptionROEWeaponFree()
	Chinook:PushTask(LandHeloRTB, 1)
	Chinook:PushTask(LandHeloLZ, 1)
end


function markRemoved(Event)
    if Event.text~=nil then 
        local text = Event.text:lower()
        local vec3 = {z=Event.pos.z, x=Event.pos.x}
		local coalition = Event.coalition
        local coord = COORDINATE:NewFromVec3(vec3)
			if Event.text:lower():find("a") then
				local task = "infantry"
				SpawnChinook(coord, coalition, task)
			end
			if Event.text:lower():find("b") then
				local task = "flag"
				SpawnChinook(coord, coalition, task)
			end
    end
end

function SupportHandler:onEvent(Event)
    if Event.id == world.event.S_EVENT_MARK_ADDED then
        -- env.info(string.format("BTI: Support got event ADDED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    elseif Event.id == world.event.S_EVENT_MARK_CHANGE then
        -- env.info(string.format("BTI: Support got event CHANGE id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    elseif Event.id == world.event.S_EVENT_MARK_REMOVED then
        -- env.info(string.format("BTI: Support got event REMOVED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
        markRemoved(Event)
    end
end

world.addEventHandler(SupportHandler)
