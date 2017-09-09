'use strict'

AppController = require './app.coffee'
Track         = require '../models/track.coffee'

class CurrentController extends AppController
  constructor: (app) ->
    super app, 'current'

    @view     = @cartunes.currentBar
    @interval = null
    @started  = null
    @offset   = null
    @current  = null
    @coverQ   = app.set 'cover queue'

    @app.on 'current:set', (track, position) =>
      return @clearCurrent() unless track

      track = new Track track
      @setCurrent track, position

    @app.on 'state:stopped', =>
      clearInterval @interval if @interval
      @interval = null

    @app.on 'state:paused', (position) =>
      clearInterval @interval if @interval
      @interval = null
      @setCurrent @current, position

    @app.on 'state:playing', (position) =>
      @setPlaying position

    @view.on 'queue:cover', =>
      track = @current
      @coverQ.push track : track, (err, cover) =>
        return if err or !cover or track != @current
        @view.setCover cover

    @view.on 'click:vote', =>
      @dnode().current.vote()

    @view.on 'click:downvote', =>
      @dnode().current.downvote()

    @init()

  init: ->
    gotCurrentTrack = (err, track, state, position) =>
      throw err if err
      return @clearCurrent() unless track

      track = new Track track
      @setCurrent track, position

      if 'playing' == state && !@interval
        @setPlaying()

    @dnode().current.get gotCurrentTrack

    this

  setPlaying: (position) ->
    if 'number' == typeof position
      @updatePosition position

    if !@interval
      @interval = setInterval(
        => @updatePosition()
        1000
      )

    this

  setCurrent: (track, position = 0) ->
    @started = Date.now()
    @offset  = position
    @current = track

    @view.render @current

    @updatePosition()

    this

  updatePosition: ->
    return this unless @current

    now   = Date.now()
    total = @offset + (now - @started)

    percent = (Math.round (total / @current.get('length')) * 1000) / 10
    @view.setPosition percent

    this

  clearCurrent: ->
    clearInterval @interval if @interval
    @interval = null
    @started  = null
    @offset   = null
    @current  = null

    @view.clear()

    this

module.exports = CurrentController
