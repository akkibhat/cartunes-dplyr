'use strict'

shoe   = require 'shoe'
dnode  = require 'dnode'
inject = require 'reconnect-core'
reconnect = inject shoe

module.exports = (app, done) ->
  complete = false
  api      = require('../lib/dnode.coffee')(app)

  reconnect (stream) ->
    d = dnode api
    d.on 'remote', (remote) ->
      app.set 'dnode', remote
      unless complete
        complete = yes
        done()
    d.pipe(stream).pipe(d)
  .connect '/shoe'
