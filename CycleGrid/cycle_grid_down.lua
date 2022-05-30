-- @noindex
-- User Variables
local cycleValue = -1
list = {1/16,1/8,1/4,1/2,1}

local function GetGrid()
	local retval, divisionIn, swingmodeIn, swingamtIn = reaper.GetSetProjectGrid(0, false)
	return divisionIn,swingmodeIn,swingamtIn
end

local function CycleGrid(swing1,swing2,ind)
	if ind < 1 then
		local value = list[#list]
	else
		local value = list[ind]
	end
	reaper.GetSetProjectGrid(0, true,value)
end
local index = 0
local g1,g2,g3 = GetGrid()
for i=1,#list do
	if list[i] == g1 then
		index = i
	end
end

local newindex = index + cycleValue
CycleGrid(g2,g3,newindex)
