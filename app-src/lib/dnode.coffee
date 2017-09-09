'use strict'

helpers = require './mopidy.js'
crypto  = require 'crypto'

module.exports = (app) ->
  clients    = []
  mopidy     = app.set 'mopidy'
  db         = app.set 'db'

  app.set 'dnode clients', clients

  return (remote, dnode) ->
    return dnode.end() unless dnode.stream && dnode.stream.remoteAddress
    clients.push remote

    controller = app.set 'mopidy controller'
    addr = crypto.createHash 'sha1'
    addr.update dnode.stream.remoteAddress
    addr = addr.digest 'hex'

    dnode.once 'end', ->
      index = clients.indexOf remote
      clients.splice index, 1
      addr = controller = remote = dnode = null
      return

    return {
      db         :
        search   : (query, done) ->
          helpers.search mopidy, query, done
          return

      queue      :
        add      : (track) ->
          app.emit 'queue:add', track, addr
          return

        downvote : (track) ->
          app.emit 'queue:downvote', track, addr
          return

        get      : (done) ->
          controller.getQueue done
          return

      current    :
        vote     : (clientId) ->
          app.emit 'current:vote', clientId || addr
          return

        downvote : (clientId) ->
          app.emit 'current:downvote', clientId || addr
          return

        get      : (done) ->
          controller.getPlaying done
          return

      clients    :
        getId    : (done) ->
          done null, addr
          return
    }
