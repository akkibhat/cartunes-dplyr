'use strict'

bb      = require 'backbone'
Emitter = require('events').EventEmitter
helpers = require '../lib/mopidy.js'

class Track extends bb.Model
  idAttribute: 'uri'

class Queue extends bb.Collection
  model: Track

class MopidyController extends Emitter
  constructor: (app) ->
    @app       = app
    @mopidy    = app.set 'mopidy'
    @clients   = app.set 'dnode clients'
    @db        = app.set 'db'
    @queue     = new Queue
    @current   = null

    @setupListeners()
    @checkPlaying()

  setupListeners: ->
    @app.on 'queue:add', (track, addr) =>
      @queueAdd track, addr
      return
    @app.on 'queue:downvote', (track, addr) =>
      @queueDownvote track, addr
      return

    @app.on 'current:vote', (clientId) =>
      @votePlaying clientId, 1
      return
    @app.on 'current:downvote', (clientId) =>
      @votePlaying clientId, -1
      return

    @mopidy.on 'event:trackPlaybackStarted', (track) =>
      @trackChange track.tl_track.track
      return

    @mopidy.on 'event:playbackStateChanged', (state) =>
      if 'stopped' == state.new_state
        @current = null

        if 0 == @queue.length
          @queueUpdate()

      @stateChanged state.new_state
      return

    @mopidy.on 'event:seeked', (position) =>
      for client in @clients
        client.state?.change? 'playing', position
      client = null
      return

    @queue.on 'add change', (track) =>
      track = track.toJSON()
      for client in @clients
        client.queue?.trackChanged? track
      client = null
      return

    @queue.on 'remove', (track) =>
      track = track.toJSON()
      for client in @clients
        client.queue?.trackRemoved? track
      client = null
      return

    this

  checkPlaying: ->
    gotState = (state) =>
      return if state == 'playing'
      @db.getQueue @app.set('queue max'), gotQueue
      return

    gotQueue = (err, tracks) =>
      throw err if err
      return unless 0 < tracks.length

      @queue.set tracks

      track = helpers.cleanTrack tracks[0]

      helpers.setNextTrack @mopidy, tracks[0], trackSet
      return

    trackSet = (err) =>
      throw err if err

      @mopidy.playback.play(null)
        .then playing, (err) -> throw err
      return

    playing = ->

    @mopidy.playback.getState()
      .then gotState, (err) -> throw err

    this

  getQueue: (done) ->
    gotQueue = (err, tracks) =>
      return done err if err
      done null, tracks
      @queue.set tracks
      return

    @db.getQueue @app.set('queue max'), gotQueue

    this

  queueAdd: (track, addr) ->
    votedTrack = (err) =>
      return if err

      # Attach votes to track
      @db.getVotes [track], gotVotes
      return

    gotVotes = (err) =>
      return if err

      # Tell clients track has changed
      @triggerTrackChanged track
      return

    @db.voteTrack track, addr, votedTrack

    this

  queueDownvote: (track, addr) ->
    downvoted = (err) =>
      return if err

      @db.getVotes [track], gotVotes
      return

    gotVotes = (err) =>
      return if err

      if app.set('vote limit') >= track.votes
        @db.removeTrack track, trackRemoved
      else
        @triggerTrackChanged track
      return

    trackRemoved = (err) =>
      throw err if err
      @queueUpdate()
      return

    @db.downvoteTrack track, addr, downvoted

    this

  triggerTrackChanged: ->
    @queueUpdate()
    @checkPlaying()

    this

  queueUpdate: (done) ->
    gotQueue = (err, tracks) =>
      throw err if err

      @queue.set tracks

      if 0 == @queue.length && !@current
        for client in @clients
          client.current?.set? null, 0
        client = null
        @mopidy.tracklist.clear()
        return
      else if 0 == @queue.length
        helpers.clear @mopidy, ->
        return

      # Set next track
      helpers.setNextTrack @mopidy, tracks[0], nextTrackSet
      return

    nextTrackSet = (err) =>
      throw err if err
      done() if done
      return

    @db.getQueue @app.set('queue max'), gotQueue

    this

  queueRefresh: ->
    gotQueue = (err, tracks) =>
      return if err

      for client in @clients
        client.queue?.refresh? tracks
      client = null
      return

    @db.getQueue @app.set('queue max'), gotQueue

    this

  trackChange: (track) ->
    gotTracks = (err, tracks) =>
      throw err if err
      return unless tracks && tracks[0]

      track = tracks[0]

      @db.getVotes [track], gotVotes
      return

    gotVotes = (err) =>
      throw err if err

      # Save current vote state
      @current    =
        votes     : track.votes
        votesHash : track.votesHash
        previous  : track.previous

      @db.resetTrack track, trackReset
      return

    trackReset = (err) =>
      throw err if err

      @current.updated = track.updated

      @queueUpdate()
      @setPlaying track, 0
      return

    @db.getTracks [track.uri], gotTracks

    this

  setPlaying: (track, position = 0) ->
    track.votes     = @current.votes
    track.votesHash = @current.votesHash
    track.previous  = @current.previous

    for client in @clients
      client.current?.set? track, position
    client = null

    this

  votePlaying: (clientId, amount) ->
    return this unless @current

    s = {}

    @current.votesHash[clientId] = +amount
    votes = 0
    for client, value of @current.votesHash
      votes += +value
    @current.votes = votes

    gotCurrentTrack = (track) =>
      return unless track

      s.track = track

      if app.set('vote limit') >= votes
        @db.removeTrack track, trackRemoved
      else
        @db.setPooledVotes track, votes, setVotes
      return

    trackRemoved = (err) =>
      throw err if err
      @current = null
      @queueUpdate queueUpdated
      return

    queueUpdated = =>
      @mopidy.playback.next()
        .then onNext, (err) -> throw err
      return
    onNext = ->

    setVotes = (err) =>
      throw err if err

      # Update playing track
      @queueUpdate()

      @mopidy.playback.getTimePosition()
        .then gotTimePosition, (err) -> throw err
      return

    gotTimePosition = (position) =>
      @setPlaying s.track, position
      return

    @mopidy.playback.getCurrentTrack()
      .then gotCurrentTrack, (err) -> throw err

    this

  stateChanged: (state) ->
    gotTimePosition = (position) =>
      for client in @clients
        client.state?.change? state, position || 0
      client = null
      return

    if 'stopped' == state
      gotTimePosition 0
      return this

    @mopidy.playback.getTimePosition()
      .then gotTimePosition, (err) -> throw err

    this

  getPlaying: (done) ->
    s = {}

    gotCurrentTrack = (track) =>
      return done() unless track

      unless @current
        @current    =
          votes     : 0
          votesHash : {}
          previous  : 0
          updated   : Date.now()

      track.votes     = @current.votes
      track.votesHash = @current.votesHash
      track.previous  = @current.previous
      track.updated   = @current.updated

      s.track = track

      @mopidy.playback.getState()
        .then gotState, (err) -> done err
      return

    gotState = (state) =>
      s.state = if 'playing' == state then state else 'paused'

      @mopidy.playback.getTimePosition()
        .then gotPosition, (err) -> done err
      return

    gotPosition = (position) =>
      done null, s.track, s.state, position
      return

    @mopidy.playback.getCurrentTrack()
      .then gotCurrentTrack, (err) -> done err

    this

module.exports = MopidyController
