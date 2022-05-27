local reaper = reaper -- Just so VSCode shuts up
local json = require "json"

MB_TITLE = "Serialize FX Params into json"
SELECTED_TRACK = nil
SELECTED_FX_NUM = nil
SELECTED_FX_NAME = nil
PARAMS_TABLE = {}
OUTPUT_PATH = reaper.GetProjectPath()
OUTPUT_FILE = nil
STATUS = true
SERIALIZED_FILE = nil

SEP = (function ()
    local os = reaper.GetOS()
    if os == "Win32" or os == "Win64" then return "\\"
    else return "/" end
end)()

local function getSelectedTrack()
    if reaper.CountSelectedTracks(0) == 0 then return false end
    SELECTED_TRACK = reaper.GetSelectedTrack(0,0)
    return true
end

local function getLastTouchedFX()
    local _, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()
    local _, fxName = reaper.TrackFX_GetFXName(SELECTED_TRACK, fxnumber)
    SELECTED_FX_NUM = fxnumber
    SELECTED_FX_NAME = string.gsub(fxName, "VST3: ", "")
    return _
end

local function getFXParamsTable()
    local numParams = reaper.TrackFX_GetNumParams(SELECTED_TRACK, SELECTED_FX_NUM)- 1
    for i = 0, numParams, 1 do
        local _, param = reaper.TrackFX_GetParamName(SELECTED_TRACK, SELECTED_FX_NUM, i)
        if not _ then
            return false
        end
        if param ~= "MIDI CC" then
          table.insert(PARAMS_TABLE, {["index"]=i, ["name"] = param})
        end
    end
    return true
end

local function serializeJson()
    OUTPUT_FILE = OUTPUT_PATH..SEP..SELECTED_FX_NAME..".json"
    local file = assert(io.open(OUTPUT_FILE, "w+"))
    SERIALIZED_FILE = json.encode(PARAMS_TABLE)
    assert(file:write(SERIALIZED_FILE))
    file:close()
    return true
end

local function run(fun, msg)
    if not fun() then
        STATUS = false
        return reaper.MB(msg, MB_TITLE, 0)
    end
end

local function checkStatus()
    local msg = (function () if STATUS then return "Success" else return "Failure" end end)()
    reaper.MB(msg, MB_TITLE, 0)
end

local function main()
    run(getSelectedTrack, "No Tracks Selected")
    run(getLastTouchedFX, "No Last Touched FX")
    run(getFXParamsTable, "Could not create Table")
    run(serializeJson, "Could not serialize Json")
    checkStatus()
end

main()
