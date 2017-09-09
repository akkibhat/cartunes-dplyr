'use strict'

bb = require 'backbone'

class PanelLabel extends bb.View
  hide: ->
    @$el.removeClass 'panel-label-focus'

  show: ->
    @$el.addClass 'panel-label-focus'

  focus: ->
    @$el.parent().find('.panel-label-focus').removeClass 'panel-label-focus'
    @show()
    this

module.exports = PanelLabel
