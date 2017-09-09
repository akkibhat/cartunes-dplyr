'use strict'

Lastfm = require 'browserified-lastfm-api'

module.exports = (app) ->
  cache  = new Lastfm.Cache
  lastfm = new Lastfm
    apiKey    : '1d2a8eac86c98dcd3d468805be615b43'
    apiSecret : ''
    cache     : cache

  app.set 'lastfm', lastfm
