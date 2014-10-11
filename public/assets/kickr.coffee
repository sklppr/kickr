# Create socket connection.
socket = io()

# Get elements and templates.
tables = $("#tables")
template = Handlebars.compile($("#table-template").html())

# Store socket ID.
socket.on "id", (id) -> socket.id = id

# Render tables after receiving data.
socket.on "data", (data) ->
  tables.empty()
  for table in data
    table.joined = socket.id in table.player_ids
    table.full = table.fill_level == 100
    table.ready = table.full && table.joined
    table.joinable = !table.full && !table.joined
    table.players = switch table.player_count
      when 0 then ""
      when 1 then "1 player"
      else "#{table.player_count} players"
    tables.append(template(table))

# Show notification when ready.
socket.on "ready", ->
  alert("Table is ready!")

# Emit event to join a table.
tables.on "click", ".join-table", (event) ->
  socket.emit("join", $(this).data("table"))

# Emit event to leave a table.
tables.on "click", ".leave-table", (event) ->
  socket.emit("leave", $(this).data("table"))
