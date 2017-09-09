'use strict'

# Setup backbone
bb   = require 'backbone'
bb.$ = require 'jquery'

# Setup page and app
page   = require 'page'
cartunes  = require './views/cartunes.coffee'
Router = require './lib/router.coffee'
app    = new (require './lib/app.coffee')

bb.app = app

# TODO : Remove
window.cartunes = app

page.once 'ready', ->
  require('./config/dnode.coffee')(app, gotStream)

gotStream = ->
  # Get client id
  app.set('dnode').clients.getId gotClientId

gotClientId = (err, clientId) ->
  throw err if err

  app.set 'client id', clientId

  # Setup other config
  require('./config/lastfm.coffee')(app)
  require('./config/queues.coffee')(app)

  app.set 'cartunes', new cartunes
  app.set 'router', new Router

  require('./config/routing.coffee')(app)

  bb.history.start()
