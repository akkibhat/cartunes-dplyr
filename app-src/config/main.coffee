'use strict'

connect = require 'connect'
mpath   = require 'path'

module.exports = (app) ->
  app.set(
    'public'
    mpath.resolve mpath.join __dirname, '../public'
  )

  app.use connect.logger()
  if app.set 'gzip compression'
    app.use connect.compress()
  app.use connect.static(app.set 'public')
