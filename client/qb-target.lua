-- ### QB-TARGET TO OX_TARGET COMPAT ### --
if not Config.Modules['qb-target'].active then return end
local function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_%s_%s'):format(Config.Modules['qb-target'].resource_name, exportName), function(setCB)
        setCB(func)
    end)
end

local target = exports.ox_target
local IDS = {}


---@param options table
local function convert(options)
    local distance = options.distance
    options = options.options

    -- People may pass options as a hashmap (or mixed, even)
    for k, v in pairs(options) do
        if type(k) ~= 'number' then
            table.insert(options, v)
        end
    end

    for id, v in pairs(options) do
        if type(id) ~= 'number' then
            options[id] = nil
            goto continue
        end

        v.onSelect = v.action
        v.distance = v.distance or distance
        v.name = v.name or v.label
        v.items = v.item
        v.icon = v.icon
        v.groups = v.job

        local groupType = type(v.groups)
        if groupType == 'nil' then
            v.groups = {}
            groupType = 'table'
        end
        if groupType == 'string' then
            local val = v.gang
            if type(v.gang) == 'table' then
                if table.type(v.gang) ~= 'array' then
                    val = {}
                    for k in pairs(v.gang) do
                        val[#val + 1] = k
                    end
                end
            end

            if val then
                v.groups = {v.groups, type(val) == 'table' and table.unpack(val) or val}
            end

            val = v.citizenid
            if type(v.citizenid) == 'table' then
                if table.type(v.citizenid) ~= 'array' then
                    val = {}
                    for k in pairs(v.citizenid) do
                        val[#val+1] = k
                    end
                end
            end

            if val then
                v.groups = {v.groups, type(val) == 'table' and table.unpack(val) or val}
            end
        elseif groupType == 'table' then
            local val = {}
            if table.type(v.groups) ~= 'array' then
                for k in pairs(v.groups) do
                    val[#val + 1] = k
                end
                v.groups = val
                val = nil
            end

            val = v.gang
            if type(v.gang) == 'table' then
                if table.type(v.gang) ~= 'array' then
                    val = {}
                    for k in pairs(v.gang) do
                        val[#val + 1] = k
                    end
                end
            end

            if val then
                v.groups = {table.unpack(v.groups), type(val) == 'table' and table.unpack(val) or val}
            end

            val = v.citizenid
            if type(v.citizenid) == 'table' then
                if table.type(v.citizenid) ~= 'array' then
                    val = {}
                    for k in pairs(v.citizenid) do
                        val[#val+1] = k
                    end
                end
            end

            if val then
                v.groups = {table.unpack(v.groups), type(val) == 'table' and table.unpack(val) or val}
            end
        end

        if type(v.groups) == 'table' and table.type(v.groups) == 'empty' then
            v.groups = nil
        end

        if v.event and v.type and v.type ~= 'client' then
            if v.type == 'server' then
                v.serverEvent = v.event
            elseif v.type == 'command' then
                v.command = v.event
            end

            v.event = nil
            v.type = nil
        end

        v.action = nil
        v.job = nil
        v.gang = nil
        v.citizenid = nil
        v.item = nil
        v.qtarget = true

        ::continue::
    end

    return options
end


---@param allow boolean
exportHandler('AllowTargeting', function(allow)
    target:setAllowTargeting(not allow)
end)


---@param name string
---@param center vector3 | table | vector4
---@param radius number
---@param options table
---@param targetoptions table
exportHandler('AddCircleZone', function(name, center, radius, options, targetoptions)
    local id = math.random(1,100000000)
    IDS[name] = id
    return target:addSphereZone({
        name = IDS[name],
        coords = center,
        radius = radius,
        debug = options.debugPoly,
        options = convert(targetoptions),
    })
end)


---@param name string
---@param center vector3 | table | vector4
---@param length number
---@param width number
---@param options table
---@param targetoptions table
exportHandler('AddBoxZone', function(name, center, length, width, options, targetoptions)
    local id = math.random(1,100000000)
    IDS[name] = id
    local z = center.z

    if not options.useZ then
        z = z + math.abs(options.maxZ - options.minZ) / 2
        center = vec3(center.x, center.y, z)
    end

    return target:addBoxZone({
        name = IDS[name],
        coords = center,
        size = vec3(width, length, (options.useZ or not options.maxZ) and center.z or math.abs(options.maxZ - options.minZ)),
        debug = options.debugPoly,
        rotation = options.heading,
        options = convert(targetoptions),
    })
end)


---@param name string
---@param points table
---@param options table
---@param targetoptions table
exportHandler('AddPolyZone', function(name, points, options, targetoptions)
    local id = math.random(1,100000000)
    IDS[name] = id
    local newPoints = table.create(#points, 0)
    local thickness = math.abs(options.maxZ - options.minZ)

    for i = 1, #points do
        local point = points[i]
        newPoints[i] = vec3(point.x, point.y, options.maxZ - (thickness / 2))
    end

    return target:addPolyZone({
        name = IDS[name],
        points = newPoints,
        thickness = thickness,
        debug = options.debugPoly,
        options = convert(targetoptions),
    })
end)


---@param name string
---@param entity ?
---@param options table
---@param targetoptions table
exportHandler('AddEntityZone', function(name, entity, options, targetoptions)
    local id = math.random(1,100000000)
    IDS[name] = id

    local entityCoords = GetEntityCoords(entity)
    local entityModel = GetEntityModel(entity)
    
    local minimum, maximum = GetModelDimensions(entityModel)
    local width = math.abs(maximum.x - minimum.x)
    local length = math.abs(maximum.y - minimum.y)
    local height = math.abs(maximum.z - minimum.z)

    local center = vec3(entityCoords.x, entityCoords.y, entityCoords.z + height / 2)

    return target:addBoxZone({
        name = IDS[name],
        coords = center,
        size = vec3(width, length, height),
        debug = options.debugPoly,
        rotation = options.heading,
        options = convert(targetoptions),
    })
end)


---@param name string
exportHandler('RemoveZone', function(name)
    local id = IDS[name]
    target:removeZone(id, true)
end)


---@param bones string | table
---@param options table
exportHandler('AddTargetBone', function(bones, options)
    if type(bones) ~= 'table' then bones = { bones } end
    options = convert(options)

    for _, v in pairs(options) do
        v.bones = bones
    end

    target:addGlobalVehicle(options)
end)


---@param bones string | table
---@param labels string | table
exportHandler('RemoveTargetBone', function(bones, labels)
    print('Not yet implemented.')
end)


---@param entities string | table
---@param options table
exportHandler('AddTargetEntity', function(entities, options)
    if type(entities) ~= 'table' then entities = { entities } end
    options = convert(options)

    for i = 1, #entities do
        local entity = entities[i]

        if NetworkGetEntityIsNetworked(entity) then
            target:addEntity(NetworkGetNetworkIdFromEntity(entity), options)
        else
            target:addLocalEntity(entity, options)
        end
    end
end)


---@param entities string | table
---@param labels string | table
exportHandler('RemoveTargetEntity', function(entities, labels)
    if type(entities) ~= 'table' then entities = { entities } end

    for i = 1, #entities do
        local entity = entities[i]

        if NetworkGetEntityIsNetworked(entity) then
            target:removeEntity(NetworkGetNetworkIdFromEntity(entity), labels)
        else
            target:removeLocalEntity(entity, labels)
        end
    end
end)


---@param models string | table
---@param options table
exportHandler('AddTargetModel', function(models, options)
    target:addModel(models, convert(options))
end)


---@param models string | table
---@param labels string | table
exportHandler('RemoveTargetModel', function(models, labels)
    target:removeModel(models, labels)
end)


---@param options table
exportHandler('AddGlobalPed', function(options)
    target:addGlobalPed(convert(options))
end)


---@param labels string | table
exportHandler('RemoveGlobalPed', function(labels)
    target:removeGlobalPed(labels)
end)


---@param options table
exportHandler('AddGlobalVehicle', function(options)
    target:addGlobalVehicle(convert(options))
end)


---@param labels string | table
exportHandler('RemoveGlobalVehicle', function(labels)
    target:removeGlobalVehicle(labels)
end)


---@param options table
exportHandler('AddGlobalObject', function(options)
    target:addGlobalObject(convert(options))
end)


---@param labels string | table
exportHandler('RemoveGlobalObject', function(labels)
    target:removeGlobalObject(labels)
end)


---@param options table
exportHandler('AddGlobalPlayer', function(options)
    target:addGlobalPlayer(convert(options))
end)


---@param labels string | table
exportHandler('RemoveGlobalPlayer', function(labels)
    target:removeGlobalPlayer(labels)
end)


---@param data table
exportHandler('SpawnPed', function(data)
    print('Not yet implemented.')
end)


---@param peds string | table
exportHandler('RemoveSpawnedPed', function(peds)
    print('Not yet implemented.')
end)