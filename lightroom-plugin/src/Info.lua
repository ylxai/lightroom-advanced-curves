--[[----------------------------------------------------------------------------

Advanced Curve Editor Plugin for Adobe Lightroom
Copyright (c) 2024 PhotoStudio Pro

This plugin provides advanced curve editing capabilities beyond Lightroom's
built-in tone curve functionality.

------------------------------------------------------------------------------]]

return {
    -- Plugin Information
    LrSdkVersion = 11.0,
    LrSdkMinimumVersion = 6.0,  -- Compatible with Lightroom 6 and newer
    
    LrToolkitIdentifier = 'com.photostudiopro.advancedcurves',
    LrPluginName = 'Advanced Curve Editor',
    
    -- Plugin Metadata
    LrPluginInfoUrl = 'https://photostudiopro.com/lightroom-plugin',
    LrPluginInfoProvider = 'PluginInfoProvider.lua',
    
    LrHelpMenuItems = {
        {
            title = 'Advanced Curve Editor Help',
            file = 'help.html',
        },
    },
    
    -- Version Information
    VERSION = { major = 1, minor = 0, revision = 0, build = 1 },
    
    -- Export Service
    LrExportServiceProvider = {
        title = 'Advanced Curve Processing',
        file = 'AdvancedCurveExportService.lua',
        
        supportsIncrementalPublish = false,
        exportPresetFields = {
            { key = 'curvePreset', default = 'none' },
            { key = 'curveData', default = '' },
            { key = 'applyToChannels', default = 'rgb' },
        },
    },
    
    -- Library Menu Items
    LrLibraryMenuItems = {
        {
            title = 'Advanced Curve Editor',
            file = 'AdvancedCurveDialog.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = 'Batch Apply Curves',
            file = 'BatchCurveProcessor.lua',
            enabledWhen = 'photosSelected',
        },
        {
            title = 'Import Curve Preset',
            file = 'CurvePresetImporter.lua',
        },
        {
            title = 'Export Curve Preset',
            file = 'CurvePresetExporter.lua',
            enabledWhen = 'photosAvailable',
        },
    },
    
    -- Develop Menu Items  
    LrDevelopMenuItems = {
        {
            title = 'Open Advanced Curve Editor',
            file = 'AdvancedCurveDialog.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = 'Reset All Curves',
            file = 'CurveReset.lua',
            enabledWhen = 'photosAvailable',
        },
    },
    
    -- File Menu Items
    LrFileMenuItems = {
        {
            title = 'Advanced Curves - Preferences',
            file = 'PreferencesDialog.lua',
        },
    },
    
    -- Metadata Provider
    LrMetadataProvider = 'MetadataDefinition.lua',
    
    -- Plugin Initialization
    LrInitPlugin = 'PluginInit.lua',
    LrShutdownPlugin = 'PluginShutdown.lua',
    
    -- Plugin Configuration
    LrPluginInfoProvider = 'PluginInfoProvider.lua',
    LrExportMenuItems = {
        {
            title = 'Export with Advanced Curves',
            file = 'AdvancedCurveExportService.lua',
        },
    },
}