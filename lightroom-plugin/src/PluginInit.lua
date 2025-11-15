--[[----------------------------------------------------------------------------

Plugin Initialization
Handles plugin startup and initialization tasks

------------------------------------------------------------------------------]]

local LrLogger = import 'LrLogger'
local LrPrefs = import 'LrPrefs'

local logger = LrLogger('AdvancedCurves')
logger:enable("logfile")

--[[
    Initialize the plugin
]]
local function initPlugin()
    logger:info("Advanced Curve Editor Plugin initializing...")
    
    -- Initialize preferences with defaults
    local prefs = LrPrefs.prefsForPlugin()
    
    if prefs.curveResolution == nil then
        prefs.curveResolution = 256
    end
    
    if prefs.maxControlPoints == nil then
        prefs.maxControlPoints = 32
    end
    
    if prefs.defaultCurveType == nil then
        prefs.defaultCurveType = 'cubic_spline'
    end
    
    if prefs.enableRealTimePreview == nil then
        prefs.enableRealTimePreview = true
    end
    
    if prefs.autoSavePresets == nil then
        prefs.autoSavePresets = true
    end
    
    logger:info("Advanced Curve Editor Plugin initialized successfully")
end

-- Initialize the plugin
initPlugin()