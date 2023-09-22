-- ### QB-MENU TO OX_LIB COMPAT ### --
if not Config.Modules['qb-menu'].active then return end
local function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_%s_%s'):format(Config.Modules['qb-menu'].resource_name, exportName), function(setCB)
        setCB(func)
    end)
end

local function convert(menu)
    local new_context = {}
    new_context.id = menu.id or ('convert_'..math.random(1, 10000))
    new_context.title = ConvertText(menu.title) or 'Options'

    local options = {}
    for _,button in pairs(menu) do
        local isServer, event, serverEvent, icon, title, description = button.params?.isServer or false, nil, nil, nil, nil, nil
        if isServer then serverEvent = button.params?.event or '' else event = button.params?.event or '' end
        if QBCore.Shared.Items[button.icon] then icon = ("nui://%s/html/images/%s"):format(Config.InventoryName, QBCore.Shared.Items[tostring(button.icon)].image) else icon = button.icon or nil end
        if ConvertText(button.header) then title = ConvertText(button.header) description = ConvertText(button.txt) end
        if not ConvertText(button.header) and ConvertText(button.txt) then title = ConvertText(button.txt) description = nil end
        if not ConvertText(button.header) and not ConvertText(button.txt) then title = ' ' description = nil end

        options[#options+1] = {
            title = title,
            disabled = button.isMenuHeader or false,
            onSelect = button.action or nil,
            icon = icon,
            arrow = button.subMenu or false,
            description = description,
            event = event,
            serverEvent = serverEvent,
            args = button.params?.args or nil,
        }
    end

    new_context.options = options
    return new_context
end

exportHandler('openMenu', function(data, _)
    local menu = convert(data)
    lib.registerContext(menu)
    lib.showContext(menu.id)
end)

exportHandler('closeMenu', function()
    lib.hideContext()
end)

exportHandler('showHeader', function(data)
    local menu = convert(data)
    lib.registerContext(menu)
    lib.showContext(menu.id)
end)

RegisterNetEvent('qb-menu:client:closeMenu', function()
    lib.hideContext()
end)
