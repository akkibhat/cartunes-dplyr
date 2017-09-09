'use strict'

AppController = require './app.coffee'

class ListController extends AppController
  constructor: (app, name) ->
    super app, name

  init: ->
    @view.list.on 'scroll', (start, count) =>
      @queueCovers start, count

  queueCovers: (start, count) ->
    q        = @app.set 'cover queue'
    hasReset = no

    onReset = ->
      hasReset = yes
    @view.list.collection.once 'reset', onReset

    end = start + count

    tracks = @view.list.collection.models.slice(start, end).reverse()
    tracks.forEach (track, i) =>
      index = end - i - 1
      return if track.cover

      q.unshift track : track, (err, cover) =>
        return if err || hasReset
        track.cover = cover
        @view.list.setTrackCover track
        @view.list.collection.off 'reset', onReset

    this

module.exports = ListController
