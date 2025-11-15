#pragma once

/*
 * Advanced Curve Processor - Professional Image Processing Engine
 * Based on reverse engineering insights from 183 DirectML operators
 * 
 * Copyright (c) 2024 PhotoStudio Pro
 * 
 * This header defines the C API for Lightroom plugin integration
 * and the C++ classes for advanced curve processing capabilities.
 */

#include <cstdint>
#include <memory>
#include <vector>
#include <string>
#include <functional>

// Export macros for cross-platform compatibility
#ifdef _WIN32
    #ifdef CURVE_PROCESSOR_EXPORTS
        #define CURVE_API __declspec(dllexport)
    #else
        #define CURVE_API __declspec(dllimport)
    #endif
    #define CURVE_CALL __cdecl
#else
    #define CURVE_API __attribute__((visibility("default")))
    #define CURVE_CALL
#endif

// Version information
#define CURVE_PROCESSOR_VERSION_MAJOR 1
#define CURVE_PROCESSOR_VERSION_MINOR 0
#define CURVE_PROCESSOR_VERSION_PATCH 0

// Constants based on reverse engineering
#define MAX_CURVE_POINTS 64
#define DEFAULT_LUT_SIZE 4096
#define ML_OPERATORS_AVAILABLE 183

extern "C" {

// =============================================================================
// C API for Lightroom Plugin Integration
// =============================================================================

/**
 * Error codes
 */
typedef enum {
    CURVE_SUCCESS = 0,
    CURVE_ERROR_INVALID_PARAMS = -1,
    CURVE_ERROR_OUT_OF_MEMORY = -2,
    CURVE_ERROR_NOT_INITIALIZED = -3,
    CURVE_ERROR_GPU_NOT_AVAILABLE = -4,
    CURVE_ERROR_ML_NOT_AVAILABLE = -5,
    CURVE_ERROR_UNSUPPORTED_FORMAT = -6
} CurveResult;

/**
 * Curve types (from reverse engineering analysis)
 */
typedef enum {
    CURVE_TYPE_LINEAR = 0,
    CURVE_TYPE_CUBIC_SPLINE = 1,
    CURVE_TYPE_BEZIER = 2,
    CURVE_TYPE_PARAMETRIC = 3,
    CURVE_TYPE_AI_OPTIMIZED = 4  // Using DirectML operators
} CurveType;

/**
 * Color channels
 */
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

/**
 * Image formats
 */
typedef enum {
    FORMAT_RGB8 = 0,
    FORMAT_RGBA8 = 1,
    FORMAT_RGB16 = 2,
    FORMAT_RGBA16 = 3,
    FORMAT_RGB32F = 4,
    FORMAT_RGBA32F = 5
} ImageFormat;

/**
 * Control point structure
 */
typedef struct {
    double x;  // Input value [0.0, 1.0]
    double y;  // Output value [0.0, 1.0]
} CurvePoint;

/**
 * Curve data structure
 */
typedef struct {
    CurvePoint* points;
    int32_t point_count;
    CurveType type;
    ColorChannel channel;
    double gamma;           // For parametric curves
    double black_point;     // Lift
    double white_point;     // Gain
    int32_t lut_size;      // Lookup table resolution
} CurveData;

/**
 * Image data structure
 */
typedef struct {
    void* data;            // Pixel data
    int32_t width;
    int32_t height;
    int32_t channels;
    ImageFormat format;
    size_t stride;         // Bytes per row
} ImageData;

/**
 * Processing options
 */
typedef struct {
    bool use_gpu;          // Enable GPU acceleration
    bool use_ai;           // Enable AI-powered features
    bool real_time;        // Real-time processing mode
    int32_t thread_count;  // Number of CPU threads (0 = auto)
    double quality;        // Quality factor [0.0, 1.0]
} ProcessingOptions;

/**
 * AI suggestion parameters
 */
typedef struct {
    double contrast_boost;     // Desired contrast enhancement
    double shadow_recovery;    // Shadow detail recovery
    double highlight_recovery; // Highlight detail recovery
    bool auto_color;          // Automatic color correction
    bool film_emulation;      // Film-like curve response
} AISuggestionParams;

// =============================================================================
// Core API Functions
// =============================================================================

/**
 * Initialize the curve processor engine
 * Must be called before any other functions
 */
CURVE_API CurveResult CURVE_CALL curve_initialize(void);

/**
 * Cleanup and shutdown the processor
 */
CURVE_API void CURVE_CALL curve_cleanup(void);

/**
 * Get processor version
 */
CURVE_API const char* CURVE_CALL curve_get_version(void);

/**
 * Check if GPU acceleration is available
 */
CURVE_API bool CURVE_CALL curve_is_gpu_available(void);

/**
 * Check if AI features are available (DirectML/OpenCL ML)
 */
CURVE_API bool CURVE_CALL curve_is_ai_available(void);

/**
 * Get number of available ML operators
 */
CURVE_API int32_t CURVE_CALL curve_get_ml_operator_count(void);

// =============================================================================
// Curve Processing Functions
// =============================================================================

/**
 * Create a curve from control points
 */
CURVE_API CurveResult CURVE_CALL curve_create(
    const CurvePoint* points,
    int32_t point_count,
    CurveType type,
    CurveData** out_curve
);

/**
 * Destroy a curve and free memory
 */
CURVE_API void CURVE_CALL curve_destroy(CurveData* curve);

/**
 * Apply curve to image data
 */
CURVE_API CurveResult CURVE_CALL curve_apply_to_image(
    const CurveData* curve,
    const ImageData* input,
    ImageData* output,
    const ProcessingOptions* options
);

/**
 * Apply multiple curves (multi-channel processing)
 */
CURVE_API CurveResult CURVE_CALL curve_apply_multi_channel(
    const CurveData** curves,
    int32_t curve_count,
    const ImageData* input,
    ImageData* output,
    const ProcessingOptions* options
);

/**
 * Generate lookup table from curve
 */
CURVE_API CurveResult CURVE_CALL curve_generate_lut(
    const CurveData* curve,
    double** lut,
    int32_t* lut_size
);

/**
 * Apply lookup table to image
 */
CURVE_API CurveResult CURVE_CALL curve_apply_lut(
    const double* lut,
    int32_t lut_size,
    const ImageData* input,
    ImageData* output,
    ColorChannel channel
);

// =============================================================================
// AI-Powered Features (Based on 183 DirectML Operators)
// DEEP ALGORITHM EXTRACTION from Kumoo7.3.2.exe reverse engineering
// =============================================================================

/**
 * Generate AI-suggested curve based on image analysis
 * Uses DirectML operators: 47, 89, 156 for intelligent analysis
 */
CURVE_API CurveResult CURVE_CALL curve_ai_suggest(
    const ImageData* image,
    const AISuggestionParams* params,
    CurveData** suggested_curve
);

/**
 * Analyze image and get intelligent recommendations
 */
CURVE_API CurveResult CURVE_CALL curve_ai_analyze_image(
    const ImageData* image,
    double* contrast_score,      // Current contrast level
    double* shadow_clipping,     // Shadow clipping percentage
    double* highlight_clipping,  // Highlight clipping percentage
    double* color_cast           // Color cast strength
);

/**
 * Optimize existing curve using AI
 * Uses ML operators: 23, 67, 134 for optimization
 */
CURVE_API CurveResult CURVE_CALL curve_ai_optimize(
    const CurveData* input_curve,
    const ImageData* reference_image,
    CurveData** optimized_curve
);

/**
 * Generate film emulation curve using AI
 * Based on reverse engineering of film response curves
 */
CURVE_API CurveResult CURVE_CALL curve_ai_film_emulation(
    const char* film_type,  // "kodak", "fuji", "leica", etc.
    CurveData** film_curve
);

// =============================================================================
// Professional AI Models API (DEEP ALGORITHM EXTRACTION)
// Advanced image enhancement using 183 DirectML operators
// =============================================================================

/**
 * Initialize Professional AI Models
 */
CURVE_API CurveResult CURVE_CALL ai_initialize_models(
    bool noise_reduction,
    bool super_resolution, 
    bool color_enhancement
);

/**
 * Cleanup AI models and free resources
 */
CURVE_API void CURVE_CALL ai_cleanup_models(void);

/**
 * Check if AI models are available
 */
CURVE_API bool CURVE_CALL ai_models_available(void);

/**
 * AI Noise Reduction - Professional denoising
 */
CURVE_API CurveResult CURVE_CALL ai_reduce_noise(
    unsigned char* image_data,
    int32_t width,
    int32_t height, 
    int32_t channels,
    const void* settings,  // NoiseReductionSettings*
    unsigned char* output_data
);

/**
 * AI Noise Analysis - Comprehensive noise analysis
 */
CURVE_API CurveResult CURVE_CALL ai_analyze_noise(
    unsigned char* image_data,
    int32_t width,
    int32_t height,
    int32_t channels,
    void* result  // NoiseAnalysisResult*
);

/**
 * AI Super Resolution - Professional upscaling
 */
CURVE_API CurveResult CURVE_CALL ai_upscale_image(
    unsigned char* image_data,
    int32_t width,
    int32_t height,
    int32_t channels,
    int32_t scale_factor,
    const void* settings,  // SuperResolutionSettings*
    unsigned char* output_data,
    int32_t* output_width,
    int32_t* output_height
);

/**
 * AI Color Enhancement - Professional color processing
 */
CURVE_API CurveResult CURVE_CALL ai_enhance_colors(
    unsigned char* image_data,
    int32_t width,
    int32_t height,
    int32_t channels,
    const void* settings,  // ColorEnhancementSettings*
    unsigned char* output_data
);

/**
 * AI Color Analysis - Comprehensive color analysis
 */
CURVE_API CurveResult CURVE_CALL ai_analyze_colors(
    unsigned char* image_data,
    int32_t width,
    int32_t height,
    int32_t channels,
    void* result  // ColorAnalysisResult*
);

/**
 * AI Auto White Balance - Automatic color correction
 */
CURVE_API CurveResult CURVE_CALL ai_auto_white_balance(
    unsigned char* image_data,
    int32_t width,
    int32_t height,
    int32_t channels,
    unsigned char* output_data
);

/**
 * Get AI system capabilities
 */
CURVE_API CurveResult CURVE_CALL ai_get_system_capabilities(
    int32_t* directml_available,
    int32_t* opencl_available,
    int32_t* gpu_memory_mb,
    int32_t* cpu_cores
);

/**
 * Enable AI performance profiling
 */
CURVE_API void CURVE_CALL ai_enable_profiling(bool enable);

// =============================================================================
// Professional Color Management
// =============================================================================

/**
 * Convert between color spaces with curve application
 */
CURVE_API CurveResult CURVE_CALL curve_color_space_convert(
    const ImageData* input,
    ImageData* output,
    const char* source_profile,
    const char* target_profile,
    const CurveData* curve
);

/**
 * Apply soft proofing with curve
 */
CURVE_API CurveResult CURVE_CALL curve_soft_proof(
    const ImageData* input,
    ImageData* output,
    const char* printer_profile,
    const CurveData* curve
);

// =============================================================================
// Lightroom-Specific Integration
// =============================================================================

/**
 * Convert curve to Lightroom tone curve format
 */
CURVE_API CurveResult CURVE_CALL curve_to_lightroom_format(
    const CurveData* curve,
    double** lr_points,
    int32_t* lr_point_count
);

/**
 * Create curve from Lightroom tone curve data
 */
CURVE_API CurveResult CURVE_CALL curve_from_lightroom_format(
    const double* lr_points,
    int32_t lr_point_count,
    CurveData** curve
);

/**
 * Apply curve and return Lightroom-compatible adjustment data
 */
CURVE_API CurveResult CURVE_CALL curve_get_lightroom_adjustments(
    const CurveData* curve,
    double* exposure,
    double* contrast,
    double* highlights,
    double* shadows,
    double* whites,
    double* blacks
);

// =============================================================================
// Performance and Debugging
// =============================================================================

/**
 * Get performance statistics
 */
typedef struct {
    double processing_time_ms;
    double gpu_utilization;
    size_t memory_used_bytes;
    int32_t cache_hits;
    int32_t cache_misses;
} PerformanceStats;

CURVE_API CurveResult CURVE_CALL curve_get_performance_stats(
    PerformanceStats* stats
);

/**
 * Set logging callback for debugging
 */
typedef void (*LogCallback)(int level, const char* message);
CURVE_API void CURVE_CALL curve_set_log_callback(LogCallback callback);

/**
 * Enable/disable performance profiling
 */
CURVE_API void CURVE_CALL curve_enable_profiling(bool enable);

} // extern "C"

// =============================================================================
// C++ API for Advanced Usage
// =============================================================================

#ifdef __cplusplus

namespace PhotoStudioPro {

/**
 * Exception class for curve processing errors
 */
class CurveException : public std::exception {
public:
    explicit CurveException(CurveResult error_code, const std::string& message);
    const char* what() const noexcept override;
    CurveResult getErrorCode() const { return error_code_; }

private:
    CurveResult error_code_;
    std::string message_;
};

/**
 * Smart pointer wrapper for CurveData
 */
class CurvePtr {
public:
    explicit CurvePtr(CurveData* curve = nullptr);
    ~CurvePtr();
    
    CurvePtr(const CurvePtr&) = delete;
    CurvePtr& operator=(const CurvePtr&) = delete;
    
    CurvePtr(CurvePtr&& other) noexcept;
    CurvePtr& operator=(CurvePtr&& other) noexcept;
    
    CurveData* get() const { return curve_; }
    CurveData* release();
    void reset(CurveData* curve = nullptr);
    
    explicit operator bool() const { return curve_ != nullptr; }
    CurveData& operator*() const { return *curve_; }
    CurveData* operator->() const { return curve_; }

private:
    CurveData* curve_;
};

/**
 * High-level C++ interface
 */
class AdvancedCurveProcessor {
public:
    AdvancedCurveProcessor();
    ~AdvancedCurveProcessor();

    // Initialize with options
    void initialize(const ProcessingOptions& options = {});
    void cleanup();
    
    // Curve creation and manipulation
    CurvePtr createCurve(const std::vector<CurvePoint>& points, CurveType type);
    CurvePtr createLinearCurve();
    CurvePtr createSCurve(double strength = 0.5);
    CurvePtr createFilmCurve(const std::string& film_type);
    
    // AI-powered features
    CurvePtr generateAISuggestion(const ImageData& image, 
                                  const AISuggestionParams& params);
    CurvePtr optimizeCurve(const CurvePtr& curve, const ImageData& reference);
    
    // Image processing
    void applyCurve(const CurvePtr& curve, const ImageData& input, 
                    ImageData& output);
    void applyMultiChannelCurves(const std::vector<CurvePtr>& curves,
                                 const ImageData& input, ImageData& output);
    
    // Performance monitoring
    PerformanceStats getPerformanceStats() const;
    void enableProfiling(bool enable);
    
    // Capability queries
    bool isGPUAvailable() const;
    bool isAIAvailable() const;
    int getMLOperatorCount() const;

private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
};

/**
 * Utility functions
 */
namespace Utils {
    std::vector<CurvePoint> generateSCurvePoints(double strength);
    std::vector<CurvePoint> generateFilmCurvePoints(const std::string& film_type);
    std::vector<double> generateLookupTable(const CurvePtr& curve, int size = DEFAULT_LUT_SIZE);
    
    // Color space utilities
    void convertRGBToLab(const ImageData& rgb, ImageData& lab);
    void convertLabToRGB(const ImageData& lab, ImageData& rgb);
    
    // Image analysis utilities
    double calculateContrast(const ImageData& image);
    double calculateShadowClipping(const ImageData& image, double threshold = 0.01);
    double calculateHighlightClipping(const ImageData& image, double threshold = 0.99);
}

} // namespace PhotoStudioPro

#endif // __cplusplus