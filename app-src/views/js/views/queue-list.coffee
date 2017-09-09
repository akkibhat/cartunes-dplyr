'use strict'

bb              = require 'backbone'
$               = require 'jquery'
Tracklist       = require './tracklist.coffee'
QueueCollection = require '../models/queue.coffee'

class QueueList extends Tracklist
  constructor: ->
    @collection = new QueueCollection

    super arguments...

    @collection.on 'reset', =>
      @render()

    @collection.on 'add change', (track) =>
      @addTrack track

    @collection.on 'remove', (track, coll, opts) =>
      @removeTrack track, opts

  el: '.panel-queue'
  template: require './templates/queue-list.jade'
  trackTemplate: require './templates/queue-list-track.jade'

  events:
    'click .button-up'   : 'clickedUp'
    'click .button-down' : 'clickedDown'

  addTrack: (track) ->
    @collection.sort()
    index = @collection.indexOf track

    unless @tracklist
      @render()
      return this

    if track.$el
      $el = track.$el
      $el.find('.tracklist-votes').html track.get('votes')
      $el.find('button').prop 'disabled', no

      vote = track.clientVoted bb.app.set('client id')
      if 1 == vote
        $el.find('.button-up').prop 'disabled', yes
      else if -1 == vote
        $el.find('.button-down').prop 'disabled', yes
    else
      html      = @trackTemplate
        track    : track
        app      : bb.app
        clientId : bb.app.set('client id')
      $el       = $ html
      track.$el = $el

    $el.remove()
    @tracks = @tracklist.find 'li'

    if 0 == index
      @tracklist.prepend $el
    else
      $prev = @tracks.eq(index - 1)
      $prev.after $el

    @tracks = @tracklist.find 'li'
    @scroll yes

    this

  removeTrack: (track, opts) ->
    index = opts.index

    @tracks.eq(index).remove()
    @tracks = @tracklist.find 'li'

    @scroll yes

    this

  clickedButton: (event, type) ->
    button = @$(event.currentTarget)
    track  = button.parent().parent()
    index  = @tracks.index track

    track.find('button').prop 'disabled', no
    button.prop 'disabled', yes

    @trigger "click:#{type}", index
    this

  clickedUp: (event) ->
    @clickedButton event, 'up'
    this

  clickedDown: (event) ->
    @clickedButton event, 'down'
    this

module.exports = QueueList
