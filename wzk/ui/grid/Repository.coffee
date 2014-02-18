goog.provide 'wzk.ui.grid.Repository'

goog.require 'goog.net.EventType'

class wzk.ui.grid.Repository

  ###*
    @param {wzk.resource.Client} client
  ###
  constructor: (@client) ->

  ###*
    @param {wzk.resource.Query} query for filtering
    @param {function(Array, Object)} onLoad
  ###
  load: (query, onLoad) ->

    @client.find query.composePath(), onLoad, null, query

  ###*
    @param {Object} model
    @param {function()} onSuccess
  ###
  delete: (model, onSuccess) ->
    @client.delete model, onSuccess
