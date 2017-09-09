'use strict'

assert = require 'assert'
bb     = require 'backbone'
cartunes  = require '../../views/cartunes.coffee'

describe 'cartunes', ->
  it 'extends backbone.Epoxy.View', ->
    assert.equal 'function', typeof cartunes::__proto__.getBinding
