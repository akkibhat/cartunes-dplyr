Mopidy  = require 'mopidy'
helpers = require '../lib/mopidy.js'

module.exports = (app, done) ->
  mopidy = new Mopidy
    webSocketUrl : app.set 'mopidy ws'
  app.set 'mopidy', mopidy

  onceOnline = ->
    mopidy.playback.stop(true)
      .then(mopidy.tracklist.clear(), helpers.onError)
      .then(mopidy.tracklist.setConsume(true), helpers.onError)
      .then(mopidy.tracklist.setRandom(false), helpers.onError)
      .then(mopidy.tracklist.setRepeat(false), helpers.onError)
      .then(mopidy.tracklist.setSingle(false), helpers.onError)
      .then(done, helpers.onError)
  mopidy.once 'state:online', onceOnline
