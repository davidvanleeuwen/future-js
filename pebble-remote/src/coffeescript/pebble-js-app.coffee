# This is sandboxed within the watchface on your phone
httpLocation  = '192.168.123.16'

Pebble.addEventListener "ready", (e) ->
  console.log 'JS READY'


post = (path, cb) ->
  request = new XMLHttpRequest()
  request.open('POST', "http://#{httpLocation}:5000/#{path}", true)

  console.log 'POSTING'

  request.onload = (e) ->
    cb?(request, request.responseText)

  request.send(null)


Pebble.addEventListener "appmessage", (e) ->
  msg = e.payload.dummy
  switch msg
    when 'connect'
      post 'connect', (req, resp) ->
        console.log 'CONNECTED'
    when 'next'
      post 'next', (req, resp) ->
        console.log 'NEXT SLIDE'
    when 'previous'
      post 'previous', (req, resp) ->
        console.log 'PREVIOUS SLIDE'