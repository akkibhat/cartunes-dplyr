'use strict'

MopidyController = require '../controllers/mopidy.js'

module.exports = (app) ->
  mopidy = new MopidyController app
  app.set 'mopidy controller', mopidy
