'use strict'

ListController = require './list.coffee'

class ResultsController extends ListController
  constructor: (app) ->
    super app, 'results'

    @view = @cartunes.results

    @router.on 'route:queue', =>
      return unless @view.list.collection.length
      @view.list.collection.reset []

    @router.on 'route:search', (query) =>
      @view.focus()
      @getResults query

    @view.list.on 'click:add', (index) =>
      @queueTrack @view.list.collection.at index

    @cartunes.queue.list.collection.on 'add remove change reset', =>
      @view.list.updateState @cartunes.queue.list.collection

    @view.list.on 'render', =>
      @view.list.updateState @cartunes.queue.list.collection

    @init()

  gotResults: (data) ->
    @view.list.collection.reset data
    this

  getResults: (query) ->
    # Get search results
    @dnode().db.search query, (err, results) =>
      return @app.emit 'error', err if err
      @gotResults results
    this

  queueTrack: (track) ->
    @dnode().queue.add track.toJSON()
    this

module.exports = ResultsController
