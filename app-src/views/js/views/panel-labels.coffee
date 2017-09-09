'use strict'

bb         = require 'backbone'
PanelLabel = require './panel-label.coffee'

class PanelLabels extends bb.Collection
  constructor: ->
    super arguments...

    @on 'focus', @focusLabel

  model: PanelLabel

  focusLabel: (label) ->
    for label in @models
      label.hide()

    label.show()
    this

module.exports = PanelLabels
