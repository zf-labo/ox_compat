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
---@param entity number
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


-- ### SPAWN PEDS ###
local Peds = {}
local pedsReady = false
local function SpawnPed(data)
	local spawnedped
	local key, value = next(data)
	if type(value) == 'table' and type(key) ~= 'string' then
		for _, v in pairs(data) do
			if v.spawnNow then
				RequestModel(v.model)
				while not HasModelLoaded(v.model) do
					Wait(0)
				end

				if type(v.model) == 'string' then v.model = joaat(v.model) end

				if v.minusOne then
					spawnedped = CreatePed(0, v.model, v.coords.x, v.coords.y, v.coords.z - 1.0, v.coords.w or 0.0, v.networked or false, true)
				else
					spawnedped = CreatePed(0, v.model, v.coords.x, v.coords.y, v.coords.z, v.coords.w or 0.0, v.networked or false, true)
				end

				if v.freeze then
					FreezeEntityPosition(spawnedped, true)
				end

				if v.invincible then
					SetEntityInvincible(spawnedped, true)
				end

				if v.blockevents then
					SetBlockingOfNonTemporaryEvents(spawnedped, true)
				end

				if v.animDict and v.anim then
					RequestAnimDict(v.animDict)
					while not HasAnimDictLoaded(v.animDict) do
						Wait(0)
					end

					TaskPlayAnim(spawnedped, v.animDict, v.anim, 8.0, 0, -1, v.flag or 1, 0, false, false, false)
				end

				if v.scenario then
					SetPedCanPlayAmbientAnims(spawnedped, true)
					TaskStartScenarioInPlace(spawnedped, v.scenario, 0, true)
				end

				if v.pedrelations and type(v.pedrelations.groupname) == 'string' then
					if type(v.pedrelations.groupname) ~= 'string' then error(v.pedrelations.groupname .. ' is not a string') end

					local pedgrouphash = joaat(v.pedrelations.groupname)

					if not DoesRelationshipGroupExist(pedgrouphash) then
						AddRelationshipGroup(v.pedrelations.groupname)
					end

					SetPedRelationshipGroupHash(spawnedped, pedgrouphash)
					if v.pedrelations.toplayer then
						SetRelationshipBetweenGroups(v.pedrelations.toplayer, pedgrouphash, joaat('PLAYER'))
					end

					if v.pedrelations.toowngroup then
						SetRelationshipBetweenGroups(v.pedrelations.toowngroup, pedgrouphash, pedgrouphash)
					end
				end

				if v.weapon then
					if type(v.weapon.name) == 'string' then v.weapon.name = joaat(v.weapon.name) end

					if IsWeaponValid(v.weapon.name) then
						SetCanPedEquipWeapon(spawnedped, v.weapon.name, true)
						GiveWeaponToPed(spawnedped, v.weapon.name, v.weapon.ammo, v.weapon.hidden or false, true)
						SetPedCurrentWeaponVisible(spawnedped, not v.weapon.hidden or false, true)
					end
				end

				if v.target then
					if v.target.useModel then
                        target:addModel(data.model, convert({
                            options = data.target.options,
                            distance = data.target.distance
                        }))
                    else
                        target:addLocalEntity(spawnedped, convert({
                            options = data.target.options,
                            distance = data.target.distance
                        }))
					end
				end

				v.currentpednumber = spawnedped

				if v.action then
					v.action(v)
				end
			end

			local nextnumber = #Peds + 1
			if nextnumber <= 0 then nextnumber = 1 end

            v.res = GetInvokingResource()
			Peds[nextnumber] = v
		end
	else
		if data.spawnNow then
			RequestModel(data.model)
			while not HasModelLoaded(data.model) do
				Wait(0)
			end

			if type(data.model) == 'string' then data.model = joaat(data.model) end

			if data.minusOne then
				spawnedped = CreatePed(0, data.model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.coords.w, data.networked or false, true)
			else
				spawnedped = CreatePed(0, data.model, data.coords.x, data.coords.y, data.coords.z, data.coords.w, data.networked or false, true)
			end

			if data.freeze then
				FreezeEntityPosition(spawnedped, true)
			end

			if data.invincible then
				SetEntityInvincible(spawnedped, true)
			end

			if data.blockevents then
				SetBlockingOfNonTemporaryEvents(spawnedped, true)
			end

			if data.animDict and data.anim then
				RequestAnimDict(data.animDict)
				while not HasAnimDictLoaded(data.animDict) do
					Wait(0)
				end

				TaskPlayAnim(spawnedped, data.animDict, data.anim, 8.0, 0, -1, data.flag or 1, 0, false, false, false)
			end

			if data.scenario then
				SetPedCanPlayAmbientAnims(spawnedped, true)
				TaskStartScenarioInPlace(spawnedped, data.scenario, 0, true)
			end

			if data.pedrelations then
				if type(data.pedrelations.groupname) ~= 'string' then error(data.pedrelations.groupname .. ' is not a string') end

				local pedgrouphash = joaat(data.pedrelations.groupname)

				if not DoesRelationshipGroupExist(pedgrouphash) then
					AddRelationshipGroup(data.pedrelations.groupname)
				end

				SetPedRelationshipGroupHash(spawnedped, pedgrouphash)
				if data.pedrelations.toplayer then
					SetRelationshipBetweenGroups(data.pedrelations.toplayer, pedgrouphash, joaat('PLAYER'))
				end

				if data.pedrelations.toowngroup then
					SetRelationshipBetweenGroups(data.pedrelations.toowngroup, pedgrouphash, pedgrouphash)
				end
			end

			if data.weapon then
				if type(data.weapon.name) == 'string' then data.weapon.name = joaat(data.weapon.name) end

				if IsWeaponValid(data.weapon.name) then
					SetCanPedEquipWeapon(spawnedped, data.weapon.name, true)
					GiveWeaponToPed(spawnedped, data.weapon.name, data.weapon.ammo, data.weapon.hidden or false, true)
					SetPedCurrentWeaponVisible(spawnedped, not data.weapon.hidden or false, true)
				end
			end

			if data.target then
				if data.target.useModel then
                    target:addModel(data.model, convert({
                        options = data.target.options,
                        distance = data.target.distance
                    }))
				else
                    target:addLocalEntity(spawnedped, convert({
                        options = data.target.options,
                        distance = data.target.distance
                    }))
				end
			end

			data.currentpednumber = spawnedped

			if data.action then
				data.action(data)
			end
		end

		local nextnumber = #Peds + 1
		if nextnumber <= 0 then nextnumber = 1 end

        data.res = GetInvokingResource()
		Peds[nextnumber] = data
	end
end


function SpawnPeds()
	if pedsReady or not next(Peds) then return end
	for k, v in pairs(Peds) do
		if not v.currentpednumber or v.currentpednumber == 0 then
			local spawnedped
			RequestModel(v.model)
			while not HasModelLoaded(v.model) do
				Wait(0)
			end

			if type(v.model) == 'string' then v.model = joaat(v.model) end

			if v.minusOne then
				spawnedped = CreatePed(0, v.model, v.coords.x, v.coords.y, v.coords.z - 1.0, v.coords.w, v.networked or false, false)
			else
				spawnedped = CreatePed(0, v.model, v.coords.x, v.coords.y, v.coords.z, v.coords.w, v.networked or false, false)
			end

			if v.freeze then
				FreezeEntityPosition(spawnedped, true)
			end

			if v.invincible then
				SetEntityInvincible(spawnedped, true)
			end

			if v.blockevents then
				SetBlockingOfNonTemporaryEvents(spawnedped, true)
			end

			if v.animDict and v.anim then
				RequestAnimDict(v.animDict)
				while not HasAnimDictLoaded(v.animDict) do
					Wait(0)
				end

				TaskPlayAnim(spawnedped, v.animDict, v.anim, 8.0, 0, -1, v.flag or 1, 0, false, false, false)
			end

			if v.scenario then
				SetPedCanPlayAmbientAnims(spawnedped, true)
				TaskStartScenarioInPlace(spawnedped, v.scenario, 0, true)
			end

			if v.pedrelations then
				if type(v.pedrelations.groupname) ~= 'string' then error(v.pedrelations.groupname .. ' is not a string') end

				local pedgrouphash = joaat(v.pedrelations.groupname)

				if not DoesRelationshipGroupExist(pedgrouphash) then
					AddRelationshipGroup(v.pedrelations.groupname)
				end

				SetPedRelationshipGroupHash(spawnedped, pedgrouphash)
				if v.pedrelations.toplayer then
					SetRelationshipBetweenGroups(v.pedrelations.toplayer, pedgrouphash, joaat('PLAYER'))
				end

				if v.pedrelations.toowngroup then
					SetRelationshipBetweenGroups(v.pedrelations.toowngroup, pedgrouphash, pedgrouphash)
				end
			end

			if v.weapon then
				if type(v.weapon.name) == 'string' then v.weapon.name = joaat(v.weapon.name) end

				if IsWeaponValid(v.weapon.name) then
					SetCanPedEquipWeapon(spawnedped, v.weapon.name, true)
					GiveWeaponToPed(spawnedped, v.weapon.name, v.weapon.ammo, v.weapon.hidden or false, true)
					SetPedCurrentWeaponVisible(spawnedped, not v.weapon.hidden or false, true)
				end
			end

			if v.target then
				if v.target.useModel then
					AddTargetModel(v.model, {
						options = v.target.options,
						distance = v.target.distance
					})
				else
					AddTargetEntity(spawnedped, {
						options = v.target.options,
						distance = v.target.distance
					})
				end
			end

			if v.action then
				v.action(v)
			end

			Peds[k].currentpednumber = spawnedped
		end
	end
	pedsReady = true
end


function DeletePeds(res)
    if res then
        for k, v in pairs(Peds) do
            if v.res == res then
                DeletePed(v.currentpednumber)
                Peds[k].currentpednumber = 0
            end
        end
    else
        if not pedsReady or not next(Peds) then return end
        for k, v in pairs(Peds) do
            DeletePed(v.currentpednumber)
            Peds[k].currentpednumber = 0
        end
        pedsReady = false
    end
end


AddEventHandler('onResourceStart', function(resource)
	if resource ~= GetCurrentResourceName() then return end
	SpawnPeds()
end)


AddEventHandler('onResourceStop', function(resource)
    DeletePeds(resource)
	if resource ~= GetCurrentResourceName() then return end
	DeletePeds()
end)


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	SpawnPeds()
end)


---@param data table
exportHandler('SpawnPed', function(data)
    SpawnPed(data)
end)


---@param peds string | table
exportHandler('RemoveSpawnedPed', function(peds) end)
