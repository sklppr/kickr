# Create socket connection.
socket = io()

# Wrapper for Notification API.
Notify =
  supported: -> window.hasOwnProperty("Notification")
  permitted: -> Notification.permission == "granted"
  request: -> Notification.requestPermission() if @supported() && !@permitted()
  show: (title, options) ->
    if !@supported() && @permitted()
      new Notification(title, options)
    else
      alert(options.body || title)

# Get elements and templates.
tables = $("#tables")
template = Handlebars.compile($("#tables-template").html())

# After receiving data, generate additional display data and render tables.
socket.on "data", (data) ->
  for table in data
    table.joined = socket.io.engine.id in table.players
    table.joinable = !table.full && !table.joined
    table.ready = table.full && table.joined
    table.percentage = 100 * table.players.length / 4
    table.players = switch table.players.length
      when 0 then ""
      when 1 then "1 player"
      else "#{table.players.length} players"
  tables.html(template(data))

# Show notification when ready.
socket.on "ready", (name) ->
  Notify.show("Kickr", body: "Table #{name} is ready!", icon: "/assets/notification-ready.png")

# Emit event to join a table.
tables.on "click", ".join-table", (event) ->
  socket.emit("join", $(this).data("table"))
  # Request permission for notifications.
  Notify.request()

# Emit event to leave a table.
tables.on "click", ".leave-table", (event) ->
  socket.emit("leave", $(this).data("table"))
