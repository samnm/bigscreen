mdns = require 'mdns'
request = require 'request'
readline = require 'readline'

makeRequest = (server, params = {}) ->
  console.log 'making request'
  options = 
    uri: "http://#{server.host}:#{server.port}/command"
    json: params
  request.post options, (error, response, body) ->
    console.log error
    console.log body

handleCommand = (command) ->
  params = 
    command: command
  makeRequest servers['rinzler'], params

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
rl.setPrompt '> ', 2
rl.prompt()
rl.on "line", (line) ->
  handleCommand line.trim()
  rl.prompt()