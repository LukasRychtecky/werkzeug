goog.require 'goog.object'

###*
  Wrap JSON as a model, add to string ability.
###
class wzk.resource.Model

  @TO_S = '_obj_name'

  ###*
    @param {Object} _data
  ###
  constructor: (@_data) ->
    @[k] = v for k, v of @_data

  ###*
    @return {string}
  ###
  toString: ->
    return @['_autocomplete_value'] if @['_autocomplete_value']?
    return @[wzk.resource.Model.TO_S] if @[wzk.resource.Model.TO_S]
    return goog.object.getAnyValue(@_data)
