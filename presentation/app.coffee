# Dependencies
express     = require('express')
app         = express()
sockjs      = require('sockjs')

server      = require('http').createServer(app)
io          = sockjs.createServer()

io.installHandlers(server, {prefix: '/socket'})

# Setup server
app.use express.static('./public')
app.set 'view engine', 'jade'
app.set 'views', './public'

# Realtime server
connections = []
io.on 'connection', (conn) ->
  connections.push conn

  conn.on 'close', ->
    index = connections.indexOf(conn)
    connections = connections.splice(index, 1) if index > -1

broadcast = (data) ->
  for conn in connections
    conn.write(JSON.stringify(data))

# Endpoints
app.post '/connect', (req, res) ->
  broadcast({connected: true})
  res.send(200)

app.post '/next', (req, res) ->
  broadcast({next: true})
  res.send(200)

app.post '/previous', (req, res) ->
  broadcast({previous: true})
  res.send(200)

app.get '/*', (req, res) ->
  res.render('index')


# <quote>Joker: And, here, we, go...</quote>
server.listen 5000, ->
  console.log("Remote presentation is running")