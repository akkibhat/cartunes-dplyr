'use strict'

bb                  = require 'backbone'
Tracklist           = require './tracklist.coffee'
TracklistCollection = require '../models/tracklist.coffee'

class ResultsList extends Tracklist
  constructor: ->
    super arguments...

    @scrollTimeout = null
    @tracklist     = null
    @tracks        = null
    @trackHeight   = null

    @collection.on 'reset', =>
      @render()

  el: '.panel-results'
  template: require './templates/results-list.jade'

  events:
    'click .button-add' : 'clickedAdd'

  clickedAdd: (event) ->
    button = @$(event.currentTarget)
    track  = button.parent().parent()
    index  = @tracks.index track

    @trigger 'click:add', index

    this

  updateState: (queue) ->
    @$el.find('.button-add').prop 'disabled', no

    queue.forEach (qTrack, i) =>
      track = @collection.get qTrack.get('uri')
      return unless track and qTrack.clientVoted bb.app.set 'client id'

      index = @collection.indexOf track
      @tracks.eq(index).find('.button-add').prop 'disabled', yes

module.exports = ResultsList
