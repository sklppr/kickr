# Create socket connection.
socket = io()

# Wrapper for Notification API.
Notify =
  supported: -> window.hasOwnProperty("Notification")
  permitted: -> Notification.permission == "granted"
  request: -> Notification.requestPermission() if @supported() && !@permitted()
  show: (title, body) ->
    if @supported() && @permitted()
      new Notification(title, body: body)
    else
      alert(body)

# Get elements and templates.
tables = $("#tables")
template = Handlebars.compile($("#tables-template").html())

# Render tables after receiving data.
socket.on "data", (data) ->
  for table in data
    table.joined = socket.io.engine.id in table.player_ids
    table.full = table.fill_level == 100
    table.ready = table.full && table.joined
    table.joinable = !table.full && !table.joined
    table.players = switch table.player_count
      when 0 then ""
      when 1 then "1 player"
      else "#{table.player_count} players"
  tables.html(template(data))

# Show notification when ready.
socket.on "ready", ->
  Notify.show("Kickr", "Table is ready!")

# Emit event to join a table.
tables.on "click", ".join-table", (event) ->
  socket.emit("join", $(this).data("table"))
  # Request permission for notifications.
  Notify.request()

# Emit event to leave a table.
tables.on "click", ".leave-table", (event) ->
  socket.emit("leave", $(this).data("table"))
