'use strict'

bb = require 'backbone'

class Panel extends bb.View
  hide: ->
    @$el.removeClass 'panel-focus'
    this

  show: ->
    @$el.addClass 'panel-focus'
    this

  focus: ->
    @label.focus()

    @$el.parent().find('.panel-focus').removeClass 'panel-focus'
    @show()

    this

module.exports = Panel
