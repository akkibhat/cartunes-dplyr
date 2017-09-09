var express = require('express')
var http    = require('http')
var mapp    = require('./app')
var shoe    = require('shoe')
var config  = require('./config.json')

app         = express()
shoe        = shoe()

app.set('shoe', shoe)
app.set('env', 'production')

mapp(app, function (err) {
  if (err) throw err

  var server = http.createServer()
  server.on('request', app)

  server.listen(config.port)
  shoe.install(server, '/shoe')

  console.error('Listening on http://127.0.0.1:' + config.port)
})
