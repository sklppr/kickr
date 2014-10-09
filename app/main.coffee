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

# Updates table data based on room status and returns it.
data = ->
  for table in tables
    table.player_ids = Object.keys(io.sockets.adapter.rooms[table.id] ? {})
    table.player_count = table.player_ids.length
    table.fill_level = 100 * table.player_count / 4
  tables

# Handle connecting clients.
io.on "connect", (socket) ->

  # Send socket ID and table data to new client.
  socket.emit("id", socket.id)
  socket.emit("data", data())

  # Handle client joining a table.
  socket.on "join", (id) ->
    socket.join(id)
    io.emit("data", data())

  # Handle client leaving a table.
  socket.on "leave", (id) ->
    socket.leave(id)
    io.emit("data", data())

  # Handle client disconnecting.
  socket.on "disconnect", () ->
    # Client will automatically leave all rooms.
    io.emit("data", data())

# Run server.
server.listen(3000)
