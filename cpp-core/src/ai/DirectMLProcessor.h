/*
 * DirectML Processor Header
 * AI-Powered Curve Processing using 183 discovered DirectML operators
 * 
 * Copyright (c) 2024 PhotoStudio Pro
 */

#pragma once

#include "AdvancedCurveProcessor.h"
#include <memory>
#include <vector>
#include <string>

namespace PhotoStudioPro {

/**
 * DirectML-powered AI processor for advanced curve operations
 * Based on reverse engineering insights from 183 ML operators
 */
class DirectMLProcessor {
public:
    DirectMLProcessor();
    ~DirectMLProcessor();
    
    // Non-copyable
    DirectMLProcessor(const DirectMLProcessor&) = delete;
    DirectMLProcessor& operator=(const DirectMLProcessor&) = delete;
    
    /**
     * Initialize DirectML and compile critical operators
     * @return true if initialization successful
     */
    bool initialize();
    
    /**
     * Cleanup DirectML resources
     */
    void cleanup();
    
    /**
     * Check if DirectML is properly initialized
     */
    bool isInitialized() const;
    
    /**
     * Generate intelligent curve based on image analysis
     * Uses DirectML operator 47 for AI-powered curve generation
     * 
     * @param image Input image for analysis
     * @param params AI suggestion parameters
     * @return Generated curve data
     */
    CurveData generateIntelligentCurve(const ImageData& image,
                                     const AISuggestionParams& params);
    
    /**
     * Optimize existing curve using AI
     * Uses DirectML operators 23, 67, 134 for optimization
     * 
     * @param input_curve Original curve to optimize
     * @param reference_image Reference image for optimization context
     * @return Optimized curve data
     */
    CurveData optimizeCurve(const CurveData& input_curve,
                           const ImageData& reference_image);
    
    /**
     * Generate film emulation curve using AI
     * Based on reverse engineered film response analysis
     * 
     * @param film_type Film type identifier ("kodak", "fuji", "leica", etc.)
     * @return Film emulation curve
     */
    CurveData generateFilmEmulationCurve(const std::string& film_type);
    
    /**
     * Real-time curve preview optimization
     * Uses DirectML operator 161 for real-time preview optimization
     * 
     * @param curve Input curve
     * @param preview_size Target preview size
     * @return Optimized curve for preview
     */
    CurveData optimizeForPreview(const CurveData& curve, 
                                const std::pair<int, int>& preview_size);
    
    /**
     * Batch processing optimization
     * Uses DirectML operator 160 for batch processing
     * 
     * @param curves Vector of curves to optimize for batch processing
     * @return Optimized curves
     */
    std::vector<CurveData> optimizeForBatch(const std::vector<CurveData>& curves);
    
    /**
     * Professional color grading curve generation
     * Uses DirectML operator 173 for professional color grading
     * 
     * @param image Input image
     * @param grading_style Style identifier ("cinema", "broadcast", "web", etc.)
     * @return Professional grading curve
     */
    CurveData generateColorGradingCurve(const ImageData& image,
                                       const std::string& grading_style);
    
    /**
     * Check if specific ML operator is available
     * 
     * @param operator_id Operator ID (0-182, total 183 operators)
     * @return true if operator is compiled and ready
     */
    bool isOperatorAvailable(int operator_id) const;
    
    /**
     * Get number of available ML operators
     * 
     * @return Number of compiled and ready operators
     */
    int getAvailableOperatorCount() const;
    
    /**
     * Get list of available operators with descriptions
     * 
     * @return Vector of operator descriptions
     */
    std::vector<std::string> getOperatorList() const;
    
    /**
     * Get DirectML device capabilities
     */
    struct DeviceCapabilities {
        bool supports_fp16;
        bool supports_fp64;
        size_t max_memory_mb;
        int compute_units;
        std::string device_name;
        std::string driver_version;
    };
    
    DeviceCapabilities getDeviceCapabilities() const;
    
    /**
     * Performance profiling for ML operations
     */
    struct MLPerformanceStats {
        double operator_execution_time_ms;
        double memory_allocation_time_ms;
        double data_transfer_time_ms;
        size_t gpu_memory_used_mb;
        int cache_hits;
        int cache_misses;
        double gpu_utilization_percent;
    };
    
    MLPerformanceStats getMLPerformanceStats() const;
    
    /**
     * Enable/disable ML performance profiling
     */
    void enableMLProfiling(bool enable);

private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
    
    // Helper methods
    CurveData generateFallbackCurve(const ImageData& image,
                                   const AISuggestionParams& params);
    
    double calculateImageBrightness(const ImageData& image);
    double calculateImageContrast(const ImageData& image);
    
    std::vector<double> analyzeImageHistogram(const ImageData& image);
    double detectColorCast(const ImageData& image);
    double calculateDynamicRange(const ImageData& image);
};

/**
 * AI-powered image analysis utilities
 * Support functions for DirectML curve processing
 */
class AIImageAnalyzer {
public:
    struct ImageCharacteristics {
        double average_brightness;
        double contrast_level;
        double shadow_clipping_percent;
        double highlight_clipping_percent;
        double color_cast_strength;
        double noise_level;
        double sharpness_score;
        double dynamic_range;
        std::vector<double> histogram_rgb[3];
        std::vector<double> histogram_luminance;
    };
    
    /**
     * Comprehensive image analysis using DirectML
     * Uses operators 0-7 for various analysis tasks
     */
    static ImageCharacteristics analyzeImage(const ImageData& image);
    
    /**
     * Detect optimal curve adjustments based on image analysis
     * Uses operators 47-52 for curve suggestions
     */
    static AISuggestionParams suggestOptimalAdjustments(const ImageCharacteristics& characteristics);
    
    /**
     * Professional workflow analysis
     * Uses operator 159 for workflow optimization
     */
    static std::string detectWorkflowType(const ImageData& image);
    
private:
    static double calculateNoiseLevel(const ImageData& image);
    static double calculateSharpness(const ImageData& image);
    static std::vector<double> calculateHistogram(const ImageData& image, int channel);
};

/**
 * Film emulation database
 * Based on reverse engineered film response curves
 */
class FilmEmulationDatabase {
public:
    struct FilmProfile {
        std::string name;
        std::string manufacturer;
        std::string type; // "color_negative", "color_positive", "bw", etc.
        std::vector<CurvePoint> red_curve;
        std::vector<CurvePoint> green_curve;
        std::vector<CurvePoint> blue_curve;
        std::vector<CurvePoint> luminance_curve;
        double grain_strength;
        double color_saturation;
        double contrast_boost;
    };
    
    /**
     * Get available film profiles
     */
    static std::vector<std::string> getAvailableFilms();
    
    /**
     * Get specific film profile
     */
    static const FilmProfile* getFilmProfile(const std::string& film_name);
    
    /**
     * Generate curves for film emulation
     */
    static std::vector<CurveData> generateFilmCurves(const std::string& film_name);
    
private:
    static void initializeFilmDatabase();
    static std::map<std::string, FilmProfile> film_database;
    static bool database_initialized;
};

/**
 * Professional color grading presets
 * Based on industry-standard color grading techniques
 */
class ColorGradingPresets {
public:
    enum class GradingStyle {
        CINEMA_BLOCKBUSTER,    // Hollywood blockbuster look
        CINEMA_INDEPENDENT,    // Independent film aesthetic
        BROADCAST_NEWS,        // News broadcast standard
        BROADCAST_SPORTS,      // Sports broadcast enhancement
        WEB_YOUTUBE,           // YouTube optimization
        WEB_INSTAGRAM,         // Instagram-friendly curves
        PRINT_MAGAZINE,        // Magazine print preparation
        PRINT_FINE_ART,        // Fine art print optimization
        SCIENTIFIC_MEDICAL,    // Medical/scientific imaging
        FORENSIC_ENHANCEMENT,  // Forensic image enhancement
        VINTAGE_FILM,          // Vintage film emulation
        MODERN_DIGITAL,        // Modern digital aesthetic
    };
    
    /**
     * Generate curves for specific grading style
     */
    static std::vector<CurveData> generateGradingCurves(GradingStyle style,
                                                       const ImageData& reference_image);
    
    /**
     * Get grading style from string
     */
    static GradingStyle parseGradingStyle(const std::string& style_name);
    
    /**
     * Get available grading styles
     */
    static std::vector<std::string> getAvailableStyles();
};

} // namespace PhotoStudioPro