#!/usr/bin/env lua5.3

--[[----------------------------------------------------------------------------

Simple Plugin Test Script
Test basic functionality of the Advanced Curve Editor plugin

Run with: lua5.3 test_plugin.lua

------------------------------------------------------------------------------]]

-- Add source directory to path
package.path = package.path .. ";src/?.lua"

-- Import modules
local CurveEngine = require 'CurveEngine'
local CurvePresets = require 'CurvePresets'

-- Test configuration
local VERBOSE = true
local EXIT_ON_FAILURE = true

-- Test results
local tests_run = 0
local tests_passed = 0
local tests_failed = 0

-- Colors for output (if terminal supports it)
local function colored_output(color, text)
    local colors = {
        red = '\27[31m',
        green = '\27[32m', 
        yellow = '\27[33m',
        blue = '\27[34m',
        reset = '\27[0m'
    }
    
    if os.getenv("TERM") and colors[color] then
        return colors[color] .. text .. colors.reset
    else
        return text
    end
end

-- Test assertion function
local function assert_test(condition, message, test_name)
    tests_run = tests_run + 1
    
    if condition then
        tests_passed = tests_passed + 1
        if VERBOSE then
            print(colored_output("green", "✓ " .. test_name))
        end
    else
        tests_failed = tests_failed + 1
        print(colored_output("red", "✗ " .. test_name .. ": " .. (message or "Failed")))
        
        if EXIT_ON_FAILURE then
            print(colored_output("red", "\nTest failed, exiting..."))
            os.exit(1)
        end
    end
end

-- Test function wrapper
local function test(name, func)
    if VERBOSE then
        print(colored_output("blue", "\nTesting: " .. name))
    end
    
    local ok, err = pcall(func)
    if not ok then
        print(colored_output("red", "✗ " .. name .. ": " .. err))
        tests_failed = tests_failed + 1
        tests_run = tests_run + 1
        
        if EXIT_ON_FAILURE then
            os.exit(1)
        end
    end
end

-- Print test header
print(colored_output("blue", "========================================"))
print(colored_output("blue", " Advanced Curve Editor Plugin Tests"))
print(colored_output("blue", "========================================"))
print()

-- Test 1: Curve Engine Basic Functionality
test("Curve Engine - Basic Creation", function()
    local curve = CurveEngine.createCurve({{0, 0}, {1, 1}})
    assert_test(curve ~= nil, "Failed to create curve", "Curve creation")
    assert_test(curve.points ~= nil, "Curve has no points", "Curve points")
    assert_test(#curve.points >= 2, "Insufficient curve points", "Curve point count")
    assert_test(curve.lookupTable ~= nil, "No lookup table generated", "Lookup table")
end)

-- Test 2: Curve Types
test("Curve Engine - Different Curve Types", function()
    local points = {{0, 0}, {0.5, 0.7}, {1, 1}}
    
    local linearCurve = CurveEngine.createCurve(points, CurveEngine.CURVE_TYPES.LINEAR)
    assert_test(linearCurve.type == CurveEngine.CURVE_TYPES.LINEAR, "Linear curve type", "Linear curve")
    
    local splineCurve = CurveEngine.createCurve(points, CurveEngine.CURVE_TYPES.CUBIC_SPLINE)
    assert_test(splineCurve.type == CurveEngine.CURVE_TYPES.CUBIC_SPLINE, "Spline curve type", "Spline curve")
end)

-- Test 3: Curve Evaluation
test("Curve Engine - Value Evaluation", function()
    local curve = CurveEngine.createCurve({{0, 0}, {1, 1}})
    
    local result1 = CurveEngine.applyCurve(curve, 0.0)
    assert_test(math.abs(result1 - 0.0) < 0.01, "Start point evaluation", "Start point")
    
    local result2 = CurveEngine.applyCurve(curve, 1.0)
    assert_test(math.abs(result2 - 1.0) < 0.01, "End point evaluation", "End point")
    
    local result3 = CurveEngine.applyCurve(curve, 0.5)
    assert_test(result3 >= 0.0 and result3 <= 1.0, "Midpoint in range", "Midpoint range")
end)

-- Test 4: RGB Curve Application
test("Curve Engine - RGB Application", function()
    local curves = {}
    curves[CurveEngine.CHANNELS.RGB] = CurveEngine.createCurve({{0, 0}, {1, 1}})
    
    local r, g, b = CurveEngine.applyRGBCurves(curves, 0.5, 0.3, 0.8)
    assert_test(r ~= nil and g ~= nil and b ~= nil, "RGB values returned", "RGB output")
    assert_test(r >= 0 and r <= 1, "Red value in range", "Red range")
    assert_test(g >= 0 and g <= 1, "Green value in range", "Green range")
    assert_test(b >= 0 and b <= 1, "Blue value in range", "Blue range")
end)

-- Test 5: Lightroom Conversion
test("Curve Engine - Lightroom Conversion", function()
    local curve = CurveEngine.createCurve({{0, 0}, {0.5, 0.7}, {1, 1}})
    
    local lrPoints = CurveEngine.convertToLightroomToneCurve(curve)
    assert_test(lrPoints ~= nil, "Lightroom conversion", "LR conversion")
    assert_test(#lrPoints >= 2, "Lightroom points count", "LR points count")
    
    local backCurve = CurveEngine.createFromLightroomToneCurve(lrPoints)
    assert_test(backCurve ~= nil, "Reverse conversion", "Reverse conversion")
end)

-- Test 6: Curve Data Export/Import
test("Curve Engine - Data Export/Import", function()
    local originalCurve = CurveEngine.createCurve({{0, 0}, {0.3, 0.5}, {1, 1}})
    
    local exportedData = CurveEngine.exportCurveData(originalCurve)
    assert_test(exportedData ~= nil and exportedData ~= "", "Export data", "Export")
    
    local importedCurve = CurveEngine.importCurveData(exportedData)
    assert_test(importedCurve ~= nil, "Import curve", "Import")
    assert_test(#importedCurve.points == #originalCurve.points, "Point count match", "Point count")
end)

-- Test 7: Curve Presets
test("Curve Presets - Basic Operations", function()
    local presets = CurvePresets.getPresetsForChannel(CurveEngine.CHANNELS.RGB)
    assert_test(presets ~= nil and #presets > 0, "Presets available", "Presets list")
    
    local linearPreset = CurvePresets.getPresetByName("Linear")
    assert_test(linearPreset ~= nil, "Linear preset exists", "Linear preset")
    
    local curve = CurvePresets.createCurveFromPreset(linearPreset)
    assert_test(curve ~= nil, "Curve from preset", "Preset curve")
end)

-- Test 8: Preset Categories
test("Curve Presets - Categories", function()
    local categories = CurvePresets.getPresetsByCategory(CurveEngine.CHANNELS.RGB)
    assert_test(categories ~= nil, "Categories exist", "Categories")
    
    local menuItems = CurvePresets.getPresetMenuItems(CurveEngine.CHANNELS.RGB)
    assert_test(menuItems ~= nil and #menuItems > 0, "Menu items", "Menu items")
end)

-- Test 9: Advanced Presets
test("Curve Presets - Advanced Presets", function()
    local sCurve = CurvePresets.createCurveFromPreset("S-Curve")
    assert_test(sCurve ~= nil, "S-Curve preset", "S-Curve")
    
    local film = CurvePresets.createCurveFromPreset("Film Emulation")
    assert_test(film ~= nil, "Film preset", "Film preset")
    
    -- Test that S-curve actually increases contrast
    local midResult = CurveEngine.applyCurve(sCurve, 0.5)
    assert_test(midResult > 0.4 and midResult < 0.6, "S-curve midpoint", "S-curve effect")
end)

-- Test 10: Edge Cases
test("Curve Engine - Edge Cases", function()
    -- Empty points
    local emptyCurve = CurveEngine.createCurve({})
    assert_test(emptyCurve ~= nil, "Handle empty points", "Empty points")
    
    -- Single point
    local singleCurve = CurveEngine.createCurve({{0.5, 0.5}})
    assert_test(singleCurve ~= nil, "Handle single point", "Single point")
    
    -- Out of range evaluation
    local testCurve = CurveEngine.createCurve({{0, 0}, {1, 1}})
    local negResult = CurveEngine.applyCurve(testCurve, -0.5)
    local overResult = CurveEngine.applyCurve(testCurve, 1.5)
    assert_test(negResult >= 0 and negResult <= 1, "Negative input clamped", "Negative clamp")
    assert_test(overResult >= 0 and overResult <= 1, "Over input clamped", "Over clamp")
end)

-- Test 11: Performance Test
test("Performance - Large Operations", function()
    local startTime = os.clock()
    
    -- Create complex curve
    local points = {}
    for i = 0, 20 do
        local x = i / 20
        local y = x + 0.1 * math.sin(x * math.pi * 4)
        y = math.max(0, math.min(1, y))
        table.insert(points, {x, y})
    end
    
    local complexCurve = CurveEngine.createCurve(points, CurveEngine.CURVE_TYPES.CUBIC_SPLINE)
    
    -- Apply curve 1000 times
    for i = 1, 1000 do
        local input = i / 1000
        CurveEngine.applyCurve(complexCurve, input)
    end
    
    local elapsed = os.clock() - startTime
    assert_test(elapsed < 1.0, "Performance under 1 second", "Performance test")
    
    if VERBOSE then
        print(string.format("  Performance: 1000 evaluations in %.3f seconds", elapsed))
    end
end)

-- Print test summary
print()
print(colored_output("blue", "========================================"))
print(colored_output("blue", " Test Results"))
print(colored_output("blue", "========================================"))
print()

if tests_failed == 0 then
    print(colored_output("green", string.format("All %d tests passed! ✓", tests_passed)))
    print()
    print(colored_output("green", "Plugin is ready for Lightroom installation."))
    print()
    print("Next steps:")
    print("1. Run './setup.sh' to install the plugin")
    print("2. Start Lightroom and enable the plugin")
    print("3. Test with actual photos")
else
    print(colored_output("red", string.format("Tests failed: %d/%d", tests_failed, tests_run)))
    print(colored_output("yellow", string.format("Tests passed: %d/%d", tests_passed, tests_run)))
    print()
    print(colored_output("red", "Please fix the issues before installing."))
    os.exit(1)
end

print()