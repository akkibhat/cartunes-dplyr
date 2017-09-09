'use strict'

Emitter = require('events').EventEmitter

class AppController extends Emitter
  constructor: (app, name) ->
    @app    = app
    @name   = name
    @router = app.set 'router'
    @cartunes  = app.set 'cartunes'

  dnode: -> @app.set 'dnode'

module.exports = AppController
