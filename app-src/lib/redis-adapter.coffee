'use strict'

helpers = require './mopidy.js'

class RedisAdapter
  constructor: (redis, prefix = '') ->
    @redis  = redis
    @prefix = prefix

  @SORT_FN: (a, b) ->
    if a.votes == b.votes
      return a.updated - b.updated
    return b.votes - a.votes

  key: ->
    args = []
    args.push arguments...
    args = args.join ':'
    return "#{@prefix}#{args}"

  #
  # Get an array of tracks from uri's
  #
  # @param Array    uris
  # @param Function done
  #
  getTracks: (uris, done) ->
    return done null, [] unless uris.length

    gotTracks = (err, tracks) =>
      return done err if err

      return done null, [] unless tracks
      tracks = for track in tracks then JSON.parse track
      done null, tracks
      uris = tracks = null
      return

    @redis.hmget @key('tracks'), uris, gotTracks

    this

  #
  # Adds a track to the queue / pool. If already added it increments the number
  # of votes on it.
  #
  # @param Object   track
  # @param Function done
  #
  voteTrack: (track, clientId, done) ->
    # prefix:votes:uri clientid 1
    # prefix:tracks uri json
    onExec = (err) ->
      done err
      return

    previous = track.previous
    helpers.cleanTrack track
    track.updated = Date.now()
    track.previous = previous || 0
    @redis
      .multi()
      .hset @key('tracks'), track.uri, JSON.stringify track
      .hset @key('votes', track.uri), clientId, 1
      .zrem @key('pool'), track.uri
      .sadd @key('voted'), track.uri
      .exec onExec

    this

  downvoteTrack: (track, clientId, done) ->
    onExec = (err) ->
      done err
      return

    previous = track.previous
    helpers.cleanTrack track
    track.updated = Date.now()
    track.previous = previous
    @redis
      .multi()
      .hset @key('tracks'), track.uri, JSON.stringify track
      .hset @key('votes', track.uri), clientId, -1
      .zrem @key('pool'), track.uri
      .sadd @key('voted'), track.uri
      .exec onExec

    this

  getVotes: (tracks, done) ->
    gotVotes = (err, results) ->
      return done err if err

      unless results
        return done null, tracks

      for votes, index in results
        track = tracks[index]

        unless votes
          track.votes     = 0
          track.votesHash = {}
          continue

        total = 0
        for client, val of votes
          total += +val
        track.votes     = total
        track.votesHash = votes

      done null, tracks
      track = tracks = null
      return

    multi = @redis.multi()
    for track in tracks then multi.hgetall @key('votes', track.uri)
    multi.exec gotVotes

    this

  resetTrack: (track, done) ->
    gotVotes = (err) =>
      return done err if err
      return done() unless 'number' == typeof track.votes

      votesHash = track.votesHash
      votes     = track.votes
      previous  = track.previous

      helpers.cleanTrack track
      track.updated = Date.now()

      track.previous = previous || 0
      if votesHash && 0 < Object.keys(votesHash).length
        track.previous = votes

      @redis
        .multi()
        .hset @key('tracks'), track.uri, JSON.stringify track
        .del @key('votes', track.uri)
        .srem @key('voted'), track.uri
        .zadd @key('pool'), "#{track.previous}", track.uri
        .exec onExec
      track = null
      return

    onExec = (err) -> done err

    @getVotes [track], gotVotes

    this

  setPooledVotes: (track, votes, done) ->
    gotTracks = (err, tracks) =>
      return done err if err

      track = tracks[0]
      return done() unless track
      track.previous = votes

      @redis
        .multi()
        .hset @key('tracks'), track.uri, JSON.stringify track
        .zadd @key('pool'), +votes, track.uri
        .exec (err) -> done err

    @getTracks [track.uri], gotTracks

    this

  removeTrack: (track, done) ->
    onExec = (err) -> done err

    @redis
      .multi()
      .hdel @key('tracks'), track.uri
      .del @key('votes', track.uri)
      .srem @key('voted'), track.uri
      .zrem @key('pool'), track.uri
      .exec onExec

    this

  #
  # Gets the current queue with votes
  #
  # @param Function done
  #
  getQueue: (length, done) ->
    # err, tracks
    #
    # prefix:queue
    # Sorted set
    #
    # uri votes.timestamp
    s = votes : {}

    @redis.smembers @key('voted'), (err, uris) =>
      return done err if err

      s.uris = uris

      if length > uris.length
        @redis.zrevrange @key('pool'), 0, -1, 'WITHSCORES', gotPool
      else
        gotPool null, []

    gotPool = (err, poolUris) =>
      return done err if err

      s.votes = {}
      toFetch = []

      for uri, index in poolUris by 2
        s.votes[uri] = poolUris[index + 1]
        toFetch.push uri

      if 0 < toFetch.length
        @getTracks toFetch, gotPoolTracks
      else
        s.poolTracks = []
        @getTracks s.uris, gotTracks
      return

    gotPoolTracks = (err, poolTracks) =>
      return done err if err

      for track in poolTracks
        track.votes = s.votes[track.uri]

      poolTracks = poolTracks
        .sort(RedisAdapter.SORT_FN)
        .slice(0, length - s.uris.length)

      s.poolTracks = poolTracks
      @getTracks s.uris, gotTracks
      return

    gotTracks = (err, tracks) =>
      return done err if err

      s.tracks = tracks
      s.tracks.push s.poolTracks...
      @getVotes s.tracks, gotVotes
      return

    gotVotes = (err) =>
      return done err if err

      for track in s.tracks
        track.votes = 0 unless 'number' == typeof track.votes

      # Sort by votes then date
      s.tracks.sort RedisAdapter.SORT_FN

      done null, s.tracks
      s = null
      return

    this

module.exports = RedisAdapter
