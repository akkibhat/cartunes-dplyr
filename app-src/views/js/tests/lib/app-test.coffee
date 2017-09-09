'use strict'

assert = require 'assert'
App    = require '../../lib/app.coffee'
app    = null

describe 'App', ->
  it 'should be a constructor', ->
    app = new App

  it 'should be able to set settings', ->
    assert.equal 'value', app.set('test', 'value')
    assert.equal 'value', app.settings.test

  it 'should get settings', ->
    assert.equal 'value', app.set('test')
