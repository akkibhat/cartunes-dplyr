'use strict'

bb = require 'backbone'

class Track extends bb.Model
  @COVER_CACHE   = {}
  @COVER_PENDING = {}

  idAttribute: 'uri'

  cleanup: ->
    @off()

  getCover: (done) ->
    artist = @get('artists')[0]?.name || ''
    album  = @get('album').name
    key    = "#{album}:#{artist}"

    if Track.COVER_PENDING[key]
      Track.COVER_PENDING[key].push done
      return
    else if Track.COVER_CACHE[key]
      return done null, Track.COVER_CACHE[key]

    lastfm = bb.app.set 'lastfm'
    Track.COVER_PENDING[key] = [done]

    lastfm.album.getInfo
      artist : @get('artists')[0]?.name || ''
      album  : @get('album').name
    , success : (data) ->
        for image in data.album.image
          if 'large' == image.size
            Track.COVER_CACHE[key] = image['#text']
            for fn in Track.COVER_PENDING[key]
              fn(null, image['#text'])
            Track.COVER_PENDING[key] = null
            return
        return

      error   : (code, message) ->
        error = new Error message
        error.code = code

        for fn in Track.COVER_PENDING[key]
          fn(error)
        Track.COVER_PENDING[key] = null

    this

  clientVoted: (clientId) ->
    votesHash = @get('votesHash')
    return false unless votesHash
    vote = votesHash[clientId]
    return if vote then +vote else 0

module.exports = Track
