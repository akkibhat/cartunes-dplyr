'use strict'

exports.cleanTrack = (track) ->
  delete track.votes
  delete track.votesHash
  delete track.updated
  delete track.previous
  return track

exports.search = (m, query, done) ->
  promise = m.library.search any : query

  gotResults = (results) ->
    tracks    = []
    instances = []

    for searchResults in results
      tracks.push searchResults.tracks...

    done null, tracks
    results = tracks = null
    return

  gotError = (err) -> done err

  promise.then gotResults, gotError

exports.onError = (err) ->
  console.error err.stack
  return

exports.clear = (m, done) ->
  s = {}

  onError = (err) ->
    done err
    s = null
    return

  gotCurrentTrack = (tlTrack) ->
    if tlTrack
      m.tracklist.index tlTrack
        .then gotIndex, onError
    else
      gotPrevious []
    return

  gotIndex = (index) ->
    s.current = index

    if 0 >= index
      gotPrevious []
    else
      m.tracklist.slice 0, index
        .then gotPrevious, onError
    return

  gotPrevious = (tlTracks) ->
    s.previous = tlTracks

    m.tracklist.slice s.current + 1, Infinity
      .then gotTracks, onError
    return

  gotTracks = (tracks) ->
    tracks or= []
    tracks.push s.previous...

    ids = for track in tracks then track.tlid
    m.tracklist.remove tlid : ids
      .then onRemove, onError
    s = ids = tracks = null
    return

  onRemove = -> done()

  m.playback.getCurrentTlTrack()
    .then gotCurrentTrack, onError

exports.setNextTrack = (m, track, done) ->
  onError = (err) -> done err

  exports.cleanTrack track

  onClear = (err) ->
    return done err if err

    m.tracklist.add [track], null
      .then onAdd, onError
    return
  onAdd = -> done()

  exports.clear m, onClear
