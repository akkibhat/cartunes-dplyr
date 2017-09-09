'use strict'

bb    = require 'backbone'
Track = require './track.coffee'

class Tracklist extends bb.Collection
  constructor: ->
    super arguments...

    @on 'remove', @onRemove
    @on 'reset', @onReset

  model: Track

  onRemove: (model) ->
    model.cleanup()

  onReset: (coll, opts) ->
    for model in opts.previousModels
      model.cleanup()

module.exports = Tracklist
