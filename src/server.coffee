mdns = require 'mdns'
express = require 'express'

ad = mdns.createAdvertisement(mdns.tcp('http'), 4321)
ad.start()

app = express()
app.use express.json()

app.get '/', (req, res) ->
  body = 'Hello!'
  res.setHeader "Content-Type", "text/plain"
  res.setHeader "Content-Length", body.length
  res.end body
  console.log req

app.post '/command', (req, res) ->
  console.log req.body.command

app.listen(4321);