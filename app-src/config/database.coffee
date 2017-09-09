'use strict'

redis   = require 'redis'
Adapter = require '../lib/redis-adapter.js'

module.exports = (app) ->
  app.set 'redis', redis.createClient(
    app.set 'redis port'
    app.set 'redis host'
  )

  app.set 'db', new Adapter app.set('redis'), app.set('redis prefix')
