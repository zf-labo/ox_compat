-- ### QB-INPUT COMPAT ### --
local QBCore = exports['qb-core']:GetCoreObject()
local function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_qb-input_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

local function convert(data)
    local typesConvert = {
        ['text'] = 'input',
        ['password'] = 'input',
        ['number'] = 'number',
        ['radio'] = 'select',
        ['checkbox'] = 'select',
        ['select'] = 'select',
    }

    local new_input = {}
    new_input.title = data.header or 'Inputs'
    
    local rows, ids = {}, {}
    for _, input in pairs(data.inputs) do
        rows[#rows+1] = {
            type = typesConvert[input.type] or 'input',
            label = input.text,
            required = input.required,
            default = input.default,
            password = input.type == 'password',
        }
        ids[#ids+1] = input.name
    end
    
    new_input.rows = rows
    return new_input.title, new_input.rows, {allowCancel = true}, ids
end

exportHandler('ShowInput', function(data)
    local title, rows, options, ids = convert(data)
    local result = lib.inputDialog(title, rows, options)

    local dialog = {}
    for i = 1, #ids do dialog[ids[i]] = result[i] end
    return dialog
end)