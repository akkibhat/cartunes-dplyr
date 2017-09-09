'use strict'

bb = require 'backbone'

SearchBar  = require './search-bar.coffee'
Results    = require './results.coffee'
Queue      = require './queue.coffee'
CurrentBar = require './current-bar.coffee'

class cartunes extends bb.View
  constructor: ->
    super arguments...

    @searchBar  = new SearchBar
    @results    = new Results
    @queue      = new Queue
    @currentBar = new CurrentBar

module.exports = cartunes
