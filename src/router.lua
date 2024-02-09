Rooms = Rooms or {}

Handlers.add(
    "Register",
    Handlers.utils.hasMatchingTag("Action", "Register"),
    function(m)
        print("Adding room '" .. m.Name .. "'. Added by: " .. m.From)
        local address = m.Address or m.From
        table.insert(Rooms, { Address = address, Name = m.Name, AddedBy = m.From })
        ao.send({
            Target = m.From,
            Action = "Registered"
        })
    end
)

Handlers.add(
    "Get-List",
    Handlers.utils.hasMatchingTag("Action", "Get-List"),
    function(m)
        print("Listing rooms for: " .. m.From)
        local reply = { Target = m.From, Action = "Room-List" }
        for i = 1, #Rooms do
            reply["Room-" .. Rooms[i].Name] = Rooms[i].Address
        end
        ao.send(reply)
    end
)

Handlers.add(
    "Unregister",
    Handlers.utils.hasMatchingTag("Action", "Unregister"),
    function(m)
        local room = nil
        for i = 1, #Rooms do
            if Rooms[i].Name == m.Name then
                room = Rooms[i]
                room.Index = i
            end
        end

        if m.From ~= room.AddedBy then
            print("UNAUTH: Remove attempt by " .. m.From .. " for '" .. m.Name .. "'!")
            return
        end

        table.remove(Rooms, room.Index)
    end
)