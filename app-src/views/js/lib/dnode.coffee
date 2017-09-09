'use strict'

module.exports = (app) ->
  return {
    queue          :
      trackChanged : (track) ->
        app.emit 'queue:trackChanged', track

      trackRemoved : (track) ->
        app.emit 'queue:trackRemoved', track

      refresh      : (tracks) ->
        app.emit 'queue:refresh', tracks

    current        :
      set          : (track, position) ->
        app.emit 'current:set', track, position

    state          :
      change       : (state, position) ->
        app.emit "state:#{state}", position
  }

