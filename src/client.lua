DevChat = {}

DevChat.Colors = {
    red = "\27[31m",
    green = "\27[32m",
    blue = "\27[34m",
    reset = "\27[0m",
    gray = "\27[90m"
}

DevChat.Router = "xnkv_QpWqICyt8NpVMbfsUQciZ4wlm5DigLrfXRm8fY"
DevChat.InitRoom = "isImEFj7zii8ALzRirQ2nqUUXecCkdFSh10xB_hbBJ0"
DevChat.LastSend = DevChat.LastSend or DevChat.InitRoom

DevChat.LastReceive = {
    Room = DevChat.InitRoom,
    Sender = nil
}

DevChat.InitRooms = { [DevChat.InitRoom] = "DevChat-Main" }
DevChat.Rooms = DevChat.Rooms or DevChat.InitRooms

DevChat.Confirmations = DevChat.Confirmations or true

-- Helper function to go from roomName => address
DevChat.findRoom =
    function(target)
        for address, name in pairs(DevChat.Rooms) do
            if target == name then
                return address
            end
        end
    end

DevChat.add =
    function(...)
        local arg = {...}
        ao.send({
            Target = DevChat.Router,
            Action = "Register",
            Name = arg[1] or Name,
            Address = arg[2] or ao.id
        })
    end

List =
    function()
        ao.send({ Target = DevChat.Router, Action = "Get-List" })
        return(DevChat.Colors.gray .. "Getting the room list from the DevChat index..." .. DevChat.Colors.reset)
    end

Join =
    function(id, ...)
        local arg = {...}
        local addr = DevChat.findRoom(id) or id
        local nick = arg[1] or ao.id
        ao.send({ Target = addr, Action = "Register", Nickname = nick })
        return(
            DevChat.Colors.gray ..
             "Registering with room " ..
            DevChat.Colors.blue .. id .. 
            DevChat.Colors.gray .. "..." .. DevChat.Colors.reset)
    end

Say =
    function(text, ...)
        local arg = {...}
        local id = arg[1]
        if id ~= nil then
            -- Remember the new room for next time.
            DevChat.LastSend = DevChat.findRoom(id) or id
        end
        local name = DevChat.Rooms[DevChat.LastSend] or id
        ao.send({ Target = DevChat.LastSend, Action = "Broadcast", Data = text })
        if DevChat.Confirmations then
            return(DevChat.Colors.gray .. "Broadcasting to " .. DevChat.Colors.blue ..
                name .. DevChat.Colors.gray .. "..." .. DevChat.Colors.reset)
        else
            return ""
        end
    end

Tip =
    function(...) -- Recipient, Target, Qty
        local arg = {...}
        local room = arg[2] or DevChat.LastReceive.Room
        local roomName = DevChat.Rooms[room] or room
        local qty = tostring(arg[3] or 1)
        local recipient = arg[1] or DevChat.LastReceive.Sender
        ao.send({
            Action = "Transfer",
            Target = room,
            Recipient = recipient,
            Quantity = qty
        })
        return(DevChat.Colors.gray .. "Sent tip of " ..
            DevChat.Colors.green .. qty .. DevChat.Colors.gray ..
            " to " .. DevChat.Colors.red .. recipient .. DevChat.Colors.gray ..
            " in room " .. DevChat.Colors.blue .. roomName .. DevChat.Colors.gray ..
            "."
        )
    end

Replay =
    function(...) -- depth, room
        local arg = {...}
        local room = nil
        if arg[2] then
            room = DevChat.findRoom(arg[2]) or arg[2]
        else
            room = DevChat.LastReceive.Room
        end
        local roomName = DevChat.Rooms[room] or room
        local depth = arg[1] or 3

        ao.send({
            Target = room,
            Action = "Replay",
            Depth = tostring(depth)
        })
        return(
            DevChat.Colors.gray ..
             "Requested replay of the last " ..
            DevChat.Colors.green .. depth .. 
            DevChat.Colors.gray .. " messages from " .. DevChat.Colors.blue ..
            roomName .. DevChat.Colors.reset .. ".")
    end

Leave =
    function(id)
        local addr = DevChat.findRoom(id) or id
        ao.send({ Target = addr, Action = "Unregister" })
        return(
            DevChat.Colors.gray ..
             "Leaving room " ..
            DevChat.Colors.blue .. id ..
            DevChat.Colors.gray .. "..." .. DevChat.Colors.reset)
    end


Handlers.add(
    "DevChat-Broadcasted",
    Handlers.utils.hasMatchingTag("Action", "Broadcasted"),
    function (m)
        local shortRoom = DevChat.Rooms[m.From] or string.sub(m.From, 1, 6)
        if m.Broadcaster == ao.id then
            if DevChat.Confirmations == true then
                print(
                    DevChat.Colors.gray .. "[Received confirmation of your broadcast in "
                    .. DevChat.Colors.blue .. shortRoom .. DevChat.Colors.gray .. ".]"
                    .. DevChat.Colors.reset)
            end
        else
            local nick = string.sub(m.Nickname, 1, 10)
            if m.Broadcaster ~= m.Nickname then
                nick = nick .. DevChat.Colors.gray .. "#" .. string.sub(m.Broadcaster, 1, 3)
            end
            print(
                "[" .. DevChat.Colors.red .. nick .. DevChat.Colors.reset
                .. "@" .. DevChat.Colors.blue .. shortRoom .. DevChat.Colors.reset
                .. "]> " .. DevChat.Colors.green .. m.Data .. DevChat.Colors.reset)

            DevChat.LastReceive.Room = m.From
            DevChat.LastReceive.Sender = m.Broadcaster
        end
    end
)

Handlers.add(
    "DevChat-List",
    function(m)
        if m.Action == "Room-List" and m.From == DevChat.Router then
            return true
        end
        return false
    end,
    function(m)
        local intro = "👋 The following rooms are currently available on DevChat:\n\n"
        local rows = ""
        DevChat.Rooms = DevChat.InitRooms

        for i = 1, #m.TagArray do
            local filterPrefix = "Room-" -- All of our room tags start with this
            local tagPrefix = string.sub(m.TagArray[i].name, 1, #filterPrefix)
            local name = string.sub(m.TagArray[i].name, #filterPrefix + 1, #m.TagArray[i].name)
            local address = m.TagArray[i].value

            if tagPrefix == filterPrefix then
                rows = rows .. DevChat.Colors.blue .. "        " .. name .. DevChat.Colors.reset .. "\n"
                DevChat.Rooms[address] = name
            end
        end

        print(
            intro .. rows .. "\nJoin a chat by running `Join(\"chatName\"[, \"yourNickname\"])`! You can leave chats with `Leave(\"name\")`.")
    end
)

if DevChatRegistered == nil then
    DevChatRegistered = true
    Join(DevChat.InitRoom)
end

return(
    DevChat.Colors.blue .. "\n\nWelcome to ao DevChat v0.1!\n\n" .. DevChat.Colors.reset ..
    "DevChat is a simple service that helps the ao community communicate as we build our new computer.\n" ..
    "The interface is simple. Run...\n\n" ..
    DevChat.Colors.green .. "\t\t`List()`" .. DevChat.Colors.reset .. " to see which rooms are available.\n" .. 
    DevChat.Colors.green .. "\t\t`Join(\"RoomName\")`" .. DevChat.Colors.reset .. " to join a room.\n" .. 
    DevChat.Colors.green .. "\t\t`Say(\"Msg\"[, \"RoomName\"])`" .. DevChat.Colors.reset .. " to post to a room (remembering your last choice for next time).\n" ..
    DevChat.Colors.green .. "\t\t`Replay([\"Count\"])`" .. DevChat.Colors.reset .. " to reprint the most recent messages from a chat.\n" ..
    DevChat.Colors.green .. "\t\t`Leave(\"RoomName\")`" .. DevChat.Colors.reset .. " at any time to unsubscribe from a chat.\n" ..
    DevChat.Colors.green .. "\t\t`Tip([\"Recipient\"])`" .. DevChat.Colors.reset .. " to send a token from the chatroom to the sender of the last message.\n\n" ..
    "You have already been registered to the " .. DevChat.Colors.blue .. DevChat.Rooms[DevChat.InitRoom] .. DevChat.Colors.reset .. ".\n" ..
    "Have fun, be respectful, and remember: Cypherpunks ship code! 🫡")