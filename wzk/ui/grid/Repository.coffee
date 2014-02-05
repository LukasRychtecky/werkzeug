goog.provide 'wzk.ui.grid.Repository'

goog.require 'goog.net.EventType'

class wzk.ui.grid.Repository

  ###*
    @param {wzk.resource.Client} client
    @param {string} resource
  ###
  constructor: (@client, @resource) ->

  ###*
    @param {Object} query for filtering
      base: {number}
      offset: {number}
    @param {function(Array, Object)} onLoad
  ###
  load: (query, onLoad) ->
    query.offset ?= 0
    query.base ?= 10

    @client.find @resource, onLoad, null, query

  ###*
    @param {Object} model
    @param {function()} onSuccess
  ###
  delete: (model, onSuccess) ->
    @client.delete model, onSuccess
