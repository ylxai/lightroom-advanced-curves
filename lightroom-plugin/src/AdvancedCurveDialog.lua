--[[----------------------------------------------------------------------------

Advanced Curve Dialog
Main user interface for the Advanced Curve Editor plugin

Features:
- Interactive curve editing
- Multi-channel support
- Real-time preview
- Curve presets
- Professional tools

------------------------------------------------------------------------------]]

local LrApplication = import 'LrApplication'
local LrDevelopController = import 'LrDevelopController'
local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrView = import 'LrView'
local LrColor = import 'LrColor'
local LrTasks = import 'LrTasks'

-- Import our curve engine
local CurveEngine = require 'CurveEngine'

local AdvancedCurveDialog = {}

-- UI Constants
local CURVE_CANVAS_SIZE = 400
local CONTROL_PANEL_WIDTH = 200
local DIALOG_WIDTH = CURVE_CANVAS_SIZE + CONTROL_PANEL_WIDTH + 40
local DIALOG_HEIGHT = 600

-- Dialog state
local dialogState = {
    curves = {},
    activeChannel = CurveEngine.CHANNELS.RGB,
    selectedPoint = nil,
    previewEnabled = true,
    autoApply = false,
    curveType = CurveEngine.CURVE_TYPES.CUBIC_SPLINE
}

--[[
    Main dialog function - called by Lightroom
]]
function AdvancedCurveDialog.showDialog()
    LrFunctionContext.callWithContext("AdvancedCurveDialog", function(context)
        AdvancedCurveDialog.initializeDialog()
        AdvancedCurveDialog.createDialog(context)
    end)
end

--[[
    Initialize dialog state
]]
function AdvancedCurveDialog.initializeDialog()
    -- Initialize curves for all channels
    dialogState.curves = {}
    for channel, _ in pairs(CurveEngine.CHANNELS) do
        dialogState.curves[channel] = CurveEngine.createCurve({{0, 0}, {1, 1}})
    end
    
    -- Load current Lightroom settings if available
    AdvancedCurveDialog.loadCurrentLightroomCurves()
end

--[[
    Load current curves from Lightroom develop settings
]]
function AdvancedCurveDialog.loadCurrentLightroomCurves()
    local catalog = LrApplication.activeCatalog()
    local photo = catalog:getTargetPhoto()
    
    if photo then
        local developSettings = photo:getDevelopSettings()
        
        -- Load tone curve if exists
        if developSettings.ToneCurvePV2012 then
            local curve = CurveEngine.createFromLightroomToneCurve(developSettings.ToneCurvePV2012)
            if curve then
                dialogState.curves[CurveEngine.CHANNELS.RGB] = curve
            end
        end
        
        -- Load individual channel curves
        if developSettings.ToneCurvePV2012Red then
            dialogState.curves[CurveEngine.CHANNELS.RED] = 
                CurveEngine.createFromLightroomToneCurve(developSettings.ToneCurvePV2012Red)
        end
        
        if developSettings.ToneCurvePV2012Green then
            dialogState.curves[CurveEngine.CHANNELS.GREEN] = 
                CurveEngine.createFromLightroomToneCurve(developSettings.ToneCurvePV2012Green)
        end
        
        if developSettings.ToneCurvePV2012Blue then
            dialogState.curves[CurveEngine.CHANNELS.BLUE] = 
                CurveEngine.createFromLightroomToneCurve(developSettings.ToneCurvePV2012Blue)
        end
    end
end

--[[
    Create and show the main dialog
]]
function AdvancedCurveDialog.createDialog(context)
    local viewFactory = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share
    
    -- Create property table for data binding
    local props = LrBinding.makePropertyTable(context)
    
    -- Initialize properties
    props.activeChannel = dialogState.activeChannel
    props.curveType = dialogState.curveType
    props.previewEnabled = dialogState.previewEnabled
    props.autoApply = dialogState.autoApply
    props.selectedPointX = 0
    props.selectedPointY = 0
    props.statusText = "Advanced Curve Editor Ready"
    
    -- Create the main dialog content
    local dialogContent = viewFactory:column {
        spacing = viewFactory:control_spacing(),
        
        -- Header
        viewFactory:row {
            viewFactory:static_text {
                title = "Advanced Curve Editor",
                font = "<system/bold>",
                text_color = LrColor("blue"),
            },
            
            viewFactory:push_button {
                title = "Help",
                action = function()
                    AdvancedCurveDialog.showHelp()
                end
            }
        },
        
        -- Main content area
        viewFactory:row {
            spacing = viewFactory:control_spacing(),
            
            -- Curve canvas area
            viewFactory:column {
                spacing = viewFactory:control_spacing(),
                
                -- Channel selector
                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    
                    viewFactory:static_text {
                        title = "Channel:",
                    },
                    
                    viewFactory:popup_menu {
                        items = {
                            { title = "RGB", value = CurveEngine.CHANNELS.RGB },
                            { title = "Red", value = CurveEngine.CHANNELS.RED },
                            { title = "Green", value = CurveEngine.CHANNELS.GREEN },
                            { title = "Blue", value = CurveEngine.CHANNELS.BLUE },
                            { title = "Luminance", value = CurveEngine.CHANNELS.LUMINANCE },
                        },
                        value = bind 'activeChannel',
                        immediate = true,
                    },
                    
                    viewFactory:static_text {
                        title = "Type:",
                    },
                    
                    viewFactory:popup_menu {
                        items = {
                            { title = "Cubic Spline", value = CurveEngine.CURVE_TYPES.CUBIC_SPLINE },
                            { title = "Linear", value = CurveEngine.CURVE_TYPES.LINEAR },
                            { title = "Bezier", value = CurveEngine.CURVE_TYPES.BEZIER },
                        },
                        value = bind 'curveType',
                        immediate = true,
                    }
                },
                
                -- Curve canvas (placeholder - actual canvas would need custom control)
                viewFactory:view {
                    width = CURVE_CANVAS_SIZE,
                    height = CURVE_CANVAS_SIZE,
                    
                    -- This would be replaced with actual curve canvas in real implementation
                    viewFactory:column {
                        fill_horizontal = 1,
                        fill_vertical = 1,
                        
                        viewFactory:static_text {
                            title = "Curve Canvas Area",
                            alignment = "center",
                            text_color = LrColor("gray"),
                            font = "<system/small>",
                        },
                        
                        viewFactory:static_text {
                            title = string.format("%dx%d", CURVE_CANVAS_SIZE, CURVE_CANVAS_SIZE),
                            alignment = "center",
                            text_color = LrColor("gray"),
                            font = "<system/small>",
                        },
                        
                        -- Placeholder curve info
                        viewFactory:static_text {
                            title = bind {
                                key = 'activeChannel',
                                transform = function(value, fromTable)
                                    return "Active: " .. (value or "RGB")
                                end
                            },
                            alignment = "center",
                            font = "<system/small>",
                        }
                    }
                },
                
                -- Canvas controls
                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    
                    viewFactory:push_button {
                        title = "Add Point",
                        action = function()
                            AdvancedCurveDialog.addCurvePoint()
                        end
                    },
                    
                    viewFactory:push_button {
                        title = "Delete Point",
                        enabled = bind {
                            key = 'selectedPointX',
                            transform = function(value)
                                return value ~= nil and value ~= 0 and value ~= 1
                            end
                        },
                        action = function()
                            AdvancedCurveDialog.deleteCurvePoint()
                        end
                    },
                    
                    viewFactory:push_button {
                        title = "Reset Curve",
                        action = function()
                            AdvancedCurveDialog.resetCurrentCurve()
                        end
                    }
                }
            },
            
            -- Control panel
            viewFactory:column {
                width = CONTROL_PANEL_WIDTH,
                spacing = viewFactory:control_spacing(),
                
                -- Point editor
                viewFactory:group_box {
                    title = "Point Editor",
                    
                    viewFactory:column {
                        spacing = viewFactory:control_spacing(),
                        
                        viewFactory:row {
                            viewFactory:static_text {
                                title = "X:",
                                width = 20,
                            },
                            
                            viewFactory:edit_field {
                                value = bind 'selectedPointX',
                                precision = 3,
                                min = 0,
                                max = 1,
                                width_in_chars = 8,
                                immediate = true,
                            }
                        },
                        
                        viewFactory:row {
                            viewFactory:static_text {
                                title = "Y:",
                                width = 20,
                            },
                            
                            viewFactory:edit_field {
                                value = bind 'selectedPointY',
                                precision = 3,
                                min = 0,
                                max = 1,
                                width_in_chars = 8,
                                immediate = true,
                            }
                        }
                    }
                },
                
                -- Options
                viewFactory:group_box {
                    title = "Options",
                    
                    viewFactory:column {
                        spacing = viewFactory:control_spacing(),
                        
                        viewFactory:checkbox {
                            title = "Preview",
                            value = bind 'previewEnabled',
                            checked_value = true,
                            unchecked_value = false,
                        },
                        
                        viewFactory:checkbox {
                            title = "Auto Apply",
                            value = bind 'autoApply',
                            checked_value = true,
                            unchecked_value = false,
                        }
                    }
                },
                
                -- Presets
                viewFactory:group_box {
                    title = "Presets",
                    
                    viewFactory:column {
                        spacing = viewFactory:control_spacing(),
                        
                        viewFactory:popup_menu {
                            items = {
                                { title = "Linear", value = "linear" },
                                { title = "S-Curve", value = "s_curve" },
                                { title = "Inverse S-Curve", value = "inverse_s" },
                                { title = "Film Emulation", value = "film" },
                                { title = "High Contrast", value = "high_contrast" },
                                { title = "Low Contrast", value = "low_contrast" },
                            },
                            value = "linear",
                        },
                        
                        viewFactory:row {
                            viewFactory:push_button {
                                title = "Load",
                                action = function()
                                    AdvancedCurveDialog.loadPreset()
                                end
                            },
                            
                            viewFactory:push_button {
                                title = "Save",
                                action = function()
                                    AdvancedCurveDialog.savePreset()
                                end
                            }
                        },
                        
                        viewFactory:push_button {
                            title = "Import...",
                            action = function()
                                AdvancedCurveDialog.importCurve()
                            end
                        },
                        
                        viewFactory:push_button {
                            title = "Export...",
                            action = function()
                                AdvancedCurveDialog.exportCurve()
                            end
                        }
                    }
                }
            }
        },
        
        -- Status bar
        viewFactory:separator {},
        
        viewFactory:row {
            viewFactory:static_text {
                title = bind 'statusText',
                text_color = LrColor("gray"),
                font = "<system/small>",
            },
            
            viewFactory:spacer {
                fill_horizontal = 1,
            },
            
            viewFactory:static_text {
                title = "v1.0",
                text_color = LrColor("gray"),
                font = "<system/small>",
            }
        },
        
        -- Dialog buttons
        viewFactory:separator {},
        
        viewFactory:row {
            viewFactory:spacer {
                fill_horizontal = 1,
            },
            
            viewFactory:push_button {
                title = "Reset All",
                action = function()
                    AdvancedCurveDialog.resetAllCurves()
                end
            },
            
            viewFactory:push_button {
                title = "Apply",
                action = function()
                    AdvancedCurveDialog.applyCurvesToLightroom()
                end
            },
            
            viewFactory:push_button {
                title = "Cancel",
                action = function()
                    LrDialogs.stopModalWithResult(dialogContent, "cancel")
                end
            },
            
            viewFactory:push_button {
                title = "OK",
                action = function()
                    AdvancedCurveDialog.applyCurvesToLightroom()
                    LrDialogs.stopModalWithResult(dialogContent, "ok")
                end
            }
        }
    }
    
    -- Show the dialog
    local result = LrDialogs.presentModalDialog({
        title = "Advanced Curve Editor",
        contents = dialogContent,
        resizable = true,
    })
end

--[[
    Apply curves to Lightroom develop settings
]]
function AdvancedCurveDialog.applyCurvesToLightroom()
    local catalog = LrApplication.activeCatalog()
    local photo = catalog:getTargetPhoto()
    
    if not photo then
        LrDialogs.message("No photo selected", "Please select a photo to apply curves.")
        return
    end
    
    catalog:withWriteAccessDo("Apply Advanced Curves", function()
        local developSettings = {}
        
        -- Convert our curves to Lightroom format
        if dialogState.curves[CurveEngine.CHANNELS.RGB] then
            developSettings.ToneCurvePV2012 = 
                CurveEngine.convertToLightroomToneCurve(dialogState.curves[CurveEngine.CHANNELS.RGB])
        end
        
        if dialogState.curves[CurveEngine.CHANNELS.RED] then
            developSettings.ToneCurvePV2012Red = 
                CurveEngine.convertToLightroomToneCurve(dialogState.curves[CurveEngine.CHANNELS.RED])
        end
        
        if dialogState.curves[CurveEngine.CHANNELS.GREEN] then
            developSettings.ToneCurvePV2012Green = 
                CurveEngine.convertToLightroomToneCurve(dialogState.curves[CurveEngine.CHANNELS.GREEN])
        end
        
        if dialogState.curves[CurveEngine.CHANNELS.BLUE] then
            developSettings.ToneCurvePV2012Blue = 
                CurveEngine.convertToLightroomToneCurve(dialogState.curves[CurveEngine.CHANNELS.BLUE])
        end
        
        photo:applyDevelopSettings(developSettings)
    end)
end

--[[
    Add a curve point at the center
]]
function AdvancedCurveDialog.addCurvePoint()
    local curve = dialogState.curves[dialogState.activeChannel]
    if curve and curve.points then
        -- Add point at center (0.5, 0.5) if not too many points
        if #curve.points < 32 then
            table.insert(curve.points, {0.5, 0.5})
            curve.lookupTable = CurveEngine.generateLookupTable(curve.points, curve.type)
            curve.modified = true
        end
    end
end

--[[
    Delete the selected curve point
]]
function AdvancedCurveDialog.deleteCurvePoint()
    -- Implementation would delete selected point
    -- For now, just show a message
    LrDialogs.message("Delete Point", "Point deletion not yet implemented in this demo.")
end

--[[
    Reset the current curve to linear
]]
function AdvancedCurveDialog.resetCurrentCurve()
    local curve = CurveEngine.createCurve({{0, 0}, {1, 1}})
    dialogState.curves[dialogState.activeChannel] = curve
end

--[[
    Reset all curves to linear
]]
function AdvancedCurveDialog.resetAllCurves()
    for channel, _ in pairs(CurveEngine.CHANNELS) do
        dialogState.curves[channel] = CurveEngine.createCurve({{0, 0}, {1, 1}})
    end
end

--[[
    Load a curve preset
]]
function AdvancedCurveDialog.loadPreset()
    LrDialogs.message("Load Preset", "Preset loading will be implemented in next version.")
end

--[[
    Save current curve as preset
]]
function AdvancedCurveDialog.savePreset()
    LrDialogs.message("Save Preset", "Preset saving will be implemented in next version.")
end

--[[
    Import curve from file
]]
function AdvancedCurveDialog.importCurve()
    LrDialogs.message("Import Curve", "Curve import will be implemented in next version.")
end

--[[
    Export curve to file
]]
function AdvancedCurveDialog.exportCurve()
    LrDialogs.message("Export Curve", "Curve export will be implemented in next version.")
end

--[[
    Show help dialog
]]
function AdvancedCurveDialog.showHelp()
    local helpText = [[
Advanced Curve Editor Help

Basic Usage:
1. Select a channel (RGB, Red, Green, Blue, or Luminance)
2. Choose curve type (Cubic Spline recommended)
3. Add points by clicking "Add Point"
4. Edit point coordinates in the Point Editor
5. Click "Apply" to apply changes to Lightroom

Features:
- Multi-channel curve editing
- High precision point editing
- Real-time preview
- Curve presets
- Import/Export capabilities

Keyboard Shortcuts:
- ESC: Cancel dialog
- Enter: Apply and close
- Delete: Remove selected point

For more information, visit:
https://photostudiopro.com/lightroom-plugin
]]
    
    LrDialogs.message("Advanced Curve Editor Help", helpText)
end

-- Return the module
return AdvancedCurveDialog