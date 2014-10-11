express = require("express")
app = express()
server = require("http").createServer(app)
io = require("socket.io")(server)

# Serve static assets from public folder.
app.use(express.static("#{__dirname}/../public"))

# Wrapper for table data.
class Table
  id: null
  name: null
  constructor: (@name, @id) ->
  players: -> Object.keys(io.sockets.adapter.rooms[@id] ? {})
  full: -> @players().length == 4
  data: -> id: @id, name: @name, players: @players(), full: @full()

# Generate tables. Players will join corresponding rooms.
tables = (process.env.TABLES?.split(",") || [ 1, 2, 3 ]).map (name, id) -> new Table(name, id)

# Collects table data.
data = -> table.data() for table in tables

# Handle connecting players.
io.on "connect", (socket) ->

  # Send table data to new player.
  socket.emit("data", data())

  # Handle player joining a table.
  socket.on "join", (id) ->
    # Only join room if not full.
    unless tables[id].full()
      socket.join(id)
      io.emit("data", data())
      # If room is full now, notify players that table is ready.
      io.to(id).emit("ready", tables[id].name) if tables[id].full()

  # Handle player leaving a table.
  socket.on "leave", (id) ->
    socket.leave(id)
    io.emit("data", data())

  # Handle player disconnecting.
  socket.on "disconnect", () ->
    # Player will automatically leave all rooms.
    io.emit("data", data())

# Run server.
server.listen(process.env.PORT || 3000)
