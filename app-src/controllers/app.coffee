'use strict'

#
# Base controller for all the things
#
# @constructor
# @param express.Application
#

class AppController
  constructor: (app, name) ->
    @app  = app
    @name = name || 'app'

    @defaults =
      jsext   : app.set 'javascript extension'

  #
  # Setup the request and response
  #
  # @param http.IncomingMessage req
  # @param http.OutgoingMessage res
  #
  setup: (req, res) ->
    res.locals @defaults
    res.locals.request = req
    return

  #
  # Get a model
  #
  # @param String model
  #
  model: (model) ->
    return

  #
  # Call a route and ensure it is correctly bound
  #
  # @param String method
  #
  route: (method) ->
    self = @
    fn   = @[method]

    return fn.__cache if fn.__cache

    if 4 == fn.length
      cacheFn = (err, req, res, next) ->
        self.setup req, res if self.setup
        self[method](err, req, res, next)
    else
      cacheFn = (req, res, next) ->
        self.setup req, res if self.setup
        self[method](req, res, next)

    return fn.__cache = cacheFn

module.exports = AppController
