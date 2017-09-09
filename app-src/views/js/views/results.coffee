'use strict'

Panel       = require './panel.coffee'
ResultsList = require './results-list.coffee'
PanelLabel  = require './panel-label.coffee'

class Results extends Panel
  constructor: ->
    super arguments...

    @list  = new ResultsList
    @label = new PanelLabel el : '.panel-label-results'

  el: '.panel-results'

module.exports = Results
