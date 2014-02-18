goog.require 'wzk.resource.Model'
goog.require 'wzk.resource.ModelBuilder'

class wzk.ui.grid.CellFormatter

  constructor: ->

  ###*
    @param {Object} model
    @param {string|null|undefined=} property
    @return {string}
  ###
  format: (model, property = null) ->
    value = ''
    if property?
      value = @lookupValue model, property
    else
      value = model[property]
    @flat value

  ###*
    @protected
    @param {Array.<wzk.resource.Model>|string} value
    @return {string}
  ###
  flat: (value) ->
    text = ''
    if goog.isArray value
      text = (@toStr obj for obj in value).join(', ')
    else
      text = @toStr value
    text

  ###*
    @protected
    @param {*} value
    @return {string}
  ###
  toStr: (value) ->
    value = new wzk.resource.Model value if goog.isObject value
    String value

  ###*
    @protected
    @param {Object} model
    @param {string} property
    @return {Array.<Object>|string}
  ###
  lookupValue: (model, property) ->
    path = property.split '__'
    obj = model
    while path.length > 0
      prop = path.shift()
      if obj[prop]?
        obj = obj[prop]
    obj
