'use strict'

bb = require 'backbone'

class SearchBar extends bb.View
  constructor: ->
    super arguments...

    @form       = @$el.find 'form'
    @input      = @$el.find '.search-input'
    @button     = @$el.find '.search-button'
    @buttonIcon = @button.find '.icon'

    @closeVisible = no

  el: '.search-wrap'
  input: null

  events:
    'submit form'          : 'submit'
    'click .search-button' : 'onClose'

  showClose: (show) ->
    show = yes unless 'boolean' == typeof show

    if show
      @buttonIcon
        .removeClass 'icon-magnifier'
        .addClass 'icon-close'
    else
      @buttonIcon
        .removeClass 'icon-close'
        .addClass 'icon-magnifier'

    @closeVisible = show
    this

  submit: (event) ->
    event.preventDefault()

    @input.blur()
    @trigger 'submit', @input.val()
    this

  render: (value) ->
    @input.val value
    this

  reset: ->
    @input.val ''
    @showClose no
    @trigger 'reset'
    this

  onClose: ->
    if @closeVisible
      @trigger 'close'
    else
      @form.submit()
    this

module.exports = SearchBar
