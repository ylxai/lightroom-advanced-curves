--[[----------------------------------------------------------------------------

Metadata Definition
Defines custom metadata fields for the Advanced Curve Editor plugin

------------------------------------------------------------------------------]]

return {
    metadataFieldsForPhotos = {
        {
            id = 'advancedCurveData',
            title = 'Advanced Curve Data',
            dataType = 'string',
            searchable = false,
            browsable = false,
        },
        {
            id = 'curvePresetName',
            title = 'Curve Preset',
            dataType = 'string',
            searchable = true,
            browsable = true,
        },
        {
            id = 'curveModificationDate',
            title = 'Curve Modified',
            dataType = 'string',
            searchable = false,
            browsable = true,
        },
        {
            id = 'curveVersion',
            title = 'Curve Version',
            dataType = 'string',
            searchable = false,
            browsable = false,
        }
    },
    
    schemaVersion = 1,
}