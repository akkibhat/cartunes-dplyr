'use strict'

bb = require 'backbone'

class CurrentBar extends bb.View
  constructor: ->
    super arguments...

    @progressBar = @$el.find '.progress-bar'
    @cover       = @$el.find '.track-cover'
    @name        = @$el.find '.track-name'
    @artist      = @$el.find '.track-artist'
    @votes       = @$el.find '.track-votes'
    @buttons     = @$el.find '.button'
    @buttonUp    = @$el.find '.button-up'
    @buttonDown  = @$el.find '.button-down'

    @noCover     = @cover.attr 'src'

  el: '.controls-wrap'

  events:
    'click .button-up'   : 'voteClicked'
    'click .button-down' : 'downvoteClicked'

  render: (track) ->
    @model = track

    @cover.attr 'src', @noCover
    @name.html track.get 'name'
    @artist.html track.get('artists')[0]?.name || ''
    @votes.html track.get 'votes'

    voted = track.clientVoted bb.app.set 'client id'

    @buttons.prop 'disabled', no
    if 1 == voted
      @buttonUp.prop 'disabled', yes
    else if -1 == voted
      @buttonDown.prop 'disabled', yes

    @trigger 'queue:cover'

    this

  setPosition: (percent) ->
    @progressBar.css width : "#{percent}%"

    this

  setCover: (url) ->
    @cover.attr 'src', url
    this

  voteClicked: ->
    @trigger 'click:vote'
    this

  downvoteClicked: ->
    @trigger 'click:downvote'
    this

  clear: ->
    @cover.attr 'src', @noCover
    @name.html ''
    @artist.html ''
    @votes.html 0
    @buttons.prop 'disabled', yes
    @setPosition 0

    this

module.exports = CurrentBar
