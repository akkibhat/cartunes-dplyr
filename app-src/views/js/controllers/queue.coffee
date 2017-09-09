'use strict'

ListController = require './list.coffee'

class QueueController extends ListController
  constructor: (app) ->
    super app, 'queue'

    @view = @cartunes.queue

    @router.on 'route:queue', =>
      @view.focus()

    @app.on 'queue:trackChanged', (track) =>
      @trackChanged track

    @app.on 'queue:trackRemoved', (track) =>
      @trackRemoved track

    @app.on 'queue:refresh', (tracks) =>
      @view.list.collection.set tracks

    @view.list.on 'click:up', (index) =>
      track = @view.list.collection.at index
      @dnode().queue.add track.toJSON()

    @view.list.on 'click:down', (index) =>
      track = @view.list.collection.at index
      @dnode().queue.downvote track.toJSON()

    @refresh ->

    @init()

  refresh: (done) ->
    gotQueue = (err, tracks) =>
      return done err if err
      return unless tracks && tracks.length

      @view.list.collection.reset tracks
      done()

    @dnode().queue.get gotQueue

    this

  trackChanged: (track) ->
    @view.list.collection.add track, merge : true
    this

  trackRemoved: (track) ->
    track = @view.list.collection.get track.uri
    @view.list.collection.remove track
    this

module.exports = QueueController
