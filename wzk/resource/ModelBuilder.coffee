goog.require 'wzk.resource.Model'

class wzk.resource.ModelBuilder

  constructor: ->

  ###*
    @param {Object|Array} dataOrArray
    @return {wzk.resource.Model|Array.<wzk.resource.Model>}
  ###
  build: (dataOrArray) ->
    if goog.isArray dataOrArray
      return (@buildModel obj for obj in dataOrArray)

    @buildModel dataOrArray

  ###*
    @param {Object} data
    @return {wzk.resource.Model}
  ###
  buildModel: (data) ->
    new wzk.resource.Model data
