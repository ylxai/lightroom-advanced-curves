--[[----------------------------------------------------------------------------

Batch Curve Processor
Apply curves to multiple photos at once

------------------------------------------------------------------------------]]

local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrView = import 'LrView'
local LrTasks = import 'LrTasks'
local LrProgressScope = import 'LrProgressScope'

local CurveEngine = require 'CurveEngine'

local BatchCurveProcessor = {}

--[[
    Show batch processing dialog
]]
function BatchCurveProcessor.showDialog()
    LrFunctionContext.callWithContext("BatchCurveProcessor", function(context)
        BatchCurveProcessor.createDialog(context)
    end)
end

--[[
    Create batch processing dialog
]]
function BatchCurveProcessor.createDialog(context)
    local viewFactory = LrView.osFactory()
    local bind = LrView.bind
    
    local props = LrBinding.makePropertyTable(context)
    props.sourceType = 'selected'
    props.curvePreset = 'none'
    props.applyToChannels = 'rgb'
    props.overwriteExisting = false
    
    local catalog = LrApplication.activeCatalog()
    local selectedPhotos = catalog:getTargetPhotos()
    
    local dialogContent = viewFactory:column {
        spacing = viewFactory:control_spacing(),
        
        viewFactory:row {
            viewFactory:static_text {
                title = "Batch Curve Processor",
                font = "<system/bold>",
            }
        },
        
        viewFactory:group_box {
            title = "Source Photos",
            
            viewFactory:column {
                spacing = viewFactory:control_spacing(),
                
                viewFactory:radio_button {
                    title = string.format("Selected Photos (%d)", #selectedPhotos),
                    value = bind 'sourceType',
                    checked_value = 'selected',
                },
                
                viewFactory:radio_button {
                    title = "All Photos in Filmstrip",
                    value = bind 'sourceType', 
                    checked_value = 'filmstrip',
                },
                
                viewFactory:radio_button {
                    title = "Entire Catalog",
                    value = bind 'sourceType',
                    checked_value = 'catalog',
                }
            }
        },
        
        viewFactory:group_box {
            title = "Curve Settings",
            
            viewFactory:column {
                spacing = viewFactory:control_spacing(),
                
                viewFactory:row {
                    viewFactory:static_text {
                        title = "Preset:",
                    },
                    
                    viewFactory:popup_menu {
                        items = {
                            { title = "None", value = 'none' },
                            { title = "S-Curve", value = 's_curve' },
                            { title = "Film Emulation", value = 'film' },
                            { title = "High Contrast", value = 'high_contrast' },
                        },
                        value = bind 'curvePreset',
                    }
                },
                
                viewFactory:row {
                    viewFactory:static_text {
                        title = "Apply to:",
                    },
                    
                    viewFactory:popup_menu {
                        items = {
                            { title = "RGB Only", value = 'rgb' },
                            { title = "Individual Channels", value = 'individual' },
                            { title = "All Channels", value = 'all' },
                        },
                        value = bind 'applyToChannels',
                    }
                },
                
                viewFactory:checkbox {
                    title = "Overwrite existing curves",
                    value = bind 'overwriteExisting',
                }
            }
        },
        
        viewFactory:row {
            viewFactory:spacer { fill_horizontal = 1 },
            
            viewFactory:push_button {
                title = "Cancel",
                action = function()
                    LrDialogs.stopModalWithResult(dialogContent, "cancel")
                end
            },
            
            viewFactory:push_button {
                title = "Process",
                action = function()
                    BatchCurveProcessor.processBatch(props)
                    LrDialogs.stopModalWithResult(dialogContent, "ok")
                end
            }
        }
    }
    
    LrDialogs.presentModalDialog({
        title = "Batch Curve Processor",
        contents = dialogContent,
    })
end

--[[
    Process batch operation
]]
function BatchCurveProcessor.processBatch(props)
    local catalog = LrApplication.activeCatalog()
    local photos = {}
    
    -- Get photos based on source type
    if props.sourceType == 'selected' then
        photos = catalog:getTargetPhotos()
    elseif props.sourceType == 'filmstrip' then
        photos = catalog:getMultipleSelectedOrAllPhotos()
    else
        photos = catalog:getAllPhotos()
    end
    
    if #photos == 0 then
        LrDialogs.message("No Photos", "No photos found to process.")
        return
    end
    
    -- Generate curve based on preset
    local curve = BatchCurveProcessor.generateCurveFromPreset(props.curvePreset)
    if not curve then
        LrDialogs.message("Invalid Preset", "Selected preset is not available.")
        return
    end
    
    -- Process photos with progress
    LrTasks.startAsyncTask(function()
        LrProgressScope({
            title = "Processing Curves",
            functionContext = context,
        }, function(scope)
            
            scope:setPortionComplete(0, #photos)
            
            catalog:withWriteAccessDo("Batch Apply Curves", function()
                for i, photo in ipairs(photos) do
                    scope:setPortionComplete(i - 1, #photos)
                    
                    if scope:isCanceled() then
                        break
                    end
                    
                    BatchCurveProcessor.applyCurveToPhoto(photo, curve, props)
                end
            end)
            
            scope:done()
        end)
    end)
end

--[[
    Generate curve from preset name
]]
function BatchCurveProcessor.generateCurveFromPreset(presetName)
    if presetName == 's_curve' then
        return CurveEngine.createCurve({{0, 0}, {0.25, 0.2}, {0.75, 0.8}, {1, 1}})
    elseif presetName == 'film' then
        return CurveEngine.createCurve({{0, 0.05}, {0.5, 0.5}, {1, 0.95}})
    elseif presetName == 'high_contrast' then
        return CurveEngine.createCurve({{0, 0}, {0.3, 0.1}, {0.7, 0.9}, {1, 1}})
    end
    
    return nil
end

--[[
    Apply curve to a single photo
]]
function BatchCurveProcessor.applyCurveToPhoto(photo, curve, props)
    local developSettings = {}
    
    if props.applyToChannels == 'rgb' or props.applyToChannels == 'all' then
        developSettings.ToneCurvePV2012 = CurveEngine.convertToLightroomToneCurve(curve)
    end
    
    if props.applyToChannels == 'individual' or props.applyToChannels == 'all' then
        developSettings.ToneCurvePV2012Red = CurveEngine.convertToLightroomToneCurve(curve)
        developSettings.ToneCurvePV2012Green = CurveEngine.convertToLightroomToneCurve(curve)
        developSettings.ToneCurvePV2012Blue = CurveEngine.convertToLightroomToneCurve(curve)
    end
    
    photo:applyDevelopSettings(developSettings)
end

return BatchCurveProcessor