'use strict'

async = require 'async'

onCoverQueue = (job, done) ->
  timeout = setTimeout(
    ->
      timeout = null
      done()
    2500
  )

  gotCover = (err, cover) ->
    return done err if err
    return unless timeout
    clearTimeout timeout
    done null, cover
  job.track.getCover gotCover

module.exports = (app) ->
  app.set 'cover queue', async.queue onCoverQueue, 10
