--[[----------------------------------------------------------------------------

Advanced Curve Editor Plugin for Adobe Lightroom
Professional curve editing with AI-powered features

Based on reverse engineering insights and 183 DirectML operators
Copyright (c) 2024 PhotoStudio Pro

This plugin provides advanced curve editing capabilities that surpass
Lightroom's built-in tone curve functionality, leveraging AI and GPU acceleration.

------------------------------------------------------------------------------]]

return {
    -- Plugin Information
    LrSdkVersion = 11.0,
    LrSdkMinimumVersion = 6.0,  -- Compatible with Lightroom 6 and newer
    
    LrToolkitIdentifier = 'com.photostudiopro.advancedcurves.pro',
    LrPluginName = 'Advanced Curve Editor Pro',
    
    -- Plugin Metadata
    LrPluginInfoUrl = 'https://photostudiopro.com/lightroom-plugin',
    LrPluginInfoProvider = 'PluginInfoProvider.lua',
    LrHelpMenuItems = {
        {
            title = 'Advanced Curve Editor Help',
            file = 'help/UserGuide.html',
        },
        {
            title = 'AI Features Guide',
            file = 'help/AIFeatures.html',
        },
        {
            title = 'Performance Optimization',
            file = 'help/Performance.html',
        },
    },
    
    -- Version Information (includes reference to 183 operators)
    VERSION = { 
        major = 1, 
        minor = 0, 
        revision = 0, 
        build = 183,  -- Reference to 183 DirectML operators
        suffix = "rev183ops"
    },
    
    -- Export Service for professional workflow
    LrExportServiceProvider = {
        title = 'Advanced Curve Processing',
        file = 'AdvancedCurveExportService.lua',
        
        supportsIncrementalPublish = false,
        supportsCustomExportLocation = true,
        
        exportPresetFields = {
            { key = 'curvePreset', default = 'none' },
            { key = 'curveData', default = '' },
            { key = 'applyToChannels', default = 'rgb' },
            { key = 'useAI', default = true },
            { key = 'useGPU', default = true },
            { key = 'qualityLevel', default = 0.9 },
            { key = 'enableProfiling', default = false },
        },
        
        hideSections = { 'exportLocation' },
        allowFileFormats = { 'JPEG', 'PSD', 'TIFF', 'DNG' },
        allowColorSpaces = { 'sRGB', 'AdobeRGB', 'ProPhotoRGB' },
    },
    
    -- Library Menu Items
    LrLibraryMenuItems = {
        {
            title = 'Advanced Curve Editor Pro',
            file = 'AdvancedCurveDialog.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = '&AI Curve Suggestion',
            file = 'AICurveSuggestion.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = 'Batch Apply Curves',
            file = 'BatchCurveProcessor.lua',
            enabledWhen = 'photosSelected',
        },
        {
            title = LOC "$$$/AdvancedCurves/Menu/Separator1=–",
        },
        {
            title = 'Film Emulation Curves',
            file = 'FilmEmulationDialog.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = 'Professional Color Grading',
            file = 'ColorGradingDialog.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = LOC "$$$/AdvancedCurves/Menu/Separator2=–",
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
        {
            title = LOC "$$$/AdvancedCurves/Menu/Separator3=–",
        },
        {
            title = 'Performance Monitor',
            file = 'PerformanceMonitor.lua',
        },
        {
            title = 'System Information',
            file = 'SystemInfoDialog.lua',
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
            title = 'AI Enhance with Curves',
            file = 'AIEnhancementDialog.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = LOC "$$$/AdvancedCurves/Menu/Separator4=–",
        },
        {
            title = 'Reset All Curves',
            file = 'CurveReset.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = 'Copy Curves to Selected',
            file = 'CurveCopyDialog.lua',
            enabledWhen = 'photosSelected',
        },
    },
    
    -- File Menu Items for preferences and configuration
    LrFileMenuItems = {
        {
            title = 'Advanced Curves - Preferences',
            file = 'PreferencesDialog.lua',
        },
        {
            title = 'Advanced Curves - GPU Settings',
            file = 'GPUSettingsDialog.lua',
        },
        {
            title = 'Advanced Curves - AI Configuration',
            file = 'AIConfigDialog.lua',
        },
    },
    
    -- Metadata Provider for storing curve data
    LrMetadataProvider = 'MetadataDefinition.lua',
    
    -- Plugin Lifecycle
    LrInitPlugin = 'PluginInit.lua',
    LrShutdownPlugin = 'PluginShutdown.lua',
    
    -- Additional Export Menu Items
    LrExportMenuItems = {
        {
            title = 'Export with AI-Enhanced Curves',
            file = 'AdvancedCurveExportService.lua',
        },
        {
            title = 'Batch Export with Film Emulation',
            file = 'FilmEmulationExportService.lua',
        },
        {
            title = 'Professional Workflow Export',
            file = 'ProfessionalExportService.lua',
        },
    },
    
    -- Edit Menu Items for curve operations
    LrEditMenuItems = {
        {
            title = 'Undo Curve Changes',
            file = 'CurveUndo.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = 'Redo Curve Changes',
            file = 'CurveRedo.lua',
            enabledWhen = 'photosAvailable',
        },
    },
    
    -- View Menu Items for monitoring and debugging
    LrViewMenuItems = {
        {
            title = 'Show Curve Performance Stats',
            file = 'PerformanceStatsDialog.lua',
        },
        {
            title = 'Show AI Operator Status',
            file = 'AIOperatorStatusDialog.lua',
        },
        {
            title = 'Show GPU Utilization',
            file = 'GPUUtilizationDialog.lua',
        },
    },
    
    -- Plugin Configuration and Features
    LrPluginInfoProvider = 'PluginInfoProvider.lua',
    
    -- Enable advanced features based on system capabilities
    LrEnablePlugin = function()
        -- This function can perform runtime checks
        return true
    end,
    
    -- Plugin sections for organize functionality
    LrSections = {
        {
            title = 'Curve Processing',
            id = 'curveProcessing',
            synopsis = 'Advanced curve editing with mathematical precision',
        },
        {
            title = 'AI Enhancement',
            id = 'aiEnhancement', 
            synopsis = 'AI-powered curve suggestions using 183 DirectML operators',
        },
        {
            title = 'Professional Workflow',
            id = 'professionalWorkflow',
            synopsis = 'Professional color grading and film emulation tools',
        },
        {
            title = 'Performance Optimization',
            id = 'performanceOptimization',
            synopsis = 'GPU acceleration and real-time processing capabilities',
        },
    },
    
    -- Localization support
    LrDefaultCollectionBehavior = {
        searchAllLocalizedCatalogs = true,
    },
    
    -- Development and debugging features
    LrDebugInfo = function()
        local CurveDLLInterface = require 'CurveDLLInterface'
        
        if CurveDLLInterface.isReady() then
            local caps = CurveDLLInterface.getCapabilities()
            local stats = CurveDLLInterface.getPerformanceStats()
            
            return {
                dllVersion = caps.version,
                gpuAvailable = caps.gpu_available,
                aiAvailable = caps.ai_available,
                mlOperators = caps.ml_operators,
                lastProcessingTime = stats and stats.processing_time_ms or "N/A",
                memoryUsed = stats and stats.memory_used_bytes or 0,
            }
        else
            return {
                dllLoaded = false,
                error = "DLL not loaded or initialized"
            }
        end
    end,
    
    -- Custom properties for advanced features
    LrCustomProperties = {
        -- Enable experimental features
        enableExperimentalFeatures = {
            type = 'boolean',
            default = false,
            title = 'Enable Experimental AI Features',
        },
        
        -- GPU memory management
        gpuMemoryLimit = {
            type = 'number',
            default = 2048,  -- 2GB default limit
            min = 512,
            max = 16384,
            title = 'GPU Memory Limit (MB)',
        },
        
        -- AI processing quality
        aiProcessingQuality = {
            type = 'enum',
            default = 'high',
            values = {
                { value = 'draft', title = 'Draft (Fast)' },
                { value = 'good', title = 'Good (Balanced)' },
                { value = 'high', title = 'High (Quality)' },
                { value = 'maximum', title = 'Maximum (Slow)' },
            },
            title = 'AI Processing Quality',
        },
        
        -- Professional workflow mode
        professionalMode = {
            type = 'boolean',
            default = false,
            title = 'Enable Professional Mode',
        },
    },
    
    -- Integration with Lightroom's undo system
    LrUndo = {
        enableUndoRedo = true,
        maxUndoLevels = 50,
    },
    
    -- Performance configuration
    LrPerformance = {
        enableMultithreading = true,
        enableGPUAcceleration = true,
        enableMLAcceleration = true,
        cacheSize = '512MB',
        previewCacheSize = '256MB',
    },
    
    -- Security and privacy
    LrPrivacy = {
        collectAnonymousUsageStats = false,
        enableTelemetry = false,
        sharePreferences = false,
    },
    
    -- Advanced curve processor configuration
    LrAdvancedCurveConfig = {
        maxControlPoints = 64,
        defaultLUTSize = 4096,
        enableRealTimePreview = true,
        enableCurveSmoothing = true,
        defaultCurveType = 'cubic_spline',
        enableAIOptimization = true,
        mlOperatorCount = 183,  -- Reference to discovered operators
    },
    
    -- System requirements check
    LrSystemRequirements = {
        minimumMemory = '4GB',
        recommendedMemory = '16GB',
        supportedOS = {
            'Windows 10 64-bit',
            'Windows 11',
            'macOS 10.14+',
            'Ubuntu 18.04+',
        },
        requiredLibraries = {
            'Microsoft Visual C++ Redistributable 2019+',
            'DirectX 12 (Windows)',
            'OpenCL 1.2+ (Optional)',
        },
    },
}