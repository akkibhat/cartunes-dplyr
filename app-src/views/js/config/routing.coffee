'use strict'

CurrentController  = require '../controllers/current.coffee'
SearchController  = require '../controllers/search.coffee'
QueueController   = require '../controllers/queue.coffee'
ResultsController = require '../controllers/results.coffee'

module.exports = (app) ->
  router  = app.set 'router'

  current = new CurrentController app
  search  = new SearchController app
  results = new ResultsController app
  queue   = new QueueController app

  search.on 'query', (safeQuery) ->
    router.navigate "search/#{safeQuery}", trigger : yes

  search.on 'reset', ->
    router.navigate '', trigger : yes
