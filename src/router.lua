Rooms = Rooms or {}

Handlers.add(
    "Register",
    function(m)
       return m.Action == "Register" and m.Address == m.From
    end,
    function(m)
        assert(m.Address, 'Address Tag is required!')
        assert(type(m.Address) == "string", 'Address should be string')
        assert(#m.Address == 43, 'Address should be 43 characters log')
        assert(type(m.Name) == "string", 'Name should be string')

        print("Adding room '" .. m.Name .. "'. Added by: " .. m.From)
        local address = m.Address or m.From
        table.insert(Rooms, { Address = address, Name = m.Name, AddedBy = m.From })
        ao.send({
            Target = m.From,
            Action = Colors.gray .. "Registered Room " .. Colors.blue .. m.Name .. Colors.reset
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
            print(Colors.red .. 
              "UNAUTH: Remove attempt by ".. 
              Colors.green .. m.From .. " for '" .. 
              Colors.blue .. m.Name .. "'!" .. Colors.reset
            )
            return
        end

        table.remove(Rooms, room.Index)
    end
)