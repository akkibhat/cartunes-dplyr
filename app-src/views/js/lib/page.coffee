'use strict'

Emitter = require('events').EventEmitter

page = module.exports = new Emitter

page.isReady = no

page.once 'ready', ->
  page.isReady = yes

page.on 'newListener', (event, fn) ->
  if 'ready' == event && page.isReady
    setTimeout(
      ->
        page.emit 'ready'
      0
    )
