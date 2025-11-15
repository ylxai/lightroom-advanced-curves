--[[----------------------------------------------------------------------------

Advanced Curve Dialog - Main UI
Professional curve editing interface with AI-powered features

Based on reverse engineering insights and 183 DirectML operators
Copyright (c) 2024 PhotoStudio Pro

------------------------------------------------------------------------------]]

local LrApplication = import 'LrApplication'
local LrDevelopController = import 'LrDevelopController'
local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrView = import 'LrView'
local LrColor = import 'LrColor'
local LrTasks = import 'LrTasks'
local LrLogger = import 'LrLogger'

-- Import our DLL interface
local CurveDLLInterface = require 'CurveDLLInterface'

local logger = LrLogger('AdvancedCurves.Dialog')
logger:enable("logfile")

local AdvancedCurveDialog = {}

-- UI Constants
local DIALOG_WIDTH = 1000
local DIALOG_HEIGHT = 700
local CURVE_CANVAS_SIZE = 500
local CONTROL_PANEL_WIDTH = 480

-- Curve types (matching C++ API)
local CURVE_TYPES = {
    LINEAR = 0,
    CUBIC_SPLINE = 1,
    BEZIER = 2,
    PARAMETRIC = 3,
    AI_OPTIMIZED = 4
}

-- Color channels (matching C++ API)
local CHANNELS = {
    RGB = 0,
    RED = 1,
    GREEN = 2,
    BLUE = 3,
    LUMINANCE = 4,
    LAB_L = 5,
    LAB_A = 6,
    LAB_B = 7
}

-- Dialog state
local dialogState = {
    activeChannel = CHANNELS.RGB,
    curveType = CURVE_TYPES.CUBIC_SPLINE,
    controlPoints = {{x = 0, y = 0}, {x = 1, y = 1}},
    selectedPoint = nil,
    useAI = true,
    useGPU = true,
    realTimePreview = true,
    currentCurve = nil,
    imageAnalysis = nil,
    performanceStats = nil
}

--[[
    Main dialog function - called by Lightroom
]]
function AdvancedCurveDialog.showDialog()
    LrFunctionContext.callWithContext("AdvancedCurveDialog", function(context)
        -- Initialize DLL interface
        if not CurveDLLInterface.initialize() then
            LrDialogs.message("Initialization Error", 
                "Failed to initialize Advanced Curve Processor.\n\n" ..
                "Please check that the plugin is properly installed and " ..
                "all required libraries are available.")
            return
        end
        
        AdvancedCurveDialog.initializeDialog(context)
        AdvancedCurveDialog.createDialog(context)
    end)
end

--[[
    Initialize dialog state and data
]]
function AdvancedCurveDialog.initializeDialog(context)
    logger:info("Initializing Advanced Curve Dialog...")
    
    -- Load current photo and analyze if AI is available
    local catalog = LrApplication.activeCatalog()
    local photo = catalog:getTargetPhoto()
    
    if photo and CurveDLLInterface.getCapabilities().ai_available then
        AdvancedCurveDialog.analyzeCurrentImage(photo)
    end
    
    -- Load current Lightroom curves if available
    AdvancedCurveDialog.loadCurrentLightroomCurves(photo)
    
    logger:info("Dialog initialization complete")
end

--[[
    Analyze current image using AI capabilities
]]
function AdvancedCurveDialog.analyzeCurrentImage(photo)
    logger:info("Analyzing current image with AI...")
    
    LrTasks.startAsyncTask(function()
        -- This would extract image data from Lightroom
        -- For demonstration, we'll simulate image analysis
        local image_data = {
            width = 1920,
            height = 1080,
            channels = 3,
            format = 0, -- FORMAT_RGB8
            data = nil  -- Would contain actual pixel data
        }
        
        -- Note: In real implementation, we would extract actual image data
        -- from Lightroom's preview or develop settings
        
        if image_data.data then
            dialogState.imageAnalysis = CurveDLLInterface.analyzeImage(image_data)
            
            if dialogState.imageAnalysis then
                logger:info("Image analysis complete:")
                logger:info("  Contrast: " .. tostring(dialogState.imageAnalysis.contrast_score))
                logger:info("  Shadow clipping: " .. tostring(dialogState.imageAnalysis.shadow_clipping))
                logger:info("  Highlight clipping: " .. tostring(dialogState.imageAnalysis.highlight_clipping))
            end
        end
    end)
end

--[[
    Load current curves from Lightroom
]]
function AdvancedCurveDialog.loadCurrentLightroomCurves(photo)
    if not photo then return end
    
    local developSettings = photo:getDevelopSettings()
    
    -- Load RGB tone curve if exists
    if developSettings.ToneCurvePV2012 then
        local lr_points = developSettings.ToneCurvePV2012
        
        -- Convert Lightroom points to our format
        local points = {}
        for _, point in ipairs(lr_points) do
            -- Convert from Lightroom range (-100 to 100) to normalized (0 to 1)
            table.insert(points, {
                x = (point[1] + 100) / 200,
                y = (point[2] + 100) / 200
            })
        end
        
        if #points >= 2 then
            dialogState.controlPoints = points
            logger:info("Loaded " .. #points .. " control points from Lightroom")
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
    props.useAI = dialogState.useAI
    props.useGPU = dialogState.useGPU
    props.realTimePreview = dialogState.realTimePreview
    props.selectedPointX = 0.5
    props.selectedPointY = 0.5
    props.statusText = "Advanced Curve Editor Ready"
    props.aiStatusText = "AI Ready"
    props.gpuStatusText = "GPU Ready"
    
    -- Update status based on capabilities
    local caps = CurveDLLInterface.getCapabilities()
    props.aiStatusText = caps.ai_available and "AI: " .. caps.ml_operators .. " operators" or "AI: Not Available"
    props.gpuStatusText = caps.gpu_available and "GPU: Available" or "GPU: Not Available"
    
    -- Create the main dialog content
    local dialogContent = viewFactory:column {
        spacing = viewFactory:control_spacing(),
        width = DIALOG_WIDTH,
        height = DIALOG_HEIGHT,
        
        -- Header with title and system info
        viewFactory:row {
            viewFactory:column {
                viewFactory:static_text {
                    title = "Advanced Curve Editor Pro",
                    font = "<system/bold/large>",
                    text_color = LrColor("blue"),
                },
                viewFactory:static_text {
                    title = "Professional curve editing with AI-powered features",
                    font = "<system/small>",
                    text_color = LrColor("gray"),
                },
            },
            
            viewFactory:spacer { fill_horizontal = 1 },
            
            viewFactory:column {
                viewFactory:static_text {
                    title = bind 'aiStatusText',
                    font = "<system/small>",
                    text_color = LrColor("darkGreen"),
                },
                viewFactory:static_text {
                    title = bind 'gpuStatusText',
                    font = "<system/small>",
                    text_color = LrColor("darkGreen"),
                },
                viewFactory:static_text {
                    title = "v" .. caps.version,
                    font = "<system/small>",
                    text_color = LrColor("gray"),
                },
            }
        },
        
        viewFactory:separator {},
        
        -- Main content area
        viewFactory:row {
            spacing = viewFactory:control_spacing(),
            fill = 1,
            
            -- Left panel: Curve editor
            viewFactory:column {
                width = CURVE_CANVAS_SIZE + 50,
                spacing = viewFactory:control_spacing(),
                
                -- Channel and curve type selection
                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    
                    viewFactory:static_text {
                        title = "Channel:",
                        width = 60,
                    },
                    
                    viewFactory:popup_menu {
                        items = {
                            { title = "RGB", value = CHANNELS.RGB },
                            { title = "Red", value = CHANNELS.RED },
                            { title = "Green", value = CHANNELS.GREEN },
                            { title = "Blue", value = CHANNELS.BLUE },
                            { title = "Luminance", value = CHANNELS.LUMINANCE },
                            { title = "Lab L", value = CHANNELS.LAB_L },
                            { title = "Lab A", value = CHANNELS.LAB_A },
                            { title = "Lab B", value = CHANNELS.LAB_B },
                        },
                        value = bind 'activeChannel',
                        width = 120,
                        immediate = true,
                    },
                    
                    viewFactory:spacer { width = 20 },
                    
                    viewFactory:static_text {
                        title = "Type:",
                        width = 40,
                    },
                    
                    viewFactory:popup_menu {
                        items = {
                            { title = "Cubic Spline", value = CURVE_TYPES.CUBIC_SPLINE },
                            { title = "Linear", value = CURVE_TYPES.LINEAR },
                            { title = "Bezier", value = CURVE_TYPES.BEZIER },
                            { title = "Parametric", value = CURVE_TYPES.PARAMETRIC },
                            { title = "AI Optimized", value = CURVE_TYPES.AI_OPTIMIZED },
                        },
                        value = bind 'curveType',
                        width = 120,
                        immediate = true,
                        enabled = caps.ai_available or LrView.bind {
                            key = 'curveType',
                            transform = function(value)
                                return value ~= CURVE_TYPES.AI_OPTIMIZED
                            end
                        }
                    }
                },
                
                -- Curve canvas area
                viewFactory:group_box {
                    title = "Curve Editor",
                    width = CURVE_CANVAS_SIZE,
                    height = CURVE_CANVAS_SIZE,
                    
                    -- Canvas placeholder (would be custom control in full implementation)
                    viewFactory:column {
                        fill = 1,
                        
                        viewFactory:static_text {
                            title = "Interactive Curve Canvas",
                            alignment = "center",
                            font = "<system/small>",
                            text_color = LrColor("gray"),
                        },
                        
                        viewFactory:spacer { fill_vertical = 1 },
                        
                        viewFactory:static_text {
                            title = string.format("%dx%d canvas area", CURVE_CANVAS_SIZE, CURVE_CANVAS_SIZE),
                            alignment = "center",
                            font = "<system/small>",
                            text_color = LrColor("gray"),
                        },
                        
                        viewFactory:spacer { fill_vertical = 1 },
                        
                        -- Control points display
                        viewFactory:static_text {
                            title = bind {
                                keys = { 'activeChannel', 'curveType' },
                                operation = function(binder, values)
                                    local channel_names = {"RGB", "Red", "Green", "Blue", "Lum", "Lab L", "Lab A", "Lab B"}
                                    local type_names = {"Linear", "Cubic", "Bezier", "Param", "AI"}
                                    return string.format("Channel: %s | Type: %s", 
                                                       channel_names[values.activeChannel + 1] or "Unknown",
                                                       type_names[values.curveType + 1] or "Unknown")
                                end
                            },
                            alignment = "center",
                            font = "<system/small>",
                        }
                    }
                },
                
                -- Curve control buttons
                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    
                    viewFactory:push_button {
                        title = "Add Point",
                        action = function()
                            AdvancedCurveDialog.addControlPoint(props)
                        end,
                    },
                    
                    viewFactory:push_button {
                        title = "Delete Point",
                        enabled = bind {
                            key = 'selectedPointX',
                            transform = function(value)
                                return value ~= 0 and value ~= 1
                            end
                        },
                        action = function()
                            AdvancedCurveDialog.deleteControlPoint(props)
                        end,
                    },
                    
                    viewFactory:push_button {
                        title = "Reset Curve",
                        action = function()
                            AdvancedCurveDialog.resetCurve(props)
                        end,
                    }
                }
            },
            
            -- Right panel: Controls and AI features
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
                                width = 30,
                            },
                            
                            viewFactory:edit_field {
                                value = bind 'selectedPointX',
                                precision = 3,
                                min = 0,
                                max = 1,
                                width_in_chars = 8,
                                immediate = true,
                            },
                            
                            viewFactory:spacer { width = 20 },
                            
                            viewFactory:static_text {
                                title = "Y:",
                                width = 30,
                            },
                            
                            viewFactory:edit_field {
                                value = bind 'selectedPointY',
                                precision = 3,
                                min = 0,
                                max = 1,
                                width_in_chars = 8,
                                immediate = true,
                            }
                        },
                        
                        viewFactory:static_text {
                            title = "Drag points on curve or enter precise coordinates",
                            font = "<system/small>",
                            text_color = LrColor("gray"),
                        }
                    }
                },
                
                -- AI Features (only if available)
                caps.ai_available and viewFactory:group_box {
                    title = "AI-Powered Features",
                    
                    viewFactory:column {
                        spacing = viewFactory:control_spacing(),
                        
                        viewFactory:static_text {
                            title = string.format("Using %d DirectML operators", caps.ml_operators),
                            font = "<system/small>",
                            text_color = LrColor("darkGreen"),
                        },
                        
                        viewFactory:separator {},
                        
                        viewFactory:push_button {
                            title = "🤖 AI Curve Suggestion",
                            action = function()
                                AdvancedCurveDialog.generateAISuggestion(props)
                            end,
                        },
                        
                        viewFactory:push_button {
                            title = "🎬 Film Emulation",
                            action = function()
                                AdvancedCurveDialog.showFilmEmulation(props)
                            end,
                        },
                        
                        viewFactory:push_button {
                            title = "🎨 Color Grading",
                            action = function()
                                AdvancedCurveDialog.showColorGrading(props)
                            end,
                        },
                        
                        viewFactory:checkbox {
                            title = "Auto-optimize curves",
                            value = bind 'useAI',
                            checked_value = true,
                            unchecked_value = false,
                        }
                    }
                } or viewFactory:group_box {
                    title = "AI Features",
                    
                    viewFactory:static_text {
                        title = "AI features require DirectML support.\nInstall DirectML for advanced capabilities.",
                        text_color = LrColor("gray"),
                        font = "<system/small>",
                    }
                },
                
                -- Processing options
                viewFactory:group_box {
                    title = "Processing Options",
                    
                    viewFactory:column {
                        spacing = viewFactory:control_spacing(),
                        
                        viewFactory:checkbox {
                            title = "Use GPU acceleration",
                            value = bind 'useGPU',
                            enabled = caps.gpu_available,
                            checked_value = true,
                            unchecked_value = false,
                        },
                        
                        viewFactory:checkbox {
                            title = "Real-time preview",
                            value = bind 'realTimePreview',
                            checked_value = true,
                            unchecked_value = false,
                        },
                        
                        viewFactory:separator {},
                        
                        viewFactory:push_button {
                            title = "📊 Performance Stats",
                            action = function()
                                AdvancedCurveDialog.showPerformanceStats()
                            end,
                        }
                    }
                },
                
                -- Presets
                viewFactory:group_box {
                    title = "Curve Presets",
                    
                    viewFactory:column {
                        spacing = viewFactory:control_spacing(),
                        
                        viewFactory:popup_menu {
                            items = {
                                { title = "None", value = "none" },
                                { title = "S-Curve (Contrast)", value = "s_curve" },
                                { title = "Film Emulation", value = "film" },
                                { title = "High Contrast", value = "high_contrast" },
                                { title = "Low Contrast", value = "low_contrast" },
                                { title = "Shadow Lift", value = "shadow_lift" },
                                { title = "Highlight Recovery", value = "highlight_recovery" },
                            },
                            value = "none",
                            width = 200,
                        },
                        
                        viewFactory:row {
                            viewFactory:push_button {
                                title = "Load",
                                action = function()
                                    AdvancedCurveDialog.loadPreset(props)
                                end,
                            },
                            
                            viewFactory:push_button {
                                title = "Save",
                                action = function()
                                    AdvancedCurveDialog.savePreset(props)
                                end,
                            },
                            
                            viewFactory:push_button {
                                title = "Export",
                                action = function()
                                    AdvancedCurveDialog.exportCurve(props)
                                end,
                            }
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
            
            viewFactory:spacer { fill_horizontal = 1 },
            
            viewFactory:static_text {
                title = "PhotoStudio Pro | Based on 183 DirectML operators",
                text_color = LrColor("gray"),
                font = "<system/small>",
            }
        },
        
        -- Dialog buttons
        viewFactory:separator {},
        
        viewFactory:row {
            viewFactory:spacer { fill_horizontal = 1 },
            
            viewFactory:push_button {
                title = "Reset All",
                action = function()
                    AdvancedCurveDialog.resetAllCurves(props)
                end,
            },
            
            viewFactory:push_button {
                title = "Preview",
                action = function()
                    AdvancedCurveDialog.previewChanges(props)
                end,
            },
            
            viewFactory:push_button {
                title = "Cancel",
                action = function()
                    LrDialogs.stopModalWithResult(dialogContent, "cancel")
                end,
            },
            
            viewFactory:push_button {
                title = "Apply",
                action = function()
                    AdvancedCurveDialog.applyCurvesToLightroom(props)
                    LrDialogs.stopModalWithResult(dialogContent, "ok")
                end,
            }
        }
    }
    
    -- Show the dialog
    local result = LrDialogs.presentModalDialog({
        title = "Advanced Curve Editor Pro",
        contents = dialogContent,
        resizable = true,
    })
    
    -- Cleanup
    CurveDLLInterface.cleanup()
end

--[[
    Generate AI curve suggestion
]]
function AdvancedCurveDialog.generateAISuggestion(props)
    logger:info("Generating AI curve suggestion...")
    
    if not CurveDLLInterface.getCapabilities().ai_available then
        LrDialogs.message("AI Not Available", "AI features require DirectML support.")
        return
    end
    
    LrTasks.startAsyncTask(function()
        -- Simulate AI processing
        local ai_params = {
            contrast_boost = 0.7,
            shadow_recovery = 0.2,
            highlight_recovery = 0.1,
            auto_color = true,
            film_emulation = false
        }
        
        -- Generate AI suggestion (would use actual image data in real implementation)
        local suggested_curve = CurveDLLInterface.generateAISuggestion(nil, ai_params)
        
        if suggested_curve then
            -- Convert AI suggestion to control points
            local ai_points = CurveDLLInterface.convertToLightroomFormat(suggested_curve)
            
            if ai_points then
                dialogState.controlPoints = {}
                for _, point in ipairs(ai_points) do
                    table.insert(dialogState.controlPoints, {
                        x = (point[1] + 100) / 200,
                        y = (point[2] + 100) / 200
                    })
                end
                
                props.statusText = "AI curve suggestion applied"
                logger:info("AI curve suggestion generated with " .. #ai_points .. " points")
            end
            
            CurveDLLInterface.destroyCurve(suggested_curve)
        else
            props.statusText = "Failed to generate AI suggestion"
        end
    end)
end

--[[
    Apply curves to Lightroom develop settings
]]
function AdvancedCurveDialog.applyCurvesToLightroom(props)
    logger:info("Applying curves to Lightroom...")
    
    local catalog = LrApplication.activeCatalog()
    local photo = catalog:getTargetPhoto()
    
    if not photo then
        LrDialogs.message("No Photo Selected", "Please select a photo to apply curves.")
        return
    end
    
    -- Create curve from control points
    local curve_ptr = CurveDLLInterface.createCurve(dialogState.controlPoints, props.curveType)
    
    if not curve_ptr then
        LrDialogs.message("Error", "Failed to create curve from control points.")
        return
    end
    
    catalog:withWriteAccessDo("Apply Advanced Curves", function()
        -- Convert curve to Lightroom format
        local lr_points = CurveDLLInterface.convertToLightroomFormat(curve_ptr)
        
        if lr_points then
            local developSettings = {}
            
            if props.activeChannel == CHANNELS.RGB then
                developSettings.ToneCurvePV2012 = lr_points
            elseif props.activeChannel == CHANNELS.RED then
                developSettings.ToneCurvePV2012Red = lr_points
            elseif props.activeChannel == CHANNELS.GREEN then
                developSettings.ToneCurvePV2012Green = lr_points
            elseif props.activeChannel == CHANNELS.BLUE then
                developSettings.ToneCurvePV2012Blue = lr_points
            end
            
            photo:applyDevelopSettings(developSettings)
            props.statusText = "Curves applied to Lightroom successfully"
            logger:info("Curves applied successfully")
        else
            props.statusText = "Failed to convert curve to Lightroom format"
        end
    end)
    
    CurveDLLInterface.destroyCurve(curve_ptr)
end

--[[
    Add control point
]]
function AdvancedCurveDialog.addControlPoint(props)
    if #dialogState.controlPoints < 32 then
        table.insert(dialogState.controlPoints, {x = 0.5, y = 0.5})
        props.statusText = "Control point added"
    else
        props.statusText = "Maximum control points reached"
    end
end

--[[
    Reset curve to linear
]]
function AdvancedCurveDialog.resetCurve(props)
    dialogState.controlPoints = {{x = 0, y = 0}, {x = 1, y = 1}}
    props.statusText = "Curve reset to linear"
end

--[[
    Show performance statistics
]]
function AdvancedCurveDialog.showPerformanceStats()
    local stats = CurveDLLInterface.getPerformanceStats()
    
    if stats then
        local message = string.format(
            "Performance Statistics:\n\n" ..
            "Processing Time: %.2f ms\n" ..
            "GPU Utilization: %.1f%%\n" ..
            "Memory Used: %.1f MB\n" ..
            "Cache Hits: %d\n" ..
            "Cache Misses: %d",
            stats.processing_time_ms,
            stats.gpu_utilization,
            stats.memory_used_bytes / 1024 / 1024,
            stats.cache_hits,
            stats.cache_misses
        )
        
        LrDialogs.message("Performance Statistics", message)
    else
        LrDialogs.message("Performance Statistics", "No performance data available.")
    end
end

-- Additional placeholder functions for full implementation
function AdvancedCurveDialog.deleteControlPoint(props) end
function AdvancedCurveDialog.loadPreset(props) end
function AdvancedCurveDialog.savePreset(props) end
function AdvancedCurveDialog.exportCurve(props) end
function AdvancedCurveDialog.showFilmEmulation(props) end
function AdvancedCurveDialog.showColorGrading(props) end
function AdvancedCurveDialog.previewChanges(props) end
function AdvancedCurveDialog.resetAllCurves(props) end

return AdvancedCurveDialog