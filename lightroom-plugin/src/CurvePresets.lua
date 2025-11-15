--[[----------------------------------------------------------------------------

Curve Presets Manager
Manage built-in and custom curve presets

------------------------------------------------------------------------------]]

local CurveEngine = require 'CurveEngine'

local CurvePresets = {}

-- Built-in presets
CurvePresets.BUILTIN_PRESETS = {
    {
        name = "Linear",
        description = "No adjustment - straight line",
        points = {{0, 0}, {1, 1}},
        type = CurveEngine.CURVE_TYPES.LINEAR,
        category = "Basic"
    },
    {
        name = "S-Curve",
        description = "Classic S-curve for increased contrast",
        points = {{0, 0}, {0.25, 0.2}, {0.75, 0.8}, {1, 1}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Contrast"
    },
    {
        name = "Inverse S-Curve",
        description = "Inverse S-curve for decreased contrast",
        points = {{0, 0}, {0.25, 0.3}, {0.75, 0.7}, {1, 1}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Contrast"
    },
    {
        name = "Film Emulation",
        description = "Classic film response curve",
        points = {{0, 0.05}, {0.18, 0.15}, {0.5, 0.5}, {0.82, 0.85}, {1, 0.95}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Film"
    },
    {
        name = "High Contrast",
        description = "Dramatic contrast enhancement",
        points = {{0, 0}, {0.2, 0.05}, {0.4, 0.3}, {0.6, 0.7}, {0.8, 0.95}, {1, 1}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Contrast"
    },
    {
        name = "Low Contrast",
        description = "Soft, flat look",
        points = {{0, 0.1}, {0.5, 0.5}, {1, 0.9}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Contrast"
    },
    {
        name = "Highlight Recovery",
        description = "Recover blown highlights",
        points = {{0, 0}, {0.7, 0.7}, {0.9, 0.8}, {1, 0.85}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Recovery"
    },
    {
        name = "Shadow Lift",
        description = "Lift shadows for detail",
        points = {{0, 0.15}, {0.1, 0.2}, {0.3, 0.3}, {1, 1}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Recovery"
    },
    {
        name = "Vintage",
        description = "Vintage film look with lifted blacks",
        points = {{0, 0.1}, {0.3, 0.25}, {0.7, 0.75}, {1, 0.95}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Film"
    },
    {
        name = "Cinematic",
        description = "Hollywood-style color grading",
        points = {{0, 0}, {0.15, 0.1}, {0.5, 0.45}, {0.85, 0.9}, {1, 1}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Cinematic"
    }
}

-- Red channel specific presets
CurvePresets.RED_CHANNEL_PRESETS = {
    {
        name = "Warm Highlights",
        description = "Add warmth to highlights",
        points = {{0, 0}, {0.7, 0.75}, {1, 1}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Color"
    },
    {
        name = "Cool Shadows",
        description = "Cool down shadow areas",
        points = {{0, 0}, {0.3, 0.25}, {1, 1}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Color"
    }
}

-- Green channel specific presets
CurvePresets.GREEN_CHANNEL_PRESETS = {
    {
        name = "Skin Tone Enhancement",
        description = "Enhance skin tones",
        points = {{0, 0}, {0.4, 0.45}, {0.7, 0.75}, {1, 1}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Portrait"
    }
}

-- Blue channel specific presets
CurvePresets.BLUE_CHANNEL_PRESETS = {
    {
        name = "Sky Enhancement",
        description = "Enhance sky blues",
        points = {{0, 0}, {0.6, 0.65}, {1, 1}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Landscape"
    },
    {
        name = "Orange Teal",
        description = "Popular orange/teal look",
        points = {{0, 0.05}, {0.5, 0.45}, {1, 0.95}},
        type = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        category = "Cinematic"
    }
}

--[[
    Get all available presets for a channel
    @param channel: Channel identifier (RGB, RED, GREEN, BLUE)
]]
function CurvePresets.getPresetsForChannel(channel)
    local presets = {}
    
    -- Always include RGB presets
    for _, preset in ipairs(CurvePresets.BUILTIN_PRESETS) do
        table.insert(presets, preset)
    end
    
    -- Add channel-specific presets
    if channel == CurveEngine.CHANNELS.RED then
        for _, preset in ipairs(CurvePresets.RED_CHANNEL_PRESETS) do
            table.insert(presets, preset)
        end
    elseif channel == CurveEngine.CHANNELS.GREEN then
        for _, preset in ipairs(CurvePresets.GREEN_CHANNEL_PRESETS) do
            table.insert(presets, preset)
        end
    elseif channel == CurveEngine.CHANNELS.BLUE then
        for _, preset in ipairs(CurvePresets.BLUE_CHANNEL_PRESETS) do
            table.insert(presets, preset)
        end
    end
    
    return presets
end

--[[
    Get preset by name
    @param name: Preset name
    @param channel: Channel (optional, defaults to RGB)
]]
function CurvePresets.getPresetByName(name, channel)
    local presets = CurvePresets.getPresetsForChannel(channel or CurveEngine.CHANNELS.RGB)
    
    for _, preset in ipairs(presets) do
        if preset.name == name then
            return preset
        end
    end
    
    return nil
end

--[[
    Create curve from preset
    @param preset: Preset object or name
    @param channel: Channel (optional)
]]
function CurvePresets.createCurveFromPreset(preset, channel)
    if type(preset) == "string" then
        preset = CurvePresets.getPresetByName(preset, channel)
    end
    
    if not preset then
        return nil
    end
    
    return CurveEngine.createCurve(preset.points, preset.type)
end

--[[
    Get presets grouped by category
    @param channel: Channel identifier
]]
function CurvePresets.getPresetsByCategory(channel)
    local presets = CurvePresets.getPresetsForChannel(channel)
    local categories = {}
    
    for _, preset in ipairs(presets) do
        local category = preset.category or "Other"
        if not categories[category] then
            categories[category] = {}
        end
        table.insert(categories[category], preset)
    end
    
    return categories
end

--[[
    Generate dropdown menu items for presets
    @param channel: Channel identifier
]]
function CurvePresets.getPresetMenuItems(channel)
    local presets = CurvePresets.getPresetsForChannel(channel)
    local items = {}
    
    -- Add "None" option
    table.insert(items, {title = "None", value = "none"})
    
    -- Group by category
    local categories = CurvePresets.getPresetsByCategory(channel)
    local sortedCategories = {}
    
    for category, _ in pairs(categories) do
        table.insert(sortedCategories, category)
    end
    table.sort(sortedCategories)
    
    for _, category in ipairs(sortedCategories) do
        -- Add separator for category
        if #items > 1 then
            table.insert(items, {title = "-", value = "separator"})
        end
        
        -- Add category header
        table.insert(items, {title = "── " .. category .. " ──", value = "header"})
        
        -- Add presets in category
        for _, preset in ipairs(categories[category]) do
            table.insert(items, {
                title = preset.name,
                value = preset.name,
                tooltip = preset.description
            })
        end
    end
    
    return items
end

--[[
    Apply multiple presets to different channels
    @param presetMap: Table mapping channel to preset name
]]
function CurvePresets.applyPresetMap(presetMap)
    local curves = {}
    
    for channel, presetName in pairs(presetMap) do
        if presetName ~= "none" then
            local curve = CurvePresets.createCurveFromPreset(presetName, channel)
            if curve then
                curves[channel] = curve
            end
        end
    end
    
    return curves
end

--[[
    Create custom preset from current curve
    @param curve: Curve object
    @param name: Preset name
    @param description: Preset description
    @param category: Preset category
]]
function CurvePresets.createCustomPreset(curve, name, description, category)
    if not curve or not curve.points or not name then
        return nil
    end
    
    return {
        name = name,
        description = description or "",
        points = curve.points,
        type = curve.type,
        category = category or "Custom",
        isCustom = true,
        created = os.date("%Y-%m-%d %H:%M:%S")
    }
end

--[[
    Save custom preset to user preferences
    @param preset: Custom preset object
]]
function CurvePresets.saveCustomPreset(preset)
    -- In a real implementation, this would save to Lightroom preferences
    -- For now, just return success
    if preset and preset.name then
        return true
    end
    return false
end

--[[
    Load custom presets from user preferences
]]
function CurvePresets.loadCustomPresets()
    -- In a real implementation, this would load from Lightroom preferences
    -- For now, return empty table
    return {}
end

--[[
    Export preset to file format
    @param preset: Preset object
]]
function CurvePresets.exportPreset(preset)
    if not preset then
        return nil
    end
    
    local exportData = {
        version = "1.0",
        name = preset.name,
        description = preset.description,
        category = preset.category,
        type = preset.type,
        points = preset.points,
        created = preset.created or os.date("%Y-%m-%d %H:%M:%S"),
        exported = os.date("%Y-%m-%d %H:%M:%S")
    }
    
    -- Simple JSON-like serialization
    local function serializeTable(t, indent)
        indent = indent or ""
        local result = "{\n"
        
        for k, v in pairs(t) do
            result = result .. indent .. "  "
            
            if type(k) == "string" then
                result = result .. '"' .. k .. '": '
            else
                result = result .. '[' .. k .. ']: '
            end
            
            if type(v) == "string" then
                result = result .. '"' .. v .. '"'
            elseif type(v) == "number" then
                result = result .. v
            elseif type(v) == "table" then
                result = result .. serializeTable(v, indent .. "  ")
            else
                result = result .. tostring(v)
            end
            
            result = result .. ",\n"
        end
        
        result = result .. indent .. "}"
        return result
    end
    
    return serializeTable(exportData)
end

--[[
    Import preset from file data
    @param data: Exported preset data string
]]
function CurvePresets.importPreset(data)
    -- In a real implementation, this would parse JSON
    -- For now, return nil
    return nil
end

return CurvePresets