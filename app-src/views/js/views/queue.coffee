'use strict'

Panel     = require './panel.coffee'
QueueList = require './queue-list.coffee'
PanelLabel  = require './panel-label.coffee'

class Queue extends Panel
  constructor: ->
    super arguments...

    @list  = new QueueList
    @label = new PanelLabel el : '.panel-label-queue'

  el: '.panel-queue'

module.exports = Queue
