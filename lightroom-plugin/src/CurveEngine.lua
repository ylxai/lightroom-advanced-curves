--[[----------------------------------------------------------------------------

Advanced Curve Engine
Mathematical foundation for advanced curve editing

Features:
- Cubic spline interpolation
- Bezier curve support
- Multi-channel curve processing
- High precision curve calculations

------------------------------------------------------------------------------]]

local LrMath = import 'LrMath'
local LrColor = import 'LrColor'

local CurveEngine = {}

-- Constants
local CURVE_RESOLUTION = 256
local MAX_CONTROL_POINTS = 32
local MIN_CONTROL_POINTS = 2

-- Curve Types
CurveEngine.CURVE_TYPES = {
    LINEAR = 'linear',
    CUBIC_SPLINE = 'cubic_spline',
    BEZIER = 'bezier',
    PARAMETRIC = 'parametric'
}

-- Color Channels
CurveEngine.CHANNELS = {
    RGB = 'rgb',
    RED = 'red',
    GREEN = 'green', 
    BLUE = 'blue',
    LUMINANCE = 'luminance',
    LAB_L = 'lab_l',
    LAB_A = 'lab_a',
    LAB_B = 'lab_b'
}

--[[
    Initialize curve engine
]]
function CurveEngine.initialize()
    return {
        curves = {},
        activeChannel = CurveEngine.CHANNELS.RGB,
        curveType = CurveEngine.CURVE_TYPES.CUBIC_SPLINE,
        resolution = CURVE_RESOLUTION,
        modified = false
    }
end

--[[
    Create a new curve with control points
    @param points: Array of {x, y} control points (0-1 range)
    @param curveType: Type of curve interpolation
]]
function CurveEngine.createCurve(points, curveType)
    curveType = curveType or CurveEngine.CURVE_TYPES.CUBIC_SPLINE
    
    -- Validate points
    if not points or #points < MIN_CONTROL_POINTS then
        points = {{0, 0}, {1, 1}}  -- Default linear curve
    end
    
    -- Sort points by x coordinate
    table.sort(points, function(a, b) return a[1] < b[1] end)
    
    -- Ensure curve starts at 0,0 and ends at 1,1
    if points[1][1] > 0 then
        table.insert(points, 1, {0, points[1][2]})
    end
    if points[#points][1] < 1 then
        table.insert(points, {1, points[#points][2]})
    end
    
    return {
        points = points,
        type = curveType,
        lookupTable = CurveEngine.generateLookupTable(points, curveType),
        modified = true
    }
end

--[[
    Generate lookup table for curve
    @param points: Control points
    @param curveType: Type of interpolation
]]
function CurveEngine.generateLookupTable(points, curveType)
    local lut = {}
    
    if curveType == CurveEngine.CURVE_TYPES.LINEAR then
        lut = CurveEngine.generateLinearLUT(points)
    elseif curveType == CurveEngine.CURVE_TYPES.CUBIC_SPLINE then
        lut = CurveEngine.generateCubicSplineLUT(points)
    elseif curveType == CurveEngine.CURVE_TYPES.BEZIER then
        lut = CurveEngine.generateBezierLUT(points)
    else
        lut = CurveEngine.generateLinearLUT(points)
    end
    
    return lut
end

--[[
    Generate linear interpolation lookup table
]]
function CurveEngine.generateLinearLUT(points)
    local lut = {}
    
    for i = 0, CURVE_RESOLUTION - 1 do
        local x = i / (CURVE_RESOLUTION - 1)
        local y = CurveEngine.linearInterpolate(points, x)
        lut[i + 1] = LrMath.clamp(y, 0, 1)
    end
    
    return lut
end

--[[
    Linear interpolation between control points
]]
function CurveEngine.linearInterpolate(points, x)
    if x <= points[1][1] then return points[1][2] end
    if x >= points[#points][1] then return points[#points][2] end
    
    for i = 1, #points - 1 do
        if x >= points[i][1] and x <= points[i + 1][1] then
            local t = (x - points[i][1]) / (points[i + 1][1] - points[i][1])
            return points[i][2] + t * (points[i + 1][2] - points[i][2])
        end
    end
    
    return x  -- Fallback
end

--[[
    Generate cubic spline interpolation lookup table
]]
function CurveEngine.generateCubicSplineLUT(points)
    local lut = {}
    local splineCoeffs = CurveEngine.calculateCubicSplineCoefficients(points)
    
    for i = 0, CURVE_RESOLUTION - 1 do
        local x = i / (CURVE_RESOLUTION - 1)
        local y = CurveEngine.evaluateCubicSpline(splineCoeffs, points, x)
        lut[i + 1] = LrMath.clamp(y, 0, 1)
    end
    
    return lut
end

--[[
    Calculate cubic spline coefficients using natural splines
]]
function CurveEngine.calculateCubicSplineCoefficients(points)
    local n = #points
    local h = {}
    local alpha = {}
    local l = {}
    local mu = {}
    local z = {}
    local c = {}
    local b = {}
    local d = {}
    
    -- Calculate h values
    for i = 1, n - 1 do
        h[i] = points[i + 1][1] - points[i][1]
    end
    
    -- Calculate alpha values
    for i = 2, n - 1 do
        alpha[i] = (3 / h[i]) * (points[i + 1][2] - points[i][2]) - 
                   (3 / h[i - 1]) * (points[i][2] - points[i - 1][2])
    end
    
    -- Solve tridiagonal system
    l[1] = 1
    mu[1] = 0
    z[1] = 0
    
    for i = 2, n - 1 do
        l[i] = 2 * (points[i + 1][1] - points[i - 1][1]) - h[i - 1] * mu[i - 1]
        mu[i] = h[i] / l[i]
        z[i] = (alpha[i] - h[i - 1] * z[i - 1]) / l[i]
    end
    
    l[n] = 1
    z[n] = 0
    c[n] = 0
    
    -- Back substitution
    for j = n - 1, 1, -1 do
        c[j] = z[j] - mu[j] * c[j + 1]
        b[j] = (points[j + 1][2] - points[j][2]) / h[j] - h[j] * (c[j + 1] + 2 * c[j]) / 3
        d[j] = (c[j + 1] - c[j]) / (3 * h[j])
    end
    
    return {
        a = points,  -- y values
        b = b,       -- linear coefficients
        c = c,       -- quadratic coefficients
        d = d        -- cubic coefficients
    }
end

--[[
    Evaluate cubic spline at point x
]]
function CurveEngine.evaluateCubicSpline(coeffs, points, x)
    local n = #points
    
    if x <= points[1][1] then return points[1][2] end
    if x >= points[n][1] then return points[n][2] end
    
    -- Find the appropriate interval
    local i = 1
    for j = 1, n - 1 do
        if x >= points[j][1] and x <= points[j + 1][1] then
            i = j
            break
        end
    end
    
    local dx = x - points[i][1]
    local y = points[i][2] + coeffs.b[i] * dx + 
              coeffs.c[i] * dx * dx + coeffs.d[i] * dx * dx * dx
    
    return y
end

--[[
    Apply curve to a single value
    @param curve: Curve object
    @param value: Input value (0-1)
]]
function CurveEngine.applyCurve(curve, value)
    if not curve or not curve.lookupTable then
        return value
    end
    
    value = LrMath.clamp(value, 0, 1)
    local index = math.floor(value * (CURVE_RESOLUTION - 1)) + 1
    
    -- Linear interpolation between LUT entries
    if index < CURVE_RESOLUTION then
        local t = (value * (CURVE_RESOLUTION - 1)) - (index - 1)
        local y1 = curve.lookupTable[index]
        local y2 = curve.lookupTable[index + 1]
        return y1 + t * (y2 - y1)
    else
        return curve.lookupTable[CURVE_RESOLUTION]
    end
end

--[[
    Apply curves to RGB values
    @param curves: Table of curves by channel
    @param r, g, b: RGB values (0-1)
]]
function CurveEngine.applyRGBCurves(curves, r, g, b)
    local newR, newG, newB = r, g, b
    
    -- Apply RGB curve (affects all channels)
    if curves[CurveEngine.CHANNELS.RGB] then
        newR = CurveEngine.applyCurve(curves[CurveEngine.CHANNELS.RGB], newR)
        newG = CurveEngine.applyCurve(curves[CurveEngine.CHANNELS.RGB], newG)
        newB = CurveEngine.applyCurve(curves[CurveEngine.CHANNELS.RGB], newB)
    end
    
    -- Apply individual channel curves
    if curves[CurveEngine.CHANNELS.RED] then
        newR = CurveEngine.applyCurve(curves[CurveEngine.CHANNELS.RED], newR)
    end
    if curves[CurveEngine.CHANNELS.GREEN] then
        newG = CurveEngine.applyCurve(curves[CurveEngine.CHANNELS.GREEN], newG)
    end
    if curves[CurveEngine.CHANNELS.BLUE] then
        newB = CurveEngine.applyCurve(curves[CurveEngine.CHANNELS.BLUE], newB)
    end
    
    return LrMath.clamp(newR, 0, 1), LrMath.clamp(newG, 0, 1), LrMath.clamp(newB, 0, 1)
end

--[[
    Convert curve to Lightroom-compatible tone curve points
]]
function CurveEngine.convertToLightroomToneCurve(curve)
    local lrPoints = {}
    
    if curve and curve.points then
        for i, point in ipairs(curve.points) do
            -- Convert from 0-1 range to -100 to 100 range
            local x = (point[1] * 200) - 100
            local y = (point[2] * 200) - 100
            table.insert(lrPoints, {x, y})
        end
    end
    
    return lrPoints
end

--[[
    Create curve from Lightroom tone curve points
]]
function CurveEngine.createFromLightroomToneCurve(lrPoints)
    local points = {}
    
    if lrPoints then
        for i, point in ipairs(lrPoints) do
            -- Convert from -100 to 100 range to 0-1 range
            local x = (point[1] + 100) / 200
            local y = (point[2] + 100) / 200
            table.insert(points, {x, y})
        end
    end
    
    return CurveEngine.createCurve(points)
end

--[[
    Export curve data as string for saving
]]
function CurveEngine.exportCurveData(curve)
    if not curve or not curve.points then
        return ""
    end
    
    local data = {
        version = "1.0",
        type = curve.type,
        points = curve.points
    }
    
    -- Simple serialization (in real implementation, use JSON)
    local serialized = ""
    for i, point in ipairs(curve.points) do
        serialized = serialized .. point[1] .. "," .. point[2]
        if i < #curve.points then
            serialized = serialized .. ";"
        end
    end
    
    return curve.type .. "|" .. serialized
end

--[[
    Import curve data from string
]]
function CurveEngine.importCurveData(data)
    if not data or data == "" then
        return nil
    end
    
    local parts = {}
    for part in string.gmatch(data, "([^|]+)") do
        table.insert(parts, part)
    end
    
    if #parts < 2 then
        return nil
    end
    
    local curveType = parts[1]
    local pointsData = parts[2]
    local points = {}
    
    for pointStr in string.gmatch(pointsData, "([^;]+)") do
        local coords = {}
        for coord in string.gmatch(pointStr, "([^,]+)") do
            table.insert(coords, tonumber(coord))
        end
        if #coords == 2 then
            table.insert(points, {coords[1], coords[2]})
        end
    end
    
    return CurveEngine.createCurve(points, curveType)
end

return CurveEngine