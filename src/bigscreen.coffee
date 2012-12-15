mdns = require 'mdns'
express = require 'express'
sys = require 'sys'
exec = require('child_process').exec
os = require 'os'
ffmpeg = require 'fluent-ffmpeg'
request = require 'request'
readline = require 'readline'

### 
  Server
###

puts = (error, stdout, stderr) ->
  sys.puts stdout

executeCommand = (command) ->
  switch command.type
    when 'watch' then executeWatch command
    when 'open' then executeOpen command
    else console.log "Received bad command, ", command

executeOpen = (command) ->
  exec "open #{command.url}", puts

executeWatch = (command) ->


streams = {}
ad = mdns.createAdvertisement(mdns.tcp('http'), 4321, name:"BigScreen@#{os.hostname()}")
ad.start()

app = express()
app.use express.json()

app.post '/url', (req, res) ->
  executeCommand req.body.command.url

app.post '/play', (req, res) ->
  executeCommand req.body.command.url

app.post '/open', (req, res) ->
  executeCommand req.body.command.url

app.post '/stream', (req, res) ->
  executeCommand req.body.command.url

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

### 
  Client
###

makeRequest = (server, params = {}) ->
  options = 
    uri: "http://#{server.host}:#{server.port}/url"
    json: params
  request.post options, (error, response, body) ->
    console.log error
    console.log body

requestCommand = (rawCommand) ->
  params = 
    command: parsePlainTextCommand rawCommand
  makeRequest servers["BigScreen@#{os.hostname()}"], params

parseWatchCommand = (param) ->
  type: 'watch',
  query: param.join ' '

parseOpenCommand = (url) ->
  type: 'open',
  url: url

parsePlainTextCommand = (raw) ->
  components = raw.split ' '
  command = components[0]
  body = raw.substring(components[0].length + 1)
  switch components[0]
    when 'watch' then parseWatchCommand body
    when 'open' then parseOpenCommand body
    else parseOpenCommand raw

browser = mdns.createBrowser mdns.tcp('http')
servers = {}

browser.on 'serviceUp', (service) ->
  console.log 'service up: ', service.name
  servers[service.name] = service if service.name.indexOf('BigScreen@') == 0

browser.on 'serviceDown', (service) ->
  console.log 'service down: ', service.name
  delete servers[service.name] if service.name.indexOf('BigScreen@') == 0

browser.start()

rl = readline.createInterface(
  input: process.stdin
  output: process.stdout
)
rl.on "line", (line) ->
  requestCommand line.trim()
