local setupEvent = nil

local cachedDoors = {}

setupEvent = AddEventHandler("Core:Shared:Ready", function()
    for index, clinic in ipairs(Config.Clinics) do
        if not clinic.door or not clinic.door.location then
            goto skip
        end

        local point = lib.points.new({
            coords = clinic.door.location,
            distance = 30.0,
            door = "clinic_" .. index
        })

        function point:onEnter()
            local doorHandle = GetClosestObjectOfType(
                self.coords.x, self.coords.y, self.coords.z,
                1.0,
                clinic.door.model, false, false, false
            )

            if not DoesEntityExist(doorHandle) then
                return
            end

            cachedDoors[self.door] = doorHandle

            exports.ox_target:addLocalEntity(doorHandle, {
                label = locale("CLINIC_DOOR"),
                icon = "DoorOpen",
                distance = 1.5,

                onSelect = function()
                    local opened, errorMsg = lib.callback.await("prp-crime:server:clinicDoor", 350, self.door)

                    if not opened then
                        exports["prp-hud-v2"]:NotificationError(errorMsg)

                        return
                    end

                    exports["prp-hud-v2"]:NotificationSuccess(locale("CLINIC_DOOR_UNLOCKED"))
                end
            })
        end

        function point:onExit()
            if not cachedDoors[self.door] then
                return
            end

            exports.ox_target:removeLocalEntity(cachedDoors[self.door])

            cachedDoors[self.door] = nil
        end

        :: skip ::
    end

    if not setupEvent then
        return
    end

    RemoveEventHandler(setupEvent)
end)

