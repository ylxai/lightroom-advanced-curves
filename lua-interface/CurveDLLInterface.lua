--[[----------------------------------------------------------------------------

Advanced Curve DLL Interface
Lua bridge to C++ processing engine with DirectML support

Based on reverse engineering insights and 183 DirectML operators
Copyright (c) 2024 PhotoStudio Pro

------------------------------------------------------------------------------]]

local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'

local logger = LrLogger('AdvancedCurves.DLLInterface')
logger:enable("logfile")

local CurveDLLInterface = {}

-- DLL loading and management
local dll = nil
local dll_loaded = false
local dll_initialized = false

-- FFI interface setup
local ffi = require 'ffi'

-- Define C API interface (matching AdvancedCurveProcessor.h)
ffi.cdef[[
    // Error codes
    typedef enum {
        CURVE_SUCCESS = 0,
        CURVE_ERROR_INVALID_PARAMS = -1,
        CURVE_ERROR_OUT_OF_MEMORY = -2,
        CURVE_ERROR_NOT_INITIALIZED = -3,
        CURVE_ERROR_GPU_NOT_AVAILABLE = -4,
        CURVE_ERROR_ML_NOT_AVAILABLE = -5,
        CURVE_ERROR_UNSUPPORTED_FORMAT = -6
    } CurveResult;
    
    // Curve types
    typedef enum {
        CURVE_TYPE_LINEAR = 0,
        CURVE_TYPE_CUBIC_SPLINE = 1,
        CURVE_TYPE_BEZIER = 2,
        CURVE_TYPE_PARAMETRIC = 3,
        CURVE_TYPE_AI_OPTIMIZED = 4
    } CurveType;
    
    // Color channels
    typedef enum {
        CHANNEL_RGB = 0,
        CHANNEL_RED = 1,
        CHANNEL_GREEN = 2,
        CHANNEL_BLUE = 3,
        CHANNEL_LUMINANCE = 4,
        CHANNEL_LAB_L = 5,
        CHANNEL_LAB_A = 6,
        CHANNEL_LAB_B = 7
    } ColorChannel;
    
    // Image formats
    typedef enum {
        FORMAT_RGB8 = 0,
        FORMAT_RGBA8 = 1,
        FORMAT_RGB16 = 2,
        FORMAT_RGBA16 = 3,
        FORMAT_RGB32F = 4,
        FORMAT_RGBA32F = 5
    } ImageFormat;
    
    // Control point structure
    typedef struct {
        double x;
        double y;
    } CurvePoint;
    
    // Curve data structure
    typedef struct {
        CurvePoint* points;
        int32_t point_count;
        CurveType type;
        ColorChannel channel;
        double gamma;
        double black_point;
        double white_point;
        int32_t lut_size;
    } CurveData;
    
    // Image data structure
    typedef struct {
        void* data;
        int32_t width;
        int32_t height;
        int32_t channels;
        ImageFormat format;
        size_t stride;
    } ImageData;
    
    // Processing options
    typedef struct {
        bool use_gpu;
        bool use_ai;
        bool real_time;
        int32_t thread_count;
        double quality;
    } ProcessingOptions;
    
    // AI suggestion parameters
    typedef struct {
        double contrast_boost;
        double shadow_recovery;
        double highlight_recovery;
        bool auto_color;
        bool film_emulation;
    } AISuggestionParams;
    
    // Performance statistics
    typedef struct {
        double processing_time_ms;
        double gpu_utilization;
        size_t memory_used_bytes;
        int32_t cache_hits;
        int32_t cache_misses;
    } PerformanceStats;
    
    // Core API functions
    CurveResult curve_initialize(void);
    void curve_cleanup(void);
    const char* curve_get_version(void);
    bool curve_is_gpu_available(void);
    bool curve_is_ai_available(void);
    int32_t curve_get_ml_operator_count(void);
    
    // Curve processing functions
    CurveResult curve_create(const CurvePoint* points, int32_t point_count,
                           CurveType type, CurveData** out_curve);
    void curve_destroy(CurveData* curve);
    CurveResult curve_apply_to_image(const CurveData* curve, const ImageData* input,
                                   ImageData* output, const ProcessingOptions* options);
    CurveResult curve_generate_lut(const CurveData* curve, double** lut, int32_t* lut_size);
    
    // AI-powered features (183 DirectML operators)
    CurveResult curve_ai_suggest(const ImageData* image, const AISuggestionParams* params,
                               CurveData** suggested_curve);
    CurveResult curve_ai_analyze_image(const ImageData* image, double* contrast_score,
                                     double* shadow_clipping, double* highlight_clipping,
                                     double* color_cast);
    CurveResult curve_ai_optimize(const CurveData* input_curve, const ImageData* reference_image,
                                CurveData** optimized_curve);
    
    // Lightroom integration
    CurveResult curve_to_lightroom_format(const CurveData* curve, double** lr_points,
                                        int32_t* lr_point_count);
    CurveResult curve_from_lightroom_format(const double* lr_points, int32_t lr_point_count,
                                          CurveData** curve);
    
    // Performance monitoring
    CurveResult curve_get_performance_stats(PerformanceStats* stats);
    void curve_enable_profiling(bool enable);
]]

--[[
    Initialize DLL interface
]]
function CurveDLLInterface.initialize()
    if dll_loaded then
        return dll_initialized
    end
    
    logger:info("Initializing Advanced Curve DLL interface...")
    
    -- Determine DLL path based on platform
    local dll_name
    local plugin_path = _PLUGIN.path
    
    if WIN_ENV then
        dll_name = "AdvancedCurveProcessor.dll"
    elseif MAC_ENV then
        dll_name = "libAdvancedCurveProcessor.dylib"
    else
        dll_name = "libAdvancedCurveProcessor.so"
    end
    
    local dll_path = LrPathUtils.child(plugin_path, dll_name)
    
    -- Try alternative locations
    local possible_paths = {
        dll_path,
        LrPathUtils.child(plugin_path, "bin/" .. dll_name),
        LrPathUtils.child(plugin_path, "lib/" .. dll_name),
        LrPathUtils.child(plugin_path, "../cpp-core/build/" .. dll_name),
        dll_name  -- Try system PATH
    }
    
    local dll_found = false
    for _, path in ipairs(possible_paths) do
        if LrFileUtils.exists(path) then
            dll_path = path
            dll_found = true
            logger:info("Found DLL at: " .. path)
            break
        end
    end
    
    if not dll_found then
        logger:warn("DLL not found in any expected location")
        logger:warn("Searched paths:")
        for _, path in ipairs(possible_paths) do
            logger:warn("  " .. path)
        end
        return false
    end
    
    -- Load DLL
    local success, result = pcall(function()
        dll = ffi.load(dll_path)
        return true
    end)
    
    if not success then
        logger:error("Failed to load DLL: " .. tostring(result))
        return false
    end
    
    dll_loaded = true
    logger:info("DLL loaded successfully")
    
    -- Initialize the curve processor
    local init_result = dll.curve_initialize()
    if init_result == 0 then  -- CURVE_SUCCESS
        dll_initialized = true
        logger:info("Curve processor initialized successfully")
        
        -- Log capabilities
        local version = ffi.string(dll.curve_get_version())
        local gpu_available = dll.curve_is_gpu_available()
        local ai_available = dll.curve_is_ai_available()
        local ml_operators = dll.curve_get_ml_operator_count()
        
        logger:info("Processor version: " .. version)
        logger:info("GPU acceleration: " .. tostring(gpu_available))
        logger:info("AI features: " .. tostring(ai_available))
        logger:info("ML operators available: " .. tostring(ml_operators))
        
        return true
    else
        logger:error("Failed to initialize curve processor, error: " .. tostring(init_result))
        return false
    end
end

--[[
    Cleanup DLL resources
]]
function CurveDLLInterface.cleanup()
    if dll_initialized then
        dll.curve_cleanup()
        dll_initialized = false
        logger:info("Curve processor cleaned up")
    end
    
    dll_loaded = false
    dll = nil
end

--[[
    Check if DLL is loaded and initialized
]]
function CurveDLLInterface.isReady()
    return dll_loaded and dll_initialized
end

--[[
    Get processor capabilities
]]
function CurveDLLInterface.getCapabilities()
    if not CurveDLLInterface.isReady() then
        return {
            version = "Not available",
            gpu_available = false,
            ai_available = false,
            ml_operators = 0
        }
    end
    
    return {
        version = ffi.string(dll.curve_get_version()),
        gpu_available = dll.curve_is_gpu_available(),
        ai_available = dll.curve_is_ai_available(),
        ml_operators = dll.curve_get_ml_operator_count()
    }
end

--[[
    Create curve from control points
]]
function CurveDLLInterface.createCurve(points, curve_type)
    if not CurveDLLInterface.isReady() then
        logger:error("DLL not ready for createCurve")
        return nil
    end
    
    if not points or #points < 2 then
        logger:error("Invalid points for curve creation")
        return nil
    end
    
    -- Convert Lua table to C array
    local c_points = ffi.new("CurvePoint[?]", #points)
    for i = 1, #points do
        c_points[i-1].x = points[i].x or 0
        c_points[i-1].y = points[i].y or 0
    end
    
    -- Create curve
    local curve_ptr = ffi.new("CurveData*[1]")
    local result = dll.curve_create(c_points, #points, curve_type or 1, curve_ptr)
    
    if result == 0 then  -- CURVE_SUCCESS
        return curve_ptr[0]
    else
        logger:error("Failed to create curve, error: " .. tostring(result))
        return nil
    end
end

--[[
    Destroy curve and free memory
]]
function CurveDLLInterface.destroyCurve(curve_ptr)
    if dll and curve_ptr then
        dll.curve_destroy(curve_ptr)
    end
end

--[[
    Generate AI-suggested curve based on image analysis
    Uses DirectML operators for intelligent processing
]]
function CurveDLLInterface.generateAISuggestion(image_data, params)
    if not CurveDLLInterface.isReady() then
        logger:error("DLL not ready for AI suggestion")
        return nil
    end
    
    if not dll.curve_is_ai_available() then
        logger:warn("AI features not available, using fallback")
        return CurveDLLInterface.generateFallbackSuggestion(params)
    end
    
    -- Convert image data to C structure
    local c_image = ffi.new("ImageData")
    c_image.data = image_data.data
    c_image.width = image_data.width
    c_image.height = image_data.height
    c_image.channels = image_data.channels
    c_image.format = image_data.format or 0  -- FORMAT_RGB8
    c_image.stride = image_data.stride or (image_data.width * image_data.channels)
    
    -- Convert AI parameters
    local c_params = ffi.new("AISuggestionParams")
    c_params.contrast_boost = params.contrast_boost or 0.5
    c_params.shadow_recovery = params.shadow_recovery or 0.0
    c_params.highlight_recovery = params.highlight_recovery or 0.0
    c_params.auto_color = params.auto_color or false
    c_params.film_emulation = params.film_emulation or false
    
    -- Generate AI suggestion
    local curve_ptr = ffi.new("CurveData*[1]")
    local result = dll.curve_ai_suggest(c_image, c_params, curve_ptr)
    
    if result == 0 then  -- CURVE_SUCCESS
        logger:info("AI curve suggestion generated successfully")
        return curve_ptr[0]
    else
        logger:error("Failed to generate AI suggestion, error: " .. tostring(result))
        return CurveDLLInterface.generateFallbackSuggestion(params)
    end
end

--[[
    Analyze image characteristics using AI
    Uses DirectML operators 0-7 for comprehensive analysis
]]
function CurveDLLInterface.analyzeImage(image_data)
    if not CurveDLLInterface.isReady() then
        return nil
    end
    
    -- Convert image data
    local c_image = ffi.new("ImageData")
    c_image.data = image_data.data
    c_image.width = image_data.width
    c_image.height = image_data.height
    c_image.channels = image_data.channels
    c_image.format = image_data.format or 0
    c_image.stride = image_data.stride or (image_data.width * image_data.channels)
    
    -- Analyze image
    local contrast = ffi.new("double[1]")
    local shadow_clipping = ffi.new("double[1]")
    local highlight_clipping = ffi.new("double[1]")
    local color_cast = ffi.new("double[1]")
    
    local result = dll.curve_ai_analyze_image(c_image, contrast, 
                                            shadow_clipping, highlight_clipping, color_cast)
    
    if result == 0 then
        return {
            contrast_score = contrast[0],
            shadow_clipping = shadow_clipping[0],
            highlight_clipping = highlight_clipping[0],
            color_cast = color_cast[0]
        }
    else
        logger:error("Failed to analyze image, error: " .. tostring(result))
        return nil
    end
end

--[[
    Convert curve to Lightroom-compatible format
]]
function CurveDLLInterface.convertToLightroomFormat(curve_ptr)
    if not CurveDLLInterface.isReady() or not curve_ptr then
        return nil
    end
    
    local lr_points_ptr = ffi.new("double*[1]")
    local lr_point_count = ffi.new("int32_t[1]")
    
    local result = dll.curve_to_lightroom_format(curve_ptr, lr_points_ptr, lr_point_count)
    
    if result == 0 then
        local points = {}
        local count = lr_point_count[0]
        
        for i = 0, count - 1 do
            table.insert(points, {
                lr_points_ptr[0][i * 2],     -- x
                lr_points_ptr[0][i * 2 + 1]  -- y
            })
        end
        
        return points
    else
        logger:error("Failed to convert to Lightroom format, error: " .. tostring(result))
        return nil
    end
end

--[[
    Create curve from Lightroom tone curve data
]]
function CurveDLLInterface.createFromLightroomFormat(lr_points)
    if not CurveDLLInterface.isReady() or not lr_points then
        return nil
    end
    
    -- Convert Lightroom points to C array
    local point_count = #lr_points
    local c_points = ffi.new("double[?]", point_count * 2)
    
    for i = 1, point_count do
        c_points[(i-1) * 2] = lr_points[i][1]     -- x
        c_points[(i-1) * 2 + 1] = lr_points[i][2] -- y
    end
    
    local curve_ptr = ffi.new("CurveData*[1]")
    local result = dll.curve_from_lightroom_format(c_points, point_count, curve_ptr)
    
    if result == 0 then
        return curve_ptr[0]
    else
        logger:error("Failed to create from Lightroom format, error: " .. tostring(result))
        return nil
    end
end

--[[
    Get performance statistics
]]
function CurveDLLInterface.getPerformanceStats()
    if not CurveDLLInterface.isReady() then
        return nil
    end
    
    local stats = ffi.new("PerformanceStats")
    local result = dll.curve_get_performance_stats(stats)
    
    if result == 0 then
        return {
            processing_time_ms = stats.processing_time_ms,
            gpu_utilization = stats.gpu_utilization,
            memory_used_bytes = tonumber(stats.memory_used_bytes),
            cache_hits = stats.cache_hits,
            cache_misses = stats.cache_misses
        }
    else
        return nil
    end
end

--[[
    Enable performance profiling
]]
function CurveDLLInterface.enableProfiling(enable)
    if dll and dll_initialized then
        dll.curve_enable_profiling(enable)
    end
end

--[[
    Generate fallback curve suggestion (CPU-based)
]]
function CurveDLLInterface.generateFallbackSuggestion(params)
    logger:info("Using CPU fallback for curve suggestion")
    
    local points
    
    if params.contrast_boost and params.contrast_boost > 0.5 then
        -- S-curve for contrast enhancement
        points = {
            {x = 0.0, y = 0.0},
            {x = 0.25, y = 0.15 + params.contrast_boost * 0.1},
            {x = 0.5, y = 0.5},
            {x = 0.75, y = 0.85 - params.contrast_boost * 0.1},
            {x = 1.0, y = 1.0}
        }
    elseif params.film_emulation then
        -- Film emulation curve
        points = {
            {x = 0.0, y = 0.05},
            {x = 0.18, y = 0.15},
            {x = 0.5, y = 0.5},
            {x = 0.82, y = 0.85},
            {x = 1.0, y = 0.95}
        }
    else
        -- Gentle enhancement
        points = {
            {x = 0.0, y = (params.shadow_recovery or 0) * 0.1},
            {x = 0.5, y = 0.5},
            {x = 1.0, y = 1.0 - (params.highlight_recovery or 0) * 0.1}
        }
    end
    
    return CurveDLLInterface.createCurve(points, 1)  -- CURVE_TYPE_CUBIC_SPLINE
end

--[[
    Module cleanup on unload
]]
local function onModuleUnload()
    CurveDLLInterface.cleanup()
end

-- Register cleanup function
if _PLUGIN then
    _PLUGIN.terminateFunction = onModuleUnload
end

return CurveDLLInterface