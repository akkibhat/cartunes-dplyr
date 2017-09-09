'use strict'

bb = require 'backbone'

class cartunesRouter extends bb.Router
  routes:
    ''              : 'queue'
    'search/:query' : 'search'

module.exports = cartunesRouter
