'use strict'

Emitter = require('events').EventEmitter

#
# A settings registry for pulling an app together
#
# @constructor
#
class App extends Emitter
  settings: {}

  #
  # Get / set a setting
  #
  # @param           String key
  # @param @optional mixed  value
  # @return mixed
  #
  set: (key, value) ->
    if undefined == value
      return @settings[key]

    return @settings[key] = value

module.exports = App
