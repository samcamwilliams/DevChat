![Alt text](./logo.svg)

# DevChat: A simple chat interface for ao devs.
### Version: 0.1

`DevChat` is a simple way for ao devs to keep in touch while building using aos processes. It allows you to turn send and receive messages from others via ao chatrooms.

## Usage

The DevChat service is composed of three separate process types: a `router`, many `chatrooms`, and `client` users.

The `router` service provides an index of DevChat-compatible `chatrooms` that `clients` can join. Most users will only need to load the client code into their aos processes to get started.

### Running the DevChat Client

In order to get started running DevChat, simply:
1. Clone this repository.
2. Open your preferred aos process.
3. Run `.load [path to DevChat codebase]/src/client.lua`

The DevChat client will then load and be started in your aos process. The help message will print, guiding you through the basic usage and functions of the client.

### Starting a chatroom

Chatrooms in ao serve as message relays, forwarding messages from one user to all others. You can start a chatroom inside your aos process by:

1. Cloning this repository.
2. Starting `aos` with your target process.
3. Running `.load [path to DevChat codebase]/src/chatroom.lua`.
4. Registering your process with the `router`:
```
ao.send({ Target = "xnkv_QpWqICyt8NpVMbfsUQciZ4wlm5DigLrfXRm8fY", Action = "Register", Name = "[YOUR NAME HERE]" })
```

### Tokenizing

If you would like to tokenize your chatroom, please load the token blueprint with `.load-blueprint token`. You can then manipulate the `Balances` variable as necessary in order to establish the appropriate starting conditions. If a chatroom has a token, users can use the `Tip()` function in the client to send small gifts to one another. You can also enforce that only users with the token can send messages by running `RequireTokens = true`.

### Making your chatroom immutable

By default, all aos processes have the ability for their `Owner` execute code in their shell. Like all aos processes, however, the user can easily make their program immutable and trustless by setting its owner value to `nil`. To do so, simply execute `Owner = nil`. After executing this command the process will be unresponsive to any future directives by you or others.