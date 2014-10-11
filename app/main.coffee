express = require("express")
app = express()
server = require("http").createServer(app)
io = require("socket.io")(server)

# Serve static assets from public folder.
app.use(express.static("#{__dirname}/../public"))

# Tables with IDs and labels. Players will join rooms with these IDs.
tables = [
  { id: "og4", label: "4. OG" },
  { id: "og3", label: "3. OG" },
  { id: "og2", label: "2. OG" },
  { id: "og1", label: "1. OG" }
]

# Returns array of player IDs in a room.
player_ids = (room) -> Object.keys(io.sockets.adapter.rooms[room] ? {})

# Returns number of players in a room.
player_count = (room) -> player_ids(room).length

# Returns fill level of room.
fill_level = (room) -> 100 * player_count(room) / 4

# Checks if room is full.
is_full = (room) -> player_count(room) == 4

# Updates table data based on room status and returns it.
data = ->
  for table in tables
    table.player_ids = player_ids(table.id)
    table.player_count = player_count(table.id)
    table.fill_level = fill_level(table.id)
  tables

# Handle connecting players.
io.on "connect", (socket) ->

  # Send table data to new player.
  socket.emit("data", data())

  # Handle player joining a table.
  socket.on "join", (room) ->
    # Only join room if not full.
    unless is_full(room)
      socket.join(room)
      io.emit("data", data())
      # Notify players if ready.
      io.to(room).emit("ready") if is_full(room)

  # Handle player leaving a table.
  socket.on "leave", (room) ->
    socket.leave(room)
    io.emit("data", data())

  # Handle player disconnecting.
  socket.on "disconnect", () ->
    # Player will automatically leave all rooms.
    io.emit("data", data())

# Run server.
server.listen(process.env.PORT || 3000)
