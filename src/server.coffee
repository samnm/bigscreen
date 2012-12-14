mdns = require 'mdns'
express = require 'express'
sys = require 'sys'
exec = require('child_process').exec
os = require 'os'

puts = (error, stdout, stderr) ->
  sys.puts stdout

handleCommand = (command) ->
  exec "open #{command}", puts

ad = mdns.createAdvertisement(mdns.tcp('http'), 4321, name:"BigScreen@#{os.hostname()}")
ad.start()

app = express()
app.use express.json()

app.post '/url', (req, res) ->
  handleCommand req.body.command

app.post '/play', (req, res) ->
  handleCommand req.body.command

app.post '/open', (req, res) ->
  handleCommand req.body.command

app.listen(4321);