goog.require 'goog.Uri'

class wzk.resource.Query

  ###*
    @param {string} path
  ###
  constructor: (@path) ->
    @order = null
    @direction = null
    @base ?= 10
    @offset ?= 0
    @uri = new goog.Uri @path

  ###*
    @return {string}
  ###
  composePath: ->
    @uri.toString()
