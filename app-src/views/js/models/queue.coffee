'use strict'

Tracklist = require './tracklist.coffee'

class Queue extends Tracklist
  comparator: (a, b) ->
    if a.get('votes') == b.get('votes')
      return a.get('updated') - b.get('updated')
    return b.get('votes') - a.get('votes')

module.exports = Queue
