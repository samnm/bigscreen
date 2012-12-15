mdns = require 'mdns'
express = require 'express'
sys = require 'sys'
exec = require('child_process').exec
os = require 'os'
ffmpeg = require 'fluent-ffmpeg'
request = require 'request'
readline = require 'readline'

puts = (error, stdout, stderr) ->
  sys.puts stdout

receiveCommand = (command) ->
  exec "open #{command}", puts

streams = {}
ad = mdns.createAdvertisement(mdns.tcp('http'), 4321, name:"BigScreen@#{os.hostname()}")
ad.start()

app = express()
app.use express.json()

app.post '/url', (req, res) ->
  receiveCommand req.body.command

app.post '/play', (req, res) ->
  receiveCommand req.body.command

app.post '/open', (req, res) ->
  receiveCommand req.body.command

app.post '/stream', (req, res) ->
  receiveCommand req.body.command

app.get '/stream/:file', (req, res) ->
  res.contentType 'flv'
  proc = new ffmpeg(
    source: stream[req.params.file]
    nolog: true
  ).usingPreset("flashvideo").writeToStream(res, (retcode, error) ->
    console.log "file has been converted succesfully" unless error
    console.log error if error
  )

app.listen 4321

makeRequest = (server, params = {}) ->
  options = 
    uri: "http://#{server.host}:#{server.port}/url"
    json: params
  request.post options, (error, response, body) ->
    console.log error
    console.log body

requestCommand = (command) ->
  params = 
    command: command
  makeRequest servers['BigScreen@rinzler.local'], params

browser = mdns.createBrowser mdns.tcp('http')
servers = {}

browser.on 'serviceUp', (service) ->
  console.log 'service up: ', service.name
  servers[service.name] = service

browser.on 'serviceDown', (service) ->
  console.log 'service down: ', service.name
  delete servers[service.name]

browser.start()

rl = readline.createInterface(
  input: process.stdin
  output: process.stdout
)
rl.on "line", (line) ->
  console.log "Line: ", line
  requestCommand line.trim()