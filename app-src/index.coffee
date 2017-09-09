'use strict'

express = require 'express'

module.exports = (app, done) ->
  done or= (err) ->
  app or= express()

  require('./config/config.js')(app)
  require('./config/main.js')(app)

  require('./config/database.js')(app)

  afterModels = (err) ->
    return done err if err
    require('./config/mopidy.js')(app, afterMopidy)

  afterMopidy = ->
    require('./config/shoe.js')(app)
    require('./config/routing.js')(app)
    require('./config/after.js')(app)

    done(null, app)

  # require('./models')(app, afterModels)
  afterModels()
