Users = Users or {}
Name = Name or "Unnamed-Chat"
Messages = Messages or {}
MaxReplay = MaxReplay or 5

if (RequireTokens == nil) and (Balances ~= nil) then
    RequireTokens = true
end

function RegisterRoom(router) 
    ao.send({
        Target = router,
        Action = "Register",
        Address = ao.id,
        Name = Name
    })
end

function DispatchMessage(to, from, data, type)
    ao.send({
        Target = to,
        Action = "Broadcasted",
        Broadcaster = from,
        Nickname = Users[from],
        Data = data,
        Type = type
    })
end

function Broadcast(from, data, type)
    print("Broadcasting " .. type .. " message from "
        .. from .. ". Content:\n" .. data)
    for user,_ in pairs(Users) do
        DispatchMessage(user, from, data, type)
    end
    table.insert(Messages, { From = from, Type = type, Data = data })
end

Handlers.add(
    "Register",
    Handlers.utils.hasMatchingTag("Action", "Register"),
    function(m)
        print("Registering: " .. m.From .. ". Nick: " .. m.Nickname)
        Users[m.From] = m.Nickname
        ao.send({
            Target = m.From,
            Action = "Registered"
        })
    end
)

Handlers.add(
    "Unregister",
    Handlers.utils.hasMatchingTag("Action", "Unregister"),
    function(m)
        print("Unregistering: " .. m.From)
        Users[m.From] = nil
        ao.send({
            Target = m.From,
            Action = "Unregistered"
        })
    end
)

Handlers.add(
    "Broadcast",
    Handlers.utils.hasMatchingTag("Action", "Broadcast"),
    function(m)
        if RequireTokens and Balances[m.From] < 1 then
            ao.send({
                Action = "Insufficient-Balance",
                ["Your-Balance"] = tostring(Balances[m.From])
            })
            print("Rejected user " .. m.From .. " due to insufficient balance.")
        end
        Broadcast(m.From, m.Data, m.Type or "Normal")
    end
)

Handlers.add(
    "Replay",
    Handlers.utils.hasMatchingTag("Action", "Replay"),
    function(m)
        local depth = tonumber(m.Depth) or MaxReplay

        print("Replaying " .. depth .. " messages for " .. m.From .. "...")

        for i = math.max(#Messages - depth, 0) + 1, #Messages, 1 do
            print(i)
            DispatchMessage(m.From,
                Messages[i].From,
                Messages[i].Data,
                Messages[i].Type
            )
        end
    end
)

function countUsers()
    local count = 0
    for _, __ in pairs(Users) do
        count = count + 1
    end
    return count
end

Prompt =
    function()
        return Name .. "[Users:" .. countUsers() .. "]> "
    end