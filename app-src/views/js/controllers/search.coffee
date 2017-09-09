'use strict'

AppController = require './app.coffee'

class SearchController extends AppController
  constructor: (app) ->
    super app, 'search'

    @searchBar = @cartunes.searchBar

    @searchBar.on 'submit', (query) =>
      @submit query

    @searchBar.on 'close', =>
      @reset()

    @router.on 'route:search', (query) =>
      @search query

  submit: (query) ->
    safeQuery = encodeURIComponent query

    if safeQuery
      @emit 'query', safeQuery
    else
      @reset()

  search: (query) ->
    @searchBar.render query
    @searchBar.showClose yes

  reset: ->
    @searchBar.reset()
    @emit 'reset'

module.exports = SearchController
